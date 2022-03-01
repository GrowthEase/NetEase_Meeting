/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef MEETINGMANAGER_H
#define MEETINGMANAGER_H

#include <QObject>
#include "controller/beauty_ctrl_interface.h"
#include "controller/chat_ctrl_interface.h"
#include "controller/livestream_ctrl_interface.h"
#include "controller/user_ctrl_interface.h"
#include "controller/whiteboard_ctrl_interface.h"
#include "in_room_service_interface.h"
#include "in_room_stats_listener.h"
#include "room_service_interface.h"
#include "room_service_listener.h"

#include "utils/invoker.h"

using namespace neroom;

namespace neroom {

class INERoomInfo;
class INEUserController;
class INEAudioController;
class INEVideoController;
class INEScreenShareController;
class INERoomLivingController;
class INERoomWhiteboardController;
class INEInRoomBeautyController;
class INERoomChatController;

}  // namespace neroom

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

    enum DeviceStatus { DEVICE_ENABLED = kAudioEnabled, DEVICE_DISABLED_BY_DELF, DEVICE_DISABLED_BY_HOST, DEVICE_NEEDS_TO_CONFIRM };
    Q_ENUM(DeviceStatus)

    enum NetWorkQualityType { NETWORKQUALITY_GOOD = 0, NETWORKQUALITY_GENERAL, NETWORKQUALITY_BAD };
    Q_ENUM(NetWorkQualityType)

    enum MeetingIdDisplayOptions { DISPLAY_SHORT_ID_ONLY, DISPLAY_LONG_ID_ONLY, DISPLAY_ALL };
    Q_ENUM(MeetingIdDisplayOptions)

    enum HandsUpStatus { HAND_STATUS_RAISE = kHandsUpRaise, HAND_STATUS_DOWN, HAND_STATUS_AGREE, HAND_STATUS_REJECT };
    Q_ENUM(HandsUpStatus)
};

Q_DECLARE_METATYPE(NEMeeting::Status)

class MeetingManager : public QObject, public INERoomLifeCycleListener {
    Q_OBJECT

private:
    MeetingManager(QObject* parent = nullptr);

public:
    SINGLETONG(MeetingManager)
    Q_PROPERTY(QString meetingUniqueId READ meetingUniqueId WRITE setMeetingUniqueId NOTIFY meetingUniqueIdChanged)
    Q_PROPERTY(QString shortMeetingId READ shortMeetingId WRITE setShortMeetingId NOTIFY shortMeetingIdChanged)
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
    Q_INVOKABLE bool autoStartMeeting();

    // 输入密码入会
    Q_INVOKABLE void joinMeeting(const QString& strPassword);
    Q_INVOKABLE void cancelJoinMeeting();
    Q_INVOKABLE NEMeeting::Status getRoomStatus() const;
    Q_INVOKABLE void modifyNicknameInMeeting(const QString& newnickname, const QString& meetingID);

    virtual void onIdle() override;
    virtual void onConnecting() override;
    virtual void onConnected() override;
    virtual void onDisconnecting() override;
    virtual void onDisconnected(int reason) override;
    virtual void onConnectFail(int reason) override;
    virtual void onReConnecting() override;
    virtual void onReConnected() override;
    virtual void onReConnectFail() override;

    void onRoomStatusChanged(NEMeeting::Status status, int errorCode = 0);
    void onError(uint32_t errorCode, const std::string& errorMessage);

    neroom::NEErrorCode createMeeting(const NEStartRoomParams& param, const NEStartRoomOptions& option);
    neroom::NEErrorCode joinMeeting(const NEJoinRoomParams& param, const NEJoinRoomOptions& option);
    void activeMeetingWindow();

    bool initialize();
    void release();
    INERoomInfo* getMeetingInfo();
    INEInRoomAudioController* getInRoomAudioController() const;
    INEInRoomVideoController* getInRoomVideoController() const;
    INERoomUserController* getUserController() const;
    INEScreenShareController* getScreenShareController() const;
    INERoomLivingController* getLivingController() const;
    INERoomWhiteboardController* getWhiteboardController() const;
    INEInRoomBeautyController* getInRoomBeautyController() const;
    INERoomChatController* getInRoomChatController() const;

    void setStartMeetingInfo(bool isCreate, const QString& meetingId, const QString& nickname, bool audio, bool video, bool hideInvitation);

