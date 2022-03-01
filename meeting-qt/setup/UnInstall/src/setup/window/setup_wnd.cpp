/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "setup_wnd.h"
#include "file_dialog_ex.h"
#include "licence_box.h"
#include "main/main_thread.h"
#include "main/setup_data.h"

const LPCTSTR SetupForm::kClassName = L"SetupForm";
bool SetupForm::destroy_wnd_ = false;
uint32_t SetupForm::pre_progress_pos_ = 0;
SetupForm::SetupForm(std::wstring install_path)
{
	last_setup_path_ = install_path;
	if (last_setup_path_.empty())
	{
		last_setup_path_ = CSetupData::GetLastInstDir();
		if (last_setup_path_.empty())
		{
			last_setup_path_ = nbase::win32::GetCurrentModuleDirectory();
		}
	}
}

SetupForm::~SetupForm()
{
	destroy_wnd_ = true;
}

LRESULT SetupForm::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	if(uMsg == WM_KEYDOWN)
	{
		if(wParam == VK_ESCAPE)
		{
			Close();
			return 1;
		}
	}
	return __super::HandleMessage(uMsg, wParam, lParam);
}

std::wstring SetupForm::GetSkinFolder()
{
	return L"form";
}

std::wstring SetupForm::GetSkinFile()
{
	return L"setup_form.xml";
}

std::wstring SetupForm::GetWindowClassName() const
{
	return kClassName;
}

UINT SetupForm::GetClassStyle() const
{
	return (UI_CLASSSTYLE_FRAME | CS_DBLCLKS);
}

void SetupForm::OnFinalMessage( HWND hWnd )
{
	destroy_wnd_ = true;
	StdClosure cb = std::bind(&SetupForm::OnFinalMessageEx, this, hWnd);
	PostTaskWeakly(cb);
}
void SetupForm::OnFinalMessageEx(HWND hWnd)
{
	MainThread* thread = static_cast<MainThread *>(nbase::FrameworkThread::current());
	if (thread)
	{
		thread->EndSession();
	}
	__super::OnFinalMessage(hWnd);
}

void SetupForm::InitWindow()
{
	m_pRoot->AttachBubbledEvent(ui::EventType::ALL, std::bind(&SetupForm::Notify, this, std::placeholders::_1));
	caption_btn_ = (ui::Box*)FindControl(L"caption_btn");
	box_setup_1_ = (ui::Box*)FindControl(L"setup_1");
	box_setup_2_ = (ui::Box*)FindControl(L"setup_2");
	box_setup_3_ = (ui::Box*)FindControl(L"setup_3");
	progress_ = (ui::Progress*)FindControl(L"progress");
	progress_pos_ = (ui::Label*)FindControl(L"progress_pos");
	check_userdata_ = (ui::CheckBox*)FindControl(L"chkbox_userdata");
}
HRESULT SetupForm::OnClose(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	bHandled = FALSE;
	if (pre_progress_pos_ > 0 && pre_progress_pos_ < 100 && wParam == 0)
	{
		bHandled = TRUE;
		//MsgForm::MsgboxCallback msgbox_cb = [this](MsgBoxRet ret)
		//{
		//	if (!destroy_wnd_ && ret == kMsgBtn1)
		//	{
		//		this->Close(200);
		//	}
		//};
		//MsgBox()->SetTitle(L"STRING_TIPS")->SetInfor(L"STRING_STOP_SETUP_TIP")->SetIcon(kMsgIconWarn)
		//	->AddButton(L"STRING_SETUP_STOP", true)->AddButton(L"STRING_SETUP_AG")
		//	->AsynShow(NULL, ToWeakCallback(msgbox_cb));
	}
	return 0;
}

bool SetupForm::Notify(ui::EventArgs* msg)
{
	std::wstring name = msg->pSender->GetName();
	if(msg->Type == ui::EventType::CLICK) 
	{
		if (name == L"uninstall")
		{
			Setup();
		}
		else if (name == L"cancel")
		{
			Close();
		}
	}
	return true;
}
void SetupForm::Setup()
{
	LOG_APP(L"uninstall path: %s", last_setup_path_.c_str());
	CSetupData::SetInstDir(last_setup_path_);
	box_setup_2_->SetVisible(true);
	box_setup_1_->SetVisible(false);
	caption_btn_->SetVisible(false);
	StdClosure cb = std::bind(&SetupForm::DelFile, this, !check_userdata_->IsSelected());
	PostTaskWeakly(threading::kThreadMiscGlobal, cb);
}
void SetupForm::EndSetupCallback()
{
	if (!destroy_wnd_)
	{
		box_setup_3_->SetVisible(true);
		box_setup_2_->SetVisible(false);
		caption_btn_->SetVisible(true);
	}
}
void SetupForm::ShowProgress(uint32_t pos)
{
	progress_->SetValue(pos);
	std::wstring pos_text = nbase::StringPrintf(L"%d%%", pos);
	progress_pos_->SetText(pos_text);
}