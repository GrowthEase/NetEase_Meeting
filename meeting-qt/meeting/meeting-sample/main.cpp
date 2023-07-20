// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include <QDateTime>
#include <QDir>
#include <QFont>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QStandardPaths>
#include <fstream>
#include "nemeeting_manager.h"

QString appDataDir;
QString strLogPath = "meetingSample_" + QDateTime::currentDateTime().toString("yyyy-MM-dd").append("-log.txt");

void messageHandler(QtMsgType, const QMessageLogContext& context, const QString& message) {
    if (context.file && !message.isEmpty()) {
        std::string strFileTmp = context.file;
        const char* ptr = strrchr(strFileTmp.c_str(), '/');
        if (nullptr != ptr) {
            char fn[512] = {0};
            sprintf(fn, "%s", ptr + 1);
            strFileTmp = fn;
        }
        const char* ptrTmp = strrchr(strFileTmp.c_str(), '\\');
        if (nullptr != ptrTmp) {
            char fn[512] = {0};
            sprintf(fn, "%s", ptrTmp + 1);
            strFileTmp = fn;
        }
        std::string strLog;
        strLog.append("[");
        strLog.append(strFileTmp);
        strLog.append(":");
        strLog.append(std::to_string(context.line));
        strLog.append("] ");
        strLog.append(message.toStdString());
        std::string messageLog =
            qPrintable(QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss").append(": ").append(QString::fromStdString(strLog)));
        std::ofstream output;
        output.open(qPrintable(appDataDir + strLogPath), std::ios::out | std::ios::app);
        output << messageLog << "\n";
    }
}

int main(int argc, char* argv[]) {
#ifdef WIN32
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
#else

#endif
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    QGuiApplication::setOrganizationName("NetEase");
    QGuiApplication::setOrganizationDomain("yunxin.163.com");
    QGuiApplication::setApplicationName("MeetingSample");
    QGuiApplication::setApplicationDisplayName("NetEase Meeting");

    QFont font = QGuiApplication::font();
    font.setWeight(QFont::Light);
    QGuiApplication::setFont(font);

    appDataDir = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    appDataDir.append("/Netease/MeetingSample/app/");
    QDir logDir = appDataDir;
    if (!logDir.exists(appDataDir))
        logDir.mkpath(appDataDir);

    if (QFile::exists(appDataDir + strLogPath)) {
        std::ofstream output;
        output.open(qPrintable(appDataDir + strLogPath), std::ios::out | std::ios::app);
        output << "\n";
        output << "\n";
        std::string messageLog =
            qPrintable(QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss").append(": ======================================"));
        output << messageLog << "\n";
    }
    qInstallMessageHandler(messageHandler);

    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;

    NEMeetingManager meetingManager;

    engine.rootContext()->setContextProperty("meetingManager", &meetingManager);

    qmlRegisterUncreatableType<MeetingsStatus>("NetEase.Meeting.MeetingStatus", 1, 0, "MeetingStatus", "");
    qmlRegisterUncreatableType<RunningStatus>("NetEase.Meeting.RunningStatus", 1, 0, "RunningStatus", "");

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject* obj, const QUrl& objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
