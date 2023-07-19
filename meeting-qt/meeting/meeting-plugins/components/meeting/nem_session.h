// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_COMPONENTS_MEETING_NEM_SESSION_H_
#define MEETING_PLUGINS_COMPONENTS_MEETING_NEM_SESSION_H_

#include <QDebug>
#include <QObject>
#include <QPointer>
#include <string>
#include "include/meeting_service_interface.h"
#include "nem_audio_controller.h"
#include "nem_engine.h"
#include "nem_members_controller.h"
#include "nem_mine.h"
#include "nem_share_controller.h"
#include "nem_video_controller.h"
#include "utils/invoker.h"

class NEMSession : public QObject, public nem_sdk::IMeetingEventHandler {
    Q_OBJECT
    Q_ENUMS(MeetingStatus)

public:
    explicit NEMSession(QObject* parent = nullptr);

    enum MeetingStatus {
        MEETING_IDLE,  // Default status
        MEETING_CONNECTING,
        MEETING_PREPARING,
        MEETING_PREPARED,
        MEETING_CONNECT_FAILED,
        MEETING_CONNECTED,
        MEETING_DISCONNECTED,
        MEETING_ENDED
    };

    enum MeetingMuteType {
        MEETING_MUTE_DEFAULT,       // Default state
        MEETING_MUTE_ALLOW_UNMUTE,  // Allow unmute by self
        MEETING_MUTE_NEEDS_HANDSUP  // Needs to hands up
    };

    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)
    Q_PROPERTY(NEMEngine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(QString meetingId READ meetingId WRITE setMeetingId NOTIFY meetingIdChanged)
    Q_PROPERTY(QString shortMeetingNum READ shortMeetingNum NOTIFY shortMeetingNumChanged)
    Q_PROPERTY(QString channelId READ channelId NOTIFY channelIdChanged)
    Q_PROPERTY(QString sipChannelId READ sipChannelId NOTIFY sipChannelIdChanged)
    Q_PROPERTY(QString topic READ topic WRITE setTopic NOTIFY topicChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(bool locked READ locked WRITE setLocked NOTIFY lockedChanged)
    Q_PROPERTY(MeetingMuteType muteType READ muteType WRITE setMuteType NOTIFY muteTypeChanged)
    Q_PROPERTY(time_t createdAt READ createdAt NOTIFY createdAtChanged)
    Q_PROPERTY(time_t updatedAt READ updatedAt NOTIFY updatedAtChanged)
    Q_PROPERTY(time_t startTime READ startTime NOTIFY startTimeChanged)
    Q_PROPERTY(time_t endTime READ endTime NOTIFY endTimeChanged)
    Q_PROPERTY(time_t duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(MeetingStatus status READ status NOTIFY statusChanged)
    Q_PROPERTY(NEMMine* mine READ mine WRITE setMine NOTIFY mineChanged)
    Q_PROPERTY(int errorCode READ errorCode NOTIFY errorCodeChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)
    Q_PROPERTY(NEMAudioController* audioController READ audioController WRITE setAudioController NOTIFY audioControllerChanged)
    Q_PROPERTY(NEMVideoController* videoController READ videoController WRITE setVideoController NOTIFY videoControllerChanged)
    Q_PROPERTY(NEMShareController* shareController READ shareController WRITE setShareController NOTIFY shareControllerChanged)
    Q_PROPERTY(NEMMembersController* membersController READ membersController WRITE setMembersController NOTIFY membersControllerChanged)

    Q_INVOKABLE bool create(const QString& meetingId, const QString& nickname, bool enableAudio = true, bool enableVideo = true);
    Q_INVOKABLE bool join(const QString& meetingId,
                          const QString& password,
                          const QString& nickname,
                          bool enableAudio = true,
                          bool enableVideo = true);
    Q_INVOKABLE void leave(bool finish = false);

    bool isValid() const;
    void setIsValid(bool isValid);

    NEMEngine* engine() const;
    void setEngine(NEMEngine* engine);

    QString meetingId() const;
    void setMeetingId(const QString& meetingId);

    QString shortMeetingNum() const;
    void setShortMeetingNum(const QString& shortMeetingNum);

    QString channelId() const;
    void setChannelId(const QString& channelId);

    QString sipChannelId() const;
    void setSipChannelId(const QString& sipChannelId);

    QString topic() const;
    void setTopic(const QString& topic);

    QString password() const;
    void setPassword(const QString& password);

    bool locked() const;
    void setLocked(bool locked);

    MeetingMuteType muteType() const;
    void setMuteType(const MeetingMuteType& muteType);

    time_t createdAt() const;
    void setCreatedAt(const time_t& createdAt);

    time_t updatedAt() const;
    void setUpdatedAt(const time_t& updatedAt);

    time_t startTime() const;
    void setStartTime(const time_t& startTime);

    time_t endTime() const;
    void setEndTime(const time_t& endTime);

    time_t duration() const;
    void setDuration(const time_t& duration);

    MeetingStatus status() const;
    void setStatus(const MeetingStatus& status);

    NEMMine* mine() const;
    void setMine(NEMMine* mine);

    int errorCode() const;
    void setErrorCode(int errorCode);

    QString errorString() const;
    void setErrorString(const QString& errorString);

    NEMAudioController* audioController() const;
    void setAudioController(NEMAudioController* audioController);

    NEMVideoController* videoController() const;
    void setVideoController(NEMVideoController* videoController);

    NEMShareController* shareController() const;
    void setShareController(NEMShareController* shareController);

    NEMMembersController* membersController() const;
    void setMembersController(NEMMembersController* membersController);

Q_SIGNALS:
    void isValidChanged();
    void engineChanged();
    void meetingIdChanged();
    void shortMeetingNumChanged();
    void channelIdChanged();
    void sipChannelIdChanged();
    void topicChanged();
    void passwordChanged();
    void lockedChanged();
    void muteTypeChanged();
    void createdAtChanged();
    void updatedAtChanged();
    void startTimeChanged();
    void endTimeChanged();
    void durationChanged();
    void statusChanged();
    void mineChanged();
    void errorCodeChanged();
    void errorStringChanged();
    void audioControllerChanged();
    void videoControllerChanged();
    void shareControllerChanged();
    void membersControllerChanged();

    void connected();
    void disconnected();  // IM or RTC disconnected, wait to reconnect
    void ended();         // left/disconnected/kicked(multispot/host)
    void error();

protected:
    void onMeetingStatusChanged(nem_sdk::MeetingStatus status, nem_sdk::MeetingStatusExtCode result) override;
    void onMeetingJoinTypeChanged(nem_sdk::MeetingJoinType joinType) override;
    void onMeetingMuteStatusChanged(bool muted) override;
    void onMeetingMuteNeedHandsUpChanged(bool bNeedHandsUp) override;
    void onMeetingSIPChannelIdChanged(const std::string sipChannelId) override;
    void onMeetingDurationChanged(const uint64_t& duration) override;
    void onMeetingStartTimeChanged(uint64_t startTime) override;
    void onError(uint32_t errorCode, const std::string& errorMessage) override;

private:
    bool updateMeetingInfo(bool cleanup = false);
    MeetingStatus transformStatus(const nem_sdk::MeetingStatus& status);

private:
    QPointer<Invoker> m_invoker = nullptr;
    nem_sdk::IMeetingService* m_meetingService = nullptr;
    bool m_isValid = false;
    QPointer<NEMEngine> m_engine = nullptr;
    QString m_meetingId;
    QString m_shortMeetingNum;
    QString m_channelId;
    QString m_sipChannelId;
    QString m_topic;
    QString m_password;
    bool m_locked = false;
    MeetingMuteType m_muteType = MEETING_MUTE_DEFAULT;
    time_t m_createdAt = 0;
    time_t m_updatedAt = 0;
    time_t m_startTime = 0;
    time_t m_endTime = 0;
    time_t m_duration = 0;
    MeetingStatus m_status = MEETING_IDLE;
    NEMMine* m_mine;
    int m_errorCode = 0;
    QString m_errorString;

    NEMAudioController* m_audioController = nullptr;
    NEMVideoController* m_videoController = nullptr;
    NEMShareController* m_shareController = nullptr;
    NEMMembersController* m_membersController = nullptr;
};

#endif  // MEETING_PLUGINS_COMPONENTS_MEETING_NEM_SESSION_H_
