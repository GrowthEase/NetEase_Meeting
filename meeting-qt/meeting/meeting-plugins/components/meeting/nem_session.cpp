// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_session.h"

NEMSession::NEMSession(QObject* parent)
    : QObject(parent)
    , m_invoker(new Invoker) {}

bool NEMSession::create(const QString& meetingId, const QString& nickname, bool enableAudio, bool enableVideo) {
    if (isValid() && m_meetingService) {
        nem_sdk::CreateMeetingParam params;
        QByteArray byteMeetingId = meetingId.toUtf8();
        params.meetingId = byteMeetingId.data();
        QByteArray byteNickname = nickname.toUtf8();
        params.nickname = byteNickname.data();
        params.audio = enableAudio ? nem_sdk::kDeviceEnabled : nem_sdk::kDeviceDisabledBySelf;
        params.video = enableVideo ? nem_sdk::kDeviceEnabled : nem_sdk::kDeviceDisabledBySelf;
        return m_meetingService->createMeeting(params) == nem_sdk::kNEMNoError;
    }
    return false;
}

bool NEMSession::join(const QString& meetingId, const QString& password, const QString& nickname, bool enableAudio, bool enableVideo) {
    if (isValid() && m_meetingService) {
        nem_sdk::JoinMeetingParam params;
        QByteArray byteMeetingId = meetingId.toUtf8();
        params.meetingId = byteMeetingId.data();
        QByteArray byteNickname = nickname.toUtf8();
        params.nickname = byteNickname.data();
        QByteArray bytePassword = password.toUtf8();
        params.password = bytePassword.data();
        params.audio = enableAudio ? nem_sdk::kDeviceEnabled : nem_sdk::kDeviceDisabledBySelf;
        params.video = enableVideo ? nem_sdk::kDeviceEnabled : nem_sdk::kDeviceDisabledBySelf;
        return m_meetingService->joinMeeting(params) == nem_sdk::kNEMNoError;
    }
    return false;
}

void NEMSession::leave(bool finish) {
    if (m_meetingService) {
        m_meetingService->leaveMeeting(finish);
    }
}

bool NEMSession::isValid() const {
    return m_isValid;
}

void NEMSession::setIsValid(bool isValid) {
    m_isValid = isValid;
}

NEMEngine* NEMSession::engine() const {
    return m_engine;
}

void NEMSession::setEngine(NEMEngine* engine) {
    if (m_engine != engine) {
        m_engine = engine;
        Q_EMIT engineChanged();
        if (m_engine != nullptr) {
            m_meetingService = m_engine->getMeetingService();
            m_meetingService->setMeetingEventHandler(this);
            if (m_audioController != nullptr) {
                auto audioCtrl = m_meetingService->getMeetingAudioCtrl();
                m_audioController->setAudioController(audioCtrl);
            }
            if (m_videoController != nullptr) {
                auto videoCtrl = m_meetingService->getMeetingVideoCtrl();
                m_videoController->setVideoController(videoCtrl);
            }
            if (m_shareController != nullptr) {
                auto shareCtrl = m_meetingService->getSharingController();
                m_shareController->setShareController(shareCtrl);
            }
            if (m_membersController != nullptr) {
                auto membersCtrl = m_meetingService->getMeetingMembersCtrl();
                m_membersController->setMembersController(membersCtrl);
            }
            setIsValid(true);
        }
    }
}

QString NEMSession::meetingId() const {
    return m_meetingId;
}

void NEMSession::setMeetingId(const QString& meetingId) {
    if (m_meetingId != meetingId) {
        m_meetingId = meetingId;
        Q_EMIT meetingIdChanged();
    }
}

QString NEMSession::shortMeetingNum() const {
    return m_shortMeetingNum;
}

void NEMSession::setShortMeetingNum(const QString& shortMeetingNum) {
    if (m_shortMeetingNum != shortMeetingNum) {
        m_shortMeetingNum = shortMeetingNum;
        Q_EMIT shortMeetingNumChanged();
    }
}

