// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_hosting_module/global/global.h"
#include "nem_hosting_module/service/account_service.h"
#include "nem_hosting_module/service/auth_service.h"
#include "nem_hosting_module/service/feedback_service.h"
#include "nem_hosting_module/service/meeting_service.h"
#include "nem_hosting_module/service/premeeting_service.h"
#include "nem_hosting_module/service/setting_service.h"
#include "nem_hosting_module_core/manager/service_manager.h"
#include "nem_hosting_module_protocol/protocol/global_protocol.h"
#include "nem_hosting_module_protocol/protocol/settings_protocol.h"

#if defined(WIN32)
#include <Windows.h>
#include <shellapi.h>
#define MEETING_HOST_EXECUTOR "NetEaseMeetingClient.exe"
#include "nem_hosting_module/base/launch_win32.h"
#else
#include <sys/shm.h>
#include <algorithm>
#include "nem_hosting_module/base/lunch_mac.h"
#endif

#define SHARED_TEXT_SIZE 2048

typedef struct tagSharedData {
    char text[SHARED_TEXT_SIZE] = {0};
} SharedData;

// std::unique_ptr<NS_NEM_SDK_HOSTMOD::Global> g_global_ = nullptr;
NS_I_NEM_SDK::NEMeetingKit* NS_I_NEM_SDK::NEMeetingKit::getInstance() {
    if (NS_NEM_SDK_HOSTMOD::NEMeetingSDKIMP::global_object_ == nullptr) {
        NS_NEM_SDK_HOSTMOD::NEMeetingSDKIMP::global_object_ = std::make_shared<NS_NEM_SDK_HOSTMOD::NEMeetingSDKIMP>();
        NS_NEM_SDK_HOSTMOD::NEMeetingSDKIMP::global_object_->AttachUnInit([]() { NS_NEM_SDK_HOSTMOD::NEMeetingSDKIMP::global_object_ = nullptr; });
    }

    if (!NS_NEM_SDK_HOSTMOD::NEMeetingSDKIMP::global_object_->IsRunning()) {
        NS_NEM_SDK_HOSTMOD::NEMeetingSDKIMP::global_object_->Start();
        // while (!NS_NEM_SDK_HOSTMOD::NEMeetingSDKIMP::global_object_->IsRunning());
    }
    return NS_NEM_SDK_HOSTMOD::NEMeetingSDKIMP::global_object_.get();
}

NNEM_SDK_HOSTING_MODULE_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

std::shared_ptr<NEMeetingSDKIMP> NEMeetingSDKIMP::global_object_ = nullptr;
NEMeetingSDKIMP::NEMeetingSDKIMP()
    : IService(ServiceID::SID_Global)
    , NS_NIPCLIB::IPCThread("NEMeetingSDKIMP")
    , inited_(false)
    , initting_(false)
    , notify_exception_(false)
    , ipc_server_(nullptr)
    , uninit_callback_(nullptr)
    , exception_handler_(nullptr)
    , log_callback_(nullptr) {}
NEMeetingSDKIMP::~NEMeetingSDKIMP() {}

void NEMeetingSDKIMP::initialize(const NEMeetingKitConfig& config, const NEInitializeCallback& cb) {
    if (isInitialized()) {
        if (nullptr != cb)
            cb(NEErrorCode::ERROR_CODE_SUCCESS, "NEMeetingKit already initialize.");
        return;
    }
    if (config.getAppKey().empty()) {
        if (nullptr != cb)
            cb(NEErrorCode::ERROR_CODE_FAILED, "Application key is empty.");
        return;
    }
    auto instance = NEMeetingKit::getInstance();
    global_config_ = config;
    int keepAliveInterval = global_config_.getKeepAliveInterval();
    if (keepAliveInterval >= 0 && keepAliveInterval < 3) {
        global_config_.setKeepAliveInterval(3);
    }
    TaskLoop()->PostTask(NS_NIPCLIB::Bind(&NEMeetingSDKIMP::InvokeInit, this, cb));
}

