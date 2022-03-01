/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include <QDebug>

#include "live_manager.h"
#include "manager/meeting_manager.h"

LiveManager::LiveManager(QObject* parent)
    : QObject(parent) {
    m_liveStreamController = MeetingManager::getInstance()->getLivingController();
}

LiveManager::~LiveManager() {}

void LiveManager::onLiveStreamStatusChanged(int liveState) {
    if (liveState == 1 || liveState == 3) {
        liveStateChanged(false, false);
    } else {
        liveStateChanged(true, false);
    }
}

void LiveManager::initLiveStreamStatus(int liveState) {
    if (liveState == 1 || liveState == 3) {
        liveStateChanged(false, true);
    } else {
        liveStateChanged(true, true);
    }
}

QString LiveManager::getLiveUrl() {
    if (MeetingManager::getInstance()->getMeetingInfo() == nullptr) {
        return "";
    }

    return QString::fromStdString(MeetingManager::getInstance()->getMeetingInfo()->getLiveStreamInfo().liveUrl);
}

QString LiveManager::getLiveTittle() {
    if (MeetingManager::getInstance()->getMeetingInfo() == nullptr) {
        return "";
    }

    QString title = QString::fromStdString(MeetingManager::getInstance()->getMeetingInfo()->getLiveStreamInfo().title);

    if (title.isEmpty()) {
        title = QString::fromStdString(MeetingManager::getInstance()->getMeetingInfo()->getSubject());
    }

    return title;
}

QString LiveManager::getLivePassword() {
    if (MeetingManager::getInstance()->getMeetingInfo() == nullptr) {
        return "";
    }
    return QString::fromStdString(MeetingManager::getInstance()->getMeetingInfo()->getLiveStreamInfo().password);
}

bool LiveManager::getLiveChatRoomEnable() {
    if (MeetingManager::getInstance()->getMeetingInfo() == nullptr) {
        return false;
    }

    return MeetingManager::getInstance()->getMeetingInfo()->getLiveStreamInfo().liveChatRoomEnable;
}
bool LiveManager::getLiveAccessEnable() {
    if (MeetingManager::getInstance()->getMeetingInfo() == nullptr) {
        return false;
    }

    return MeetingManager::getInstance()->getMeetingInfo()->getLiveStreamInfo().liveWebAccessControlLevel == kNERoomLiveAccessAppToken;
}

int LiveManager::getLiveLayout() {
    auto meetingInfo = MeetingManager::getInstance()->getMeetingInfo();
    if (meetingInfo) {
        return meetingInfo->getLiveStreamInfo().liveLayout;
    }
    return 1;
}

int LiveManager::getLiveUserCount() {
    return m_liveParam.userList.size();
}

QJsonArray LiveManager::getLiveUsersList() {
    QJsonArray array;
    auto meetingInfo = MeetingManager::getInstance()->getMeetingInfo();
    if (Q_NULLPTR == meetingInfo) {
        return array;
    }

    std::vector<std::string> vecUsers = MeetingManager::getInstance()->getMeetingInfo()->getLiveStreamInfo().userList;
    for (auto user : vecUsers) {
        QJsonValue value = QString::fromStdString(user);
        array << value;
    }

    return array;
}

bool LiveManager::startLive(QJsonObject liveParams) {
    qInfo() << "liveParams: " << liveParams;
    m_liveParam.userList.clear();

    QJsonArray userArray = liveParams["liveUsers"].toArray();
    for (int i = 0; i < userArray.size(); i++) {
        QJsonObject obj = userArray[i].toObject();
        std::string uid = obj["accountId"].toVariant().toString().toStdString();
        m_liveParam.userList.push_back(uid);
    }

    int layoutMode = liveParams["layoutType"].toInt();

    m_liveParam.title = liveParams["liveTitle"].toString().toStdString();
    m_liveParam.liveChatRoomEnable = liveParams["liveChatRoomEnable"].toBool();
    m_liveParam.password = liveParams["password"].toString().toStdString();
    m_liveParam.liveLayout = (NELiveLayout)layoutMode;
    m_liveParam.liveWebAccessControlLevel = liveParams["liveAccessEnable"].toBool() ? kNERoomLiveAccessAppToken : kNERoomLiveAccessToken;

    m_liveStreamController->startLiveStream(m_liveParam, [this](bool success, uint32_t errorCode, const std::string& errorMessage) {
        emit liveStartFinished(success, QString::fromStdString(errorMessage));

        if (success) {
            emit liveStateChanged(true, false);
        }
    });

    return true;
}

bool LiveManager::updateLive(QJsonObject liveParams) {
    m_liveParam.userList.clear();
    QJsonArray userArray = liveParams["liveUsers"].toArray();
    for (int i = 0; i < userArray.size(); i++) {
        QJsonObject obj = userArray[i].toObject();
        std::string uid = obj["accountId"].toVariant().toString().toStdString();
        m_liveParam.userList.push_back(uid);
    }

    int layoutMode = liveParams["layoutType"].toInt();

    m_liveParam.liveChatRoomEnable = liveParams["liveChatRoomEnable"].toBool();
    m_liveParam.liveLayout = (NELiveLayout)layoutMode;

    m_liveStreamController->updateLiveStream(m_liveParam, [this](bool success, uint32_t errorCode, const std::string& errorMessage) {
        emit liveUpdateFinished(success, QString::fromStdString(errorMessage));
    });

    return true;
}

bool LiveManager::stopLive() {
    m_liveStreamController->stopLiveStream([this](bool success, uint32_t errorCode, const std::string& errorMessage) {
        emit liveStopFinished(success, QString::fromStdString(errorMessage));

        if (success) {
            emit liveStateChanged(false, false);
        }
    });

    return true;
}
