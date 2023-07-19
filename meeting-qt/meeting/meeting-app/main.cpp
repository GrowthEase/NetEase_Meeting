// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include <QSharedMemory>
#include <QtWebEngine/QtWebEngine>
#include "meeting_app.h"
#include "modules/auth_manager.h"
#include "modules/client_updator.h"
#include "modules/commandline_parser.h"
#include "modules/config_manager.h"
#include "modules/feedback_manager.h"
#include "modules/history_manager.h"
#include "modules/local_socket.h"
#include "modules/models/history_model.h"
#include "modules/models/members_model.h"
#include "modules/nemeeting_sdk_manager.h"
#include "modules/statistics_manager.h"
#ifdef WIN32
#include "app_dump.h"
#endif

int main(int argc, char* argv[]) {
#ifdef WIN32
    ::SetUnhandledExceptionFilter(MyUnhandledExceptionFilter);
    MeetingApp::setBugList(argv[0]);
    MeetingApp::setAttribute(Qt::AA_EnableHighDpiScaling);
    MeetingApp::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QtWebEngine::initialize();
#else
    signal(SIGPIPE, SIG_IGN);
#endif

    MeetingApp::setOrganizationName("NetEase");
    MeetingApp::setOrganizationDomain("yunxin.163.com");
    MeetingApp::setApplicationName("Meeting");
    MeetingApp::setApplicationDisplayName("NetEase Meeting");
    MeetingApp::setApplicationVersion(APPLICATION_VERSION);

    MeetingApp app(argc, argv);

    if (ConfigManager::getInstance()->getValue("localLogsTmp", "").toString().isEmpty()) {
        ConfigManager::getInstance()->setValue("localLogsTmp", "clear");
        FeedbackManager::clean(true, true);
    }

    LogInstance logInstance(argv);

    bool appRunning = false;
    LocalSocket appInstance;
    if (appInstance.connectToServer()) {
        appRunning = true;
    }

    CommandLineParser commandLineParser;
    auto type = commandLineParser.parseCommandLine(app);
    auto arguments = commandLineParser.getArguments();
    QString inviteMeetingId;
    if (appRunning) {
        if (type == kRunTypeInvite || type == kRunTypeSSO) {
            appInstance.notify(arguments);
            return 0;
        }
    } else {
        QUrl url(arguments);
        QUrlQuery urlQuery(url.query());
        YXLOG(Info) << "urlQuery: " << urlQuery.toString().toStdString() << YXLOGEnd;
        if (urlQuery.hasQueryItem("meetingId")) {
            inviteMeetingId = urlQuery.queryItemValue("meetingId");
        }
    }

    appInstance.listen();

    QString languageTmp = "zh-CN";
    QString language = languageTmp;
    language.replace("-", "_");
    language.insert(0, "meeting-app_");
    language.append(".qm");
    YXLOG(Info) << "language is: " << language.toStdString() << YXLOGEnd;
    // Load translations
    QTranslator translator;
    QString qmPath = QGuiApplication::applicationDirPath() + "/";
#ifdef Q_OS_MACX
    qmPath.append("../Resources/");
#endif
    if (!QFile::exists(qmPath + language)) {
        language = languageTmp;
        auto sysLanguageList = language.split("-");
        if (!sysLanguageList.empty()) {
            language = sysLanguageList.at(0);
        }
        language.insert(0, "meeting-app_");
        language.append(".qm");
        YXLOG(Info) << "language is: " << language.toStdString() << YXLOGEnd;
    }

    bool loadResult = translator.load(language, qmPath);
    if (loadResult) {
        loadResult = app.installTranslator(&translator);
        if (!loadResult) {
            YXLOG(Warn) << "installTranslator language failed." << YXLOGEnd;
        }
    } else {
        YXLOG(Warn) << "translator load failed." << YXLOGEnd;
    }

    // Set default styelsheet
    QQuickStyle::setStyle("Material");

    qmlRegisterUncreatableType<MeetingsStatus>("NetEase.Meeting.MeetingStatus", 1, 0, "MeetingStatus", "");
    qmlRegisterUncreatableType<RunningStatus>("NetEase.Meeting.RunningStatus", 1, 0, "RunningStatus", "");
    qmlRegisterType<Clipboard>("NetEase.Meeting.Clipboard", 1, 0, "Clipboard");
    // qmlRegisterType<URSJsBridge>("URSJsBridge", 1, 0, "URSJsBridge");
    qmlRegisterType<MembersModel>("NetEase.Meeting.MembersModel", 1, 0, "MembersModel");
    qmlRegisterType<HistoryModel>("NetEase.Meeting.HistoryModel", 1, 0, "HistoryModel");
    qmlRegisterSingletonType(QUrl("qrc:/qml/components/GlobalToast.qml"), "NetEase.Meeting.GlobalToast", 1, 0, "GlobalToast");

    AuthManager authManager;
    HistoryManager historyManager;
    NEMeetingSDKManager meetingManager(&authManager, &historyManager);
    if (!inviteMeetingId.isEmpty()) {
        meetingManager.onInviteByLink(inviteMeetingId);
    }
    ClientUpdater clientUpdater(&meetingManager);
    StatisticsManager statisticsManager;
    FeedbackManager feedbackManager(&authManager);
    QQmlApplicationEngine engine;
    QObject::connect(&app, &MeetingApp::dockClicked, &meetingManager, &NEMeetingSDKManager::onDockClicked);
    QObject::connect(&app, &MeetingApp::loginWithSSO, &authManager, &AuthManager::loginWithSSO);
    QObject::connect(&app, &MeetingApp::inviteByLink, &meetingManager, &NEMeetingSDKManager::onInviteByLink);
    QObject::connect(&appInstance, &LocalSocket::loginWithSSO, &authManager, &AuthManager::loginWithSSO);
    QObject::connect(&appInstance, &LocalSocket::inviteByLink, &meetingManager, &NEMeetingSDKManager::onInviteByLink);
    QObject::connect(&meetingManager, &NEMeetingSDKManager::unInitializeFeedback, &feedbackManager, &FeedbackManager::resetFeedback);

    engine.rootContext()->setContextProperty("configManager", ConfigManager::getInstance());
    engine.rootContext()->setContextProperty("meetingManager", &meetingManager);
    engine.rootContext()->setContextProperty("authManager", &authManager);
    engine.rootContext()->setContextProperty("historyManager", &historyManager);
    engine.rootContext()->setContextProperty("clientUpdater", &clientUpdater);
    engine.rootContext()->setContextProperty("statisticsManager", &statisticsManager);
    engine.rootContext()->setContextProperty("feedbackManager", &feedbackManager);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject* obj, const QUrl& objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    int ret = app.exec();

    int meetingStatus = meetingManager.getCurrentMeetingStatus();
    if (ret == 0 && (meetingStatus == 3 || meetingStatus == 4)) {
        qint64 timestamp = QDateTime::currentDateTime().toSecsSinceEpoch();
        ConfigManager::getInstance()->setValue("lastExceptionTime", timestamp);
        ConfigManager::getInstance()->setValue("lastMeetingStatus", meetingStatus);
        return 0;
    }

    if (773 == ret) {
        clientUpdater.lanchApp();
        return 0;
    }

    ConfigManager::getInstance()->setValue("lastMeetingStatus", 1);

    return ret;
}
