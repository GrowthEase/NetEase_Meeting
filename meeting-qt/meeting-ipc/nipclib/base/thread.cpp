/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */


#include "nipclib/base/ipc_thread.h"
NIPCLIB_BEGIN_DECLS
#ifdef WIN32
#include <windows.h>
__declspec(thread) ThreadTLS* IThread::tls_data_ = nullptr;

namespace {
	const DWORD kVCThreadNameException = 0x406D1388;
	typedef struct tagTHREADNAME_INFO {
		DWORD dwType;  // Must be 0x1000.
		LPCSTR szName;  // Pointer to name (in user addr space).
		DWORD dwThreadID;  // Thread ID (-1=caller thread).
		DWORD dwFlags;  // Reserved for future use, must be zero.
	} THREADNAME_INFO;

	// This function has try handling, so it is separated out of its caller.
	void SetNameInternal(std::thread::id thread_id, const char* name) {
		THREADNAME_INFO info;
		void* ptr_stl_id = &thread_id;
		union {int64_t stl_id;	DWORD win_id;} stl_thread_id;
		stl_thread_id.stl_id = *(int64_t*)(ptr_stl_id);
		info.dwType = 0x1000;
		info.szName = name;
		info.dwThreadID = stl_thread_id.stl_id;
		info.dwFlags = 0;

		__try {
			RaiseException(kVCThreadNameException, 0, sizeof(info) / sizeof(DWORD),
				reinterpret_cast<DWORD_PTR*>(&info));
		}
		__except (EXCEPTION_CONTINUE_EXECUTION) {
		}
	}
}
#else
thread_local ThreadTLS* IThread::tls_data_ = nullptr;
#endif

IPCThread::IPCThread(const std::string& name) :
	begin_internal_callback_(nullptr),
	end_internal_callback_(nullptr),
	begin_callback_(nullptr),
	end_callback_(nullptr),
    first_time_(true),
	exit_(false),
	running_(false),
	stl_thread_(nullptr),
	name_(name) ,
	task_loop_(new ThreadTaskLoop)
{
	task_loop_->SetTaskDelegat(this);
};
IPCThread:: ~IPCThread() 
{
	if (running_ && stl_thread_ != nullptr)
	{
		Stop();
		stl_thread_->Join();
		stl_thread_.reset();
	}
};
bool IPCThread::IsRunning() const
{
	return running_;
}
void IPCThread::AttachBegin(const RuntimeCallback& begin_callback)
{
	begin_callback_ = begin_callback;
}
void IPCThread::AttachEnd(const RuntimeCallback& end_callback)
{
	end_callback_ = end_callback;
}
ITaskLoop* IPCThread::TaskLoop()
{
	return task_loop_.get();
}
void IPCThread::PostTask(const Task& task)
{
	{
		std::lock_guard<std::recursive_mutex> auto_lock(mut_task_list_);
		catch_task_list_.push(task);
		if (task_list_.empty())
			task_list_.swap(catch_task_list_);
	}
	std::unique_lock<std::recursive_mutex> lk(mut_loop_);
	cv_loop.notify_all();
}
void IPCThread::PostRepeatTask(int time_block, const Task& task, int times/* = -1*/)
{
	InsertDelayTask(time_block, task, times);
}
void IPCThread::PostHighPriorityTask(const Task& task)
{
	{
		std::lock_guard<std::recursive_mutex> auto_lock(mut_high_priority_task_list_);
		catch_high_priority_task_list_.push(task);
		if (high_priority_task_list_.empty())
			high_priority_task_list_.swap(catch_high_priority_task_list_);
	}
	std::unique_lock<std::recursive_mutex> lk(mut_loop_);
	cv_loop.notify_all();
}
void IPCThread::PostDelayTask(int time_block, const Task& task)
{
	InsertDelayTask(time_block, task, 0);
}
void IPCThread::Start()
{
	stl_thread_ = std::make_unique< STLThread>([this]() {
		DoMain();
		});
	if (!running_)
	{
		std::unique_lock<std::mutex> wait_lock(run_signal_lock_);
		if (!running_)
			run_signal_cond_var_.wait(wait_lock);
	}

}
void IPCThread::Stop()
{
	DoStop();
	Join();
}
void IPCThread::Join()
{
	DoJoin();
}
void IPCThread::AttachCurrentThread()
{
	DoMain();
}
bool IPCThread::IsCurrentThread()
{
	return IThread::GetID() == thread_id_;
}
void IPCThread::AttachInternalBegin(const RuntimeCallback& begin_callback)
{
	begin_internal_callback_ = begin_callback;
}
void IPCThread::AttachInternalEnd(const RuntimeCallback& end_callback)
{
	end_internal_callback_ = end_callback;
}
void IPCThread::DoStop()
{
	exit_ = true;
	std::unique_lock<std::recursive_mutex> lk(mut_loop_);
	cv_loop.notify_all();
}
void IPCThread::DoJoin()
{
	if (stl_thread_ != nullptr)
	{
		stl_thread_->Join();
	}
}
void IPCThread::DoMain()
{
	thread_id_ = std::this_thread::get_id();
	ThreadTLS tls_data(name_,TaskLoop(), thread_id_);
	SetThreadTLS(tls_data);
#ifdef WIN32		
	SetNameInternal(thread_id_, name_.c_str());
#endif
	{
		std::unique_lock<std::mutex> lock(run_signal_lock_);
		if (begin_internal_callback_ != nullptr)
			begin_internal_callback_();
		if (begin_callback_ != nullptr)
			begin_callback_();
		running_ = true;
		run_signal_cond_var_.notify_all();
	}
	OnTaskLoop();
	running_ = false;
	if (end_callback_)
		end_callback_();
	if (end_internal_callback_ != nullptr)
		end_internal_callback_();
}

