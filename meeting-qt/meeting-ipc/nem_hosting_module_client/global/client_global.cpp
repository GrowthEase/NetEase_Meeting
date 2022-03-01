/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module_client/global/client_global.h"
#include "nem_hosting_module_core/manager/service_manager.h"
#include "nem_hosting_module_protocol/protocol/global_protocol.h"
#include "nem_hosting_module_client/service/client_meeting_service.h"
#include "nem_hosting_module_client/service/client_auth_service.h"
#include "nem_hosting_module_client/service/client_setting_service.h"
#include "nem_hosting_module_client/service/client_account_service.h"
#include "nem_hosting_module_client/service/client_feedback_service.h"
#include "nem_hosting_module_client/service/client_premeeting_service.h"
#if defined(WIN32)
#include <Windows.h>
#else
#include <sys/shm.h>
#endif

#define SHARED_TEXT_SIZE 2048

typedef struct tagSharedData
{
    char text[SHARED_TEXT_SIZE];
} SharedData;

NS_I_NEM_SDK::NEMeetingSDKIPCClient* NS_I_NEM_SDK::NEMeetingSDKIPCClient::getInstance()
{
#if defined(_DEBUG)
    static int debug_flag = 0;
    if (debug_flag == 0)
    {
        MessageBoxA(NULL, "1", "1", 0);
        debug_flag = 1;
    }
#endif
    if (NS_NEM_SDK_HOSTMOD_CLIENT::NEMeetingSDKIMP::global_object_ == nullptr)
        NS_NEM_SDK_HOSTMOD_CLIENT::NEMeetingSDKIMP::global_object_ = std::make_shared<NS_NEM_SDK_HOSTMOD_CLIENT::NEMeetingSDKIMP>();
    if (!NS_NEM_SDK_HOSTMOD_CLIENT::NEMeetingSDKIMP::global_object_->IsRunning())
    {
        NS_NEM_SDK_HOSTMOD_CLIENT::NEMeetingSDKIMP::global_object_->Start();
        while (!NS_NEM_SDK_HOSTMOD_CLIENT::NEMeetingSDKIMP::global_object_->IsRunning());
    }
    return NS_NEM_SDK_HOSTMOD_CLIENT::NEMeetingSDKIMP::global_object_.get();
}

NNEM_SDK_HOSTING_MODULE_CLIENT_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

std::shared_ptr<NEMeetingSDKIMP> NEMeetingSDKIMP::global_object_ = nullptr;

NEMeetingSDKIMP::NEMeetingSDKIMP() : IService(ServiceID::SID_Global), NS_NIPCLIB::IPCThread("NEMeetingSDKIMP"),
inited_(false),
ipc_client_(nullptr),
init_cb_(nullptr),
uninit_callback_(nullptr),
exception_handler_(nullptr),
private_initialize_cb_(nullptr),
log_cb_(nullptr)
{

}
NEMeetingSDKIMP::~NEMeetingSDKIMP()
{

}
void NEMeetingSDKIMP::OnLoad()
{

}
void NEMeetingSDKIMP::OnRelease()
{
}
void NEMeetingSDKIMP::privateInitialize(int port)
{
    TaskLoop()->PostTask(NS_NIPCLIB::Bind(&NEMeetingSDKIMP::InvokeInit, this, port));
}
void NEMeetingSDKIMP::initialize(const NEMeetingSDKConfig& config, const NEInitializeCallback& cb)
{
    global_config_ = config;
    init_cb_ = cb;
    std::string shared_key = global_config_.getAppInfo()->OrganizationName();
    shared_key.append(global_config_.getAppInfo()->ApplicationName());
    shared_key.append(global_config_.getAppInfo()->ProductName());

#ifdef WIN32
    auto CurrentProcessId = GetCurrentProcessId();
    HANDLE CurrentProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, CurrentProcessId);
    HANDLE lhShareMemory;
    lhShareMemory = CreateFileMappingA(HANDLE(0xFFFFFFFF), NULL, PAGE_READWRITE,
        0, sizeof(decltype(GetCurrentProcessId())), shared_key.c_str());
    if (lhShareMemory != NULL)
    {
        auto mem = MapViewOfFile(lhShareMemory, FILE_MAP_WRITE, 0, 0, sizeof(decltype(GetCurrentProcessId())));
        if (mem != nullptr)
        {
            memcpy(mem, &CurrentProcessId, sizeof(decltype(GetCurrentProcessId())));
            UnmapViewOfFile(mem);
        }
    }
