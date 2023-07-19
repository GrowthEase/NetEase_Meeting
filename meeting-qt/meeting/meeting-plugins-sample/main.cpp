// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include <QDebug>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char* argv[]) {
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    QGuiApplication::setOrganizationName("NetEase");
    QGuiApplication::setOrganizationDomain("yunxin.163.com");
    QGuiApplication::setApplicationName("NEMeetingSample");
    QGuiApplication::setApplicationDisplayName("NEMeeting Sample");
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    // engine.addPluginPath(QGuiApplication::applicationDirPath());
    const QUrl url(QStringLiteral("qrc:/main.qml"));
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
