/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "whiteboard_manager.h"
#include "controller/whiteboard_ctrl_interface.h"
#include "manager/meeting_manager.h"
#include "members_manager.h"

WhiteboardManager::WhiteboardManager(QObject* parent)
    : QObject(parent) {
    m_whiteboardController = MeetingManager::getInstance()->getWhiteboardController();
    qRegisterMetaType<NERoomWhiteboardShareStatus>();
}

void WhiteboardManager::onWhiteboardInitStatus() {
    if (m_whiteboardSharing) {
        return;
    }

    if (!m_bAutoOpenWhiteboard) {
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
    m_whiteboardController->startWhiteboardShare(std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
}

void WhiteboardManager::closeWhiteboard(const QString& accountId) {
    if(accountId == AuthManager::getInstance()->authAccountId()) {
        m_whiteboardController->stopWhiteboardShare(std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
    } else {
        m_whiteboardController->stopParticipantWhiteboardShare(accountId.toStdString()), std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2);
    }
}

void WhiteboardManager::enableWhiteboardDraw(const QString& accountId) {
    m_whiteboardController->enableWhiteboardInteractPrivilege(accountId.toStdString(), std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
}

void WhiteboardManager::disableWhiteboardDraw(const QString& accountId) {
    m_whiteboardController->disableWhiteboardInteractPrivilege(accountId.toStdString(), std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
}

QString WhiteboardManager::getDefaultDownloadPath() {
    return QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
}

void WhiteboardManager::showFileInFolder(const QString& path) {
#ifdef Q_OS_WIN32
    QProcess::startDetached("explorer.exe", {"/select,", QDir::toNativeSeparators(path)});
#elif defined(Q_OS_MACX)
    QProcess::execute("/usr/bin/osascript", {"-e", "tell application \"Finder\" to reveal POSIX file \"" + path + "\""});
    QProcess::execute("/usr/bin/osascript", {"-e", "tell application \"Finder\" to activate"});
#endif
}

QString WhiteboardManager::getWhiteboardUrl() {
    return QString::fromStdString(m_whiteboardController->getWhiteboardUrl());
}

QString WhiteboardManager::getWhiteboardLoginMessage() {
    return QString::fromStdString(m_whiteboardController->getWhiteboardLoginMessage());
}

QString WhiteboardManager::getWhiteboardLogoutMessage() {
    return QString::fromStdString(m_whiteboardController->getWhiteboardLogoutMessage());
}

QString WhiteboardManager::getWhiteboardDrawPrivilegeMessage() {
    return QString::fromStdString(m_whiteboardController->getWhiteboardDrawPrivilegeMessage());
}

QString WhiteboardManager::getWhiteboardToolConfigMessage() {
    return QString::fromStdString(m_whiteboardController->getWhiteboardToolConfigMessage());
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
    setWhiteboardSharerAccountId(status == kNERoomWhiteboardShareStatusStart ? userId : "");

    if (!isSharing) {
        //重置画笔权限
        MembersManager::getInstance()->resetWhiteboardDrawEnable();
        setWhiteboardDrawEnable(false);

        if (status == kNERoomWhiteboardShareStatusStopByHost) {
            emit whiteboardCloseByHost();
        }
    }
}

void WhiteboardManager::onRoomUserWhiteboardDrawEnableStatusChangedUI(const QString& userId, bool enable) {
    setWhiteboardDrawEnable(enable);
    emit whiteboardDrawEnableChanged(userId, enable);
}
