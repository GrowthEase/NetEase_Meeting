/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef  _SDK_BASE_TASK_INTERFACE_H_
#define _SDK_BASE_TASK_INTERFACE_H_

#include "nipclib/nipclib_export.h"
#include "nipclib/config/build_config.h"

#include <functional>

NIPCLIB_BEGIN_DECLS

using RuntimeCallback = std::function<void()>;
using Task = std::function<void()>;

class ITaskDelegate
{
public:
	virtual void PostTask(const Task& task) = 0;
	virtual void PostHighPriorityTask(const Task& task) = 0;
	virtual void PostDelayTask(int time_block, const Task& task) = 0;
	virtual void PostRepeatTask(int time_block, const Task& task, int times = -1) = 0;
};
class ITaskPostor
{
public:
	ITaskPostor() = default;
	virtual ~ITaskPostor() = default;
public:
	virtual void PostTask(const Task& task) = 0;
	virtual void PostHighPriorityTask(const Task& task) = 0;
	virtual void PostDelayTask(int time_block, const Task& task) = 0;
	virtual void PostRepeatTask(int time_block, const Task& task, int times = -1) = 0;
};
class ITaskLoop : public ITaskPostor
{
public:
	ITaskLoop() = default;
	virtual ~ITaskLoop() = default;
public:
	virtual void SetTaskDelegat(ITaskDelegate* delegate) = 0;
	
};
NIPCLIB_END_DECLS

#endif//_SDK_BASE_TASK_INTERFACE_H_
