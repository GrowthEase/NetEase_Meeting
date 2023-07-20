// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETINGMANAGER_H
#define MEETINGMANAGER_H

#include <QObject>
#include "controller/chat_ctrl_interface.h"
#include "controller/live_ctrl_interface.h"
#include "controller/meeting_controller.h"
#include "controller/rtc_ctrl_interface.h"
#include "controller/whiteboard_ctrl_interface.h"
#include "room_service_interface.h"

#include "controller/subscribe_helper.h"
#include "utils/invoker.h"

using namespace neroom;

namespace neroom {}  // namespace neroom

typedef struct tagAutoStartInfo {
    bool isCreate;
    QString meetingId;
    QString nickname;
    bool audio;
    bool video;
    bool hideInvitation;
} AutoStartInfo;

class NEMeeting : public QObject {
    Q_GADGET
public:
    explicit NEMeeting() {}
    enum Status {
        MEETING_IDLE,
        MEETING_CONNECTING,
        MEETING_WAITING_VERIFY_PASSWORD,
        MEETING_PREPARING,
        MEETING_PREPARED,
        MEETING_CONNECTED,
        MEETING_RECONNECTED,
        MEETING_RECONNECT_FAILED,
        MEETING_CONNECT_FAILED,
        MEETING_DISCONNECTED,
        MEETING_KICKOUT_BY_HOST,
        MEETING_MULTI_SPOT_LOGIN,
        MEETING_ENDED,
        MEETING_CMD_CHANNEL_DISCONNECTED,
    };
    Q_ENUM(Status)

    enum ExtCode { EXT_DEFAULT, EXT_CODE_KICKOUTED_BY_HOST, EXT_CODE_MEETING_FINISHED, EXT_CODE_FAILED_TO_RELOGIN };
    Q_ENUM(ExtCode)

    enum DeviceStatus { DEVICE_ENABLED = 1, DEVICE_DISABLED_BY_DELF, DEVICE_DISABLED_BY_HOST, DEVICE_NEEDS_TO_CONFIRM };
    Q_ENUM(DeviceStatus)

    enum NetWorkQualityType { NETWORKQUALITY_GOOD = 0, NETWORKQUALITY_GENERAL, NETWORKQUALITY_BAD, NETWORKQUALITY_UNKNOWN };
    Q_ENUM(NetWorkQualityType)

    enum MeetingIdDisplayOptions { DISPLAY_SHORT_ID_ONLY, DISPLAY_LONG_ID_ONLY, DISPLAY_ALL };
    Q_ENUM(MeetingIdDisplayOptions)

    enum HandsUpStatus { HAND_STATUS_RAISE = 1, HAND_STATUS_DOWN, HAND_STATUS_AGREE, HAND_STATUS_REJECT };
    Q_ENUM(HandsUpStatus)

    enum HandsUpType { HAND_TYPE_DEFAULT, HAND_TYPE_AUDIO, HAND_TYPE_VIDEO };
    Q_ENUM(HandsUpType)
};

Q_DECLARE_METATYPE(NEMeeting::Status)

