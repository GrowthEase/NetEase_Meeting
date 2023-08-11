// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * @file setting_service.h
 * @brief 配置服务头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_INTERFACE_SETTING_SERVICE_H_
#define NEM_SDK_INTERFACE_INTERFACE_SETTING_SERVICE_H_

#include "controller_define.h"
#include "meeting.h"
#include "service_define.h"
#include "settings.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

class NEVideoController;
class NEAudioController;
class NEOtherController;
class NEBeautyFaceController;
class NELiveController;
class NESettingsChangeNotifyHandler;
class NEWhiteboardController;
class NERecordController;
class NEVirtualBackgroundController;

/**
 * @brief 配置服务
 */
class NEM_SDK_INTERFACE_EXPORT NESettingsService : public NEService {
public:
    using NEShowSettingUIWndCallback = NEEmptyCallback;
    using NEBoolCallback = NECallback<bool>;
    using NEIntCallback = NECallback<int>;
    using NEHistoryMeetingCallback = NECallback<std::list<NEHistoryMeetingItem>>;
    using NEAudioQualityCallback = NECallback<AudioQuality>;
    using NERemoteVideoResolutionCallback = NECallback<RemoteVideoResolution>;
    using NELocalVideoResolutionCallback = NECallback<LocalVideoResolution>;
    using AudioDeviceAutoSelectTypeCallback = NECallback<AudioDeviceAutoSelectType>;
    using NESharingSidebarViewModeCallback = NECallback<SharingSidebarViewMode>;
    using NEVirtualBackgroundCallback = NECallback<std::vector<NEMeetingVirtualBackground>>;

public:
    /**
     * @brief 获取视频控制器
     * @return NEVideoController* 视频控制器对象
     */
    virtual NEVideoController* GetVideoController() const = 0;

    /**
     * @brief 获取音频控制器
     * @return NEAudioController* 音频控制器对象
     */
    virtual NEAudioController* GetAudioController() const = 0;

    /**
     * @brief 获取其他控制器
     * @return NEOtherController*其他控制器对象
     */
    virtual NEOtherController* GetOtherController() const = 0;

    /**
     * @brief 获取美颜控制器
     * @return NEBeautyFaceController* 美颜控制器对象
     */
    virtual NEBeautyFaceController* GetBeautyFaceController() const = 0;

    /**
     * @brief 获取直播控制器
     * @return NELiveController* 直播控制器对象
     */
    virtual NELiveController* GetLiveController() const = 0;

    /**
     * @brief 获取白板控制器
     * @return NEWhiteboardController* 白板控制器对象
     */
    virtual NEWhiteboardController* GetWhiteboardController() const = 0;

    /**
     * @brief 获取录制控制器
     * @return NERecordController* 录制控制器对象
     */
    virtual NERecordController* GetRecordController() const = 0;

    /**
     * @brief 获取虚拟背景控制器
     * @return NEVirtualBackgroundController* 虚拟背景控制器
     */
    virtual NEVirtualBackgroundController* GetVirtualBackgroundController() const = 0;

    /**
     * @brief 显示配置窗口
     * @param config 配置参数
     * @param cb 回调
     * @return void
     */
    virtual void showSettingUIWnd(const NESettingsUIWndConfig& config, const NEShowSettingUIWndCallback& cb) = 0;

    /**
     * @brief 设置配置状态监听器, 用于接收状态变更通知
     * @param handler 监听器
     * @return void
     */
    virtual void setNESettingsChangeNotifyHandler(NESettingsChangeNotifyHandler* handler) = 0;

    /**
     * @brief 获取历史会议信息，当前仅会返回最近一次的会议记录，不支持漫游
     * @param callback 回调
     * @return void
     */
    virtual void getHistoryMeetingItem(const NEHistoryMeetingCallback& callback) = 0;
};

/**
 * @brief 视频控制器
 */
