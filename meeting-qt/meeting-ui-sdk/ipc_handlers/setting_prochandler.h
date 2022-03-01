/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_IPC_APP_PROCHANDLER_SETTING_PROCHANDLER_H_
#define NEM_SDK_INTERFACE_IPC_APP_PROCHANDLER_SETTING_PROCHANDLER_H_

#include "client_setting_service.h"

class NESettingsServiceProcHandlerIMP : public NS_I_NEM_SDK::NESettingsServiceProcHandler {
public:
    virtual bool onShowSettingUIWnd(const NS_I_NEM_SDK::NESettingsUIWndConfig& config,
                                    const NS_I_NEM_SDK::NESettingsService::NEShowSettingUIWndCallback& cb) override;

    virtual void onSetTurnOnMyVideoWhenJoinMeeting(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsTurnOnMyVideoWhenJoinMeetingEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;

    virtual void onSetTurnOnMyAudioWhenJoinMeeting(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsTurnOnMyAudioWhenJoinMeetingEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;

    virtual void onShowMyMeetingElapseTime(bool show, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsShowMyMeetingElapseTimeEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;

    virtual void onEnableBeauty(bool enable, const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;
    virtual void onIsBeautyEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;
    virtual void onSetBeautyValue(int value, const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;
    virtual void onGetBeautyValue(const NS_I_NEM_SDK::NESettingsService::NEIntCallback& cb) override;

    virtual void onIsLiveEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;

    virtual void onGetHistoryMeeting(const NS_I_NEM_SDK::NESettingsService::NEHistoryMeetingCallback& cb) override;

    virtual void onIsWhiteboardEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;

    virtual void onIsCloudRecordEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;
};

#endif  // NEM_SDK_INTERFACE_IPC_APP_PROCHANDLER_SETTING_PROCHANDLER_H_