QString NEMSession::channelId() const {
    return m_channelId;
}

void NEMSession::setChannelId(const QString& channelId) {
    if (m_channelId != channelId) {
        m_channelId = channelId;
        Q_EMIT channelIdChanged();
    }
}

QString NEMSession::sipChannelId() const {
    return m_sipChannelId;
}

void NEMSession::setSipChannelId(const QString& sipChannelId) {
    if (m_sipChannelId != sipChannelId) {
        m_sipChannelId = sipChannelId;
        Q_EMIT sipChannelIdChanged();
    }
}

QString NEMSession::topic() const {
    return m_topic;
}

void NEMSession::setTopic(const QString& topic) {
    if (m_topic != topic) {
        m_topic = topic;
        Q_EMIT topicChanged();
    }
}

QString NEMSession::password() const {
    return m_password;
}

void NEMSession::setPassword(const QString& password) {
    if (m_password != password) {
        m_password = password;
        Q_EMIT passwordChanged();
    }
}

bool NEMSession::locked() const {
    return m_locked;
}

void NEMSession::setLocked(bool locked) {
    if (m_locked != locked) {
        m_locked = locked;
        Q_EMIT lockedChanged();
    }
}

NEMSession::MeetingMuteType NEMSession::muteType() const {
    return m_muteType;
}

void NEMSession::setMuteType(const MeetingMuteType& muteType) {
    if (m_muteType != muteType) {
        m_muteType = muteType;
        Q_EMIT muteTypeChanged();
    }
}

time_t NEMSession::createdAt() const {
    return m_createdAt;
}

void NEMSession::setCreatedAt(const time_t& createdAt) {
    if (m_createdAt != createdAt) {
        m_createdAt = createdAt;
        Q_EMIT createdAtChanged();
    }
}

time_t NEMSession::updatedAt() const {
    return m_updatedAt;
}

void NEMSession::setUpdatedAt(const time_t& updatedAt) {
    if (m_updatedAt != updatedAt) {
        m_updatedAt = updatedAt;
        Q_EMIT updatedAtChanged();
    }
}

time_t NEMSession::startTime() const {
    return m_startTime;
}

void NEMSession::setStartTime(const time_t& startTime) {
    if (m_startTime != startTime) {
        m_startTime = startTime;
        Q_EMIT startTimeChanged();
    }
}

time_t NEMSession::endTime() const {
    return m_endTime;
}

void NEMSession::setEndTime(const time_t& endTime) {
    if (m_endTime != endTime) {
        m_endTime = endTime;
        Q_EMIT endTimeChanged();
    }
}

time_t NEMSession::duration() const {
    return m_duration;
}

void NEMSession::setDuration(const time_t& duration) {
    if (m_duration != duration) {
        m_duration = duration;
        Q_EMIT durationChanged();
    }
}

NEMSession::MeetingStatus NEMSession::status() const {
    return m_status;
}

void NEMSession::setStatus(const MeetingStatus& status) {
    if (m_status != status) {
        m_status = status;
        Q_EMIT statusChanged();
    }
}

NEMMine* NEMSession::mine() const {
    return m_mine;
}

void NEMSession::setMine(NEMMine* mine) {
    if (m_mine != mine) {
        m_mine = mine;
        Q_EMIT mineChanged();
        if (m_audioController != nullptr) {
            connect(m_audioController, &NEMAudioController::userAudioStatusChanged, m_mine, &NEMMine::userAudioStatusChanged);
        }
        if (m_videoController != nullptr) {
            connect(m_videoController, &NEMVideoController::userVideoStatusChanged, m_mine, &NEMMine::userVideoStatusChanged);
        }
    }
}

int NEMSession::errorCode() const {
    return m_errorCode;
}

void NEMSession::setErrorCode(int errorCode) {
    if (m_errorCode != errorCode) {
        m_errorCode = errorCode;
        Q_EMIT errorCodeChanged();
    }
}

QString NEMSession::errorString() const {
    return m_errorString;
}

