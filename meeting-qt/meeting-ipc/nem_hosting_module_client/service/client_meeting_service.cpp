/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module_client/service/client_meeting_service.h"
#include "nem_hosting_module_protocol/protocol/meeting_protocol.h"

NNEM_SDK_HOSTING_MODULE_CLIENT_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

NEMeetingServiceIMP::NEMeetingServiceIMP()
    : IService(ServiceID::SID_Metting) {}

NEMeetingServiceIMP::~NEMeetingServiceIMP() {}

void NEMeetingServiceIMP::OnLoad() {}

void NEMeetingServiceIMP::OnRelease() {}

void NEMeetingServiceIMP::startMeeting(const NEStartMeetingParams& param, const NEStartMeetingOptions& opts, const NEStartMeetingCallback& cb) {
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onStartMeeting(param, opts, cb);
}

void NEMeetingServiceIMP::joinMeeting(const NEJoinMeetingParams& param, const NEJoinMeetingOptions& opts, const NEJoinMeetingCallback& cb) {
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onJoinMeeting(param, opts, cb);
}

void NEMeetingServiceIMP::leaveMeeting(bool finish, const NELeaveMeetingCallback& cb) {
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onLeaveMeeting(finish, cb);
}

void NEMeetingServiceIMP::getCurrentMeetingInfo(const NEGetMeetingInfoCallback& cb) {
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onGetCurrentMeetingInfo(cb);
}

void NEMeetingServiceIMP::addMeetingStatusListener(NEMeetingStatusListener* listener) {}

void NEMeetingServiceIMP::setOnInjectedMenuItemClickListener(NEMeetingOnInjectedMenuItemClickListener* listener) {}

void NEMeetingServiceIMP::onMeetingStatusChanged(int status, int code) {
    MeetingStatusChangePack pack;
    pack.status_ = status;
    pack.code_ = code;
    SendData(MettingCID::MettingCID_Notify_MeetingStatus, pack, 0);
}

void NEMeetingServiceIMP::onInjectedMenuItemClick(const NEMeetingMenuItem& meeting_menu_item) {
    MeetingMenuItemClickedPack pack;
    pack.menu_item_ = meeting_menu_item;
    SendData(MettingCID::MettingCID_Notify_MeetingMenuItemClicked, pack, 0);
}

void NEMeetingServiceIMP::getBuiltinMenuItems(const std::vector<int>& menuItemsId, const NEGetPresetMenuItemsCallback& cb) {
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onGetPresetMenuItems(menuItemsId, cb);
}

void NEMeetingServiceIMP::subscribeRemoteAudioStream(const std::string& accountId, bool subscribe, const NEEmptyCallback& cb) {
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onSubscribeRemoteAudioStream(accountId, subscribe, cb);
}
void NEMeetingServiceIMP::subscribeRemoteAudioStreams(const std::vector<std::string>& accountIdList,
                                                           bool subscribe,
                                                           const NEEmptyCallback& cb) {
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onSubscribeRemoteAudioStreams(accountIdList, subscribe, cb);
}
void NEMeetingServiceIMP::subscribeAllRemoteAudioStreams(bool subscribe, const NEEmptyCallback& cb) {
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onSubscribeAllRemoteAudioStreams(subscribe, cb);
}

void NEMeetingServiceIMP::OnPack(int cid, const std::string& data, uint64_t sn) {
    switch (cid) {
        case MettingCID::MettingCID_Start: {
            StartRequest request;
            if (request.Parse(data)) {
                startMeeting(request.param_, request.options_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                 StartResponse response;
                                 response.error_code_ = error_code;
                                 response.error_msg_ = error_msg;
                                 SendData(MettingCID::MettingCID_Start_CB, response, sn);
                             }));
            }
        } break;
        case MettingCID::MettingCID_Join: {
            JoinRequest request;
            if (request.Parse(data)) {
                joinMeeting(request.param_, request.options_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                JoinResponse response;
                                response.error_code_ = error_code;
                                response.error_msg_ = error_msg;
                                SendData(MettingCID::MettingCID_Join_CB, response, sn);
                            }));
            }
        } break;
        case MeetingCID_Leave: {
            LeaveMeetingRequest request;
            if (request.Parse(data)) {
                leaveMeeting(request.finish_, [this, sn](NEErrorCode error_code, const std::string& error_msg) {
                    LeaveMeetingResponse response;
                    response.error_code_ = error_code;
                    response.error_msg_ = error_msg;
                    SendData(MettingCID::MeetingCID_Leave_CB, response, sn);
                });
            }
        } break;
        case MettingCID::MeetingCID_GetInfo: {
            GetMeetingInfoRequest request;
            if (request.Parse(data)) {
                getCurrentMeetingInfo(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_message, const NEMeetingInfo& meeting_info) {
                        GetMeetingInfoResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_message;
                        response.meeting_info_ = meeting_info;
                        SendData(MettingCID::MeetingCID_GetInfo_CB, response, sn);
                    }));
            }
        } break;
        case MettingCID::MettingCID_GetPresetMenuItems: {
            GetPresetMenuItemsRequest request;
            if (request.Parse(data)) {
                getBuiltinMenuItems(request.menu_items_id_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_message,
                                                                                      std::vector<NEMeetingMenuItem> menu_items) {
                                        GetPresetMenuItemsResponse response;
                                        response.error_code_ = error_code;
                                        response.error_msg_ = error_message;
                                        response.menu_items_ = menu_items;
                                        SendData(MettingCID::MettingCID_GetPresetMenuItems_CB, response, sn);
                                    }));
            }
        } break;
        case MettingCID::MettingCID_Notify_MeetingMenuItemClicked_CB: {
            MeetingMenuItemClickedPack response;
            if (response.Parse(data)) {
                if (_ProcHandler() != nullptr)
                    _ProcHandler()->onInjectedMenuItemClickExReturn(response.menu_item_.itemId, response.menu_item_.itemGuid,
                                                                    response.menu_item_.itemCheckedIndex);
            }
        } break;
        case MettingCID::MettingCID_SubscribeAudioStream: {
            SubscribeAudioStreamsRequest request;
            if (request.Parse(data)) {
                subscribeRemoteAudioStream(request.accountIdList_.front(), request.subscribe_,
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_message) {
                        NEMIPCProtocolErrorInfoBody response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_message;
                        SendData(MettingCID::MettingCID_SubscribeAudioStream_CB, response, sn);
                    }));
            }
        } break;
        case MettingCID::MettingCID_SubscribeAudioStreams: {
            SubscribeAudioStreamsRequest request;
            if (request.Parse(data)) {
                subscribeRemoteAudioStreams(request.accountIdList_, request.subscribe_,
                                                 ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_message) {
                                                     NEMIPCProtocolErrorInfoBody response;
                                                     response.error_code_ = error_code;
                                                     response.error_msg_ = error_message;
                                                     SendData(MettingCID::MettingCID_SubscribeAudioStreams_CB, response, sn);
                                                 }));
            }
        } break;
        case MettingCID::MettingCID_SubscribeAllAudioStreams: {
            SubscribeAllAudioStreamsRequest request;
            if (request.Parse(data)) {
                subscribeAllRemoteAudioStreams(request.finish_,
                                           ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_message) {
                                               NEMIPCProtocolErrorInfoBody response;
                                               response.error_code_ = error_code;
                                               response.error_msg_ = error_message;
                                               SendData(MettingCID::MettingCID_SubscribeAllAudioStreams_CB, response, sn);
                                           }));
            }
        } break;
    }
}

NNEM_SDK_HOSTING_MODULE_CLIENT_END_DECLS
