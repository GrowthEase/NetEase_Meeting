/**
 * @file meeting_event_base.h
 * @author Dylan (dengjiajia@corp.netease.com)
 * @brief 会议相关 event 数据上报
 * @version 0.1
 * @date 2023-06-21
 *
 * Copyright (c) 2023 NetEase
 *
 */
#ifndef MEETING_BASE_EVENT_H_
#define MEETING_BASE_EVENT_H_

#include "base_type_defines.h"
#include "meeting_event_network_helper.h"
#include "statistics/stat_event_interface.h"

static const char* kMeetingActionEventAppKey = "appKey";
static const char* kMeetingActionEventFieldUserID = "userId";
static const char* kMeetingActionEventFieldTimestamp = "timeStamp";
static const char* kMeetingActionEventFieldOccurTime = "startTime";
static const char* kMeetingActionEventFieldFinalTime = "endTime";
static const char* kMeetingActionEventFieldDuration = "duration";
static const char* kMeetingActionEventFieldParameters = "params";
static const char* kMeetingActionEventFieldComponent = "component";
static const char* kMeetingActionEventFieldFramework = "framework";
static const char* kMeetingActionEventFieldVersion = "version";
static const char* kMeetingActionEventFieldSucceed = "succeed";
static const char* kMeetingActionEventFieldResultCode = "code";
static const char* kMeetingActionEventFieldMeetingTime = "meeting_time";
static const char* kMeetingActionEventFieldMeetingID = "meeting_id";
static const char* kMeetingActionEventFieldMemberUID = "member_uid";
static const char* kMeetingActionEventFieldMemberProfile = "member_profile";
static const char* kMeetingActionEventFieldNetworkType = "networkType";
static const char* kMeetingActionEventFieldReason = "reason";
static const char* kMeetingActionEventFieldMeetingDuration = "meetingDuration";

static const char* kMeetingActionEventComponentKey = "MeetingKit";
static const char* kMeetingActionEventFrameworkKey = "Qt";

static const char* kEventNameKeyCreateMeeting = "MeetingKit_start_meeting";
static const char* kEventNameKeyJoinMeeting = "MeetingKit_join_meeting";
static const char* kEventNameKeyEndMeeting = "MeetingKit_meeting_end";

// 具体事件通用
static const char* kEventCommonTime = "time";

class MeetingBaseEvent : public StatEventBase {
public:
    MeetingBaseEvent();
    ~MeetingBaseEvent() override = default;
    std::string OnGetEventUUID() const override;
    time_t OnGetStartTime() const override;
    time_t OnGetEndTime() const override;
    bool IsSucceed() const override;
    int32_t OnGetResultCode() const override;
    std::string OnGetEventContent() const override;
    void OnFinalEvent() override;

private:
    time_t GetCurrentTimestamp() const;

protected:
    time_t start_time_{0};
    time_t end_time_{0};
    bool succeed_{false};
    int32_t result_code_{0};
    std::string message_;
    QString network_type_;
};

class MeetingBaseEventWithSteps : public MeetingBaseEvent {
public:
    MeetingBaseEventWithSteps() = default;
    ~MeetingBaseEventWithSteps() override = default;
    void AddStep(const std::shared_ptr<IMeetingStep>& step) {
        step->SetStepIndex(steps_.size());
        steps_.push_back(step);
    }
    std::string OnGetEventContent() const override {
        auto content = MeetingBaseEvent::OnGetEventContent();
        QJsonObject contentValues = QJsonDocument::fromJson(QString::fromStdString(content).toUtf8()).object();
        QJsonArray steps;
        for (const auto& step : steps_) {
            std::string stepContent = step->GetStepContent();
            QJsonDocument contentDoc = QJsonDocument::fromJson(QString::fromStdString(stepContent).toUtf8());
            if (step->GetStepIndex() == steps_.size() - 1) {
                contentValues[kMeetingActionEventFieldResultCode] = step->GetResultCode();
            }
            steps.append(contentDoc.object());
        }
        if (!steps.isEmpty()) {
            contentValues.insert("steps", steps);
        }
        return QJsonDocument(contentValues).toJson().toStdString();
    }

private:
    std::list<std::shared_ptr<IMeetingStep>> steps_;
};