#else
    SharedData* shared;
    std::hash<std::string> hash_fn;
    size_t str_hash = hash_fn(shared_key);
    std::cout << str_hash << '\n';
    do
    {
        // Open shared memory by custom ID
        shmid_ = shmget(str_hash, sizeof(SharedData), 0666 | IPC_CREAT);
        if (shmid_ == -1)
            break;

        // Attach shared memory to process virtual address
        auto shm = shmat(shmid_, 0, 0);
        if (shm == (void*)-1)
            break;

        // Copy process ID to shared memory
        shared = (SharedData*)shm;
        auto string_pid = std::to_string(getpid());
        auto string_srv_info = "" + string_pid;
        strncpy(shared->text, string_srv_info.c_str(), SHARED_TEXT_SIZE);

        // Detach shared memory from process after copy data
        shmdt(shm);
    } while(false);
#endif

    onIPCClientInitialize();
}

void NEMeetingSDKIMP::onIPCClientInitialize()
{
    LOG_IPCCLIENT_INFO("onIPCClientInitialize start.")
    SetKeepAliveInterval(global_config_.getKeepAliveInterval());
    if (_ProcHandler() != nullptr)
    {
        LOG_IPCCLIENT_INFO("_ProcHandler is not nullptr.")
        _ProcHandler()->onInitialize(global_config_, init_cb_);
    }
    else
    {
        TaskLoop()->PostDelayTask(50, NS_NIPCLIB::Bind(&NEMeetingSDKIMP::onIPCClientInitialize, this));
    }
}

void NEMeetingSDKIMP::unInitialize(const NEUnInitializeCallback& cb)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onUnInitialize(cb);
}
void NEMeetingSDKIMP::querySDKVersion(const NEQuerySDKVersionCallback& cb)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onQuerySDKVersion(cb);
}
void NEMeetingSDKIMP::activeWindow(const NEActiveWindowCallback& cb)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onActiveWindow(cb);
}
void NEMeetingSDKIMP::Exit()
{
    inited_ = false;
    if (ipc_client_ != nullptr)
        ipc_client_->Stop();
    auto global = shared_from_this();
    std::thread exit([global]() {
        global->Stop();
        global->Join();
    });
    exit.join();
    ServiceManager<NS_NIPCLIB::IPCClient>::Clear();
    auth_service_->OnRelease();
    meeting_service_->OnRelease();
    setting_service_->OnRelease();
    account_service_->OnRelease();
    feedback_service_->OnRelease();
    premeeting_service_->OnRelease();
    global->OnRelease();

    auth_service_.reset();
    meeting_service_.reset();
    setting_service_.reset();
    account_service_.reset();
    feedback_service_.reset();
    premeeting_service_.reset();

    global->SetProcThread(nullptr);
    global->SetIPCController(nullptr);

#ifdef WIN32
#else
    if (shmid_ != -1)
    {
        shmctl(shmid_, IPC_RMID, 0);
    }
#endif
}
NEMeetingService* NEMeetingSDKIMP::getMeetingService()
{
    if (inited_)
        return meeting_service_.get();
    return nullptr;
}
NEAuthService* NEMeetingSDKIMP::getAuthService()
{
    if (inited_)
        return auth_service_.get();
    return nullptr;
}
NESettingsService* NEMeetingSDKIMP::getSettingsService()
{
    if (inited_)
        return setting_service_.get();
    return nullptr;
}
NEAccountService* NEMeetingSDKIMP::getAccountService()
{
    if (inited_)
        return account_service_.get();
    return nullptr;
}

