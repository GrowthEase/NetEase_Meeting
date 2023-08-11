// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "pre_meeting_manager.h"
#include <QObject>

PreMeetingManager::PreMeetingManager(QObject* parent)
    : QObject(parent) {
    m_preMeetingController = std::make_shared<NEPreMeetingController>();
    qRegisterMetaType<nem_sdk_interface::NEMeetingItem>("NEMeetingItem");
    qRegisterMetaType<QList<nem_sdk_interface::NEMeetingItem>>("QList<NEMeetingItem>");
}

bool PreMeetingManager::scheduleMeeting(const nem_sdk_interface::NEMeetingItem& item) {
    m_preMeetingController->scheduleRoom(item, [=](int errorCode, const std::string& errorMessage, const nem_sdk_interface::NEMeetingItem& item) {
        Invoker::getInstance()->execute([=]() { emit scheduleOrEditMeeting(errorCode, QString::fromStdString(errorMessage), item); });
    });
    return true;
}

bool PreMeetingManager::editSchedule(const nem_sdk_interface::NEMeetingItem& item) {
    m_preMeetingController->editRoom(item, [=](int errorCode, const std::string& errorMessage) {
        Invoker::getInstance()->execute([=]() { emit scheduleOrEditMeeting(errorCode, QString::fromStdString(errorMessage), item); });
    });
    return true;
}

bool PreMeetingManager::cancelSchedule(uint64_t uniqueMeetingId) {
    m_preMeetingController->cancelRoom(uniqueMeetingId, [=](int errorCode, const std::string& errorMessage) {
        Invoker::getInstance()->execute([=]() {
            nem_sdk_interface::NEMeetingItem item;
            item.status = MEETING_CANCEL;
            emit scheduleOrEditMeeting(errorCode, QString::fromStdString(errorMessage), item);
        });
    });
    return true;
}

bool PreMeetingManager::getMeetingList(const std::list<nem_sdk_interface::NEMeetingItemStatus>& status) {
    m_preMeetingController->getRoomList(status, [=](int errorCode, const std::string& errorMessage,
                                                    const std::list<nem_sdk_interface::NEMeetingItem>& items) {
        Invoker::getInstance()->execute([=]() {
            QList<nem_sdk_interface::NEMeetingItem> meetingLists;
            if (200 == errorCode) {
                YXLOG(Info) << "Query meeting list callback: " << items.size() << YXLOGEnd;
                for (auto& scheduledMeeting : items) {
                    YXLOG(Info) << "unique meeting ID: " << scheduledMeeting.meetingId << ", meetingTopic: " << scheduledMeeting.subject << YXLOGEnd;
                    meetingLists.push_back(scheduledMeeting);
                }
            }
            emit getMeetingLists(errorCode, QString::fromStdString(errorMessage), meetingLists);
        });
    });

    return true;
}

bool PreMeetingManager::getMeetingInfo(uint64_t uniqueMeetingId, nem_sdk_interface::NEMeetingItem& scheduledInfo) {
    return m_preMeetingController->getRoomItemByUniqueId(uniqueMeetingId, scheduledInfo) == kNENoError;
}

void PreMeetingManager::onScheduleRoomStatusChanged(uint64_t uniqueRoomId, int roomStatus) {
    emit meetingStatusChanged(uniqueRoomId, roomStatus);
}

// void PreMeetingManager::onScheduleRoomStatusChanged(uint64_t uniqueRoomId, int roomStatus) {
//    Invoker::getInstance()->execute([=]() { emit meetingStatusChanged(uniqueRoomId, roomStatus); });
//}

void PreMeetingManager::onScheduleRoomStatusChanged(std::list<nem_sdk_interface::NEMeetingItem>& changedRoomList) {
    Invoker::getInstance()->execute([=]() {
        for (auto& changedMeeting : changedRoomList) {
            emit meetingStatusChanged(changedMeeting.meetingId, changedMeeting.status);
        }
    });
}
