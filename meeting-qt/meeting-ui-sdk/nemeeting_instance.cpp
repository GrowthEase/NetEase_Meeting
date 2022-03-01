/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nemeeting_instance.h"

#include "components/clipboard.h"
#include "components/mouse_event_spy.h"

#include "models/members_model.h"
#include "models/screen_model.h"
#include "models/device_model.h"

#include "providers/frame_provider.h"
#include "providers/screen_provider.h"
#include "providers/auth_notifier.h"
#include "providers/meeting_notifier.h"
#include "providers/controller.h"

#include "manager/global_manager.h"
#include "manager/meeting/members_manager.h"
#include "manager/meeting/video_manager.h"
#include "manager/meeting/share_manager.h"

#include "service/ui_sdk_account_service.h"
#include "service/ui_sdk_auth_service.h"
#include "service/ui_sdk_meeting_service.h"
#include "service/ui_sdk_setting_service.h"

std::shared_ptr<NEMeetingInstance> NEMeetingInstance::meeting_instance_ = nullptr;
std::recursive_mutex NEMeetingInstance::meeting_instance_mutex_;
NEMeetingSDK* NEMeetingSDK::getInstance()
{
    if (NEMeetingInstance::meeting_instance_ == nullptr)
    {
        NEMeetingInstance::meeting_instance_mutex_.lock();
        if(NEMeetingInstance::meeting_instance_ == nullptr)
            NEMeetingInstance::meeting_instance_ = std::make_shared<NEMeetingInstance>();
        NEMeetingInstance::meeting_instance_mutex_.unlock();
    }
    return NEMeetingInstance::meeting_instance_.get();
}

NEMeetingInstance::NEMeetingInstance() :
    auth_service_(nullptr),
    meeting_service_(nullptr),
    settings_service_(nullptr),
    account_service_(nullptr),
    main_thread_(nullptr),
    app_(nullptr),
    init_with_qt_(false)
{

}

void NEMeetingInstance::initialize(const NEMeetingSDKConfig &config, const NEInitializeCallback &cb)
{
    NEErrorCode error_code = NEErrorCode::ERROR_CODE_SUCCESS;
    std::string error_msg = NE_ERROR_MSG_SUCCESS;

    if (app_ == nullptr)
    {
        int argc = 0;
        char** argv = nullptr;
        app_ = new QGuiApplication(argc, argv);
        init_with_qt_ = false;
    }

	GlobalManager::getInstance()->startup();
    AuthManager::getInstance()->setAuthAppKey(QString::fromStdString(config.getAppKey()));

    if(doInitialize(config))
    {
        auth_service_ = std::make_unique<NEAuthServiceIMP>();
        meeting_service_ = std::make_unique<NEMeetingServiceIMP>();
        settings_service_ = std::make_unique<NESettingsServiceIMP>();
        account_service_ = std::make_unique<NEAccountServiceIMP>();
    }
    else
    {
        error_code = NEErrorCode::ERROR_CODE_FAILED;
        error_msg = "SDK initialize failed";
    }
    if(cb != nullptr)
    {
        cb(error_code,error_msg);
    }
}

void NEMeetingInstance::initializeWithQt(const NEMeetingSDKConfig &config, const NEMeetingSDK::NEInitializeCallback &cb, void *app)
{
    NEErrorCode error_code = NEErrorCode::ERROR_CODE_SUCCESS;
    std::string error_msg = NE_ERROR_MSG_SUCCESS;

    init_with_qt_ = true;

    app_ = (QGuiApplication*)app;
    app_->setOrganizationName(QString::fromStdString(config.getAppInfo()->OrganizationName()));
    app_->setOrganizationDomain(QString::fromStdString(config.getDomain()));
    app_->setApplicationName(QString::fromStdString(config.getAppInfo()->ApplicationName()));
    app_->setApplicationDisplayName(QString::fromStdString(config.getAppInfo()->ApplicationName()));

    GlobalManager::getInstance()->startup();
    AuthManager::getInstance()->setAuthAppKey(QString::fromStdString(config.getAppKey()));

    if (doInitialize(config))
    {
        auth_service_ = std::make_unique<NEAuthServiceIMP>();
        meeting_service_ = std::make_unique<NEMeetingServiceIMP>();
        settings_service_ = std::make_unique<NESettingsServiceIMP>();
        account_service_ = std::make_unique<NEAccountServiceIMP>();
    }
    else
    {
        error_code = NEErrorCode::ERROR_CODE_FAILED;
        error_msg = "SDK initialize failed";
    }
    if(cb != nullptr)
    {
        cb(error_code,error_msg);
    }
}

void NEMeetingInstance::unInitialize(const NEUnInitializeCallback &cb)
{
    NEErrorCode error_code = NEErrorCode::ERROR_CODE_SUCCESS;
    std::string error_msg = NE_ERROR_MSG_SUCCESS;

    GlobalManager::getInstance()->shutdown();

    if(doUnInitialize())
    {
        auth_service_.reset();
        meeting_service_.reset();
        settings_service_.reset();
        account_service_.reset();
    }
    else
    {
        error_code = NEErrorCode::ERROR_CODE_FAILED;
        error_msg = "SDK initialize failed";
    }
    auto __this = shared_from_this();
    NEMeetingInstance::meeting_instance_mutex_.lock();
    NEMeetingInstance::meeting_instance_.reset();
    NEMeetingInstance::meeting_instance_mutex_.unlock();
    if(cb != nullptr)
    {
        cb(error_code,error_msg);
    }
}

