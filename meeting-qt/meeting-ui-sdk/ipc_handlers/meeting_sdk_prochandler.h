/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_APP_PROCHANDLER_MEETING_SDK_PROCHANDLER_H_
#define NEM_SDK_INTERFACE_APP_PROCHANDLER_MEETING_SDK_PROCHANDLER_H_

#include "client_meeting_sdk.h"

extern bool g_bInitialized;

class NEMeetingSDKProcHandlerIMP : public QObject, public NS_I_NEM_SDK::NEMeetingSDKProcHandler
{
    Q_OBJECT
public:
    NEMeetingSDKProcHandlerIMP(QObject* parent = nullptr);

public:
	virtual void onInitialize(const NS_I_NEM_SDK::NEMeetingSDKConfig& config, const NS_I_NEM_SDK::NEMeetingSDK::NEInitializeCallback& cb) override;
	virtual void onUnInitialize(const NS_I_NEM_SDK::NEMeetingSDK::NEUnInitializeCallback& cb) override;
    virtual void onQuerySDKVersion(const NS_I_NEM_SDK::NEMeetingSDK::NEQuerySDKVersionCallback& cb) override;
    virtual void onActiveWindow(const NS_I_NEM_SDK::NEMeetingSDK::NEActiveWindowCallback& cb) override;
    virtual void attachSDKInitialize(const std::function<void(bool)>& cb) override;
    void onInitLocalEnviroment(bool success);

    NS_I_NEM_SDK::NEMeetingSDKConfig getSDKConfig() const;

private:
    std::function<void(bool)> sdk_init_callback_;
    NS_I_NEM_SDK::NEMeetingSDK::NEInitializeCallback init_local_enviroment_cb_;
    NS_I_NEM_SDK::NEMeetingSDKConfig  sdk_config_;
};

#endif // NEM_SDK_INTERFACE_APP_PROCHANDLER_MEETING_SDK_PROCHANDLER_H_
