// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "meeting_manager.h"
#include "feedback_manager.h"
#include "global_manager.h"
#include "listeners/meeting_service_listener.h"
#include "manager/auth_manager.h"
#include "manager/chat_manager.h"
#include "manager/config_manager.h"
#include "manager/device_manager.h"
#include "manager/live_manager.h"
#include "manager/more_item_manager.h"
#include "meeting/invite_manager.h"
#include "meeting/members_manager.h"
#include "meeting/share_manager.h"
#include "meeting/video_manager.h"
#include "meeting/whiteboard_manager.h"
#include "settings_manager.h"

MeetingManager::MeetingManager(QObject* parent)
    : QObject(parent) {
    qRegisterMetaType<NEMeeting::Status>();

    m_meetingController = std::make_shared<NEMeetingController>();
    m_subscribeHelper = std::make_shared<SubscribeHelper>();

    m_durationTimer.setTimerType(Qt::PreciseTimer);
    m_durationTimer.setInterval(1000);
    m_durationTimer.callOnTimeout([this]() {
        auto currenttime = std::chrono::time_point_cast<std::chrono::seconds>(std::chrono::system_clock::now()).time_since_epoch().count();
        m_uMeetingDuration = (currenttime - m_uMeetingStartTime);
        emit meetingDurationChanged();
    });

    m_joinTimeoutTimer.setTimerType(Qt::PreciseTimer);
    m_joinTimeoutTimer.setSingleShot(true);
    m_joinTimeoutTimer.callOnTimeout([this]() {
        if (m_meetingStatus == NEMeeting::MEETING_CONNECTING) {
            YXLOG(Info) << "joinTimeoutTimer, leaveMeeting." << YXLOGEnd;
            leaveMeeting(false);
            emit meetingStatusChanged(NEMeeting::MEETING_CONNECT_FAILED, 408, "joinTimeoutTimer");
            m_meetingStatus = NEMeeting::MEETING_IDLE;
            emit meetingStatusChanged(NEMeeting::MEETING_IDLE, 0);
        }
    });

    m_remainingTipTimer.setTimerType(Qt::PreciseTimer);
    m_remainingTipTimer.setInterval(1000);
    m_remainingTipTimer.callOnTimeout([this]() {
        m_uRemainingSeconds--;
        setRemainingSeconds(m_uRemainingSeconds);
    });

    qmlRegisterUncreatableType<NEMeeting>("NetEase.Meeting.MeetingStatus", 1, 0, "MeetingStatus", "");
    setShowMeetingDuration(ConfigManager::getInstance()->getValue("localShowtime", false).toBool());
}

bool MeetingManager::autoStartMeeting() {
    YXLOG(Info) << "Auto start meeting with command line params." << YXLOGEnd;

    MoreItemManager::getInstance()->restoreToolbar();
    if (m_autoStartInfo.isCreate) {
        //        NEStartRoomParams param;
        //        NEStartRoomOptions option;
        //        QByteArray byteMeetingId = m_autoStartInfo.meetingId.toUtf8();
        //        QByteArray byteNickname = m_autoStartInfo.nickname.toUtf8();
        //        param.roomId = byteMeetingId.data();
        //        param.displayName = byteNickname.data();
        //        option.noAudio = !m_autoStartInfo.audio;
        //        option.noVideo = !m_autoStartInfo.video;
        //        createMeeting(param, option);
    } else {
        //        NEJoinRoomParams param;
        //        NEJoinRoomOptions option;
        //        QByteArray byteMeetingId = m_autoStartInfo.meetingId.toUtf8();
        //        QByteArray byteNickname = m_autoStartInfo.nickname.toUtf8();
        //        param.roomId = byteMeetingId.data();
        //        param.displayName = byteNickname.data();
        //        option.noAudio = !m_autoStartInfo.audio;
        //        option.noVideo = !m_autoStartInfo.video;
        //        joinMeeting(param, option);
    }

    return true;
}

bool MeetingManager::createMeeting(const NS_I_NEM_SDK::NEStartMeetingParams& param, const NERoomOptions& option) {
    m_noVideo = option.noVideo;
    m_noAudio = option.noAudio;

    onConnecting();
    m_meetingController->startRoom(param, option, [=](int errorCode, const std::string& errorMessage) {
        if (errorCode == 0) {
        } else {
            QString qstrErrorMessage = QString::fromStdString(errorMessage);
            if (errorMessage == "kFailed_connect_server") {
                qstrErrorMessage = tr("Failed to connect to server, please try agine.");
            }
            emit meetingStatusChanged(NEMeeting::MEETING_CONNECT_FAILED, errorCode, qstrErrorMessage);
            m_meetingStatus = NEMeeting::MEETING_IDLE;
            emit meetingStatusChanged(NEMeeting::MEETING_IDLE, 0);
        }
    });
    return true;
}

