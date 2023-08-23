// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
#include "chat_manager.h"
#include <QDir>
#include <QFile>
#include <QObject>
#include "global_manager.h"
#include "meeting/members_manager.h"
#include "settings_manager.h"

ChatManager::ChatManager(QObject* parent)
    : QObject(parent) {
    qmlRegisterUncreatableType<MessageModelEnum>("NetEase.Meeting.MessageModelEnum", 1, 0, "MessageModelEnum", "");
}

ChatManager::~ChatManager() {
    {
        std::lock_guard<std::recursive_mutex> lock(m_sendListMutex);
        m_sendList.clear();
    }
}

void ChatManager::logoutChatroom() {
    auto chatController = MeetingManager::getInstance()->getInRoomChatController();
    if (chatController) {
        chatController->leaveChatroom();
    }
    m_bLogined = false;
}

void ChatManager::loginChatroom() {
    if (m_bLogined) {
        return;
    }

    if (m_chatRoomOpen) {
        auto chatController = MeetingManager::getInstance()->getInRoomChatController();
        if (chatController) {
            chatController->joinChatroom([this](int code, const std::string& msg) {
                if (code == 0) {
                    m_bLogined = true;
                } else {
                    m_bLogined = false;
                    if (!msg.empty()) {
                        QString strMsg = QString::fromStdString(msg);
                        if (msg == "joinChatroom failed") {
                            strMsg = tr("Chartoom Connection is disconnect!");
                        }
                        emit error(code, strMsg);
                    }
                }
            });
        }
        m_bLogined = true;
    }
}

// void ChatManager::onChatroomLogout(int error_code, int reason) {
//    Q_UNUSED(error_code);
//    Q_UNUSED(reason);
//}

void ChatManager::onRecvMsgCallback(const std::vector<SharedChatMessagePtr>& messages) {
    for (auto& message : messages) {
        YXLOG(Info) << "[ChatManager] Received new chatroom message, message ID: " << message->messageUuid()
                    << ", message type: " << message->messageType() << ", message from: " << message->fromUserUuid() << YXLOGEnd;
        if (message->messageType() == kNERoomMessageTypeText) {
            auto chatTextMsg = std::dynamic_pointer_cast<INERoomChatTextMessage>(message);
            if (chatTextMsg == nullptr) {
                continue;
            }

            ChatMessage message;
            message.sendFlag = false;
            message.messageType = MessageModelEnum::TEXT;
            message.messageUuid = QString::fromStdString(chatTextMsg->messageUuid());
            message.nickName = QString::fromStdString(chatTextMsg->fromNick());
            message.timestamp = QDateTime::currentDateTime().toMSecsSinceEpoch();
            message.text = QString::fromStdString(chatTextMsg->text());
            emit newMessageAdd(message);

            // 刷新消息提示
            emit msgTipSignal(message.nickName, message.text);
        } else if (message->messageType() == kNERoomMessageTypeFile) {
            if (!MeetingManager::getInstance()->enableFileMessage()) {
                continue;
            }

            auto fileMsg = std::dynamic_pointer_cast<INERoomChatFileMessage>(message);
            if (fileMsg == nullptr) {
                continue;
            }

            ChatMessage message;
            message.sendFlag = false;
            message.fileUrl = QString::fromStdString(fileMsg->url());
            message.messageType = MessageModelEnum::FILE;
            message.messageUuid = QString::fromStdString(fileMsg->messageUuid());
            message.nickName = QString::fromStdString(fileMsg->fromNick());
            message.fileStatus = MessageModelEnum::IDLE;
            message.timestamp = QDateTime::currentDateTime().toMSecsSinceEpoch();
            message.fileExt = QString::fromStdString(fileMsg->extension());
            message.fileName = QString::fromStdString(fileMsg->displayName());
            message.fileSize = fileMsg->size();
            emit newMessageAdd(message);

            // 刷新消息提示
            QString tip = "[" + tr("file") + "]";
            emit msgTipSignal(message.nickName, tip);
        } else if (message->messageType() == kNERoomMessageTypeImage) {
            if (!MeetingManager::getInstance()->enableImageMessage()) {
                continue;
            }

            auto imageMsg = std::dynamic_pointer_cast<INERoomChatImageMessage>(message);
            if (imageMsg == nullptr) {
                continue;
            }

            QFile file(QString::fromStdString(imageMsg->path()));
            QFileInfo info(file);
            if (!file.exists()) {
                return;
            }

            ChatMessage message;
            message.sendFlag = false;
            message.fileUrl = QString::fromStdString(imageMsg->url());
            message.messageType = MessageModelEnum::IMAGE;
            message.messageUuid = QString::fromStdString(imageMsg->messageUuid());
            message.nickName = QString::fromStdString(imageMsg->fromNick());
            message.fileStatus = MessageModelEnum::SUCCESS;
            message.imageWidth = imageMsg->width();
            message.imageHeight = imageMsg->height();
            message.filePath = QString::fromStdString(imageMsg->path());
            message.timestamp = QDateTime::currentDateTime().toMSecsSinceEpoch();
            message.fileName = QString::fromStdString(imageMsg->displayName());
            message.fileExt = QString::fromStdString(imageMsg->extension());
            emit newMessageAdd(message);

            // 刷新消息提示
            QString tip = "[" + tr("image") + "]";
            emit msgTipSignal(message.nickName, tip);
        }
    }
}

