// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_hosting_module/service/setting_service.h"

#include "nem_hosting_module_protocol/protocol/settings_protocol.h"

NNEM_SDK_HOSTING_MODULE_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

class NEVideoControllerIMP : public NEVideoController {
public:
    NEVideoControllerIMP(NESettingsServiceIMP* pSettingsService)
        : m_pSettingsService(pSettingsService) {}

    ~NEVideoControllerIMP() {}

    virtual void setTurnOnMyVideoWhenJoinMeeting(bool bOn, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, bOn, cb]() {
            SettingsBoolRequest request;
            request.status_ = bOn;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_TurnOnMyVideoWhenJoinMeeting, request, cb);
        }));
    }

    virtual void isTurnOnMyVideoWhenJoinMeetingEnabled(const NESettingsService::NEBoolCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, cb]() {
            m_pSettingsService->SendData(SettingsCID::SettingsCID_isTurnOnMyVideoWhenJoinMeetingEnabled, NEMIPCProtocolEmptyBody(), cb);
        }));
    }

    virtual void setRemoteVideoResolution(RemoteVideoResolution enumRemoteVideoResolution, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, enumRemoteVideoResolution, cb]() {
            SettingsIntRequest request;
            request.value_ = (int)enumRemoteVideoResolution;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setRemoteVideoResolution, request, cb);
        }));
    }

    virtual void getRemoteVideoResolution(const NESettingsService::NERemoteVideoResolutionCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", RemoteVideoResolution_Default);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_getRemoteVideoResolution, NEMIPCProtocolEmptyBody(), cb); }));
    }

    virtual void setMyVideoResolution(LocalVideoResolution enumLocalVideoResolution, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, enumLocalVideoResolution, cb]() {
            SettingsIntRequest request;
            request.value_ = (int)enumLocalVideoResolution;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setMyVideoResolution, request, cb);
        }));
    }

    virtual void getMyVideoResolution(const NESettingsService::NELocalVideoResolutionCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", LocalVideoResolution_720P);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_getMyVideoResolution, NEMIPCProtocolEmptyBody(), cb); }));
    }

    virtual void setMyVideoFramerate(LocalVideoFramerate enumLocalVideoFramerate, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, enumLocalVideoFramerate, cb]() {
            SettingsIntRequest request;
            request.value_ = (int)enumLocalVideoFramerate;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setMyVideoFramerate, request, cb);
        }));
    }

private:
    NESettingsServiceIMP* m_pSettingsService = nullptr;
};

class NEAudioControllerIMP : public NEAudioController {
public:
    NEAudioControllerIMP(NESettingsServiceIMP* pSettingsService)
        : m_pSettingsService(pSettingsService) {}
    ~NEAudioControllerIMP() {}