void NEMeetingSDKIMP::unInitialize(const NEUnInitializeCallback& cb) {
    if (!inited_ && !initting_) {
        notify_exception_ = false;
        initting_ = false;
        if (nullptr != cb)
            cb(NEErrorCode::ERROR_CODE_SUCCESS, "NEMeetingKit already uninitialize.");
        return;
    }

    notify_exception_ = false;
    inited_ = false;
    initting_ = false;

    UnInitRequest request;
    NEUnInitializeCallback cbTmp;
    SendData(GlobalCID::GlobalCID_UnInit, request, IPCAsyncResponseCallback(cbTmp));
    std::this_thread::sleep_for(std::chrono::milliseconds(100));
    if (ipc_server_ != nullptr) {
        ipc_server_->Close();
        ipc_server_->Stop();
    }
    auto global = shared_from_this();
    if (global) {
        global->Stop();
        global->Join();
    }
    ServiceManager<NS_NIPCLIB::IPCServer>::Clear();
    if (auth_service_)
        auth_service_->OnRelease();
    if (meeting_service_)
        meeting_service_->OnRelease();
    if (setting_service_)
        setting_service_->OnRelease();
    if (account_service_)
        account_service_->OnRelease();
    if (feedback_service_)
        feedback_service_->OnRelease();
    if (premeeting_service_)
        premeeting_service_->OnRelease();
    if (global) {
        global->OnRelease();
    }

    if (auth_service_)
        auth_service_.reset();
    if (meeting_service_)
        meeting_service_.reset();
    if (setting_service_)
        setting_service_.reset();
    if (account_service_)
        account_service_.reset();
    if (feedback_service_)
        feedback_service_.reset();
    if (premeeting_service_)
        premeeting_service_.reset();

    if (global) {
        global->SetProcThread(nullptr);
        global->SetIPCController(nullptr);
    }

    if (cb != nullptr)
        cb(NEErrorCode::ERROR_CODE_SUCCESS, "Uninit success.");
    if (uninit_callback_ != nullptr)
        uninit_callback_();
}

bool NEMeetingSDKIMP::isInitialized() {
    return inited_;
}

void NEMeetingSDKIMP::activeWindow(/*bool bRaise, */ const NEActiveWindowCallback& cb) {
    ActiveWindowRequest request;
    request.bRaise_ = true;  // bRaise;
    SendData(GlobalCID::GlobalCID_ActiveWindow, request, IPCAsyncResponseCallback(cb));
}

void NEMeetingSDKIMP::setSoftwareRender(bool bSoftware, const NEEmptyCallback& cb) {
#if defined(_WIN32)
    std::string sdk_path = global_config_.getAppInfo()->SDKPath();
    if (sdk_path.empty()) {
        CHAR strModule[2048] = {0};
        GetModuleFileNameA(NULL, strModule, 2048);  // 得到当前模块路径
        sdk_path = strModule;
    }
    sdk_path = sdk_path.substr(0, sdk_path.find_last_of('\\'));
    sdk_path.append("\\config\\custom.ini");

    BOOL bRet = WritePrivateProfileStringA("Render", "GraphicsApi", bSoftware ? "5" : "0", sdk_path.c_str());
    if (cb) {
        cb(0 != bRet ? NEErrorCode::ERROR_CODE_SUCCESS : NEErrorCode::ERROR_CODE_FAILED, 0 != bRet ? "" : "error: " + std::to_string(GetLastError()));
    }
#else
    if (cb) {
        cb(NEErrorCode::ERROR_CODE_FAILED, "error: not support");
    }
#endif  //
}

void NEMeetingSDKIMP::isSoftwareRender(const NEBoolCallback& cb) {
#if defined(_WIN32)
    if (cb) {
        std::string sdk_path = global_config_.getAppInfo()->SDKPath();
        if (sdk_path.empty()) {
            CHAR strModule[2048] = {0};
            GetModuleFileNameA(NULL, strModule, 2048);  // 得到当前模块路径
            sdk_path = strModule;
        }
        sdk_path = sdk_path.substr(0, sdk_path.find_last_of('\\'));
        sdk_path.append("\\config\\custom.ini");

        UINT iRet = GetPrivateProfileIntA("Render", "GraphicsApi", 0, sdk_path.c_str());
        cb(NEErrorCode::ERROR_CODE_SUCCESS, "", 5 == iRet);
    }
#else
    if (cb) {
        cb(NEErrorCode::ERROR_CODE_FAILED, "error: not support", false);
    }
#endif  //
}

