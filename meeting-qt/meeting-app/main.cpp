/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include <QSharedMemory>
#include "meeting_app.h"
#include "modules/auth_manager.h"
#include "modules/client_updator.h"
#include "modules/statistics_manager.h"
#include "modules/nemeeting_sdk_manager.h"
#include "modules/feedback_manager.h"
#include "modules/local_socket.h"
#include "modules/commandline_parser.h"
#include "modules/config_manager.h"
#ifdef WIN32
#include "app_dump.h"
#endif

int main(int argc, char *argv[])
{
#ifdef WIN32
    ::SetUnhandledExceptionFilter(MyUnhandledExceptionFilter);
    MeetingApp::setBugList(argv[0]);
    MeetingApp::setAttribute(Qt::AA_EnableHighDpiScaling);
    MeetingApp::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
#else
    signal(SIGPIPE, SIG_IGN);
#endif

    MeetingApp::setOrganizationName("NetEase");
    MeetingApp::setOrganizationDomain("yunxin.163.com");
    MeetingApp::setApplicationName("Meeting");
    MeetingApp::setApplicationDisplayName("NetEase Meeting");
    MeetingApp::setApplicationVersion(APPLICATION_VERSION);

    MeetingApp app(argc, argv);

    LogInstance logInstance(argv);

    bool appRunning = false;
    LocalSocket appInstance;
    if (appInstance.connectToServer())
    {
        appRunning = true;
    }

    CommandLineParser commandLineParser;
    auto type = commandLineParser.parseCommandLine(app);
    if (type == kRunTypeSSO && appRunning)
    {
        appInstance.notify(commandLineParser.getSSOArguments());
        return 0;
    }

    appInstance.listen();

    // Load translations
    QTranslator translator;
#ifdef Q_OS_MACX
    bool loadResult = translator.load(QLocale(), QLatin1String("meeting-app"), QLatin1String("_"), QGuiApplication::applicationDirPath() + "/../Resources/");
#else
    bool loadResult = translator.load(QLocale(), QLatin1String("meeting-app"), QLatin1String("_"), QGuiApplication::applicationDirPath());
#endif
    if (loadResult)
        app.installTranslator(&translator);

    // Set default styelsheet
    QQuickStyle::setStyle("Material");

    qmlRegisterUncreatableType<MeetingsStatus>("NetEase.Meeting.MeetingStatus", 1, 0, "MeetingStatus", "");
    qmlRegisterUncreatableType<RunningStatus>("NetEase.Meeting.RunningStatus", 1, 0, "RunningStatus", "");
    qmlRegisterType<Clipboard>("NetEase.Meeting.Clipboard", 1, 0, "Clipboard");

    NEMeetingSDKManager meetingManager;
    AuthManager authManager;
    ClientUpdater clientUpdater(&meetingManager);
    StatisticsManager statisticsManager;
    FeedbackManager feedbackManager(&authManager);
    QQmlApplicationEngine engine;
    QObject::connect(&app, &MeetingApp::dockClicked, &meetingManager, &NEMeetingSDKManager::onDockClicked);
    QObject::connect(&app, &MeetingApp::loginWithSSO, &authManager, &AuthManager::loginWithSSO);
    QObject::connect(&appInstance, &LocalSocket::loginWithSSO, &authManager, &AuthManager::loginWithSSO);

    engine.rootContext()->setContextProperty("configManager", ConfigManager::getInstance());
    engine.rootContext()->setContextProperty("meetingManager", &meetingManager);
    engine.rootContext()->setContextProperty("authManager", &authManager);
    engine.rootContext()->setContextProperty("clientUpdater", &clientUpdater);
    engine.rootContext()->setContextProperty("statisticsManager", &statisticsManager);
    engine.rootContext()->setContextProperty("feedbackManager", &feedbackManager);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    int ret = app.exec();
    if (773 == ret)
    {
        clientUpdater.lanchApp();
        return 0;
    }

    return ret;
}
