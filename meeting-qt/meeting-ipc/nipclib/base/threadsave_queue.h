/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NIPCLIB_BASE_THREADSAVE_QUEUE_H_
#define NIPCLIB_BASE_THREADSAVE_QUEUE_H_

#include "nipclib/nipclib_export.h"
#include "nipclib/config/build_config.h"

#include <queue>
#include <memory>
#include <mutex>
#include <condition_variable>
#include <iostream>
#include <thread>
#include <list>
NIPCLIB_BEGIN_DECLS
template<typename T>
using QueueDataList = std::list< T>;
template<typename T>
class NIPCLIB_EXPORT ThreadsaveQueue {
public:
	ThreadsaveQueue() {}
	void push(T new_value) {
		std::lock_guard<std::recursive_mutex> auto_lock(data_queue_lock_);
		data_queue_.push(new_value);
		data_cond_.notify_one();
	}
	void push(const QueueDataList<T> data_list)
	{
		std::lock_guard<std::recursive_mutex> auto_lock(data_queue_lock_);
		for (auto it : data_list)
		{
			data_queue_.push(it); 
		}		
		data_cond_.notify_one();
	}
	T wait_and_pop() {
		std::unique_lock<std::recursive_mutex> auto_lock(data_queue_lock_);
		data_cond_.wait(auto_lock, [this]() {return !data_queue_.empty(); });
		T value = data_queue_.front();
		data_queue_.pop();
		return value;
	}
	bool empty()const {
		std::lock_guard<std::recursive_mutex> auto_lock(data_queue_lock_);
		return data_queue_.empty();
	}
private:
	mutable std::recursive_mutex data_queue_lock_;
	std::queue<T> data_queue_;
	std::condition_variable_any data_cond_;
};
NIPCLIB_END_DECLS
#endif//NIPCLIB_BASE_THREADSAVE_QUEUE_H_