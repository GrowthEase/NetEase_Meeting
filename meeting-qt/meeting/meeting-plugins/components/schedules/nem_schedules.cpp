// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_schedules.h"

NEMSchedule::NEMSchedule(QObject* parent)
    : QObject(parent)
    , m_filter(NEMSchedule::QUERY_TYPE_IDLE | NEMSchedule::QUERY_TYPE_STARTED | NEMSchedule::QUERY_TYPE_ENDED)
    , m_invoker(new Invoker) {}

QVector<ScheduleItem> NEMSchedule::items() const {
    return m_items;
}

void NEMSchedule::queryItems() {
    if (m_preMeetingService) {
        std::vector<nem_sdk::PreMeetingsStatus> filterList;
        if (m_filter & QUERY_TYPE_IDLE)
            filterList.push_back(nem_sdk::kPreMeetingStatusIdle);
        if (m_filter & QUERY_TYPE_STARTED)
            filterList.push_back(nem_sdk::kPreMeetingStatusStarted);
        if (m_filter & QUERY_TYPE_ENDED)
            filterList.push_back(nem_sdk::kPreMeetingStatusEnded);
        if (m_filter & QUERY_TYPE_CANCELED)
            filterList.push_back(nem_sdk::kPreMeetingStatusCanceled);
        if (m_filter & QUERY_TYPE_RECYCLED)
            filterList.push_back(nem_sdk::kPreMeetingStatusRecycled);
        m_preMeetingService->queryMeetingList(filterList);
    }
}

void NEMSchedule::onQueryMeetingList(nem_sdk::PreMeetingResult result, std::map<uint64_t, nem_sdk::ScheduleMeetingInfo> uniqueMeetingIds) {
    m_invoker->execute([=]() {
        if (result.errorCode == 200) {
            Q_EMIT preResetItems();
            m_items.clear();
            for (auto& item : uniqueMeetingIds) {
                auto& info = item.second;
                ScheduleItem tmpItem;
                tmpItem.topic = QString::fromStdString(info.meetingTopic);
                tmpItem.uniqueId = info.uniqueMeetingId;
                tmpItem.meetingId = QString::fromStdString(info.meetingId);
                tmpItem.createdAt = info.createTime;
                tmpItem.updatedAt = info.updateTime;
                tmpItem.startTime = info.startTime;
                tmpItem.endTime = info.endTime;
                tmpItem.mute = info.muteAfterMemberJoin;
                tmpItem.state = info.meetingStatus;
                tmpItem.password = QString::fromStdString(info.meetingPassword);
                m_items.push_back(tmpItem);
            }
            Q_EMIT postResetItems();
        }
    });
}

void NEMSchedule::onScheduleOrEditMeeting(nem_sdk::PreMeetingResult result, nem_sdk::ScheduleMeetingInfo scheduleMeetingInfo, bool bEdit) {
    if (scheduleMeetingInfo.meetingId.empty()) {
        Q_EMIT cancelMeeting(result.errorCode, QString::fromStdString(result.errorMessage), scheduleMeetingInfo.uniqueMeetingId);
    } else {
        QJsonObject item;
        item["topic"] = QString::fromStdString(scheduleMeetingInfo.meetingTopic);
        item["uniqueId"] = (qint64)scheduleMeetingInfo.uniqueMeetingId;
        item["meetingId"] = QString::fromStdString(scheduleMeetingInfo.meetingId);
        item["createdAt"] = scheduleMeetingInfo.createTime;
        item["updatedAt"] = scheduleMeetingInfo.updateTime;
        item["state"] = (NEMSchedule::MeetingStatus)scheduleMeetingInfo.meetingStatus;
        item["startTime"] = scheduleMeetingInfo.startTime;
        item["endTime"] = scheduleMeetingInfo.endTime;
        item["password"] = QString::fromStdString(scheduleMeetingInfo.meetingPassword);
        item["mute"] = scheduleMeetingInfo.muteAfterMemberJoin;
        item["live"] = scheduleMeetingInfo.isSupportLive;

        if (bEdit) {
            Q_EMIT editMeeting(result.errorCode, QString::fromStdString(result.errorMessage), item);
        } else {
            Q_EMIT scheduleMeeting(result.errorCode, QString::fromStdString(result.errorMessage), item);
        }
    }
}

void NEMSchedule::onMeetingStatusChanged(uint64_t uniqueMeetingId, const nem_sdk::PreMeetingsStatus& meetingStatus) {
    Q_EMIT meetingStatusChanged(uniqueMeetingId, (NEMSchedule::MeetingStatus)meetingStatus);
}

