/**
 * @file setting_service.h
 * @brief 配置服务头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_INTERFACE_SETTING_SERVICE_H_
#define NEM_SDK_INTERFACE_INTERFACE_SETTING_SERVICE_H_

#include "service_define.h"
#include "controller_define.h"
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

/**
 * @brief 配置服务
 */
class NEM_SDK_INTERFACE_EXPORT NESettingsService : public NEService
{
public:
    using NEShowSettingUIWndCallback = NEEmptyCallback;
    using NEBoolCallback = NECallback<bool>;
    using NEIntCallback = NECallback<int>;
    using NEHistoryMeetingCallback = NECallback<std::list<NEHistoryMeetingItem>>;
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
class NEM_SDK_INTERFACE_EXPORT NEVideoController : public NEController
{
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
};

/**
 * @brief 音频控制器
 */
class NEM_SDK_INTERFACE_EXPORT NEAudioController : public NEController
{
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
};

/**
 * @brief 其他控制器
 */
class NEM_SDK_INTERFACE_EXPORT NEOtherController : public NEController
{
public:
    /**
     * @brief 开启或关闭显示会议时长功能
     * @param show true-开启，false-关闭
     * @param cb 回调
     * @return void
     */
    //virtual void enableShowMyMeetingElapseTime(bool show, const NEEmptyCallback& cb) const = 0;

    /**
     * @brief 查询显示会议时长功能开启状态
     * @param cb 回调
     * @return void
     */
    //virtual void isShowMyMeetingElapseTimeEnabled(const NESettingsService::NEBoolCallback& cb) const = 0;
};

/**
 * @brief 配置状态监听器
 */
class NESettingsChangeNotifyHandler : NEObject
{
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
};

/**
 * @brief 美颜控制器
 */
class NEM_SDK_INTERFACE_EXPORT NEBeautyFaceController : public NEController
{
public:
   ///**
   // * @brief 美颜使能接口，控制美颜服务开关
   // * @param enable true-打开，false-关闭
   // * @param cb 回调
   // * @return bool
   // * - true： 成功
   // * - false：失败
   // */
   // virtual bool enableBeautyFace(bool enable, const NESettingsService::NEBoolCallback& cb) = 0;

    /**
     * @brief 查询美颜开关状态，关闭在隐藏会中美颜按钮
     * @param cb 回调
     * @return bool
     * - true： 成功
     * - false：失败
     */
    virtual bool isBeautyFaceEnabled(const NESettingsService::NEBoolCallback& cb) = 0;


    /**
     * @brief 获取当前美颜参数
     * @param cb 回调，关闭返回0
     * @return
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
class NEM_SDK_INTERFACE_EXPORT NELiveController : public NEController
{
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
class NEM_SDK_INTERFACE_EXPORT NEWhiteboardController : public NEController
{

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
class NEM_SDK_INTERFACE_EXPORT NERecordController : public NEController
{

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
NNEM_SDK_INTERFACE_END_DECLS
#endif // NEM_SDK_INTERFACE_INTERFACE_SETTING_SERVICE_H_
