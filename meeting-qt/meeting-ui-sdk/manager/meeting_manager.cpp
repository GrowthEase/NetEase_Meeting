/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "meeting_manager.h"
#include "controller/beauty_ctrl_interface.h"
#include "controller/chat_ctrl_interface.h"
#include "controller/livestream_ctrl_interface.h"
#include "controller/record_ctrl_interface.h"
#include "controller/video_ctrl_interface.h"
#include "controller/whiteboard_ctrl_interface.h"
#include "global_manager.h"
#include "listeners/meeting_service_listener.h"
#include "listeners/meeting_stats_listener.h"
#include "manager/chat_manager.h"
#include "manager/config_manager.h"
#include "manager/device_manager.h"
#include "manager/live_manager.h"
#include "manager/meeting/whiteboard_manager.h"
#include "manager/more_item_manager.h"
#include "meeting/members_manager.h"
#include "meeting/share_manager.h"
#include "meeting/video_manager.h"
#include "settings_manager.h"

MeetingManager::MeetingManager(QObject* parent)
    : QObject(parent) {
    qRegisterMetaType<NEMeeting::Status>();

    m_durationTimer.setTimerType(Qt::PreciseTimer);
    m_durationTimer.setInterval(1000);
    m_durationTimer.callOnTimeout([this]() {
        auto currenttime = std::chrono::time_point_cast<std::chrono::seconds>(std::chrono::system_clock::now()).time_since_epoch().count();
        m_uMeetingDuration = (currenttime - m_uMeetingStartTime) + m_uMeetingDurationEx;
        emit meetingDurationChanged();
    });

    qmlRegisterUncreatableType<NEMeeting>("NetEase.Meeting.MeetingStatus", 1, 0, "MeetingStatus", "");
    setShowMeetingDuration(ConfigManager::getInstance()->getValue("localShowtime", false).toBool());
}

bool MeetingManager::autoStartMeeting() {
    YXLOG(Info) << "Auto start meeting with command line params." << YXLOGEnd;

    MoreItemManager::getInstance()->restoreToolbar();
    if (m_autoStartInfo.isCreate) {
        NEStartRoomParams param;
        NEStartRoomOptions option;
        QByteArray byteMeetingId = m_autoStartInfo.meetingId.toUtf8();
        QByteArray byteNickname = m_autoStartInfo.nickname.toUtf8();
        param.roomId = byteMeetingId.data();
        param.displayName = byteNickname.data();
        option.noAudio = !m_autoStartInfo.audio;
        option.noVideo = !m_autoStartInfo.video;
        createMeeting(param, option);
    } else {
        NEJoinRoomParams param;
        NEJoinRoomOptions option;
        QByteArray byteMeetingId = m_autoStartInfo.meetingId.toUtf8();
        QByteArray byteNickname = m_autoStartInfo.nickname.toUtf8();
        param.roomId = byteMeetingId.data();
        param.displayName = byteNickname.data();
        option.noAudio = !m_autoStartInfo.audio;
        option.noVideo = !m_autoStartInfo.video;
        joinMeeting(param, option);
    }

    return true;
}

neroom::NEErrorCode MeetingManager::createMeeting(const NEStartRoomParams& param, const NEStartRoomOptions& option) {
    return m_meetingService->startRoom(param, option, [=](int errorCode, const std::string& errorMessage) {
        if (errorCode != 200 && errorCode != 0) {
            emit meetingStatusChanged(NEMeeting::MEETING_CONNECT_FAILED, errorCode, QString::fromStdString(errorMessage));
        }
    });
}

void MeetingManager::cancelJoinMeeting() {
    YXLOG(Info) << "CancelJoinMeeting." << YXLOGEnd;
    emit meetingStatusChanged(NEMeeting::MEETING_CONNECT_FAILED, -1);
}

void MeetingManager::joinMeeting(const QString& strPassword) {
    YXLOG(Info) << "joinMeeting by input password." << YXLOGEnd;
    m_joinRoomParams.password = strPassword.toStdString();
    joinMeeting(m_joinRoomParams, m_joinRoomOptions);
}

