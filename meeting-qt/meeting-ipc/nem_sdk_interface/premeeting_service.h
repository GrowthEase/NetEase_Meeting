/**
 * @file premeeting_service.h
 * @brief 预约会议头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_INTERFACE_PREMEETING_SERVICE_H_
#define NEM_SDK_INTERFACE_INTERFACE_PREMEETING_SERVICE_H_

#include "service_define.h"
#include <list>

NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 监听预约会议状态变更通知
 */
class NEScheduleMeetingStatusListener : public NEObject
{
public:
    /**
     * @brief 监听预约会议状态变更通知
     * @param uniqueMeetingId 会议的唯一Id
     * @param meetingStatus 会与状态 参考{@link NEMeetingItemStatus}
     */
    virtual void onScheduleMeetingStatusChanged(uint64_t uniqueMeetingId, const int& meetingStatus) = 0;
};

/**
 * @brief 预约会议服务
 */
class NEM_SDK_INTERFACE_EXPORT NEPreMeetingService : public NEService
{
public:
    using NEScheduleMeetingItemCallback = NECallback<NEMeetingItem>;
    using NEOperateScheduleMeetingCallback = NEEmptyCallback;
    using NEGetMeetingListCallback = NECallback<std::list<NEMeetingItem>&>;
public:
    /**
     * @brief 预约会议
     * @return NEMeetingItem
     */
    virtual NEMeetingItem createScheduleMeetingItem() = 0;

    /**
     * @brief 预约会议
     * @param item 会议条目
     * @param callback 回调
     * @return void
     */
    virtual void scheduleMeeting(const NEMeetingItem& item, const NEScheduleMeetingItemCallback& callback) = 0;

    /**
     * @brief 取消已预约的会议
     * @param meetingUniqueId 会议唯一Id
     * @param callback 回调
     * @return void
     */
    virtual void cancelMeeting(const int64_t &meetingUniqueId, const NEOperateScheduleMeetingCallback& callback) = 0;

    /**
     * @brief 编辑会议
     * @param item 会议条目
     * @param callback 回调
     * @return void
     */
    virtual void editMeeting(const NEMeetingItem& item, const NEOperateScheduleMeetingCallback& callback) = 0;

    /**
     * @brief 查询预约会议信息
     * @param meetingUniqueId 会议唯一Id
     * @param callback 回调
     * @return void
     */
    virtual void getMeetingItemById(const int64_t &meetingUniqueId, const NEScheduleMeetingItemCallback& callback) = 0;

    /**
     * @brief 查询特定状态下的会议列表，目前仅仅支持查询待开始、进行中及已结束，后续将支持已取消和已回收状态。
     * @param status 会议状态 参考{@link NEMeetingItemStatus}
     * @param callback 回调
     * @return void
     */
    virtual void getMeetingList(std::list<NEMeetingItemStatus> status,const NEGetMeetingListCallback& callback) = 0;

    /**
     * @brief 注册预约会议状态变更监听器
     * @param listener 监听器
     * @return void
     */
    virtual void registerScheduleMeetingStatusListener(NEScheduleMeetingStatusListener* listener) = 0;

    /**
     * @brief 反注册预约会议状态变更监听器
     * @param listener 监听器
     * @return void
     */
    virtual void unRegisterScheduleMeetingStatusListener(NEScheduleMeetingStatusListener* listener) = 0;
};

NNEM_SDK_INTERFACE_END_DECLS
#endif // NEM_SDK_INTERFACE_INTERFACE_PREMEETING_SERVICE_H_

