/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

//work MiscThread
#include "setup_wnd.h"
#include "utils/7zDec.h"
#include "Resource.h"
#include "main/setup_data.h"

#include <ShlObj.h>

//开始删除旧文件
void SetupForm::DelFile(bool del_user_data)
{
	LOG_APP(L"DelFile begin");
	LOG_APP(L"Del Link");
	int num = CSetupData::GetDelFileInfoListNum(0);
	for (int i = 0; i < num && !destroy_wnd_; i++)
	{
		CSetupData::DeleteOldFile(i);
		SetProgressCurStepPos(i*PROGRESS_DEL_LINK / num);
	}
	pre_progress_pos_ = PROGRESS_DEL_LINK;
	LOG_APP(L"Del Install Dir");
	num = CSetupData::GetDelFileInfoListNum(1);
	for (int i = 0; i < num && !destroy_wnd_; i++)
	{
		CSetupData::DeleteOldFile(i);
		SetProgressCurStepPos(i*PROGRESS_DEL_INSTALL / num);
	}
	pre_progress_pos_ = PROGRESS_DEL_LINK + PROGRESS_DEL_INSTALL;
	if (del_user_data)
	{
		LOG_APP(L"Del Install userdata");
		num = CSetupData::GetDelFileInfoListNum(2);
		for (int i = 0; i < num && !destroy_wnd_; i++)
		{
			CSetupData::DeleteOldFile(i);
			SetProgressCurStepPos(i*PROGRESS_DEL_USERDATA / num);
		}
	} 
	else
	{
		LOG_APP(L"Not Del Install userdata");
	}
	pre_progress_pos_ = PROGRESS_DEL_LINK + PROGRESS_DEL_INSTALL + PROGRESS_DEL_USERDATA;
	LOG_APP(L"DelFile end");
	StdClosure cb = std::bind(&SetupForm::DelReg, this);
	PostTaskWeakly(threading::kThreadMiscGlobal, cb);
}
//删除注册表
void SetupForm::DelReg()
{
	LOG_APP(L"DelReg begin");
	int num = CSetupData::GetDelRegInfoListNum();
	for (int i = 0; i < num && !destroy_wnd_; i++)
	{
		CSetupData::DeleteRegInfo(i);
		SetProgressCurStepPos(i*PROGRESS_DEL_REG / num);
	}
	pre_progress_pos_ = PROGRESS_DEL_LINK + PROGRESS_DEL_INSTALL + PROGRESS_DEL_USERDATA + PROGRESS_DEL_REG;
	SetProgressCurStepPos(0);
	LOG_APP(L"DelReg end");
	StdClosure cb = std::bind(&SetupForm::EndSetupCallback, this);
	PostTaskWeakly(threading::kThreadUI, cb);
}

void SetupForm::SetProgressCurStepPos(uint32_t pos)
{
	if (!destroy_wnd_)
	{
		uint32_t progress_pos = pre_progress_pos_ + pos;
		StdClosure cb_temp = std::bind(&SetupForm::ShowProgress, this, progress_pos);
		PostTaskWeakly(threading::kThreadUI, cb_temp);
	}
}