void NEMeetingSDKIMP::queryKitVersion(const NEQueryKitVersionCallback& cb) {
    QuerySDKVersionRequest request;
    SendData(GlobalCID::GlobalCID_QuerySDKVersion, request, IPCAsyncResponseCallback(cb));
}

void NEMeetingSDKIMP::switchLanguage(NEMeetingLanguage language, const NEEmptyCallback& cb) {
    SettingsIntRequest request;
    request.value_ = (int)language;
    SendData(GlobalCID::GlobalCID_SwitchLanguage, request, IPCAsyncResponseCallback(cb));
}

NEMeetingService* NEMeetingSDKIMP::getMeetingService() {
    if (inited_)
        return meeting_service_.get();
    return nullptr;
}

NEAuthService* NEMeetingSDKIMP::getAuthService() {
    if (inited_)
        return auth_service_.get();
    return nullptr;
}

NESettingsService* NEMeetingSDKIMP::getSettingsService() {
    if (inited_)
        return setting_service_.get();
    return nullptr;
}

NEAccountService* NEMeetingSDKIMP::getAccountService() {
    if (inited_)
        return account_service_.get();
    return nullptr;
}

NEFeedbackService* NEMeetingSDKIMP::getFeedbackService() {
    if (inited_)
        return feedback_service_.get();
    return nullptr;
}

NEPreMeetingService* nem_sdk_hosting_module::NEMeetingSDKIMP::getPremeetingService() {
    if (inited_)
        return premeeting_service_.get();
    return nullptr;
}

NEMeetingKitConfig NEMeetingSDKIMP::GetInitConfig() const {
    return global_config_;
}

void NEMeetingSDKIMP::WriteLog(LogLevel level, const std::string& strLog) {
    if (log_callback_) {
        log_callback_(level, strLog);
    }
}

void NEMeetingSDKIMP::InvokeInit(const NEInitializeCallback& cb) {
    if (initting_ || inited_) {
        if (cb) {
            cb(initting_ ? ERROR_CODE_FAILED : ERROR_CODE_SUCCESS, initting_ ? "already initializing" : "");
        }
        return;
    }
    if (!initting_)
        initting_ = true;

    if (ipc_server_ == nullptr) {
        ipc_server_ = std::make_shared<NS_NIPCLIB::IPCServer>();
    }

    init_callback_ = std::move(cb);
    ipc_server_->AttachInit(
        NS_NIPCLIB::Bind(&NEMeetingSDKIMP::OnIPCServerInit, this, cb, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3));
    ipc_server_->AttachReady(NS_NIPCLIB::Bind(&NEMeetingSDKIMP::OnIPCServerReady, this, cb));
    ipc_server_->AttachReceiveData(NS_NIPCLIB::Bind(&NEMeetingSDKIMP::OnReceiveIPCData, this, std::placeholders::_1));
    ipc_server_->AttachClientClose(NS_NIPCLIB::Bind(&NEMeetingSDKIMP::OnIPCClientClosed, this));
    ipc_server_->AttachClose(NS_NIPCLIB::Bind(&NEMeetingSDKIMP::OnIPCClosed, this));
    ipc_server_->Init();
    ipc_server_->Start();
}

