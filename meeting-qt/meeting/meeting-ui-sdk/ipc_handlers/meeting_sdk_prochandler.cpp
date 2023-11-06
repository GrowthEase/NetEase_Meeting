// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include <QLocale>

#include "hosting_module_client.h"
#include "manager/global_manager.h"
#include "manager/meeting_manager.h"
#include "meeting_sdk_prochandler.h"
#include "version.h"

extern HostingModuleClient ipcClient;
std::unordered_map<std::string, NEMeetingLanguage> g_languageMap = {{"zh-CN", NEMeetingLanguage::kNEChinese},
                                                                    {"en-US", NEMeetingLanguage::kNEEnglish},
                                                                    {"en-CN", NEMeetingLanguage::kNEEnglish},
                                                                    {"ja-JP", NEMeetingLanguage::kNEJapanese},
                                                                    {"ja-CN", NEMeetingLanguage::kNEJapanese}};

NEMeetingSDKProcHandlerIMP::NEMeetingSDKProcHandlerIMP(QObject* parent /* = nullptr*/)
    : QObject(parent)
    , sdk_init_callback_(nullptr)
    , init_local_enviroment_cb_(nullptr) {
    initLanguage();
}

void NEMeetingSDKProcHandlerIMP::initLanguage() {
    auto languages = QLocale().uiLanguages();
    for (auto& language : languages) {
        YXLOG(Info) << "Found language: " << language.toStdString() << YXLOGEnd;
        for (auto& it : g_languageMap) {
            auto strLanguage = QString::fromStdString(it.first);
            bool bFind = strLanguage.contains(language, Qt::CaseInsensitive);
            YXLOG(Info) << "---- " << strLanguage.toStdString() << ", --- " << language.toStdString() << YXLOGEnd;
            if (bFind) {
                YXLOG(Info) << "Use language: " << it.first << YXLOGEnd;
                ipcClient.setLanguage(it.first);
                return;
            }
        }
    }
    ipcClient.setLanguage("en-US");
}

void NEMeetingSDKProcHandlerIMP::onInitialize(const NS_I_NEM_SDK::NEMeetingKitConfig& config,
                                              const NS_I_NEM_SDK::NEMeetingKit::NEInitializeCallback& cb) {
    YXLOG_API(Info) << "Received initialize request, organization name: " << config.getAppInfo()->OrganizationName()
                    << ", application name: " << config.getAppInfo()->ApplicationName()
                    << ", application display name: " << config.getAppInfo()->ProductName() << YXLOGEnd;

    if (g_bInitialized) {
        ipcClient.WriteLog("g_bInitialized has inited.");
        if (cb)
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        return;
    }

    ipcClient.WriteLog("onInitialize init start.");

    QString logPath = QString::fromStdString(config.getLoggerConfig()->LoggerPath());
    if (!logPath.isEmpty()) {
        logPath.append("/app/ui");
        QDir logDir;
        if (!logDir.exists(logPath)) {
            if (!logDir.mkpath(logPath)) {
                ipcClient.WriteLog(QString("mkpath ").append(logPath).append(" failed!"));
                ipcClient.WriteLog("onInitialize init end.");
                if (cb) {
                    cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, tr("Parameter error, LoggerPath invalid or no create permission").toStdString());
                }
                return;
            } else {
                logDir.setPath(logPath.remove("/app/ui"));
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

void NEMeetingSDKProcHandlerIMP::onUnInitialize(const NS_I_NEM_SDK::NEMeetingKit::NEUnInitializeCallback& cb) {
    YXLOG_API(Info) << "Received uninitialize request, post exit to application event loop." << YXLOGEnd;
    if (cb) {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
    }
    if (AuthManager::getInstance()->getAuthStatus() == kAuthLoginSuccessed) {
        YXLOG(Info) << "GetAuthInfo is not nullptr." << YXLOGEnd;
        AuthManager::getInstance()->doLogout(true);
    } else {
        Invoker::getInstance()->execute([]() {
            YXLOG(Info) << "qApp exit." << YXLOGEnd;
            qApp->exit(0);
        });
    }
}

void NEMeetingSDKProcHandlerIMP::onQuerySDKVersion(const NS_I_NEM_SDK::NEMeetingKit::NEQueryKitVersionCallback& cb) {
    YXLOG_API(Info) << "Received query sdk version request." << YXLOGEnd;
    if (cb) {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", APPLICATION_VERSION);
    }
}

void NEMeetingSDKProcHandlerIMP::onActiveWindow(bool bRaise, const NS_I_NEM_SDK::NEMeetingKit::NEActiveWindowCallback& cb) {
    YXLOG_API(Info) << "Received active window request, bRaise: " << bRaise << YXLOGEnd;
    MeetingManager::getInstance()->activeMeetingWindow(bRaise);
    if (cb)
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
}

void NEMeetingSDKProcHandlerIMP::onSwitchLanguage(NS_I_NEM_SDK::NEMeetingLanguage language, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSwitchLanguage request, language: " << (int)language << YXLOGEnd;
    switch (language) {
        case NEMeetingLanguage::kNEAutomatic:
            initLanguage();
            break;
        case NEMeetingLanguage::kNEChinese:
            ipcClient.setLanguage("zh-CN");
            break;
        case NEMeetingLanguage::kNEEnglish:
            ipcClient.setLanguage("en-US");
            break;
        case NEMeetingLanguage::kNEJapanese:
            ipcClient.setLanguage("jp-JP");
            break;
        default:
            break;
    }
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

nem_sdk_interface::NEMeetingKitConfig NEMeetingSDKProcHandlerIMP::getSDKConfig() const {
    return sdk_config_;
}