class NEM_SDK_INTERFACE_EXPORT NEVideoController : public NEController {
public:
    /**
     * @brief 设置入会时本地视频开关
     * @param bOn true-入会时打开视频，false-入会时关闭视频
     * @param cb 回调
     * @return void
     */
    virtual void setTurnOnMyVideoWhenJoinMeeting(bool bOn, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询入会时的本地视频开关设置状态
     * @param cb 回调
     * @return void
     */
    virtual void isTurnOnMyVideoWhenJoinMeetingEnabled(const NESettingsService::NEBoolCallback& cb) const = 0;

    /**
     * @brief 设置远端视频在本端显示的分辨率
     * @param enumRemoteVideoResolution 分辨率 {@see RemoteVideoResolution}
     * @param cb 回调
     * @return void
     */
    virtual void setRemoteVideoResolution(RemoteVideoResolution enumRemoteVideoResolution, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询远端视频在本端显示的分辨率
     * @param cb 回调
     * @return void
     */
    virtual void getRemoteVideoResolution(const NESettingsService::NERemoteVideoResolutionCallback& cb) const = 0;

    /**
     * @brief 设置本地视频的分辨率
     * @param enumLocalVideoResolution 分辨率 {@see LocalVideoResolution}
     * @param cb 回调
     * @return void
     */
    virtual void setMyVideoResolution(LocalVideoResolution enumLocalVideoResolution, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询本地视频的分辨率
     * @param cb 回调
     * @return void
     */
    virtual void getMyVideoResolution(const NESettingsService::NELocalVideoResolutionCallback& cb) const = 0;

    /**
     * @brief 设置本地视频的帧率
     * @param enumLocalVideoFramerate 分辨率 {@see LocalVideoFramerate}
     * @param cb 回调
     * @return void
     */
    virtual void setMyVideoFramerate(LocalVideoFramerate enumLocalVideoFramerate, const NEEmptyCallback& cb) const = 0;
};

/**
 * @brief 音频控制器
 */
class NEM_SDK_INTERFACE_EXPORT NEAudioController : public NEController {
public:
    /**
     * @brief 设置入会时本地音频开关
     * @param bOn true-入会时打开音频，false-入会时关闭音频
     * @param cb 回调
     * @return void
     */
    virtual void setTurnOnMyAudioWhenJoinMeeting(bool bOn, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询入会时的本地音频开关设置状态
     * @param cb 回调
     * @return void
     */
    virtual void isTurnOnMyAudioWhenJoinMeetingEnabled(const NESettingsService::NEBoolCallback& cb) const = 0;

    /**
     * @brief 设置会中本地音频AI降噪
     * @param bOn true-打开音频AI降噪，false-关闭音频AI降噪
     * @note 通话音质在通话模式时有效，默认为开启
     * @param cb 回调
     * @return void
     */
    virtual void setTurnOnMyAudioAINSWhenInMeeting(bool bOn, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询会中本地音频AI降噪设置状态
     * @param cb 回调
     * @return void
     */
    virtual void isTurnOnMyAudioAINSWhenInMeetingEnabled(const NESettingsService::NEBoolCallback& cb) const = 0;

    /**
     * @brief 设置会中麦克风音量自动调节
     * @param bOn true-打开麦克风音量自动调节，false-关闭麦克风音量自动调节
     * @param cb 回调
     * @return void
     */
    virtual void setMyAudioVolumeAutoAdjust(bool bOn, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询会中麦克风音量自动调节
     * @param cb 回调
     * @return void
     */
    virtual void isMyAudioVolumeAutoAdjust(const NESettingsService::NEBoolCallback& cb) const = 0;

    /**
     * @brief 设置通话音质
     * @param enumAudioQuality 通话音质 {@see AudioQuality}
     * @note 会前可设置，默认为通话模式，如果设置为音乐模式，则会自动关闭AI降噪开关
     * @param cb 回调
     * @return void
     */
    virtual void setMyAudioQuality(AudioQuality enumAudioQuality, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询通话音质
     * @param cb 回调
     * @return void
     */
    virtual void getMyAudioQuality(const NESettingsService::NEAudioQualityCallback& cb) const = 0;

    /**
     * @brief 设置回声消除的开关
     * @param bOn true-打开回声消除，false-关闭回声消除
     * @note 通话音质为音乐模式时有效，默认为开
     * @param cb 回调
     * @return void
     */
    virtual void setMyAudioEchoCancellation(bool bOn, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询回声消除
     * @param cb 回调
     * @return void
     */
    virtual void isMyAudioEchoCancellation(const NESettingsService::NEBoolCallback& cb) const = 0;

    /**
     * @brief 设置启用立体音
     * @param bOn true-打开立体音，false-关闭立体音
     * @note 会前可设置，通话音质在音乐模式时有效，默认为关闭
     * @param cb 回调
     * @return void
     */
    virtual void setMyAudioEnableStereo(bool bOn, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询启用立体音
     * @param cb 回调
     * @return void
     */
    virtual void isMyAudioEnableStereo(const NESettingsService::NEBoolCallback& cb) const = 0;

    /**
     * @brief 设置音频设备自动选择策略
     * @param enumAudioDeviceAutoSelectType 策略 {@see AudioDeviceAutoSelectType}
     * @param cb 回调
     * @return void
     */
    virtual void setMyAudioDeviceAutoSelectType(AudioDeviceAutoSelectType enumAudioDeviceAutoSelectType, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询音频设备自动选择策略
     * @param cb 回调
     * @return void
     */
    virtual void isMyAudioDeviceAutoSelectType(const NESettingsService::AudioDeviceAutoSelectTypeCallback& cb) const = 0;

    /**
     * @brief 设置音频设备是否默认选择上次使用的设备
     * @note 如果是，则会覆盖 \ref setMyAudioDeviceAutoSelectType "setMyAudioDeviceAutoSelectType" 的设置
     * @param bOn true 上次的设备，false 不是上次的设备
     * @param cb 回调
     * @return void
     */
    virtual void setMyAudioDeviceUseLastSelected(bool bOn, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询音频设备是否默认选择上次使用的设备
     * @param cb 回调
     * @return void
     */
    virtual void isMyAudioDeviceUseLastSelected(const NESettingsService::NEBoolCallback& cb) const = 0;
};

/**
 * @brief 其他控制器
 */
class NEM_SDK_INTERFACE_EXPORT NEOtherController : public NEController {
public:
    ///**
    // * @brief 开启或关闭显示会议时长功能
    // * @param show true-开启，false-关闭
    // * @param cb 回调
    // * @return void
    // */
    // virtual void enableShowMyMeetingElapseTime(bool show, const NEEmptyCallback& cb) const = 0;

    ///**
    // * @brief 查询显示会议时长功能开启状态
    // * @param cb 回调
    // * @return void
    // */
    // virtual void isShowMyMeetingElapseTimeEnabled(const NESettingsService::NEBoolCallback& cb) const = 0;

    /**
     * @brief 开启或关闭长按空格解除静音功能
     * @param show true-开启，false-关闭
     * @param cb 回调
     * @return void
     */
    virtual void enableUnmuteBySpace(bool show, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询长按空格解除静音功能开启状态
     * @param cb 回调
     * @return void
     */
    virtual void isUnmuteBySpaceEnabled(const NESettingsService::NEBoolCallback& cb) const = 0;

    /**
     * @brief 设置屏幕共享侧边栏的展示模式
     * @param viewMode 展示模式 @see SharingSidebarViewMode
     */
    virtual void setSharingSidebarViewMode(SharingSidebarViewMode viewMode, const NEEmptyCallback& cb) = 0;

    /**
     * @brief 获取屏幕共享侧边栏的展示模式
     * @param cb
     */
    virtual void getSharingSidebarViewMode(const NESettingsService::NESharingSidebarViewModeCallback& cb) const = 0;
};

/**
 * @brief 配置状态监听器
 */
class NESettingsChangeNotifyHandler : NEObject {
public:
    /**
     * @brief 音频状态变更
     * @param status true开启，false关闭
     * @return void
     */
    virtual void OnAudioSettingsChange(bool status) = 0;

    /**
     * @brief 视频状态变更
     * @param status true开启，false关闭
     * @return void
     */
    virtual void OnVideoSettingsChange(bool status) = 0;

    /**
     * @brief 其他状态变更
     * @param status true开启，false关闭
     * @return void
     */
    virtual void OnOtherSettingsChange(bool status) = 0;

    /**
     * @brief 音频AI降噪状态变更
     * @param status true开启，false关闭
     * @return void
     */
    virtual void OnAudioAINSSettingsChange(bool status) = 0;

    /**
     * @brief 麦克风音量自动调节状态变更
     * @param status true开启，false关闭
     * @return void
     */
    virtual void OnAudioVolumeAutoAdjustSettingsChange(bool status) = 0;

    /**
     * @brief 通话音质变更
     * @param enumAudioQuality 通话音质 {@see AudioQuality}
     * @return void
     */
    virtual void OnAudioQualitySettingsChange(AudioQuality enumAudioQuality) = 0;

    /**
     * @brief 回音消除变更
     * @param status true开启，false关闭
     * @return void
     */
    virtual void OnAudioEchoCancellationSettingsChange(bool status) = 0;

    /**
     * @brief 启用立体音变更
     * @param status true开启，false关闭
     * @return void
     */
    virtual void OnAudioEnableStereoSettingsChange(bool status) = 0;

    /**
     * @brief 远端视频在本端显示的分辨率变更
     * @param enumRemoteVideoResolution 分辨率 {@see RemoteVideoResolution}
     * @return void
     */
    virtual void OnRemoteVideoResolutionSettingsChange(RemoteVideoResolution enumRemoteVideoResolution) = 0;

    /**
     * @brief 本地视频的分辨率变更
     * @param enumLocalVideoResolution 分辨率 {@see LocalVideoResolution}
     * @return void
     */
    virtual void OnMyVideoResolutionSettingsChange(LocalVideoResolution enumLocalVideoResolution) = 0;
};

/**
 * @brief 美颜控制器
 */
class NEM_SDK_INTERFACE_EXPORT NEBeautyFaceController : public NEController {
public:
    /**
     * @brief 美颜使能接口，控制美颜服务开关
     * @note 状态为打开时，美颜设置入口会显示，状态为关闭时，美颜设置入口会隐藏
     * @param enable true 打开，false 关闭
     * @param cb 回调
     * @return bool
     * - true： 成功
     * - false：失败
     */
    virtual bool enableBeautyFace(bool enable, const NESettingsService::NEBoolCallback& cb) = 0;

    /**
     * @brief 查询美颜开关状态
     * @param cb 回调
     * @return bool
     * - true： 成功
     * - false：失败
     */
    virtual bool isBeautyFaceEnabled(const NESettingsService::NEBoolCallback& cb) = 0;

    /**
     * @brief 获取当前美颜参数
     * @param cb 回调，关闭返回0
     * @return bool
     * - true： 成功
     * - false：失败
     */
    virtual bool getBeautyFaceValue(const NESettingsService::NEIntCallback& cb) = 0;

    /**
     * @brief 设置美颜参数
     * @param value 传入美颜等级，参数规则为[0,10]整数
     * @param cb 回调
     * @return bool
     * - true： 成功
     * - false：失败
     */
    virtual bool setBeautyFaceValue(int value, const NESettingsService::NEBoolCallback& cb) = 0;
};

/**
 * @brief 直播控制器
 */
class NEM_SDK_INTERFACE_EXPORT NELiveController : public NEController {
public:
    /**
     * @brief 查询直播开关状态
     * @param cb 回调
     * @return
     * - true： 成功
     * - false：失败
     */
    virtual bool isLiveEnabled(const NESettingsService::NEBoolCallback& cb) = 0;
};

/**
 * @brief 白板控制器
 */
class NEM_SDK_INTERFACE_EXPORT NEWhiteboardController : public NEController {
public:
    /**
     * @brief 查询白板开关状态
     * @param cb 回调
     * @return
     * - true： 成功
     * - false：失败
     */
    virtual bool isWhiteboardEnabled(const NESettingsService::NEBoolCallback& cb) = 0;
};

/**
 * @brief 录制控制器
 */
class NEM_SDK_INTERFACE_EXPORT NERecordController : public NEController {
public:
    /**
     * @brief 查询云端录制开关状态
     * @param cb 回调
     * @return
     * - true： 成功
     * - false：失败
     */
    virtual bool isCloudRecordEnabled(const NESettingsService::NEBoolCallback& cb) = 0;
};

/**
 * @brief 虚拟背景控制器
 */
class NEM_SDK_INTERFACE_EXPORT NEVirtualBackgroundController : public NEController {
public:
    /**
     * @brief 虚拟背景是否显示
     * @note 需要在设置页面显示前调用
     * @param enable true-显示，false-隐藏
     * @param cb 回调
     * @return bool
     * - true： 成功
     * - false：失败
     */
    virtual bool enableVirtualBackground(bool enable, const NEEmptyCallback& cb) = 0;

    /**
     * @brief 查询虚拟背景显示状态
     * @param cb 回调
     * @return bool
     * - true： 成功
     * - false：失败
     */
    virtual bool isVirtualBackgroundEnabled(const NESettingsService::NEBoolCallback& cb) = 0;

    /**
     * @brief 获取内置虚拟背景列表
     * @param cb 回调
     * @return
     * - true： 成功
     * - false：失败
     */
    virtual bool getBuiltinVirtualBackgrounds(const NESettingsService::NEVirtualBackgroundCallback& cb) = 0;

    /**
     * @brief 设置内置虚拟背景列表
     * @note 需要在设置页面显示前调用
     * @param virtualBackgrounds 虚拟背景列表
     * @param cb 回调
     * @return bool
     * - true： 成功
     * - false：失败
     */
    virtual bool setBuiltinVirtualBackgrounds(const std::vector<NEMeetingVirtualBackground>& virtualBackgrounds, const NEEmptyCallback& cb) = 0;
};

NNEM_SDK_INTERFACE_END_DECLS
#endif  // NEM_SDK_INTERFACE_INTERFACE_SETTING_SERVICE_H_
