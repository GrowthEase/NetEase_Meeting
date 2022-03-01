/**
 * @file service_define.h
 * @brief 公共服务定义头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_DEFINE_SERVICE_H_
#define NEM_SDK_INTERFACE_DEFINE_SERVICE_H_

#include "public_define.h"
#include "callback_interface.h"
NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 公共服务
 */
class NEM_SDK_INTERFACE_EXPORT NEService : public NEObject
{
public:
    /**
     * @brief 构造函数
     */
    NEService() {}

    /**
     * @brief 析构函数
     */
    virtual ~NEService() {};
};

NNEM_SDK_INTERFACE_END_DECLS

#endif//NEM_SDK_INTERFACE_DEFINE_SERVICE_H_