    virtual void setTurnOnMyAudioWhenJoinMeeting(bool bOn, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, bOn, cb]() {
            SettingsBoolRequest request;
            request.status_ = bOn;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_TurnOnMyAudioWhenJoinMeeting, request, cb);
        }));
    }

    virtual void isTurnOnMyAudioWhenJoinMeetingEnabled(const NESettingsService::NEBoolCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, cb]() {
            m_pSettingsService->SendData(SettingsCID::SettingsCID_isTurnOnMyAudioWhenJoinMeetingEnabled, NEMIPCProtocolEmptyBody(), cb);
        }));
    }

    virtual void setTurnOnMyAudioAINSWhenInMeeting(bool bOn, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, bOn, cb]() {
            SettingsBoolRequest request;
            request.status_ = bOn;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_TurnOnMyAudioAINSWhenInMeeting, request, cb);
        }));
    }

    virtual void isTurnOnMyAudioAINSWhenInMeetingEnabled(const NESettingsService::NEBoolCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, cb]() {
            m_pSettingsService->SendData(SettingsCID::SettingsCID_isTurnOnMyAudioAINSWhenInMeetingEnabled, NEMIPCProtocolEmptyBody(), cb);
        }));
    }

    virtual void setMyAudioVolumeAutoAdjust(bool bOn, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, bOn, cb]() {
            SettingsBoolRequest request;
            request.status_ = bOn;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setMyAudioVolumeAutoAdjust, request, cb);
        }));
    }

    virtual void isMyAudioVolumeAutoAdjust(const NESettingsService::NEBoolCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_isMyAudioVolumeAutoAdjust, NEMIPCProtocolEmptyBody(), cb); }));
    }

    virtual void setMyAudioQuality(AudioQuality enumAudioQuality, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, enumAudioQuality, cb]() {
            SettingsIntRequest request;
            request.value_ = (int)enumAudioQuality;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setMyAudioQuality, request, cb);
        }));
    }

    virtual void getMyAudioQuality(const NESettingsService::NEAudioQualityCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", AudioQuality_Talk);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_getMyAudioQuality, NEMIPCProtocolEmptyBody(), cb); }));
    }

    virtual void setMyAudioEchoCancellation(bool bOn, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, bOn, cb]() {
            SettingsBoolRequest request;
            request.status_ = bOn;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setMyAudioEchoCancellation, request, cb);
        }));
    }

    virtual void isMyAudioEchoCancellation(const NESettingsService::NEBoolCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_isMyAudioEchoCancellation, NEMIPCProtocolEmptyBody(), cb); }));
    }

    virtual void setMyAudioEnableStereo(bool bOn, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, bOn, cb]() {
            SettingsBoolRequest request;
            request.status_ = bOn;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setMyAudioEnableStereo, request, cb);
        }));
    }

    virtual void isMyAudioEnableStereo(const NESettingsService::NEBoolCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_isMyAudioEnableStereo, NEMIPCProtocolEmptyBody(), cb); }));
    }

    virtual void setMyAudioDeviceAutoSelectType(AudioDeviceAutoSelectType enumAudioDeviceAutoSelectType, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, enumAudioDeviceAutoSelectType, cb]() {
            SettingsIntRequest request;
            request.value_ = (int)enumAudioDeviceAutoSelectType;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setMyAudioDeviceAutoSelectType, request, cb);
        }));
    }

    virtual void isMyAudioDeviceAutoSelectType(const NESettingsService::AudioDeviceAutoSelectTypeCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", AudioDeviceAutoSelectType_Available);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_isMyAudioDeviceAutoSelectType, NEMIPCProtocolEmptyBody(), cb); }));
    }

    virtual void setMyAudioDeviceUseLastSelected(bool bOn, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, bOn, cb]() {
            SettingsBoolRequest request;
            request.status_ = bOn;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setMyAudioDeviceUseLastSelected, request, cb);
        }));
    }

    virtual void isMyAudioDeviceUseLastSelected(const NESettingsService::NEBoolCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_isMyAudioDeviceUseLastSelected, NEMIPCProtocolEmptyBody(), cb); }));
    }

private:
    NESettingsServiceIMP* m_pSettingsService = nullptr;
};

class NEOtherControllerIMP : public NEOtherController {
public:
    NEOtherControllerIMP(NESettingsServiceIMP* pSettingsService)
        : m_pSettingsService(pSettingsService) {}
    ~NEOtherControllerIMP() {}

    /*virtual void enableShowMyMeetingElapseTime(bool show, const NEEmptyCallback& cb) const
    {
        if (!m_pSettingsService)
        {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, show, cb]() {
            SettingsBoolRequest request;
            request.status_ = show;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_ShowMyMeetingElapseTime, request, cb);
        }));
    }

    virtual void isShowMyMeetingElapseTimeEnabled(const NESettingsService::NEBoolCallback& cb) const
    {
        if (!m_pSettingsService)
        {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, cb]() {
            m_pSettingsService->SendData(SettingsCID::SettingsCID_IsShowMyMeetingElapseTimeEnabled, NEMIPCProtocolEmptyBody(), cb);
        }));
    }*/

