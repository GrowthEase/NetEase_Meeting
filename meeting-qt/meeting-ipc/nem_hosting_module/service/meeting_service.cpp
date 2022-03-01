/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module/service/meeting_service.h"
#include "nem_hosting_module_protocol/protocol/meeting_protocol.h"

NNEM_SDK_HOSTING_MODULE_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

NEMeetingServiceIMP::NEMeetingServiceIMP()
    : IService(ServiceID::SID_Metting)
    , meeting_status_(MEETING_STATUS_IDLE)
    , meeting_srv_listener_(nullptr)
    , meeting_menu_item_listener_(nullptr) {}

NEMeetingServiceIMP::~NEMeetingServiceIMP() {}

void NEMeetingServiceIMP::startMeeting(const NEStartMeetingParams& param, const NEStartMeetingOptions& opts, const NEStartMeetingCallback& cb) {
    PostTaskToProcThread(ToWeakCallback([this, param, opts, cb]() {
        StartRequest request;
        request.param_ = param;
        request.options_ = opts;
        SendData(MettingCID::MettingCID_Start, request, IPCAsyncResponseCallback(cb));
    }));
}

void NEMeetingServiceIMP::joinMeeting(const NEJoinMeetingParams& param, const NEJoinMeetingOptions& opts, const NEJoinMeetingCallback& cb) {
    PostTaskToProcThread(ToWeakCallback([this, param, opts, cb]() {
        JoinRequest request;
        request.param_ = param;
        request.options_ = opts;
        SendData(MettingCID::MettingCID_Join, request, IPCAsyncResponseCallback(cb));
    }));
}

void NEMeetingServiceIMP::leaveMeeting(bool finish, const NELeaveMeetingCallback& cb) {
    /*if (meeting_status_ != MEETING_STATUS_INMEETING)
    {
        cb(ERROR_CODE_FAILED, "Not in meeting");
        return;
    }*/

    PostTaskToProcThread(ToWeakCallback([this, cb]() {
        LeaveMeetingRequest request;
        SendData(MettingCID::MeetingCID_Leave, request, IPCAsyncResponseCallback(cb));
    }));
}

void NEMeetingServiceIMP::getCurrentMeetingInfo(const NEGetMeetingInfoCallback& cb) {
    PostTaskToProcThread(ToWeakCallback([this, cb]() {
        GetMeetingInfoRequest request;
        SendData(MettingCID::MeetingCID_GetInfo, request, IPCAsyncResponseCallback(cb));
    }));
}

NEMeetingStatus NEMeetingServiceIMP::getMeetingStatus() {
    return meeting_status_;
}

void NEMeetingServiceIMP::addMeetingStatusListener(NEMeetingStatusListener* listener) {
    meeting_srv_listener_ = listener;
}

void NEMeetingServiceIMP::setOnInjectedMenuItemClickListener(NEMeetingOnInjectedMenuItemClickListener* listener) {
    meeting_menu_item_listener_ = listener;
}

void NEMeetingServiceIMP::getBuiltinMenuItems(const std::vector<int>& menuItemsId, const NEGetPresetMenuItemsCallback& cb) {
    PostTaskToProcThread(ToWeakCallback([this, menuItemsId, cb]() {
        GetPresetMenuItemsRequest request;
        request.menu_items_id_ = menuItemsId;
        SendData(MettingCID::MettingCID_GetPresetMenuItems, request, IPCAsyncResponseCallback(cb));
    }));
}

void NEMeetingServiceIMP::subscribeRemoteAudioStream(const std::string& accountId, bool subscribe, const NEEmptyCallback& cb) {
    PostTaskToProcThread(ToWeakCallback([this, accountId, subscribe, cb]() {
        SubscribeAudioStreamsRequest request;
        request.accountIdList_.push_back(accountId);
        request.subscribe_ = subscribe;
        SendData(MettingCID::MettingCID_SubscribeAudioStream, request, IPCAsyncResponseCallback(cb));
    }));
}
void NEMeetingServiceIMP::subscribeRemoteAudioStreams(const std::vector<std::string>& accountIdList,
                                                           bool subscribe,
                                                           const NEEmptyCallback& cb) {
    PostTaskToProcThread(ToWeakCallback([this, accountIdList, subscribe, cb]() {
        SubscribeAudioStreamsRequest request;
        request.accountIdList_ = accountIdList;
        request.subscribe_ = subscribe;
        SendData(MettingCID::MettingCID_SubscribeAudioStreams, request, IPCAsyncResponseCallback(cb));
    }));
}

