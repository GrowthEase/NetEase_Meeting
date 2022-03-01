/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_SERVICE_SETTING_SERVICE_H_
#define NEM_HOSTING_MODULE_SERVICE_SETTING_SERVICE_H_
#include "nemeeting_sdk_interface_include.h"
#include "nem_hosting_module/config/build_config.h"
#include "nem_hosting_module_core/service/service.h"

NNEM_SDK_HOSTING_MODULE_BEGIN_DECLS

USING_NS_NNEM_SDK_INTERFACE

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

class NEM_SDK_INTERFACE_EXPORT NESettingsServiceIMP : public NESettingsService , public IService<NS_NIPCLIB::IPCServer>
{
public:
	NESettingsServiceIMP();
	~NESettingsServiceIMP();
    friend class NEVideoControllerIMP;
    friend class NEAudioControllerIMP;
    friend class NEOtherControllerIMP;
    friend class NEBeautyFaceControllerIMP;
    friend class NELiveControllerIMP;
    friend class NEWhiteboardControllerIMP;
    friend class NERecordControllerIMP;

public:
	virtual NEVideoController* GetVideoController() const override;

	virtual NEAudioController* GetAudioController() const override;

    virtual NEOtherController* GetOtherController() const override;

	virtual NEBeautyFaceController* GetBeautyFaceController() const override;

	virtual NELiveController* GetLiveController() const override;

    virtual NEWhiteboardController* GetWhiteboardController() const override;

	virtual NERecordController* GetRecordController() const override;

	virtual void showSettingUIWnd(const NESettingsUIWndConfig& config, const NEShowSettingUIWndCallback& cb) override;

	virtual void setNESettingsChangeNotifyHandler(NESettingsChangeNotifyHandler* handler) override {
		settings_chg_notify_handler_ = handler;
	}

	virtual void getHistoryMeetingItem(const NEHistoryMeetingCallback& callback) override;

private:
	virtual void OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb) override;
	virtual void OnPack(int cid, const std::string& data, uint64_t sn) override;
private:
	std::unique_ptr<NEVideoController> video_controller_;
	std::unique_ptr<NEAudioController> audio_controller_;
    std::unique_ptr<NEOtherController> other_controller_;
	std::unique_ptr<NEBeautyFaceController> beauty_controller_;
	std::unique_ptr<NELiveController> live_controller_;
    std::unique_ptr<NEWhiteboardController> whiteboard_controller_;
    std::unique_ptr<NERecordController> record_controller_;
	NESettingsChangeNotifyHandler* settings_chg_notify_handler_ = nullptr;
};

NNEM_SDK_HOSTING_MODULE_END_DECLS

#endif //NEM_HOSTING_MODULE_SERVICE_SETTING_SERVICE_H_