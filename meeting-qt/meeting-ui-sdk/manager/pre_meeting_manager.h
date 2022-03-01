/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef PREMEETINGMANAGER_H
#define PREMEETINGMANAGER_H

#include <QObject>
#include "global_manager.h"
#include "pre_room_service_interface.h"

using namespace neroom;

class PreMeetingManager : public QObject, public ScheduledRoomStatusListener {
    Q_OBJECT
public:
    SINGLETONG(PreMeetingManager)
public:
    explicit PreMeetingManager(QObject* parent = nullptr);

    bool scheduleMeeting(const NERoomItem& param);
    bool editSchedule(const NERoomItem& scheduledInfo);
    bool cancelSchedule(uint64_t uniqueMeetingId);
    bool getMeetingList(const std::list<NERoomItemStatus>& status);
    bool getMeetingInfo(uint64_t uniqueMeetingId, NERoomItem& scheduledInfo);

    virtual void onScheduleRoomStatusChanged(uint64_t uniqueRoomId, int roomStatus) override;
    virtual void onScheduleRoomStatusChanged(std::list<NERoomItem>& changedRoomList) override;

signals:
    void error(int errorCode, const QString& errorMessage);
    void getMeetingLists(int errorCode, const QString& errorMessage, const QList<NERoomItem>& scheduledLists);
    void meetingStatusChanged(quint64 uniqueMeetingId, int meetingStatus);
    void scheduleOrEditMeeting(int errorCode, const QString& errorMessage, NERoomItem info);

private:
    INEPreRoomService* m_preMeetingService = nullptr;
};

#endif  // PREMEETINGMANAGER_H