void NEMeetingServiceIMP::subscribeAllRemoteAudioStreams(bool subscribe, const NEEmptyCallback& cb) {
    PostTaskToProcThread(ToWeakCallback([this, subscribe, cb]() {
        SubscribeAllAudioStreamsRequest request;
        request.finish_ = subscribe;
        SendData(MettingCID::MettingCID_SubscribeAllAudioStreams, request, IPCAsyncResponseCallback(cb));
    }));
}

void NEMeetingServiceIMP::OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb) {
    switch (cid) {
        case MettingCID::MettingCID_Start_CB: {
            StartResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEStartMeetingCallback start_cb = cb.GetResponseCallback<NEStartMeetingCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case MettingCID::MettingCID_Join_CB: {
            JoinResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEStartMeetingCallback join_cb = cb.GetResponseCallback<NEJoinMeetingCallback>();
            if (join_cb != nullptr)
                join_cb(response.error_code_, response.error_msg_);
        } break;
        case MettingCID::MeetingCID_Leave_CB: {
            LeaveMeetingResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NELeaveMeetingCallback leave_cb = cb.GetResponseCallback<NELeaveMeetingCallback>();
            if (leave_cb != nullptr)
                leave_cb(response.error_code_, response.error_msg_);
        } break;
        case MettingCID::MeetingCID_GetInfo_CB: {
            GetMeetingInfoResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            auto get_meeting_info_cb = cb.GetResponseCallback<NEGetMeetingInfoCallback>();
            if (get_meeting_info_cb)
                get_meeting_info_cb(response.error_code_, response.error_msg_, response.meeting_info_);
        } break;
        case MettingCID::MettingCID_GetPresetMenuItems_CB: {
            GetPresetMenuItemsResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            auto get_preset_menu_items_cb = cb.GetResponseCallback<NEGetPresetMenuItemsCallback>();
            if (get_preset_menu_items_cb)
                get_preset_menu_items_cb(response.error_code_, response.error_msg_, response.menu_items_);
        } break;
        case MettingCID::MettingCID_SubscribeAudioStream_CB:
            {
                NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback cb_ = cb.GetResponseCallback<NEEmptyCallback>();
            if (cb_ != nullptr)
                cb_(response.error_code_, response.error_msg_);
        } break;
        case MettingCID::MettingCID_SubscribeAudioStreams_CB:
            {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback cb_ = cb.GetResponseCallback<NEEmptyCallback>();
            if (cb_ != nullptr)
                cb_(response.error_code_, response.error_msg_);
        } break;
        case MettingCID::MettingCID_SubscribeAllAudioStreams_CB:
            {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback cb_ = cb.GetResponseCallback<NEEmptyCallback>();
            if (cb_ != nullptr)
                cb_(response.error_code_, response.error_msg_);
        } break;
    }
}

void NEMeetingServiceIMP::OnPack(int cid, const std::string& data, uint64_t sn) {
    switch (cid) {
        case MettingCID::MettingCID_Notify_MeetingStatus: {
            MeetingStatusChangePack change_pack;
            if (change_pack.Parse(data)) {
                meeting_status_ = (NEMeetingStatus)change_pack.status_;
                if (meeting_srv_listener_ != nullptr)
                    meeting_srv_listener_->onMeetingStatusChanged(change_pack.status_, change_pack.code_);
            }
        } break;
        case MettingCID::MettingCID_Notify_MeetingMenuItemClicked: {
            MeetingMenuItemClickedPack menu_item_pack;
            if (menu_item_pack.Parse(data) && meeting_menu_item_listener_ != nullptr) {
                if (menu_item_pack.menu_item_.itemTitle2.empty() || menu_item_pack.menu_item_.itemImage2.empty()) {
                    meeting_menu_item_listener_->onInjectedMenuItemClick(menu_item_pack.menu_item_);
                } else {
                    meeting_menu_item_listener_->onInjectedMenuItemClickEx(
                        menu_item_pack.menu_item_, [this](int itemId, const std::string& itemGuid, int itemCheckedIndex) {
                            PostTaskToProcThread(ToWeakCallback([this, itemId, itemGuid, itemCheckedIndex]() {
                                MeetingMenuItemClickedPack request;
                                request.menu_item_.itemId = itemId;
                                request.menu_item_.itemGuid = itemGuid;
                                request.menu_item_.itemCheckedIndex = itemCheckedIndex;
                                SendData(MettingCID::MettingCID_Notify_MeetingMenuItemClicked_CB, request, 0);
                            }));
                        });
                }
            }
        } break;
    }
}

NNEM_SDK_HOSTING_MODULE_END_DECLS
