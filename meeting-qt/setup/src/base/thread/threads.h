/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef SHARED_THREADS_H_
#define SHARED_THREADS_H_

namespace threading
{

// thread ids
enum ThreadId
{
	kThreadDefault,		//没有实际的线程对应，仅仅作为默认值使用
	kThreadUI,			//UI线程（主线程）
	kThreadMiscGlobal,	//全局Misc线程（执行任务：更新下载时计算文件md5值等）
};

} //namespace threading

#endif // SHARED_THREADS_H_