static const char* kEventLoginKeyType = "type";

enum class LoginEventType { kAnonymous, kToken, kPassword };

class LoginEvent : public MeetingBaseEventWithSteps {
public:
    LoginEvent(LoginEventType loginType)
        : login_type_(loginType) {}
    ~LoginEvent() override = default;
    std::string OnGetEventName() const override { return "MeetingKit_login"; }
    std::string OnGetParameters() const override {
        QJsonObject values;
        values[kEventLoginKeyType] = static_cast<qint32>(login_type_);
        QJsonDocument doc(values);
        return doc.toJson(QJsonDocument::Compact).toStdString();
    }

private:
    LoginEventType login_type_;
};

enum class MeetingCreateType { kPersonal, kRandom };

static const char* kEventCreateMeetingNumber = "meetingNum";
static const char* kEventCreateRoomArchiveID = "roomArchiveId";
static const char* kEventCreateMeetingID = "meetingId";
static const char* kEventCreateType = "type";

class CreateMeetingEvent : public MeetingBaseEventWithSteps {
public:
    CreateMeetingEvent(const std::string& meetingNumber = "",
                       const std::string& roomArchiveID = "",
                       const std::string& meetingID = "",
                       MeetingCreateType type = MeetingCreateType::kPersonal)
        : meeting_number_(meetingNumber)
        , room_archive_id_(roomArchiveID)
        , meeting_id_(meetingID)
        , create_type_(type) {}
    ~CreateMeetingEvent() override = default;
    std::string OnGetEventName() const override { return kEventNameKeyCreateMeeting; }
    std::string OnGetParameters() const override {
        QJsonObject values;
        values[kEventCreateMeetingNumber] = QString::fromStdString(meeting_number_);
        values[kEventCreateRoomArchiveID] = QString::fromStdString(room_archive_id_);
        values[kEventCreateMeetingID] = QString::fromStdString(meeting_id_);
        values[kEventCreateType] = QString::fromStdString(TypeToString(create_type_));
        QJsonDocument doc(values);
        return doc.toJson(QJsonDocument::Compact).toStdString();
    }
    static std::string TypeToString(MeetingCreateType type) {
        switch (type) {
            case MeetingCreateType::kPersonal:
                return "personal";
            case MeetingCreateType::kRandom:
                return "random";
            default:
                return "unknown";
        }
    }

public:
    std::string meeting_number_;
    std::string room_archive_id_;
    std::string meeting_id_;
    MeetingCreateType create_type_;
};

enum class MeetingJoinType { kNormal, kAnonymous };

static const char* kEventJoinType = "type";

class JoinMeetingEvent : public MeetingBaseEventWithSteps {
public:
    JoinMeetingEvent() = default;
    ~JoinMeetingEvent() override = default;
    std::string OnGetEventName() const override { return kEventNameKeyJoinMeeting; }
    std::string OnGetParameters() const override {
        QJsonObject values;
        values[kEventCreateMeetingNumber] = QString::fromStdString(meeting_number_);
        values[kEventCreateRoomArchiveID] = QString::fromStdString(room_archive_id_);
        values[kEventCreateMeetingID] = QString::fromStdString(meeting_id_);
        values[kEventJoinType] = QString::fromStdString(TypeToString(join_type_));
        QJsonDocument doc(values);
        return doc.toJson(QJsonDocument::Compact).toStdString();
    }
    static std::string TypeToString(MeetingJoinType type) {
        switch (type) {
            case MeetingJoinType::kNormal:
                return "normal";
            case MeetingJoinType::kAnonymous:
                return "anonymous";
            default:
                return "unknown";
        }
    }

public:
    std::string meeting_number_;
    std::string room_archive_id_;
    std::string meeting_id_;
    MeetingJoinType join_type_;
};

