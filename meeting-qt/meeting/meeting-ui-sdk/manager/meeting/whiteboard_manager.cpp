// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "whiteboard_manager.h"
#include "controller/whiteboard_ctrl_interface.h"
#include "manager/global_manager.h"
#include "manager/meeting_manager.h"
#include "members_manager.h"

WhiteboardManager::WhiteboardManager(QObject* parent)
    : QObject(parent) {
    qRegisterMetaType<NERoomWhiteboardShareStatus>();
    m_meetingWhiteboardView = new MeetingWhiteboardView;
}

WhiteboardManager::~WhiteboardManager() {
    if (m_meetingWhiteboardView) {
        delete m_meetingWhiteboardView;
        m_meetingWhiteboardView = nullptr;
    }
}

void WhiteboardManager::initWhiteboardStatus() {
    m_whiteboardDrawEnable = false;
    m_whiteboardSharing = false;
    m_whiteboardSharerAccountId = "";
    auto* whiteboardController = MeetingManager::getInstance()->getWhiteboardController();
    if (!whiteboardController)
        return;
    whiteboardController->setupWhiteboardCanvas(m_meetingWhiteboardView);
    auto userId = whiteboardController->getWhiteboardSharingUserUuid();
    if (!userId.empty()) {
        onRoomUserWhiteboardShareStatusChanged(userId, kNERoomWhiteboardShareStatusStart);
    } else {
        setWhiteboardSharing(false);
        setWhiteboardSharerAccountId("");
    }
}

void WhiteboardManager::onRoomUserWhiteboardShareStatusChanged(const std::string& userId, NERoomWhiteboardShareStatus status) {
    QMetaObject::invokeMethod(this, "onRoomUserWhiteboardShareStatusChangedUI", Qt::AutoConnection, Q_ARG(QString, QString::fromStdString(userId)),
                              Q_ARG(NERoomWhiteboardShareStatus, status));
}

void WhiteboardManager::onRoomUserWhiteboardDrawEnableStatusChanged(const std::string& userId, bool enable) {
    QMetaObject::invokeMethod(this, "onRoomUserWhiteboardDrawEnableStatusChangedUI", Qt::AutoConnection,
                              Q_ARG(QString, QString::fromStdString(userId)), Q_ARG(bool, enable));
}

