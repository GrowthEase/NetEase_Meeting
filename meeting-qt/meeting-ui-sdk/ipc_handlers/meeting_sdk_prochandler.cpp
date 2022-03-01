/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "meeting_sdk_prochandler.h"
#include "manager/global_manager.h"
#include "manager/meeting_manager.h"
#include "hosting_module_client.h"
#include "version.h"

extern HostingModuleClient ipcClient;
NEMeetingSDKProcHandlerIMP::NEMeetingSDKProcHandlerIMP(QObject* parent /* = nullptr*/)
    : QObject(parent)
    , sdk_init_callback_(nullptr)
    , init_local_enviroment_cb_(nullptr) {}

void NEMeetingSDKProcHandlerIMP::onInitialize(const NS_I_NEM_SDK::NEMeetingSDKConfig& config,
                                              const NS_I_NEM_SDK::NEMeetingSDK::NEInitializeCallback& cb) {
    YXLOG_API(Info) << "Received initialize request, organization name: " << config.getAppInfo()->OrganizationName()
              << ", application name: " << config.getAppInfo()->ApplicationName()
              << ", application display name: " << config.getAppInfo()->ProductName()
              << YXLOGEnd;

    if (g_bInitialized) {
        ipcClient.WriteLog("g_bInitialized has inited.");
        if (cb)
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        return;
    }

    ipcClient.WriteLog("onInitialize init start.");

    QString logPath = QString::fromStdString(config.getLoggerConfig()->LoggerPath());
    if (!logPath.isEmpty()) {
        logPath.append("/UI");
        QDir logDir;
        if (!logDir.exists(logPath)) {
            if(!logDir.mkpath(logPath)) {
                ipcClient.WriteLog(QString("mkpath ").append(logPath).append(" failed!"));
                ipcClient.WriteLog("onInitialize init end.");
                if (cb) {
                    cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, tr("Parameter error, LoggerPath invalid or no create permission").toStdString());
                }
                return;
            } else {
                logDir.setPath(logPath.remove("/UI"));
                logPath = logDir.canonicalPath();
                config.getLoggerConfig()->LoggerPath(logPath.toStdString());
            }
        }
    }

    sdk_config_ = config;

    auto organizationName = QString::fromStdString(config.getAppInfo()->OrganizationName());
    auto applicationName = QString::fromStdString(config.getAppInfo()->ApplicationName());
    auto displayName = QString::fromStdString(config.getAppInfo()->ProductName());
    auto domain = QString::fromStdString(config.getDomain());

    QGuiApplication::setOrganizationName(organizationName.isEmpty() ? "NetEase" : organizationName);
    QGuiApplication::setApplicationName(applicationName.isEmpty() ? "Meeting" : applicationName);
    QGuiApplication::setApplicationDisplayName(displayName.isEmpty() ? tr("NetEase Meeting") : displayName);
    QGuiApplication::setOrganizationDomain(domain.isEmpty() ? "yunxin.163.com" : domain);

    init_local_enviroment_cb_ = cb;
    g_bInitialized = true;
    ipcClient.WriteLog("onInitialize init end.");
}

void NEMeetingSDKProcHandlerIMP::onUnInitialize(const NS_I_NEM_SDK::NEMeetingSDK::NEUnInitializeCallback& cb) {
    YXLOG_API(Info) << "Received uninitialize request, post exit to application event loop." << YXLOGEnd;
    if (cb) {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
    }
    if (AuthManager::getInstance()->getAuthInfo() != nullptr) {
        YXLOG(Info) << "GetAuthInfo is not nullptr." << YXLOGEnd;
        AuthManager::getInstance()->doLogout(true);
    } else {
        Invoker::getInstance()->execute([]() { qApp->exit(0); });
    }
}

void NEMeetingSDKProcHandlerIMP::onQuerySDKVersion(const NS_I_NEM_SDK::NEMeetingSDK::NEQuerySDKVersionCallback& cb) {
    YXLOG_API(Info) << "Received query sdk version request." << YXLOGEnd;
    if (cb) {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", APPLICATION_VERSION);
    }
}

void NEMeetingSDKProcHandlerIMP::onActiveWindow(const NS_I_NEM_SDK::NEMeetingSDK::NEActiveWindowCallback& cb) {
    YXLOG_API(Info) << "Received active window request." << YXLOGEnd;
    MeetingManager::getInstance()->activeMeetingWindow();
    if (cb)
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
}

void NEMeetingSDKProcHandlerIMP::attachSDKInitialize(const std::function<void(bool)>& cb) {
    sdk_init_callback_ = cb;
}

void NEMeetingSDKProcHandlerIMP::onInitLocalEnviroment(bool success) {
    if (init_local_enviroment_cb_)
        init_local_enviroment_cb_(success ? NS_I_NEM_SDK::ERROR_CODE_SUCCESS : NS_I_NEM_SDK::ERROR_CODE_FAILED, "");

    if (sdk_init_callback_)
        sdk_init_callback_(success);
}

nem_sdk_interface::NEMeetingSDKConfig NEMeetingSDKProcHandlerIMP::getSDKConfig() const {
    return sdk_config_;
}