void MeetingManager::cancelJoinMeeting() {
    YXLOG(Info) << "CancelJoinMeeting." << YXLOGEnd;
    emit meetingStatusChanged(NEMeeting::MEETING_CONNECT_FAILED, -1);
    m_meetingStatus = NEMeeting::MEETING_IDLE;
    emit meetingStatusChanged(NEMeeting::MEETING_IDLE, 0);
}

void MeetingManager::joinMeeting(const QString& strPassword) {
    YXLOG(Info) << "joinMeeting by input password." << YXLOGEnd;
    m_joinRoomParams.password = strPassword.toStdString();
    joinMeeting(m_joinRoomParams, m_joinRoomOptions);
}

bool MeetingManager::joinMeeting(const nem_sdk_interface::NEJoinMeetingParams& param, const NERoomOptions& option) {
    m_joinRoomParams = param;
    m_joinRoomOptions = option;

    m_noVideo = option.noVideo;
    m_noAudio = option.noAudio;

    if (m_meetingStatus == NEMeeting::MEETING_IDLE) {
        onConnecting();
    }
    m_meetingController->joinRoom(m_joinRoomParams, m_joinRoomOptions, [=](int errorCode, const std::string& errorMessage) {
        QString qstrErrorMessage = QString::fromStdString(errorMessage);
        if (errorMessage == "kFailed_connect_server") {
            qstrErrorMessage = tr("Failed to connect to server, please try agine.");
        }
        if (errorCode == 1020) {
            if (m_joinTimeoutTimer.isActive())
                m_joinTimeoutTimer.stop();
            emit meetingStatusChanged(NEMeeting::MEETING_WAITING_VERIFY_PASSWORD, errorCode, qstrErrorMessage);
        } else if (errorCode != 200 && errorCode != 0) {
            emit meetingStatusChanged(NEMeeting::MEETING_CONNECT_FAILED, errorCode, qstrErrorMessage);
            m_meetingStatus = NEMeeting::MEETING_IDLE;
            emit meetingStatusChanged(NEMeeting::MEETING_IDLE, 0);
        }
    });
    return true;
}

NEMeeting::Status MeetingManager::getRoomStatus() const {
    return m_meetingStatus;
}

void MeetingManager::modifyNicknameInMeeting(const QString& newnickname, const QString& meetingID) {
    auto roomContext = m_meetingController->getRoomContext();
    if (roomContext) {
        roomContext->changeMyName(newnickname.toStdString(), [this, newnickname](int errCode, const std::string&) {
            m_invoker.execute([=]() {
                if (errCode == 0) {
                    m_meetingController->updateDisplayName(newnickname.toStdString());
                }
                emit modifyNicknameResult(errCode == 0);
            });
        });
    }
}

void MeetingManager::activeMainWindow() const {
#if defined(Q_OS_MACX)
    MacXHelpers helpers;
    helpers.activeWindow(ShareManager::getInstance()->getMainWindow());
#endif
}

void MeetingManager::onIdle() {
    onRoomStatusChanged(NEMeeting::MEETING_IDLE);
}

void MeetingManager::onConnecting() {
    onRoomStatusChanged(NEMeeting::MEETING_PREPARING);
    onRoomStatusChanged(NEMeeting::MEETING_PREPARED);
    onRoomStatusChanged(NEMeeting::MEETING_CONNECTING);
}

void MeetingManager::onConnected() {
    onRoomStatusChanged(NEMeeting::MEETING_CONNECTED);
}

void MeetingManager::onDisconnected(int reason) {
    if (reason == kNERoomEndReasonLeaveBySelf) {
        onRoomStatusChanged(NEMeeting::MEETING_ENDED, 0);
    } else if (reason == kNERoomEndReasonCloseByMember) {
        if (MembersManager::getInstance()->hostAccountId() == AuthManager::getInstance()->authAccountId()) {
            onRoomStatusChanged(NEMeeting::MEETING_ENDED, 0);
        } else {
            onRoomStatusChanged(NEMeeting::MEETING_DISCONNECTED, reason);
        }
    } else {
        onRoomStatusChanged(NEMeeting::MEETING_DISCONNECTED, reason);
    }
}