    virtual void enableUnmuteBySpace(bool show, const NEEmptyCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, show, cb]() {
            SettingsBoolRequest request;
            request.status_ = show;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_enableUnmuteBySpace, request, cb);
        }));
    }

    virtual void isUnmuteBySpaceEnabled(const NESettingsService::NEBoolCallback& cb) const {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_isUnmuteBySpaceEnabled, NEMIPCProtocolEmptyBody(), cb); }));
    }

    void setSharingSidebarViewMode(SharingSidebarViewMode viewMode, const NEEmptyCallback& cb) override {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, viewMode, cb]() {
            SettingsIntRequest request;
            request.value_ = static_cast<int>(viewMode);
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setSharingSidebarViewMode, request, cb);
        }));
    }

    void getSharingSidebarViewMode(const NESettingsService::NESharingSidebarViewModeCallback& cb) const override {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", kSharingSidebarViewModeUnknown);
            return;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_getSharingSidebarViewMode, NEMIPCProtocolEmptyBody(), cb); }));
    }

private:
    NESettingsServiceIMP* m_pSettingsService = nullptr;
};

class NEBeautyFaceControllerIMP : public NEBeautyFaceController {
public:
    NEBeautyFaceControllerIMP(NESettingsServiceIMP* pSettingsService)
        : m_pSettingsService(pSettingsService) {}
    ~NEBeautyFaceControllerIMP() {}

public:
    /**
     * ʹܽӿڣշ񿪹
     * @param enable true-򿪣false-ر
     * @return ִн
     */
    virtual bool enableBeautyFace(bool enable, const NESettingsService::NEBoolCallback& cb) override {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return false;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, enable, cb]() {
            SettingsBoolRequest request;
            request.status_ = enable;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_BeautyEnabled, request, cb);
        }));
        return true;
    }

    /**
     * ѯտ״̬رػհť
     * @return true-򿪣false-ر
     */
    virtual bool isBeautyFaceEnabled(const NESettingsService::NEBoolCallback& cb) override {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return false;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_isBeautyEnabled, NEMIPCProtocolEmptyBody(), cb); }));
        return true;
    }

    /**
     * ȡǰղرշ0
     * @return true-򿪣false-ر
     */
    virtual bool getBeautyFaceValue(const NESettingsService::NEIntCallback& cb) override {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", 0);
            return false;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_getBeautyParams, NEMIPCProtocolEmptyBody(), cb); }));
        return true;
    }

    /**
     * ղ
     * @param value յȼΪ[0,10]
     * @return ִн
     */
    virtual bool setBeautyFaceValue(int value, const NESettingsService::NEBoolCallback& cb) override {
        if (value > 10 || value < 0) {
            cb(NEErrorCode::MEETING_ERROR_FAILED_PARAM_ERROR, "invalid param", false);
            return false;
        }
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return false;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, value, cb]() {
            SettingsIntRequest request;
            request.value_ = value;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setBeautyParams, request, cb);
        }));
        return true;
    }

private:
    NESettingsServiceIMP* m_pSettingsService = nullptr;
};

class NELiveControllerIMP : public NELiveController {
public:
    NELiveControllerIMP(NESettingsServiceIMP* pSettingsService)
        : m_pSettingsService(pSettingsService) {}
    ~NELiveControllerIMP() {}

public:
    /**
     * ѯֱ״̬
     * @return true-򿪣false-ر
     */
    virtual bool isLiveEnabled(const NESettingsService::NEBoolCallback& cb) override {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return false;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_isLiveEnabled, NEMIPCProtocolEmptyBody(), cb); }));
        return true;
    }

private:
    NESettingsServiceIMP* m_pSettingsService = nullptr;
};

class NEWhiteboardControllerIMP : public NEWhiteboardController {
public:
    NEWhiteboardControllerIMP(NESettingsServiceIMP* pSettingsService)
        : m_pSettingsService(pSettingsService) {}
    ~NEWhiteboardControllerIMP() {}

public:
    /**
     * ѯװ忪״̬
     * @return true-򿪣false-ر
     */
    virtual bool isWhiteboardEnabled(const NESettingsService::NEBoolCallback& cb) override {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return false;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_isWhiteboardEnabled, NEMIPCProtocolEmptyBody(), cb); }));
        return true;
    }

