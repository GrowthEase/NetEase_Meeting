/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "hosting_module_client.h"
#include <fstream>
#include "manager/meeting_manager.h"

HostingModuleClient::HostingModuleClient(QObject* parent)
    : QObject(parent)
    , account_proc_handler_(nullptr)
    , auth_service_proc_handler_(nullptr)
    , meeting_service_proc_handler_(nullptr)
    , meeting_sdk_proc_handler_(nullptr)
    , setting_service_proc_handler_(nullptr)
    , feedback_service_proc_handler_(nullptr)
    , premeeting_service_proc_handler_(nullptr) {
    auto appDataDir = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    appDataDir.append("/Netease/Meeting/UI/");
    QDir logDir = appDataDir;
    if (!logDir.exists(appDataDir))
        logDir.mkpath(appDataDir);

    QDir dir(appDataDir);
    foreach (QFileInfo mfi, dir.entryInfoList()) {
        if (mfi.isFile() && mfi.suffix() == "txt1") {
            dir.remove(mfi.fileName());
        }
    }
    m_strLogPath = appDataDir + QDateTime::currentDateTime().toString("yyyy-MM-dd-hh-mm-ss").append("-log.txt1");
}

HostingModuleClient::~HostingModuleClient() {}

void HostingModuleClient::setBugList(const char* argv) {
    QString strPath = QFileInfo(argv).absolutePath().append("/config/custom.json");
    if (!QFile::exists(strPath)) {
        qWarning() << "custom strPath is null.";
    } else {
        bool bRet = qputenv("QT_OPENGL_BUGLIST", strPath.toUtf8());
        if (!bRet) {
            qWarning() << "set setBugList failed.";
        }
    }

#if 0
    bool bRet = qputenv("QT_LOGGING_RULES", "qt.qpa.gl = true");
    if (!bRet) {
        qWarning() << "set qt.qpa.gl failed.";
    }
#endif
}

