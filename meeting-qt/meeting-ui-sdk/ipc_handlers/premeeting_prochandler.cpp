// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "premeeting_prochandler.h"
#include "ipc_handlers/hosting_module_client.h"
#include "manager/pre_meeting_manager.h"

NEPreMeetingServiceProcHandlerIMP::NEPreMeetingServiceProcHandlerIMP(QObject* parent)
    : QObject(parent) {
    connect(PreMeetingManager::getInstance(), &PreMeetingManager::scheduleOrEditMeeting, this,
            &NEPreMeetingServiceProcHandlerIMP::onScheduleOrEditMeeting);

    connect(PreMeetingManager::getInstance(), &PreMeetingManager::getMeetingLists, this, &NEPreMeetingServiceProcHandlerIMP::onQueryMeetingList);

    connect(PreMeetingManager::getInstance(), &PreMeetingManager::meetingStatusChanged, this,
            &NEPreMeetingServiceProcHandlerIMP::onMeetingStatusChanged);
}

void NEPreMeetingServiceProcHandlerIMP::onScheduleMeeting(const nem_sdk_interface::NEMeetingItem& item,
                                                          const nem_sdk_interface::NEPreMeetingService::NEScheduleMeetingItemCallback& callback) {
    YXLOG_API(Info) << "Received onScheduleMeeting, starttime: " << item.startTime << ", endtime: " << item.endTime << YXLOGEnd;
    m_scheduleMeetingCallback = callback;

    Invoker::getInstance()->execute([=]() { PreMeetingManager::getInstance()->scheduleMeeting(item); });
}

void NEPreMeetingServiceProcHandlerIMP::onEditMeeting(const nem_sdk_interface::NEMeetingItem& item,
                                                      const nem_sdk_interface::NEPreMeetingService::NEOperateScheduleMeetingCallback& callback) {
    YXLOG_API(Info) << "Received onEditMeeting." << YXLOGEnd;
    m_editMeetingCallback = callback;
    Invoker::getInstance()->execute([=]() { PreMeetingManager::getInstance()->editSchedule(item); });
}

void NEPreMeetingServiceProcHandlerIMP::onCancelMeeting(const int64_t& meetingUniqueId,
                                                        const nem_sdk_interface::NEPreMeetingService::NEOperateScheduleMeetingCallback& callback) {
    YXLOG_API(Info) << "Received onCancelMeeting." << YXLOGEnd;
    m_editMeetingCallback = callback;
    Invoker::getInstance()->execute([=]() { PreMeetingManager::getInstance()->cancelSchedule(meetingUniqueId); });
}

void NEPreMeetingServiceProcHandlerIMP::onGetMeetingItemById(const int64_t& meetingUniqueId,
                                                             const nem_sdk_interface::NEPreMeetingService::NEScheduleMeetingItemCallback& callback) {
    YXLOG_API(Info) << "Received onGetMeetingItemById." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        nem_sdk_interface::NEMeetingItem item;
        bool bret = PreMeetingManager::getInstance()->getMeetingInfo(meetingUniqueId, item);
        NS_I_NEM_SDK::NEErrorCode errorCode = NS_I_NEM_SDK::ERROR_CODE_FAILED;
        if (bret)
            errorCode = NS_I_NEM_SDK::ERROR_CODE_SUCCESS;
        std::string errorMessage = "";
        if (callback != nullptr)
            callback(errorCode, errorMessage, item);
    });
}

void NEPreMeetingServiceProcHandlerIMP::onGetMeetingList(std::list<NS_I_NEM_SDK::NEMeetingItemStatus> status,
                                                         const nem_sdk_interface::NEPreMeetingService::NEGetMeetingListCallback& callback) {
    YXLOG_API(Info) << "Received onGetMeetingList." << YXLOGEnd;
    m_getMeetingListCallback = callback;
    Invoker::getInstance()->execute([=]() {
        std::list<NEMeetingItemStatus> options;
        PreMeetingManager::getInstance()->getMeetingList(status);
    });
}

void NEPreMeetingServiceProcHandlerIMP::onScheduleOrEditMeeting(int errorCode,
                                                                const QString& errorMessage,
                                                                const nem_sdk_interface::NEMeetingItem& item) {
    YXLOG_API(Info) << "CallBack onScheduleOrEditMeeting" << YXLOGEnd;

    NS_I_NEM_SDK::NEErrorCode resultErrorCode = (NS_I_NEM_SDK::NEErrorCode)errorCode;
    std::string resultErrorMessage = errorMessage.toStdString();
    if (-1 == errorCode) {
        resultErrorMessage = "Failed to resolve data returned by the server.";
    } else if (200 == errorCode) {
        resultErrorCode = NS_I_NEM_SDK::NEErrorCode::ERROR_CODE_SUCCESS;
    }

    if (m_editMeetingCallback) {
        m_editMeetingCallback(resultErrorCode, resultErrorMessage);
        m_editMeetingCallback = nullptr;
        return;
    }

    if (m_scheduleMeetingCallback) {
        m_scheduleMeetingCallback(resultErrorCode, resultErrorMessage, item);
        m_scheduleMeetingCallback = nullptr;
    }
}

void NEPreMeetingServiceProcHandlerIMP::onQueryMeetingList(int errorCode,
                                                           const QString& errorMessage,
                                                           const QList<nem_sdk_interface::NEMeetingItem>& scheduledLists) {
    YXLOG_API(Info) << "CallBack onQueryMeetingList, scheduledLists: " << scheduledLists.size() << YXLOGEnd;
    NS_I_NEM_SDK::NEErrorCode resultErrorCode = (NS_I_NEM_SDK::NEErrorCode)errorCode;
    std::string resultErrorMessage = errorMessage.toStdString();
    if (-1 == errorCode) {
        resultErrorMessage = "Failed to resolve data returned by the server.";
    } else if (200 == errorCode) {
        resultErrorCode = NS_I_NEM_SDK::NEErrorCode::ERROR_CODE_SUCCESS;
    }

    if (m_getMeetingListCallback) {
        std::list<NS_I_NEM_SDK::NEMeetingItem> meetinglist;
        for (auto info : scheduledLists) {
            NS_I_NEM_SDK::NEMeetingItem item = info;
            meetinglist.push_back(item);
        }

        m_getMeetingListCallback(resultErrorCode, resultErrorMessage, meetinglist);
    }
}

void NEPreMeetingServiceProcHandlerIMP::onMeetingStatusChanged(uint64_t uniqueMeetingId, int meetingStatus) {
    YXLOG_API(Info) << "CallBack onMeetingStatusChanged, uniqueMeetingId: " << uniqueMeetingId << ", meetingStatus: " << meetingStatus << YXLOGEnd;
    auto* client = NEMeetingSDKIPCClient::getInstance();
    auto* preMeetingService = dynamic_cast<NEPremeetingServiceIPCClient*>(client->getPremeetingService());
    if (preMeetingService) {
        preMeetingService->onScheduleMeetingStatusChanged(uniqueMeetingId, (int)(meetingStatus));
    }
}