neroom::NEErrorCode MeetingManager::joinMeeting(const NEJoinRoomParams& param, const NEJoinRoomOptions& option) {
    m_joinRoomParams = param;
    m_joinRoomOptions = option;
    return m_meetingService->joinRoom(param, option, [=](int errorCode, const std::string& errorMessage) {
        if (errorCode == kErrorPassword || errorCode == kErrorPasswordNotPresent) {
            emit meetingStatusChanged(NEMeeting::MEETING_WAITING_VERIFY_PASSWORD, errorCode, QString::fromStdString(errorMessage));
        } else if (errorCode != 200 && errorCode != 0) {
            emit meetingStatusChanged(NEMeeting::MEETING_CONNECT_FAILED, errorCode, QString::fromStdString(errorMessage));
        }
    });
}

NEMeeting::Status MeetingManager::getRoomStatus() const {
    return m_meetingStatus;
}

void MeetingManager::modifyNicknameInMeeting(const QString& newnickname, const QString& meetingID) {
    if (m_inMeetingService) {
        m_inMeetingService->getInRoomUserController()->changeMyName(
            newnickname.toStdString(), [this](int errCode, const std::string&) { emit modifyNicknameResult(errCode == 200); });
    }
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

void MeetingManager::onDisconnecting() {
    // dononthing
}

void MeetingManager::onDisconnected(int reason) {
    if (reason == kReasonLeaveBySelf || reason == kReasonCloseBySelf) {
        onRoomStatusChanged(NEMeeting::MEETING_ENDED, 0);
    } else {
        onRoomStatusChanged(NEMeeting::MEETING_DISCONNECTED, reason);
    }
}

void MeetingManager::onConnectFail(int reason) {
    onRoomStatusChanged(NEMeeting::MEETING_DISCONNECTED, reason);
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

void MeetingManager::activeMeetingWindow() {
    if (!m_meetingService)
        return;
    if (m_meetingStatus != NEMeeting::MEETING_CONNECTED && m_meetingStatus != NEMeeting::MEETING_WAITING_VERIFY_PASSWORD)
        return;
    YXLOG(Info) << "Active meeting window on top of others windows." << YXLOGEnd;
    emit activeWindow();
}

bool MeetingManager::initialize() {
    m_meetingService = GlobalManager::getInstance()->getRoomService();
    if (m_meetingService == nullptr)
        return false;
    m_meetingService->addRoomLifeCycleListener(this);

    m_inMeetingService = GlobalManager::getInstance()->getInRoomService();
    if (m_inMeetingService == nullptr)
        return false;

    m_inMeetingServiceListener = new NEInRoomServiceListener;
    m_inMeetingService->addListener(m_inMeetingServiceListener);

    m_rtcRtcStatsEventListener = new NERtcStatsEventListener;
    m_inMeetingService->addRtcStatsEventListener(m_rtcRtcStatsEventListener);
    return true;
}

void MeetingManager::release() {
    if (!m_meetingService) {
        return;
    }
    m_meetingService->removeRoomLifeCycleListener(this);

    if (m_inMeetingServiceListener) {
        delete m_inMeetingServiceListener;
        m_inMeetingServiceListener = nullptr;
        m_inMeetingService->removeListener(nullptr);
    }

    if (m_rtcRtcStatsEventListener) {
        delete m_rtcRtcStatsEventListener;
        m_rtcRtcStatsEventListener = nullptr;
        m_inMeetingService->removeRtcStatsEventListener(nullptr);
    }
}

INERoomInfo* MeetingManager::getMeetingInfo() {
    return m_meetingService->getCurrentRoomInfo();
}

INEInRoomAudioController* MeetingManager::getInRoomAudioController() const {
    if (m_inMeetingService)
        return m_inMeetingService->getInRoomAudioController();

    return nullptr;
}

INERoomUserController* MeetingManager::getUserController() const {
    if (m_inMeetingService)
        return m_inMeetingService->getInRoomUserController();

    return nullptr;
}

INEInRoomVideoController* MeetingManager::getInRoomVideoController() const {
    if (m_inMeetingService)
        return m_inMeetingService->getInRoomVideoController();

    return nullptr;
}

INEScreenShareController* MeetingManager::getScreenShareController() const {
    if (m_inMeetingService)
        return m_inMeetingService->getScreenShareController();

    return nullptr;
}

INERoomLivingController* MeetingManager::getLivingController() const {
    if (m_inMeetingService)
        return m_inMeetingService->getInRoomLiveStreamController();

    return nullptr;
}

INERoomWhiteboardController* MeetingManager::getWhiteboardController() const {
    if (m_inMeetingService)
        return m_inMeetingService->getWhiteboardController();

    return nullptr;
}

INEInRoomBeautyController* MeetingManager::getInRoomBeautyController() const {
    if (m_inMeetingService)
        return m_inMeetingService->getInRoomBeautyController();

    return nullptr;
}

INERoomChatController* MeetingManager::getInRoomChatController() const {
    if (m_inMeetingService)
        return m_inMeetingService->getInRoomChatController();

    return nullptr;
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
        if (status == NEMeeting::MEETING_CONNECTED) {
            auto congigSvr = GlobalManager::getInstance()->getGlobalConfig();
            bool beautySupport = false;
            if (congigSvr != nullptr) {
                beautySupport = congigSvr->isBeautySupported();
                MoreItemManager::getInstance()->setBeautyVisible(beautySupport);
            }

            auto meetingInfo = m_meetingService->getCurrentRoomInfo();
            if (meetingInfo != nullptr) {
                auto beautyController = m_inMeetingService->getInRoomBeautyController();

                if(beautyController) {
                    beautyController->enableBeauty(beautySupport && beautyController->getBeautyFaceValue() > 0);
                }

                setMeetingUniqueId(QString::fromStdString(meetingInfo->getRoomUniqueId()));
                setMeetingId(QString::fromStdString(meetingInfo->getRoomId()));
                setShortMeetingId(QString::fromStdString(meetingInfo->getShortRoomId()));
                setMeetingTopic(QString::fromStdString(meetingInfo->getSubject()));
                setMeetingPassword(QString::fromStdString(meetingInfo->getPassword()));
                setMeetingSIPChannelId(QString::fromStdString(meetingInfo->getSIPId()));
                MembersManager::getInstance()->setHostAccountId(
                    QString::fromStdString(meetingInfo->getHostUserId()));  //主持人设置提前，避免设置静音等逻辑出现找不到主持人的异常
                setMeetingMuted(meetingInfo->getAudioAllMute());
                setMeetingAllowSelfAudioOn(m_inMeetingService->isParticipantsUnmuteSelfAllowed());
                setNickname(QString::fromStdString(m_inMeetingService->getMyUserInfo()->getDisplayName()));
                setMeetingSchdeuleStarttime(meetingInfo->getSheduleStartTime());
                setMeetingSchdeuleEndtime(meetingInfo->getSheduleEndTime());
                setMeetingLocked(meetingInfo->getLocked());
                auto recordController = m_inMeetingService->getInRoomRecordController();
                if (nullptr != recordController) {
                    setEnableRecord(recordController->isCloudRecordEnabled());
                }

                if (meetingInfo->getLiveStreamInfo().enable) {
                    LiveManager::getInstance()->initLiveStreamStatus(meetingInfo->getLiveStreamInfo().state);
                }
                ChatManager::getInstance()->setChatRoomOpen(true);
                VideoManager::getInstance()->setFocusAccountId(QString::fromStdString(meetingInfo->getPinnedUserId()));
                ShareManager::getInstance()->setShareAccountId(QString::fromStdString(meetingInfo->getScreenSharingUserId()));
                ShareManager::getInstance()->setPaused(false);
                WhiteboardManager::getInstance()->onWhiteboardInitStatus();
            }
        } else if (status == NEMeeting::MEETING_PREPARED) {
            DeviceManager::getInstance()->getCaptureDevices();
            DeviceManager::getInstance()->getPlayoutDevices();
            DeviceManager::getInstance()->getRecordDevices();
        } else if (status == NEMeeting::MEETING_ENDED || status == NEMeeting::MEETING_DISCONNECTED || status == NEMeeting::MEETING_CONNECT_FAILED) {
            auto beautyController = m_inMeetingService->getInRoomBeautyController();
            if (nullptr != beautyController) {
                beautyController->enableBeauty(false);
            }

            setMeetingUniqueId("");
            setMeetingId("");
            setMeetingTopic("");
            setMeetingPassword("");
            setMeetingMuted(false);
            setMeetingLocked(false);
            setMeetingAllowSelfAudioOn(false);
            setMeetingDuration(0);
            setMeetingSchdeuleStarttime(0);
            setMeetingSchdeuleEndtime(0);
            setShortMeetingId("");
            setEnableRecord(false);
            ChatManager::getInstance()->setChatRoomOpen(false);
            MembersManager::getInstance()->setHostAccountId("");
            VideoManager::getInstance()->setFocusAccountId("");
            ShareManager::getInstance()->setShareAccountId("");
            ShareManager::getInstance()->setPaused(false);
            AudioManager::getInstance()->setHandsUpStatus(false);
            auto authInfo = AuthManager::getInstance()->getAuthInfo();
            if (authInfo == nullptr) {
                YXLOG(Info) << "Reset device info after finished meeting." << YXLOGEnd;
                DeviceManager::getInstance()->resetDevicesInfo();
            }
        }
        emit meetingStatusChanged(status, errorCode);
        m_meetingStatus = status;
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

void MeetingManager::onRoomMuteNeedHandsUpChanged(bool bNeedHandsUp) {
    m_invoker.execute([=]() { setMeetingAllowSelfAudioOn(bNeedHandsUp); });
}

void MeetingManager::onRoomDurationChanged(const uint64_t& duration) {
    m_invoker.execute([=]() { m_uMeetingDurationEx = duration; });
}

void MeetingManager::onRoomStartTimeChanged(uint64_t startTime) {
    m_invoker.execute([=]() {
        m_uMeetingStartTime = startTime;
        if (!m_durationTimer.isActive()) {
            m_durationTimer.start();
        }
    });
}

void MeetingManager::onError(uint32_t errorCode, const std::string& errorMessage) {
    m_invoker.execute([=]() { emit error(errorCode, QString::fromStdString(errorMessage)); });
}

QString MeetingManager::meetingUniqueId() const {
    return m_meetingUniqueId;
}

void MeetingManager::setMeetingUniqueId(const QString& meetingUniqueId) {
    m_meetingUniqueId = meetingUniqueId;
    emit meetingUniqueIdChanged();
}

void MeetingManager::lockMeeting(bool lock) {
    m_inMeetingService->lockRoom(lock);
}

void MeetingManager::leaveMeeting(bool finish) {
    YXLOG(Info) << "leaveMeeting, finish =" << finish << YXLOGEnd;
    m_meetingService->leaveCurrentRoom(finish);
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
        m_uMeetingDurationEx = 0;
        m_uMeetingStartTime = 0;
    }
}

QString MeetingManager::nickname() const {
    if (m_meetingService && m_meetingService->getCurrentRoomInfo()) {
        return QString::fromStdString(m_inMeetingService->getMyUserInfo()->getDisplayName());
    }
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
        emit meetingLockedChanged();
    }
}

bool MeetingManager::meetingMuted() const {
    return m_meetingMuted;
}

void MeetingManager::setMeetingMuted(bool meetingMuted) {
    if(meetingMuted) {
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

QString MeetingManager::meetingId() const {
    return m_meetingId;
}

void MeetingManager::setMeetingId(const QString& meetingId) {
    m_meetingId = meetingId;
    emit meetingIdChanged();

    QString prettyMeeting = meetingId.mid(0, 3).append("-").append(meetingId.mid(3, 3)).append("-").append(meetingId.mid(6));
    setPrettyMeetingId(prettyMeeting);
}

QString MeetingManager::shortMeetingId() const {
    return m_shortMeetingId;
}

void MeetingManager::setShortMeetingId(const QString& meetingId) {
    m_shortMeetingId = meetingId;
    emit shortMeetingIdChanged();
}
