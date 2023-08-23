/**
 * @file meeting_event_base.cpp
 * @author Dylan (dengjiajia@corp.netease.com)
 * @brief 会议基础 event 数据上报
 * @version 0.1
 * @date 2023-06-21
 *
 * Copyright (c) 2023 NetEase
 *
 */
#include "meeting_event_base.h"
#include <QUuid>
#include "manager/auth_manager.h"
#include "manager/global_manager.h"
#include "version.h"

MeetingBaseEvent::MeetingBaseEvent() {
    start_time_ = GetCurrentTimestamp();
}

std::string MeetingBaseEvent::OnGetEventUUID() const {
    return QUuid::createUuid().toString().toStdString();
}

time_t MeetingBaseEvent::OnGetStartTime() const {
    return start_time_;
}

time_t MeetingBaseEvent::OnGetEndTime() const {
    return end_time_;
}

bool MeetingBaseEvent::IsSucceed() const {
    return succeed_;
}

int32_t MeetingBaseEvent::OnGetResultCode() const {
    return result_code_;
}

void MeetingBaseEvent::OnFinalEvent() {
    end_time_ = GetCurrentTimestamp();
    network_type_ = NetworkHelper::GetNetworkTypeString(NetworkHelper::GetNetworkType());
}

time_t MeetingBaseEvent::GetCurrentTimestamp() const {
    auto now = std::chrono::system_clock::now();
    auto nowMs = std::chrono::time_point_cast<std::chrono::milliseconds>(now);
    auto value = nowMs.time_since_epoch();
    return value.count();
}

std::string MeetingBaseEvent::OnGetEventContent() const {
    QJsonObject object;
    object.insert(kMeetingActionEventAppKey, GlobalManager::getInstance()->globalAppKey());
    object.insert(kMeetingActionEventFieldUserID, AuthManager::getInstance()->authAccountId());
    object.insert(kMeetingActionEventFieldOccurTime, static_cast<int64_t>(GetStartTime()));
    object.insert(kMeetingActionEventFieldTimestamp, static_cast<int64_t>(GetStartTime()));
    object.insert(kMeetingActionEventFieldFinalTime, static_cast<int64_t>(GetEndTime()));
    object.insert(kMeetingActionEventFieldDuration, static_cast<int64_t>(GetDuration()));
    object.insert(kMeetingActionEventFieldResultCode, GetResultCode());
    object.insert(kMeetingActionEventFieldNetworkType, network_type_);
    object.insert(kMeetingActionEventFieldComponent, kMeetingActionEventComponentKey);
    object.insert(kMeetingActionEventFieldFramework, QString("Qt").append(qVersion()));
    object.insert(kMeetingActionEventFieldVersion, APPLICATION_VERSION);
    object.insert(kMeetingActionEventFieldMeetingTime, 0);
    // parameters
    auto parametersString = GetParameters();
    auto parameters = QJsonDocument::fromJson(QString::fromStdString(parametersString).toUtf8());
    object.insert(kMeetingActionEventFieldParameters, parameters.object());
    return QString(QJsonDocument(object).toJson(QJsonDocument::Compact)).toStdString();
}