class MeetingManager : public QObject {
    Q_OBJECT

private:
    MeetingManager(QObject* parent = nullptr);

public:
    SINGLETONG(MeetingManager)
    Q_PROPERTY(QString meetingUniqueId READ meetingUniqueId WRITE setMeetingUniqueId NOTIFY meetingUniqueIdChanged)
    Q_PROPERTY(QString shortMeetingNum READ shortMeetingNum WRITE setShortMeetingNum NOTIFY shortMeetingNumChanged)
    Q_PROPERTY(QString meetingId READ meetingId WRITE setMeetingId NOTIFY meetingIdChanged)
    Q_PROPERTY(QString meetingTopic READ meetingTopic WRITE setMeetingTopic NOTIFY meetingTopicChanged)
    Q_PROPERTY(QString meetingPassword READ meetingPassword WRITE setMeetingPassword NOTIFY meetingPasswordChanged)
    Q_PROPERTY(QString meetingSIPChannelId READ meetingSIPChannelId WRITE setMeetingSIPChannelId NOTIFY meetingSIPChannelIdChanged)
    Q_PROPERTY(QString prettyMeetingId READ prettyMeetingId WRITE setPrettyMeetingId NOTIFY prettyMeetingIdChanged)
    Q_PROPERTY(
        quint64 meetingSchdeuleStarttime READ meetingSchdeuleStarttime WRITE setMeetingSchdeuleStarttime NOTIFY meetingSchdeuleStarttimeChanged)
    Q_PROPERTY(quint64 meetingSchdeuleEndtime READ meetingSchdeuleEndtime WRITE setMeetingSchdeuleEndtime NOTIFY meetingSchdeuleEndtimeChanged)
    Q_PROPERTY(bool meetingMuted READ meetingMuted WRITE setMeetingMuted NOTIFY meetingMutedChanged)
    Q_PROPERTY(bool meetingLocked READ meetingLocked WRITE setMeetingLocked NOTIFY meetingLockedChanged)
    Q_PROPERTY(bool showMeetingDuration READ showMeetingDuration WRITE setShowMeetingDuration NOTIFY showMeetingDurationChanged)
    Q_PROPERTY(qint64 meetingDuration READ meetingDuration WRITE setMeetingDuration NOTIFY meetingDurationChanged)
    Q_PROPERTY(qint64 remainingSeconds READ remainingSeconds WRITE setRemainingSeconds NOTIFY remainingSecondsChanged)
    Q_PROPERTY(QString nickname READ nickname WRITE setNickname NOTIFY nicknameChanged)
    Q_PROPERTY(bool autoStartMode READ autoStartMode WRITE setAutoStartMode NOTIFY autoStartModeChanged)
    Q_PROPERTY(bool hideInvitation READ hideInvitation WRITE setHideInvitation NOTIFY hideInvitationChanged)
    Q_PROPERTY(bool hideChatroom READ hideChatroom WRITE setHideChatroom NOTIFY hideChatroomChanged)
    Q_PROPERTY(NEMeeting::MeetingIdDisplayOptions meetingIdDisplayOption READ meetingIdDisplayOption WRITE setMeetingIdDisplayOption NOTIFY
                   meetingIdDisplayOptionChanged)
    Q_PROPERTY(bool hideScreenShare READ hideScreenShare WRITE setHideScreenShare NOTIFY hideScreenShareChanged)
    Q_PROPERTY(bool hideView READ hideView WRITE setHideView NOTIFY hideViewChanged)
    Q_PROPERTY(bool hideWhiteboard READ hideWhiteboard WRITE setHideWhiteboard NOTIFY hideWhiteboardChanged)
    Q_PROPERTY(bool reName READ reName WRITE setReName NOTIFY reNameChanged)
    Q_PROPERTY(bool enableRecord READ enableRecord WRITE setEnableRecord NOTIFY enableRecordChanged)
    Q_PROPERTY(int meetingMuteCount READ meetingMuteCount)
    Q_PROPERTY(int joinTimeout READ joinTimeout WRITE setJoinTimeout NOTIFY joinTimeoutChanged)
    Q_PROPERTY(bool meetingAllowSelfAudioOn READ meetingAllowSelfAudioOn WRITE setMeetingAllowSelfAudioOn NOTIFY meetingAllowSelfAudioOnChanged)
    Q_PROPERTY(bool meetingAllowSelfVideoOn READ meetingAllowSelfVideoOn WRITE setMeetingAllowSelfVideoOn NOTIFY meetingAllowSelfVideoOnChanged)
    Q_PROPERTY(bool showMemberTag READ showMemberTag WRITE setShowMemberTag NOTIFY showMemberTagChanged)
    Q_PROPERTY(bool meetingVideoMuted READ meetingVideoMuted WRITE setMeetingVideoMuted NOTIFY meetingVideoMutedChanged)
    Q_PROPERTY(int maxCount READ maxCount CONSTANT)
    Q_PROPERTY(NEMeeting::Status roomStatus READ roomStatus NOTIFY roomStatusChanged)
    Q_PROPERTY(bool hideMuteAllVideo READ hideMuteAllVideo WRITE setHideMuteAllVideo NOTIFY hideMuteAllVideoChanged)
    Q_PROPERTY(bool hideMuteAllAudio READ hideMuteAllAudio WRITE setHideMuteAllAudio NOTIFY hideMuteAllAudioChanged)
    Q_PROPERTY(bool enableFileMessage READ enableFileMessage WRITE setEnableFileMessage NOTIFY enableFileMessageChanged)
    Q_PROPERTY(bool enableImageMessage READ enableImageMessage WRITE setEnableImageMessage NOTIFY enableImageMessageChanged)
    Q_PROPERTY(QString meetingInviteUrl READ meetingInviteUrl WRITE setMeetingInviteUrl NOTIFY meetingInviteUrlChanged)
    Q_PROPERTY(QJsonObject rtcState READ rtcState WRITE setRtcState NOTIFY rtcStateChanged)