void MeetingManager::onConnectFail(int reason) {
    onRoomStatusChanged(NEMeeting::MEETING_CONNECT_FAILED, reason);
}

void MeetingManager::onReConnecting() {
    onRoomStatusChanged(NEMeeting::MEETING_CMD_CHANNEL_DISCONNECTED);
}

void MeetingManager::onReConnected() {
    onRoomStatusChanged(NEMeeting::MEETING_RECONNECTED);
}

void MeetingManager::onReConnectFail() {
    onRoomStatusChanged(NEMeeting::MEETING_RECONNECT_FAILED);
}

void MeetingManager::startJoinTimer() {
    if (m_joinTimeoutTimer.isActive())
        m_joinTimeoutTimer.stop();
    m_joinTimeoutTimer.start(m_joinTimeout);
}

void MeetingManager::activeMeetingWindow(bool bRaise) {
    if (m_meetingStatus != NEMeeting::MEETING_CONNECTED && m_meetingStatus != NEMeeting::MEETING_WAITING_VERIFY_PASSWORD &&
        m_meetingStatus != NEMeeting::MEETING_RECONNECTED)
        return;
    YXLOG(Info) << "Active meeting window on top of others windows." << YXLOGEnd;
    emit activeWindow(bRaise);
}

bool MeetingManager::initialize() {
    return true;
}

void MeetingManager::release() {}

NERoomInfo MeetingManager::getMeetingInfo() const {
    return m_meetingController->getRoomInfo();
}

INERoomContext* MeetingManager::getRoomContext() {
    return m_meetingController->getRoomContext();
}

INERoomWhiteboardController* MeetingManager::getWhiteboardController() const {
    auto context = m_meetingController->getRoomContext();
    if (context) {
        return context->getWhiteboardController();
    }
    return nullptr;
}

std::shared_ptr<NEMeetingController> MeetingManager::getMeetingController() const {
    return m_meetingController;
}

INERoomChatController* MeetingManager::getInRoomChatController() const {
    auto context = m_meetingController->getRoomContext();
    if (context) {
        return context->getChatController();
    }
    return nullptr;
}

INERoomRtcController* MeetingManager::getInRoomRtcController() const {
    auto context = m_meetingController->getRoomContext();
    if (context) {
        return context->getRtcController();
    }
    return nullptr;
}

INERoomLiveController* MeetingManager::getLiveController() const {
    auto context = m_meetingController->getRoomContext();
    if (context) {
        return context->getLiveController();
    }
    return nullptr;
}

std::shared_ptr<SubscribeHelper> MeetingManager::getSubscribeHelper() const {
    return m_subscribeHelper;
}

void MeetingManager::setStartMeetingInfo(bool isCreate,
                                         const QString& meetingId,
                                         const QString& nickname,
                                         bool audio,
                                         bool video,
                                         bool hideInvitation) {
    m_autoStartInfo.isCreate = isCreate;
    m_autoStartInfo.meetingId = meetingId;
    m_autoStartInfo.nickname = nickname;
    m_autoStartInfo.audio = audio;
    m_autoStartInfo.video = video;
    // m_autoStartInfo.hideInvitation = hideInvitation;
    setHideInvitation(hideInvitation);
    setAutoStartMode(true);
}