private:
    NESettingsServiceIMP* m_pSettingsService = nullptr;
};

class NEVirtualBackgroundControllerIMP : public NEVirtualBackgroundController {
public:
    NEVirtualBackgroundControllerIMP(NESettingsServiceIMP* pSettingsService)
        : m_pSettingsService(pSettingsService) {}
    ~NEVirtualBackgroundControllerIMP() {}

public:
    /**
     * @brief ⱳǷʾ
     * @param enable true-򿪣false-ر
     * @param cb ص
     * @return bool
     * - true ɹ
     * - falseʧ
     */
    virtual bool enableVirtualBackground(bool enable, const NEEmptyCallback& cb) override {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return false;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, enable, cb]() {
            SettingsBoolRequest request;
            request.status_ = enable;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setVirtualBackgroundEnabled, request, cb);
        }));
        return true;
    }

    /**
     * @brief ѯⱳʾ״̬
     * @param cb ص
     * @return bool
     * - true ɹ
     * - falseʧ
     */
    virtual bool isVirtualBackgroundEnabled(const NESettingsService::NEBoolCallback& cb) override {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return false;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_isVirtualBackgroundEnabled, NEMIPCProtocolEmptyBody(), cb); }));
        return true;
    }

    /**
     * @brief ȡⱳб
     * @param cb ص
     * @return
     * - true ɹ
     * - falseʧ
     */
    virtual bool getBuiltinVirtualBackgrounds(const NESettingsService::NEVirtualBackgroundCallback& cb) override {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", std::vector<NEMeetingVirtualBackground>{});
            return false;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_getVirtualBackgroundList, NEMIPCProtocolEmptyBody(), cb); }));
        return true;
    }

    /**
     * @brief ⱳб
     * @param virtualBackgrounds ⱳб
     * @param cb ص
     * @return bool
     * - true ɹ
     * - falseʧ
     */
    virtual bool setBuiltinVirtualBackgrounds(const std::vector<NEMeetingVirtualBackground>& virtualBackgrounds, const NEEmptyCallback& cb) override {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return false;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, virtualBackgrounds, cb]() {
            SettingsSetVirtualBackgroundListRequest request;
            request.params_ = virtualBackgrounds;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_setVirtualBackgroundList, request, cb);
        }));
        return true;
    }

private:
    NESettingsServiceIMP* m_pSettingsService = nullptr;
};

class NERecordControllerIMP : public NERecordController {
public:
    NERecordControllerIMP(NESettingsServiceIMP* pSettingsService)
        : m_pSettingsService(pSettingsService) {}
    ~NERecordControllerIMP() {}

public:
    /**
     * ѯ¼ƿ״̬
     * @return true-򿪣false-ر
     */
    virtual bool isCloudRecordEnabled(const NESettingsService::NEBoolCallback& cb) override {
        if (!m_pSettingsService) {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return false;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback(
            [this, cb]() { m_pSettingsService->SendData(SettingsCID::SettingsCID_isCloudRecordEnabled, NEMIPCProtocolEmptyBody(), cb); }));
        return true;
    }

private:
    NESettingsServiceIMP* m_pSettingsService = nullptr;
};

NESettingsServiceIMP::NESettingsServiceIMP()
    : IService(ServiceID::SID_Setting)
    , video_controller_(new NEVideoControllerIMP(this))
    , audio_controller_(new NEAudioControllerIMP(this))
    , other_controller_(new NEOtherControllerIMP(this))
    , beauty_controller_(new NEBeautyFaceControllerIMP(this))
    , live_controller_(new NELiveControllerIMP(this))
    , whiteboard_controller_(new NEWhiteboardControllerIMP(this))
    , record_controller_(new NERecordControllerIMP(this))
    , virtualBackground_controller_(new NEVirtualBackgroundControllerIMP(this)) {}

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
    PostTaskToProcThread(ToWeakCallback([this, config, cb]() {
        ShowUIWndRequest request;
        request.config_ = config;
        SendData(SettingsCID::SettingsCID_ShowUIWnd, request, IPCAsyncResponseCallback(cb));
    }));
}

