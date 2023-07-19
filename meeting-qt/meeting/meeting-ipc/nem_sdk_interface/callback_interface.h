// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * @file callback_interface.h
 * @brief 通用回调头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_CALLBACK_CALLBACK_INTERFACE_H_
#define NEM_SDK_INTERFACE_CALLBACK_CALLBACK_INTERFACE_H_

#include "build_config.h"
#include "nemeeting_sdk_interface_export.h"

#include <functional>
#include <string>
#include "error.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

template <class... TResultParam>
using NECallback = std::function<void(NEErrorCode, const std::string&, const TResultParam&...)>;

using NEEmptyCallback = NECallback<>;

NNEM_SDK_INTERFACE_END_DECLS
#endif  // NEM_SDK_INTERFACE_CALLBACK_CALLBACK_INTERFACE_H_
