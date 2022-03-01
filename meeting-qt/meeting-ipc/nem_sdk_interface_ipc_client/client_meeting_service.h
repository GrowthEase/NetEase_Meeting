/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_METTING_SERVICE_H_
#define NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_METTING_SERVICE_H_

#include "meeting_service.h"
#include "client_prochandler_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

class NEM_SDK_INTERFACE_EXPORT NEMeetingServiceProcHandler : public NEProcHandler
{
public:
    virtual bool onStartMeeting(const NEStartMeetingParams& param, const NEStartMeetingOptions& opts, const NEMeetingService::NEStartMeetingCallback& cb) = 0;
    virtual bool onJoinMeeting(const NEJoinMeetingParams& param, const NEJoinMeetingOptions& opts, const NEMeetingService::NEJoinMeetingCallback& cb) = 0;
    virtual bool onLeaveMeeting(bool finish, const NEMeetingService::NELeaveMeetingCallback& cb) = 0;
    virtual bool onGetCurrentMeetingInfo(const NEMeetingService::NEGetMeetingInfoCallback& cb) = 0;
    virtual void onGetPresetMenuItems(const std::vector<int>& menuItemsId, const NEMeetingService::NEGetPresetMenuItemsCallback& cb) = 0;
    virtual void onInjectedMenuItemClickExReturn(int itemId, const std::string& itemGuid, int itemCheckedIndex) = 0;
    virtual void onSubscribeRemoteAudioStream(const std::string& accountId, bool subscribe, const NEEmptyCallback& cb) = 0;
    virtual void onSubscribeRemoteAudioStreams(const std::vector<std::string>& accountIdList, bool subscribe, const NEEmptyCallback& cb) = 0;
    virtual void onSubscribeAllRemoteAudioStreams(bool subscribe, const NEEmptyCallback& cb) = 0;
};

class NEM_SDK_INTERFACE_EXPORT NEMeetingServiceIPCClient :
    public NEServiceIPCClient<NEMeetingServiceProcHandler, NEMeetingService>
{
public:
    virtual void onMeetingStatusChanged(int status, int code) = 0;
    virtual void onInjectedMenuItemClick(const NEMeetingMenuItem& meeting_menu_item) = 0;
};

NNEM_SDK_INTERFACE_END_DECLS
#endif // NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_METTING_SERVICE_H_