static const char* kRoomKitEndEventReasonKeySelf = "leaveBySelf";
static const char* kRoomKitEndEventReasonKeySyncDataError = "syncDataError";
static const char* kRoomKitEndEventReasonKeyKickOut = "kickOut";
static const char* kRoomKitEndEventReasonKeyKickBySelf = "kickBySelf";
static const char* kRoomKitEndEventReasonKeyCloseByMember = "closeByMember";
static const char* kRoomKitEndEventReasonKeyEndOfLife = "endOfLife";
static const char* kRoomKitEndEventReasonKeyAllMemberOut = "allMemberOut";
static const char* kRoomKitEndEventReasonKeyCloseByBackend = "closeByBackend";
static const char* kRoomKitEndEventReasonKeyLoginStateError = "loginStateError";
static const char* kRoomKitEndEventReasonKeyEndOfRTC = "endOfRtc";
static const char* kRoomKitEndEventReasonKeyUnknown = "unknown";

class EndMeetingEvent : public MeetingBaseEventWithSteps {
public:
    EndMeetingEvent() = default;
    ~EndMeetingEvent() override = default;
    void SetStartTime(const qint64& startTime) { start_time_ = startTime; }
    void SetMeetingStartTime(const qint64& meetingStartTime) { meeting_start_time_ = meetingStartTime; }
    std::string OnGetEventName() const override { return kEventNameKeyEndMeeting; }
    std::string OnGetParameters() const override {
        QJsonObject values;
        values[kEventCreateMeetingNumber] = QString::fromStdString(meeting_number_);
        values[kEventCreateRoomArchiveID] = QString::fromStdString(room_archive_id_);
        values[kEventCreateMeetingID] = QString::fromStdString(meeting_id_);
        values[kMeetingActionEventFieldReason] = QString::fromStdString(ReasonToString());
        values[kMeetingActionEventFieldMeetingDuration] = GetEndTime() - meeting_start_time_;
        QJsonDocument doc(values);
        return doc.toJson(QJsonDocument::Compact).toStdString();
    }
    std::string ReasonToString() const {
        std::string reasonString = kRoomKitEndEventReasonKeyUnknown;
        switch (reason_) {
            case neroom::NERoomEndReason::kNERoomEndReasonLeaveBySelf:
                reasonString = kRoomKitEndEventReasonKeySelf;
                break;
            case neroom::NERoomEndReason::kNERoomEndReasonSyncDataError:
                reasonString = kRoomKitEndEventReasonKeySyncDataError;
                break;
            case neroom::NERoomEndReason::kNERoomEndReasonKickOut:
                reasonString = kRoomKitEndEventReasonKeyKickOut;
                break;
            case neroom::NERoomEndReason::kNERoomEndReasonKickSelf:
                reasonString = kRoomKitEndEventReasonKeyKickBySelf;
                break;
            case neroom::NERoomEndReason::kNERoomEndReasonCloseByMember:
                reasonString = kRoomKitEndEventReasonKeyCloseByMember;
                break;
            case neroom::NERoomEndReason::kNERoomEndReasonEndOfLife:
                reasonString = kRoomKitEndEventReasonKeyEndOfLife;
                break;
            case neroom::NERoomEndReason::kNERoomEndReasonAllMembersOut:
                reasonString = kRoomKitEndEventReasonKeyAllMemberOut;
                break;
            case neroom::NERoomEndReason::kNERoomEndReasonByBackend:
                reasonString = kRoomKitEndEventReasonKeyCloseByBackend;
                break;
            case neroom::NERoomEndReason::kNERoomEndReasonLoginStateError:
                reasonString = kRoomKitEndEventReasonKeyLoginStateError;
                break;
                // case neroom::NERoomEndReason::kNERoomEndReasonEndOfRTC:
                //    reasonString = kRoomKitEndEventReasonKeyEndOfRTC;
                break;
            default:
                break;
        }
        return reasonString;
    }

public:
    qint64 meeting_start_time_{0};
    int reason_;
    std::string room_archive_id_;
    std::string meeting_id_;
    std::string meeting_number_;
};

#endif  // MEETING_BASE_EVENT_H_
