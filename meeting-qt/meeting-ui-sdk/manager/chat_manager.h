// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef CHATMANAGER_H
#define CHATMANAGER_H

#include "controller/chat_ctrl_interface.h"
#include "models/message_model.h"
#include "room_service_interface.h"
#include "utils/singleton.h"

using namespace neroom;

class ChatManager : public QObject {
    Q_OBJECT
private:
    ChatManager(QObject* parent = nullptr);
    ~ChatManager();

public:
    SINGLETONG(ChatManager)

    Q_PROPERTY(bool chatRoomOpen READ chatRoomOpen WRITE setChatRoomOpen NOTIFY chatRoomOpenChanged)
    Q_INVOKABLE void logoutChatroom();
    Q_INVOKABLE void loginChatroom();
    Q_INVOKABLE void sendTextMsg(const QString& text);
    Q_INVOKABLE void sendFileMsg(int type, const QString& path);
    Q_INVOKABLE void resendFileMsg(int type, const QString& path, const QString& oldMessageUuid);
    Q_INVOKABLE void stopFileMsg(const QString& messageUuid);
    Q_INVOKABLE void stopDownloadFile(const QString& messageUuid);
    Q_INVOKABLE void reloginChatroom();

    Q_INVOKABLE void saveFile(const QString& messageUuid, const QString& url, const QString& name, const QString& newPath = "");
    Q_INVOKABLE void saveFileAs(const QString& messageUuid, const QString& url, const QString& path);
    Q_INVOKABLE void saveImageAs(const QString& messageUuid, const QString& oldPath, const QString& newPath);

    Q_INVOKABLE bool isFileExists(const QString& path);
    Q_INVOKABLE bool isDirExists(const QString& path);

    Q_INVOKABLE void updateFileStatus(const QString& messageUuid, int status);
    Q_INVOKABLE void showFileInFolder(const QString& path);

    void initialize(){};
    void release(){};

    //    virtual void onChatroomLogout(int error_code, int reason) override;
    void onRecvMsgCallback(const std::vector<SharedChatMessagePtr>& messages);
    void onAttahmentProgressCallback(const std::string& messageUuid, int64_t transferred, int64_t total);
    //    virtual void onRegLinkConditionCallback(const int condition) override;

    bool chatRoomOpen();
    void setChatRoomOpen(bool chatRoomOpen);

signals:
    void chatRoomOpenChanged();
    // void recvMsgSiganl(int status, const QJsonObject& msg);
    void msgTipSignal(const QString& nickname, const QString& tip);
    void msgSendSignal();
    void error(int error_code, const QString& text);
    void disconnect(int code);

    void newMessageAdd(const ChatMessage& message);
    void messageResend(const QString& oldMessageUUid, const ChatMessage& message);
    void messageFileStatusChanged(const QString& messageUuid, int status);
    void messageFileProgressChanged(const QString& messageUuid, double progress);
    void messageFilePathChanged(const QString& messageUuid, const QString& path);

private:
    INERoomService* m_meetingSvr = nullptr;
    INERoomChatController* m_chatController;
    bool m_chatRoomOpen = false;
    std::atomic_bool m_bLogined{false};
};

#endif  // CHATMANAGER_H
