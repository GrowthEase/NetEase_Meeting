// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef SETUP_WND_H_
#define SETUP_WND_H_
#include "build/stdafx.h"
#include "msg_box.h"

#define PROGRESS_DEL_LINK 10.0
#define PROGRESS_DEL_INSTALL 80.0
#define PROGRESS_DEL_USERDATA 5.0
#define PROGRESS_DEL_REG 5.0

class SetupForm : public ui::WindowImplBase {
public:
    SetupForm(std::wstring install_path);
    virtual ~SetupForm();

    //ӿʵ
    virtual std::wstring GetSkinFolder() override;
    virtual std::wstring GetSkinFile() override;
    virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam) override;

public:
    //麯
    virtual std::wstring GetWindowClassName() const override;
    virtual UINT GetClassStyle() const override;
    virtual void OnFinalMessage(HWND hWnd) override;
    virtual void InitWindow() override;
    virtual HRESULT OnClose(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled) override;
    virtual bool Notify(ui::EventArgs* msg);

private:
    void OnFinalMessageEx(HWND hWnd);
    //ʼװ
    void Setup();
    //ʼɾļ
    void DelFile(bool del_user_data);
    //ɾע
    void DelReg();
    void EndSetupCallback();
    void SetProgressCurStepPos(uint32_t pos);
    void ShowProgress(uint32_t pos);

private:
    ui::Box* box_setup_1_ = NULL;
    ui::Box* box_setup_2_ = NULL;
    ui::Box* box_setup_3_ = NULL;
    ui::Box* caption_btn_ = NULL;
    ui::Progress* progress_ = NULL;
    ui::Label* progress_pos_ = NULL;
    ui::CheckBox* check_userdata_ = NULL;

    std::wstring last_setup_path_;

    static bool destroy_wnd_;
    static uint32_t pre_progress_pos_;
    static const LPCTSTR kClassName;
};

#endif  // SETUP_WND_H_