void MeetingManager::onRoomStatusChanged(NEMeeting::Status status, int errorCode) {
    m_invoker.execute([=]() {
        bool bEnd = false;
        if (status == NEMeeting::MEETING_CONNECTED) {
            if (m_joinTimeoutTimer.isActive())
                m_joinTimeoutTimer.stop();

            m_meetingController->initRoomInfo();
            m_subscribeHelper->init();

            auto congigSvr = GlobalManager::getInstance()->getGlobalConfig();
            if (congigSvr != nullptr) {
                bool beautySupport = congigSvr->isBeautySupported();
                beautySupport = (beautySupport && SettingsManager::getInstance()->getEnableBeauty());
                MoreItemManager::getInstance()->setBeautyVisible(beautySupport);
                SettingsManager::getInstance()->setEnableFaceBeauty(beautySupport);
                if (beautySupport) {
                    SettingsManager::getInstance()->initFaceBeautyLevel();
                }
            }

            auto meetingInfo = m_meetingController->getRoomInfo();

            if (m_showMeetingRemainingTip) {
                setRemainingSeconds(meetingInfo.remainingSeconds);
                m_remainingTipTimer.start();
            }

            setMeetingUniqueId(QString::fromStdString(meetingInfo.roomUniqueId));
            setMeetingId(QString::fromStdString(meetingInfo.roomId));
            setShortMeetingNum(QString::fromStdString(meetingInfo.shortRoomId));
            setMeetingTopic(QString::fromStdString(meetingInfo.subject));
            setMeetingPassword(QString::fromStdString(meetingInfo.password));
            setMeetingSIPChannelId(QString::fromStdString(meetingInfo.sipId));
            setMeetingInviteUrl(QString::fromStdString(meetingInfo.inviteUrl));
            MoreItemManager::getInstance()->setSipInviteVisible(!meetingInfo.sipId.empty());
            setMeetingMuted(meetingInfo.audioAllMute);
            setMeetingVideoMuted(meetingInfo.videoAllmute);

            bool isHost = m_meetingController->getRoomContext()->getLocalMember()->getUserRole().name == "host";
            bool isManager = m_meetingController->getRoomContext()->getLocalMember()->getUserRole().name == "cohost";

            if (!isHost && !isManager && meetingInfo.audioAllMute) {
                AudioManager::getInstance()->onUserAudioStatusChanged(AuthManager::getInstance()->authAccountId().toStdString(),
                                                                      NEMeeting::DEVICE_DISABLED_BY_HOST);
            }

            if (!isHost && !isManager && meetingInfo.videoAllmute) {
                VideoManager::getInstance()->onUserVideoStatusChanged(AuthManager::getInstance()->authAccountId().toStdString(),
                                                                      NEMeeting::DEVICE_DISABLED_BY_HOST);
            }

            MembersManager::getInstance()->initMemberList(m_meetingController->getRoomContext()->getLocalMember(),
                                                          m_meetingController->getRoomContext()->getRemoteMembers());
            setMeetingAllowSelfAudioOn(meetingInfo.allowSelfAudioOn);
            setMeetingAllowSelfVideoOn(meetingInfo.allowSelfVideoOn);
            setNickname(QString::fromStdString(meetingInfo.displayName));
            setMeetingSchdeuleStarttime(meetingInfo.scheduleTimeBegin);
            setMeetingSchdeuleEndtime(meetingInfo.scheduleTimeEnd);
            setMeetingLocked(meetingInfo.lock);
            ChatManager::getInstance()->setChatRoomOpen(meetingInfo.isOpenChatroom);
            VideoManager::getInstance()->setFocusAccountId(QString::fromStdString(meetingInfo.focusAccountId));
            ShareManager::getInstance()->setPaused(false);
            ShareManager::getInstance()->setShareSystemSound(false);
            ShareManager::getInstance()->setSmoothPriority(false);
            WhiteboardManager::getInstance()->initWhiteboardStatus();
            setMaxCount(QString::fromStdString(meetingInfo.extraData));
            DeviceManager::getInstance()->startVolumeIndication();
            InviteManager::getInstance()->getInviteList();
            LiveManager::getInstance()->initLiveStreamStatus();

            onRoomStartTimeChanged(m_meetingController->getRoomContext()->getRtcStartTime());

            //            auto recordController = m_inMeetingService->getInRoomRecordController();
            //            if (nullptr != recordController) {
            //                setEnableRecord(recordController->isCloudRecordEnabled());
            //            }

            auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
            if (previewRoomContext) {
                previewRoomContext->removePreviewRoomListener(m_meetingController->getRoomServiceListener());
            }

            QTimer::singleShot(100, [=]() {
                if (!m_noVideo) {
                    if (isHost || isManager || !meetingInfo.videoAllmute) {
                        VideoManager::getInstance()->disableLocalVideo(false);
                    }
                }

                if (!m_noAudio) {
                    if (isHost || isManager || !meetingInfo.audioAllMute) {
                        AudioManager::getInstance()->muteLocalAudio(false);
                    }
                }
            });
        } else if (status == NEMeeting::MEETING_RECONNECTED) {
        } else if (status == NEMeeting::MEETING_PREPARED) {
            AudioManager::getInstance()->userSpeakerChanged("");
            DeviceManager::getInstance()->getCaptureDevices();
            DeviceManager::getInstance()->getPlayoutDevices();
            DeviceManager::getInstance()->getRecordDevices();
        } else if (status == NEMeeting::MEETING_ENDED || status == NEMeeting::MEETING_DISCONNECTED || status == NEMeeting::MEETING_CONNECT_FAILED) {
            if (m_joinTimeoutTimer.isActive())
                m_joinTimeoutTimer.stop();

            if (m_remainingTipTimer.isActive())
                m_remainingTipTimer.stop();

            if (errorCode == 30113) {
                YXLOG(Info) << "Leave meeting manually, join RTC channel failed." << YXLOGEnd;
                leaveMeeting(false);
            }

            m_subscribeHelper->reset();
            m_meetingController->resetRoomContext();
            bEnd = true;
            m_meetingStatus = status;
            QString errorMessage;
            emit meetingStatusChanged(m_meetingStatus, errorCode, errorMessage);
            emit roomStatusChanged(m_meetingStatus);
            m_nMaxCount = -1;
            setMeetingUniqueId("");
            setMeetingId("");
            setMeetingTopic("");
            setMeetingPassword("");
            setMeetingMuted(false);
            setMeetingVideoMuted(false);
            setMeetingLocked(false);
            setMeetingAllowSelfAudioOn(false);
            setMeetingAllowSelfVideoOn(false);
            setMeetingDuration(0);
            setMeetingSchdeuleStarttime(0);
            setMeetingSchdeuleEndtime(0);
            setShortMeetingNum("");
            setEnableRecord(false);
            ChatManager::getInstance()->setChatRoomOpen(false);
            MembersManager::getInstance()->setHostAccountId("");
            VideoManager::getInstance()->setFocusAccountId("");
            ShareManager::getInstance()->setShareAccountId("");
            ShareManager::getInstance()->setPaused(false);
            ShareManager::getInstance()->stopScreenSharing();
            MembersManager::getInstance()->setHandsUpStatus(false);
            MembersManager::getInstance()->setHandsUpCount(0);
            MembersManager::getInstance()->setIsManagerRole(false);
            MembersManager::getInstance()->resetManagerList();
            DeviceManager::getInstance()->stopVolumeIndication();
            VideoManager::getInstance()->setLocalVideoStatus(2);
            SettingsManager::getInstance()->setExtendView(false);
            AudioManager::getInstance()->onUserAudioStatusChanged(AuthManager::getInstance()->authAccountId().toStdString(),
                                                                  NEMeeting::DEVICE_DISABLED_BY_DELF);
            AudioManager::getInstance()->onActiveSpeakerChanged("", "");
            LiveManager::getInstance()->initLiveStreamStatus();

            if (FeedbackManager::getInstance()->isAudioDumping()) {
                FeedbackManager::getInstance()->stopAudioDump();
            }
            auto previewRoomContext = GlobalManager::getInstance()->getPreviewRoomContext();
            if (previewRoomContext && getMeetingController()) {
                previewRoomContext->addPreviewRoomListener(getMeetingController()->getRoomServiceListener());
            }
        }

        QString errorMessage;
        if (!bEnd) {
            m_meetingStatus = status;
            emit meetingStatusChanged(m_meetingStatus, errorCode, errorMessage);
            emit roomStatusChanged(m_meetingStatus);
            if (status == NEMeeting::MEETING_CONNECTED) {
                ShareManager::getInstance()->setShareAccountId(QString::fromStdString(m_meetingController->getRoomInfo().screenSharingUserId));
            }
        }

        if (status == NEMeeting::MEETING_ENDED || status == NEMeeting::MEETING_CONNECT_FAILED || status == NEMeeting::MEETING_DISCONNECTED) {
            m_meetingStatus = NEMeeting::MEETING_IDLE;
            emit meetingStatusChanged(NEMeeting::MEETING_IDLE, 0);
        }
    });
}

