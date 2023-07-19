// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef PREMEETINGMANAGER_H
#define PREMEETINGMANAGER_H

#include <QObject>
#include "global_manager.h"

#include "controller/premeeting_controller.h"

using namespace neroom;

class PreMeetingManager : public QObject {
    Q_OBJECT
public:
    SINGLETONG(PreMeetingManager)
public:
    explicit PreMeetingManager(QObject* parent = nullptr);

    bool scheduleMeeting(const nem_sdk_interface::NEMeetingItem& item);
    bool editSchedule(const nem_sdk_interface::NEMeetingItem& item);
    bool cancelSchedule(uint64_t uniqueMeetingId);
    bool getMeetingList(const std::list<NEMeetingItemStatus>& status);
    bool getMeetingInfo(uint64_t uniqueMeetingId, nem_sdk_interface::NEMeetingItem& scheduledInfo);

    void onScheduleRoomStatusChanged(uint64_t uniqueRoomId, int roomStatus);
    void onScheduleRoomStatusChanged(std::list<nem_sdk_interface::NEMeetingItem>& changedRoomList);

signals:
    void error(int errorCode, const QString& errorMessage);
    void getMeetingLists(int errorCode, const QString& errorMessage, const QList<nem_sdk_interface::NEMeetingItem>& scheduledLists);
    void meetingStatusChanged(quint64 uniqueMeetingId, int meetingStatus);
    void scheduleOrEditMeeting(int errorCode, const QString& errorMessage, nem_sdk_interface::NEMeetingItem info);

private:
    std::shared_ptr<NEPreMeetingController> m_preMeetingController = nullptr;
};

#endif  // PREMEETINGMANAGER_H