void NESettingsServiceIMP::getHistoryMeetingItem(const NEHistoryMeetingCallback& callback) {
    PostTaskToProcThread(ToWeakCallback([this, callback]() {
        SettingsGetHistoryMeetingRequest request;
        SendData(SettingsCID::SettingsCID_getHistoryMeeting, request, IPCAsyncResponseCallback(callback));
    }));
}

void NESettingsServiceIMP::OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb) {
    switch (cid) {
        case SettingsCID::SettingsCID_ShowUIWnd_CB: {
            ShowUIWndResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEShowSettingUIWndCallback start_cb = cb.GetResponseCallback<NEShowSettingUIWndCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_ShowMyMeetingElapseTime_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_IsShowMyMeetingElapseTimeEnabled_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_TurnOnMyVideoWhenJoinMeeting_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_isTurnOnMyVideoWhenJoinMeetingEnabled_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_TurnOnMyAudioWhenJoinMeeting_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_isTurnOnMyAudioWhenJoinMeetingEnabled_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_TurnOnMyAudioAINSWhenInMeeting_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_isTurnOnMyAudioAINSWhenInMeetingEnabled_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_BeautyEnabled_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_isBeautyEnabled_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_setBeautyParams_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback set_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (set_cb != nullptr)
                set_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_getBeautyParams_CB: {
            SettingsIntResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEIntCallback get_cb = cb.GetResponseCallback<NEIntCallback>();
            if (get_cb != nullptr)
                get_cb(response.error_code_, response.error_msg_, response.value_);
        } break;
        case SettingsCID::SettingsCID_isLiveEnabled_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_getHistoryMeeting_CB: {
            SettingsGetHistoryMeetingResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEHistoryMeetingCallback start_cb = cb.GetResponseCallback<NEHistoryMeetingCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.params_);
        } break;
        case SettingsCID::SettingsCID_isWhiteboardEnabled_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_isCloudRecordEnabled_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_setRemoteVideoResolution_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_getRemoteVideoResolution_CB: {
            SettingsIntResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NERemoteVideoResolutionCallback start_cb = cb.GetResponseCallback<NERemoteVideoResolutionCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, (RemoteVideoResolution)response.value_);
        } break;
        case SettingsCID::SettingsCID_setMyVideoResolution_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_getMyVideoResolution_CB: {
            SettingsIntResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NELocalVideoResolutionCallback start_cb = cb.GetResponseCallback<NELocalVideoResolutionCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, (LocalVideoResolution)response.value_);
        } break;
        case SettingsCID::SettingsCID_setMyVideoFramerate_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_setMyAudioVolumeAutoAdjust_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_isMyAudioVolumeAutoAdjust_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_setMyAudioQuality_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_getMyAudioQuality_CB: {
            SettingsIntResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEAudioQualityCallback start_cb = cb.GetResponseCallback<NEAudioQualityCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, (AudioQuality)response.value_);
        } break;
        case SettingsCID::SettingsCID_setMyAudioEchoCancellation_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_isMyAudioEchoCancellation_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_setMyAudioEnableStereo_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_isMyAudioEnableStereo_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_setMyAudioDeviceAutoSelectType_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_isMyAudioDeviceAutoSelectType_CB: {
            SettingsIntResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            AudioDeviceAutoSelectTypeCallback start_cb = cb.GetResponseCallback<AudioDeviceAutoSelectTypeCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, (AudioDeviceAutoSelectType)response.value_);
        } break;
        case SettingsCID::SettingsCID_setVirtualBackgroundEnabled_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_isVirtualBackgroundEnabled_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_setVirtualBackgroundList_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_getVirtualBackgroundList_CB: {
            SettingsGetVirtualBackgroundListResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEVirtualBackgroundCallback start_cb = cb.GetResponseCallback<NEVirtualBackgroundCallback>();
            if (start_cb != nullptr) {
                start_cb(response.error_code_, response.error_msg_, response.params_);
            }
        } break;
        case SettingsCID::SettingsCID_enableUnmuteBySpace_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_isUnmuteBySpaceEnabled_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_setMyAudioDeviceUseLastSelected_CB:
        case SettingsCID::SettingsCID_setSharingSidebarViewMode_CB: {
            NEMIPCProtocolErrorInfoBody response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_);
        } break;
        case SettingsCID::SettingsCID_isMyAudioDeviceUseLastSelected_CB: {
            SettingsBoolResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
            if (start_cb != nullptr)
                start_cb(response.error_code_, response.error_msg_, response.status_);
        } break;
        case SettingsCID::SettingsCID_getSharingSidebarViewMode_CB: {
            SettingsIntResponse response;
            if (!response.Parse(data))
                response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
            NESharingSidebarViewModeCallback get_cb = cb.GetResponseCallback<NESharingSidebarViewModeCallback>();
            if (get_cb != nullptr)
                get_cb(response.error_code_, response.error_msg_, static_cast<SharingSidebarViewMode>(response.value_));
        } break;
    }
}

