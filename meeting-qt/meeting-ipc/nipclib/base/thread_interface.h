/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef  _SDK_BASE_BASE_THREAD_INTERFACE_H_
#define _SDK_BASE_BASE_THREAD_INTERFACE_H_

#include "nipclib/nipclib_export.h"
#include "nipclib/config/build_config.h"
#include <thread>
#include "nipclib/base/task_loop_interface.h"

NIPCLIB_BEGIN_DECLS
using ThreadID = std::thread::id;
class IThread;
class ThreadTLS final
{
	friend IThread;
public:
    using Logger = std::function<void(int, const std::string&)>;
public:
	ThreadTLS() :name_(""), task_loop_(nullptr), logger_(nullptr){

	}
	ThreadTLS(const std::string& name, ITaskLoop* task_loop,const ThreadID id) :
		name_(name), task_loop_(task_loop), id_(id), logger_(nullptr){

	}
    ThreadTLS(const ThreadTLS& tls_data) {
        name_ = tls_data.name_;
        task_loop_ = tls_data.task_loop_;
        id_ = tls_data.id_;
        logger_ = tls_data.logger_;
    }
    const ThreadTLS& operator = (const ThreadTLS& tls_data) {
        name_ = tls_data.name_;
        task_loop_ = tls_data.task_loop_;
        id_ = tls_data.id_;
        logger_ = tls_data.logger_;
        
        return *this;
    }
    
	~ThreadTLS() = default;
public:
	std::string GetName() const {
		return name_;
	}
	ITaskLoop* GetTaskLoop() const{
		return task_loop_;
	}
	ThreadID GetID() const {
		return id_;
	}

    inline Logger GetLogger() const {
        return logger_;
    }

    void SetLogger(Logger logger) {
        logger_ = logger;
    }

private:
	std::string name_;
	ITaskLoop* task_loop_;
	ThreadID id_;
    Logger logger_;
};
class IThread
{
public:	
	IThread() = default;
	virtual ~IThread() = default;
public:	
	static ITaskLoop* GetTaskLoop() {
		return tls_data_ == nullptr ? nullptr : tls_data_->GetTaskLoop();
	}
	static std::string GetName() {
		return tls_data_ == nullptr ? "" : tls_data_->GetName();
	}
	static ThreadID GetID() {
		return tls_data_ == nullptr ? ThreadID() : tls_data_->GetID();
	}
	static ThreadTLS* GetTLSData() {
		return tls_data_;
	}
    static void SetLogger(const ThreadTLS::Logger& log) {
        if (tls_data_ != nullptr)
            tls_data_->SetLogger(log);
    }
    static void Log(int lv, const std::string& text) {
        if (tls_data_ != nullptr && tls_data_->GetLogger() != nullptr)
            tls_data_->GetLogger()(lv,text);
    }
	virtual bool IsRunning() const = 0;
	virtual void AttachBegin(const RuntimeCallback& begin_callback) = 0;
	virtual void AttachEnd(const RuntimeCallback& end_callback) = 0;
	virtual void Start() = 0;
	virtual void Stop() = 0;
	virtual void Join() = 0;
	virtual void AttachCurrentThread() = 0;
	virtual ITaskLoop* TaskLoop() = 0;
	virtual bool IsCurrentThread() = 0;
protected:
	virtual void SetThreadTLS(const ThreadTLS& tls_data) = 0;
protected:
#ifdef WIN32
	static __declspec(thread) ThreadTLS* tls_data_;
#else
	static thread_local ThreadTLS* tls_data_;
#endif
};
NIPCLIB_END_DECLS

#endif//_SDK_BASE_BASE_THREAD_INTERFACE_H_