void NEMSession::setErrorString(const QString& errorString) {
    if (m_errorString != errorString) {
        m_errorString = errorString;
        Q_EMIT errorStringChanged();
    }
}

void NEMSession::onMeetingStatusChanged(nem_sdk::MeetingStatus status, nem_sdk::MeetingStatusExtCode result) {
    m_invoker->execute([=]() {
        setErrorCode(result.errorCode);
        setErrorString(QString::fromStdString(result.errorMessage.c_str()));
        MeetingStatus uiStatus = transformStatus(status);
        setStatus(uiStatus);
    });
}

void NEMSession::onMeetingJoinTypeChanged(nem_sdk::MeetingJoinType joinType) {
    m_invoker->execute([=]() { setLocked(joinType == nem_sdk::kJoinTypeProhibitAnyone); });
}

void NEMSession::onMeetingMuteStatusChanged(bool muted) {
    m_invoker->execute([=]() { setMuteType(muted ? MEETING_MUTE_ALLOW_UNMUTE : MEETING_MUTE_DEFAULT); });
}

void NEMSession::onMeetingMuteNeedHandsUpChanged(bool bNeedHandsUp) {
    m_invoker->execute([=]() { setMuteType(bNeedHandsUp ? MEETING_MUTE_NEEDS_HANDSUP : MEETING_MUTE_DEFAULT); });
}

void NEMSession::onMeetingSIPChannelIdChanged(const std::string sipChannelId) {
    m_invoker->execute([=]() { setSipChannelId(QString::fromStdString(sipChannelId)); });
}

void NEMSession::onMeetingDurationChanged(const uint64_t& duration) {
    m_invoker->execute([=]() { setDuration(duration); });
}

void NEMSession::onMeetingStartTimeChanged(uint64_t startTime) {
    m_invoker->execute([=]() { setStartTime(startTime); });
}

void NEMSession::onError(uint32_t errorCode, const std::string& errorMessage) {
    m_invoker->execute([=]() {
        setErrorCode(errorCode);
        setErrorString(QString::fromStdString(errorMessage));
    });
}

bool NEMSession::updateMeetingInfo(bool cleanup /* = false*/) {
    if (!cleanup && m_meetingService != nullptr) {
        auto meetingInfo = m_meetingService->getMeetingInfo();
        setChannelId(QString::fromStdString(meetingInfo->getChannelId()));
        setCreatedAt(meetingInfo->getMeetingCreatedTime());
        setDuration(meetingInfo->getMeetingDuration());
        setStartTime(meetingInfo->getMeetingSheduleBeginTime());
        setEndTime(meetingInfo->getMeetingSheduleEndTime());
        setLocked(meetingInfo->getMeetingJoinCtrlType() == nem_sdk::kJoinTypeProhibitAnyone);
        setMeetingId(QString::fromStdString(meetingInfo->getMeetingId()));
        setShortMeetingNum(QString::fromStdString(meetingInfo->getShortMeetingNum()));
        setSipChannelId(QString::fromStdString(meetingInfo->getSIPChannelId()));
        setTopic(QString::fromStdString(meetingInfo->getMeetingTopic()));
        setPassword(QString::fromStdString(meetingInfo->getMeetingPassword()));
        if (meetingInfo->getMeeintMuteAll()) {
            setMuteType(MEETING_MUTE_ALLOW_UNMUTE);
        } else if (meetingInfo->getMeetingAllowSelfAudioOn()) {
            setMuteType(MEETING_MUTE_NEEDS_HANDSUP);
        } else {
            setMuteType(MEETING_MUTE_DEFAULT);
        }
        return true;
    } else {
        setChannelId("");
        setCreatedAt(0);
        setDuration(0);
        setStartTime(0);
        setEndTime(0);
        setLocked(false);
        setMeetingId("");
        setShortMeetingNum("");
        setSipChannelId("");
        setTopic("");
        setPassword("");
        setMuteType(MEETING_MUTE_DEFAULT);
        return true;
    }
    return false;
}

