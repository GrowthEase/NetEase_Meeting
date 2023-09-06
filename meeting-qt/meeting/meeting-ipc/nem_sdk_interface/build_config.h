// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * @file build_config.h
 * @brief 编译配置头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_BUILD_CONFIG_H_
#define NEM_SDK_INTERFACE_BUILD_CONFIG_H_

#define NNEM_SDK_INTERFACE_BEGIN_DECLS namespace nem_sdk_interface {
#define NNEM_SDK_INTERFACE_END_DECLS }
#define USING_NS_NNEM_SDK_INTERFACE using namespace nem_sdk_interface;

/**
 * @brief 定义命名空间
 */
#define NS_I_NEM_SDK nem_sdk_interface

#ifdef __clang__
#if __has_extension(attribute_deprecated_with_message)
#define MEETING_KIT_DEPRECATED(message) __attribute__((deprecated(message)))
#endif
#elif defined(__GNUC__)  // not clang (gcc comes later since clang emulates gcc)
#if (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 5))
#define MEETING_KIT_DEPRECATED(message) __attribute__((deprecated(message)))
#elif (__GNUC__ > 3 || (__GNUC__ == 3 && __GNUC_MINOR__ >= 1))
#define MEETING_KIT_DEPRECATED(message) __attribute__((__deprecated__))
#endif                   // GNUC version
#elif defined(_MSC_VER)  // MSVC (after clang because clang on Windows emulates
                         // MSVC)
#define MEETING_KIT_DEPRECATED(message) __declspec(deprecated(message))
#endif  // __clang__ || __GNUC__ || _MSC_VER

#if !defined(MEETING_KIT_DEPRECATED)
#define MEETING_KIT_DEPRECATED(message)
#endif  // if !defined(MEETING_KIT_DEPRECATED)

#endif  // NEM_SDK_INTERFACE_BUILD_CONFIG_H_
