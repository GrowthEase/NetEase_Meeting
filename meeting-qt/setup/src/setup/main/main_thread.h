/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#pragma once
#include "build/stdafx.h"

class MainThread : public nbase::FrameworkThread
{
public:
	MainThread(bool setup_running, bool yixin_running, bool update, bool autosetup_yixin) : nbase::FrameworkThread("MainThread")
	{
		setup_running_ = setup_running;
		yixin_running_ = yixin_running;
		update_yixin_ = update;
		autosetup_yixin_ = autosetup_yixin;
	}
	virtual ~MainThread() {}

	void EndSession();

private:
	void StartMiscThread();
	void StopMiscThread();
	virtual void Init() override;
	virtual void Cleanup() override;
	void ShowSetupWnd();

	bool setup_running_;	//安装包正在运行
	bool yixin_running_;	//易信正在运行
	bool update_yixin_;		//易信更新正在运行
	bool autosetup_yixin_;	//自动开始安装
};
