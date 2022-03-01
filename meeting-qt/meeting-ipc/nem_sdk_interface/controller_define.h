/**
 * @file controller_define.h
 * @brief 通用控制接口头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_DEFINE_CONTROLLER_H_
#define NEM_SDK_INTERFACE_DEFINE_CONTROLLER_H_

#include "public_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 通用控制接口基类
 */
class NEM_SDK_INTERFACE_EXPORT NEController : public virtual NEObject
{
public:
    /**
     * @brief 构造函数
     */
    NEController() {}

    /**
     * @brief 析构函数
     */
    virtual ~NEController() {};
};

NNEM_SDK_INTERFACE_END_DECLS

#endif//NEM_SDK_INTERFACE_DEFINE_CONTROLLER_H_