void MeetingManager::onRoomLockStatusChanged(bool isLock) {
    m_invoker.execute([=]() {
        setMeetingLocked(isLock);
        lockStatusNotify(isLock);
    });
}

void MeetingManager::onRoomMuteStatusChanged(bool muted) {
    m_invoker.execute([=]() { setMeetingMuted(muted); });
}

void MeetingManager::onRoomMuteAllVideoStatusChanged(bool muted) {
    m_invoker.execute([=]() { setMeetingVideoMuted(muted); });
}

void MeetingManager::onRoomMuteNeedHandsUpChanged(bool bNeedHandsUp) {
    m_invoker.execute([=]() { setMeetingAllowSelfAudioOn(!bNeedHandsUp); });
}

void MeetingManager::onRoomMuteVideoNeedHandsUpChanged(bool bNeedHandsUp) {
    m_invoker.execute([=]() { setMeetingAllowSelfVideoOn(!bNeedHandsUp); });
}

void MeetingManager::onRoomStartTimeChanged(uint64_t startTime) {
    m_invoker.execute([=]() {
        m_uMeetingStartTime = startTime / 1000;
        if (!m_durationTimer.isActive()) {
            m_durationTimer.start();
        }
    });
}

void MeetingManager::onError(uint32_t errorCode, const std::string& errorMessage) {
    m_invoker.execute([=]() {
        QString qstrErrorMessage = QString::fromStdString(errorMessage);
        if (errorMessage == "kFailed_connect_server") {
            qstrErrorMessage = tr("Failed to connect to server, please try agine.");
        }
        emit error(errorCode, qstrErrorMessage);
    });
}

