/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

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
    YXLOG_API(Info) << "onScheduleMeeting, starttime = " << item.startTime << " endtime = " << item.endTime << YXLOGEnd;
    m_scheduleMeetingCallback = callback;

    Invoker::getInstance()->execute([=]() {
        NERoomItem params;
        params.roomId = item.meetingId;
        params.endTime = item.endTime;
        params.startTime = item.startTime;
        params.subject = item.subject;
        params.password = item.password;
        params.setting.attendeeAudioOff = item.setting.attendeeAudioOff;
        params.live.enable = item.enableLive;
        params.live.liveWebAccessControlLevel = (NERoomLiveAuthLevel)((int)item.liveWebAccessControlLevel);
        params.setting.cloudRecordOn = item.setting.cloudRecordOn;
        if (item.setting.scene.roleTypes.empty() == false) {
            params.setting.scene.code = item.setting.scene.code;
            for (auto it : item.setting.scene.roleTypes) {
                NERoomRoleConfiguration config;
                config.roleType = (NERoomRoleType)it.roleType;
                config.maxCount = it.maxCount;
                params.setting.scene.roleTypes.push_back(config);
            }
        }

       // params.isSupportLive = GlobalManager::getInstance()->getGlobalConfig()->getLiveStreamAbility();
        PreMeetingManager::getInstance()->scheduleMeeting(params);
    });
}

void NEPreMeetingServiceProcHandlerIMP::onEditMeeting(const nem_sdk_interface::NEMeetingItem& item,
                                                      const nem_sdk_interface::NEPreMeetingService::NEOperateScheduleMeetingCallback& callback) {
    YXLOG_API(Info) << "onEditMeeting." << YXLOGEnd;
    m_editMeetingCallback = callback;

    Invoker::getInstance()->execute([=]() {
        NERoomItem params;
        params.roomId = item.meetingId;
        params.endTime = item.endTime;
        params.startTime = item.startTime;
        params.subject = item.subject;
        params.password = item.password;
        params.setting.attendeeAudioOff = item.setting.attendeeAudioOff;
        params.roomUniqueId = item.meetingUniqueId;
        params.live.enable = item.enableLive;
        params.live.liveWebAccessControlLevel = (NERoomLiveAuthLevel)item.liveWebAccessControlLevel;
       // params.isSupportLive = GlobalManager::getInstance()->getGlobalConfig()->getLiveStreamAbility();
        params.setting.cloudRecordOn = item.setting.cloudRecordOn;
        PreMeetingManager::getInstance()->editSchedule(params);
    });
}

void NEPreMeetingServiceProcHandlerIMP::onCancelMeeting(const int64_t& meetingUniqueId,
                                                        const nem_sdk_interface::NEPreMeetingService::NEOperateScheduleMeetingCallback& callback) {
    YXLOG_API(Info) << "onCancelMeeting." << YXLOGEnd;
    m_editMeetingCallback = callback;
    Invoker::getInstance()->execute([=]() { PreMeetingManager::getInstance()->cancelSchedule(meetingUniqueId); });
}


void NEPreMeetingServiceProcHandlerIMP::onGetMeetingItemById(const int64_t& meetingUniqueId,
                                                             const nem_sdk_interface::NEPreMeetingService::NEScheduleMeetingItemCallback& callback) {
    YXLOG_API(Info) << "onGetMeetingItemById." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        NERoomItem info;
        bool bret = PreMeetingManager::getInstance()->getMeetingInfo(meetingUniqueId, info);
        NS_I_NEM_SDK::NEErrorCode errorCode = NS_I_NEM_SDK::ERROR_CODE_FAILED;
        if (bret)
            errorCode = NS_I_NEM_SDK::ERROR_CODE_SUCCESS;
        std::string errorMessage = "";
        NS_I_NEM_SDK::NEMeetingItem item;
        item.meetingId = info.roomId;
        item.status = (nem_sdk_interface::NEMeetingItemStatus)(info.status);
        item.startTime = info.startTime;
        item.endTime = info.endTime;
        item.subject = info.subject;
        item.setting.attendeeAudioOff = info.setting.attendeeAudioOff;
        item.password = info.password;
        item.meetingUniqueId = info.roomUniqueId;
        item.createTime = info.createTime;
        item.updateTime = info.updateTime;
        item.enableLive = info.live.enable;
        item.liveUrl = info.live.liveUrl;
        item.liveWebAccessControlLevel = (nem_sdk_interface::NEMettingLiveAuthLevel)info.live.liveWebAccessControlLevel;
        item.setting.cloudRecordOn = info.setting.cloudRecordOn;
        if (callback != nullptr)
            callback(errorCode, errorMessage, item);
    });
}

