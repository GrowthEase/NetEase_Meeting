/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_SERVICE_MEETING_SERVICE_H_
#define NEM_HOSTING_MODULE_SERVICE_MEETING_SERVICE_H_
#include "nemeeting_sdk_interface_include.h"
#include "nem_hosting_module/config/build_config.h"
#include "nem_hosting_module_core/service/service.h"

NNEM_SDK_HOSTING_MODULE_BEGIN_DECLS

USING_NS_NNEM_SDK_INTERFACE

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

class NEM_SDK_INTERFACE_EXPORT NEMeetingServiceIMP : public NEMeetingService, public IService<NS_NIPCLIB::IPCServer>
{
    friend NEMeetingSDK* NEMeetingSDK::getInstance();
public:
    NEMeetingServiceIMP();
    virtual ~NEMeetingServiceIMP();

public:
    virtual void startMeeting(const NEStartMeetingParams& param, const NEStartMeetingOptions& opts, const NEStartMeetingCallback& cb) override;
    virtual void joinMeeting(const NEJoinMeetingParams& param, const NEJoinMeetingOptions& opts, const NEJoinMeetingCallback& cb) override;
    virtual void leaveMeeting(bool finish, const NELeaveMeetingCallback& cb) override;
    virtual void getCurrentMeetingInfo(const NEGetMeetingInfoCallback& cb) override;
    virtual NEMeetingStatus getMeetingStatus() override;
    virtual void addMeetingStatusListener(NEMeetingStatusListener* listener) override;
    virtual void setOnInjectedMenuItemClickListener(NEMeetingOnInjectedMenuItemClickListener* listener) override;
    virtual void getBuiltinMenuItems(const std::vector<int>& menuItemsId, const NEGetPresetMenuItemsCallback& cb) override;
    virtual void subscribeRemoteAudioStream(const std::string& accountId, bool subscribe, const NEEmptyCallback& cb) override;
    virtual void subscribeRemoteAudioStreams(const std::vector<std::string>& accountIdList, bool subscribe, const NEEmptyCallback& cb) override;
    virtual void subscribeAllRemoteAudioStreams(bool subscribe, const NEEmptyCallback& cb) override;

private:
    void OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb) override;
    virtual void OnPack(int cid, const std::string& data, uint64_t sn) override;

private:
    NEMeetingStatus  meeting_status_;
    NEMeetingStatusListener* meeting_srv_listener_;
    NEMeetingOnInjectedMenuItemClickListener* meeting_menu_item_listener_;
};

NNEM_SDK_HOSTING_MODULE_END_DECLS

#endif //NEM_HOSTING_MODULE_SERVICE_MEETING_SERVICE_H_

