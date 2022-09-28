// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * @file meeting_sdk.h
 * @brief SDK头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_INTERFACE_MEETING_SDK_H_
#define NEM_SDK_INTERFACE_INTERFACE_MEETING_SDK_H_

#include "callback_interface.h"
#include "exception_define.h"
#include "sdk_init_config.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

class NEAuthService;
class NEMeetingService;
class NEAccountService;
class NESettingsService;
class NEFeedbackService;
class NEPreMeetingService;

/**
 * @brief SDK单例
 */
class NEM_SDK_INTERFACE_EXPORT NEMeetingKit : public NEObject {
public:
    using NEInitializeCallback = NEEmptyCallback;
    using NEUnInitializeCallback = NEEmptyCallback;
    using NEQueryKitVersionCallback = NECallback<std::string>;
    using NEActiveWindowCallback = NEEmptyCallback;
    using NEBoolCallback = NECallback<bool>;
    using NEExceptionHandler = std::function<void(const NEException&)>;

public:
    ////////////////////////////////////////////////////////
    /** \addtogroup getNEMeetingKit
     @{
     */
    ////////////////////////////////////////////////////////

    /**
     * @brief 获取SDK单例
     * @return NEMeetingKit* 单例对象指针
     */
    static NEMeetingKit* getInstance();

    ////////////////////////////////////////////////////////
    /** @} */
    ////////////////////////////////////////////////////////

    /**
     * @brief 初始化
     * @param config 初始化配置
     * @param cb 回调，NEInitializeCallback
     * @return void
     */
    virtual void initialize(const NEMeetingKitConfig& config, const NEInitializeCallback& cb) = 0;

    /**
     * @brief 反初始化
     * @param cb 回调
     * @return void
     */
    virtual void unInitialize(const NEUnInitializeCallback& cb) = 0;

    /**
     * @brief 获取是否初始化的状态
     * @return bool
     *  - true: 已初始化
     *  - false: 未初始化
     */
    virtual bool isInitialized() = 0;

    /**
     * @brief 获取SDK版本信息
     * @param cb 回调
     * @return void
     */
    virtual void queryKitVersion(const NEQueryKitVersionCallback& cb) = 0;

    /**
     * @brief 激活主窗口
     * @param cb 回调
     * @return void
     */
    virtual void activeWindow(const NEActiveWindowCallback& cb) = 0;

    /**
     * @brief 设置SDK程序是否为软件渲染
     * @note 只在Windows下有效，需要在初始化前调用
     * @param bSoftware 是否为软件渲染，true软件渲染，false默认方式
     * @param cb 回调
     * @return void
     */
    virtual void setSoftwareRender(bool bSoftware, const NEEmptyCallback& cb) = 0;

    /**
     * @brief 获取SDK程序是否为软件渲染
     * @note 只在Windows下有效
     * @param cb 回调
     * @return void
     */
    virtual void isSoftwareRender(const NEBoolCallback& cb) = 0;

    /**
     * @brief 设置异常回调
     * @param handler 回调
     * @return void
     */
    virtual void setExceptionHandler(const NEExceptionHandler& handler) = 0;

    /**
     * @brief 设置日志回调
     * @param cb 回调
     * @note level 日志级别
     * @attention 只有少量的组件接口层关键日志
     * @return void
     */
    virtual void setLogHandler(const std::function<void(int level, const std::string& log)>& cb) = 0;

    /**
     * @brief 获取登录服务
     * @return NEAuthService* 登录服务对象指针
     */
    virtual NEAuthService* getAuthService() = 0;

    /**
     * @brief 获取会议服务
     * @return NEMeetingService* 会议服务对象指针
     */
    virtual NEMeetingService* getMeetingService() = 0;

    /**
     * @brief 获取配置服务
     * @return NESettingsService* 配置服务对象指针
     */
    virtual NESettingsService* getSettingsService() = 0;

    /**
     * @brief 获取账户服务
     * @return NEAccountService* 账户服务对象指针
     */
    virtual NEAccountService* getAccountService() = 0;

    /**
     * @brief 获取反馈服务
     * @return NEFeedbackService* 反馈服务对象指针
     */
    virtual NEFeedbackService* getFeedbackService() = 0;

    /**
     * @brief 获取预约会议服务
     * @return NEPreMeetingService* 预约会服务对象指针
     */
    virtual NEPreMeetingService* getPremeetingService() = 0;
};
NNEM_SDK_INTERFACE_END_DECLS
#endif  // NEM_SDK_INTERFACE_INTERFACE_MEETING_SDK_H_
