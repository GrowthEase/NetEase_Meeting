/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_CLIENT_SERVICE_PREMEETING_SERVICE_H_
#define NEM_HOSTING_MODULE_CLIENT_SERVICE_PREMEETING_SERVICE_H_
#include "client_nemeeting_sdk_interface_include.h"
#include "nem_hosting_module_client/config/build_config.h"
#include "nem_hosting_module_core/service/service.h"

NNEM_SDK_HOSTING_MODULE_CLIENT_BEGIN_DECLS

USING_NS_NNEM_SDK_INTERFACE

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE



class NEM_SDK_INTERFACE_EXPORT NEPremeetingServiceIMP : public NEPremeetingServiceIPCClient, public IService<NS_NIPCLIB::IPCClient>
{
    friend NEMeetingSDKIPCClient* NEMeetingSDKIPCClient::getInstance();
public:
    NEPremeetingServiceIMP();
    virtual ~NEPremeetingServiceIMP();
public:

    virtual NEMeetingItem createScheduleMeetingItem() override;
    virtual void scheduleMeeting(const NEMeetingItem& item, const NEPreMeetingService::NEScheduleMeetingItemCallback& callback) override;
    virtual void cancelMeeting(const int64_t&meetingUniqueId, const NEPreMeetingService::NEOperateScheduleMeetingCallback& callback) override;
    virtual void editMeeting(const NEMeetingItem& item, const NEOperateScheduleMeetingCallback& callback) override;
    virtual void getMeetingItemById(const int64_t&meetingUniqueId, const NEPreMeetingService::NEScheduleMeetingItemCallback& callback) override;
    virtual void getMeetingList(std::list<NEMeetingItemStatus> status, const NEGetMeetingListCallback& callback) override;
    virtual void registerScheduleMeetingStatusListener(NEScheduleMeetingStatusListener* listener) override;
    virtual void unRegisterScheduleMeetingStatusListener(NEScheduleMeetingStatusListener* listener) override;
    
    virtual void onScheduleMeetingStatusChanged(uint64_t uniqueMeetingId, const int& meetingStatus) override;
    virtual void OnLoad() override;
    virtual void OnRelease() override;

private:
    void OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb) override {};
    virtual void OnPack(int cid, const std::string& data, uint64_t sn) override;

};

NNEM_SDK_HOSTING_MODULE_CLIENT_END_DECLS

#endif //NEM_HOSTING_MODULE_CLIENT_SERVICE_PREMEETING_SERVICE_H_
