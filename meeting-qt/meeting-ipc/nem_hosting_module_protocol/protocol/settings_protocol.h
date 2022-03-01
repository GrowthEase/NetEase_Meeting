/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_PROTOCOL_SETTINGS_PROTOCOL_H_
#define NEM_HOSTING_MODULE_PROTOCOL_SETTINGS_PROTOCOL_H_

#include "nem_hosting_module_protocol/config/build_config.h"
#include "nem_hosting_module_core/protocol/protocol.h"

NNEM_SDK_HOSTING_MODULE_PROTOCOL_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

enum SettingsCID
{
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

	SettingsCID_Notify	= 100,
	SettingsCID_ChangeNotify = SettingsCID_Notify + 1,//设置变更通知
};

class ShowUIWndRequest : public NEMIPCProtocolBody
{
public:
	virtual void OnPack(Json::Value& root) const override;
	virtual void OnParse(const Json::Value& root) override;
public:
	NESettingsUIWndConfig config_;
};
using ShowUIWndResponse = NEMIPCProtocolErrorInfoBody;

class SettingsChangeNotify : public NEMIPCProtocolBody
{
public:
	virtual void OnPack(Json::Value& root) const override;
	virtual void OnParse(const Json::Value& root) override;
	SettingChangType type_;
	bool status_;
};

class SettingsBoolRequest : public NEMIPCProtocolBody
{
public:
    virtual void OnPack(Json::Value& root) const override;
    virtual void OnParse(const Json::Value& root) override;
    bool status_;
};

class SettingsBoolResponse : public NEMIPCProtocolErrorInfoBody
{
public:
    virtual void OnOtherPack(Json::Value& root) const override;
    virtual void OnOtherParse(const Json::Value& root) override;
    bool status_;
};

class SettingsIntRequest : public NEMIPCProtocolBody
{
public:
	virtual void OnPack(Json::Value& root) const override;
	virtual void OnParse(const Json::Value& root) override;
	int value_;
};

class SettingsIntResponse : public NEMIPCProtocolErrorInfoBody
{
public:
	virtual void OnOtherPack(Json::Value& root) const override;
	virtual void OnOtherParse(const Json::Value& root) override;
	int value_;
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
NNEM_SDK_HOSTING_MODULE_PROTOCOL_END_DECLS

#endif//NEM_HOSTING_MODULE_PROTOCOL_SETTINGS_PROTOCOL_H_
