/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2013, NetEase Inc. All rights reserved.
//
// Wang Rongtao <rtwang@corp.netease.com>
// 2013/8/27
//
// This file defines all kinds of tasks

#include "base/framework/task.h"

namespace nbase
{

Task::Task()
{

}

Task::~Task()
{

}

CancelableTask::CancelableTask()
{

}

CancelableTask::~CancelableTask()
{

}

ScopedTaskRunner::ScopedTaskRunner(Task* task) : task_(task)
{

}

ScopedTaskRunner::~ScopedTaskRunner()
{
	if (task_) {
		task_->Run();
		delete task_;
	}
}

Task* ScopedTaskRunner::Release()
{
	Task *temp = task_;
	task_ = nullptr;
	return temp;
}

namespace subtle
{

TaskClosureAdapter::TaskClosureAdapter(Task *task) : task_(task)
{

}

TaskClosureAdapter::~TaskClosureAdapter()
{
	delete task_;
}

void TaskClosureAdapter::Run()
{
	task_->Run();
	delete task_;
	task_ = nullptr;
}

} // namespace subtle

} // namespace nbase