void ChatManager::onAttahmentProgressCallback(const std::string& messageUuid, int64_t transferred, int64_t total) {
    YXLOG(Info) << "onAttahmentProgressCallback messageUuid: " << messageUuid << ", transferred: " << transferred << ", total: " << total << YXLOGEnd;
    emit messageFileProgressChanged(QString::fromStdString(messageUuid), (double)transferred / total);
}

// void ChatManager::onRegLinkConditionCallback(const int condition) {
//    YXLOG(Info) << "ChatManager::OnRegLinkConditionCallback, linkCondition: " << condition << YXLOGEnd;
//    emit disconnect((int)condition);
//}

bool ChatManager::chatRoomOpen() {
    return m_chatRoomOpen;
}

void ChatManager::setChatRoomOpen(bool chatRoomOpen) {
    m_chatRoomOpen = chatRoomOpen;
    emit chatRoomOpenChanged();
}

void ChatManager::sendTextMsg(const QString& text) {
    auto chatController = MeetingManager::getInstance()->getInRoomChatController();
    if (chatController) {
        std::list<std::string> userUuids;
        QString messageUuid = QUuid::createUuid().toString();
        chatController->sendTextMessage(
            messageUuid.toStdString(), text.toStdString(), userUuids, [this, text, messageUuid](int code, const std::string& msg) {
                if (code == 0) {
                    ChatMessage message;
                    message.sendFlag = true;
                    message.messageType = MessageModelEnum::TEXT;
                    message.messageUuid = messageUuid;
                    message.nickName = QString::fromStdString(MeetingManager::getInstance()->getMeetingInfo().displayName);
                    message.timestamp = QDateTime::currentDateTime().toMSecsSinceEpoch();
                    message.text = text;
                    emit newMessageAdd(message);
                    emit msgSendSignal();
                } else {
                    emit error(-1, tr("send message fail"));
                }
            });
    }
}

void ChatManager::sendFileMsg(int type, const QString& path) {
    QFile file(path);
    if (!file.exists()) {
        emit error(-1, tr("file not exist"));
        return;
    }
    qint64 fileSize = file.size();

    qInfo() << "sendFileMsg size: " << fileSize;
    if (type == MessageModelEnum::FILE) {
        if (fileSize >= 200 * 1024 * 1024) {
            emit error(-1, tr("File size cannot exceed 200mb"));
            return;
        }
    } else if (type == MessageModelEnum::IMAGE) {
        if (fileSize >= 20 * 1024 * 1024) {
            emit error(-1, tr("Image size cannot exceed 20mb"));
            return;
        }
    } else {
        return;
    }

    auto chatController = MeetingManager::getInstance()->getInRoomChatController();
    if (chatController) {
        std::list<std::string> userUuids;
        QString messageUuid = QUuid::createUuid().toString();

        ChatMessage message;
        message.sendFlag = true;
        message.messageType = (MessageModelEnum::ChatMessageType)type;
        message.messageUuid = messageUuid;
        message.nickName = QString::fromStdString(MeetingManager::getInstance()->getMeetingInfo().displayName);
        message.filePath = path;
        QFileInfo fileInfo(path);
        message.fileDir = fileInfo.path();
        message.fileStatus = MessageModelEnum::START;
        message.fileSize = fileInfo.size();
        message.fileExt = fileInfo.suffix().toLower();
        message.fileName = fileInfo.fileName();
        message.timestamp = QDateTime::currentDateTime().toMSecsSinceEpoch();

        if (type == MessageModelEnum::FILE) {
            chatController->sendFileMessage(messageUuid.toStdString(), path.toStdString(), userUuids, [=](int code, const std::string& msg) {
                if (code == 0) {
                    emit messageFileStatusChanged(messageUuid, MessageModelEnum::SUCCESS);
                } else {
                    emit messageFileStatusChanged(messageUuid, MessageModelEnum::FAILED);
                }
            });
        } else if (type == MessageModelEnum::IMAGE) {
            QImage image;
            image.load(path);
            message.imageWidth = image.width();
            message.imageHeight = image.height();
            chatController->sendImageMessage(messageUuid.toStdString(), path.toStdString(), message.imageWidth, message.imageHeight, userUuids,
                                             [=](int code, const std::string& msg) {
                                                 if (code == 0) {
                                                     emit messageFileStatusChanged(messageUuid, MessageModelEnum::SUCCESS);
                                                 } else {
                                                     emit messageFileStatusChanged(messageUuid, MessageModelEnum::FAILED);
                                                 }
                                             });
        } else {
            return;
        }

        emit newMessageAdd(message);
        emit msgSendSignal();
    }
}