void NEMeetingInstance::querySDKVersion(const NEQuerySDKVersionCallback &cb)
{
    NEErrorCode error_code = NEErrorCode::ERROR_CODE_SUCCESS;
    std::string error_msg = NE_ERROR_MSG_SUCCESS;
    cb(error_code,error_msg,"1.0.0.1");
}

#include <QQuickWidget>

bool NEMeetingInstance::doInitialize(const NEMeetingSDKConfig& config)
{
#ifndef WIN32
    signal(SIGPIPE, SIG_IGN);
#endif
    // Load translations
    QTranslator translator;
#ifdef Q_OS_MACX
    bool loadResult = translator.load(QLocale(), QLatin1String("meeting-ui-sdk"), QLatin1String("_"), QGuiApplication::applicationDirPath() + "/../Resources/");
#else
    bool loadResult = translator.load(QLocale(), QLatin1String("meeting-ui-sdk"), QLatin1String("_"), QGuiApplication::applicationDirPath());
#endif
    if (loadResult)
        app_->installTranslator(&translator);

    int result = 0;

    {
#ifdef Q_OS_MACX
        MacXHelpers hideToolbar;
#endif
        DeviceManager::getInstance()->initialize();
        qmlRegisterTypeStep1();
        QQmlApplicationEngine* engine = new QQmlApplicationEngine;

        // QQuickView* view = new QQuickView;
        engine->rootContext()->setContextProperty("globalManager", GlobalManager::getInstance());
        engine->rootContext()->setContextProperty("authManager", AuthManager::getInstance());
        engine->rootContext()->setContextProperty("meetingManager", MeetingManager::getInstance());
        engine->rootContext()->setContextProperty("membersManager", MembersManager::getInstance());
        engine->rootContext()->setContextProperty("audioManager", AudioManager::getInstance());
        engine->rootContext()->setContextProperty("videoManager", VideoManager::getInstance());
        engine->rootContext()->setContextProperty("shareManager", ShareManager::getInstance());
        engine->rootContext()->setContextProperty("deviceManager", DeviceManager::getInstance());
        engine->rootContext()->setContextProperty("availableStyles", QQuickStyle::availableStyles());
        engine->load(QUrl("qrc:/main.qml"));
    }

    return true;
}

bool NEMeetingInstance::doUnInitialize()
{
    qApp->exit();
    return true;
}

void NEMeetingInstance::qmlRegisterTypeStep1()
{
    qmlRegisterType<AuthNotifier>("NetEase.Meeting.AuthNotifier", 1, 0, "AuthNotifier");
    qmlRegisterType<MeetingNotifier>("NetEase.Meeting.MeetingNotifer", 1, 0, "MeetingNotifer");
    qmlRegisterType<MembersModel>("NetEase.Meeting.MembersModel", 1, 0, "MembersModel");
    qmlRegisterType<DeviceModel>("NetEase.Meeting.DeviceModel", 1, 0, "DeviceModel");
    qmlRegisterType<FrameProvider>("NetEase.Meeting.FrameProvider", 1, 0, "FrameProvider");
    qmlRegisterType<ScreenProvider>("NetEase.Meeting.ScreenProvider", 1, 0, "ScreenProvider");
    qmlRegisterType<ScreenModel>("NetEase.Meeting.ScreenModel", 1, 0, "ScreenModel");
    qmlRegisterType<Clipboard>("Clipboard", 1, 0, "Clipboard");
    qmlRegisterType<MouseEventSpy>("MouseEventSpy", 1, 0, "MouseEventSpy");

    qmlRegisterSingletonType(QUrl("qrc:/qml/invite/Invitation.qml"), "NetEase.Meeting.Invitation", 1, 0, "InvitationWnd");
    qmlRegisterSingletonType(QUrl("qrc:/qml/settings/SettingsWindow.qml"), "NetEase.Meeting.Settings", 1, 0, "SettingsWnd");
    qmlRegisterSingletonType(QUrl("qrc:/qml/share/SSToolbar.qml"), "NetEase.Meeting.ScreenShare", 1, 0, "ScreenShareWnd");
}

NEAuthService* NEMeetingInstance::getAuthService()
{
    return auth_service_ == nullptr ? auth_service_.get() : nullptr;
}
NEMeetingService* NEMeetingInstance::getMeetingService()
{
    return meeting_service_ == nullptr ? meeting_service_.get() : nullptr;
}
NESettingsService* NEMeetingInstance::getSettingsService()
{
    return settings_service_ == nullptr ? settings_service_.get() : nullptr;
}
NEAccountService* NEMeetingInstance::getAccountService()
{
    return account_service_ == nullptr ? account_service_.get() : nullptr;
}
