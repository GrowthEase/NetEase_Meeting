// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NEM_HOSTING_MODULE_PROTOCOL_SETTINGS_PROTOCOL_H_
#define NEM_HOSTING_MODULE_PROTOCOL_SETTINGS_PROTOCOL_H_

#include "nem_hosting_module_core/protocol/protocol.h"
#include "nem_hosting_module_protocol/config/build_config.h"

NNEM_SDK_HOSTING_MODULE_PROTOCOL_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

enum SettingsCID {
    SettingsCID_ShowUIWnd = 1,
    SettingsCID_ShowUIWnd_CB = 2,

    SettingsCID_ShowMyMeetingElapseTime = 3,
    SettingsCID_ShowMyMeetingElapseTime_CB = 4,

    SettingsCID_IsShowMyMeetingElapseTimeEnabled = 5,
    SettingsCID_IsShowMyMeetingElapseTimeEnabled_CB = 6,

    SettingsCID_TurnOnMyVideoWhenJoinMeeting = 7,
    SettingsCID_TurnOnMyVideoWhenJoinMeeting_CB = 8,

    SettingsCID_isTurnOnMyVideoWhenJoinMeetingEnabled = 9,
    SettingsCID_isTurnOnMyVideoWhenJoinMeetingEnabled_CB = 10,

    SettingsCID_TurnOnMyAudioWhenJoinMeeting = 11,
    SettingsCID_TurnOnMyAudioWhenJoinMeeting_CB = 12,

    SettingsCID_isTurnOnMyAudioWhenJoinMeetingEnabled = 13,
    SettingsCID_isTurnOnMyAudioWhenJoinMeetingEnabled_CB = 14,

    SettingsCID_BeautyEnabled = 15,
    SettingsCID_BeautyEnabled_CB = 16,

    SettingsCID_isBeautyEnabled = 17,
    SettingsCID_isBeautyEnabled_CB = 18,

    SettingsCID_setBeautyParams = 19,
    SettingsCID_setBeautyParams_CB = 20,

    SettingsCID_getBeautyParams = 21,
    SettingsCID_getBeautyParams_CB = 22,

    SettingsCID_isLiveEnabled = 23,
    SettingsCID_isLiveEnabled_CB = 24,

    SettingsCID_getHistoryMeeting = 25,
    SettingsCID_getHistoryMeeting_CB = 26,

    SettingsCID_isWhiteboardEnabled = 27,
    SettingsCID_isWhiteboardEnabled_CB = 28,

    SettingsCID_isCloudRecordEnabled = 29,
    SettingsCID_isCloudRecordEnabled_CB = 30,

    SettingsCID_TurnOnMyAudioAINSWhenInMeeting = 31,
    SettingsCID_TurnOnMyAudioAINSWhenInMeeting_CB = 32,

    SettingsCID_isTurnOnMyAudioAINSWhenInMeetingEnabled = 33,
    SettingsCID_isTurnOnMyAudioAINSWhenInMeetingEnabled_CB = 34,

    SettingsCID_setRemoteVideoResolution = 35,
    SettingsCID_setRemoteVideoResolution_CB = 36,

    SettingsCID_getRemoteVideoResolution = 37,
    SettingsCID_getRemoteVideoResolution_CB = 38,

    SettingsCID_setMyVideoResolution = 39,
    SettingsCID_setMyVideoResolution_CB = 40,

    SettingsCID_getMyVideoResolution = 41,
    SettingsCID_getMyVideoResolution_CB = 42,

    SettingsCID_setMyAudioVolumeAutoAdjust = 43,
    SettingsCID_setMyAudioVolumeAutoAdjust_CB = 44,

    SettingsCID_isMyAudioVolumeAutoAdjust = 45,
    SettingsCID_isMyAudioVolumeAutoAdjust_CB = 46,

    SettingsCID_setMyAudioQuality = 47,
    SettingsCID_setMyAudioQuality_CB = 48,

    SettingsCID_getMyAudioQuality = 49,
    SettingsCID_getMyAudioQuality_CB = 50,

    SettingsCID_setMyAudioEchoCancellation = 51,
    SettingsCID_setMyAudioEchoCancellation_CB = 52,

