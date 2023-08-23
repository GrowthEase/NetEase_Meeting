/**
 * @file meeting_event_maanger.h
 * @author Dylan (dengjiajia@corp.netease.com)
 * @brief 基于 Qt 网络库的数据上报实现
 * @version 0.1
 * @date 2023-06-21
 *
 * Copyright (c) 2023 NetEase
 *
 */
#ifndef XKIT_DESKTOP_MEETING_EVENT_MANAGER_H
#define XKIT_DESKTOP_MEETING_EVENT_MANAGER_H

#include <map>
#include "statistics/stat_repoter_interface.h"

using EventUUID = std::string;

class MeetingEventReporter : public QObject, public StatReporterBase {
    Q_OBJECT
public:
    MeetingEventReporter() = default;
    ~MeetingEventReporter() override;

protected:
    void OnAddEvent(const std::shared_ptr<IStatEvent>& event) override;
    void OnRemoveEvent(const std::string& event_uuid) override;
};

#endif  // XKIT_DESKTOP_MEETING_EVENT_MANAGER_H