    void onRoomLockStatusChanged(bool isLock);
    void onRoomMuteStatusChanged(bool muted);
    void onRoomMuteNeedHandsUpChanged(bool bNeedHandsUp);
    void onRoomSIPChannelIdChanged(const std::string /*sipChannelId*/) {}
    void onRoomDurationChanged(const uint64_t& duration);
    void onRoomStartTimeChanged(uint64_t startTime);

    QString meetingUniqueId() const;
    void setMeetingUniqueId(const QString& meetingUniqueId);

    QString meetingId() const;
    void setMeetingId(const QString& meetingId);

    QString shortMeetingId() const;
    void setShortMeetingId(const QString& meetingId);

    bool meetingMuted() const;
    void setMeetingMuted(bool meetingMuted);

    bool meetingLocked() const;
    void setMeetingLocked(bool meetingLocked);

    QString prettyMeetingId() const;
    void setPrettyMeetingId(const QString& prettyMeetingId);

    bool showMeetingDuration() const;
    void setShowMeetingDuration(bool showMeetingDuration);

    qint64 meetingDuration() const;
    void setMeetingDuration(qint64 duration);

    QString nickname() const;
    void setNickname(const QString& nickname);

    bool autoStartMode() const;
    void setAutoStartMode(bool autoStartMode);

    bool hideInvitation() const;
    void setHideInvitation(bool hideInvitation);

    bool hideChatroom() const;
    void setHideChatroom(bool hideChatroom);

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

    int meetingMuteCount() const {return m_meetingMuteCount;}

signals:
    void error(int errorCode, const QString& errorMessage);
    void activeWindow();
    void meetingStatusChanged(NEMeeting::Status status, int errorCode, const QString& errorMessage = "");

    // Members signals
    void userJoined(const std::vector<std::string>& member_ids);
    void userLeft(const std::vector<std::string>& member_ids);

    // Binding values
    void meetingUniqueIdChanged();
    void shortMeetingIdChanged();
    void meetingIdChanged();
    void meetingTopicChanged();
    void meetingPasswordChanged();
    void meetingSIPChannelIdChanged();
    void meetingSchdeuleStarttimeChanged();
    void meetingSchdeuleEndtimeChanged();
    void meetingMutedChanged();
    void meetingLockedChanged();
    void prettyMeetingIdChanged();
    void showMeetingDurationChanged();
    void meetingDurationChanged();
    void nicknameChanged();
    void autoStartModeChanged();
    void hideInvitationChanged();
    void hideChatroomChanged();
    void hideScreenShareChanged();
    void hideViewChanged();
    void meetingIdDisplayOptionChanged();
    void hideWhiteboardChanged();
    void meetingAllowSelfAudioOnChanged();
    void reNameChanged();
    void enableRecordChanged();
    // Notifications
    void lockStatusNotify(bool locked);
    void muteStatusNotify(bool muted);
    void hostChangedNotify(const QString& changedAccountId);

    void modifyNicknameResult(bool success);
public slots:
    void lockMeeting(bool lock);
    void leaveMeeting(bool finish);
    bool isInMeeting();

private:
    INERoomService* m_meetingService = nullptr;
    INEInRoomService* m_inMeetingService = nullptr;
    INEInRoomServiceListener* m_inMeetingServiceListener = nullptr;
    INERtcStatsEventListener* m_rtcRtcStatsEventListener = nullptr;
    QTimer m_durationTimer;
    QString m_shortMeetingId = "";
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
    bool m_showMeetingDuration = true;
    qint64 m_uMeetingDuration = 0;
    qint64 m_uMeetingDurationEx = 0;
    qint64 m_uMeetingStartTime = 0;
    bool m_hideInvitation = false;
    bool m_hideChatroom = false;
    bool m_hideScreenShare = true;  // 是否显示共享屏幕
    bool m_hideView = true;         // 是否显示视图切换
    bool m_hideWhiteboard = false;  // 是否显示共享白板
    bool m_reName = true;           // 是否支持会中改名
    bool m_enableRecord = false;    // 是否显示"录制中"状态
    QString m_prettyMeetingId;
    QString m_userNickname = "";
    Invoker m_invoker;
    AutoStartInfo m_autoStartInfo;
    bool m_autoStartMode = false;
    NEMeeting::MeetingIdDisplayOptions m_meetingIdDisplayOption = NEMeeting::DISPLAY_ALL;

    int m_meetingMuteCount = 0;

    // 需要密码时缓存一下登录信息
    NEJoinRoomParams m_joinRoomParams;
    NEJoinRoomOptions m_joinRoomOptions;
    NEMeeting::Status m_meetingStatus = NEMeeting::MEETING_IDLE;
};

#endif  // MEETINGMANAGER_H
