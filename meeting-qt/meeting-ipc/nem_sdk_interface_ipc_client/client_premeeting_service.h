/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_PREMEETING_SERVICE_H_
#define NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_PREMEETING_SERVICE_H_

#include "premeeting_service.h"
#include "client_prochandler_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

class NEM_SDK_INTERFACE_EXPORT NEPremeetingServiceProcHandler : public NEProcHandler
{
public:
    virtual void onScheduleMeeting(const NEMeetingItem& item, const NEPreMeetingService::NEScheduleMeetingItemCallback& callback) = 0;
    virtual void onEditMeeting(const NEMeetingItem& item, const NEPreMeetingService::NEOperateScheduleMeetingCallback& callback) = 0;
    virtual void onCancelMeeting(const int64_t&meetingUniqueId, const NEPreMeetingService::NEOperateScheduleMeetingCallback& callback) = 0;
    //virtual void onDeleteMeeting(const int64_t&meetingUniqueId, const NEPreMeetingService::NEOperateScheduleMeetingCallback& callback) = 0;
    virtual void onGetMeetingItemById(const int64_t&meetingUniqueId, const NEPreMeetingService::NEScheduleMeetingItemCallback& callback) = 0;
    virtual void onGetMeetingList(std::list<NEMeetingItemStatus> status, const NEPreMeetingService::NEGetMeetingListCallback& callback) = 0;
};

class NEM_SDK_INTERFACE_EXPORT NEPremeetingServiceIPCClient : 
    public NEServiceIPCClient< NEPremeetingServiceProcHandler, NEPreMeetingService>
{
public:
    virtual void onScheduleMeetingStatusChanged(uint64_t uniqueMeetingId, const int& meetingStatus) = 0;
};

NNEM_SDK_INTERFACE_END_DECLS
#endif // NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_PREMEETING_SERVICE_H_
