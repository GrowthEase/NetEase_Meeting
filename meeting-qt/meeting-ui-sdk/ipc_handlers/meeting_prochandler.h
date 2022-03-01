/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_APP_PROCHANDLER_MEETING_PROCHANDLER_H_
#define NEM_SDK_INTERFACE_APP_PROCHANDLER_MEETING_PROCHANDLER_H_

#include "client_meeting_service.h"
#include "manager/meeting_manager.h"
#include "room_service_interface.h"

class NEMeetingServiceProcHandlerIMP : public QObject, public NS_I_NEM_SDK::NEMeetingServiceProcHandler {
    Q_OBJECT
public:
    NEMeetingServiceProcHandlerIMP(QObject* parent = nullptr);
    virtual bool onStartMeeting(const NS_I_NEM_SDK::NEStartMeetingParams& param,
                                const NS_I_NEM_SDK::NEStartMeetingOptions& opts,
                                const NS_I_NEM_SDK::NEMeetingService::NEStartMeetingCallback& cb) override;
    virtual bool onJoinMeeting(const NS_I_NEM_SDK::NEJoinMeetingParams& param,
                               const NS_I_NEM_SDK::NEJoinMeetingOptions& opts,
                               const NS_I_NEM_SDK::NEMeetingService::NEJoinMeetingCallback& cb) override;
    virtual bool onLeaveMeeting(bool finish, const NS_I_NEM_SDK::NEMeetingService::NELeaveMeetingCallback& cb) override;
    virtual bool onGetCurrentMeetingInfo(const NS_I_NEM_SDK::NEMeetingService::NEGetMeetingInfoCallback& cb) override;
    virtual void onGetPresetMenuItems(const std::vector<int>& menuItemsId,
                                      const NS_I_NEM_SDK::NEMeetingService::NEGetPresetMenuItemsCallback& cb) override;
    virtual void onInjectedMenuItemClickExReturn(int itemId, const std::string& itemGuid, int itemCheckedIndex) override;
    virtual void onSubscribeRemoteAudioStream(const std::string& accountId, bool subscribe, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onSubscribeRemoteAudioStreams(const std::vector<std::string>& accountIdList,
                                               bool subscribe,
                                               const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onSubscribeAllRemoteAudioStreams(bool subscribe, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;

private:
    NS_I_NEM_SDK::NEErrorCode convertExtentedCode(int extentedCode);
    bool checkOptions(const std::vector<NS_I_NEM_SDK::NEMeetingMenuItem>& items, bool bInjected);
    bool checkOptionsVisibility(const std::vector<NS_I_NEM_SDK::NEMeetingMenuItem>& items, int lengthLimit);

    bool checkOptionsEx(const std::vector<NS_I_NEM_SDK::NEMeetingMenuItem>& items);
    bool checkOptionsExMore(const std::vector<NS_I_NEM_SDK::NEMeetingMenuItem>& items);
    bool checkOptionsId(const std::vector<NS_I_NEM_SDK::NEMeetingMenuItem>& items, bool bInjected);

public slots:
    void onMeetingStatusChanged(NEMeeting::Status status, int errorCode, const QString& errorMessage);

private:
    NS_I_NEM_SDK::NEMeetingService::NEStartMeetingCallback m_startMeetingCallback = nullptr;
    NS_I_NEM_SDK::NEMeetingService::NEJoinMeetingCallback m_joinMeetingCallback = nullptr;
    NS_I_NEM_SDK::NEMeetingService::NELeaveMeetingCallback m_leaveMeetingCallback = nullptr;
};

#endif  // NEM_SDK_INTERFACE_APP_PROCHANDLER_MEETING_PROCHANDLER_H_