NEFeedbackService* NEMeetingSDKIMP::getFeedbackService()
{
    if (inited_)
        return feedback_service_.get();
    return nullptr;
}

NEPreMeetingService* NEMeetingSDKIMP::getPremeetingService()
{
    if (inited_)
        return premeeting_service_.get();
    return nullptr;
}

NEMeetingSDKConfig NEMeetingSDKIMP::GetInitConfig() const
{
    return global_config_;
}

void NEMeetingSDKIMP::WriteLog(LogLevel level, const std::string& strLog)
{
    if (log_cb_)
    {
        log_cb_(level, strLog);
    }
}

void NEMeetingSDKIMP::InvokeInit(int port)
{
    if (ipc_client_ == nullptr)
        ipc_client_ = std::make_shared<NS_NIPCLIB::IPCClient>();
    ipc_client_->AttachInit(NS_NIPCLIB::Bind(&NEMeetingSDKIMP::OnIPCClientInit, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3));
    ipc_client_->AttachReady(NS_NIPCLIB::Bind(&NEMeetingSDKIMP::OnIPCClientReady, this));
    ipc_client_->AttachReceiveData(NS_NIPCLIB::Bind(&NEMeetingSDKIMP::OnReceiveIPCData, this, std::placeholders::_1));
    ipc_client_->AttachClose(NS_NIPCLIB::Bind(&NEMeetingSDKIMP::OnIPCClose, this));
    ipc_client_->AttachKeepAliveTimeOut(NS_NIPCLIB::Bind(&NEMeetingSDKIMP::OnIPCKeepAliveTimeOut, this));
    ipc_client_->Init(port);
    ipc_client_->Start();
}
void NEMeetingSDKIMP::OnIPCClientInit(bool ret, const std::string& host, int port)
{
    IThread::SetLogger([this](int level, const std::string& strInfo) { if (log_cb_) { log_cb_((LogLevel)level, strInfo); } });
    if (ret)
    {
        auto global = shared_from_this();
        auth_service_ = std::make_shared<NEAuthServiceIMP>();
        meeting_service_ = std::make_shared<NEMeetingServiceIMP>();
        setting_service_ = std::make_shared<NESettingsServiceIMP>();
        account_service_ = std::make_shared<NEAccountServiceIMP>();
        feedback_service_ = std::make_shared<NEFeedbackServiceIMP>();
        premeeting_service_ = std::make_shared<NEPremeetingServiceIMP>();

        global->SetProcThread(global);
        meeting_service_->SetProcThread(global);
        auth_service_->SetProcThread(global);
        setting_service_->SetProcThread(global);
        account_service_->SetProcThread(global);
        feedback_service_->SetProcThread(global);
        premeeting_service_->SetProcThread(global);


        global->SetIPCController(ipc_client_);
        meeting_service_->SetIPCController(ipc_client_);
        auth_service_->SetIPCController(ipc_client_);
        setting_service_->SetIPCController(ipc_client_);
        account_service_->SetIPCController(ipc_client_);
        feedback_service_->SetIPCController(ipc_client_);
        premeeting_service_->SetIPCController(ipc_client_);


        global->OnLoad();
        auth_service_->OnLoad();
        meeting_service_->OnLoad();
        setting_service_->OnLoad();
        account_service_->OnLoad();
        feedback_service_->OnLoad();
        premeeting_service_->OnLoad();

        ServiceManager<NS_NIPCLIB::IPCClient>::RegisterService(global);
        ServiceManager<NS_NIPCLIB::IPCClient>::RegisterService(auth_service_);
        ServiceManager<NS_NIPCLIB::IPCClient>::RegisterService(meeting_service_);
        ServiceManager<NS_NIPCLIB::IPCClient>::RegisterService(setting_service_);
        ServiceManager<NS_NIPCLIB::IPCClient>::RegisterService(account_service_);
        ServiceManager<NS_NIPCLIB::IPCClient>::RegisterService(feedback_service_);
        ServiceManager<NS_NIPCLIB::IPCClient>::RegisterService(premeeting_service_);
        SetKeepAliveInterval(global_config_.getKeepAliveInterval());
    }
    if (private_initialize_cb_ != nullptr)
        private_initialize_cb_(ret);
}
void NEMeetingSDKIMP::OnIPCClientReady()
{
    //这里什么也不做，等服务端来触发初始化
}
void NEMeetingSDKIMP::OnReceiveIPCData(const NS_NIPCLIB::IPCData& data)
{
    NEMIPCProtocol protocol;
    if (protocol.Parse(data))
    {
        auto service = ServiceManager<NS_NIPCLIB::IPCClient>::GetService(protocol.SID());
        if (service != nullptr)
        {
            service->OnReceivePack(protocol.CID(), protocol.BodyText(), protocol.SN());
        }
    }
}
void NEMeetingSDKIMP::OnPack(int cid, const std::string& data, uint64_t sn)
{
    switch (cid)
    {
    case GlobalCID::GlobalCID_Init:
        OnPack_Init(data, sn);
        break;
    case GlobalCID::GlobalCID_UnInit:
    {
        OnPack_UnInit(data, sn);
    }
    break;
    case GlobalCID_QuerySDKVersion:
        OnPack_QuerySDKVersion(data, sn);
        break;
    case GlobalCID_ActiveWindow:
        OnPack_ActiveWindow(data, sn);
        break;
    default:
        break;
    }
}
void NEMeetingSDKIMP::OnPack_Init(const std::string& data, uint64_t sn)
{
    InitRequest request;
    if (request.Parse(data))
    {
        initialize(request.init_config_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
            InitResponse response;
            response.error_code_ = error_code;
            response.error_msg_ = error_msg;
            SendData(GlobalCID::GlobalCID_Init_CB, response, sn);
            if (error_code == NEErrorCode::ERROR_CODE_SUCCESS)
                NEMeetingSDKIMP::global_object_->inited_ = true;
        }));
    }
}
void NEMeetingSDKIMP::OnPack_UnInit(const std::string& data, uint64_t sn)
{
    UnInitRequest request;
    if (request.Parse(data))
    {
        unInitialize(ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
            UnInitResponse response;
            response.error_code_ = error_code;
            response.error_msg_ = error_msg;
            SendData(GlobalCID::GlobalCID_UnInit_CB, response, sn);
            if (error_code == NEErrorCode::ERROR_CODE_SUCCESS)
                NEMeetingSDKIMP::global_object_->inited_ = false;
        }));
    }
}
void NEMeetingSDKIMP::OnPack_QuerySDKVersion(const std::string& data, uint64_t sn)
{
    QuerySDKVersionRequest request;
    if (request.Parse(data))
    {
        querySDKVersion(ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const std::string& version) {
            QuerySDKVersionResponse response;
            response.error_code_ = error_code;
            response.error_msg_ = error_msg;
            response.sdkVersion = version;
            SendData(GlobalCID::GlobalCID_QuerySDKVersion_CB, response, sn);
        }));
    }
}
void NEMeetingSDKIMP::OnIPCClose()
{
    if (exception_handler_ != nullptr)
        exception_handler_(NEException(NEExceptionCode::kUISDKDisconnect, "UI SDK disconnected, maybe the app crashed."));
}

void NEMeetingSDKIMP::OnIPCKeepAliveTimeOut() {
    if (exception_handler_ != nullptr)
        exception_handler_(NEException(NEExceptionCode::kAppDisconnect, "app disconnected, because the keep-alive timeout."));
}

void NEMeetingSDKIMP::OnPack_ActiveWindow(const std::string& data, uint64_t sn)
{
    activeWindow(ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
        ActiveWindowResponse response;
        response.error_code_ = error_code;
        response.error_msg_ = error_msg;
        SendData(GlobalCID::GlobalCID_ActiveWindow_CB, response, sn);
    }));
}

NNEM_SDK_HOSTING_MODULE_CLIENT_END_DECLS
