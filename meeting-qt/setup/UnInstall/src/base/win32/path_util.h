/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2012, NetEase Inc. All rights reserved.
//
// Wang Rongtao <rtwang@corp.netease.com>
// 2012/5/31
//
// utilities for path operation

#ifndef BASE_WIN32_PATH_UTIL_H_
#define BASE_WIN32_PATH_UTIL_H_

#include "base/base_config.h"

#if defined(OS_WIN)

#include "base/base_export.h"
#include <string>

namespace nbase
{
namespace win32
{

BASE_EXPORT std::wstring GetModulePathName(HMODULE module_handle);
BASE_EXPORT std::wstring GetModuleDirectory(HMODULE module_handle);
BASE_EXPORT std::wstring GetModuleName(HMODULE module_handle);
BASE_EXPORT std::wstring GetCurrentModuleName();
BASE_EXPORT std::wstring GetCurrentModulePathName();
BASE_EXPORT std::wstring GetCurrentModuleDirectory();
BASE_EXPORT std::wstring GetWindowsDir();
BASE_EXPORT std::wstring GetSystemDir();
BASE_EXPORT std::wstring GetTempDir();
BASE_EXPORT std::wstring GetLocalAppDataDir(HANDLE token = NULL);

BASE_EXPORT bool CreateDirectoryRecursively(const wchar_t *full_dir);
BASE_EXPORT bool DeleteDirectoryRecursively(const wchar_t *full_dir);

}
}

#endif // OS_WIN
#endif // BASE_WIN32_PATH_UTIL_H_