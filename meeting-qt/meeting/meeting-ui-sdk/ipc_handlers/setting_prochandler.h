// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NEM_SDK_INTERFACE_IPC_APP_PROCHANDLER_SETTING_PROCHANDLER_H_
#define NEM_SDK_INTERFACE_IPC_APP_PROCHANDLER_SETTING_PROCHANDLER_H_

#include "client_setting_service.h"

class NESettingsServiceProcHandlerIMP : public QObject, public NS_I_NEM_SDK::NESettingsServiceProcHandler {
    Q_OBJECT
public:
    virtual bool onShowSettingUIWnd(const NS_I_NEM_SDK::NESettingsUIWndConfig& config,
                                    const NS_I_NEM_SDK::NESettingsService::NEShowSettingUIWndCallback& cb) override;

    virtual void onSetTurnOnMyVideoWhenJoinMeeting(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsTurnOnMyVideoWhenJoinMeetingEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;

    virtual void onSetTurnOnMyAudioWhenJoinMeeting(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsTurnOnMyAudioWhenJoinMeetingEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;

    virtual void onSetTurnOnMyAudioAINSWhenInMeeting(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsTurnOnMyAudioAINSWhenInMeetingEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;

    virtual void onSetRemoteVideoResolution(NS_I_NEM_SDK::RemoteVideoResolution enumRemoteVideoResolution,
                                            const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onGetRemoteVideoResolution(const NS_I_NEM_SDK::NESettingsService::NERemoteVideoResolutionCallback& cb) override;
    virtual void onSetMyVideoResolution(NS_I_NEM_SDK::LocalVideoResolution enumLocalVideoResolution,
                                        const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onGetMyVideoResolution(const NS_I_NEM_SDK::NESettingsService::NELocalVideoResolutionCallback& cb) override;
    virtual void onSetMyVideoFramerate(NS_I_NEM_SDK::LocalVideoFramerate enumLocalVideoFramerate, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onSetMyAudioVolumeAutoAdjust(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsMyAudioVolumeAutoAdjust(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;
    virtual void onSetMyAudioQuality(NS_I_NEM_SDK::AudioQuality enumAudioQuality, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onGetMyAudioQuality(const NS_I_NEM_SDK::NESettingsService::NEAudioQualityCallback& cb) override;
    virtual void onSetMyAudioEchoCancellation(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsMyAudioEchoCancellation(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;
    virtual void onSetMyAudioEnableStereo(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsMyAudioEnableStereo(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;
    virtual void onSetMyAudioDeviceAutoSelectType(NS_I_NEM_SDK::AudioDeviceAutoSelectType enumAudioDeviceAutoSelectType,
                                                  const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsMyAudioDeviceAutoSelectType(const NS_I_NEM_SDK::NESettingsService::AudioDeviceAutoSelectTypeCallback& cb) override;
    virtual void onSetMyAudioDeviceUseLastSelected(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsMyAudioDeviceUseLastSelected(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;

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

    virtual void onEnableVirtualBackground(bool enable, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsVirtualBackgroundEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;
    virtual void onGetBuiltinVirtualBackgrounds(const NS_I_NEM_SDK::NESettingsService::NEVirtualBackgroundCallback& cb) override;
    virtual void onSetBuiltinVirtualBackgrounds(const std::vector<NS_I_NEM_SDK::NEMeetingVirtualBackground>& virtualBackgrounds,
                                                const NS_I_NEM_SDK::NEEmptyCallback& cb) override;

    virtual void onEnableUnmuteBySpace(bool enable, const NS_I_NEM_SDK::NEEmptyCallback& cb) override;
    virtual void onIsUnmuteBySpaceEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) override;
};

#endif  // NEM_SDK_INTERFACE_IPC_APP_PROCHANDLER_SETTING_PROCHANDLER_H_
