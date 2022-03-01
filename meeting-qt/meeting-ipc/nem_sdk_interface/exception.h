/**
 * @file exception.h
 * @brief 异常码头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_DEFINE_EXCEPTION_H_
#define NEM_SDK_INTERFACE_DEFINE_EXCEPTION_H_

#include "public_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 异常码
 */
enum NEExceptionCode
{
    kBegin = 0,
    kUISDKDisconnect,   /**< UI SDK 断开连接 */
    kAppDisconnect,     /**< 应用层断开连接 */
    kUnknown,           /**< 未知错误，或者不方便告诉你 */
    kEnd = kUnknown
};

NNEM_SDK_INTERFACE_END_DECLS

#endif //NEM_SDK_INTERFACE_DEFINE_EXCEPTION_H_
