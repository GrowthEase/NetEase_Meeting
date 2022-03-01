/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module_client/service/client_premeeting_service.h"
#include "nem_hosting_module_protocol/protocol/meeting_protocol.h"
#include "nem_hosting_module_client/global/client_global.h"

NNEM_SDK_HOSTING_MODULE_CLIENT_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

NEPremeetingServiceIMP::NEPremeetingServiceIMP()
    :IService(ServiceID::SID_PreMeeting)
{

}

NEPremeetingServiceIMP::~NEPremeetingServiceIMP()
{

}

NEMeetingItem NEPremeetingServiceIMP::createScheduleMeetingItem()
{
    NEMeetingItem item;
    return item;
}

void NEPremeetingServiceIMP::scheduleMeeting(const NEMeetingItem& item, const NEPreMeetingService::NEScheduleMeetingItemCallback& callback)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onScheduleMeeting(item, callback);
}

void NEPremeetingServiceIMP::getMeetingItemById(const int64_t&meetingUniqueId, const NEPreMeetingService::NEScheduleMeetingItemCallback& callback)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onGetMeetingItemById(meetingUniqueId, callback);
}

void NEPremeetingServiceIMP::cancelMeeting(const int64_t&meetingUniqueId, const NEPreMeetingService::NEOperateScheduleMeetingCallback& callback)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onCancelMeeting(meetingUniqueId, callback);
}

void NEPremeetingServiceIMP::editMeeting(const NEMeetingItem& item, const NEOperateScheduleMeetingCallback& callback)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onEditMeeting(item, callback);
}

void NEPremeetingServiceIMP::getMeetingList(std::list<NEMeetingItemStatus> status, const NEPreMeetingService::NEGetMeetingListCallback& callback)
{
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onGetMeetingList(status, callback);
}

void NEPremeetingServiceIMP::registerScheduleMeetingStatusListener(NEScheduleMeetingStatusListener* listener)
{

}

void NEPremeetingServiceIMP::unRegisterScheduleMeetingStatusListener(NEScheduleMeetingStatusListener* listener)
{

}

void NEPremeetingServiceIMP::onScheduleMeetingStatusChanged(uint64_t uniqueMeetingId, const int& meetingStatus)
{
    PreMeetingStatusChangePack pack;
    pack.status_ = meetingStatus;
    pack.meetingUniqueId_ = uniqueMeetingId;
    SendData(MettingCID::MettingCID_Notify_MeetingListChanged, pack, 0);
}

void NEPremeetingServiceIMP::OnLoad()
{

}

void NEPremeetingServiceIMP::OnRelease()
{

}

void NEPremeetingServiceIMP::OnPack(int cid, const std::string& data, uint64_t sn)
{
    switch (cid)
    {
    case MettingCID::MettingCID_PreCreate:
    {
    }
    break;
    case MettingCID::MettingCID_ScheduleMeeting:
    {
        PreMeetingRequest request;
        if (request.Parse(data))
        {
            scheduleMeeting(request.param_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const NEMeetingItem & item) {
                PreMeetingResponse response;
                response.error_code_ = error_code;
                response.error_msg_ = error_msg;
                response.param_ = item;
                SendData(MettingCID::MettingCID_ScheduleMeeting_CB, response, sn);
            }));
        }
    }
    break;
    case MettingCID::MettingCID_EditMeeting:
    {
        PreMeetingRequest request;
        if (request.Parse(data))
        {
             editMeeting(request.param_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                 PreMeetingResponse response;
                 response.error_code_ = error_code;
                 response.error_msg_ = error_msg;
                 SendData(MettingCID::MettingCID_EditMeeting_CB, response, sn);
             }));
        }
    }
    break;

    case MettingCID::MettingCID_CancelMeeting:
    {
        PreMeetingRequest request;
        if (request.Parse(data))
        {
            cancelMeeting(request.param_.meetingUniqueId, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                PreMeetingResponse response;
                response.error_code_ = error_code;
                response.error_msg_ = error_msg;

                SendData(MettingCID::MettingCID_CancelMeeting_CB, response, sn);
            }));
        }
    }
    break;

    case MettingCID::MettingCID_DeleteMeeting:
    {
//         PreMeetingRequest request;
//         if (request.Parse(data))
//         {
//             deleteMeeting(request.param_.meetingUniqueId, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
//                 PreMeetingResponse response;
//                 response.error_code_ = error_code;
//                 response.error_msg_ = error_msg;
// 
//                 SendData(MettingCID::MettingCID_DeleteMeeting_CB, response, sn);
//             }));
//         }
    }
    break;

    case MettingCID::MettingCID_GetMeetingItemById :
    {
        PreMeetingRequest request;
        if (request.Parse(data))
        {
            getMeetingItemById(request.param_.meetingUniqueId, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const NEMeetingItem& item) {
                PreMeetingResponse response;
                response.error_code_ = error_code;
                response.error_msg_ = error_msg;
                response.param_ = item;
                SendData(MettingCID::MettingCID_GetMeetingItemById_CB, response, sn);
            }));
        }
    }
    break;

    case MettingCID::MettingCID_GetMeetingList: 
    {
        GetPreMeetingListRequest request;
        if (request.Parse(data))
        {
            getMeetingList(request.params_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const std::list<NEMeetingItem>& packInfo) {
                GetPreMeetingListResponse response;
                response.error_code_ = error_code;
                response.error_msg_ = error_msg;
                std::copy(packInfo.begin(), packInfo.end(), std::back_inserter(response.meeting_items));
                SendData(MettingCID::MettingCID_GetMeetingList_CB, response, sn);
            }));
        }
    }
    break;

    default:
        break;
    }
}

NNEM_SDK_HOSTING_MODULE_CLIENT_END_DECLS