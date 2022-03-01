/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "misc_thread.h"
#include "base/thread/thread_manager.h"

MiscThread::MiscThread(threading::ThreadId thread_id, const char* name)
	: FrameworkThread(name), thread_id_(thread_id)
{

}

MiscThread::~MiscThread(void)
{

}

void MiscThread::Init()
{
	nbase::ThreadManager::RegisterThread(thread_id_);
}

void MiscThread::Cleanup()
{
	nbase::ThreadManager::UnregisterThread();
}