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

#ifndef BASE_FRAMEWORK_LIBEVENT_MESSAGE_PUMP_H_
#define BASE_FRAMEWORK_LIBEVENT_MESSAGE_PUMP_H_

#include "base/base_types.h"
#include "base/framework/message_pump.h"
#include "base/framework/observer_list.h"
#include "base/time/time.h"

#if defined(OS_POSIX) && defined(WITH_LIBEVENT)

struct event_base;
struct event;

namespace nbase
{

// Class to monitor sockets and issue callbacks when sockets are ready for I/O
class BASE_EXPORT LibeventMessagePump : public MessagePump
{
public:
	class IOObserver
	{
	public:
		IOObserver() {}

		// An IOObserver is an object that receives IO notifications from the
		// MessagePump
		virtual void PreProcessIOEvent() = 0;
		virtual void PostProcessIOEvent() = 0;
	protected:
		virtual ~IOObserver() {}
	};

	// Used with WatchFileDescptor to asynchronously monitor the I/O readiness of
	// a File Descriptor.
	class Watcher
	{
	public:
		Watcher() {}
		virtual ~Watcher() {}
		// Called from MessageLoop::Run when an FD can be read from/written to
		// without blocking
		virtual void OnFileCanReadWithoutBlocking(int fd) = 0;
		virtual void OnFileCanWriteWithoutBlocking(int fd) = 0;
	};

	// Object returned by WatchFileDescriptor to manage further watching.
	class FileDescriptorWatcher
	{
	public:
		FileDescriptorWatcher();
		~FileDescriptorWatcher();

		// Stop watching the FD, always safe to call.  No-op if there's nothing
		// to do.
		bool StopWatchingFileDescriptor();

	private:
		friend class LibeventMessagePump;

		// Called by LibeventMessagePump, ownership of |e| is transferred to this
		// object
		void Init(event *e, bool is_persistent);

		// Used by MessagePumpLibevent to take ownership of event_.
		event *ReleaseEvent();

		void set_pump(LibeventMessagePump* pump) { pump_ = pump; }
		LibeventMessagePump* pump() { return pump_; }

		void set_watcher(Watcher *watcher) { watcher_ = watcher; }

		void OnFileCanReadWithoutBlocking(int fd, LibeventMessagePump *pump);
		void OnFileCanWriteWithoutBlocking(int fd, LibeventMessagePump *pump);

		bool is_persistent_;  // false if this event is one-shot.
		event *event_;
		LibeventMessagePump *pump_;
		Watcher *watcher_;
	};

	enum Mode
	{
		WATCH_READ = 1 << 0,
		WATCH_WRITE = 1 << 1,
		WATCH_READ_WRITE = WATCH_READ | WATCH_WRITE
	};


	LibeventMessagePump();
	virtual ~LibeventMessagePump();

	// Have the current thread's message loop watch for a a situation in which
	// reading/writing to the FD can be performed without blocking.
	// Callers must provide a preallocated FileDescriptorWatcher object which
	// can later be used to manage the lifetime of this event.
	// If a FileDescriptorWatcher is passed in which is already attached to
	// an event, then the effect is cumulative i.e. after the call |controller|
	// will watch both the previous event and the new one.
	// If an error occurs while calling this method in a cumulative fashion, the
	// event previously attached to |controller| is aborted.
	// Returns true on success.
	// Must be called on the same thread the message_pump is running on.
	// TODO(dkegel): switch to edge-triggered readiness notification
	bool WatchFileDescriptor(int fd,
		                     bool persistent,
		                     Mode mode,
		                     FileDescriptorWatcher *controller,
		                     Watcher *delegate);

	void AddObserver(IOObserver* obs);
	void RemoveObserver(IOObserver* obs);

	// MessagePump methods:
	virtual void Run(Delegate* delegate);
	virtual void Quit();
	virtual void ScheduleWork();
	virtual void ScheduleDelayedWork(const TimeTicks& delayed_work_time);
    
    // Return the event_base by libevent
    struct event_base* event_base();

private:
	void PreProcessIOEvent();
	void PostProcessIOEvent();

	// Risky part of constructor.  Returns true on success.
	bool Init();

	// Called by libevent to tell us a registered FD can be read/written to.
	static void OnLibeventNotification(int fd, short flags,
		                               void* context);

	// Unix pipe used to implement ScheduleWork()
	// ... callback; called by libevent inside Run() when pipe is ready to read
	static void OnWakeup(int socket, short flags, void* context);

	// This flag is set to false when Run should return.
	bool keep_running_;

	// This flag is set when inside Run.
	bool in_run_;

	// This flag is set if libevent has processed I/O events.
	bool processed_io_events_;

	// The time at which we should call DoDelayedWork.
	TimeTicks delayed_work_time_;

	// Libevent dispatcher.  Watches all sockets registered with it, and sends
	// readiness callbacks when a socket is ready for I/O.
	struct event_base *event_base_;

	// ... write end; ScheduleWork() writes a single byte to it
	int wakeup_pipe_in_;
	// ... read end; OnWakeup reads it and then breaks Run() out of its sleep
	int wakeup_pipe_out_;
	// ... libevent wrapper for read end
	event* wakeup_event_;

	ObserverList<IOObserver> io_observers_;
};

}  // namespace nbase

#endif  // WITH_LIBEVENT && OS_POSIX

#endif  // BASE_FRAMEWORK_LIBEVENT_MESSAGE_PUMP_H_