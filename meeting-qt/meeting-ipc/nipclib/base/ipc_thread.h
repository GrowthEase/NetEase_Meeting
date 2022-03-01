/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NIPCLIB_BASE_IPC_THREAD_H_
#define NIPCLIB_BASE_IPC_THREAD_H_

#include "nipclib/nipclib_export.h"
#include "nipclib/config/build_config.h"

#include <list>
#include <thread>
#include <atomic>
#include <mutex>
#include <functional>
#include <condition_variable>
#include <queue>
#include <map>
#include "nipclib/base/callback.h"
#include "nipclib/base/task_loop_interface.h"
#include "nipclib/base/thread_interface.h"

NIPCLIB_BEGIN_DECLS

class IPCThread : public IThread,public ITaskDelegate
{
private:		
	class DelayTask
	{
		friend class IPCThread;
		static constexpr inline int64_t CalcNanoMilli()	{
			return std::nano::den / std::milli::den;
		}
		using DorepeatDelegate = std::function<void(int time_block, const Task& task, int64_t repeat_times)>;
	public:
		DelayTask() : repeat_times_(0){

		}
		DelayTask(int time_block,const Task& task,int64_t repeat_times = 0) :
			time_block_(time_block),	
			repeat_times_(repeat_times),
			create_time_point_(std::chrono::steady_clock::now().time_since_epoch().count() / CalcNanoMilli()),
			task_(task){
			run_time_point_ = create_time_point_ + time_block_;
		}
		inline int64_t CalcWaitTime() const {
			return (run_time_point_ - std::chrono::steady_clock::now().time_since_epoch().count() / CalcNanoMilli());
		}
		inline bool NeedDoTask() {
			return (std::chrono::steady_clock::now().time_since_epoch().count() / CalcNanoMilli() - run_time_point_) >= 0;
		}
		inline bool Needrepeat() {
			return (repeat_times_ > 0);
		}
		inline void Run() {
			repeat_times_ -= 1;
			if (Needrepeat() && do_repeat_delegate_ != nullptr)
				do_repeat_delegate_(time_block_, task_, repeat_times_);
			task_();
		}
	private:
		int time_block_;
		int64_t repeat_times_;
		int64_t run_time_point_;
		long long create_time_point_;
		Task task_;
		DorepeatDelegate do_repeat_delegate_;
	};
private:
	class STLThread
	{
	public:
		STLThread(const std::function<void()>& thread_proc):thread_(thread_proc){}
		void Join()
		{
			if (thread_.joinable())
				thread_.join();
		}
	private:
		std::thread thread_;
	};
private:
	class ThreadTaskLoop : public ITaskLoop
	{
	public:
		virtual void SetTaskDelegat(ITaskDelegate* delegate) override {
			delegate_ = delegate;
		}
		virtual void PostTask(const Task& task) override {
			if (delegate_ != nullptr)
				delegate_->PostTask(task);
		}
		virtual void PostHighPriorityTask(const Task& task) override {
			if (delegate_ != nullptr)
				delegate_->PostHighPriorityTask(task);
		}
		virtual void PostDelayTask(int time_block, const Task& task) override {
			if (delegate_ != nullptr)
				delegate_->PostDelayTask(time_block,task);
		}
		virtual void PostRepeatTask(int time_block, const Task& task, int times = -1) override {
			if (delegate_ != nullptr)
				delegate_->PostRepeatTask(time_block,task,times);
		}
	private:
		ITaskDelegate* delegate_;
	};
public:	
    IPCThread(const std::string& name);
	virtual ~IPCThread();
public:		
	virtual bool IsRunning() const override;
	virtual void AttachBegin(const RuntimeCallback& begin_callback) override;
	virtual void AttachEnd(const RuntimeCallback& end_callback) override;
	virtual ITaskLoop* TaskLoop() override;
	virtual void Start() override;
	virtual void Stop() override;
	virtual void Join() override;
	virtual void AttachCurrentThread() override;
	virtual bool IsCurrentThread() override;
protected:
	void AttachInternalBegin(const RuntimeCallback& begin_callback);
	void AttachInternalEnd(const RuntimeCallback& end_callback);
	inline void InsertDelayTask(int time_block, const Task& task, int64_t times = -1)
	{
		{
			std::lock_guard<std::recursive_mutex> auto_lock(mut_delay_task_list_);
			if (times < 0)
				times = 0x7FFFFFFFFFFFFFFF;
			auto delay_task = DelayTask(time_block, task, times);
			delay_task.do_repeat_delegate_ = std::bind(&IPCThread::RepeatTask, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
			delay_task_list_[delay_task.run_time_point_] = delay_task;
		}

		std::unique_lock<std::recursive_mutex> lk(mut_loop_);
		cv_loop.notify_all();
	}
	virtual void DoStop();
	virtual void DoJoin();
	virtual void DoMain();
	
protected:
	virtual void OnTaskLoop();
	void RunDelayTasks();
	void RunHighPriorityTasks();
	void RunTasks();
	virtual void SetThreadTLS(const ThreadTLS& tls_data) override;
private:
    virtual void PostTask(const Task& task) override;
    virtual void PostRepeatTask(int time_block, const Task& task, int times = -1) override;
    virtual void PostHighPriorityTask(const Task& task) override;
    virtual void PostDelayTask(int time_block, const Task& task) override;
	inline int64_t GetDelayTaskWaitTime() {
        if (first_time_) {
            return 1;
        }
		std::lock_guard<std::recursive_mutex> auto_lock(mut_delay_task_list_);
		if (delay_task_list_.empty())
			return 0x13A23EC00;
		auto ret = delay_task_list_.begin()->second.CalcWaitTime();
		return ret >= 0 ? ret : 0;
	}
	inline void RepeatTask(int time_block, const Task& task, int64_t repeat_times) {
		InsertDelayTask(time_block, task, repeat_times);
	}
protected:
	RuntimeCallback begin_internal_callback_;
	RuntimeCallback end_internal_callback_;
private:
	RuntimeCallback begin_callback_;
	RuntimeCallback end_callback_;
	

	std::queue< Task> task_list_;
	std::queue< Task> catch_task_list_;
	std::recursive_mutex mut_task_list_;

	std::queue< Task> high_priority_task_list_;
	std::queue< Task> catch_high_priority_task_list_;
	std::recursive_mutex mut_high_priority_task_list_;

	std::map<uint64_t, DelayTask> delay_task_list_;
	std::recursive_mutex mut_delay_task_list_;

	std::recursive_mutex mut_loop_;
	std::condition_variable_any cv_loop;

    std::atomic_bool first_time_;
	std::atomic_bool exit_;
	std::atomic_bool running_;
	std::unique_ptr< STLThread> stl_thread_;
	std::mutex run_signal_lock_;
	std::condition_variable run_signal_cond_var_;
	std::string name_;
	std::thread::id thread_id_;
	std::shared_ptr< ThreadTaskLoop > task_loop_;
};

NIPCLIB_END_DECLS

#endif//NIPCLIB_BASE_IPC_THREAD_H_