    Q_INVOKABLE bool autoStartMeeting();
    // 输入密码入会
    Q_INVOKABLE void joinMeeting(const QString& strPassword);
    Q_INVOKABLE void cancelJoinMeeting();
    Q_INVOKABLE NEMeeting::Status getRoomStatus() const;
    Q_INVOKABLE void modifyNicknameInMeeting(const QString& newnickname, const QString& meetingID);
    Q_INVOKABLE void activeMainWindow() const;

    void onIdle();
    void onConnecting();
    void onConnected();
    void onDisconnected(int reason);
    void onConnectFail(int reason);
    void onReConnecting();
    void onReConnected();
    void onReConnectFail();

    void startJoinTimer();

    void onRoomStatusChanged(NEMeeting::Status status, int errorCode = 0);
    void onError(uint32_t errorCode, const std::string& errorMessage);

    bool createMeeting(const nem_sdk_interface::NEStartMeetingParams& param, const NERoomOptions& option);
    bool joinMeeting(const nem_sdk_interface::NEJoinMeetingParams& param, const NERoomOptions& option);
    void activeMeetingWindow(bool bRaise);
    void setShowMeetingRemainingTip(bool show) { m_showMeetingRemainingTip = show; }

    bool initialize();
    void release();
    NERoomInfo getMeetingInfo() const;
    INERoomContext* getRoomContext();
    INERoomWhiteboardController* getWhiteboardController() const;
    std::shared_ptr<NEMeetingController> getMeetingController() const;
    INERoomChatController* getInRoomChatController() const;
    INERoomRtcController* getInRoomRtcController() const;
    INERoomLiveController* getLiveController() const;
    std::shared_ptr<SubscribeHelper> getSubscribeHelper() const;

    void setStartMeetingInfo(bool isCreate, const QString& meetingId, const QString& nickname, bool audio, bool video, bool hideInvitation);

    void onRoomLockStatusChanged(bool isLock);
    void onRoomMuteStatusChanged(bool muted);
    void onRoomMuteAllVideoStatusChanged(bool muted);
    void onRoomMuteNeedHandsUpChanged(bool bNeedHandsUp);
    void onRoomMuteVideoNeedHandsUpChanged(bool bNeedHandsUp);
    void onRoomSIPChannelIdChanged(const std::string /*sipChannelId*/) {}
    void onRoomStartTimeChanged(uint64_t startTime);
    void onRtcStats(const NERoomRtcStats& stats);

    QString meetingUniqueId() const;
    void setMeetingUniqueId(const QString& meetingUniqueId);

    QString meetingId() const;
    void setMeetingId(const QString& meetingId);

    QString shortMeetingNum() const;
    void setShortMeetingNum(const QString& meetingId);

    bool meetingMuted() const;
    void setMeetingMuted(bool meetingMuted);

    bool meetingVideoMuted() const;
    void setMeetingVideoMuted(bool mute);

    bool meetingLocked() const;
    void setMeetingLocked(bool meetingLocked);

    QString prettyMeetingId() const;
    void setPrettyMeetingId(const QString& prettyMeetingId);

