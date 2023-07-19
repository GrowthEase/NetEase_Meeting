// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_COMPONENTS_SCHEDULES_NEM_SCHEDULES_H_
#define MEETING_PLUGINS_COMPONENTS_SCHEDULES_NEM_SCHEDULES_H_

#include <QJsonObject>
#include <QObject>
#include <QPointer>
#include <list>
#include <map>
#include <vector>
#include "include/pre_meeting_service_interface.h"
#include "nem_engine.h"
#include "utils/invoker.h"

typedef struct _tagScheduleItem {
    QString meetingId;
    QString topic;
    QString password;
    uint64_t uniqueId;
    nem_sdk::PreMeetingsStatus state;
    bool mute;
    time_t createdAt;
    time_t updatedAt;
    time_t startTime;
    time_t endTime;
} ScheduleItem;

class NEMSchedule : public QObject, public nem_sdk::IPreMeetingEventHandler {
    Q_OBJECT
    Q_ENUMS(FilterType)
    Q_ENUMS(MeetingStatus)

public:
    explicit NEMSchedule(QObject* parent = nullptr);

    enum FilterType {
        QUERY_TYPE_IDLE = 1,            // 0x00000001
        QUERY_TYPE_STARTED = 1 << 4,    // 0x00000010
        QUERY_TYPE_ENDED = 1 << 8,      // 0x00000100
        QUERY_TYPE_CANCELED = 1 << 12,  // 0x00001000
        QUERY_TYPE_RECYCLED = 1 << 16   // 0x00010000
    };

    enum MeetingStatus {
        MEETING_STATUS_UNKNOWN,
        MEETING_STATUS_IDLE = 0,
        MEETING_STATUS_STARTED,
        MEETING_STATUS_ENDED,
        MEETING_STATUS_CANCELED,
        MEETING_STATUS_RECYCLED
    };

    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)
    Q_PROPERTY(NEMEngine* engine READ engine WRITE setEngine NOTIFY engineChanged)

    Q_INVOKABLE void scheduleMeeting(const QString& topic, time_t startTime, time_t endTime, const QString& password, bool mute, bool isSupportLive);
    Q_INVOKABLE void editMeeting(const QString& topic, time_t startTime, time_t endTime, const QString& password, bool mute, bool isSupportLive);
    Q_INVOKABLE void cancelMeeting(uint64_t uniqueMeetingId);

    QVector<ScheduleItem> items() const;
    void queryItems();

    bool isValid() const;
    void setIsValid(bool isValid);

    NEMEngine* engine() const;
    void setEngine(NEMEngine* engine);

protected:
    void onQueryMeetingList(nem_sdk::PreMeetingResult result, std::map<uint64_t, nem_sdk::ScheduleMeetingInfo> uniqueMeetingIds) override;
    void onScheduleOrEditMeeting(nem_sdk::PreMeetingResult result, nem_sdk::ScheduleMeetingInfo scheduleMeetingInfo, bool bEdit) override;
    void onMeetingStatusChanged(uint64_t uniqueMeetingId, const nem_sdk::PreMeetingsStatus& meetingStatus) override;
    void onMeetingStatusChanged(std::list<nem_sdk::ScheduleMeetingInfo>& changedMeetingList) override;

Q_SIGNALS:
    void isValidChanged();
    void engineChanged();
    void preResetItems();
    void postResetItems();
    void preItemAppended();
    void postItemAppended();
    void preItemRemoved(int index);
    void postItemRemoved();
    void dataChanged(int index);
    void scheduleMeeting(int errorCode, const QString& errorMessage, const QJsonObject& item);
    void editMeeting(int errorCode, const QString& errorMessage, const QJsonObject& item);
    void cancelMeeting(int errorCode, const QString& errorMessage, uint64_t uniqueMeetingId);
    void meetingStatusChanged(uint64_t uniqueMeetingId, NEMSchedule::MeetingStatus meetingStatus);

private:
    int m_filter;
    bool m_isValid = false;
    QPointer<NEMEngine> m_engine = nullptr;
    QPointer<Invoker> m_invoker = nullptr;
    QVector<ScheduleItem> m_items;
    nem_sdk::IPreMeetingService* m_preMeetingService = nullptr;
};

#endif  // MEETING_PLUGINS_COMPONENTS_SCHEDULES_NEM_SCHEDULES_H_
