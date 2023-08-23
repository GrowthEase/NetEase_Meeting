// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * @file public_define.h
 * @brief 公共对象定义头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_DEFINE_PUBLIC_H_
#define NEM_SDK_INTERFACE_DEFINE_PUBLIC_H_

#include "build_config.h"
#include "nemeeting_sdk_interface_export.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 公共对象
 */
class NEM_SDK_INTERFACE_EXPORT NEObject {
public:
    /**
     * @brief 构造函数
     */
    NEObject() = default;

    /**
     * @brief 析构函数
     */
    virtual ~NEObject() = default;
};

NNEM_SDK_INTERFACE_END_DECLS

#endif  // NEM_SDK_INTERFACE_DEFINE_PUBLIC_H_
