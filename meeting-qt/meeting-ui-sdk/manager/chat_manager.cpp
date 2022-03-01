/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "chat_manager.h"
#include <QObject>
#include "global_manager.h"
#include "meeting/members_manager.h"

ChatManager::ChatManager(QObject* parent)
    : QObject(parent) {
    connect(MembersManager::getInstance(), &MembersManager::nicknameChanged, this, [this](const QString& accountId, const QString& nickname) {
        if (m_chatController) {
            if (accountId.toStdString() == GlobalManager::getInstance()->getAuthService()->getAccountInfo()->getAccountId()) {
                NEChatRoomUserRole data;
                data.nick = nickname.toStdString();
                m_chatController->updateChatRoomRole(data, {});
            }
        }
    });
}

ChatManager::~ChatManager() {}

void ChatManager::logoutChatroom() {
    if (m_chatController) {
        m_chatController->exitChatRoom();
    }

    m_bLogined = false;
}

void ChatManager::loginChatroom() {
    if (m_bLogined) {
        return;
    }

    if (m_chatRoomOpen) {
        m_chatController->enterChatRoom([this](int step, int error_code) {
            if (error_code != 200) {
                emit error(error_code, "");
            }

            if (step == 5) {
                if (error_code == 200)
                    m_bLogined = true;
                else
                    m_bLogined = false;
            }
        });
        m_bLogined = true;
    }
}

bool ChatManager::initialize() {
    m_bLogined = false;
    m_meetingSvr = GlobalManager::getInstance()->getRoomService();
    m_chatController = MeetingManager::getInstance()->getInRoomChatController();

    if (m_chatController == nullptr) {
        return false;
    }

    m_chatController->initialize();
    m_chatController->addListener(this);
    return true;
}

void ChatManager::release() {
    m_chatController->removeListener(nullptr);
    m_chatController->release();
}

void ChatManager::onChatroomLogout(int error_code, int reason) {
    Q_UNUSED(error_code);
    Q_UNUSED(reason);
}

void ChatManager::onRecvMsgCallback(int status, const std::string& jsonMsg) {
    QJsonDocument jsonDocument = QJsonDocument::fromJson(jsonMsg.c_str());
    emit recvMsgSiganl(status, jsonDocument.object());
}

void ChatManager::onRegLinkConditionCallback(const int condition) {
    YXLOG(Info) << "ChatManager::OnRegLinkConditionCallback : linkCondition = " << condition << YXLOGEnd;
    emit disconnect((int)condition);
}

bool ChatManager::chatRoomOpen() {
    return m_chatRoomOpen;
}

void ChatManager::setChatRoomOpen(bool chatRoomOpen) {
    m_chatRoomOpen = chatRoomOpen;
    emit chatRoomOpenChanged();
}

void ChatManager::sendIMTextMsg(const QString& text, const QString& flag) {
    if (m_chatController) {
        NEChatRoomMessage message;
        message.content = text.toStdString();
        message.messageExtension["sendflag"] = flag.toStdString();
        m_chatController->sendChatRoomMessage(message, [this](int code, const std::string& msg) { onRecvMsgCallback(200, msg); });
    }
}

void ChatManager::reloginChatroom() {
    YXLOG(Info) << "ChatManager::reloginChatroom." << YXLOGEnd;
    if (m_chatController) {
        m_chatController->reEnterChatRoom();
    }
}
