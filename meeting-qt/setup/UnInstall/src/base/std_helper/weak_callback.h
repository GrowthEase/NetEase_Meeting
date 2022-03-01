/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_UTILS_WEAKCALLBACK_H_
#define UI_UTILS_WEAKCALLBACK_H_

#pragma once

#include <memory>
#include "base/time/time.h"
#include "base/thread/thread_manager.h"
#include "base/thread/threads.h"

namespace nbase
{

	class WeakFlag
	{

	};

	class BASE_EXPORT SupportWeakCallback
	{
	public:
		virtual ~SupportWeakCallback(){};

		static const int TIMES_FOREVER = -1;

		template<typename CallbackType>
		CallbackType ToWeakCallback(const CallbackType& closure)
		{
			return ConvertToWeakCallback(closure, GetWeakFlag());
		}

		std::weak_ptr<WeakFlag> GetWeakFlag()
		{
			if (m_weakFlag.use_count() == 0) {
				m_weakFlag.reset((WeakFlag*)NULL);
			}
			return m_weakFlag;
		}

		void PostTaskWeakly(const StdClosure& task)
		{
			StdClosure closure = ToWeakCallback(task);
			nbase::ThreadManager::PostTask(closure);
		}

		void PostTaskWeakly(int thread_id, const StdClosure& task)
		{
			StdClosure closure = ToWeakCallback(task);
			nbase::ThreadManager::PostTask(thread_id, closure);
		}

		void PostDelayedTaskWeakly(const StdClosure& task, const TimeDelta& delay)
		{
			StdClosure closure = ToWeakCallback(task);
			nbase::ThreadManager::PostDelayedTask(closure, delay);
		}

		void PostDelayedTaskWeakly(int thread_id, const StdClosure& task, const TimeDelta& delay)
		{
			StdClosure closure = ToWeakCallback(task);
			nbase::ThreadManager::PostDelayedTask(thread_id, closure, delay);
		}

		void PostRepeatedTaskWeakly(const StdClosure& task, const TimeDelta& delay, int times = TIMES_FOREVER)
		{
			StdClosure closure = std::bind(&SupportWeakCallback::RunRepeatedly, this, task, delay, times);
			PostDelayedTaskWeakly(closure, delay);
		}

		void PostRepeatedTaskWeakly(int thread_id, const StdClosure& task, const TimeDelta& delay, int times = TIMES_FOREVER)
		{
			StdClosure closure = std::bind(&SupportWeakCallback::RunRepeatedly2, this, thread_id, task, delay, times);
			PostDelayedTaskWeakly(thread_id, closure, delay);
		}

	private:
		void RunRepeatedly(const StdClosure& task, const TimeDelta& delay, int times)
		{
			std::weak_ptr<WeakFlag> weakflag = GetWeakFlag();
			task();
			if (!weakflag.expired()) {
				if (times != TIMES_FOREVER) {
					times--;
				}
				if (times != 0) {
					PostRepeatedTaskWeakly(task, delay, times);
				}
			}
		}

		void RunRepeatedly2(int thread_id, const StdClosure& task, const TimeDelta& delay, int times)
		{
			std::weak_ptr<WeakFlag> weakflag = GetWeakFlag();
			task();
			if (!weakflag.expired()) {
				if (times != TIMES_FOREVER) {
					times--;
				}
				if (times != 0) {
					PostRepeatedTaskWeakly(thread_id, task, delay, times);
				}
			}
		}

	private:
		template<typename ReturnValue, typename... Param, typename WeakFlag>
		static std::function<ReturnValue(Param...)> ConvertToWeakCallback(
			std::function<ReturnValue(Param...)> callback, std::weak_ptr<WeakFlag> expiredFlag)
		{
			auto weakCallback = [expiredFlag, callback](Param... p) ->ReturnValue {
				if (!expiredFlag.expired()) {
					return callback(p...);
				}
				return ReturnValue();
			};

			return weakCallback;
		}

	protected:
		std::shared_ptr<WeakFlag> m_weakFlag;
	};

	//WeakCallbackFlag一般作为类成员变量使用，要继承，可使用不带Cancel()函数的SupportWeakCallback
	//这里禁止继承，主要担心误用。当使用这个类的功能，打包出多个支持weak语义的callback时，一旦错误的调用了Cancel，
	//将会取消所有callback，这种情况可能不是用户希望的。此时，应该使用多个不带Cancel函数的WeakCallbackFlag类型的成员变量，
	//每个对应一个callback，一一对应的控制每个支持weak语义的callback。
	class BASE_EXPORT WeakCallbackFlag final : public SupportWeakCallback
	{
	public:
		void Cancel() 
		{
			m_weakFlag.reset();
		}

		bool HasUsed()
		{
			return m_weakFlag.use_count() != 0;
		}
	};



	class BASE_EXPORT SupportDestroyCallback
	{
	public:

		virtual ~SupportDestroyCallback()
		{
			for (auto& closure : destroy_callback_list_) {
				if (closure) {
					closure();
				}
				else {
					assert(false);
				}
			}
		};

		void AddDestroyCallback(const StdClosure& closure)
		{
			destroy_callback_list_.push_back(closure);
		}

	private:
		std::list<StdClosure> destroy_callback_list_;
	};

}// namespace ui

#endif // UI_UTILS_WEAKCALLBACK_H_