void NESettingsServiceIMP::OnPack(int cid, const std::string& data, uint64_t sn) {
    switch (cid) {
        case SettingsCID::SettingsCID_ChangeNotify: {
            SettingsChangeNotify notify;
            if (settings_chg_notify_handler_ != nullptr && notify.Parse(data)) {
                switch (notify.type_) {
                    case NS_I_NEM_SDK::SettingChangType::SettingChangType_Audio:
                        settings_chg_notify_handler_->OnAudioSettingsChange(notify.status_);
                        break;
                    case NS_I_NEM_SDK::SettingChangType::SettingChangType_Video:
                        settings_chg_notify_handler_->OnVideoSettingsChange(notify.status_);
                        break;
                    case NS_I_NEM_SDK::SettingChangType::SettingChangType_AudioAINS:
                        settings_chg_notify_handler_->OnAudioAINSSettingsChange(notify.status_);
                        break;
                    case NS_I_NEM_SDK::SettingChangType::SettingChangType_AudioVolumeAutoAdjust:
                        settings_chg_notify_handler_->OnAudioVolumeAutoAdjustSettingsChange(notify.status_);
                        break;
                    case NS_I_NEM_SDK::SettingChangType::SettingChangType_AudioQuality:
                        settings_chg_notify_handler_->OnAudioQualitySettingsChange((AudioQuality)notify.value_);
                        break;
                    case NS_I_NEM_SDK::SettingChangType::SettingChangType_AudioEchoCancellation:
                        settings_chg_notify_handler_->OnAudioEchoCancellationSettingsChange(notify.status_);
                        break;
                    case NS_I_NEM_SDK::SettingChangType::SettingChangType_AudioEnableStereo:
                        settings_chg_notify_handler_->OnAudioEnableStereoSettingsChange(notify.status_);
                        break;
                    case NS_I_NEM_SDK::SettingChangType::SettingChangType_RemoteVideoResolution:
                        settings_chg_notify_handler_->OnRemoteVideoResolutionSettingsChange((RemoteVideoResolution)notify.value_);
                        break;
                    case NS_I_NEM_SDK::SettingChangType::SettingChangType_MyVideoResolution:
                        settings_chg_notify_handler_->OnMyVideoResolutionSettingsChange((LocalVideoResolution)notify.value_);
                        break;
                    case NS_I_NEM_SDK::SettingChangType::SettingChangType_Other:
                        settings_chg_notify_handler_->OnOtherSettingsChange(notify.status_);
                        break;
                    default:
                        break;
                }
            }
        } break;
    }
}

NNEM_SDK_HOSTING_MODULE_END_DECLS