void IPCThread::OnTaskLoop()
{
	while (!exit_)
	{
		std::cv_status ret = std::cv_status::no_timeout;
		{
			std::unique_lock<std::recursive_mutex> lk(mut_loop_);
			auto wait_tt = std::chrono::milliseconds(GetDelayTaskWaitTime());
			ret = cv_loop.wait_for(lk, wait_tt);
		}
		if (exit_)
			break;
		if (ret == std::cv_status::no_timeout)
		{
			RunTasks();
			RunDelayTasks();
		}
		else
		{
            if (first_time_)
            {
                first_time_ = false;
                RunTasks();
            }
			RunDelayTasks();
		}
	}
}
void IPCThread::RunDelayTasks()
{
	RunHighPriorityTasks();
	std::lock_guard<std::recursive_mutex> auto_lock(mut_delay_task_list_);
	if (exit_)
		return;
	auto it = delay_task_list_.begin();
	while (it != delay_task_list_.end())
	{
		if (it->second.NeedDoTask())
		{
			if (it->second.Needrepeat()) {

			}
			it->second.Run();
			it = delay_task_list_.erase(it);
			if (exit_)
				return;
		}
		else
		{
			it++;
		}
	}
}
void IPCThread::RunHighPriorityTasks()
{
	if (exit_) return;
	while (!high_priority_task_list_.empty())
	{
		high_priority_task_list_.front()();
		high_priority_task_list_.pop();
		if (exit_) return;
	}
	bool re_run = false;
	{
		std::lock_guard<std::recursive_mutex> auto_lock(mut_high_priority_task_list_);
		if (!catch_high_priority_task_list_.empty())
		{
			re_run = true;
			high_priority_task_list_.swap(catch_high_priority_task_list_);
		}
	}
	if (re_run)
		RunHighPriorityTasks();
}

void IPCThread::SetThreadTLS(const ThreadTLS& tls_data)
{
	if (tls_data_ == nullptr)
		tls_data_ = new ThreadTLS();
	*tls_data_ = tls_data;
}
void IPCThread::RunTasks()
{
	if (exit_)
		return;
	RunHighPriorityTasks();
	while (!task_list_.empty())
	{
		task_list_.front()();
		task_list_.pop();
		if (exit_)
			return;
		RunHighPriorityTasks();
	}
	bool re_run = false;
	{
		std::lock_guard<std::recursive_mutex> auto_lock(mut_task_list_);
		if (!catch_task_list_.empty())
		{
			re_run = true;
			task_list_.swap(catch_task_list_);
		}
	}
	if (re_run)
		RunTasks();
}
NIPCLIB_END_DECLS
