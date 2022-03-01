/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */


#ifndef MISC_THREAD_H_
#define MISC_THREAD_H_

#include "base/thread/framework_thread.h"
#include "base/thread/threads.h"

class MiscThread : public nbase::FrameworkThread
{
public:
	MiscThread(threading::ThreadId thread_id, const char *name);
	~MiscThread(void);

private:
	virtual void Init() override;
	virtual void Cleanup() override;

private:
	threading::ThreadId thread_id_;
};
#endif //