    SettingsCID_isMyAudioEchoCancellation = 53,
    SettingsCID_isMyAudioEchoCancellation_CB = 54,

    SettingsCID_setMyAudioEnableStereo = 55,
    SettingsCID_setMyAudioEnableStereo_CB = 56,

    SettingsCID_isMyAudioEnableStereo = 57,
    SettingsCID_isMyAudioEnableStereo_CB = 58,

    SettingsCID_setMyAudioDeviceAutoSelectType = 59,
    SettingsCID_setMyAudioDeviceAutoSelectType_CB = 60,

    SettingsCID_isMyAudioDeviceAutoSelectType = 61,
    SettingsCID_isMyAudioDeviceAutoSelectType_CB = 62,

    SettingsCID_setVirtualBackgroundEnabled = 63,
    SettingsCID_setVirtualBackgroundEnabled_CB = 64,

    SettingsCID_isVirtualBackgroundEnabled = 65,
    SettingsCID_isVirtualBackgroundEnabled_CB = 66,

    SettingsCID_setVirtualBackgroundList = 67,
    SettingsCID_setVirtualBackgroundList_CB = 68,

    SettingsCID_getVirtualBackgroundList = 69,
    SettingsCID_getVirtualBackgroundList_CB = 70,

    SettingsCID_enableUnmuteBySpace = 71,
    SettingsCID_enableUnmuteBySpace_CB = 72,

    SettingsCID_isUnmuteBySpaceEnabled = 73,
    SettingsCID_isUnmuteBySpaceEnabled_CB = 74,

    SettingsCID_setMyAudioDeviceUseLastSelected = 75,
    SettingsCID_setMyAudioDeviceUseLastSelected_CB = 76,

    SettingsCID_isMyAudioDeviceUseLastSelected = 77,
    SettingsCID_isMyAudioDeviceUseLastSelected_CB = 78,

    SettingsCID_setMyVideoFramerate = 79,
    SettingsCID_setMyVideoFramerate_CB = 80,

    SettingsCID_Notify = 100,
    SettingsCID_ChangeNotify = SettingsCID_Notify + 1,  // 设置变更通知
};

class ShowUIWndRequest : public NEMIPCProtocolBody {
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
    NESettingsUIWndConfig config_;
};
using ShowUIWndResponse = NEMIPCProtocolErrorInfoBody;

class SettingsChangeNotify : public NEMIPCProtocolBody {
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;
    SettingChangType type_;
    bool status_ = false;
    int value_ = 0;
};

class SettingsBoolRequest : public NEMIPCProtocolBody {
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;
    bool status_;
};

class SettingsBoolResponse : public NEMIPCProtocolErrorInfoBody {
public:
    virtual void OnOtherPack(Json::Value& root) const override;
    virtual void OnOtherParse(const Json::Value& root) override;
    bool status_;
};

class SettingsIntRequest : public NEMIPCProtocolBody {
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;
    int value_ = 0;
};

class SettingsIntResponse : public NEMIPCProtocolErrorInfoBody {
public:
    virtual void OnOtherPack(Json::Value& root) const override;
    virtual void OnOtherParse(const Json::Value& root) override;
    int value_ = 0;
};

class SettingsGetHistoryMeetingRequest : public NEMIPCProtocolBody {
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;

public:
};
class SettingsGetHistoryMeetingResponse : public NEMIPCProtocolErrorInfoBody {
public:
    virtual void OnOtherPack(Json::Value& root) const override;
    virtual void OnOtherParse(const Json::Value& root) override;

public:
    std::list<NEHistoryMeetingItem> params_;
};

class SettingsGetVirtualBackgroundListResponse : public NEMIPCProtocolErrorInfoBody {
public:
    virtual void OnOtherPack(Json::Value& root) const override;
    virtual void OnOtherParse(const Json::Value& root) override;

public:
    std::vector<NEMeetingVirtualBackground> params_;
};

using SettingsSetVirtualBackgroundListRequest = SettingsGetVirtualBackgroundListResponse;

NNEM_SDK_HOSTING_MODULE_PROTOCOL_END_DECLS

#endif  // NEM_HOSTING_MODULE_PROTOCOL_SETTINGS_PROTOCOL_H_