void NEMeetingSDKIMP::OnIPCServerInit(const NEInitializeCallback& cb, bool ret, const std::string& host, int port) {
    LOG_IPCSERVICE_INFO(std::string("OnIPCServerInit, ret: ")
                            .append(ret ? "true" : "false")
                            .append(", host: ")
                            .append(host)
                            .append(", port: ")
                            .append(std::to_string(port)));
    IThread::SetLogger(log_callback_);
    if (!ret) {
        PostTaskToProcThread([this, cb]() {
            if (cb != nullptr)
                cb(NEErrorCode::ERROR_CODE_FAILED, "ipc server init error");
        });
        return;
    }

    auto global = shared_from_this();
    auth_service_ = std::make_shared<NEAuthServiceIMP>();
    meeting_service_ = std::make_shared<NEMeetingServiceIMP>();
    setting_service_ = std::make_shared<NESettingsServiceIMP>();
    account_service_ = std::make_shared<NEAccountServiceIMP>();
    feedback_service_ = std::make_shared<NEFeedbackServiceIMP>();
    premeeting_service_ = std::make_shared<NEPreMeetingServiceIMP>();

    global->SetProcThread(global);
    meeting_service_->SetProcThread(global);
    auth_service_->SetProcThread(global);
    setting_service_->SetProcThread(global);
    account_service_->SetProcThread(global);
    feedback_service_->SetProcThread(global);
    premeeting_service_->SetProcThread(global);

    global->SetIPCController(ipc_server_);
    meeting_service_->SetIPCController(ipc_server_);
    auth_service_->SetIPCController(ipc_server_);
    setting_service_->SetIPCController(ipc_server_);
    account_service_->SetIPCController(ipc_server_);
    feedback_service_->SetIPCController(ipc_server_);
    premeeting_service_->SetIPCController(ipc_server_);

    global->OnLoad();
    auth_service_->OnLoad();
    meeting_service_->OnLoad();
    setting_service_->OnLoad();
    account_service_->OnLoad();
    feedback_service_->OnLoad();
    premeeting_service_->OnLoad();

    ServiceManager<NS_NIPCLIB::IPCServer>::RegisterService(global);
    ServiceManager<NS_NIPCLIB::IPCServer>::RegisterService(auth_service_);
    ServiceManager<NS_NIPCLIB::IPCServer>::RegisterService(meeting_service_);
    ServiceManager<NS_NIPCLIB::IPCServer>::RegisterService(setting_service_);
    ServiceManager<NS_NIPCLIB::IPCServer>::RegisterService(account_service_);
    ServiceManager<NS_NIPCLIB::IPCServer>::RegisterService(feedback_service_);
    ServiceManager<NS_NIPCLIB::IPCServer>::RegisterService(premeeting_service_);
    SetKeepAliveInterval(global_config_.getKeepAliveInterval());

    if (ret) {
        PostTaskToProcThread([this, port, cb]() {
            std::string shared_key = global_config_.getAppInfo()->OrganizationName();
            shared_key.append(global_config_.getAppInfo()->ApplicationName());
            shared_key.append(global_config_.getAppInfo()->ProductName());
#if defined(WIN32)
            // 关闭上一次的进程
            HANDLE lhShareMemory;
            lhShareMemory = OpenFileMappingA(FILE_MAP_READ, false, shared_key.c_str());
            if (lhShareMemory != NULL) {
                auto mem = (char*)MapViewOfFile(lhShareMemory, FILE_MAP_READ, 0, 0, sizeof(decltype(GetCurrentProcessId())));
                if (mem != NULL) {
                    DWORD CurrentProcessId = 0;
                    HANDLE SDKProcessHandle;
                    memcpy(&CurrentProcessId, mem, sizeof(decltype(GetCurrentProcessId())));
                    LOG_IPCSERVICE_INFO("Latest processID is: " + std::to_string(CurrentProcessId));
                    SDKProcessHandle = OpenProcess(PROCESS_ALL_ACCESS, FALSE, CurrentProcessId);
                    if (SDKProcessHandle != NULL) {
                        HANDLE hToken;
                        LUID sedebugnamevalue;
                        TOKEN_PRIVILEGES tkp;
                        if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken)) {
                            if (LookupPrivilegeValue(NULL, SE_DEBUG_NAME, &sedebugnamevalue)) {
                                tkp.PrivilegeCount = 1;
                                tkp.Privileges[0].Luid = sedebugnamevalue;
                                tkp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
                                if (AdjustTokenPrivileges(hToken, FALSE, &tkp, sizeof tkp, NULL, NULL)) {
                                    BOOL ret = ::TerminateProcess(SDKProcessHandle, 0);
                                    std::string strTmp = "successful.";
                                    if (TRUE != ret) {
                                        strTmp = "unsuccessful. GetLastError(): " + std::to_string(GetLastError());
                                    }
                                    LOG_IPCSERVICE_INFO("Latest processID " + std::to_string(CurrentProcessId) + " is closed: " + strTmp);
                                } else {
                                    CloseHandle(hToken);
                                }
                            } else {
                                CloseHandle(hToken);
                            }
                        }
                    }
                    UnmapViewOfFile(mem);
                }
                CloseHandle(lhShareMemory);
            }
            std::string sdk_path = global_config_.getAppInfo()->SDKPath();
            char module_name[2048];
            GetModuleFileNameA(NULL, module_name, 2048);
            std::string str_module_name = module_name;
            str_module_name = str_module_name.substr(0, str_module_name.find_last_of('\\'));
            if (sdk_path.empty())
                sdk_path = str_module_name;
            sdk_path.append("\\").append(MEETING_HOST_EXECUTOR);

            std::string commond_line;  // ("--plugin");
            commond_line.append("--port=\"").append(std::to_string(port)).append("\"");
            ProcessLauncher::LaunchParams launch_parameter;
            launch_parameter.process_path = sdk_path;
            launch_parameter.command_line = commond_line;
            launch_parameter.working_dir = global_config_.getAppInfo()->SDKPath().empty() ? str_module_name : global_config_.getAppInfo()->SDKPath();
            if (!ProcessLauncher::LaunchProcess(launch_parameter)) {
                initting_ = false;
                LOG_IPCSERVICE_ERROR("Launch process [" + sdk_path + "] is not successed, GetLastError() is: " + std::to_string(GetLastError()));
                if (cb) {
                    cb(NEErrorCode::ERROR_CODE_FAILED, "Load sdk error");
                }
            } else {
                LOG_IPCSERVICE_INFO("Launch process [" + sdk_path + "] is successed.");
            }
#else
            SharedData* shared;
            int process_id = 0;
            std::hash<std::string> hash_fn;
            size_t str_hash = hash_fn(shared_key);
            std::cout << "Open shared memory address: " << str_hash << '\n';

            do {
                auto shmid = shmget(str_hash, sizeof(SharedData), 0666 | IPC_CREAT);
                if (shmid == -1)
                    break;

                std::cout << "Get shared memory address successfully." << std::endl;

                auto shm = shmat(shmid, 0, 0);
                if (shm == (void*)-1)
                    break;

                std::cout << "Attach shared memory address successfully." << shm << std::endl;

                shared = (SharedData*)shm;
                std::string str_shared_memory = shared->text;
                if (str_shared_memory.length() != 0) {
                    std::cout << "Got shared memory data: " << str_shared_memory << std::endl;
                    process_id = std::stoi(str_shared_memory.c_str());
                } else {
                    std::cout << "Shared memory data is empty." << std::endl;
                }

                LOG_IPCSERVICE_INFO("Latest processID is: " + std::to_string(process_id));

                int process_id_new = 0;
                memset(shared->text, 0, SHARED_TEXT_SIZE);
                if (!lunchProcess(global_config_.getAppInfo()->SDKPath(), process_id_new, port, process_id)) {
                    initting_ = false;
                    if (cb) {
                        cb(NEErrorCode::ERROR_CODE_FAILED, "Load sdk error");
                    }
                } else {
                    std::string strProcessId = std::to_string(process_id_new);
                    strncpy(shared->text, strProcessId.c_str(), std::min((int)strProcessId.length(), (int)(SHARED_TEXT_SIZE - 1)));
                }
                shmdt(shm);
            } while (false);
#endif
        });
    }
}

