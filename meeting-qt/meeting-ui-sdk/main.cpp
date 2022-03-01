/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include <QUuid>
#include "manager/chat_manager.h"
#include "manager/device_manager.h"
#include "manager/global_manager.h"
#include "manager/live_manager.h"
#include "manager/meeting/members_manager.h"
#include "manager/meeting/share_manager.h"
#include "manager/meeting/video_manager.h"
#include "manager/meeting/whiteboard_manager.h"
#include "manager/more_item_manager.h"
#include "manager/settings_manager.h"
#include "modules/command_parser.h"

#include "models/device_model.h"
#include "models/live_members_model.h"
#include "models/members_model.h"
#include "models/more_item_model.h"
#include "models/screen_model.h"

#include "providers/frame_provider.h"
#include "providers/frame_rate.h"
#include "providers/screen_provider.h"
#include "providers/video_window.h"

#include "components/clipboard.h"
#include "components/mouse_event_spy.h"
#include "components/screensaver.h"
#include "components/whiteboard_jsBridge.h"

#include "ipc_handlers/hosting_module_client.h"

#include "base/log_instance.h"

#include <QtWebEngine/QtWebEngine>

#ifdef Q_OS_WIN32
#include "app_dump.h"
#else
#endif

bool g_bInitialized = false;

HostingModuleClient ipcClient;

