/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_CLIENT_EXPORT_H_
#define NEM_HOSTING_MODULE_CLIENT_EXPORT_H_
#include "client_nemeeting_sdk_interface_include.h"
#include "nem_hosting_module_client/config/build_config.h"
#include "nipclib/base/ipc_thread.h"
#include "nipclib/ipc/ipc_client.h"
#include "nem_hosting_module_core/service/service.h"

NNEM_SDK_HOSTING_MODULE_CLIENT_BEGIN_DECLS

USING_NS_NNEM_SDK_INTERFACE

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

#define LOG_IPCCLIENT_DEBUG(log)    LOG_IPCCLIENT(NEMeetingSDKIPCClient::LogLevel_DEBUG, log)
#define LOG_IPCCLIENT_INFO(log)     LOG_IPCCLIENT(NEMeetingSDKIPCClient::LogLevel_INFO, log)
#define LOG_IPCCLIENT_WARNING(log)  LOG_IPCCLIENT(NEMeetingSDKIPCClient::LogLevel_WARNING, log)
#define LOG_IPCCLIENT_ERROR(log)    LOG_IPCCLIENT(NEMeetingSDKIPCClient::LogLevel_ERROR, log)
#define LOG_IPCCLIENT_FATAL(log)    LOG_IPCCLIENT(NEMeetingSDKIPCClient::LogLevel_FATAL, log)
#define LOG_IPCCLIENT_V0(log)       LOG_IPCCLIENT(NEMeetingSDKIPCClient::LogLevel_V0, log)
#define LOG_IPCCLIENT_V1(log)       LOG_IPCCLIENT(NEMeetingSDKIPCClient::LogLevel_V1, log)
#define LOG_IPCCLIENT_V2(log)       LOG_IPCCLIENT(NEMeetingSDKIPCClient::LogLevel_V2, log)
#define LOG_IPCCLIENT_V3(log)       LOG_IPCCLIENT(NEMeetingSDKIPCClient::LogLevel_V3, log)
#define LOG_IPCCLIENT_V4(log)       LOG_IPCCLIENT(NEMeetingSDKIPCClient::LogLevel_V4, log)

#define LOG_IPCCLIENT(logLevel, log) \
    { \
        auto ipcClient = dynamic_cast<NEMeetingSDKIMP*>(NEMeetingSDKIPCClient::getInstance()); \
        if (ipcClient) \
        {   \
            ipcClient->WriteLog(logLevel, /*std::string(__FILE__) + " " + */std::string(__FUNCTION__) + ":" + std::to_string(__LINE__) + "] " + log); \
        } \
    }

class NEAuthServiceIMP;
class NEMeetingServiceIMP;
class NESettingsServiceIMP;
class NEAccountServiceIMP;
class NEFeedbackServiceIMP;
class NEPremeetingServiceIMP;

class NEM_SDK_INTERFACE_EXPORT NEMeetingSDKIMP : public NEMeetingSDKIPCClient,
    public IService<NS_NIPCLIB::IPCClient>,
    public NS_NIPCLIB::IPCThread,
    public std::enable_shared_from_this<NEMeetingSDKIMP>
{
    friend NEMeetingSDKIPCClient* NEMeetingSDKIPCClient::getInstance();
public:
    NEMeetingSDKIMP();
    virtual ~NEMeetingSDKIMP();
public:
    virtual void initialize(const NEMeetingSDKConfig& config, const NEInitializeCallback& cb) override;
    virtual void unInitialize(const NEUnInitializeCallback& cb) override;
    virtual bool isInitialized() override { return true; };
    virtual void querySDKVersion(const NEQuerySDKVersionCallback& cb) override;
    virtual void activeWindow(const NEActiveWindowCallback& cb) override;
    virtual void setExceptionHandler(const NEExceptionHandler& handler) override {
        exception_handler_ = handler;
    }
    virtual void setLogHandler(const std::function<void(int level, const std::string& log)>& cb)  override {}
    virtual NEAuthService* getAuthService() override;
    virtual NEMeetingService* getMeetingService() override;
    virtual NESettingsService* getSettingsService() override;
    virtual NEAccountService* getAccountService() override;
    virtual NEFeedbackService* getFeedbackService() override;
    virtual NEPreMeetingService* getPremeetingService() override;
    virtual void privateInitialize(int port) override;
    virtual void attachPrivateInitialize(const std::function<void(bool)>& cb) override {
        private_initialize_cb_ = cb;
    }
    virtual void setLogCallBack(const std::function<void(LogLevel level, const std::string&)>& cb) override {
        log_cb_ = cb;
    }
    virtual void Exit();
    virtual void OnLoad() override;
    virtual void OnRelease() override;
public:
    NEMeetingSDKConfig GetInitConfig() const;
    void WriteLog(LogLevel level, const std::string& strLog);
private:
    void InvokeInit(int port);
    void AttachUnInit(const std::function<void()>& callback)
    {
        uninit_callback_ = callback;
    }
    void onIPCClientInitialize();
    void OnIPCClientInit(bool ret, const std::string& host, int port);
    void OnIPCClientReady();
    void OnReceiveIPCData(const NS_NIPCLIB::IPCData& data);
    void OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb) override {};
    virtual void OnPack(int cid, const std::string& data, uint64_t sn) override;
private:
    void OnPack_Init(const std::string& data, uint64_t sn);
    void OnPack_UnInit(const std::string& data, uint64_t sn);
    void OnPack_QuerySDKVersion(const std::string& data, uint64_t sn);
    void OnPack_ActiveWindow(const std::string& data, uint64_t sn);
private:
    void OnIPCClose();
    void OnIPCKeepAliveTimeOut();

private:
    std::atomic_bool inited_;
    static std::shared_ptr<NEMeetingSDKIMP> global_object_;
    std::shared_ptr<NEMeetingServiceIMP> meeting_service_;
    std::shared_ptr<NEAuthServiceIMP> auth_service_;
    std::shared_ptr<NESettingsServiceIMP> setting_service_;
    std::shared_ptr<NEAccountServiceIMP> account_service_;
    std::shared_ptr<NEFeedbackServiceIMP> feedback_service_;
    std::shared_ptr<NEPremeetingServiceIMP>premeeting_service_;

    NEMeetingSDKConfig global_config_;
    NEInitializeCallback init_cb_;
    std::function<void()> uninit_callback_;
    std::shared_ptr<NS_NIPCLIB::IPCClient> ipc_client_;
    std::function<void(bool)> private_initialize_cb_;
    std::function<void(LogLevel level, const std::string&)> log_cb_;
    NEExceptionHandler exception_handler_;
#ifndef WIN32
    uint64_t shmid_ = -1;
#endif
};

NNEM_SDK_HOSTING_MODULE_CLIENT_END_DECLS

#endif //NEM_HOSTING_MODULE_CLIENT_EXPORT_H_
