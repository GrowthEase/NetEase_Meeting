// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_hosting_module_client/service/client_setting_service.h"
#include "nem_hosting_module_protocol/protocol/settings_protocol.h"

NNEM_SDK_HOSTING_MODULE_CLIENT_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

#include "settings.h"

class NEVideoControllerIMP : public NEVideoController {
    void setTurnOnMyVideoWhenJoinMeeting(bool bOn, const NEEmptyCallback& cb) const {}
    void isTurnOnMyVideoWhenJoinMeetingEnabled(const NESettingsService::NEBoolCallback& cb) const {}
    void setRemoteVideoResolution(RemoteVideoResolution enumRemoteVideoResolution, const NEEmptyCallback& cb) const {}
    void getRemoteVideoResolution(const NESettingsService::NERemoteVideoResolutionCallback& cb) const {}
    void setMyVideoResolution(LocalVideoResolution enumLocalVideoResolution, const NEEmptyCallback& cb) const {}
    void getMyVideoResolution(const NESettingsService::NELocalVideoResolutionCallback& cb) const {}
    void setMyVideoFramerate(LocalVideoFramerate enumLocalVideoFramerate, const NEEmptyCallback& cb) const {}
};

class NEAudioControllerIMP : public NEAudioController {
    void setTurnOnMyAudioWhenJoinMeeting(bool bOn, const NEEmptyCallback& cb) const {}
    void isTurnOnMyAudioWhenJoinMeetingEnabled(const NESettingsService::NEBoolCallback& cb) const {}
    void setTurnOnMyAudioAINSWhenInMeeting(bool bOn, const NEEmptyCallback& cb) const {}
    void isTurnOnMyAudioAINSWhenInMeetingEnabled(const NESettingsService::NEBoolCallback& cb) const {}
    void setMyAudioVolumeAutoAdjust(bool bOn, const NEEmptyCallback& cb) const {}
    void isMyAudioVolumeAutoAdjust(const NESettingsService::NEBoolCallback& cb) const {}
    void setMyAudioQuality(AudioQuality enumAudioQuality, const NEEmptyCallback& cb) const {}
    void getMyAudioQuality(const NESettingsService::NEAudioQualityCallback& cb) const {}
    void setMyAudioEchoCancellation(bool bOn, const NEEmptyCallback& cb) const {}
    void isMyAudioEchoCancellation(const NESettingsService::NEBoolCallback& cb) const {}
    void setMyAudioEnableStereo(bool bOn, const NEEmptyCallback& cb) const {}
    void isMyAudioEnableStereo(const NESettingsService::NEBoolCallback& cb) const {}
    void setMyAudioDeviceAutoSelectType(AudioDeviceAutoSelectType enumAudioDeviceAutoSelectType, const NEEmptyCallback& cb) const {}
    void isMyAudioDeviceAutoSelectType(const NESettingsService::AudioDeviceAutoSelectTypeCallback& cb) const {}
    void setMyAudioDeviceUseLastSelected(bool bOn, const NEEmptyCallback& cb) const {}
    void isMyAudioDeviceUseLastSelected(const NESettingsService::NEBoolCallback& cb) const {}
};

class NEOtherControllerIMP : public NEOtherController {
    void enableShowMyMeetingElapseTime(bool show, const NEEmptyCallback& cb) const {}
    void isShowMyMeetingElapseTimeEnabled(const NESettingsService::NEBoolCallback& cb) const {}
    void enableUnmuteBySpace(bool show, const NEEmptyCallback& cb) const {}
    void isUnmuteBySpaceEnabled(const NESettingsService::NEBoolCallback& cb) const {}
};

class NEBeautyFaceControllerIMP : public NEBeautyFaceController {
public:
    /**
     * 美颜使能接口，控制美颜服务开关
     * @param enable true-打开，false-关闭
     * @return 返回执行结果
     */
    virtual bool enableBeautyFace(bool enable, const NESettingsService::NEBoolCallback& cb) override { return false; };

    /**
     * 查询美颜开关状态，关闭在隐藏会中美颜按钮
     * @return true-打开，false-关闭
     */
    virtual bool isBeautyFaceEnabled(const NESettingsService::NEBoolCallback& cb) override { return false; };

