/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/10
//
// Semaphore implementation

#ifndef BASE_SYNCHRONIZATION_SEMAPHORE_H_
#define BASE_SYNCHRONIZATION_SEMAPHORE_H_

#include "base/base_export.h"
#include "base/base_types.h"

#if defined(OS_WIN)
#include <windows.h>
#else
#include <sys/semaphore.h>
#endif

namespace nbase
{

class BASE_EXPORT Semaphore
{
public:
#if defined(OS_WIN)
typedef HANDLE OSSemaphoreType;
#elif defined(OS_POSIX)
typedef sem_t *OSSemaphoreType;
#endif

	Semaphore();
	~Semaphore();

public:
	bool CreateSemaphore(const char *sem_name, uint32_t init_value, uint32_t max_value);
	/* wait the semaphore until some post one*/
	bool WaitSemaphore();
	/* wait the semaphore until some post one or timeout */
	bool WaitSemaphore(uint32_t timeout_ms);
	/* post some semaphore*/
	bool PostSemaphore(uint32_t post_num);

private:
	uint32_t        init_value_;
	OSSemaphoreType semaphore_;
};

}  // namespace nbase

#endif  // BASE_SYNCHRONIZATION_SEMAPHORE_H_