QString MeetingManager::meetingUniqueId() const {
    return m_meetingUniqueId;
}

void MeetingManager::setMeetingUniqueId(const QString& meetingUniqueId) {
    m_meetingUniqueId = meetingUniqueId;
    emit meetingUniqueIdChanged();
}

void MeetingManager::lockMeeting(bool lock) {
    auto roomContext = m_meetingController->getRoomContext();
    if (roomContext) {
        if (lock) {
            roomContext->lockRoom({});
        } else {
            roomContext->unlockRoom({});
        }
    }
}

void MeetingManager::leaveMeeting(bool finish, const neroom::NECallback<>& callback) {
    YXLOG(Info) << "leaveMeeting, finish: " << finish << YXLOGEnd;
    m_meetingController->leaveCurrentRoom(finish, callback);
}

bool MeetingManager::isInMeeting() {
    return m_meetingStatus == NEMeeting::MEETING_CONNECTED || m_meetingStatus == NEMeeting::MEETING_RECONNECTED;
}

bool MeetingManager::reName() const {
    return m_reName;
}

void MeetingManager::setReName(bool reName) {
    m_reName = reName;
    emit reNameChanged();
}

bool MeetingManager::enableRecord() const {
    return m_enableRecord;
}

void MeetingManager::setEnableRecord(bool enableRecord) {
    m_enableRecord = enableRecord;
    emit enableRecordChanged();
}

NEMeeting::MeetingIdDisplayOptions MeetingManager::meetingIdDisplayOption() const {
    return m_meetingIdDisplayOption;
}

void MeetingManager::setMeetingIdDisplayOption(const NEMeeting::MeetingIdDisplayOptions& meetingIdDisplayOption) {
    m_meetingIdDisplayOption = meetingIdDisplayOption;
    Q_EMIT meetingIdDisplayOptionChanged();
}

QString MeetingManager::meetingSIPChannelId() const {
    return m_meetingSIPChannelId;
}

void MeetingManager::setMeetingSIPChannelId(const QString& meetingSIPChannelId) {
    m_meetingSIPChannelId = meetingSIPChannelId;
    emit meetingSIPChannelIdChanged();
}

quint64 MeetingManager::meetingSchdeuleStarttime() {
    return m_meetingScheduleStarttime;
}

void MeetingManager::setMeetingSchdeuleStarttime(quint64 start) {
    m_meetingScheduleStarttime = start;
    emit meetingSchdeuleStarttimeChanged();
}

quint64 MeetingManager::meetingSchdeuleEndtime() {
    return m_meetingScheduleEndtime;
}

void MeetingManager::setMeetingSchdeuleEndtime(quint64 end) {
    m_meetingScheduleEndtime = end;
    emit meetingSchdeuleEndtimeChanged();
}

bool MeetingManager::meetingAllowSelfAudioOn() const {
    return m_meetingAllowSelfAudioOn;
}

void MeetingManager::setMeetingAllowSelfAudioOn(bool bHandsUp) {
    m_meetingAllowSelfAudioOn = bHandsUp;
    emit meetingAllowSelfAudioOnChanged();
}

bool MeetingManager::meetingAllowSelfVideoOn() const {
    return m_meetingAllowSelfVideoOn;
}

void MeetingManager::setMeetingAllowSelfVideoOn(bool bHandsUp) {
    m_meetingAllowSelfVideoOn = bHandsUp;
    emit meetingAllowSelfVideoOnChanged();
}

QString MeetingManager::meetingPassword() const {
    return m_meetingPassword;
}

void MeetingManager::setMeetingPassword(const QString& meetingPassword) {
    m_meetingPassword = meetingPassword;
    emit meetingPasswordChanged();
}

QString MeetingManager::meetingTopic() const {
    return m_meetingTopic;
}

