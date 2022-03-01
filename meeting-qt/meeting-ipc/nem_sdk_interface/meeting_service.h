/**
 * @file meeting_service.h
 * @brief 会议服务头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_INTERFACE_METTING_SERVICE_H_
#define NEM_SDK_INTERFACE_INTERFACE_METTING_SERVICE_H_

#include "service_define.h"
#include "metting.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 监听会议状态变更通知
 */
class NEMeetingStatusListener : public NEObject
{
public:
   /**
    * @brief 会议的状态信息
    * @param status 会议状态，参考NEMeetingStatus
    * @param code 错误码
    * @return void
    */
    virtual void onMeetingStatusChanged(int status, int code) = 0;
};

/**
 * @brief 监听会议中按钮点击状态变更通知
 */
class NEMeetingOnInjectedMenuItemClickListener : public NEObject
{
public:
    /**
     * @brief 多个状态的菜单的返回回调
     * @param itemId 菜单项itemId
     * @param itemGuid 菜单项itemGuid
     * @param itemCheckedIndex 菜单项新的itemCheckedIndex，如果不更改，则赋值回调中的状态
     * @return void
     */
    using NEInjectedMenuItemClickCallback = std::function<void(int itemId, const std::string& itemGuid, int itemCheckedIndex)>;

    /**
     * @brief 菜单点击后发出通知，仅在单个状态的菜单才有
     * @param meeting_menu_item 菜单项内容
     * @return void
     */
    virtual void onInjectedMenuItemClick(const NEMeetingMenuItem& meeting_menu_item) = 0;

    /**
     * @brief 菜单点击时发出通知，等待返回值，以确定状态是否变更，仅在多个状态的菜单才有
     * @param meeting_menu_item 菜单项内容
     * @param cb 回调，菜单项状态
     * @return void
     */
    virtual void onInjectedMenuItemClickEx(const NEMeetingMenuItem& meeting_menu_item, const NEInjectedMenuItemClickCallback& cb) = 0;
};

/**
 * @brief 会议服务
 */
class NEM_SDK_INTERFACE_EXPORT NEMeetingService : public NEService
{
public:
    using NEStartMeetingCallback = NEEmptyCallback;
    using NEJoinMeetingCallback = NEEmptyCallback;
    using NELeaveMeetingCallback = NEEmptyCallback;
    using NEGetMeetingInfoCallback = NECallback<NEMeetingInfo>;
    using NEGetPresetMenuItemsCallback = NECallback<std::vector<NEMeetingMenuItem>>;

public:
    /**
     * @brief 开始会议
     * @param param 开始会议参数
     * @param opts 开始会议选项
     * @param cb 回调
     * @return void
     */
    virtual void startMeeting(const NEStartMeetingParams& param, const NEStartMeetingOptions& opts, const NEStartMeetingCallback& cb) = 0;

    /**
     * @brief 加入会议
     * @param param 加入会议参数
     * @param opts 加入会议选项
     * @param cb 回调
     * @return void
     */
    virtual void joinMeeting(const NEJoinMeetingParams& param, const NEJoinMeetingOptions& opts, const NEJoinMeetingCallback& cb) = 0;

    /**
     * @brief 离开会议
     * @param finish 是否要结束会议，true结束，false不结束
     * @attention 目前只支持false
     * @param cb 回调
     * @return void
     */
    virtual void leaveMeeting(bool finish, const NELeaveMeetingCallback& cb) = 0;

    /**
     * @brief 获取当前会议信息
     * @param cb 回调
     * @return void
     */
    virtual void getCurrentMeetingInfo(const NEGetMeetingInfoCallback& cb) = 0;

    /**
     * @brief 获取会议状态
     * @return NEMeetingStatus 会议状态
     */
    virtual NEMeetingStatus getMeetingStatus() = 0;

    /**
     * @brief 添加会议监听，接收会议状态
     * @param listener 监听对象
     * @return void
     */
    virtual void addMeetingStatusListener(NEMeetingStatusListener* listener) = 0;

    /**
     * @brief 添加会议按钮点击事件监听，接收点击事件
     * @param listener 监听对象
     * @return void
     */
    virtual void setOnInjectedMenuItemClickListener(NEMeetingOnInjectedMenuItemClickListener* listener) = 0;

    /**
     * @brief 获取内置菜单
     * @param menuItemsId 菜单id，如果vector为空则返回所有
     * @param cb 回调
     * @return void
     */
    virtual void getBuiltinMenuItems(const std::vector<int>& menuItemsId, const NEGetPresetMenuItemsCallback& cb) = 0;

    /**
     * @brief 订阅会议内单个音频流
     * @param accountId 账号accountId
     * @param subscribe true订阅 false 取消订阅
     * @param cb 回调
     * @return void
     */
    virtual void subscribeRemoteAudioStream(const std::string& accountId, bool subscribe, const NEEmptyCallback& cb) = 0;

    /**
     * @brief 订阅会议内多个音频流
     * @param accountIdList 账号accountId列表
     * @param subscribe true订阅 false 取消订阅
     * @param cb 回调
     * @return void
     */
    virtual void subscribeRemoteAudioStreams(const std::vector<std::string>& accountIdList, bool subscribe, const NEEmptyCallback& cb) = 0;

    /**
     * @brief 订阅会议内全部音频流
     * @param subscribe true订阅 false 取消订阅
     * @param cb 回调
     * @return void
     */
    virtual void subscribeAllRemoteAudioStreams(bool subscribe, const NEEmptyCallback& cb) = 0;
};

NNEM_SDK_INTERFACE_END_DECLS
#endif // NEM_SDK_INTERFACE_INTERFACE_METTING_SERVICE_H_

