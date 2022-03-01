/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2013, NetEase Inc. All rights reserved.
//
// Author: Wang Rongtao <rtwang@corp.netease.com>
// Date: 2013/9/17
//
// The Singleton<Type> class manages a single instance of Type,
// which will be lazily created on the first time it's accessed

#ifndef BASE_MEMORY_SINGLETON_H_
#define BASE_MEMORY_SINGLETON_H_

#include "base/base_config.h"
#include "base/third_party/chrome/atomicops.h"
#include "base/thread/thread.h"
#include "base/util/at_exit.h"
#include "base/log/log.h"
#include "base/forbid_copy.h"

namespace nbase
{

template<typename Type>
class Singleton
{	
public:
	NBASE_FORBID_COPY(Singleton)

	// |Type| must implements the |GetInstance| method
	friend Type* Type::GetInstance();

	static Type* get()
	{
		using namespace base::subtle;

		AtomicWord value = NoBarrier_Load(&instance_);
		if (value == kNone || value == kCreating)
		{
			if (Acquire_CompareAndSwap(&instance_, kNone, kCreating) == kNone)
			{
				// we take the chance to create the instance
				Type *obj = new Type();
				AtExitManager::RegisterCallback(OnExit, nullptr);
				Release_Store(&instance_, reinterpret_cast<AtomicWord>(obj));
				return obj;
			}
			// wait, util another thread created the instance
			while (NoBarrier_Load(&instance_) != kCreating)
				Thread::YieldThread();
		}

		return reinterpret_cast<Type*>(instance_);
	}

private:
	enum
	{
		kNone = 0,
		kCreating,
	};

	static void OnExit(void *)
	{
		delete reinterpret_cast<Type *>(
			base::subtle::NoBarrier_Load(&instance_));
		instance_ = 0;
	}

	static base::subtle::AtomicWord instance_;
};

template<typename Type>
base::subtle::AtomicWord Singleton<Type>::instance_ = 0;

}

#endif // BASE_MEMORY_SINGLETON_H_
