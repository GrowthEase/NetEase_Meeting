/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2013, NetEase Inc. All rights reserved.
//
// Wang Rongtao <rtwang@corp.netease.com>
// 2013/9/17
//
// File path operation

#ifndef BASE_FILE_FILE_PATH_H_
#define BASE_FILE_FILE_PATH_H_

#include <string>

namespace nbase
{

#if defined(OS_POSIX)
typedef std::string PathString;
#elif defined(OS_WIN)
typedef std::wstring PathString;
#endif

typedef PathString::value_type PathChar;

} // namespace nbase

#endif // BASE_FILE_FILE_PATH_H_
