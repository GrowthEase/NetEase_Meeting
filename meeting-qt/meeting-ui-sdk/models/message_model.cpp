// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "message_model.h"
#include "manager/chat_manager.h"

MessageModel::MessageModel(QObject* parent)
    : QAbstractListModel(parent) {
    qRegisterMetaType<ChatMessage>();
    connect(ChatManager::getInstance(), &ChatManager::newMessageAdd, this, &MessageModel::appendMessage);
    connect(ChatManager::getInstance(), &ChatManager::messageFileStatusChanged, this, &MessageModel::updateFileStatus);
    connect(ChatManager::getInstance(), &ChatManager::messageFileProgressChanged, this, &MessageModel::updateFileProgress);
    connect(ChatManager::getInstance(), &ChatManager::messageFilePathChanged, this, &MessageModel::updateFilePath);
    connect(ChatManager::getInstance(), &ChatManager::messageResend, this, &MessageModel::repaceMessage);
}

int MessageModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid())
        return 0;

    return m_messageUuids.count();
}

QVariant MessageModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid())

        if ((index.row() + 1) > m_messageUuids.size())
            return QVariant();

    auto messageId = m_messageUuids.at(index.row());
    auto message = m_messageList[messageId];

    switch (role) {
        case kMessageUuid:
            return QVariant(message.messageUuid);
        case kMessageType:
            return QVariant(message.messageType);
        case kMessageNickName:
            return QVariant(message.nickName);
        case kMessageFlag:
            return QVariant(message.sendFlag);
        case kMessageTime:
            return QVariant(message.timestamp);
        case kMessageText:
            return QVariant(message.text);
        case kMessageFileStatus:
            return QVariant(message.fileStatus);
        case kMessageFileUrl:
            return QVariant(message.fileUrl);
        case kMessageFilePath:
            return QVariant(message.filePath);
        case kMessageFileDir:
            return QVariant(message.fileDir);
        case kMessageFileExt:
            return QVariant(message.fileExt);
        case kMessageFileName:
            return QVariant(message.fileName);
        case kMessageFileSize:
            return QVariant(message.fileSize);
        case kMessageImageWidth:
            return QVariant(message.imageWidth);
        case kMessageImageHeight:
            return QVariant(message.imageHeight);
        case kMessageFileProgress:
            return QVariant(message.progress);
    }

    return QVariant();
}

QHash<int, QByteArray> MessageModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[kMessageUuid] = "uuid";
    names[kMessageType] = "type";
    names[kMessageNickName] = "nickname";
    names[kMessageFlag] = "sendFlag";
    names[kMessageTime] = "time";
    names[kMessageText] = "text";
    names[kMessageFileStatus] = "fileStatus";
    names[kMessageFileUrl] = "fileUrl";
    names[kMessageFilePath] = "filePath";
    names[kMessageFileDir] = "fileDir";
    names[kMessageFileExt] = "fileExt";
    names[kMessageFileName] = "fileName";
    names[kMessageFileSize] = "fileSize";
    names[kMessageImageWidth] = "imageWidth";
    names[kMessageImageHeight] = "imageHeight";
    names[kMessageFileProgress] = "progress";
    return names;
}

void MessageModel::clearMessage() {
    beginResetModel();
    m_messageList.clear();
    m_messageUuids.clear();
    endResetModel();
    m_lastMsgTimeStamp = -1;
}

void MessageModel::appendMessage(const ChatMessage& message) {
    addTimeTipMessage(message.timestamp);

    int index = m_messageUuids.size();
    beginInsertRows(QModelIndex(), index, index);
    auto newMessage = message;
    newMessage.index = index;
    m_messageUuids << message.messageUuid;
    m_messageList[message.messageUuid] = newMessage;
    endInsertRows();
}

void MessageModel::repaceMessage(const QString& oldMessageUuid, const ChatMessage& message) {
    qInfo() << "repaceMessage oldMessageUuid " << oldMessageUuid << ", new MessageUuid: " << message.messageUuid;
    bool found = false;
    int index = 0;
    for (index = 0; index < m_messageUuids.count(); index++) {
        if (m_messageUuids[index] == oldMessageUuid) {
            m_messageUuids.replace(index, message.messageUuid);
            found = true;
            break;
        }
    }

    if (found) {
        auto newMessage = message;
        newMessage.index = index;
        m_messageList[message.messageUuid] = newMessage;
        QModelIndex modelIndex = createIndex(index, 0);
        emit dataChanged(modelIndex, modelIndex);
    } else {
        appendMessage(message);
    }
}

void MessageModel::updateFileStatus(const QString& messageUuid, int status) {
    auto& message = m_messageList[messageUuid];
    message.fileStatus = (MessageModelEnum::ChatFileStatusType)status;
    QModelIndex modelIndex = createIndex(message.index, 0);
    QVector<int> roles = {kMessageFileStatus};
    Q_EMIT dataChanged(modelIndex, modelIndex, roles);
}

void MessageModel::updateFileProgress(const QString& messageUuid, double progress) {
    auto& message = m_messageList[messageUuid];
    message.progress = progress;
    QModelIndex modelIndex = createIndex(message.index, 0);
    QVector<int> roles = {kMessageFileProgress};
    Q_EMIT dataChanged(modelIndex, modelIndex, roles);
}

void MessageModel::updateFilePath(const QString& messageUuid, const QString& path) {
    auto& message = m_messageList[messageUuid];
    QFileInfo fileInfo(path);
    message.fileDir = fileInfo.path();
    message.filePath = path;
    QModelIndex modelIndex = createIndex(message.index, 0);
    QVector<int> roles = {kMessageFileDir, kMessageFilePath};
    Q_EMIT dataChanged(modelIndex, modelIndex, roles);
}

void MessageModel::addTimeTipMessage(qint64 timestamp) {
    if (m_lastMsgTimeStamp < 0) {
        m_lastMsgTimeStamp = timestamp;
        return;
    }

    qint64 gap = timestamp - m_lastMsgTimeStamp;

    // 消息间隔超过5分钟，插入一条时间消息
    if (gap / 1000 >= 300 && m_messageUuids.count() >= 1) {
        ChatMessage message;
        message.messageUuid = QUuid::createUuid().toString();
        message.index = m_messageUuids.count();
        message.text = QDateTime::fromMSecsSinceEpoch(timestamp).toString("hh:mm");
        message.messageType = MessageModelEnum::TIME;
        beginInsertRows(QModelIndex(), message.index, message.index);
        m_messageUuids << message.messageUuid;
        m_messageList[message.messageUuid] = message;
        endInsertRows();
    }

    m_lastMsgTimeStamp = timestamp;
}
