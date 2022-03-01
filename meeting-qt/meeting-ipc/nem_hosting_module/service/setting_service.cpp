/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module/service/setting_service.h"

#include "nem_hosting_module_protocol/protocol/settings_protocol.h"

NNEM_SDK_HOSTING_MODULE_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL

class NEVideoControllerIMP : public NEVideoController
{
public:
    NEVideoControllerIMP(NESettingsServiceIMP* pSettingsService)
        : m_pSettingsService(pSettingsService)
    {}
    ~NEVideoControllerIMP() {}

    virtual void setTurnOnMyVideoWhenJoinMeeting(bool bOn, const NEEmptyCallback& cb) const
    {
        if (!m_pSettingsService)
        {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, bOn, cb]() {
            SettingsBoolRequest request;
            request.status_ = bOn;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_TurnOnMyVideoWhenJoinMeeting, request, cb);
        }));
    }

    virtual void isTurnOnMyVideoWhenJoinMeetingEnabled(const NESettingsService::NEBoolCallback& cb) const
    {
        if (!m_pSettingsService)
        {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, cb]() {
            m_pSettingsService->SendData(SettingsCID::SettingsCID_isTurnOnMyVideoWhenJoinMeetingEnabled, NEMIPCProtocolEmptyBody(), cb);
        }));
    }

private:
    NESettingsServiceIMP* m_pSettingsService = nullptr;
};
class NEAudioControllerIMP : public NEAudioController
{
public:
    NEAudioControllerIMP(NESettingsServiceIMP* pSettingsService)
        : m_pSettingsService(pSettingsService)
    {}
    ~NEAudioControllerIMP() {}

    virtual void setTurnOnMyAudioWhenJoinMeeting(bool bOn, const NEEmptyCallback& cb) const
    {
        if (!m_pSettingsService)
        {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "");
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, bOn, cb]() {
            SettingsBoolRequest request;
            request.status_ = bOn;
            m_pSettingsService->SendData(SettingsCID::SettingsCID_TurnOnMyAudioWhenJoinMeeting, request, cb);
        }));
    }

    virtual void isTurnOnMyAudioWhenJoinMeetingEnabled(const NESettingsService::NEBoolCallback& cb) const
    {
        if (!m_pSettingsService)
        {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return;
        }

        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, cb]() {
            m_pSettingsService->SendData(SettingsCID::SettingsCID_isTurnOnMyAudioWhenJoinMeetingEnabled, NEMIPCProtocolEmptyBody(), cb);
        }));
    }
private:
    NESettingsServiceIMP* m_pSettingsService = nullptr;
};

class NEOtherControllerIMP : public NEOtherController
{
public:
    NEOtherControllerIMP(NESettingsServiceIMP* pSettingsService)
        : m_pSettingsService(pSettingsService)
    {}
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
private:
    NESettingsServiceIMP* m_pSettingsService = nullptr;
};

class NEBeautyFaceControllerIMP : public NEBeautyFaceController
{
public:
	NEBeautyFaceControllerIMP(NESettingsServiceIMP* pSettingsService)
		: m_pSettingsService(pSettingsService)
	{}
	~NEBeautyFaceControllerIMP() {}
public:
	/**
	* 美颜使能接口，控制美颜服务开关
	* @param enable true-打开，false-关闭
	* @return 返回执行结果
	*/
// 	virtual bool enableBeautyFace(bool enable, const NESettingsService::NEBoolCallback& cb) override {
// 		if (!m_pSettingsService)
// 		{
// 			cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
// 			return false;
// 		}
// 
// 		m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, enable, cb]() {
// 			SettingsBoolRequest request;
// 			request.status_ = enable;
// 			m_pSettingsService->SendData(SettingsCID::SettingsCID_BeautyEnabled, request, cb);
// 		}));
// 		return true;
// 	}

