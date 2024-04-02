/** @file nertc_base.h
  * @brief  Defines macro output. The file only defines macro output instead of anything else. 
  * @copyright (c) 2015-2019, NetEase Inc. All rights reserved.
  */

#ifndef NERTC_BASE_H
#define NERTC_BASE_H

#if defined(_WIN32)
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>
#define NERTC_CALL __cdecl
#if defined(NERTC_SDK_EXPORT)
#define NERTC_API extern "C" __declspec(dllexport)
#else
#define NERTC_API extern "C" __declspec(dllimport)
#endif
#elif defined(__APPLE__)
#define NERTC_API __attribute__((visibility("default"))) extern "C"
#define NERTC_CALL
#elif defined(__ANDROID__) || defined(__linux__)
#define NERTC_API extern "C" __attribute__((visibility("default")))
#define NERTC_CALL
#else
#define NERTC_API extern "C"
#define NERTC_CALL
#endif

#if defined __GNUC__
#define NERTC_DEPRECATED __attribute__ ((deprecated))
#elif defined(_MSC_VER)
#define NERTC_DEPRECATED __declspec(deprecated)
#else
#define NERTC_DEPRECATED
#endif

#endif