void WhiteboardManager::openWhiteboard(const QString& accountId) {
    auto whiteboardController = MeetingManager::getInstance()->getWhiteboardController();
    if (whiteboardController) {
        whiteboardController->startWhiteboardShare(
            std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
    }
}

void WhiteboardManager::closeWhiteboard(const QString& accountId) {
    auto whiteboardController = MeetingManager::getInstance()->getWhiteboardController();
    if (whiteboardController) {
        if (accountId == AuthManager::getInstance()->authAccountId()) {
            whiteboardController->stopWhiteboardShare(
                std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
        } else {
            whiteboardController->stopMemberWhiteboardShare(accountId.toStdString()),
                std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2);
        }
    }
}

void WhiteboardManager::enableWhiteboardDraw(const QString& accountId) {
    MeetingManager::getInstance()->getRoomContext()->updateMemberProperty(
        accountId.toStdString(), "wbDrawable", "1",
        std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
}

void WhiteboardManager::disableWhiteboardDraw(const QString& accountId) {
    MeetingManager::getInstance()->getRoomContext()->updateMemberProperty(
        accountId.toStdString(), "wbDrawable", "0",
        std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
}

QString WhiteboardManager::getDefaultDownloadPath() {
    return QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
}

void WhiteboardManager::showFileInFolder(const QString& path) {
#ifdef Q_OS_WIN32
    QProcess::startDetached("explorer.exe", {"/select,", QDir::toNativeSeparators(path)});
#elif defined(Q_OS_MACX)
    QProcess::startDetached("/usr/bin/osascript", {"-e", "tell application \"Finder\" to reveal POSIX file \"" + path + "\""});
    QProcess::startDetached("/usr/bin/osascript", {"-e", "tell application \"Finder\" to activate"});
#endif
}

QString WhiteboardManager::getWhiteboardUrl() {
    auto whiteboardController = MeetingManager::getInstance()->getWhiteboardController();
    if (whiteboardController) {
        QString url = QString::fromStdString(whiteboardController->getWhiteboardUrl());
        bool useConsole = ConfigManager::getInstance()->getValue("whiteboardConsole").toBool();
        if (useConsole) {
            int index = url.indexOf(".html");
            url.insert(index, "_vconsole");
        }
        return url;
    }

    return "";
}

void WhiteboardManager::login() {
    auto whiteboardController = MeetingManager::getInstance()->getWhiteboardController();
    if (whiteboardController) {
        whiteboardController->login();
    }
}

void WhiteboardManager::logout() {
    auto whiteboardController = MeetingManager::getInstance()->getWhiteboardController();
    if (whiteboardController) {
        whiteboardController->logout();
    }
}

void WhiteboardManager::auth() {
    auto whiteboardController = MeetingManager::getInstance()->getWhiteboardController();
    if (whiteboardController) {
        whiteboardController->auth();
    }
}

void WhiteboardManager::setEnableDraw(bool enable) {
    auto whiteboardController = MeetingManager::getInstance()->getWhiteboardController();
    if (whiteboardController) {
        whiteboardController->setEnableDraw(enable);
    }
}

bool WhiteboardManager::hasDrawPrivilege() {
    auto whiteboardController = MeetingManager::getInstance()->getWhiteboardController();
    if (whiteboardController) {
        return whiteboardController->getWhiteboardSharingUserUuid() == AuthManager::getInstance()->authAccountId().toStdString() ||
               m_whiteboardDrawEnable;
    } else {
        return m_whiteboardDrawEnable;
    }
}

bool WhiteboardManager::whiteboardSharing() const {
    return m_whiteboardSharing;
}

void WhiteboardManager::setWhiteboardSharing(bool whiteboardSharing) {
    if (m_whiteboardSharing != whiteboardSharing) {
        m_whiteboardSharing = whiteboardSharing;
        emit whiteboardSharingChanged();
    }
}

bool WhiteboardManager::whiteboardDrawEnable() const {
    return m_whiteboardDrawEnable;
}

void WhiteboardManager::setWhiteboardDrawEnable(bool enable) {
    if (m_whiteboardDrawEnable != enable) {
        m_whiteboardDrawEnable = enable;
    }
}

QString WhiteboardManager::whiteboardSharerAccountId() const {
    return m_whiteboardSharerAccountId;
}

void WhiteboardManager::setWhiteboardSharerAccountId(const QString& whiteboardSharerAccountId) {
    m_whiteboardSharerAccountId = whiteboardSharerAccountId;
    emit whiteboardSharerAccountIdChanged();
}

void WhiteboardManager::onRoomUserWhiteboardShareStatusChangedUI(const QString& userId, NERoomWhiteboardShareStatus status) {
    bool isSharing = status == kNERoomWhiteboardShareStatusStart;
    setWhiteboardSharing(isSharing);
    setWhiteboardSharerAccountId(isSharing ? userId : "");
    if (userId.toStdString() == AuthManager::getInstance()->getAuthInfo().accountId) {
        setWhiteboardDrawEnable(isSharing);
    }

    if (!isSharing) {
        if (m_whiteboardDrawEnable) {
            disableWhiteboardDraw(QString::fromStdString(AuthManager::getInstance()->getAuthInfo().accountId));
        }

        // 重置画笔权限
        MembersManager::getInstance()->resetWhiteboardDrawEnable();
        if (status == kNERoomWhiteboardShareStatusStopByHost) {
            emit whiteboardCloseByHost();
        }
    }
    MembersManager::getInstance()->updateWhiteboardOwner(userId, isSharing);
}

void WhiteboardManager::onRoomUserWhiteboardDrawEnableStatusChangedUI(const QString& userId, bool enable) {
    if (userId.toStdString() == AuthManager::getInstance()->getAuthInfo().accountId) {
        setWhiteboardDrawEnable(enable);
    }

    emit whiteboardDrawEnableChanged(userId, enable);
}

void MeetingWhiteboardView::onLogin(const std::string& webScript) {
    WhiteboardManager::getInstance()->sendMessageToWeb(QString::fromStdString(webScript));
}

void MeetingWhiteboardView::onAuth(const std::string& webScript) {
    WhiteboardManager::getInstance()->sendMessageToWeb(QString::fromStdString(webScript));
}

void MeetingWhiteboardView::onLogout(const std::string& webScript) {
    WhiteboardManager::getInstance()->sendMessageToWeb(QString::fromStdString(webScript));
}

void MeetingWhiteboardView::onDrawEnableChanged(const std::string& webScript) {
    WhiteboardManager::getInstance()->sendMessageToWeb(QString::fromStdString(webScript));
}

void MeetingWhiteboardView::onToolConfigChanged(const std::string& webScript) {
    WhiteboardManager::getInstance()->sendMessageToWeb(QString::fromStdString(webScript));
}
