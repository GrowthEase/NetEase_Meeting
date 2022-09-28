// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "audio_manager.h"
#include "controller/audio_controller.h"
#include "members_manager.h"
#include "share_manager.h"
#include "video_manager.h"

#ifdef Q_OS_MACX
#include "components/auth_checker.h"
#endif

AudioManager::AudioManager(QObject* parent)
    : QObject(parent) {
    m_audioController = std::make_shared<NEMeetingAudioController>();
}

bool AudioManager::hasMicrophonePermission() {
#ifdef Q_OS_WIN32
    return true;
#else
    return checkAuthMicrophone();
#endif
}

void AudioManager::openSystemMicrophoneSettings() {
#ifdef Q_OS_MACX
    openMicrophoneSettings();
#endif
}

void AudioManager::onUserAudioStatusChanged(const std::string& accountId, NEMeeting::DeviceStatus deviceStatus) {
    QMetaObject::invokeMethod(this, "onUserAudioStatusChangedUI", Qt::AutoConnection, Q_ARG(QString, QString::fromStdString(accountId)),
                              Q_ARG(NEMeeting::DeviceStatus, deviceStatus));
}

void AudioManager::onActiveSpeakerChanged(const std::string& accountId, const std::string& nickname) {
    QMetaObject::invokeMethod(this, "onActiveSpeakerChangedUI", Qt::AutoConnection, Q_ARG(QString, QString::fromStdString(accountId)),
                              Q_ARG(QString, QString::fromStdString(nickname)));
}

void AudioManager::onUserSpeakerChanged(const std::list<std::string>& nickname) {
    QStringList nickNameTmp;
    if (NEMeeting::DEVICE_ENABLED == m_localAudioStatus && !nickname.empty()) {
        nickNameTmp << MembersManager::getInstance()->getNicknameByAccountId(AuthManager::getInstance()->authAccountId());
    }
    std::for_each(nickname.begin(), nickname.end(), [&nickNameTmp](auto& it) { nickNameTmp << QString::fromStdString(it); });
    QMetaObject::invokeMethod(this, "onUserSpeakerChangedUI", Qt::AutoConnection, Q_ARG(QStringList, nickNameTmp));
}

void AudioManager::onRemoteUserAudioStats(const std::vector<NEAudioStats>& videoStats) {
    QJsonArray statsArray;
    for (auto& stats : videoStats) {
        QJsonObject statsObj;
        statsObj["accountId"] = QString::fromStdString(stats.userUuid);
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

void AudioManager::muteLocalAudio(bool mute) {
    if (!mute && !hasMicrophonePermission()) {
        emit showPermissionWnd();
        return;
    }

    if (mute && m_localAudioStatus != NEMeeting::DEVICE_ENABLED) {
        return;
    }

    if (!mute && m_localAudioStatus == NEMeeting::DEVICE_ENABLED) {
        return;
    }

    m_audioController->muteMyAudio(mute, [=](uint32_t errorCode, const std::string& errorMessage) {
        YXLOG(Info) << "muteMyAudio: errorCode " << errorCode << ", errorMessage: " << errorMessage << YXLOGEnd;
        if (errorCode != 0) {
            QString qstrErrorMessage = mute ? tr("mute My Audio failed") : tr("unmute My Audio failed");
            MeetingManager::getInstance()->onError(errorCode, qstrErrorMessage.toStdString());
        }
    });
}

bool AudioManager::startAudioDump() {
    return m_audioController->startAudioDump();
}

bool AudioManager::stopAudioDump() {
    return m_audioController->stopAudioDump();
}

bool AudioManager::enableAudioVolumeIndication(bool enable) {
    return m_audioController->enableAudioVolumeIndication(enable, 200);
}

std::shared_ptr<NEMeetingAudioController> AudioManager::getAudioController() {
    return m_audioController;
}

void AudioManager::muteRemoteAudio(const QString& accountId, bool mute, bool bAllowOpenByself) {
    QByteArray byteAccountId = accountId.toUtf8();
    if (accountId.isEmpty()) {
        if (mute) {
            m_audioController->muteAllParticipantsAudio(bAllowOpenByself, [=](int code, const std::string& msg) {
                MeetingManager::getInstance()->onError(code, msg);
                if (code == 0) {
                    MeetingManager::getInstance()->onRoomMuteStatusChanged(true);
                }
            });
        } else {
            m_audioController->unmuteAllParticipantsAudio([=](int code, const std::string& msg) {
                MeetingManager::getInstance()->onError(code, msg);
                if (code == 0) {
                    MeetingManager::getInstance()->onRoomMuteStatusChanged(false);
                }
            });
        }
    } else {
        m_audioController->muteParticipantAudio(
            byteAccountId.data(), mute,
            std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
    }
}

void AudioManager::onUserAudioStatusChangedUI(const QString& changedAccountId, NEMeeting::DeviceStatus deviceStatus) {
    auto authInfo = AuthManager::getInstance()->getAuthInfo();
    if (authInfo.accountId == changedAccountId.toStdString()) {
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

void AudioManager::onUserSpeakerChangedUI(const QStringList& nickname) {
    emit userSpeakerChanged(nickname.join(tr(",")));
}

QString AudioManager::activeSpeaker() const {
    return m_activeSpeaker;
}

void AudioManager::setActiveSpeaker(const QString& activeSpeaker) {
    if (activeSpeaker != m_activeSpeaker && VideoManager::getInstance()->focusAccountId().isEmpty() &&
        ShareManager::getInstance()->shareAccountId().isEmpty()) {
        m_activeSpeaker = activeSpeaker;
        MeetingManager::getInstance()->getMeetingController()->getRoomInfo().speakerUserId = m_activeSpeaker.toStdString();
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

int AudioManager::localAudioStatus() const {
    return m_localAudioStatus;
}

void AudioManager::setLocalAudioStatus(const int& localAudioStatus) {
    if (m_localAudioStatus != localAudioStatus) {
        m_localAudioStatus = (NEMeeting::DeviceStatus)localAudioStatus;
        YXLOG(Info) << "m_localAudioStatus changed :" << m_localAudioStatus << YXLOGEnd;
        emit localAudioStatusChanged();
    }
}
