/**
 * @file feedback_service.h
 * @brief 反馈服务头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_INTERFACE_FEEDBACK_SERVICE_H_
#define NEM_SDK_INTERFACE_INTERFACE_FEEDBACK_SERVICE_H_

#include "service_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 监听反馈状态变更通知
 * @see NEFeedbackService#addListener
 */
class FeedbackServiceListener : public NEObject
{
public:
    /**
     * @brief 反馈的状态信息
     * @param type 0是日志类型，2是崩溃类型
     * @param status 200是成功，其他是失败
     * @param url 上传的url地址
     * @return void
     */
    virtual void onFeedbackStatus(int type, int status, std::string url) = 0;
};

/**
 * @brief 反馈服务
 */
class NEM_SDK_INTERFACE_EXPORT NEFeedbackService : public NEService
{
public:
    using NEFeedbackCallback = NECallback<const std::string&, const int&>;
public:
    /**
     * @brief 反馈接口
     * @param type 0是日志类型，2是崩溃类型
     * @param path 文件路径
     * @param cb 回调
     * @return void
     */
    virtual void feedback(const int& type, const std::string& path, const NEFeedbackCallback& cb) = 0;

     /**
     * @brief 添加反馈监听，接收反馈状态
     * @param listener 监听对象
     * @return void
     */
    virtual void addListener(FeedbackServiceListener* listener) = 0;
};

NNEM_SDK_INTERFACE_END_DECLS
#endif // NEM_SDK_INTERFACE_INTERFACE_FEEDBACK_SERVICE_H_