void ChatManager::resendFileMsg(int type, const QString& path, const QString& oldMessageUuid) {
    QFile file(path);
    qint64 fileSize = file.size();

    if (type == 2) {
        if (fileSize >= 200 * 1024 * 1024) {
            emit error(-1, tr("File size cannot exceed 200mb"));
            return;
        }
    } else if (type == 3) {
        if (fileSize >= 20 * 1024 * 1024) {
            emit error(-1, tr("Image size cannot exceed 20mb"));
            return;
        }
    } else {
        return;
    }

    auto chatController = MeetingManager::getInstance()->getInRoomChatController();
    if (chatController) {
        std::list<std::string> userUuids;
        QString messageUuid = QUuid::createUuid().toString();

        ChatMessage message;
        message.sendFlag = true;
        message.messageType = (MessageModelEnum::ChatMessageType)type;
        message.messageUuid = messageUuid;
        message.nickName = QString::fromStdString(MeetingManager::getInstance()->getMeetingInfo().displayName);
        message.filePath = path;
        QFileInfo fileInfo(path);
        message.fileDir = fileInfo.path();
        message.fileStatus = MessageModelEnum::START;
        message.fileSize = fileInfo.size();
        message.fileExt = fileInfo.suffix().toLower();
        message.fileName = fileInfo.fileName();
        message.timestamp = QDateTime::currentDateTime().toMSecsSinceEpoch();

        if (type == MessageModelEnum::FILE) {
            chatController->sendFileMessage(messageUuid.toStdString(), path.toStdString(), userUuids, [=](int code, const std::string& msg) {
                if (code == 0) {
                    emit messageFileStatusChanged(messageUuid, MessageModelEnum::SUCCESS);
                } else {
                    emit messageFileStatusChanged(messageUuid, MessageModelEnum::FAILED);
                }
            });
        } else if (type == MessageModelEnum::IMAGE) {
            QImage image;
            image.load(path);
            message.imageWidth = image.width();
            message.imageHeight = image.height();
            chatController->sendImageMessage(messageUuid.toStdString(), path.toStdString(), message.imageWidth, message.imageHeight, userUuids,
                                             [=](int code, const std::string& msg) {
                                                 if (code == 0) {
                                                     emit messageFileStatusChanged(messageUuid, MessageModelEnum::SUCCESS);
                                                 } else {
                                                     emit messageFileStatusChanged(messageUuid, MessageModelEnum::FAILED);
                                                 }
                                             });
        } else {
            return;
        }

        emit messageResend(oldMessageUuid, message);
    }
}

void ChatManager::stopFileMsg(const QString& messageUuid) {
    auto chatController = MeetingManager::getInstance()->getInRoomChatController();
    if (chatController) {
        chatController->cancelSendFileMessage(messageUuid.toStdString(), [=](int code, const std::string& msg) {
            emit messageFileStatusChanged(messageUuid, MessageModelEnum::FAILED);
        });
    }
}

void ChatManager::stopDownloadFile(const QString& messageUuid) {
    auto chatController = MeetingManager::getInstance()->getInRoomChatController();
    if (chatController) {
        chatController->cancelDownloadAttachment(messageUuid.toStdString(), [=](int code, const std::string& msg) {
            emit messageFilePathChanged(messageUuid, "");
            emit messageFileStatusChanged(messageUuid, MessageModelEnum::IDLE);
        });
    }
}

