/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module/service/premeeting_service.h"
#include "nem_hosting_module_protocol/protocol/meeting_protocol.h"

NNEM_SDK_HOSTING_MODULE_BEGIN_DECLS
USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

NEPreMeetingServiceIMP::NEPreMeetingServiceIMP()
    :IService(ServiceID::SID_PreMeeting),
    premeeting_status_listener_(nullptr)
{

}

NEPreMeetingServiceIMP::~NEPreMeetingServiceIMP()
{

}

NEMeetingItem NEPreMeetingServiceIMP::createScheduleMeetingItem()
{
    NEMeetingItem item;
    return item;
}

void NEPreMeetingServiceIMP::scheduleMeeting(const NEMeetingItem& item, const NEScheduleMeetingItemCallback& callback)
{
    PostTaskToProcThread(ToWeakCallback([this, item, callback]() {
        PreMeetingRequest request;
        request.param_ = item;
        SendData(MettingCID::MettingCID_ScheduleMeeting, request, IPCAsyncResponseCallback(callback));
    }));
}

void NEPreMeetingServiceIMP::getMeetingList(std::list<NEMeetingItemStatus> status, const NEGetMeetingListCallback& callback)
{
    PostTaskToProcThread(ToWeakCallback([this, status, callback]() {
        GetPreMeetingListRequest request;
        request.params_ = status;
        SendData(MettingCID::MettingCID_GetMeetingList, request, IPCAsyncResponseCallback(callback));
    }));
}

void NEPreMeetingServiceIMP::registerScheduleMeetingStatusListener(NEScheduleMeetingStatusListener* listener)
{
    premeeting_status_listener_ = listener;
}

void NEPreMeetingServiceIMP::unRegisterScheduleMeetingStatusListener(NEScheduleMeetingStatusListener* listener)
{
    premeeting_status_listener_ = listener;
}

void NEPreMeetingServiceIMP::getMeetingItemById(const int64_t& meetingUniqueId, const NEScheduleMeetingItemCallback& callback)
{
    PostTaskToProcThread(ToWeakCallback([this, meetingUniqueId, callback]() {
        PreMeetingRequest request;
        request.param_.meetingUniqueId = meetingUniqueId;
        SendData(MettingCID::MettingCID_GetMeetingItemById, request, IPCAsyncResponseCallback(callback));
    }));
}

void NEPreMeetingServiceIMP::cancelMeeting(const int64_t& meetingUniqueId, const NEOperateScheduleMeetingCallback& callback)
{
    PostTaskToProcThread(ToWeakCallback([this, meetingUniqueId, callback]() {
        PreMeetingRequest request;
        request.param_.meetingUniqueId = meetingUniqueId;
        SendData(MettingCID::MettingCID_CancelMeeting, request, IPCAsyncResponseCallback(callback));
    }));
}

void NEPreMeetingServiceIMP::editMeeting(const NEMeetingItem& item, const NEOperateScheduleMeetingCallback& callback)
{
    PostTaskToProcThread(ToWeakCallback([this, item, callback]() {
        PreMeetingRequest request;
        request.param_.meetingUniqueId = item.meetingUniqueId;
        request.param_.meetingId = item.meetingId;
        request.param_.subject = item.subject;
        request.param_.startTime = item.startTime;
        request.param_.endTime = item.endTime;
        request.param_.password = item.password;
        request.param_.setting.attendeeAudioOff = item.setting.attendeeAudioOff;
		request.param_.enableLive = item.enableLive;
        request.param_.liveWebAccessControlLevel = item.liveWebAccessControlLevel;
		request.param_.liveUrl = item.liveUrl;
        request.param_.setting.cloudRecordOn  = item.setting.cloudRecordOn ;
        SendData(MettingCID::MettingCID_EditMeeting, request, IPCAsyncResponseCallback(callback));
    }));
}

void NEPreMeetingServiceIMP::OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb)
{
    switch (cid)
    {
    case MettingCID::MettingCID_PreCreate_CB:
    {
        PreMeetingResponse response;
        if (!response.Parse(data))
        {
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        }

        NEScheduleMeetingItemCallback premeeting_cb = cb.GetResponseCallback<NEScheduleMeetingItemCallback>();
        if (premeeting_cb != nullptr)
        {
            premeeting_cb(response.error_code_, response.error_msg_, response.param_);
        }

    }
    break;

    case MettingCID::MettingCID_ScheduleMeeting_CB:
    {
        PreMeetingResponse response;
        if (!response.Parse(data))
        {
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        }

        NEScheduleMeetingItemCallback callback = cb.GetResponseCallback<NEScheduleMeetingItemCallback>();
        if ( callback )
        {
            callback(response.error_code_, response.error_msg_, response.param_);
        }
    }
    break;

    case MettingCID::MettingCID_EditMeeting_CB:
    {
        PreMeetingResponse response;
        if (!response.Parse(data))
        {
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        }
        NEOperateScheduleMeetingCallback callback = cb.GetResponseCallback<NEOperateScheduleMeetingCallback>();
        if (callback)
        {
            callback(response.error_code_, response.error_msg_);
        }
    }
    break;

    case MettingCID::MettingCID_CancelMeeting_CB:
    {
        PreMeetingResponse response;
        if (!response.Parse(data))
        {
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        }
        NEOperateScheduleMeetingCallback callback = cb.GetResponseCallback<NEOperateScheduleMeetingCallback>();
        if (callback)
        {
            callback(response.error_code_, response.error_msg_);
        }
    }
    break;

    case MettingCID::MettingCID_DeleteMeeting_CB:
    {
        PreMeetingResponse response;
        if (!response.Parse(data))
        {
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        }
        NEOperateScheduleMeetingCallback callback = cb.GetResponseCallback<NEOperateScheduleMeetingCallback>();
        if (callback)
        {
            callback(response.error_code_, response.error_msg_);
        }
    }
    break;

    case MettingCID::MettingCID_GetMeetingItemById_CB:
    {
        PreMeetingResponse response;
        if (!response.Parse(data))
        {
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        }
        NEScheduleMeetingItemCallback callback = cb.GetResponseCallback<NEScheduleMeetingItemCallback>();
        if (callback)
        {
            callback(response.error_code_, response.error_msg_, response.param_);
        }
    }
    break;

    case MettingCID::MettingCID_GetMeetingList_CB:
    {
        GetPreMeetingListResponse response;
        if (!response.Parse(data))
        {
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        }
        NEGetMeetingListCallback callback = cb.GetResponseCallback<NEGetMeetingListCallback>();
        if (callback)
        {
            callback(response.error_code_, response.error_msg_, response.meeting_items);
        }
    }
    break;

    default:
        break;
    }
}

void NEPreMeetingServiceIMP::OnPack(int cid, const std::string & data, uint64_t sn)
{
    switch (cid)
    {
    case MettingCID::MettingCID_Notify_MeetingListChanged:
    {
        PreMeetingStatusChangePack pack;
        if (pack.Parse(data) && premeeting_status_listener_)
        {
            premeeting_status_listener_->onScheduleMeetingStatusChanged(pack.meetingUniqueId_, pack.status_);
        }
    }
    break;

    default:
        break;
    }
}


NNEM_SDK_HOSTING_MODULE_END_DECLS



