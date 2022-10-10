// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_SETTING_SERVICE_H_
#define NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_SETTING_SERVICE_H_

#include "client_prochandler_define.h"
#include "setting_service.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

class NEM_SDK_INTERFACE_EXPORT NESettingsServiceProcHandler : public NEProcHandler {
public:
    virtual bool onShowSettingUIWnd(const NESettingsUIWndConfig& config, const NESettingsService::NEShowSettingUIWndCallback& cb) = 0;

    virtual void onSetTurnOnMyVideoWhenJoinMeeting(bool bOn, const NEEmptyCallback& cb) = 0;
    virtual void onIsTurnOnMyVideoWhenJoinMeetingEnabled(const NESettingsService::NEBoolCallback& cb) = 0;

    virtual void onSetTurnOnMyAudioWhenJoinMeeting(bool bOn, const NEEmptyCallback& cb) = 0;
    virtual void onIsTurnOnMyAudioWhenJoinMeetingEnabled(const NESettingsService::NEBoolCallback& cb) = 0;

    virtual void onSetTurnOnMyAudioAINSWhenInMeeting(bool bOn, const NEEmptyCallback& cb) = 0;
    virtual void onIsTurnOnMyAudioAINSWhenInMeetingEnabled(const NESettingsService::NEBoolCallback& cb) = 0;

    virtual void onSetRemoteVideoResolution(RemoteVideoResolution enumRemoteVideoResolution, const NEEmptyCallback& cb) = 0;
    virtual void onGetRemoteVideoResolution(const NESettingsService::NERemoteVideoResolutionCallback& cb) = 0;
    virtual void onSetMyVideoResolution(LocalVideoResolution enumLocalVideoResolution, const NEEmptyCallback& cb) = 0;
    virtual void onGetMyVideoResolution(const NESettingsService::NELocalVideoResolutionCallback& cb) = 0;
    virtual void onSetMyAudioVolumeAutoAdjust(bool bOn, const NEEmptyCallback& cb) = 0;
    virtual void onIsMyAudioVolumeAutoAdjust(const NESettingsService::NEBoolCallback& cb) = 0;
    virtual void onSetMyAudioQuality(AudioQuality enumAudioQuality, const NEEmptyCallback& cb) = 0;
    virtual void onGetMyAudioQuality(const NESettingsService::NEAudioQualityCallback& cb) = 0;
    virtual void onSetMyAudioEchoCancellation(bool bOn, const NEEmptyCallback& cb) = 0;
    virtual void onIsMyAudioEchoCancellation(const NESettingsService::NEBoolCallback& cb) = 0;
    virtual void onSetMyAudioEnableStereo(bool bOn, const NEEmptyCallback& cb) = 0;
    virtual void onIsMyAudioEnableStereo(const NESettingsService::NEBoolCallback& cb) = 0;
    virtual void onSetMyAudioDeviceAutoSelectType(AudioDeviceAutoSelectType enumAudioDeviceAutoSelectType, const NEEmptyCallback& cb) = 0;
    virtual void onIsMyAudioDeviceAutoSelectType(const NESettingsService::AudioDeviceAutoSelectTypeCallback& cb) = 0;

    virtual void onShowMyMeetingElapseTime(bool show, const NEEmptyCallback& cb) = 0;
    virtual void onIsShowMyMeetingElapseTimeEnabled(const NESettingsService::NEBoolCallback& cb) = 0;

    virtual void onEnableBeauty(bool enable, const NESettingsService::NEBoolCallback& cb) = 0;
    virtual void onIsBeautyEnabled(const NESettingsService::NEBoolCallback& cb) = 0;
    virtual void onSetBeautyValue(int value, const NESettingsService::NEBoolCallback& cb) = 0;
    virtual void onGetBeautyValue(const NESettingsService::NEIntCallback& cb) = 0;
    virtual void onIsLiveEnabled(const NESettingsService::NEBoolCallback& cb) = 0;
    virtual void onGetHistoryMeeting(const NESettingsService::NEHistoryMeetingCallback& cb) = 0;
    virtual void onIsWhiteboardEnabled(const NESettingsService::NEBoolCallback& cb) = 0;
    virtual void onIsCloudRecordEnabled(const NESettingsService::NEBoolCallback& cb) = 0;

    virtual void onEnableVirtualBackground(bool enable, const NEEmptyCallback& cb) = 0;
    virtual void onIsVirtualBackgroundEnabled(const NESettingsService::NEBoolCallback& cb) = 0;
    virtual void onGetBuiltinVirtualBackgrounds(const NESettingsService::NEVirtualBackgroundCallback& cb) = 0;
    virtual void onSetBuiltinVirtualBackgrounds(const std::vector<NEMeetingVirtualBackground>& virtualBackgrounds, const NEEmptyCallback& cb) = 0;

    virtual void onEnableUnmuteBySpace(bool enable, const NEEmptyCallback& cb) = 0;
    virtual void onIsUnmuteBySpaceEnabled(const NESettingsService::NEBoolCallback& cb) = 0;
};

class NEM_SDK_INTERFACE_EXPORT NESettingsServiceIPCClient : public NEServiceIPCClient<NESettingsServiceProcHandler, NESettingsService> {
public:
    virtual void notifySettingsChange(SettingChangType type, bool status, int value) = 0;
};

NNEM_SDK_INTERFACE_END_DECLS
#endif  // NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_SETTING_SERVICE_H_