NEMSession::MeetingStatus NEMSession::transformStatus(const nem_sdk::MeetingStatus& status) {
    MeetingStatus uiStatus;
    switch (status) {
        case nem_sdk::kMeetingIdel:
            uiStatus = MEETING_IDLE;
            break;
        case nem_sdk::kMeetingConnecting:
            uiStatus = MEETING_CONNECTING;
            break;
        case nem_sdk::kMeetingVerifyPassword:
            uiStatus = MEETING_CONNECT_FAILED;
            break;
        case nem_sdk::kMeetingPreparing:
            uiStatus = MEETING_PREPARING;
            break;
        case nem_sdk::kMeetingPrepared:
            uiStatus = MEETING_PREPARED;
            break;
        case nem_sdk::kMeetingConnected:
            uiStatus = MEETING_CONNECTED;
            updateMeetingInfo();
            Q_EMIT connected();
            break;
        case nem_sdk::kMeetingReconnected:
            uiStatus = MEETING_CONNECTING;
            break;
        case nem_sdk::kMeetingReconnectFailed:
        case nem_sdk::kMeetingConnectFailed:
            uiStatus = MEETING_CONNECT_FAILED;
            Q_EMIT error();
            break;
        case nem_sdk::kMeetingDisconnected:
        case nem_sdk::kMeetingKickoutByHost:
        case nem_sdk::kMeetingMultispotLogin:
        case nem_sdk::kMeetingCmdChannelDisconnected:
            uiStatus = MEETING_DISCONNECTED;
            Q_EMIT disconnected();
            break;
        case nem_sdk::kMeetingEnded:
            uiStatus = MEETING_ENDED;
            updateMeetingInfo(true);
            Q_EMIT ended();
            break;
    }
    return uiStatus;
}

NEMMembersController* NEMSession::membersController() const {
    return m_membersController;
}

void NEMSession::setMembersController(NEMMembersController* membersController) {
    if (m_membersController != membersController) {
        m_membersController = membersController;
        Q_EMIT membersControllerChanged();
        if (m_membersController != nullptr && isValid()) {
            auto membersCtrl = m_meetingService->getMeetingMembersCtrl();
            m_membersController->setMembersController(membersCtrl);
        }
    }
}

NEMAudioController* NEMSession::audioController() const {
    return m_audioController;
}

void NEMSession::setAudioController(NEMAudioController* audioController) {
    if (m_audioController != audioController) {
        m_audioController = audioController;
        Q_EMIT audioControllerChanged();
        if (m_audioController != nullptr && isValid()) {
            auto audioCtrl = m_meetingService->getMeetingAudioCtrl();
            m_audioController->setAudioController(audioCtrl);
        }
        if (m_membersController) {
            connect(m_audioController, &NEMAudioController::userAudioStatusChanged, m_membersController,
                    &NEMMembersController::handleAudioStatusChanged);
        }
    }
}

NEMVideoController* NEMSession::videoController() const {
    return m_videoController;
}

void NEMSession::setVideoController(NEMVideoController* videoController) {
    if (m_videoController != videoController) {
        m_videoController = videoController;
        Q_EMIT videoControllerChanged();
        if (m_videoController != nullptr && isValid()) {
            auto videoCtrl = m_meetingService->getMeetingVideoCtrl();
            m_videoController->setVideoController(videoCtrl);
        }
        if (m_membersController) {
            connect(m_videoController, &NEMVideoController::userVideoStatusChanged, m_membersController,
                    &NEMMembersController::handleVideoStatusChanged);
        }
    }
}

NEMShareController* NEMSession::shareController() const {
    return m_shareController;
}

void NEMSession::setShareController(NEMShareController* shareController) {
    if (m_shareController != shareController) {
        m_shareController = shareController;
        Q_EMIT shareControllerChanged();
        if (m_shareController != nullptr && isValid()) {
            auto shareCtrol = m_meetingService->getSharingController();
            m_shareController->setShareController(shareCtrol);
        }
    }
}
