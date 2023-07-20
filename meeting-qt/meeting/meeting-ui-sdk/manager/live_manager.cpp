// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include <QDebug>

#include "controller/live_ctrl_interface.h"
#include "live_manager.h"
#include "manager/meeting_manager.h"
#include "utils/invoker.h"

LiveManager::LiveManager(QObject* parent)
    : QObject(parent) {}

LiveManager::~LiveManager() {}

void LiveManager::onLiveStreamStatusChanged(int liveState) {
    Invoker::getInstance()->execute([=]() {
        initLiveInfo();
        emit liveStateChanged(liveState);
    });
}

void LiveManager::initLiveStreamStatus() {
    if (initLiveInfo()) {
        emit liveStateChanged(m_liveInfo.state);
    } else {
        liveStateChanged(1);
    }
}

QString LiveManager::getLiveUrl() {
    return QString::fromStdString(MeetingManager::getInstance()->getMeetingInfo().liveUrl);
}

QString LiveManager::getLiveTittle() {
    return m_liveInfo.title.empty() ? QString::fromStdString(MeetingManager::getInstance()->getMeetingInfo().subject)
                                    : QString::fromStdString(m_liveInfo.title);
}

QString LiveManager::getLivePassword() {
    return QString::fromStdString(m_liveInfo.password);
}

bool LiveManager::getLiveChatRoomEnable() {
    return m_liveChatRoomEnable;
}

bool LiveManager::getLiveAccessEnable() {
    return m_onlyEmployeesAllow;
}

int LiveManager::getLiveLayout() {
    return m_liveInfo.liveLayout;
}

int LiveManager::getLiveUserCount() {
    return m_liveInfo.userUuidList.size();
}

QJsonArray LiveManager::getLiveUsersList() {
    QJsonArray array;
    std::vector<std::string> vecUsers = m_liveInfo.userUuidList;
    for (auto user : vecUsers) {
        QJsonValue value = QString::fromStdString(user);
        array << value;
    }

    return array;
}

bool LiveManager::startLive(QJsonObject liveParams) {
    qInfo() << "liveParams: " << liveParams;

    NERoomLiveRequest live;
    live.title = liveParams["liveTitle"].toString().toStdString();
    live.password = liveParams["password"].toString().toStdString();
    live.liveLayout = (NERoomLiveLayout)liveParams["layoutType"].toInt();

    QJsonArray extensionUserArray;
    QJsonArray userArray = liveParams["liveUsers"].toArray();
    for (int i = 0; i < userArray.size(); i++) {
        QJsonObject obj = userArray[i].toObject();
        QString uid = obj["accountId"].toVariant().toString();
        live.userUuidList.push_back(uid.toStdString());
        extensionUserArray << uid;
    }

    QJsonObject extentionConfig;
    extentionConfig["onlyEmployeesAllow"] = liveParams["liveAccessEnable"].toBool();
    extentionConfig["liveChatRoomEnable"] = liveParams["liveChatRoomEnable"].toBool();
    extentionConfig["listUids"] = extensionUserArray;
    QByteArray byteArray = QJsonDocument(extentionConfig).toJson(QJsonDocument::Compact);
    live.extentionConfig = byteArray.data();

    auto liveController = MeetingManager::getInstance()->getLiveController();
    if (liveController) {
        liveController->startLive(live, [this](int code, const std::string& msg) {
            YXLOG(Info) << "startLive code: " << code << YXLOGEnd;
            YXLOG(Info) << "startLive msg: " << msg << YXLOGEnd;

            QString qstrErrorMessage = QString::fromStdString(msg);
            if (msg == "kFailed_connect_server") {
                qstrErrorMessage = tr("Failed to connect to server, please try agine.");
            }

            emit liveStartFinished(code == 0, qstrErrorMessage);
        });
    }

    return true;
}

bool LiveManager::updateLive(QJsonObject liveParams) {
    NERoomLiveRequest live;
    live.title = m_liveInfo.title;
    live.password = m_liveInfo.password;
    live.liveLayout = (NERoomLiveLayout)liveParams["layoutType"].toInt();

    QJsonArray extensionUserArray;
    QJsonArray userArray = liveParams["liveUsers"].toArray();
    for (int i = 0; i < userArray.size(); i++) {
        QJsonObject obj = userArray[i].toObject();
        QString uid = obj["accountId"].toVariant().toString();
        live.userUuidList.push_back(uid.toStdString());
        extensionUserArray << uid;
    }

    QJsonObject extentionConfig;
    extentionConfig["onlyEmployeesAllow"] = m_onlyEmployeesAllow;
    extentionConfig["liveChatRoomEnable"] = liveParams["liveChatRoomEnable"].toBool();
    extentionConfig["listUids"] = extensionUserArray;
    QByteArray byteArray = QJsonDocument(extentionConfig).toJson(QJsonDocument::Compact);
    live.extentionConfig = byteArray.data();

    auto liveController = MeetingManager::getInstance()->getLiveController();
    if (liveController) {
        liveController->updateLive(live, [this](int code, const std::string& msg) {
            YXLOG(Info) << "updateLive code: " << code << YXLOGEnd;
            YXLOG(Info) << "updateLive msg: " << msg << YXLOGEnd;

            QString qstrErrorMessage = QString::fromStdString(msg);
            if (msg == "kFailed_connect_server") {
                qstrErrorMessage = tr("Failed to connect to server, please try agine.");
            }
            emit liveUpdateFinished(code == 0, qstrErrorMessage);
        });
    }

    return true;
}

bool LiveManager::stopLive() {
    auto liveController = MeetingManager::getInstance()->getLiveController();
    if (liveController) {
        liveController->stopLive([this](int code, const std::string& msg) {
            YXLOG(Info) << "stopLive code: " << code << YXLOGEnd;
            YXLOG(Info) << "stopLive msg: " << msg << YXLOGEnd;

            QString qstrErrorMessage = QString::fromStdString(msg);
            if (msg == "kFailed_connect_server") {
                qstrErrorMessage = tr("Failed to connect to server, please try agine.");
            }

            emit liveStopFinished(code == 0, qstrErrorMessage);
        });
    }

    return true;
}

bool LiveManager::initLiveInfo() {
    auto liveController = MeetingManager::getInstance()->getLiveController();
    if (liveController) {
        m_liveInfo = liveController->getLiveInfo();

        QJsonParseError err;
        QJsonDocument doc = QJsonDocument::fromJson(QString::fromStdString(m_liveInfo.extentionConfig).toUtf8(), &err);
        if (err.error != QJsonParseError::NoError)
            return false;

        auto extentionConfig = doc.object();
        if (extentionConfig.contains("onlyEmployeesAllow")) {
            m_onlyEmployeesAllow = extentionConfig["onlyEmployeesAllow"].toBool();
        }
        if (extentionConfig.contains("liveChatRoomEnable")) {
            m_liveChatRoomEnable = extentionConfig["liveChatRoomEnable"].toBool();
        }
        if (m_liveInfo.state == kNERoomLiveStateStarted) {
            if (extentionConfig.contains("listUids")) {
                m_liveInfo.userUuidList.clear();
                auto array = extentionConfig["listUids"].toArray();
                for (auto item : array) {
                    m_liveInfo.userUuidList.push_back(item.toString().toStdString());
                }
            }
        }

        return true;
    }

    return false;
}
