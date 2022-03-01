/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2013, NetEase Inc. All rights reserved.
//
// Wang Rongtao <rtwang@corp.netease.com>
// 2013/9/17
//
// Unicode define

#ifndef BASE_UTIL_UNICODE_H_
#define BASE_UTIL_UNICODE_H_

#include <string>
#include "base/base_types.h"

typedef char UTF8Char;
#if defined(WCHAR_T_IS_UTF16)
typedef wchar_t UTF16Char;
typedef int32_t UTF32Char;
#else
typedef int16_t UTF16Char;
typedef wchar_t UTF32Char;
#endif

typedef std::basic_string<UTF8Char> UTF8String;
typedef UTF8String U8String;
typedef std::basic_string<UTF16Char> UTF16String;
typedef UTF16String U16String;
typedef std::basic_string<UTF32Char> UTF32String;
typedef UTF32String U32String;

#endif // BASE_UTIL_UNICODE_H_