void NEMeetingSDKIMP::OnIPCServerReady(const NEInitializeCallback& cb) {
    LOG_IPCSERVICE_INFO("OnIPCServerReady start.");
    PostTaskToProcThread([this, cb]() {
        LOG_IPCSERVICE_INFO("OnIPCServerReady .......");
        InitRequest request;
        request.init_config_ = global_config_;
        SendData(GlobalCID::GlobalCID_Init, request, IPCAsyncResponseCallback(cb));
    });
}

void NEMeetingSDKIMP::OnReceiveIPCData(const NS_NIPCLIB::IPCData& data) {
    LOG_IPCSERVICE_INFO("OnReceiveIPCData.");
    NEMIPCProtocol protocol;
    if (protocol.Parse(data)) {
        auto service = ServiceManager<NS_NIPCLIB::IPCServer>::GetService(protocol.SID());
        if (service != nullptr) {
            LOG_IPCSERVICE_INFO("OnReceiveIPCData, sid: " + std::to_string(protocol.SID()) + ", cid: " + std::to_string(protocol.CID()) + ", data: ");
            if (protocol.SN() > 0) {
                IPCAsyncResponseCallback cb;
                if (IPCAsyncRequestManager::GetInstance()->GetResponseCallback(protocol.SN(), cb))
                    service->OnReceivePack(protocol.CID(), protocol.BodyText(), cb);
            } else {
                service->OnReceivePack(protocol.CID(), protocol.BodyText(), protocol.SN());  // 认为是推送包
            }
        }
    }
}

