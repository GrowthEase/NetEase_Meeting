/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_SETTING_SERVICE_H_
#define NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_SETTING_SERVICE_H_

#include "setting_service.h"
#include "client_prochandler_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

class NEM_SDK_INTERFACE_EXPORT NESettingsServiceProcHandler : public NEProcHandler
{
public:
    virtual bool onShowSettingUIWnd(const NESettingsUIWndConfig& config, const NESettingsService::NEShowSettingUIWndCallback& cb) = 0;
   
    virtual void onSetTurnOnMyVideoWhenJoinMeeting(bool bOn, const NEEmptyCallback& cb) = 0;
    virtual void onIsTurnOnMyVideoWhenJoinMeetingEnabled(const NESettingsService::NEBoolCallback& cb) = 0;

    virtual void onSetTurnOnMyAudioWhenJoinMeeting(bool bOn, const NEEmptyCallback& cb) = 0;
    virtual void onIsTurnOnMyAudioWhenJoinMeetingEnabled(const NESettingsService::NEBoolCallback& cb) = 0;

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
};

class NEM_SDK_INTERFACE_EXPORT NESettingsServiceIPCClient :
    public NEServiceIPCClient< NESettingsServiceProcHandler, NESettingsService>
{
public:
    virtual void notifySettingsChange(SettingChangType type, bool status) = 0;
};

NNEM_SDK_INTERFACE_END_DECLS
#endif // NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_SETTING_SERVICE_H_
