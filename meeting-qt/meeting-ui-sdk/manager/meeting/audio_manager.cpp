/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "audio_manager.h"
#include "share_manager.h"
#include "video_manager.h"

AudioManager::AudioManager(QObject* parent)
    : QObject(parent) {
    qRegisterMetaType<NEMeeting::HandsUpStatus>();
    m_audioController = MeetingManager::getInstance()->getInRoomAudioController();
}

void AudioManager::onUserAudioStatusChanged(const std::string& accountId, NEMeeting::DeviceStatus deviceStatus) {
    QMetaObject::invokeMethod(this, "onUserAudioStatusChangedUI", Qt::AutoConnection, Q_ARG(QString, QString::fromStdString(accountId)),
                              Q_ARG(NEMeeting::DeviceStatus, deviceStatus));
}

void AudioManager::onActiveSpeakerChanged(const std::string& accountId, const std::string& nickname) {
    QMetaObject::invokeMethod(this, "onActiveSpeakerChangedUI", Qt::AutoConnection, Q_ARG(QString, QString::fromStdString(accountId)),
                              Q_ARG(QString, QString::fromStdString(nickname)));
}

void AudioManager::onRemoteUserAudioStats(const std::vector<AudioStats>& videoStats) {
    QJsonArray statsArray;
    for (auto& stats : videoStats) {
        QJsonObject statsObj;
        statsObj["accountId"] = QString::fromStdString(stats.userId);
        statsObj["bitRate"] = (qint32)(stats.bitRate);
        statsObj["lossRate"] = (qint32)(stats.lossRate);
        statsObj["volume"] = (qint32)(stats.volume);
        statsArray.push_back(statsObj);
    }
    emit remoteUserAudioStats(statsArray);
}

void AudioManager::onError(uint32_t errorCode, const std::string& errorMessage) {
    emit error(errorCode, QString::fromStdString(errorMessage));
}

void AudioManager::onHandsUpStatusChanged(const std::string& accountId, NEHandsUpStatus handsUpStatus) {
    QMetaObject::invokeMethod(this, "onHandsUpStatusChangedUI", Qt::AutoConnection, Q_ARG(QString, QString::fromStdString(accountId)),
                              Q_ARG(NEMeeting::HandsUpStatus, (NEMeeting::HandsUpStatus)handsUpStatus));
}

void AudioManager::muteLocalAudio(bool mute) {
    m_audioController->muteMyAudio(mute, std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
}

void AudioManager::muteRemoteAudio(const QString& accountId, bool mute, bool bAllowOpenByself) {
    QByteArray byteAccountId = accountId.toUtf8();
    if (accountId.isEmpty()) {
        if (mute) {
            m_audioController->muteAllParticipantsAudio(
                bAllowOpenByself, std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
        } else {
            m_audioController->unmuteAllParticipantsAudio(
                std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
        }
    } else {
        m_audioController->muteParticipantAudio(byteAccountId.data(), mute,
                                                std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
    }
}

void AudioManager::allowRemoteMemberHandsUp(const QString& accountId, bool bAllowHandsUp) {
    QByteArray byteAccountId = accountId.toUtf8();
    m_audioController->lowerHand(byteAccountId.data(),
                                 std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
}

void AudioManager::handsUpToSpeak(bool bHandsUp) {
    m_audioController->raiseMyHand(bHandsUp, std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
}

void AudioManager::onUserAudioStatusChangedUI(const QString& changedAccountId, NEMeeting::DeviceStatus deviceStatus) {

    auto authInfo = AuthManager::getInstance()->getAuthInfo();
    if (authInfo && authInfo->getAccountId() == changedAccountId.toStdString()) {
        if (m_localAudioStatus != deviceStatus) {
            emit userAudioStatusChanged(changedAccountId, deviceStatus);
        }

        setLocalAudioStatus(deviceStatus);
    } else {
        emit userAudioStatusChanged(changedAccountId, deviceStatus);
    }
}

void AudioManager::onActiveSpeakerChangedUI(const QString& accountId, const QString& nickname) {
    setActiveSpeaker(accountId);
    setActiveSpeakerNickname(nickname);
}

void AudioManager::onHandsUpStatusChangedUI(const QString& accountId, NEMeeting::HandsUpStatus status) {
    YXLOG(Info) << "onHandsUpStatusChangedUI accountId = " << accountId.toStdString() << " audio handstatus : " << status << YXLOGEnd;
    auto authInfo = AuthManager::getInstance()->getAuthInfo();
    if (nullptr == authInfo) {
        return;
    }

    if (authInfo->getAccountId() == accountId.toStdString()) {
        if (status == NEMeeting::HAND_STATUS_RAISE) {
            m_bHandsUp = true;
        } else {
            m_bHandsUp = false;
        }
    }

    emit handsupStatusChanged(accountId, status);
}

QString AudioManager::activeSpeaker() const {
    return m_activeSpeaker;
}

void AudioManager::setActiveSpeaker(const QString& activeSpeaker) {
    if (activeSpeaker != m_activeSpeaker && VideoManager::getInstance()->focusAccountId().isEmpty() &&
        ShareManager::getInstance()->shareAccountId().isEmpty()) {
        m_activeSpeaker = activeSpeaker;
        emit activeSpeakerChanged();
    }
}

QString AudioManager::activeSpeakerNickname() const {
    return m_activeSpeakerNickname;
}

void AudioManager::setActiveSpeakerNickname(const QString& activeSpeakerNickname) {
    if (activeSpeakerNickname != m_activeSpeakerNickname) {
        m_activeSpeakerNickname = activeSpeakerNickname;
        emit activeSpeakerNicknameChanged();
    }
}

bool AudioManager::handsUpStatus() const {
    return m_bHandsUp;
}

void AudioManager::setHandsUpStatus(bool handsUp) {
    m_bHandsUp = handsUp;
}

int AudioManager::localAudioStatus() const {
    return m_localAudioStatus;
}

void AudioManager::setLocalAudioStatus(const int& localAudioStatus) {
    if (m_localAudioStatus != localAudioStatus) {
        m_localAudioStatus = (NEMeeting::DeviceStatus)localAudioStatus;
        emit localAudioStatusChanged();
    }
}