int main(int argc, char* argv[]) {
#ifdef WIN32
    ::SetUnhandledExceptionFilter(MyUnhandledExceptionFilter);
    HostingModuleClient::setBugList(argv[0]);
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
#else
    signal(SIGPIPE, SIG_IGN);
    QGuiApplication::setQuitOnLastWindowClosed(false);
#endif
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

    QtWebEngine::initialize();

    QGuiApplication app(argc, argv);

    CommandParser commandParser;
    auto runType = commandParser.parseCommandLine(app);
    QString appKey;
    bool useAssetSrvConfig = false;
    bool multClient = false;
    switch (runType) {
        case kRunTypeIPCMode: {
            unsigned short port = commandParser.getIPCClientPort();
            qInfo() << "NetEase meeting startup on port:" << port;
            ipcClient.InitLocalEnviroment(port);
            QElapsedTimer time;
            time.start();
            int maxTime = 5 * 1000;
            bool bLog = false;
            while (!g_bInitialized) {
                std::this_thread::yield();
                if (!bLog && time.elapsed() > maxTime) {
                    ipcClient.WriteLog(QString("g_bInitialized not init, pid: %1").arg(qApp->applicationPid()));
                    bLog = true;
                }
            }
            ipcClient.WriteLog(QString("g_bInitialized inited, pid: %1").arg(qApp->applicationPid()));

            QString strLogPath = QString::fromStdString(ipcClient.getSDKConfig().getLoggerConfig()->LoggerPath());
            while (strLogPath.endsWith("/") || strLogPath.endsWith("\\")) {
                strLogPath = strLogPath.left(strLogPath.length() - 1);
            }
            qApp->setProperty("logPath", strLogPath);
            qApp->setProperty("logLevel", ipcClient.getSDKConfig().getLoggerConfig()->LoggerLevel());
            break;
        }
        case kRunTypeCommandlineMode: {
            qInfo() << "Run application as command line mode";
            ApplicationInfo appInfo = commandParser.getApplicationInfo();
            app.setApplicationName(appInfo.appliactionName);
            app.setApplicationDisplayName(appInfo.applicationDisplayName);
            app.setOrganizationDomain(appInfo.applicationDomain);
            app.setOrganizationName(appInfo.organizationName);
            appKey = commandParser.getCommandLineInfo().appKey;
            break;
        }
        case kRunTypeDefault: {
            qInfo() << "Failed to parse command line parameters.";
            return 0;
        }
        default:
            break;
    }

    LogInstance logger(argv);
    Invoker::getInstance();
    SettingsManager::getInstance();
    if (kRunTypeIPCMode == runType) {
        auto sdkConfig = ipcClient.getSDKConfig();
        appKey = QString::fromStdString(sdkConfig.getAppKey());
        useAssetSrvConfig = sdkConfig.getUseAssetServerConfig();
    } else if (kRunTypeCommandlineMode == runType) {
        CommandlineInfo command = commandParser.getCommandLineInfo();
        multClient = command.multClient;
    }

    // Load translations
    QTranslator translator;
#ifdef Q_OS_MACX
    bool loadResult =
        translator.load(QLocale(), QLatin1String("meeting-ui-sdk"), QLatin1String("_"), QGuiApplication::applicationDirPath() + "/../Resources/");
#else
    bool loadResult = translator.load(QLocale(), QLatin1String("meeting-ui-sdk"), QLatin1String("_"), QGuiApplication::applicationDirPath());
#endif
    if (loadResult)
        app.installTranslator(&translator);

    GlobalManager::getInstance()->initialize(appKey, useAssetSrvConfig, !multClient ? "" : QUuid::createUuid().toString());
    AuthManager::getInstance()->initialize();
    MeetingManager::getInstance()->initialize();
    DeviceManager::getInstance()->initialize();
    ChatManager::getInstance()->initialize();

    if (runType == kRunTypeIPCMode) {
        ipcClient.OnInitLocalEnviroment(true);
    }

    if (runType == kRunTypeCommandlineMode) {
        CommandlineInfo command = commandParser.getCommandLineInfo();
        if (command.accountId.isEmpty() || command.accountToken.isEmpty()) {
            MoreItemManager::getInstance()->restoreMore();
            MoreItemManager::getInstance()->restoreToolbar();
            NEJoinRoomParams params;
            NEJoinRoomOptions options;
            params.roomId = command.meetingId.toStdString();
            params.displayName = command.nickname.toStdString();
            options.noAudio = !command.audio;
            options.noVideo = !command.video;
            MeetingManager::getInstance()->joinMeeting(params, options);
        } else {
            AuthManager::getInstance()->setAutoLoginInfo(command.accountId, command.accountToken);
            MeetingManager::getInstance()->setStartMeetingInfo(command.create, command.meetingId, command.nickname, command.audio, command.video,
                                                               command.hideInvite);
        }
    }

    int result = 0;
    qmlRegisterType<MembersModel>("NetEase.Meeting.MembersModel", 1, 0, "MembersModel");
    qmlRegisterType<DeviceModel>("NetEase.Meeting.DeviceModel", 1, 0, "DeviceModel");
    qmlRegisterType<FrameProvider>("NetEase.Meeting.FrameProvider", 1, 0, "FrameProvider");
    qmlRegisterType<ScreenProvider>("NetEase.Meeting.ScreenProvider", 1, 0, "ScreenProvider");
    qmlRegisterType<ScreenModel>("NetEase.Meeting.ScreenModel", 1, 0, "ScreenModel");
    qmlRegisterType<MoreItemModel>("NetEase.Meeting.MoreItemModel", 1, 0, "MoreItemModel");
    qmlRegisterType<ToolbarItemModel>("NetEase.Meeting.ToolbarItemModel", 1, 0, "ToolbarItemModel");
    qmlRegisterType<Clipboard>("Clipboard", 1, 0, "Clipboard");
    qmlRegisterType<MouseEventSpy>("MouseEventSpy", 1, 0, "MouseEventSpy");
    qmlRegisterType<FilterProxyModel>("NetEase.Meeting.FilterProxyModel", 1, 0, "FilterProxyModel");
    qmlRegisterType<ScreenSaver>("NetEase.Meeting.ScreenSaver", 1, 0, "ScreenSaver");
    qmlRegisterType<LiveMembersModel>("NetEase.Meeting.LiveMembersModel", 1, 0, "LiveMembersModel");
    qmlRegisterType<VideoWindow>("NetEase.Meeting.VideoWindow", 1, 0, "VideoWindow");
    qmlRegisterType<WhiteboardJsBridge>("WhiteboardJsBridge", 1, 0, "WhiteboardJsBridge");

    qmlRegisterSingletonType(QUrl("qrc:/qml/toast/ToastWindow.qml"), "NetEase.Meeting.ToastHelper", 1, 0, "ToastHelper");
    qmlRegisterSingletonType(QUrl("qrc:/qml/toast/GlobalToast.qml"), "NetEase.Meeting.GlobalToast", 1, 0, "GlobalToast");
    qmlRegisterSingletonType(QUrl("qrc:/qml/toast/MessageBubble.qml"), "NetEase.Meeting.MessageBubble", 1, 0, "MessageBubble");
    qmlRegisterSingletonType(QUrl("qrc:/qml/settings/SettingsWindow.qml"), "NetEase.Meeting.Settings", 1, 0, "SettingsWnd");
    qmlRegisterSingletonType(QUrl("qrc:/qml/chattingroom/GlobalChatManager.qml"), "NetEase.Meeting.GlobalChatManager", 1, 0, "GlobalChatManager");

    {
        QQmlApplicationEngine engine;
        QObject::connect(&engine, &QQmlApplicationEngine::quit, &QGuiApplication::quit);

        QObject::connect(AudioManager::getInstance(), &AudioManager::userAudioStatusChanged, MembersManager::getInstance(),
                         &MembersManager::handleAudioStatusChanged);
        QObject::connect(VideoManager::getInstance(), &VideoManager::userVideoStatusChanged, MembersManager::getInstance(),
                         &MembersManager::handleVideoStatusChanged);
        QObject::connect(AudioManager::getInstance(), &AudioManager::handsupStatusChanged, MembersManager::getInstance(),
                         &MembersManager::handleHandsupStatusChanged);
        QObject::connect(MeetingManager::getInstance(), &MeetingManager::meetingStatusChanged, MembersManager::getInstance(),
                         &MembersManager::handleMeetingStatusChanged);
        QObject::connect(WhiteboardManager::getInstance(), &WhiteboardManager::whiteboardDrawEnableChanged, MembersManager::getInstance(),
                         &MembersManager::handleWhiteboardDrawEnableChanged);
        QObject::connect(ShareManager::getInstance(), &ShareManager::shareAccountIdChanged, MembersManager::getInstance(),
                         &MembersManager::handleShareAccountIdChanged);

        engine.addImageProvider(QLatin1String("shareScreen"), new ShareImageProvider(ScreenModel::kScreenType_Screen));
        engine.addImageProvider(QLatin1String("shareApp"), new ShareImageProvider(ScreenModel::kScreenType_App));
        engine.addImageProvider(QLatin1String("localImage"), new localImageProvider());
        engine.rootContext()->setContextProperty("globalManager", GlobalManager::getInstance());
        engine.rootContext()->setContextProperty("authManager", AuthManager::getInstance());
        engine.rootContext()->setContextProperty("meetingManager", MeetingManager::getInstance());
        engine.rootContext()->setContextProperty("membersManager", MembersManager::getInstance());
        engine.rootContext()->setContextProperty("audioManager", AudioManager::getInstance());
        engine.rootContext()->setContextProperty("videoManager", VideoManager::getInstance());
        engine.rootContext()->setContextProperty("shareManager", ShareManager::getInstance());
        engine.rootContext()->setContextProperty("deviceManager", DeviceManager::getInstance());
        engine.rootContext()->setContextProperty("availableStyles", QQuickStyle::availableStyles());
        engine.rootContext()->setContextProperty("chatManager", ChatManager::getInstance());
        engine.rootContext()->setContextProperty("moreItemManager", MoreItemManager::getInstance());
        engine.rootContext()->setContextProperty("SettingsManager", SettingsManager::getInstance());
        engine.rootContext()->setContextProperty("liveManager", LiveManager::getInstance());
        engine.rootContext()->setContextProperty("whiteboardManager", WhiteboardManager::getInstance());

        const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
        QObject::connect(
            &engine, &QQmlApplicationEngine::objectCreated, &app,
            [url](QObject* obj, const QUrl& objUrl) {
                if (!obj && url == objUrl)
                    QCoreApplication::exit(-1);
            },
            Qt::QueuedConnection);
        engine.load(url);

        if (!engine.rootObjects().isEmpty()) {
            QObject* pObj = engine.rootObjects().first();
            if (pObj) {
                QWindow* pWindow = qobject_cast<QWindow*>(pObj);
                if (pWindow) {
                    ShareManager::getInstance()->setMainWindow(pWindow);
                }
            }
        }

        result = app.exec();
    }

    ChatManager::getInstance()->release();
    MeetingManager::getInstance()->release();
    AuthManager::getInstance()->release();
    DeviceManager::getInstance()->release();
    GlobalManager::getInstance()->release();

    if (runType == kRunTypeIPCMode)
        ipcClient.Uninit();

    return result;
}
