/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "pre_meeting_manager.h"
#include <QObject>

PreMeetingManager::PreMeetingManager(QObject* parent)
    : QObject(parent)
    , m_preMeetingService(GlobalManager::getInstance()->getPreRoomService()) {
    qRegisterMetaType<NERoomItem>("NERoomItem");
    qRegisterMetaType<QList<NERoomItem>>("QList<NERoomItem>");
    m_preMeetingService->addScheduledRoomStatusListener(this);
}

bool PreMeetingManager::scheduleMeeting(const NERoomItem& param) {
    if (!m_preMeetingService)
        return false;

    m_preMeetingService->scheduleRoom(param, [=](int errorCode, const std::string& errorMessage, const NERoomItem& item) {
        Invoker::getInstance()->execute([=]() { emit scheduleOrEditMeeting(errorCode, QString::fromStdString(errorMessage), item); });
    });
    return true;
}

bool PreMeetingManager::editSchedule(const NERoomItem& scheduledInfo) {
    if (!m_preMeetingService)
        return false;

    m_preMeetingService->editRoom(scheduledInfo, [=](int errorCode, const std::string& errorMessage) {
        Invoker::getInstance()->execute([=]() { emit scheduleOrEditMeeting(errorCode, QString::fromStdString(errorMessage), scheduledInfo); });
    });
    return true;
}

bool PreMeetingManager::cancelSchedule(uint64_t uniqueMeetingId) {
    if (!m_preMeetingService)
        return false;

    m_preMeetingService->cancelRoom(uniqueMeetingId, [=](int errorCode, const std::string& errorMessage) {
        Invoker::getInstance()->execute([=]() {
            NERoomItem item;
            item.status = ROOM_CANCEL;
            emit scheduleOrEditMeeting(errorCode, QString::fromStdString(errorMessage), item);
        });
    });
    return true;
}

bool PreMeetingManager::getMeetingList(const std::list<NERoomItemStatus>& status) {
    if (!m_preMeetingService)
        return false;

    m_preMeetingService->getRoomList(status, [=](int errorCode, const std::string& errorMessage, const std::list<NERoomItem>& items) {
        Invoker::getInstance()->execute([=]() {
            QList<NERoomItem> meetingLists;
            if (200 == errorCode) {
                YXLOG(Info) << "Query meeting list callback: " << items.size() << YXLOGEnd;
                for (auto& scheduledMeeting : items) {
                    YXLOG(Info) << "unique meeting ID: " << scheduledMeeting.roomUniqueId << ",meetingTopic: " << scheduledMeeting.subject
                                << YXLOGEnd;
                    meetingLists.push_back(scheduledMeeting);
                }
            }
            emit getMeetingLists(errorCode, QString::fromStdString(errorMessage), meetingLists);
        });
    });

    return true;
}

bool PreMeetingManager::getMeetingInfo(uint64_t uniqueMeetingId, NERoomItem& scheduledInfo) {
    if (!m_preMeetingService)
        return false;

    return m_preMeetingService->getRoomItemByUniqueId(uniqueMeetingId, scheduledInfo) == kNENoError;
}

void PreMeetingManager::onScheduleRoomStatusChanged(uint64_t uniqueRoomId, int roomStatus) {
    Invoker::getInstance()->execute([=]() { emit meetingStatusChanged(uniqueRoomId, roomStatus); });
}

void PreMeetingManager::onScheduleRoomStatusChanged(std::list<NERoomItem>& changedRoomList) {
    Invoker::getInstance()->execute([=]() {
        for (auto& changedMeeting : changedRoomList) {
            emit meetingStatusChanged(changedMeeting.roomUniqueId, changedMeeting.status);
        }
    });
}
