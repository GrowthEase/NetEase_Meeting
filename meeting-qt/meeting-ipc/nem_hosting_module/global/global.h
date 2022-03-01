/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_EXPORT_H_
#define NEM_HOSTING_MODULE_EXPORT_H_
#include "nemeeting_sdk_interface_include.h"
#include "nem_hosting_module/config/build_config.h"
#include "nipclib/base/ipc_thread.h"
#include "nipclib/ipc/ipc_server.h"
#include "nem_hosting_module_core/service/service.h"
#include <atomic>

NNEM_SDK_HOSTING_MODULE_BEGIN_DECLS

USING_NS_NNEM_SDK_INTERFACE
USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

#define LOG_IPCSERVICE_DEBUG(log)    LOG_IPCSERVICE(NEMeetingSDKIMP::LogLevel_DEBUG, log)
#define LOG_IPCSERVICE_INFO(log)     LOG_IPCSERVICE(NEMeetingSDKIMP::LogLevel_INFO, log)
#define LOG_IPCSERVICE_WARNING(log)  LOG_IPCSERVICE(NEMeetingSDKIMP::LogLevel_WARNING, log)
#define LOG_IPCSERVICE_ERROR(log)    LOG_IPCSERVICE(NEMeetingSDKIMP::LogLevel_ERROR, log)
#define LOG_IPCSERVICE_FATAL(log)    LOG_IPCSERVICE(NEMeetingSDKIMP::LogLevel_FATAL, log)

#define LOG_IPCSERVICE(logLevel, log) \
    { \
        auto ipcService = dynamic_cast<NEMeetingSDKIMP*>(NEMeetingSDK::getInstance()); \
        if (ipcService) \
        {   \
            ipcService->WriteLog(logLevel, /*std::string(__FILE__) + " " + */std::string(__FUNCTION__) + ":" + std::to_string(__LINE__) + "] " + log); \
        } \
    }

class NEAuthServiceIMP;
class NEMeetingServiceIMP;
class NESettingsServiceIMP;
class NEAccountServiceIMP;
class NEFeedbackServiceIMP;
class NEPreMeetingServiceIMP;


class NEM_SDK_INTERFACE_EXPORT NEMeetingSDKIMP : public NEMeetingSDK,
	public IService<NS_NIPCLIB::IPCServer>,
	public NS_NIPCLIB::IPCThread,
	public std::enable_shared_from_this<NEMeetingSDKIMP>
{
	friend NEMeetingSDK* NEMeetingSDK::getInstance();
public:
	NEMeetingSDKIMP();
	virtual ~NEMeetingSDKIMP();
    enum LogLevel
    {
        LogLevel_DEBUG = 0,
        LogLevel_INFO,
        LogLevel_WARNING,
        LogLevel_ERROR,
        LogLevel_FATAL,
    };
public:
	virtual void initialize(const NEMeetingSDKConfig& config, const NEInitializeCallback& cb) override;
	virtual void unInitialize(const NEUnInitializeCallback& cb) override;
    virtual bool isInitialized() override;
    virtual void activeWindow(const NEActiveWindowCallback& cb) override;
	virtual void querySDKVersion(const NEQuerySDKVersionCallback& cb) override;
	virtual void setExceptionHandler(const NEExceptionHandler& handler) override {
		exception_handler_ = handler;
	}
    virtual void setLogHandler(const std::function<void(int level, const std::string& log)>& cb) override {
        log_callback_ = this->ToWeakCallback(cb);
    }
	virtual NEAuthService* getAuthService() override;
	virtual NEMeetingService* getMeetingService() override;
	virtual NESettingsService* getSettingsService() override;
	virtual NEAccountService* getAccountService() override;
    virtual NEFeedbackService* getFeedbackService() override;
    virtual NEPreMeetingService* getPremeetingService() override;

public:
	NEMeetingSDKConfig GetInitConfig() const;
    void WriteLog(LogLevel level, const std::string& strLog);
private:
	void InvokeInit(const NEInitializeCallback& cb);
	void AttachUnInit(const std::function<void()>& callback)
	{
		uninit_callback_ = callback;
	}
	void OnIPCServerInit(const NEInitializeCallback& cb,bool ret, const std::string& host, int port);
	void OnIPCServerReady(const NEInitializeCallback& cb);
	void OnReceiveIPCData(const NS_NIPCLIB::IPCData& data);
	virtual void OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb) override;
	virtual void OnPack(int cid, const std::string& data, uint64_t sn) override {};
	void OnIPCClosed();
	void OnIPCClientClosed();
private:
	void OnPack_InitCallback(const std::string& data, const IPCAsyncResponseCallback& cb);
private:
	std::atomic_bool inited_;
	std::atomic_bool initting_;
	std::atomic_bool notify_exception_;
	static std::shared_ptr<NEMeetingSDKIMP> global_object_;
	std::shared_ptr<NEMeetingServiceIMP> meeting_service_;
	std::shared_ptr< NEAuthServiceIMP> auth_service_;
	std::shared_ptr< NESettingsServiceIMP> setting_service_;
	std::shared_ptr< NEAccountServiceIMP> account_service_;
    std::shared_ptr< NEFeedbackServiceIMP> feedback_service_;
    std::shared_ptr< NEPreMeetingServiceIMP> premeeting_service_;

	NEMeetingSDKConfig global_config_;
	std::shared_ptr<NS_NIPCLIB::IPCServer> ipc_server_;
	std::function<void()> uninit_callback_;
    NEInitializeCallback init_callback_ = nullptr;
    std::atomic_bool read_init_ = ATOMIC_VAR_INIT(false);
    std::unique_ptr<std::thread> read_init_thread_ = nullptr;
    NEExceptionHandler exception_handler_;
    std::function<void(int level, const std::string& log)> log_callback_;
    std::shared_ptr<std::thread> unInitialize_thread_;
};

NNEM_SDK_HOSTING_MODULE_END_DECLS

#endif //NEM_HOSTING_MODULE_EXPORT_H_