    bool showMeetingDuration() const;
    void setShowMeetingDuration(bool showMeetingDuration);

    qint64 meetingDuration() const;
    void setMeetingDuration(qint64 duration);

    bool showMemberTag() const;
    void setShowMemberTag(bool showMemberTag);

    QString nickname() const;
    void setNickname(const QString& nickname);

    bool autoStartMode() const;
    void setAutoStartMode(bool autoStartMode);

    bool hideInvitation() const;
    void setHideInvitation(bool hideInvitation);

    bool hideChatroom() const;
    void setHideChatroom(bool hideChatroom);

    bool hideMuteAllVideo() const;
    void setHideMuteAllVideo(bool hideMuteAllVideo);

    bool hideMuteAllAudio() const;
    void setHideMuteAllAudio(bool hideMuteAllAudio);

    bool enableFileMessage() const;
    void setEnableFileMessage(bool enableFileMessage);

    bool enableImageMessage() const;
    void setEnableImageMessage(bool enableImageMessage);

    QString meetingTopic() const;
    void setMeetingTopic(const QString& meetingTopic);

    QString meetingPassword() const;
    void setMeetingPassword(const QString& meetingPassword);

    QString meetingSIPChannelId() const;
    void setMeetingSIPChannelId(const QString& meetingSIPChannelId);

    quint64 meetingSchdeuleStarttime();
    void setMeetingSchdeuleStarttime(quint64 start);

    quint64 meetingSchdeuleEndtime();
    void setMeetingSchdeuleEndtime(quint64 end);

    NEMeeting::MeetingIdDisplayOptions meetingIdDisplayOption() const;
    void setMeetingIdDisplayOption(const NEMeeting::MeetingIdDisplayOptions& meetingIdDisplayOption);
    bool meetingAllowSelfAudioOn() const;
    void setMeetingAllowSelfAudioOn(bool bHandsUp);

    bool meetingAllowSelfVideoOn() const;
    void setMeetingAllowSelfVideoOn(bool bHandsUp);

    bool hideScreenShare() const;
    void setHideScreenShare(bool hideScreenShare);

    bool hideView() const;
    void setHideView(bool hideView);

    bool hideWhiteboard() const;
    void setHideWhiteboard(bool hideWhiteboard);

    bool reName() const;
    void setReName(bool reName);

    bool enableRecord() const;
    void setEnableRecord(bool enableRecord);

    int meetingMuteCount() const { return m_meetingMuteCount; }

    int joinTimeout() const;
    void setJoinTimeout(int joinTimeout);

    Q_INVOKABLE bool hideSip() const;
    void setHideSip(bool hideSip);

    int maxCount() const;
    NEMeeting::Status roomStatus() const { return getRoomStatus(); }

    void setRemainingSeconds(qint64 remainingSeconds);
    qint64 remainingSeconds() const { return m_uRemainingSeconds; }

    QString meetingInviteUrl() const { return m_meetingInviteUrl; }
    void setMeetingInviteUrl(const QString& meetingInviteUrl);

    const QJsonObject& rtcState() const;
    void setRtcState(const QJsonObject& newRtcState);

signals:
    void error(int errorCode, const QString& errorMessage);
    void activeWindow(bool bRaise);
    void meetingStatusChanged(NEMeeting::Status status, int errorCode, const QString& errorMessage = "");

    // Members signals
    void userJoined(const std::vector<std::string>& member_ids);
    void userLeft(const std::vector<std::string>& member_ids);

