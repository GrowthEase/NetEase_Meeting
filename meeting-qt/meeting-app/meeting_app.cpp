// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "meeting_app.h"
#include <QQuickWindow>
#include <QUrl>
#include <QUrlQuery>
#include "nemeeting_sdk_manager.h"

MeetingApp::MeetingApp(int& argc, char** argv)
    : QApplication(argc, argv) {}

void MeetingApp::setBugList(const char* argv) {
#if 0
    bool bRet = qputenv("QT_LOGGING_RULES", "qt.qpa.gl = true");
    if (!bRet) {
        qWarning() << "set qt.qpa.gl failed.";
    }
#endif

    QString strPath = QFileInfo(argv).absolutePath().append("/config/custom.json");
    if (!QFile::exists(strPath)) {
        qWarning() << "custom strPath is null.";
    } else {
        bool bRet = qputenv("QT_OPENGL_BUGLIST", strPath.toUtf8());
        if (!bRet) {
            qWarning() << "set setBugList failed.";
        }
    }

    QString ss = QFileInfo(argv).absolutePath().append("/config/custom.ini");
    QSettings settings(QFileInfo(argv).absolutePath().append("/config/custom.ini"), QSettings::IniFormat);
    settings.sync();

    //    QSGRendererInterface::GraphicsApi graphicsApi = (QSGRendererInterface::GraphicsApi)settings.value("Render/GraphicsApi", 0).toInt();
    //    if (graphicsApi != QSGRendererInterface::Unknown) {
    //        QQuickWindow::setSceneGraphBackend(graphicsApi);
    //    }

    int attribute = settings.value("Render/GraphicsApi", 0).toInt();
    switch (attribute) {
        case 1:
            QCoreApplication::setAttribute(Qt::AA_UseSoftwareOpenGL);
            break;
        case 2:
            QCoreApplication::setAttribute(Qt::AA_UseDesktopOpenGL);
            break;
        case 5:
            QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
            break;
        default:
            break;
    }
}

bool MeetingApp::notify(QObject* watched, QEvent* event) {
    if (watched == this && event->type() == QEvent::ApplicationStateChange) {
        auto ev = static_cast<QApplicationStateChangeEvent*>(event);
        YXLOG(Info) << "Application state changed: " << ev->applicationState() << YXLOGEnd;
        if (_prevAppState == Qt::ApplicationActive && ev->applicationState() == Qt::ApplicationActive) {
            emit dockClicked();
        }
        _prevAppState = ev->applicationState();
    }
    // This event only happended on macOS
    if (watched == this && event->type() == QEvent::FileOpen) {
        QFileOpenEvent* fileEvent = static_cast<QFileOpenEvent*>(event);
        if (!fileEvent->url().isEmpty()) {
            if (ConfigManager::getInstance()->getLocalDebugLevel()) {
                YXLOG(Debug) << "Received custom scheme url request: " << fileEvent->url().toString().toStdString() << YXLOGEnd;
            } else {
                YXLOG(Info) << "Received custom scheme url request." << YXLOGEnd;
            }

            QUrl url(fileEvent->url().toString());
            QUrlQuery urlQuery(url.query());
            emit loginWithSSO(urlQuery.queryItemValue(kSSOAppKey), urlQuery.queryItemValue(kSSOUser), urlQuery.queryItemValue(kSSOToken));
        } else if (!fileEvent->file().isEmpty()) {
            YXLOG(Info) << "Received custom scheme file request: " << fileEvent->file().toStdString() << YXLOGEnd;
        }
        return false;
    }

    return QApplication::notify(watched, event);
}