void NEMeetingSDKIMP::OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb) {
    LOG_IPCSERVICE_INFO("OnPack cid: " + std::to_string(cid) + ", data: ");
    switch (cid) {
        case GlobalCID::GlobalCID_Init_CB:
            read_init_ = true;
            OnPack_InitCallback(data, cb);
            init_callback_ = nullptr;
            read_init_thread_ = nullptr;
            break;
        case GlobalCID::GlobalCID_UnInit_CB: {
            UnInitResponse response;
            if (response.Parse(data)) {
                NEUnInitializeCallback uninit_cb = cb.GetResponseCallback<NEUnInitializeCallback>();
                if (uninit_cb != nullptr) {
                    global_config_.setAppKey("");
                    uninit_cb(response.error_code_, "");
                }
            }
        } break;
        case GlobalCID_QuerySDKVersion_CB: {
            QuerySDKVersionResponse response;
            if (response.Parse(data)) {
                NEQueryKitVersionCallback query_cb = cb.GetResponseCallback<NEQueryKitVersionCallback>();
                if (query_cb != nullptr)
                    query_cb(response.error_code_, response.error_msg_, response.sdkVersion);
            }
        } break;
        case GlobalCID_ActiveWindow_CB: {
            ActiveWindowResponse response;
            NEActiveWindowCallback active_cb = cb.GetResponseCallback<NEActiveWindowCallback>();
            if (active_cb)
                active_cb(ERROR_CODE_SUCCESS, "");
        } break;
        case GlobalCID_SwitchLanguage_CB: {
            SettingsIntResponse response;
            if (response.Parse(data)) {
                NEEmptyCallback switchLanguage_cb = cb.GetResponseCallback<NEEmptyCallback>();
                if (switchLanguage_cb != nullptr)
                    switchLanguage_cb(response.error_code_, response.error_msg_);
            }
        } break;
        default:
            break;
    }
}

void NEMeetingSDKIMP::OnPack_InitCallback(const std::string& data, const IPCAsyncResponseCallback& cb) {
    LOG_IPCSERVICE_INFO("OnPack_InitCallback, data: ");
    initting_ = false;
    bool bRet = true;
    InitResponse response;
    if (response.Parse(data)) {
        bRet = NEErrorCode::ERROR_CODE_SUCCESS == response.error_code_;
    } else {
        bRet = false;
        response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        response.error_msg_ = "InitResponse parse failed";
    }

    inited_ = bRet;
    notify_exception_ = bRet;
    NEInitializeCallback init_cb = cb.GetResponseCallback<NEInitializeCallback>();
    if (init_cb != nullptr)
        init_cb(response.error_code_, response.error_msg_);

    if (!bRet) {
        unInitialize_thread_ = std::make_shared<std::thread>([this]() {
            inited_ = true;
            unInitialize(nullptr);
        });
    }
}

void NEMeetingSDKIMP::OnIPCClosed() {
    if (exception_handler_ != nullptr) {
        if (notify_exception_) {
            exception_handler_(NEException(NEExceptionCode::kAppDisconnect, "Hosting module server closed"));
        }
    }
}

void NEMeetingSDKIMP::OnIPCClientClosed() {
    if (exception_handler_ != nullptr) {
        if (notify_exception_ || initting_) {
            exception_handler_(NEException(NEExceptionCode::kUISDKDisconnect, "UI SDK disconnected, maybe the UI SDK crashed"));
        }
    }
}

NNEM_SDK_HOSTING_MODULE_END_DECLS
