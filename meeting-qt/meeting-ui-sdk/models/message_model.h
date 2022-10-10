// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MESSAGEMODEL_H
#define MESSAGEMODEL_H

#include <QAbstractListModel>

class MessageModelEnum : public QObject {
    Q_GADGET
public:
    explicit MessageModelEnum() {}
    enum ChatMessageType { UNKNOWN, TEXT, FILE, IMAGE, TIME };
    Q_ENUM(ChatMessageType)

    enum ChatFileStatusType { IDLE, START, SUCCESS, FAILED };
    Q_ENUM(ChatFileStatusType)
};

typedef struct tagChatMessage {
    QString messageUuid;
    MessageModelEnum::ChatMessageType messageType = MessageModelEnum::UNKNOWN;
    MessageModelEnum::ChatFileStatusType fileStatus = MessageModelEnum::IDLE;
    QString nickName;
    bool sendFlag = true;  // true: 发送 false：接收
    qint64 timestamp;
    QString text;
    QString fileUrl;
    QString filePath;
    QString fileDir;
    QString fileExt;
    QString fileName;
    qint64 fileSize;
    int imageWidth = 0;
    int imageHeight = 0;
    int index = 0;
    double progress = 0.0;
} ChatMessage;
Q_DECLARE_METATYPE(ChatMessage)

class MessageModel : public QAbstractListModel {
    Q_OBJECT

public:
    explicit MessageModel(QObject* parent = nullptr);

    enum {
        kMessageUuid = Qt::UserRole,
        kMessageType,
        kMessageNickName,
        kMessageFlag,
        kMessageTime,
        kMessageText,
        kMessageFileStatus,
        kMessageFileUrl,
        kMessageFileDir,
        kMessageFileExt,
        kMessageFileName,
        kMessageFilePath,
        kMessageFileSize,
        kMessageImageWidth,
        kMessageImageHeight,
        kMessageFileProgress
    };

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void clearMessage();

public:
    void appendMessage(const ChatMessage& message);
    void repaceMessage(const QString& oldMessageUuid, const ChatMessage& message);
    void updateFileStatus(const QString& messageUuid, int status);
    void updateFileProgress(const QString& messageUuid, double progress);
    void updateFilePath(const QString& messageUuid, const QString& path);

private:
    void addTimeTipMessage(qint64 timestamp);

private:
    QMap<QString, ChatMessage> m_messageList;
    QVector<QString> m_messageUuids;
    qint64 m_lastMsgTimeStamp = -1;
};

#endif  // MESSAGEMODEL_H