void MeetingManager::setMeetingTopic(const QString& meetingTopic) {
    m_meetingTopic = meetingTopic;
    emit meetingTopicChanged();
}

bool MeetingManager::hideChatroom() const {
    return m_hideChatroom;
}

void MeetingManager::setHideChatroom(bool hideChatroom) {
    m_hideChatroom = hideChatroom;
    emit hideChatroomChanged();
}

bool MeetingManager::hideMuteAllVideo() const {
    return m_hideMuteAllVideo;
}

void MeetingManager::setHideMuteAllVideo(bool hideMuteAllVideo) {
    m_hideMuteAllVideo = hideMuteAllVideo;
    emit hideMuteAllVideoChanged();
}

bool MeetingManager::hideMuteAllAudio() const {
    return m_hideMuteAllAudio;
}

void MeetingManager::setHideMuteAllAudio(bool hideMuteAllAudio) {
    m_hideMuteAllAudio = hideMuteAllAudio;
    emit hideMuteAllAudioChanged();
}

bool MeetingManager::enableFileMessage() const {
    return m_enableFileMessage;
}

void MeetingManager::setEnableFileMessage(bool enableFileMessage) {
    m_enableFileMessage = enableFileMessage;
    emit enableFileMessageChanged();
}

bool MeetingManager::enableImageMessage() const {
    return m_enableImageMessage;
}

void MeetingManager::setEnableImageMessage(bool enableImageMessage) {
    m_enableImageMessage = enableImageMessage;
    emit enableImageMessageChanged();
}

bool MeetingManager::hideInvitation() const {
    return m_hideInvitation;
}

void MeetingManager::setHideInvitation(bool hideInvitation) {
    m_hideInvitation = hideInvitation;
    emit hideInvitationChanged();
}

bool MeetingManager::hideScreenShare() const {
    return m_hideScreenShare;
}

void MeetingManager::setHideScreenShare(bool hideScreenShare) {
    if (hideScreenShare != m_hideScreenShare) {
        m_hideScreenShare = hideScreenShare;
        emit hideScreenShareChanged();
    }
}

bool MeetingManager::hideView() const {
    return m_hideView;
}

void MeetingManager::setHideView(bool hideView) {
    if (hideView != m_hideView) {
        m_hideView = hideView;
        emit hideViewChanged();
    }
}

bool MeetingManager::hideWhiteboard() const {
    return m_hideWhiteboard;
}

void MeetingManager::setHideWhiteboard(bool hideWhiteboard) {
    if (hideWhiteboard != m_hideWhiteboard) {
        m_hideWhiteboard = hideWhiteboard;
        emit hideWhiteboardChanged();
    }
}

bool MeetingManager::autoStartMode() const {
    return m_autoStartMode;
}

void MeetingManager::setAutoStartMode(bool autoStartMode) {
    m_autoStartMode = autoStartMode;
    emit autoStartModeChanged();
}

bool MeetingManager::showMeetingDuration() const {
    return m_showMeetingDuration;
}

void MeetingManager::setShowMeetingDuration(bool showMeetingDuration) {
    m_showMeetingDuration = showMeetingDuration;
    emit showMeetingDurationChanged();
}

qint64 MeetingManager::meetingDuration() const {
    return m_uMeetingDuration;
}

void MeetingManager::setMeetingDuration(qint64 /*duration*/) {
    if (m_durationTimer.isActive()) {
        m_durationTimer.stop();

        m_uMeetingDuration = 0;
        emit meetingDurationChanged();
        m_uMeetingStartTime = 0;
    }
}

bool MeetingManager::showMemberTag() const {
    return m_bshowMemberTag;
}

void MeetingManager::setShowMemberTag(bool showMemberTag) {
    m_bshowMemberTag = showMemberTag;
    emit showMemberTagChanged();
}

QString MeetingManager::nickname() const {
    //    if (m_meetingService && m_meetingService->getCurrentRoomInfo()) {
    //        auto myUserInfo = m_inMeetingService->getMyUserInfo();
    //        if (myUserInfo) {
    //            return QString::fromStdString(myUserInfo->getDisplayName());
    //        }
    //    }
    return "";
}

void MeetingManager::setNickname(const QString& nickname) {
    m_userNickname = nickname;
    emit nicknameChanged();
}

QString MeetingManager::prettyMeetingId() const {
    return m_prettyMeetingId;
}

void MeetingManager::setPrettyMeetingId(const QString& prettyMeetingId) {
    m_prettyMeetingId = prettyMeetingId;
    emit prettyMeetingIdChanged();
}

