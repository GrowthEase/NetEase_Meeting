/**
 * @file nemeeting_sdk_interface_export.h
 * @brief 库导入导出定义头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_EXPORT_H_
#define NEM_SDK_INTERFACE_EXPORT_H_

#if defined(NEM_SDK_INTERFACE_COMPONENT_BUILD)
    #if defined(WIN32)
        #if defined(NEM_SDK_INTERFACE_IMPLEMENTATION)
        #define NEM_SDK_INTERFACE_EXPORT __declspec(dllexport)
        #define NEM_SDK_INTERFACE_EXPORT_PRIVATE __declspec(dllexport)
        #else
        #define NEM_SDK_INTERFACE_EXPORT __declspec(dllimport)
        #define NEM_SDK_INTERFACE_EXPORT_PRIVATE __declspec(dllimport)
        #endif  // defined(NEM_SDK_INTERFACE_IMPLEMENTATION)
    #else  // defined(WIN32)
        #if defined(NEM_SDK_INTERFACE_IMPLEMENTATION)
            #define NEM_SDK_INTERFACE_EXPORT __attribute__((visibility("default")))
            #define NEM_SDK_INTERFACE_EXPORT_PRIVATE __attribute__((visibility("default")))
        #else
            #define NEM_SDK_INTERFACE_EXPORT
            #define NEM_SDK_INTERFACE_EXPORT_PRIVATE
        #endif  // defined(NEM_SDK_INTERFACE_IMPLEMENTATION)
    #endif
#else  // defined(NEM_SDK_INTERFACE_COMPONENT_BUILD)
    #define NEM_SDK_INTERFACE_EXPORT
    #define NEM_SDK_INTERFACE_EXPORT_PRIVATE
#endif

#endif  // NEM_SDK_INTERFACE_EXPORT_H_
