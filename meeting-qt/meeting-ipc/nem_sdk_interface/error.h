/**
 * @file error.h
 * @brief 错误码头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_DEFINE_ERROR_H_
#define NEM_SDK_INTERFACE_DEFINE_ERROR_H_

#include "public_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 错误枚举
 */
enum NEErrorCode
{
    /**
     * 对应接口调用成功
     */
    ERROR_CODE_SUCCESS = 0,

    /**
     * 对应接口调用失败
     */
    ERROR_CODE_FAILED = -1,

    /**
     * SDK登录鉴权请求失败
     */
    MEETING_ERROR_FAILED_IM_LOGIN_ERROR = -2,

    /**
     * 接口调用失败，原因为无网络连接
     */
    MEETING_ERROR_NO_NETWORK = -3,

    /**
     * 创建会议失败，原因为当前已经存在一个使用相同会议ID的会议。调用方此时可以加入该会议或者等待该会议结束后重新创建
     */
    MEETING_ERROR_FAILED_ALREADY_IN_MEETING = -4,

    /**
     * 接口调用失败，原因为参数错误
     */
    MEETING_ERROR_FAILED_PARAM_ERROR = -5,

    /**
     * 创建或加入会议失败，原因为当前已经处于一个会议中
     */
    MEETING_ERROR_ALREADY_INMEETING = -6,

    /**
     * 创建或加入会议失败，原因为当前登录状态已失效
     */
    ERROR_CODE_NO_AUTH = -7,

    /**
     * 加入会议失败，原因为会议密码错误
     * @since 1.2.3
     */
    ERROR_CODE_MEETING_PASSWORD_ERROR = -8,

    /**
     * 加入会议失败，原因为主动取消加入
     * @since 1.2.3
     */
    ERROR_CODE_CANCELLED = -9,

    /**
     * 接口调用失败，原因为出现了异常
     */
    ERROR_CODE_UNEXPECTED = -100000,

    /**
     * 接口调用失败，原因为对应接口未实现
     */
    ERROR_CODE_NOT_IMPLEMENTED = -100001,

    /**
     * 接口调用失败，原因为SDK未初始化或初始化失败
     */
    ERROR_CODE_SDK_UNINITIALIZE = -100002,

	/**
     * 接口调用失败，原因为不支持该服务
     */
    ERROR_CODE_SDK_SERVICE_NOTSUPPORT = -100003,
};

NNEM_SDK_INTERFACE_END_DECLS

#endif //NEM_SDK_INTERFACE_DEFINE_ERROR_H_