void NEMSchedule::onMeetingStatusChanged(std::list<nem_sdk::ScheduleMeetingInfo>& changedMeetingList) {
    m_invoker->execute([=]() {
        for (auto& item : changedMeetingList) {
            int filter = 0;
            switch (item.meetingStatus) {
                case nem_sdk::kPreMeetingStatusIdle:
                    filter |= QUERY_TYPE_IDLE;
                    break;
                case nem_sdk::kPreMeetingStatusStarted:
                    filter |= QUERY_TYPE_STARTED;
                    break;
                case nem_sdk::kPreMeetingStatusEnded:
                    filter |= QUERY_TYPE_ENDED;
                    break;
                case nem_sdk::kPreMeetingStatusCanceled:
                    filter |= QUERY_TYPE_CANCELED;
                    break;
                case nem_sdk::kPreMeetingStatusRecycled:
                    filter |= QUERY_TYPE_RECYCLED;
                    break;
            }

            int foundIndex = -1;
            for (auto i = 0; i < m_items.size(); i++) {
                auto& itemRef = m_items[i];
                if (itemRef.uniqueId == item.uniqueMeetingId) {
                    foundIndex = i;
                    if (filter & m_filter) {
                        itemRef.meetingId = QString::fromStdString(item.meetingId);
                        itemRef.createdAt = item.createTime;
                        itemRef.updatedAt = item.updateTime;
                        itemRef.startTime = item.startTime;
                        itemRef.endTime = item.endTime;
                        itemRef.mute = item.muteAfterMemberJoin;
                        itemRef.state = item.meetingStatus;
                        itemRef.topic = QString::fromStdString(item.meetingTopic);
                        itemRef.password = QString::fromStdString(item.meetingPassword);
                    }
                    break;
                }
            }

            if (!(filter & m_filter)) {
                Q_EMIT preItemRemoved(foundIndex);
                m_items.remove(foundIndex);
                Q_EMIT postItemRemoved();
                continue;
            }

            if (foundIndex != -1) {
                Q_EMIT dataChanged(foundIndex);
                continue;
            }

            // New schedule created.
            ScheduleItem newItem;
            newItem.uniqueId = item.uniqueMeetingId;
            newItem.meetingId = QString::fromStdString(item.meetingId);
            newItem.createdAt = item.createTime;
            newItem.updatedAt = item.updateTime;
            newItem.startTime = item.startTime;
            newItem.endTime = item.endTime;
            newItem.mute = item.muteAfterMemberJoin;
            newItem.state = item.meetingStatus;
            newItem.topic = QString::fromStdString(item.meetingTopic);
            newItem.password = QString::fromStdString(item.meetingPassword);
            Q_EMIT preItemAppended();
            m_items.push_back(newItem);
            Q_EMIT postItemAppended();
        }
    });
}

bool NEMSchedule::isValid() const {
    return m_isValid;
}

void NEMSchedule::setIsValid(bool isValid) {
    if (m_isValid != isValid) {
        m_isValid = isValid;
        Q_EMIT isValidChanged();
    }
}

NEMEngine* NEMSchedule::engine() const {
    return m_engine;
}

void NEMSchedule::setEngine(NEMEngine* engine) {
    if (m_engine != engine) {
        m_engine = engine;
        m_preMeetingService = m_engine->getPreMeetingService();
        m_preMeetingService->setPreMeetingEventHandler(this);
        setIsValid(true);
        queryItems();
    }
}

void NEMSchedule::scheduleMeeting(const QString& topic, time_t startTime, time_t endTime, const QString& password, bool mute, bool isSupportLive) {
    if (m_preMeetingService) {
        nem_sdk::ScheduleMeetingParams scheduleMeetingParam;
        scheduleMeetingParam.meetingTopic = topic.toStdString();
        scheduleMeetingParam.meetingPassword = password.toStdString();
        scheduleMeetingParam.startTime = startTime;
        scheduleMeetingParam.endTime = endTime;
        scheduleMeetingParam.muteAfterMemberJoin = mute;
        scheduleMeetingParam.isSupportLive = isSupportLive;
        m_preMeetingService->scheduleMeeting(scheduleMeetingParam);
    }
}

void NEMSchedule::editMeeting(const QString& topic, time_t startTime, time_t endTime, const QString& password, bool mute, bool isSupportLive) {
    if (m_preMeetingService) {
        nem_sdk::ScheduleMeetingInfo scheduleMeetingParam;
        scheduleMeetingParam.meetingTopic = topic.toStdString();
        scheduleMeetingParam.meetingPassword = password.toStdString();
        scheduleMeetingParam.startTime = startTime;
        scheduleMeetingParam.endTime = endTime;
        scheduleMeetingParam.muteAfterMemberJoin = mute;
        scheduleMeetingParam.isSupportLive = isSupportLive;
        m_preMeetingService->editMeeting(scheduleMeetingParam);
    }
}

void NEMSchedule::cancelMeeting(uint64_t uniqueMeetingId) {
    if (m_preMeetingService) {
        m_preMeetingService->cancelMeeting(uniqueMeetingId);
    }
}
