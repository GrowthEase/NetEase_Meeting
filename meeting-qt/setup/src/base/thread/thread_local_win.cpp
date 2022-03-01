/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Wang Rongtao <rtwang@corp.netease.com>
// Date: 2011/6/14
//
// This file implements some useful thread local template data structures for Windows

#include "base/thread/thread_local.h"
#if defined(OS_WIN)
#include <assert.h>
#include <windows.h>

namespace nbase
{

namespace internal
{

// static
void ThreadLocalPlatform::AllocateSlot(SlotType &slot)
{
	slot = ::TlsAlloc();
	assert(slot != TLS_OUT_OF_INDEXES);
}

// static
void ThreadLocalPlatform::FreeSlot(SlotType &slot)
{
	if (!::TlsFree(slot))
	{
		assert(false);
	}
}

// static
void* ThreadLocalPlatform::GetValueFromSlot(SlotType &slot)
{
	return ::TlsGetValue(slot);
}

// static
void ThreadLocalPlatform::SetValueInSlot(SlotType &slot, void *value)
{
	if (!::TlsSetValue(slot, value))
	{
		assert(false);
	}
}

}  // namespace internal

}  // namespace base

#endif // OS_WIN