bool MeetingManager::meetingLocked() const {
    return m_meetingLocked;
}

void MeetingManager::setMeetingLocked(bool meetingLocked) {
    if (m_meetingLocked != meetingLocked) {
        m_meetingLocked = meetingLocked;
        m_meetingController->updateIsLock(meetingLocked);
        emit meetingLockedChanged();
    }
}

bool MeetingManager::meetingMuted() const {
    return m_meetingMuted;
}

void MeetingManager::setMeetingMuted(bool meetingMuted) {
    if (meetingMuted) {
        m_meetingMuteCount++;
    } else {
        m_meetingMuteCount = 0;
    }

    if (m_meetingMuted != meetingMuted) {
        m_meetingMuted = meetingMuted;
        emit muteStatusNotify(meetingMuted);
        emit meetingMutedChanged();
    }
}

bool MeetingManager::meetingVideoMuted() const {
    return m_meetingVideoMuted;
}

void MeetingManager::setMeetingVideoMuted(bool mute) {
    if (m_meetingVideoMuted != mute) {
        m_meetingVideoMuted = mute;
        emit muteStatusNotify(mute, false);
        emit meetingVideoMutedChanged();
    }
}

QString MeetingManager::meetingId() const {
    return m_meetingId;
}

void MeetingManager::setMeetingId(const QString& meetingId) {
    m_meetingId = meetingId;
    emit meetingIdChanged();

    QString prettyMeeting = meetingId.mid(0, 3).append("-").append(meetingId.mid(3, 3)).append("-").append(meetingId.mid(6));
    setPrettyMeetingId(prettyMeeting);
}

QString MeetingManager::shortMeetingNum() const {
    return m_shortMeetingNum;
}

void MeetingManager::setShortMeetingNum(const QString& meetingId) {
    m_shortMeetingNum = meetingId;
    emit shortMeetingNumChanged();
}

int MeetingManager::joinTimeout() const {
    return m_joinTimeout;
}

void MeetingManager::setJoinTimeout(int joinTimeout) {
    if (m_joinTimeout != joinTimeout) {
        m_joinTimeout = joinTimeout;
        emit joinTimeoutChanged(m_joinTimeout);
    }
}

bool MeetingManager::hideSip() const {
    return m_hideSip;
}

void MeetingManager::setHideSip(bool hideSip) {
    if (hideSip != m_hideSip) {
        m_hideSip = hideSip;
    }
}

int MeetingManager::maxCount() const {
    return m_nMaxCount;
}

void MeetingManager::setRemainingSeconds(qint64 remainingSeconds) {
    m_uRemainingSeconds = remainingSeconds;
    emit remainingSecondsChanged();
}

void MeetingManager::setMeetingInviteUrl(const QString& meetingInviteUrl) {
    m_meetingInviteUrl = meetingInviteUrl;
    emit meetingInviteUrlChanged();
}

void MeetingManager::setMaxCount(const QString& extraData) {
    YXLOG(Info) << "setMaxCount, extraData:" << extraData.toStdString() << YXLOGEnd;
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(extraData.toUtf8(), &err);
    if (err.error != QJsonParseError::NoError)
        return;

    QJsonObject obj = doc.object();
    if (obj.contains("maxCount")) {
        int temp = obj["maxCount"].toInt();
        if (temp > 0) {
            m_nMaxCount = temp;
            YXLOG(Info) << "setMaxCount, m_nMaxCount:" << m_nMaxCount << YXLOGEnd;
        }
    }
}

void MeetingManager::onRtcStats(const NERoomRtcStats& stats) {
    QJsonObject obj;
    obj["downRtt"] = stats.downRtt;
    obj["txPacketLossRate"] =
        (NEMeeting::DEVICE_ENABLED == VideoManager::getInstance()->localVideoStatus() || ShareManager::getInstance()->ownerSharing())
            ? stats.txVideoPacketLossRate
            : stats.txAudioPacketLossRate;
    obj["rxPacketLossRate"] = MembersManager::getInstance()->isOpenRemoteVideo() ? stats.rxVideoPacketLossRate : stats.rxAudioPacketLossRate;
    setRtcState(obj);
}

const QJsonObject& MeetingManager::rtcState() const {
    return m_rtcState;
}

void MeetingManager::setRtcState(const QJsonObject& newRtcState) {
    if (m_rtcState == newRtcState)
        return;
    m_rtcState = newRtcState;
    emit rtcStateChanged();
}