    /**
     * 获取当前美颜参数，关闭返回0
     * @return true-打开，false-关闭
     */
    virtual bool getBeautyFaceValue(const NESettingsService::NEIntCallback& cb) override { return false; };

    /**
     * 设置美颜参数
     * @param value 传入美颜等级，参数规则为[0,10]整数
     * @return 返回执行结果
     */
    virtual bool setBeautyFaceValue(int value, const NESettingsService::NEBoolCallback& cb) override { return false; };
};

class NELiveControllerIMP : public NELiveController {
public:
    /**
     * 查询直播开关状态
     * @return true-打开，false-关闭
     */
    virtual bool isLiveEnabled(const NESettingsService::NEBoolCallback& cb) override { return false; };
};

class NEWhiteboardControllerIMP : public NEWhiteboardController {
public:
    /**
     * 查询白板开关状态
     * @return true-打开，false-关闭
     */
    virtual bool isWhiteboardEnabled(const NESettingsService::NEBoolCallback& cb) override { return false; };
};

class NERecordControllerIMP : public NERecordController {
public:
    /**
     * 查询录制开关状态
     * @return true-打开，false-关闭
     */
    virtual bool isCloudRecordEnabled(const NESettingsService::NEBoolCallback& cb) override { return false; };
};

class NEVirtualBackgroundControllerIMP : public NEVirtualBackgroundController {
public:
    virtual bool enableVirtualBackground(bool enable, const NEEmptyCallback& cb) override { return false; }

    virtual bool isVirtualBackgroundEnabled(const NESettingsService::NEBoolCallback& cb) override { return false; }

    virtual bool getBuiltinVirtualBackgrounds(const NESettingsService::NEVirtualBackgroundCallback& cb) override { return false; }

    virtual bool setBuiltinVirtualBackgrounds(const std::vector<NEMeetingVirtualBackground>& virtualBackgrounds, const NEEmptyCallback& cb) override {
        return false;
    }
};

NESettingsServiceIMP::NESettingsServiceIMP()
    : IService(ServiceID::SID_Setting)
    , video_controller_(new NEVideoControllerIMP())
    , audio_controller_(new NEAudioControllerIMP())
    , other_controller_(new NEOtherControllerIMP())
    , beauty_controller_(new NEBeautyFaceControllerIMP())
    , live_controller_(new NELiveControllerIMP())
    , whiteboard_controller_(new NEWhiteboardControllerIMP())
    , record_controller_(new NERecordControllerIMP())
    , virtualBackground_controller_(new NEVirtualBackgroundControllerIMP()) {}

NESettingsServiceIMP::~NESettingsServiceIMP() {}
NEVideoController* NESettingsServiceIMP::GetVideoController() const {
    return video_controller_.get();
}
NEAudioController* NESettingsServiceIMP::GetAudioController() const {
    return audio_controller_.get();
}
NEOtherController* NESettingsServiceIMP::GetOtherController() const {
    return other_controller_.get();
}

NEBeautyFaceController* NESettingsServiceIMP::GetBeautyFaceController() const {
    return beauty_controller_.get();
}

NELiveController* NESettingsServiceIMP::GetLiveController() const {
    return live_controller_.get();
}

NEWhiteboardController* NESettingsServiceIMP::GetWhiteboardController() const {
    return whiteboard_controller_.get();
}

NERecordController* NESettingsServiceIMP::GetRecordController() const {
    return record_controller_.get();
}

NEVirtualBackgroundController* NESettingsServiceIMP::GetVirtualBackgroundController() const {
    return virtualBackground_controller_.get();
}

void NESettingsServiceIMP::showSettingUIWnd(const NESettingsUIWndConfig& config, const NEShowSettingUIWndCallback& cb) {
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onShowSettingUIWnd(config, cb);
}

