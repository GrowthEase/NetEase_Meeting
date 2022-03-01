/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// setup.cpp : 定义应用程序的入口点。
//

#include "build/stdafx.h"
#include <atlbase.h>
#include <shellapi.h>
#include "setup.h"
#include "main/main_thread.h"
#include "main/setup_data.h"
#include "base/util/cmd_line_args.h"

#ifdef _DEBUG
const nbase::LogInterface::Level kDefaultLogLevel = nbase::LogInterface::LV_PRO;
#else
const nbase::LogInterface::Level kDefaultLogLevel = nbase::LogInterface::LV_APP;
#endif
nbase::LogInterface::Level g_log_level = kDefaultLogLevel;

static bool uninstall_begin_ = false;
static std::wstring uninstall_path_;

std::wstring GetAppDataPath()
{
	std::wstring app_data_path = nbase::win32::GetLocalAppDataDir()
		+ CSetupData::GetProductDoc();

	if (!nbase::FilePathIsExist(app_data_path, true)) {
		nbase::CreateDirectory(app_data_path);
	}
	return app_data_path;
}
std::wstring GetLocalTempPath()
{
	std::wstring app_data_path = nbase::win32::GetLocalAppDataDir();
	app_data_path += L"temp\\nim\\~u\\";
	if (!nbase::FilePathIsExist(app_data_path, true)) {
		nbase::CreateDirectory(app_data_path);
	}
	return app_data_path;
}
std::wstring GetLogFilePath()
{
	std::wstring path;
	nbase::FilePathCompose(GetAppDataPath(), L"nim_setup_log.txt", path);

	return path;
}
void InitAppLog()
{
	std::wstring log_file_path = GetLogFilePath();
	std::wstring log_dir_path;
	nbase::FilePathApartDirectory(log_file_path, log_dir_path);
	static const ULONGLONG limit_max = 2 * 1024 * 1024, limit_to = 1024 * 1024;
	nbase::DefHalfLog(log_file_path.c_str(), limit_max, limit_to);

	nbase::DefLogSetOutPath(log_dir_path.c_str());
	nbase::DefLogSetSuffix(L"nim_setup_log");
	nbase::DefLogSetFlag(nbase::LogInterface::LOG_FTYPE_ONLYONE);
#ifdef _DEBUG
	nbase::DefLogSetFlag(nbase::LogInterface::LOG_OUT_DEBUGINFO);
#endif
	nbase::DefLogSetLevel(g_log_level);
}

static bool Init(HINSTANCE hInst)
{
	LOG_APP("app: started");
	InitAppLog();

	return true;
}
void ParseCommandLine()
{
	nbase::CmdLineArgs args;
	for (auto iter = args.begin(); iter != args.end(); iter++) {
		std::wstring cmd = nbase::StringPrintf(L"%s", *iter);
		std::wstring key = L"/uninstall=";
		if (cmd.find(key.c_str()) == 0) {
			uninstall_path_ = cmd.substr(key.size());
			uninstall_begin_ = true;
		}
	}
}

int APIENTRY _tWinMain(_In_ HINSTANCE hInstance,
                     _In_opt_ HINSTANCE hPrevInstance,
                     _In_ LPTSTR    lpCmdLine,
                     _In_ int       nCmdShow)
{
	nbase::AtExitManager at_manager;

	CComModule _Module;
	_Module.Init(NULL, hInstance);

	// CRT都会用到
	_wsetlocale(LC_ALL, L"chs");

#ifdef _DEBUG
	AllocConsole();
	freopen("CONOUT$", "w+t", stdout);
	freopen("CONOUT$", "w+t", stderr);
	wprintf_s(L"cmd string:\n%s\n", lpCmdLine);
#endif

	if (!Init(hInstance))
		return 1;
	ParseCommandLine();
	//bool copy_ret = false;
	if (!uninstall_begin_)
	{
		LOG_APP("------- copy uninstall -------");
		std::wstring cur_file = nbase::win32::GetCurrentModulePathName();
		std::wstring cur_dir = nbase::win32::GetCurrentModuleDirectory();
		std::wstring temp_dir = GetLocalTempPath();
		CSetupData::DeleteOldFile(temp_dir + L"*.*");
		std::wstring dest_file;
		for (int i = 1; i <= 10; i++)
		{
			dest_file = nbase::StringPrintf(L"%s%du.exe", temp_dir.c_str(), i);
			if (nbase::CopyFile(cur_file, dest_file))
			{
				//copy_ret = true;
				std::wstring cmd = nbase::StringPrintf(L"\"/uninstall=%s\"", cur_dir.c_str());
				HINSTANCE inst = ::ShellExecute(NULL, L"open", dest_file.c_str(), cmd.c_str(), NULL, SW_SHOW);
				int ret = (int)inst;
				if (ret > 32)
				{
					LOG_APP(L"start_run %s, %s", dest_file.c_str(), cmd.c_str());
				}
				else
				{
					LOG_ERR(L"start_run %s, %s failed %d", dest_file.c_str(), cmd.c_str(), ret);
				}
				return 0;
			}
		}
		LOG_APP("------- copy uninstall fail -------");
	}
	//if (uninstall_begin_ || !copy_ret)
	{
		LOG_APP("------- start uninstall -------");
		LOG_APP("app: run message loop");

		{
			MainThread thread(uninstall_path_);
			thread.RunOnCurrentThreadWithLoop(nbase::MessageLoop::kUIMessageLoop);
		}

		LOG_APP("app: leave message loop");
	}
	return 0;
}
