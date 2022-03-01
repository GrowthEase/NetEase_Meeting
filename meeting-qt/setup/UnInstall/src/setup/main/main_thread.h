/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#pragma once
#include "build/stdafx.h"

class MainThread : public nbase::FrameworkThread
{
public:
	MainThread(std::wstring install_path) : nbase::FrameworkThread("MainThread")
	{
		install_path_ = install_path;
	}
	virtual ~MainThread() {}

	void EndSession();

private:
	void StartMiscThread();
	void StopMiscThread();
	virtual void Init() override;
	virtual void Cleanup() override;
	void ShowSetupWnd();

	std::wstring install_path_;
};