void NESettingsServiceIMP::notifySettingsChange(SettingChangType type, bool status, int value) {
    PostTaskToProcThread(ToWeakCallback([this, type, status, value]() {
        SettingsChangeNotify notify_pack;
        notify_pack.type_ = type;
        notify_pack.status_ = status;
        notify_pack.value_ = value;
        SendData(SettingsCID::SettingsCID_ChangeNotify, notify_pack, 0);
    }));
}

void NESettingsServiceIMP::getHistoryMeetingItem(const NEHistoryMeetingCallback& callback) {
    if (_ProcHandler() != nullptr)
        _ProcHandler()->onGetHistoryMeeting(callback);
}

void NESettingsServiceIMP::OnPack(int cid, const std::string& data, uint64_t sn) {
    switch (cid) {
        case SettingsCID::SettingsCID_ShowUIWnd: {
            ShowUIWndRequest request;
            if (request.Parse(data)) {
                showSettingUIWnd(request.config_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                     ShowUIWndResponse response;
                                     response.error_code_ = error_code;
                                     response.error_msg_ = error_msg;
                                     SendData(SettingsCID::SettingsCID_ShowUIWnd_CB, response, sn);
                                 }));
            }
        } break;
        case SettingsCID::SettingsCID_ShowMyMeetingElapseTime: {
            SettingsBoolRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onShowMyMeetingElapseTime(request.status_,
                                                          ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                                              NEMIPCProtocolErrorInfoBody response;
                                                              response.error_code_ = error_code;
                                                              response.error_msg_ = error_msg;
                                                              SendData(SettingsCID::SettingsCID_ShowMyMeetingElapseTime_CB, response, sn);
                                                          }));
            }
        } break;
        case SettingsCID::SettingsCID_IsShowMyMeetingElapseTimeEnabled: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsShowMyMeetingElapseTimeEnabled(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const bool& bOn) {
                        SettingsBoolResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.status_ = bOn;
                        SendData(SettingsCID::SettingsCID_IsShowMyMeetingElapseTimeEnabled_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_TurnOnMyVideoWhenJoinMeeting: {
            SettingsBoolRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetTurnOnMyVideoWhenJoinMeeting(
                    request.status_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                        NEMIPCProtocolErrorInfoBody response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        SendData(SettingsCID::SettingsCID_TurnOnMyVideoWhenJoinMeeting_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_isTurnOnMyVideoWhenJoinMeetingEnabled: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsTurnOnMyVideoWhenJoinMeetingEnabled(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const bool& bOn) {
                        SettingsBoolResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.status_ = bOn;
                        SendData(SettingsCID::SettingsCID_isTurnOnMyVideoWhenJoinMeetingEnabled_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_TurnOnMyAudioWhenJoinMeeting: {
            SettingsBoolRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetTurnOnMyAudioWhenJoinMeeting(
                    request.status_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                        NEMIPCProtocolErrorInfoBody response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        SendData(SettingsCID::SettingsCID_TurnOnMyAudioWhenJoinMeeting_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_isTurnOnMyAudioWhenJoinMeetingEnabled: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsTurnOnMyAudioWhenJoinMeetingEnabled(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const bool& bOn) {
                        SettingsBoolResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.status_ = bOn;
                        SendData(SettingsCID::SettingsCID_isTurnOnMyAudioWhenJoinMeetingEnabled_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_TurnOnMyAudioAINSWhenInMeeting: {
            SettingsBoolRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetTurnOnMyAudioAINSWhenInMeeting(
                    request.status_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                        NEMIPCProtocolErrorInfoBody response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        SendData(SettingsCID::SettingsCID_TurnOnMyAudioAINSWhenInMeeting_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_isTurnOnMyAudioAINSWhenInMeetingEnabled: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsTurnOnMyAudioAINSWhenInMeetingEnabled(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const bool& bOn) {
                        SettingsBoolResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.status_ = bOn;
                        SendData(SettingsCID::SettingsCID_isTurnOnMyAudioAINSWhenInMeetingEnabled_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_BeautyEnabled: {
            SettingsBoolRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onEnableBeauty(request.status_,
                                               ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, bool bOn) {
                                                   SettingsBoolResponse response;
                                                   response.error_code_ = error_code;
                                                   response.error_msg_ = error_msg;
                                                   response.status_ = bOn;
                                                   SendData(SettingsCID::SettingsCID_BeautyEnabled_CB, response, sn);
                                               }));
            }
        } break;
        case SettingsCID::SettingsCID_isBeautyEnabled: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsBeautyEnabled(ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, bool bOn) {
                    SettingsBoolResponse response;
                    response.error_code_ = error_code;
                    response.error_msg_ = error_msg;
                    response.status_ = bOn;
                    SendData(SettingsCID::SettingsCID_isBeautyEnabled_CB, response, sn);
                }));
            }
        } break;
        case SettingsCID::SettingsCID_setBeautyParams: {
            SettingsIntRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetBeautyValue(request.value_,
                                                 ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, bool value) {
                                                     SettingsBoolResponse response;
                                                     response.error_code_ = error_code;
                                                     response.error_msg_ = error_msg;
                                                     response.status_ = value;
                                                     SendData(SettingsCID::SettingsCID_setBeautyParams_CB, response, sn);
                                                 }));
            }
        } break;
        case SettingsCID::SettingsCID_getBeautyParams: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onGetBeautyValue(ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, int value) {
                    SettingsIntResponse response;
                    response.error_code_ = error_code;
                    response.error_msg_ = error_msg;
                    response.value_ = value;
                    SendData(SettingsCID::SettingsCID_getBeautyParams_CB, response, sn);
                }));
            }
        } break;
        case SettingsCID::SettingsCID_isLiveEnabled: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsLiveEnabled(ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, bool bOn) {
                    SettingsBoolResponse response;
                    response.error_code_ = error_code;
                    response.error_msg_ = error_msg;
                    response.status_ = bOn;
                    SendData(SettingsCID::SettingsCID_isLiveEnabled_CB, response, sn);
                }));
            }
        } break;
        case SettingsCID::SettingsCID_getHistoryMeeting: {
            SettingsGetHistoryMeetingRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onGetHistoryMeeting(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, std::list<NEHistoryMeetingItem> list) {
                        SettingsGetHistoryMeetingResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.params_ = list;
                        SendData(SettingsCID::SettingsCID_getHistoryMeeting_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_isWhiteboardEnabled: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsWhiteboardEnabled(ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, bool bOn) {
                    SettingsBoolResponse response;
                    response.error_code_ = error_code;
                    response.error_msg_ = error_msg;
                    response.status_ = bOn;
                    SendData(SettingsCID::SettingsCID_isWhiteboardEnabled_CB, response, sn);
                }));
            }
        } break;
        case SettingsCID::SettingsCID_isCloudRecordEnabled: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsCloudRecordEnabled(ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, bool bOn) {
                    SettingsBoolResponse response;
                    response.error_code_ = error_code;
                    response.error_msg_ = error_msg;
                    response.status_ = bOn;
                    SendData(SettingsCID::SettingsCID_isCloudRecordEnabled_CB, response, sn);
                }));
            }
        } break;
        case SettingsCID::SettingsCID_setRemoteVideoResolution: {
            SettingsIntRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetRemoteVideoResolution((RemoteVideoResolution)request.value_,
                                                           ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                                               NEMIPCProtocolErrorInfoBody response;
                                                               response.error_code_ = error_code;
                                                               response.error_msg_ = error_msg;
                                                               SendData(SettingsCID::SettingsCID_setRemoteVideoResolution_CB, response, sn);
                                                           }));
            }
        } break;
        case SettingsCID::SettingsCID_getRemoteVideoResolution: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onGetRemoteVideoResolution(ToWeakCallback(
                    [this, sn](NEErrorCode error_code, const std::string& error_msg, const RemoteVideoResolution& enumRemoteVideoResolution) {
                        SettingsIntResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.value_ = (int)enumRemoteVideoResolution;
                        SendData(SettingsCID::SettingsCID_getRemoteVideoResolution_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_setMyVideoResolution: {
            SettingsIntRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetMyVideoResolution((LocalVideoResolution)request.value_,
                                                       ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                                           NEMIPCProtocolErrorInfoBody response;
                                                           response.error_code_ = error_code;
                                                           response.error_msg_ = error_msg;
                                                           SendData(SettingsCID::SettingsCID_setMyVideoResolution_CB, response, sn);
                                                       }));
            }
        } break;
        case SettingsCID::SettingsCID_getMyVideoResolution: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onGetMyVideoResolution(ToWeakCallback(
                    [this, sn](NEErrorCode error_code, const std::string& error_msg, const LocalVideoResolution& enumLocalVideoResolution) {
                        SettingsIntResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.value_ = (int)enumLocalVideoResolution;
                        SendData(SettingsCID::SettingsCID_getMyVideoResolution_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_setMyVideoFramerate: {
            SettingsIntRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetMyVideoFramerate((LocalVideoFramerate)request.value_,
                                                      ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                                          NEMIPCProtocolErrorInfoBody response;
                                                          response.error_code_ = error_code;
                                                          response.error_msg_ = error_msg;
                                                          SendData(SettingsCID::SettingsCID_setMyVideoFramerate_CB, response, sn);
                                                      }));
            }
        } break;
        case SettingsCID::SettingsCID_setMyAudioVolumeAutoAdjust: {
            SettingsBoolRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetMyAudioVolumeAutoAdjust(request.status_,
                                                             ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                                                 NEMIPCProtocolErrorInfoBody response;
                                                                 response.error_code_ = error_code;
                                                                 response.error_msg_ = error_msg;
                                                                 SendData(SettingsCID::SettingsCID_setMyAudioVolumeAutoAdjust_CB, response, sn);
                                                             }));
            }
        } break;
        case SettingsCID::SettingsCID_isMyAudioVolumeAutoAdjust: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsMyAudioVolumeAutoAdjust(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const bool& bOn) {
                        SettingsBoolResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.status_ = bOn;
                        SendData(SettingsCID::SettingsCID_isMyAudioVolumeAutoAdjust_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_setMyAudioQuality: {
            SettingsIntRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetMyAudioQuality((AudioQuality)request.value_,
                                                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                                        NEMIPCProtocolErrorInfoBody response;
                                                        response.error_code_ = error_code;
                                                        response.error_msg_ = error_msg;
                                                        SendData(SettingsCID::SettingsCID_setMyAudioQuality_CB, response, sn);
                                                    }));
            }
        } break;
        case SettingsCID::SettingsCID_getMyAudioQuality: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onGetMyAudioQuality(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const AudioQuality& enumAudioQuality) {
                        SettingsIntResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.value_ = (int)enumAudioQuality;
                        SendData(SettingsCID::SettingsCID_getMyAudioQuality_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_setMyAudioEchoCancellation: {
            SettingsBoolRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetMyAudioEchoCancellation(request.status_,
                                                             ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                                                 NEMIPCProtocolErrorInfoBody response;
                                                                 response.error_code_ = error_code;
                                                                 response.error_msg_ = error_msg;
                                                                 SendData(SettingsCID::SettingsCID_setMyAudioEchoCancellation_CB, response, sn);
                                                             }));
            }
        } break;
        case SettingsCID::SettingsCID_isMyAudioEchoCancellation: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsMyAudioEchoCancellation(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const bool& bOn) {
                        SettingsBoolResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.status_ = bOn;
                        SendData(SettingsCID::SettingsCID_isMyAudioEchoCancellation_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_setMyAudioEnableStereo: {
            SettingsBoolRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetMyAudioEnableStereo(request.status_,
                                                         ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                                             NEMIPCProtocolErrorInfoBody response;
                                                             response.error_code_ = error_code;
                                                             response.error_msg_ = error_msg;
                                                             SendData(SettingsCID::SettingsCID_setMyAudioEnableStereo_CB, response, sn);
                                                         }));
            }
        } break;
        case SettingsCID::SettingsCID_isMyAudioEnableStereo: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsMyAudioEnableStereo(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const bool& bOn) {
                        SettingsBoolResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.status_ = bOn;
                        SendData(SettingsCID::SettingsCID_isMyAudioEnableStereo_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_setMyAudioDeviceAutoSelectType: {
            SettingsIntRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetMyAudioDeviceAutoSelectType(
                    (AudioDeviceAutoSelectType)request.value_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                        NEMIPCProtocolErrorInfoBody response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        SendData(SettingsCID::SettingsCID_setMyAudioDeviceAutoSelectType_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_isMyAudioDeviceAutoSelectType: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsMyAudioDeviceAutoSelectType(ToWeakCallback(
                    [this, sn](NEErrorCode error_code, const std::string& error_msg, const AudioDeviceAutoSelectType& enumAudioDeviceAutoSelectType) {
                        SettingsIntResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.value_ = (int)enumAudioDeviceAutoSelectType;
                        SendData(SettingsCID::SettingsCID_isMyAudioDeviceAutoSelectType_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_setVirtualBackgroundEnabled: {
            SettingsBoolRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onEnableVirtualBackground(request.status_,
                                                          ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                                              NEMIPCProtocolErrorInfoBody response;
                                                              response.error_code_ = error_code;
                                                              response.error_msg_ = error_msg;
                                                              SendData(SettingsCID::SettingsCID_setVirtualBackgroundEnabled_CB, response, sn);
                                                          }));
            }
        } break;
        case SettingsCID::SettingsCID_isVirtualBackgroundEnabled: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsVirtualBackgroundEnabled(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const bool& bOn) {
                        SettingsBoolResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.status_ = bOn;
                        SendData(SettingsCID::SettingsCID_isVirtualBackgroundEnabled_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_setVirtualBackgroundList: {
            SettingsSetVirtualBackgroundListRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetBuiltinVirtualBackgrounds(request.params_,
                                                               ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                                                   NEMIPCProtocolErrorInfoBody response;
                                                                   response.error_code_ = error_code;
                                                                   response.error_msg_ = error_msg;
                                                                   SendData(SettingsCID::SettingsCID_setVirtualBackgroundList_CB, response, sn);
                                                               }));
            }
        } break;
        case SettingsCID::SettingsCID_getVirtualBackgroundList: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onGetBuiltinVirtualBackgrounds(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg,
                                              const std::vector<NEMeetingVirtualBackground>& virtualBackgroundList) {
                        SettingsGetVirtualBackgroundListResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.params_ = virtualBackgroundList;
                        SendData(SettingsCID::SettingsCID_getVirtualBackgroundList_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_enableUnmuteBySpace: {
            SettingsBoolRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onEnableUnmuteBySpace(request.status_,
                                                      ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                                                          NEMIPCProtocolErrorInfoBody response;
                                                          response.error_code_ = error_code;
                                                          response.error_msg_ = error_msg;
                                                          SendData(SettingsCID::SettingsCID_enableUnmuteBySpace_CB, response, sn);
                                                      }));
            }
        } break;
        case SettingsCID::SettingsCID_isUnmuteBySpaceEnabled: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsUnmuteBySpaceEnabled(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const bool& bOn) {
                        SettingsBoolResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.status_ = bOn;
                        SendData(SettingsCID::SettingsCID_isUnmuteBySpaceEnabled_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_setMyAudioDeviceUseLastSelected: {
            SettingsBoolRequest request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onSetMyAudioDeviceUseLastSelected(
                    request.status_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg) {
                        NEMIPCProtocolErrorInfoBody response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        SendData(SettingsCID::SettingsCID_setMyAudioDeviceUseLastSelected_CB, response, sn);
                    }));
            }
        } break;
        case SettingsCID::SettingsCID_isMyAudioDeviceUseLastSelected: {
            NEMIPCProtocolEmptyBody request;
            if (request.Parse(data) && _ProcHandler()) {
                _ProcHandler()->onIsMyAudioDeviceUseLastSelected(
                    ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const bool& bOn) {
                        SettingsBoolResponse response;
                        response.error_code_ = error_code;
                        response.error_msg_ = error_msg;
                        response.status_ = bOn;
                        SendData(SettingsCID::SettingsCID_isMyAudioDeviceUseLastSelected_CB, response, sn);
                    }));
            }
        } break;
    }
}
NNEM_SDK_HOSTING_MODULE_CLIENT_END_DECLS
