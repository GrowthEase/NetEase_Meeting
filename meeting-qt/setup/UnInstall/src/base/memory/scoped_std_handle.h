/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Wang Rongtao <rtwang@corp.netease.com>
// Date: 2011/6/8
//
// a implementation of scoped handle which ensures the safe use of stardard handles

#ifndef BASE_MEMORY_SCOPED_STD_HANDLE_H_
#define BASE_MEMORY_SCOPED_STD_HANDLE_H_

#include <stdio.h>
#include "base/base_config.h"
#include "base/base_export.h"
#include "base/forbid_copy.h"

namespace nbase
{

class BASE_EXPORT ScopedStdHandle
{
public:
	NBASE_FORBID_COPY(ScopedStdHandle)

	ScopedStdHandle() : handle_(nullptr) {}
	ScopedStdHandle(FILE *handle) : handle_(handle) {}
	~ScopedStdHandle() { Reset(nullptr); }

	bool Valid() const { return handle_ != nullptr; }
	FILE* Get() const { return handle_; }
	FILE* Release() { FILE *old_handle = handle_; handle_ = nullptr; return old_handle; }
	void Reset(FILE *handle) { if (Valid()) fclose(handle_); handle_ = handle; }
	operator FILE *() const { return handle_; }
	operator FILE **() { return &handle_; }

private:

	FILE *handle_;
};

} // namespace

#endif // BASE_MEMORY_SCOPED_STD_HANDLE_H_