	/**
	 * 查询美颜开关状态，关闭在隐藏会中美颜按钮
	 * @return true-打开，false-关闭
	 */
	virtual bool isBeautyFaceEnabled(const NESettingsService::NEBoolCallback& cb) override {
		if (!m_pSettingsService)
		{
			cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
			return false;
		}
		m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, cb]() {
			m_pSettingsService->SendData(SettingsCID::SettingsCID_isBeautyEnabled, NEMIPCProtocolEmptyBody(), cb);
		}));
		return true;
	}


	/**
	 * 获取当前美颜参数，关闭返回0
	 * @return true-打开，false-关闭
	 */
	virtual bool getBeautyFaceValue(const NESettingsService::NEIntCallback& cb) override {
		if (!m_pSettingsService)
		{
			cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", 0);
			return false;
		}
		m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, cb]() {
			m_pSettingsService->SendData(SettingsCID::SettingsCID_getBeautyParams, NEMIPCProtocolEmptyBody(), cb);
		}));
		return true;
	}

	/**
	 * 设置美颜参数
	 * @param value 传入美颜等级，参数规则为[0,10]整数
	 * @return 返回执行结果
	 */
	virtual bool setBeautyFaceValue(int value, const NESettingsService::NEBoolCallback& cb) override {
		if (value > 10 || value < 0) 
		{
			cb(NEErrorCode::MEETING_ERROR_FAILED_PARAM_ERROR, "invalid param", false);
			return false;
		}
		if (!m_pSettingsService)
		{
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

class NELiveControllerIMP : public NELiveController
{
public:
	NELiveControllerIMP(NESettingsServiceIMP* pSettingsService)
		: m_pSettingsService(pSettingsService)
	{}
	~NELiveControllerIMP() {}
public:
	 /**
	 * 查询直播开关状态
	 * @return true-打开，false-关闭
	 */
	virtual bool isLiveEnabled(const NESettingsService::NEBoolCallback& cb) override {
		if (!m_pSettingsService)
		{
			cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
			return false;
		}
		m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, cb]() {
			m_pSettingsService->SendData(SettingsCID::SettingsCID_isLiveEnabled, NEMIPCProtocolEmptyBody(), cb);
		}));
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
     * 查询白板开关状态
     * @return true-打开，false-关闭
     */
    virtual bool isWhiteboardEnabled(const NESettingsService::NEBoolCallback& cb) override {
        if (!m_pSettingsService) 
        {
            cb(NEErrorCode::ERROR_CODE_NOT_IMPLEMENTED, "", false);
            return false;
        }
        m_pSettingsService->PostTaskToProcThread(m_pSettingsService->ToWeakCallback([this, cb]() {
            m_pSettingsService->SendData(SettingsCID::SettingsCID_isWhiteboardEnabled, NEMIPCProtocolEmptyBody(), cb);
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
     * 查询录制开关状态
     * @return true-打开，false-关闭
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

NESettingsServiceIMP::NESettingsServiceIMP() : IService(ServiceID::SID_Setting),
video_controller_(new NEVideoControllerIMP(this)),
audio_controller_(new NEAudioControllerIMP(this)),
other_controller_(new NEOtherControllerIMP(this)),
beauty_controller_(new NEBeautyFaceControllerIMP(this)),
live_controller_(new NELiveControllerIMP(this)), 
whiteboard_controller_(new NEWhiteboardControllerIMP(this)),
record_controller_(new NERecordControllerIMP(this))
{
}
NESettingsServiceIMP::~NESettingsServiceIMP()
{

}
NEVideoController* NESettingsServiceIMP::GetVideoController() const
{
    return video_controller_.get();
}
NEAudioController* NESettingsServiceIMP::GetAudioController() const
{
    return audio_controller_.get();
}
NEOtherController* NESettingsServiceIMP::GetOtherController() const
{
    return other_controller_.get();
}

NEBeautyFaceController* NESettingsServiceIMP::GetBeautyFaceController() const
{
	return beauty_controller_.get();
}

NELiveController* NESettingsServiceIMP::GetLiveController() const
{
	return live_controller_.get();
}

NEWhiteboardController* NESettingsServiceIMP::GetWhiteboardController() const
{
    return whiteboard_controller_.get();
}

NERecordController* NESettingsServiceIMP::GetRecordController() const
{
    return record_controller_.get();
}

void NESettingsServiceIMP::showSettingUIWnd(const NESettingsUIWndConfig& config, const NEShowSettingUIWndCallback& cb)
{
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

void NESettingsServiceIMP::OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb)
{
    switch (cid)
    {
    case SettingsCID::SettingsCID_ShowUIWnd_CB:
    {
        ShowUIWndResponse response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEShowSettingUIWndCallback start_cb = cb.GetResponseCallback<NEShowSettingUIWndCallback>();
        if (start_cb != nullptr)
            start_cb(response.error_code_, response.error_msg_);
    }
    break;
    case SettingsCID::SettingsCID_ShowMyMeetingElapseTime_CB:
    {
        NEMIPCProtocolErrorInfoBody response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
        if (start_cb != nullptr)
            start_cb(response.error_code_, response.error_msg_);
    }
    break;
    case SettingsCID::SettingsCID_IsShowMyMeetingElapseTimeEnabled_CB:
    {
        SettingsBoolResponse response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
        if (start_cb != nullptr)
            start_cb(response.error_code_, response.error_msg_, response.status_);
    }
    break;
    case SettingsCID::SettingsCID_TurnOnMyVideoWhenJoinMeeting_CB:
    {
        NEMIPCProtocolErrorInfoBody response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
        if (start_cb != nullptr)
            start_cb(response.error_code_, response.error_msg_);
    }
    break;
    case SettingsCID::SettingsCID_isTurnOnMyVideoWhenJoinMeetingEnabled_CB:
    {
        SettingsBoolResponse response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
        if (start_cb != nullptr)
            start_cb(response.error_code_, response.error_msg_, response.status_);
    }
    break;
    case SettingsCID::SettingsCID_TurnOnMyAudioWhenJoinMeeting_CB:
    {
        NEMIPCProtocolErrorInfoBody response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEEmptyCallback start_cb = cb.GetResponseCallback<NEEmptyCallback>();
        if (start_cb != nullptr)
            start_cb(response.error_code_, response.error_msg_);
    }
    break;
    case SettingsCID::SettingsCID_isTurnOnMyAudioWhenJoinMeetingEnabled_CB:
    {
        SettingsBoolResponse response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
        if (start_cb != nullptr)
            start_cb(response.error_code_, response.error_msg_, response.status_);
    }
    break;


	case SettingsCID::SettingsCID_BeautyEnabled_CB:
	{
		SettingsBoolResponse response;
		if (!response.Parse(data))
			response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
		NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
		if (start_cb != nullptr)
			start_cb(response.error_code_, response.error_msg_, response.status_);
	}
	break;

	case SettingsCID::SettingsCID_isBeautyEnabled_CB:
	{
		SettingsBoolResponse response;
		if (!response.Parse(data))
			response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
		NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
		if (start_cb != nullptr)
			start_cb(response.error_code_, response.error_msg_, response.status_);
	}
	break;

	case SettingsCID::SettingsCID_setBeautyParams_CB:
	{
		SettingsBoolResponse response;
		if (!response.Parse(data))
			response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
		NEBoolCallback set_cb = cb.GetResponseCallback<NEBoolCallback>();
		if (set_cb != nullptr)
			set_cb(response.error_code_, response.error_msg_, response.status_);
	}
	break;

	case SettingsCID::SettingsCID_getBeautyParams_CB:
	{
		SettingsIntResponse response;
		if (!response.Parse(data))
			response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
		NEIntCallback get_cb = cb.GetResponseCallback<NEIntCallback>();
		if (get_cb != nullptr)
			get_cb(response.error_code_, response.error_msg_, response.value_);
	}
	break;

	case SettingsCID::SettingsCID_isLiveEnabled_CB:
	{
		SettingsBoolResponse response;
		if (!response.Parse(data))
			response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
		NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
		if (start_cb != nullptr)
			start_cb(response.error_code_, response.error_msg_, response.status_);
	}
	break;

    case SettingsCID::SettingsCID_getHistoryMeeting_CB: 
    {
        SettingsGetHistoryMeetingResponse response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEHistoryMeetingCallback start_cb = cb.GetResponseCallback<NEHistoryMeetingCallback>();
        if (start_cb != nullptr)
            start_cb(response.error_code_, response.error_msg_, response.params_);
    } 
    break;

    case SettingsCID::SettingsCID_isWhiteboardEnabled_CB: 
    {
        SettingsBoolResponse response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
        if (start_cb != nullptr)
            start_cb(response.error_code_, response.error_msg_, response.status_);
    } 
    break;

    case SettingsCID::SettingsCID_isCloudRecordEnabled_CB: {
        SettingsBoolResponse response;
        if (!response.Parse(data))
            response.error_code_ = NEErrorCode::ERROR_CODE_FAILED;
        NEBoolCallback start_cb = cb.GetResponseCallback<NEBoolCallback>();
        if (start_cb != nullptr)
            start_cb(response.error_code_, response.error_msg_, response.status_);
    } 
    break;
    }
}

void NESettingsServiceIMP::OnPack(int cid, const std::string& data, uint64_t sn)
{
    switch (cid)
    {
        case SettingsCID::SettingsCID_ChangeNotify:
        {
            SettingsChangeNotify notify;
            if (settings_chg_notify_handler_ != nullptr && notify.Parse(data))
            {
                switch (notify.type_)
                {
                case NS_I_NEM_SDK::SettingChangType::SettingChangType_Audio:
                    settings_chg_notify_handler_->OnAudioSettingsChange(notify.status_);
                    break;
                case NS_I_NEM_SDK::SettingChangType::SettingChangType_Video:
                    settings_chg_notify_handler_->OnVideoSettingsChange(notify.status_);
                    break;
                case NS_I_NEM_SDK::SettingChangType::SettingChangType_Other:
                    settings_chg_notify_handler_->OnOtherSettingsChange(notify.status_);
                    break;
                default:
                    break;
                }
            }
        }
        break;
    }
    
}
NNEM_SDK_HOSTING_MODULE_END_DECLS