    // Binding values
    void meetingUniqueIdChanged();
    void shortMeetingNumChanged();
    void meetingIdChanged();
    void meetingTopicChanged();
    void meetingPasswordChanged();
    void meetingSIPChannelIdChanged();
    void meetingSchdeuleStarttimeChanged();
    void meetingSchdeuleEndtimeChanged();
    void meetingMutedChanged();
    void meetingVideoMutedChanged();
    void meetingLockedChanged();
    void prettyMeetingIdChanged();
    void showMeetingDurationChanged();
    void showMemberTagChanged();
    void meetingDurationChanged();
    void remainingSecondsChanged();
    void nicknameChanged();
    void autoStartModeChanged();
    void hideInvitationChanged();
    void hideChatroomChanged();
    void hideMuteAllVideoChanged();
    void hideMuteAllAudioChanged();
    void hideScreenShareChanged();
    void hideViewChanged();
    void meetingIdDisplayOptionChanged();
    void hideWhiteboardChanged();
    void meetingAllowSelfAudioOnChanged();
    void meetingAllowSelfVideoOnChanged();
    void reNameChanged();
    void enableRecordChanged();
    void joinTimeoutChanged(int joinTimeout);
    // Notifications
    void lockStatusNotify(bool locked);
    void muteStatusNotify(bool muted, bool audio = true);
    void hostChangedNotify(const QString& changedAccountId);

    void modifyNicknameResult(bool success);
    void roomStatusChanged(NEMeeting::Status roomStatus);

    void enableFileMessageChanged();
    void enableImageMessageChanged();

    void meetingInviteUrlChanged();

    void rtcStateChanged();

public slots:
    void lockMeeting(bool lock);
    void leaveMeeting(bool finish, const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool isInMeeting();

private:
    void setMaxCount(const QString& extraData);

private:
    std::shared_ptr<NEMeetingController> m_meetingController = nullptr;
    QTimer m_durationTimer;
    QTimer m_remainingTipTimer;
    QString m_shortMeetingNum = "";
    QString m_meetingUniqueId;
    QString m_meetingId;
    QString m_meetingTopic;
    QString m_meetingPassword;
    QString m_meetingSIPChannelId;
    quint64 m_meetingScheduleStarttime = 0;
    quint64 m_meetingScheduleEndtime = 0;
    bool m_meetingMuted = false;
    bool m_meetingLocked = false;
    bool m_meetingAllowSelfAudioOn = false;
    bool m_meetingAllowSelfVideoOn = false;
    bool m_showMeetingDuration = true;
    qint64 m_uMeetingDuration = 0;
    qint64 m_uMeetingStartTime = 0;
    qint64 m_uRemainingSeconds = 0;
    bool m_hideInvitation = false;
    bool m_hideChatroom = false;
    bool m_hideScreenShare = true;     // 是否显示共享屏幕
    bool m_hideView = true;            // 是否显示视图切换
    bool m_hideWhiteboard = false;     // 是否显示共享白板
    bool m_hideSip = false;            // 是否显示SIP
    bool m_reName = true;              // 是否支持会中改名
    bool m_enableRecord = false;       // 是否显示"录制中"状态
    bool m_hideMuteAllVideo = true;    // 是否显示"全体关闭/打开视频"按钮
    bool m_hideMuteAllAudio = false;   // 是否显示"全体静音"按钮
    bool m_enableFileMessage = true;   // 是否支持"聊天室文件消息"
    bool m_enableImageMessage = true;  // 是否支持"聊天室图片消息"
    QString m_prettyMeetingId;
    QString m_userNickname = "";
    Invoker m_invoker;
    AutoStartInfo m_autoStartInfo;
    bool m_autoStartMode = false;
    NEMeeting::MeetingIdDisplayOptions m_meetingIdDisplayOption = NEMeeting::DISPLAY_ALL;

    int m_meetingMuteCount = 0;

    // 需要密码时缓存一下登录信息
    nem_sdk_interface::NEJoinMeetingParams m_joinRoomParams;
    NERoomOptions m_joinRoomOptions;
    NEMeeting::Status m_meetingStatus = NEMeeting::MEETING_IDLE;
    int m_joinTimeout = 45 * 1000;
    QTimer m_joinTimeoutTimer;

    bool m_bshowMemberTag = false;
    int m_nMaxCount = -1;

    bool m_meetingVideoMuted = false;

    bool m_noVideo = true;
    bool m_noAudio = true;

    std::shared_ptr<SubscribeHelper> m_subscribeHelper = nullptr;
    bool m_showMeetingRemainingTip = false;
    QString m_meetingInviteUrl;
    QJsonObject m_rtcState;
};

#endif  // MEETINGMANAGER_H
