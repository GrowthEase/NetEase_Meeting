/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_PROTOCOL_METTING_PROTOCOL_H_
#define NEM_HOSTING_MODULE_PROTOCOL_METTING_PROTOCOL_H_

#include "nem_hosting_module_protocol/config/build_config.h"
#include "nem_hosting_module_core/protocol/protocol.h"

NNEM_SDK_HOSTING_MODULE_PROTOCOL_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

enum MettingCID
{
    MettingCID_Start = 1,
    MettingCID_Start_CB,
    MettingCID_Join,
    MettingCID_Join_CB,
    MeetingCID_Leave,
    MeetingCID_Leave_CB,
    MeetingCID_GetInfo,
    MeetingCID_GetInfo_CB,
    MettingCID_PreCreate,
    MettingCID_PreCreate_CB,
    MettingCID_ScheduleMeeting,
    MettingCID_ScheduleMeeting_CB,
    MettingCID_EditMeeting,
    MettingCID_EditMeeting_CB,
    MettingCID_CancelMeeting,
    MettingCID_CancelMeeting_CB,
    MettingCID_DeleteMeeting,
    MettingCID_DeleteMeeting_CB,
    MettingCID_GetMeetingItemById,
    MettingCID_GetMeetingItemById_CB,
    MettingCID_GetMeetingList,
    MettingCID_GetMeetingList_CB,
    MettingCID_GetPresetMenuItems,
    MettingCID_GetPresetMenuItems_CB,
    MettingCID_SubscribeAudioStream,
    MettingCID_SubscribeAudioStream_CB,
    MettingCID_SubscribeAudioStreams,
    MettingCID_SubscribeAudioStreams_CB,
    MettingCID_SubscribeAllAudioStreams,
    MettingCID_SubscribeAllAudioStreams_CB,
    MettingCID_Notify_Begin = 100,
    MettingCID_Notify_MeetingStatus,
    MettingCID_Notify_MeetingMenuItemClicked,
    MettingCID_Notify_MeetingMenuItemClicked_CB,
    MettingCID_Notify_MeetingListChanged,
    MettingCID_Notify_End,
};

class StartRequest : public NEMIPCProtocolBody
{
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    NEStartMeetingParams param_;
    NEStartMeetingOptions options_;
};
using StartResponse = NEMIPCProtocolErrorInfoBody;

class JoinRequest : public NEMIPCProtocolBody
{
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    NEJoinMeetingParams param_;
    NEJoinMeetingOptions options_;
};
using JoinResponse = NEMIPCProtocolErrorInfoBody;

class LeaveMeetingRequest : public NEMIPCProtocolBody
{
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;
public:
    bool finish_ = false;
};
using LeaveMeetingResponse = NEMIPCProtocolErrorInfoBody;

class MeetingStatusChangePack : public NEMIPCProtocolBody
{
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    int status_;
    int code_;
};

class MeetingMenuItemClickedPack : public NEMIPCProtocolBody
{
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    NEMeetingMenuItem menu_item_;
};

class GetPresetMenuItemsResponse : public NEMIPCProtocolErrorInfoBody
{
public:
    virtual void OnOtherPack(Json::Value& root) const override;
    virtual void OnOtherParse(const Json::Value& root) override;

public:
    std::vector<NEMeetingMenuItem> menu_items_;
};

class GetPresetMenuItemsRequest : public NEMIPCProtocolBody
{
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    std::vector<int> menu_items_id_;
};

class GetMeetingInfoRequest : public NEMIPCProtocolBody
{
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;
};

class GetMeetingInfoResponse : public NEMIPCProtocolErrorInfoBody
{
public:
    virtual void OnOtherPack(Json::Value& root) const override;
    virtual void OnOtherParse(const Json::Value& root) override;

public:
    NEMeetingInfo meeting_info_;
};

class PreMeetingRequest : public NEMIPCProtocolBody
{
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;
public:
    NEMeetingItem param_;
};

class PreMeetingResponse : public NEMIPCProtocolErrorInfoBody
{
public:
    virtual void OnOtherPack(Json::Value& root) const override;
    virtual void OnOtherParse(const Json::Value& root) override;
public:
    NEMeetingItem param_;
};

class GetPreMeetingListRequest : public NEMIPCProtocolErrorInfoBody
{
public:
    virtual void OnOtherPack(Json::Value& root) const override;
    virtual void OnOtherParse(const Json::Value& root) override;
public:
    std::list<NEMeetingItemStatus> params_;
};

class GetPreMeetingListResponse : public NEMIPCProtocolErrorInfoBody
{
public:
    virtual void OnOtherPack(Json::Value& root) const override;
    virtual void OnOtherParse(const Json::Value& root) override;
public:
    std::list<NEMeetingItem> meeting_items;
};

class PreMeetingStatusChangePack : public NEMIPCProtocolBody
{
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    int status_;
    int64_t meetingUniqueId_;
};

class SubscribeAudioStreamsRequest : public NEMIPCProtocolBody {
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    std::vector<std::string> accountIdList_;
    bool subscribe_ = true;
};

using SubscribeAllAudioStreamsRequest = LeaveMeetingRequest;

NNEM_SDK_HOSTING_MODULE_PROTOCOL_END_DECLS

#endif//NEM_HOSTING_MODULE_PROTOCOL_METTING_PROTOCOL_H_
