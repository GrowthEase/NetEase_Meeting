/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/28
//
// IO message pump with libevent

#include "libevent_message_pump.h"

#if defined(OS_POSIX) && defined(WITH_LIBEVENT)

#include <unistd.h>
#include <fcntl.h>
#include <event.h>

#include <memory>
#include "observer_list.h"
#include "base/time/time.h"
#include "base/network/nio_base.h"
#include "base/macros.h"
#include "base/log/log_impl.h"

namespace nbase
{

static int SetNonBlocking(int fd)
{
	int flags = fcntl(fd, F_GETFL, 0);
	if (flags == -1)
		flags = 0;
	return fcntl(fd, F_SETFL, flags | O_NONBLOCK);
}


LibeventMessagePump::FileDescriptorWatcher::FileDescriptorWatcher()
	: is_persistent_(false),
	  event_(NULL),
	  pump_(NULL),
	  watcher_(NULL)
{
}

LibeventMessagePump::FileDescriptorWatcher::~FileDescriptorWatcher()
{
	if (event_)
	{
		StopWatchingFileDescriptor();
	}
}

bool LibeventMessagePump::FileDescriptorWatcher::StopWatchingFileDescriptor()
{
	event *e = ReleaseEvent();
	if (e == NULL)
		return true;

	// event_del() is a no-op if the event isn't active.
	int rv   = event_del(e);
	delete e;
	pump_    = NULL;
	watcher_ = NULL;
	return (rv == 0);
}

void LibeventMessagePump::FileDescriptorWatcher::Init(event *e, bool is_persistent)
{
	if (e)
	{
		is_persistent_ = is_persistent;
		event_         = e;
	}
}

event * LibeventMessagePump::FileDescriptorWatcher::ReleaseEvent()
{
	struct event *e = event_;
	event_ = NULL;
	return e;
}

void LibeventMessagePump::FileDescriptorWatcher::OnFileCanReadWithoutBlocking(
	int fd, LibeventMessagePump *pump)
{
	pump->PreProcessIOEvent();
	watcher_->OnFileCanReadWithoutBlocking(fd);
	pump->PostProcessIOEvent();
}

void LibeventMessagePump::FileDescriptorWatcher::OnFileCanWriteWithoutBlocking(
	int fd, LibeventMessagePump *pump)
{
	pump->PreProcessIOEvent();
	watcher_->OnFileCanWriteWithoutBlocking(fd);
	pump->PostProcessIOEvent();
}

LibeventMessagePump::LibeventMessagePump()
	: keep_running_(true),
	  in_run_(false),
	  processed_io_events_(false),
	  event_base_(event_base_new()),
	  wakeup_pipe_in_(-1),
	  wakeup_pipe_out_(-1)
{
	Init();
}

LibeventMessagePump::~LibeventMessagePump()
{
	if (wakeup_event_)
	{
		event_del(wakeup_event_);
		delete wakeup_event_;
	}
	if (wakeup_pipe_in_ >= 0)
	{
		int r = ::close(wakeup_pipe_in_);
		if (r != 0)
		{
			DEFLOG(LogInterface::LV_ERR, 
				   __FILE__, 
				   __LINE__, 
				   "LibeventMessagePump close wakeup_pipe_in_ error:%d", 
				   errno);
		}
	}
	if (wakeup_pipe_out_ >= 0)
	{
		int r = ::close(wakeup_pipe_out_);
		if (r != 0)
		{
			DEFLOG(LogInterface::LV_ERR, 
				   __FILE__, 
				   __LINE__, 
				   "LibeventMessagePump close wakeup_pipe_out_ error:%d", 
				   errno);
		}
	}
	if (event_base_)
		event_base_free(event_base_);
}

bool LibeventMessagePump::WatchFileDescriptor(int fd,
	                                          bool persistent,
											  Mode mode,
											  FileDescriptorWatcher *controller,
											  Watcher *delegate)
{
    if (fd <= 0)
		assert(0);
	PTR_FALSE(controller);
	PTR_FALSE(delegate);
	if (!(mode == WATCH_READ || mode == WATCH_WRITE || mode == WATCH_READ_WRITE))
		assert(0);
	
	int event_mask = persistent ? EV_PERSIST : 0;
	if ((mode & WATCH_READ) != 0)
		event_mask |= EV_READ;
	if ((mode & WATCH_WRITE) != 0)
		event_mask |= EV_WRITE;

	std::unique_ptr<event> evt(controller->ReleaseEvent());
	if (evt.get() == NULL)
	{
		evt.reset(new event);
	}
	else
	{
		// Make sure we don't pick up any funky internal libevent masks.
		int old_interest_mask = evt.get()->ev_events &
			                    (EV_READ | EV_WRITE | EV_PERSIST);

		// Combine old/new event masks.
		event_mask |= old_interest_mask;

		// Must disarm the event before we can reuse it.
		event_del(evt.get());

		// It's illegal to use this function to listen on 2 separate fds with the
		// same |controller|.
		if (EVENT_FD(evt.get()) != fd)
		{
			return false;
		}
	}

	// Set current interest mask and message pump for this event.
	event_set(evt.get(), fd, event_mask, OnLibeventNotification, controller);

	// Tell libevent which message pump this socket will belong to when we add it.
	if (event_base_set(event_base_, evt.get()) != 0)
	{
		return false;
	}

	// Add this socket to the list of monitored sockets.
	if (event_add(evt.get(), NULL) != 0)
	{
		return false;
	}

	// Transfer ownership of evt to controller.
	controller->Init(evt.release(), persistent);

	controller->set_watcher(delegate);
	controller->set_pump(this);

	return true;
}

void LibeventMessagePump::AddObserver(IOObserver* obs)
{
	io_observers_.AddObserver(obs);
}

void LibeventMessagePump::RemoveObserver(IOObserver* obs)
{
	io_observers_.RemoveObserver(obs);
}

// Tell libevent to break out of inner loop.
static void timer_callback(int fd, short events, void *context)
{
	event_base_loopbreak((struct event_base *)context);
}

void LibeventMessagePump::Run(Delegate* delegate)
{
	in_run_ = true;

	// event_base_loopexit() + EVLOOP_ONCE is leaky, see http://crbug.com/25641.
	// Instead, make our own timer and reuse it on each call to event_base_loop().
	std::unique_ptr<event> timer_event(new event);

	for (;;)
	{
		bool did_work = delegate->DoWork();
		if (!keep_running_)
			break;

		event_base_loop(event_base_, EVLOOP_NONBLOCK);
		did_work |= processed_io_events_;
		processed_io_events_ = false;
		if (!keep_running_)
			break;

		did_work |= delegate->DoDelayedWork(&delayed_work_time_);
		if (!keep_running_)
			break;

		if (did_work)
			continue;

		did_work = delegate->DoIdleWork();
		if (!keep_running_)
			break;

		if (did_work)
			continue;

		// EVLOOP_ONCE tells libevent to only block once,
		// but to service all pending events when it wakes up.
		if (delayed_work_time_.is_null())
		{
			event_base_loop(event_base_, EVLOOP_ONCE);
		}
		else
		{
			TimeDelta delay = delayed_work_time_ - TimeTicks::Now();
			if (delay > TimeDelta())
			{
				struct timeval poll_tv;
				poll_tv.tv_sec = delay.ToSeconds();
				poll_tv.tv_usec = delay.ToMicroseconds() % Time::kMicrosecondsPerSecond;
				event_set(timer_event.get(), -1, 0, timer_callback, event_base_);
				event_base_set(event_base_, timer_event.get());
				event_add(timer_event.get(), &poll_tv);
				event_base_loop(event_base_, EVLOOP_ONCE);
				event_del(timer_event.get());
			}
			else
			{
				// It looks like delayed_work_time_ indicates a time in the past, so we
				// need to call DoDelayedWork now.
				delayed_work_time_ = TimeTicks();
			}
		}
	}

	keep_running_ = true;
}

void LibeventMessagePump::Quit()
{
	if (in_run_)
	{
		keep_running_ = false;
		ScheduleWork();
	}
}

void LibeventMessagePump::ScheduleWork()
{
	char buf = 0;
	int write_len = write(wakeup_pipe_in_, &buf, 1);
	if (!(write_len == 1 || errno == EAGAIN))
	{
		DEFLOG(LogInterface::LV_ERR, 
			   __FILE__,
			   __LINE__, 
			   "LibeventMessagePump ScheduleWork write errno %d", 
			   errno);
	}
}

void LibeventMessagePump::ScheduleDelayedWork(const TimeTicks& delayed_work_time)
{
	// We know that we can't be blocked on Wait right now since this method can
	// only be called on the same thread as Run, so we only need to update our
	// record of how long to sleep when we do sleep.
	delayed_work_time_ = delayed_work_time;
}
    
event_base* LibeventMessagePump::event_base()
{
    return event_base_;
}

void LibeventMessagePump::PreProcessIOEvent()
{
	AutoLazyEraser lazy_eraser(&io_observers_);
	size_t index = 0;
	IOObserver* observer;
	while (index < io_observers_.GetObserverCount())
	{
		observer = io_observers_.GetObserver(index++);
		if (observer == NULL)
			continue;
		observer->PreProcessIOEvent();
	}
}

void LibeventMessagePump::PostProcessIOEvent()
{
	AutoLazyEraser lazy_eraser(&io_observers_);
	size_t index = 0;
	IOObserver* observer;
	while (index < io_observers_.GetObserverCount())
	{
		observer = io_observers_.GetObserver(index++);
		if (observer == NULL)
			continue;
		observer->PostProcessIOEvent();
	}
}

bool LibeventMessagePump::Init()
{
	int fds[2];
	if (pipe(fds))
	{
		DEFLOG(LogInterface::LV_ERR, 
			   __FILE__, 
			   __LINE__, 
			   "pipe() failed, errno:%d", 
			   errno);
		return false;
	}
	if (SetNonBlocking(fds[0]))
	{
		DEFLOG(LogInterface::LV_ERR, 
			   __FILE__, 
			   __LINE__, 
			   "set_block for pipe fd[0] failed, errno:%d", 
			   errno);
		return false;
	}
	if (SetNonBlocking(fds[1]))
	{
		DEFLOG(LogInterface::LV_ERR, 
			   __FILE__, 
			   __LINE__, 
			   "set_block for pipe fd[1] failed, errno:%d", 
			   errno);
		return false;
	}
	wakeup_pipe_out_ = fds[0];
	wakeup_pipe_in_ = fds[1];

	wakeup_event_ = new event;
	event_set(wakeup_event_, wakeup_pipe_out_, EV_READ | EV_PERSIST,
		OnWakeup, this);
	event_base_set(event_base_, wakeup_event_);

	if (event_add(wakeup_event_, 0))
		return false;
	return true;
}

void LibeventMessagePump::OnLibeventNotification(int fd, short flags, void* context)
{
	FileDescriptorWatcher* controller =
		static_cast<FileDescriptorWatcher*>(context);

	LibeventMessagePump* pump = controller->pump();
	pump->processed_io_events_ = true;

	if (flags & EV_WRITE)
	{
		controller->OnFileCanWriteWithoutBlocking(fd, pump);
	}
	if (flags & EV_READ)
	{
		controller->OnFileCanReadWithoutBlocking(fd, pump);
	}

}

void LibeventMessagePump::OnWakeup(int socket, short flags, void* context)
{
	nbase::LibeventMessagePump* that =
		static_cast<nbase::LibeventMessagePump*>(context);
	if (that->wakeup_pipe_out_ != socket)
		return;

	// Remove and discard the wakeup byte.
	char buf;
	int nread = read(socket, &buf, 1);
	if (nread != 1)
		return;
	that->processed_io_events_ = true;
	// Tell libevent to break out of inner loop.
	event_base_loopbreak(that->event_base_);
}

}

#endif  // WITH_LIBEVENT && OS_POSIX

