/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef CHATMANAGER_H
#define CHATMANAGER_H

#include "controller/chat_ctrl_interface.h"
#include "room_service_interface.h"
#include "utils/singleton.h"

using namespace neroom;

class ChatManager : public QObject, public INERoomChatListener {
    Q_OBJECT
private:
    ChatManager(QObject* parent = nullptr);
    ~ChatManager();

public:
    SINGLETONG(ChatManager)

    Q_PROPERTY(bool chatRoomOpen READ chatRoomOpen WRITE setChatRoomOpen NOTIFY chatRoomOpenChanged)
    Q_INVOKABLE void logoutChatroom();
    Q_INVOKABLE void loginChatroom();
    Q_INVOKABLE void sendIMTextMsg(const QString& text, const QString& flag);
    Q_INVOKABLE void reloginChatroom();
    bool initialize();
    void release();

    virtual void onChatroomLogout(int error_code, int reason) override;
    virtual void onRecvMsgCallback(int status, const std::string& jsonMsg) override;
    virtual void onRegLinkConditionCallback(const int condition) override;

    bool chatRoomOpen();
    void setChatRoomOpen(bool chatRoomOpen);

signals:
    void chatRoomOpenChanged();
    void recvMsgSiganl(int status, const QJsonObject& msg);
    void error(int error_code, const QString& text);
    void disconnect(int code);

private:
    INERoomService* m_meetingSvr = nullptr;
    INERoomChatController* m_chatController;
    bool m_chatRoomOpen = false;
    std::atomic_bool m_bLogined;
};

#endif  // CHATMANAGER_H