void NEPreMeetingServiceProcHandlerIMP::onGetMeetingList(std::list<NS_I_NEM_SDK::NEMeetingItemStatus> status,
                                                         const nem_sdk_interface::NEPreMeetingService::NEGetMeetingListCallback& callback) {
    YXLOG_API(Info) << "onGetMeetingList." << YXLOGEnd;
    m_getMeetingListCallback = callback;
    Invoker::getInstance()->execute([=]() {
        std::list<NERoomItemStatus> options;
        for (auto& state : status) {
            switch (state) {
                case MEETING_INVALID:
                    break;
                case MEETING_INIT:
                    options.push_back(ROOM_INIT);
                    break;
                case MEETING_STARTED:
                    options.push_back(ROOM_STARTED);
                    break;
                case MEETING_ENDED:
                    options.push_back(ROOM_ENDED);
                    break;
                case MEETING_CANCEL:
                    options.push_back(ROOM_CANCEL);
                    break;
                case MEETING_RECYCLED:
                    options.push_back(ROOM_RECYCLED);
                    break;
            }
        }
        PreMeetingManager::getInstance()->getMeetingList(options);
    });
}

void NEPreMeetingServiceProcHandlerIMP::onScheduleOrEditMeeting(int errorCode, const QString& errorMessage, const NERoomItem& info) {
    YXLOG_API(Info) << "onScheduleOrEditMeeting" << YXLOGEnd;

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
    }

    if (m_scheduleMeetingCallback) {
        NS_I_NEM_SDK::NEMeetingItem item;
        item.meetingId = info.roomId;
        item.meetingUniqueId = info.roomUniqueId;
        item.password = info.password;
        item.subject = info.subject;
        item.startTime = info.startTime;
        item.endTime = info.endTime;
        item.status = (NS_I_NEM_SDK::NEMeetingItemStatus)info.status;
        item.createTime = info.createTime;
        item.updateTime = info.updateTime;
        item.setting.attendeeAudioOff = info.setting.attendeeAudioOff;

        if (info.setting.scene.roleTypes.empty() == false) {
            item.setting.scene.code = info.setting.scene.code;
            item.setting.scene.roleTypes.clear();
            for (auto it : info.setting.scene.roleTypes) {
                NEMeetingRoleConfiguration config;
                config.roleType = (NEMeetingRoleType)it.roleType;
                config.maxCount = it.maxCount;
                item.setting.scene.roleTypes.push_back(config);
            }
        }

        item.enableLive = info.live.enable;
        item.liveUrl = info.live.liveUrl;
        item.setting.cloudRecordOn = info.setting.cloudRecordOn;

        m_scheduleMeetingCallback(resultErrorCode, resultErrorMessage, item);
        m_scheduleMeetingCallback = nullptr;
    }
}

void NEPreMeetingServiceProcHandlerIMP::onQueryMeetingList(int errorCode,
                                                           const QString& errorMessage,
                                                           const QList<NERoomItem>& scheduledLists) {
    YXLOG_API(Info) << "Query meeting list in proc handler: " << scheduledLists.size() << YXLOGEnd;
    NS_I_NEM_SDK::NEErrorCode resultErrorCode = (NS_I_NEM_SDK::NEErrorCode)errorCode;
    std::string resultErrorMessage = errorMessage.toStdString();
    if (-1 == errorCode) {
        resultErrorMessage = "Failed to resolve data returned by the server.";
    } else if (200 == errorCode) {
        resultErrorCode = NS_I_NEM_SDK::NEErrorCode::ERROR_CODE_SUCCESS;
    }

    std::list<NS_I_NEM_SDK::NEMeetingItem> meetinglist;
    for (auto info : scheduledLists) {
        NS_I_NEM_SDK::NEMeetingItem item;
        item.meetingId = info.roomId;
        item.status = (nem_sdk_interface::NEMeetingItemStatus)(info.status);
        item.startTime = info.startTime;
        item.endTime = info.endTime;
        item.subject = info.subject;
        item.setting.attendeeAudioOff = info.setting.attendeeAudioOff;
        item.password = info.password;
        item.meetingUniqueId = info.roomUniqueId;
        item.createTime = info.createTime;
        item.updateTime = info.updateTime;
        item.enableLive = info.live.enable;
        item.liveUrl = info.live.liveUrl;
        item.liveWebAccessControlLevel = (nem_sdk_interface::NEMettingLiveAuthLevel)info.live.liveWebAccessControlLevel;
        YXLOG(Info) << "unique meeting ID: " << info.roomUniqueId << ", topic: " << info.subject << ", meeting ID: " << info.roomId
                  << ", meeting status: " << info.status << YXLOGEnd;
        meetinglist.push_back(item);
    }

    if (m_getMeetingListCallback)
        m_getMeetingListCallback(resultErrorCode, resultErrorMessage, meetinglist);
}

void NEPreMeetingServiceProcHandlerIMP::onMeetingStatusChanged(uint64_t uniqueMeetingId, int meetingStatus) {
    YXLOG_API(Info) << "onMeetingStatusChanged, uniqueMeetingId: " << uniqueMeetingId << " ,meetingStatus:" << meetingStatus << YXLOGEnd;
    auto* client = NEMeetingSDKIPCClient::getInstance();
    auto* preMeetingService = dynamic_cast<NEPremeetingServiceIPCClient*>(client->getPremeetingService());
    if (preMeetingService) {
        preMeetingService->onScheduleMeetingStatusChanged(uniqueMeetingId, (int)(meetingStatus));
    }
}
