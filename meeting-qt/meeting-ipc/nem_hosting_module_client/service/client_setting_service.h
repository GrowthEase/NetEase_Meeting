/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_CLIENT_SERVICE_SETTING_SERVICE_H_
#define NEM_HOSTING_MODULE_CLIENT_SERVICE_SETTING_SERVICE_H_
#include "client_nemeeting_sdk_interface_include.h"
#include "nem_hosting_module_client/config/build_config.h"
#include "nem_hosting_module_core/service/service.h"

NNEM_SDK_HOSTING_MODULE_CLIENT_BEGIN_DECLS

USING_NS_NNEM_SDK_INTERFACE

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

class NEVideoControllerIMP;
class NEAudioControllerIMP;
class NEOtherControllerIMP;
class NEBeautyControllerIMP;
class NEWhiteboardControllerIMP;
class NERecordControllerIMP;
class NEM_SDK_INTERFACE_EXPORT NESettingsServiceIMP : public NESettingsServiceIPCClient, public IService<NS_NIPCLIB::IPCClient>
{
    friend NEMeetingSDKIPCClient* NEMeetingSDKIPCClient::getInstance();
public:
    NESettingsServiceIMP();
    ~NESettingsServiceIMP();
public:
    virtual NEVideoController* GetVideoController() const override;

    virtual NEAudioController* GetAudioController() const override;

    virtual NEOtherController* GetOtherController() const override;

	virtual NEBeautyFaceController* GetBeautyFaceController() const override;

	virtual NELiveController* GetLiveController() const override;

    virtual NEWhiteboardController* GetWhiteboardController() const override;

    virtual NERecordController* GetRecordController() const override;

    virtual void setNESettingsChangeNotifyHandler(NESettingsChangeNotifyHandler* handler) override {}
    virtual void showSettingUIWnd(const NESettingsUIWndConfig& config, const NEShowSettingUIWndCallback& cb) override;
    virtual void notifySettingsChange(SettingChangType type, bool status) override;
    virtual void getHistoryMeetingItem(const NEHistoryMeetingCallback& callback) override;
private:
    void OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb) override {};
    virtual void OnPack(int cid, const std::string& data, uint64_t sn) override;
private:
    std::unique_ptr<NEVideoControllerIMP> video_controller_;
    std::unique_ptr<NEAudioControllerIMP> audio_controller_;
    std::unique_ptr<NEOtherControllerIMP> other_controller_;
	std::unique_ptr<NEBeautyFaceController> beauty_controller_;
	std::unique_ptr<NELiveController> live_controller_;
    std::unique_ptr<NEWhiteboardController> whiteboard_controller_;
    std::unique_ptr<NERecordControllerIMP> record_controller_;
};

NNEM_SDK_HOSTING_MODULE_CLIENT_END_DECLS

#endif //NEM_HOSTING_MODULE_CLIENT_SERVICE_SETTING_SERVICE_H_