void ChatManager::reloginChatroom() {
    //    YXLOG(Info) << "ChatManager::reloginChatroom." << YXLOGEnd;
    //    if (m_chatController) {
    //        m_chatController->reEnterChatRoom();
    //    }
}

void ChatManager::saveFile(const QString& messageUuid, const QString& url, const QString& name, const QString& newPath) {
    QString path = "";
    if (newPath.isEmpty()) {
        path = SettingsManager::getInstance()->cacheDir() + "/" + AuthManager::getInstance()->authAccountId() + "/file/" + name;
    } else {
        path = newPath;
    }

    auto chatController = MeetingManager::getInstance()->getInRoomChatController();
    if (chatController) {
        chatController->downloadAttachment(messageUuid.toStdString(), url.toStdString(), path.toStdString(), [=](int code, const std::string& msg) {
            if (code == 0) {
                emit messageFileStatusChanged(messageUuid, MessageModelEnum::SUCCESS);
                emit messageFilePathChanged(messageUuid, path);
            } else {
                emit messageFileStatusChanged(messageUuid, MessageModelEnum::FAILED);
            }
        });
        emit messageFileStatusChanged(messageUuid, MessageModelEnum::START);
    }
}

void ChatManager::saveFileAs(const QString& messageUuid, const QString& url, const QString& path) {
    auto chatController = MeetingManager::getInstance()->getInRoomChatController();
    if (chatController) {
        chatController->downloadAttachment(messageUuid.toStdString(), url.toStdString(), path.toStdString(), [=](int code, const std::string& msg) {
            if (code == 0) {
                emit messageFileStatusChanged(messageUuid, MessageModelEnum::SUCCESS);
            } else {
                emit messageFileStatusChanged(messageUuid, MessageModelEnum::FAILED);
            }
        });
        emit messageFilePathChanged(messageUuid, path);
        emit messageFileStatusChanged(messageUuid, MessageModelEnum::START);
    }
}

void ChatManager::saveImageAs(const QString& messageUuid, const QString& oldPath, const QString& newPath) {
    std::thread thread([=]() {
        bool ret = QFile::copy(oldPath, newPath);
        if (ret) {
            // 另存为不更新path
            //  emit messageFilePathChanged(messageUuid, newPath);
        }
    });

    thread.detach();
}

bool ChatManager::isFileExists(const QString& path) {
    return QFile::exists(path);
}

bool ChatManager::isDirExists(const QString& path) {
    QDir dir(path);
    return dir.exists();
}

void ChatManager::updateFileStatus(const QString& messageUuid, int status) {
    emit messageFileStatusChanged(messageUuid, status);
}

void ChatManager::showFileInFolder(const QString& path) {
#ifdef Q_OS_WIN32
    QProcess::startDetached("explorer.exe", {"/select,", QDir::toNativeSeparators(path)});
#elif defined(Q_OS_MACX)
    QProcess::startDetached("/usr/bin/osascript", {"-e", "tell application \"Finder\" to reveal POSIX file \"" + path + "\""});
    QProcess::startDetached("/usr/bin/osascript", {"-e", "tell application \"Finder\" to activate"});
#endif
}

void ChatManager::sendMsg(int type, const QString& fileName) {
    bool running = false;
    {
        std::lock_guard<std::recursive_mutex> lock(m_sendListMutex);
        ChatMessage msg;
        msg.messageType = (MessageModelEnum::ChatMessageType)type;
        msg.text = fileName;

        running = !m_sendList.empty();
        m_sendList.emplace_back(msg);
    }

    if (!running) {
        auto task = [this]() {
            bool sendText = false;
            while (!m_sendList.empty()) {
                if (MessageModelEnum::TEXT == m_sendList.front().messageType) {
                    sendTextMsg(m_sendList.front().text);
                    sendText = true;
                } else if (MessageModelEnum::IMAGE == m_sendList.front().messageType) {
                    if (sendText) {
                        std::this_thread::sleep_for(std::chrono::milliseconds(300));
                    }
                    sendFileMsg(3, m_sendList.front().text);
                    sendText = false;
                }
                {
                    std::lock_guard<std::recursive_mutex> lock(m_sendListMutex);
                    m_sendList.erase(m_sendList.begin());
                }
            }
        };

        std::thread(task).detach();
    }
}
