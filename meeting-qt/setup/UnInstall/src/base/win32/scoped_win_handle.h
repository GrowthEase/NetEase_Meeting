/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

/*
 *
 *	Author		Wang Rongtao <rtwang@corp.netease.com>
 *	Date		2011-06-08
 *	Copyright	Hangzhou, Netease Inc.
 *	Brief		a implementation of scoped handle which ensures the safe use of Windows handles
 *
 */

#ifndef BASE_WIN32_SCOPED_WIN_HANDLE_H_
#define BASE_WIN32_SCOPED_WIN_HANDLE_H_

#include "base/base_config.h"
#if defined(OS_WIN)

#include <windows.h>
#include "base/base_export.h"
#include "base/forbid_copy.h"

namespace nbase
{
namespace win32
{

class BASE_EXPORT ScopedWinHandle
{
public:
	NBASE_FORBID_COPY(ScopedWinHandle)

	ScopedWinHandle() : handle_(INVALID_HANDLE_VALUE) {}
	ScopedWinHandle(HANDLE handle) : handle_(handle) {}
	~ScopedWinHandle() { Reset(INVALID_HANDLE_VALUE); }

	bool Valid() const { return handle_ != INVALID_HANDLE_VALUE; }
	HANDLE Get() const { return handle_; }
	HANDLE Release() { HANDLE old_handle = handle_; handle_ = INVALID_HANDLE_VALUE; return old_handle; }
	void Reset(HANDLE handle) { if (Valid()) ::CloseHandle(handle_); handle_ = handle; }
	HANDLE* operator&() { return &handle_; }
	operator HANDLE() const { return handle_; }

private:

	HANDLE handle_;
};

} // namespace win32
} // namespace nbase

#endif // OS_WIN
#endif // BASE_WIN32_SCOPED_WIN_HANDLE_H_