void HostingModuleClient::WriteLog(const QString& strLog) {
    std::ofstream output;
    output.open(qPrintable(m_strLogPath), std::ios::out | std::ios::app);
    std::string message = qPrintable(QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss").append(": ").append(strLog));
    output << message << "\n";
}

bool HostingModuleClient::InitLocalEnviroment(int port) {
    YXLOG(Info) << "Initialize local enviroment on port: " << port << YXLOGEnd;
    auto* client = dynamic_cast<NEMeetingSDKIPCClient*>(NEMeetingSDKIPCClient::getInstance());
    if (client == nullptr)
        return false;

    client->setLogCallBack([this](NEMeetingSDKIPCClient::LogLevel level, const std::string& strLog) {
        if (!g_bInitialized) {
            WriteLog(QString::fromStdString(strLog));
            return;
        }
        switch (level) {
            case NEMeetingSDKIPCClient::LogLevel_DEBUG:
                YXLOG(Info) << strLog;
                break;
            case NEMeetingSDKIPCClient::LogLevel_INFO:
                YXLOG(Info) << strLog;
                break;
            case NEMeetingSDKIPCClient::LogLevel_WARNING:
                YXLOG(Warn) << strLog;
                break;
            case NEMeetingSDKIPCClient::LogLevel_ERROR:
                YXLOG(Error) << strLog;
                break;
            case NEMeetingSDKIPCClient::LogLevel_FATAL:
                YXLOG(Fatal) << strLog;
                break;
            case NEMeetingSDKIPCClient::LogLevel_V0:
#ifdef USE_GOOGLE_LOG
                VLOG(0) << strLog;
#else
                YXLOG(Info) << strLog;
#endif
                break;
            case NEMeetingSDKIPCClient::LogLevel_V1:
#ifdef USE_GOOGLE_LOG
                VLOG(1) << strLog;
#else
                YXLOG(Info) << strLog;
#endif
                break;
            case NEMeetingSDKIPCClient::LogLevel_V2:
#ifdef USE_GOOGLE_LOG
                VLOG(2) << strLog;
#else
                YXLOG(Info) << strLog;
#endif
                break;
            case NEMeetingSDKIPCClient::LogLevel_V3:
#ifdef USE_GOOGLE_LOG
                VLOG(3) << strLog;
#else
                YXLOG(Info) << strLog;
#endif
                break;
            case NEMeetingSDKIPCClient::LogLevel_V4:
#ifdef USE_GOOGLE_LOG
                VLOG(4) << strLog;
#else
                YXLOG(Info) << strLog;
#endif
                break;
            default:
                YXLOG(Info) << strLog;
        }
    });

    client->setExceptionHandler(std::bind(&HostingModuleClient::onException, this, std::placeholders::_1));
    client->attachPrivateInitialize([this](bool ret) {
        if (!ret)
            return;
        auto* client = NEMeetingSDKIPCClient::getInstance();
        meeting_sdk_proc_handler_ = std::make_unique<NEMeetingSDKProcHandlerIMP>();
        client->setProcHandler(meeting_sdk_proc_handler_.get());
        meeting_sdk_proc_handler_->attachSDKInitialize([this](bool) {
            auto* client = NEMeetingSDKIPCClient::getInstance();
            account_proc_handler_ = std::make_unique<NEAccountProcHandlerIMP>();
            auth_service_proc_handler_ = std::make_unique<NEAuthServiceProcHandlerIMP>();
            meeting_service_proc_handler_ = std::make_unique<NEMeetingServiceProcHandlerIMP>();
            setting_service_proc_handler_ = std::make_unique<NESettingsServiceProcHandlerIMP>();
            feedback_service_proc_handler_ = std::make_unique<NEFeedbackServiceProcHandlerIMP>();
            premeeting_service_proc_handler_ = std::make_unique<NEPreMeetingServiceProcHandlerIMP>();

            auto* account_service = dynamic_cast<NEAccountServiceIPCClient*>(client->getAccountService());
            if (account_service != nullptr)
                account_service->setProcHandler(account_proc_handler_.get());

            auto* auth_service = dynamic_cast<NEAuthServiceIPCClient*>(client->getAuthService());
            if (auth_service != nullptr)
                auth_service->setProcHandler(auth_service_proc_handler_.get());

            auto* meeting_service = dynamic_cast<NEMeetingServiceIPCClient*>(client->getMeetingService());
            if (meeting_service != nullptr)
                meeting_service->setProcHandler(meeting_service_proc_handler_.get());

            auto* settings_service = dynamic_cast<NESettingsServiceIPCClient*>(client->getSettingsService());
            if (settings_service != nullptr)
                settings_service->setProcHandler(setting_service_proc_handler_.get());

            auto* feedback_service = dynamic_cast<NEFeedbackServiceIPCClient*>(client->getFeedbackService());
            if (feedback_service != nullptr)
                feedback_service->setProcHandler(feedback_service_proc_handler_.get());

            auto* pre_meeting_service = dynamic_cast<NEPremeetingServiceIPCClient*>(client->getPremeetingService());
            if (pre_meeting_service != nullptr)
                pre_meeting_service->setProcHandler(premeeting_service_proc_handler_.get());

            connect(MeetingManager::getInstance(), &MeetingManager::meetingStatusChanged, this,
                    [](NEMeeting::Status status, int errorCode, const QString& errorMessage) {
                        YXLOG(Info) << "Connection meeting status chagned, status: " << status << ", ext code: " << errorCode
                                    << ", error message: " << errorMessage.toStdString() << YXLOGEnd;
                        if (status == NEMeeting::MEETING_DISCONNECTED || status == NEMeeting::MEETING_IDLE ||
                            status == NEMeeting::MEETING_CONNECTED || status == NEMeeting::MEETING_ENDED ||
                            status == NEMeeting::MEETING_MULTI_SPOT_LOGIN || status == NEMeeting::MEETING_CONNECTING ||
                            status == NEMeeting::MEETING_WAITING_VERIFY_PASSWORD) {
                            int interface_status = MEETING_STATUS_IDLE;
                            int interface_code = MEETING_DISCONNECTING_BY_SELF;

                            switch (status) {
                                case NEMeeting::MEETING_IDLE:
                                    interface_status = MEETING_STATUS_IDLE;
                                    break;
                                case NEMeeting::MEETING_CONNECTING:
                                    interface_status = MEETING_STATUS_CONNECTING;
                                    break;
                                case NEMeeting::MEETING_CONNECTED:
                                    interface_status = MEETING_STATUS_INMEETING;
                                    break;
                                case NEMeeting::MEETING_DISCONNECTED:
                                    interface_status = MEETING_STATUS_DISCONNECTING;
                                    if (errorCode == kReasonRemovedByHost)
                                        interface_code = MEETING_DISCONNECTING_REMOVED_BY_HOST;
                                    else if (errorCode == kReasonCloseByHost)
                                        interface_code = MEETING_DISCONNECTING_CLOSED_BY_HOST;
                                    else if (errorCode == kReasonLoginOnOtherDevice)
                                        interface_code = MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE;
                                    else if (errorCode == kReasonAuthInfoExpired)
                                        interface_code = MEETING_DISCONNECTING_AUTH_INFO_EXPIRED;
                                    else if (errorCode == kReasonOtherError)
                                        interface_code = MEETING_DISCONNECTING_BY_SERVER;
                                    break;
                                case NEMeeting::MEETING_ENDED:
                                    interface_status = MEETING_STATUS_DISCONNECTING;
                                    if (errorCode == kReasonDefault)
                                        interface_code = MEETING_DISCONNECTING_BY_SELF;
                                    else
                                        interface_code = MEETING_DISCONNECTING_CLOSED_BY_SELF_AS_HOST;
                                    break;
                                case NEMeeting::MEETING_MULTI_SPOT_LOGIN:
                                    interface_status = MEETING_STATUS_DISCONNECTING;
                                    interface_code = MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE;
                                    break;
                                case NEMeeting::MEETING_WAITING_VERIFY_PASSWORD:
                                    interface_status = MEETING_STATUS_WAITING;
                                    interface_code = MEETING_WAITING_VERIFY_PASSWORD;
                                    break;
                                default:
                                    break;
                            }

                            auto* client = NEMeetingSDKIPCClient::getInstance();
                            auto* meeting_service = dynamic_cast<NEMeetingServiceIPCClient*>(client->getMeetingService());
                            if (meeting_service != nullptr) {
                                YXLOG_API(Info) << "onMeetingStatusChanged status chagned, interface_status: " << interface_status
                                                << ", interface_code: " << interface_code << YXLOGEnd;
                                meeting_service->onMeetingStatusChanged(interface_status, interface_code);
                            }
                        }
                    });
        });
    });
    client->privateInitialize(port);
    return true;
}

void HostingModuleClient::OnInitLocalEnviroment(bool success) {
    YXLOG_API(Info) << "Initialize local enviroment result: " << success << YXLOGEnd;
    if (meeting_sdk_proc_handler_)
        meeting_sdk_proc_handler_->onInitLocalEnviroment(success);
}

NEMeetingSDKConfig HostingModuleClient::getSDKConfig() const {
    YXLOG(Info) << "getSDKConfig." << YXLOGEnd;
    if (meeting_sdk_proc_handler_)
        return meeting_sdk_proc_handler_->getSDKConfig();
    else
        return NEMeetingSDKConfig();
}

void HostingModuleClient::Uninit() {
    YXLOG_API(Info) << "Received uninitialize request." << YXLOGEnd;
}

void HostingModuleClient::onException(const NEException& exception) {
    YXLOG_API(Error) << "Received exception, error code: " << exception.ExceptionCode() << ", error message: " << exception.ExceptionMessage()
                     << YXLOGEnd;
    if (meeting_sdk_proc_handler_ && kAppDisconnect == exception.ExceptionCode()) {
        meeting_sdk_proc_handler_->onUnInitialize(nullptr);
    }
    // qApp->exit(0);
}
