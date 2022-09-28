// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/*
MsgBoxRet ret =	MsgBox(L"TITLE_ID", L"TEXT_ID")
        ->SetIcon(L"warning.png")					//Сͼ
        ->AddButton(L"BUTTON_TEXT_ID")				//Ӱťť1<= N <=3
        ->AddButton(L"BUTTON_TEXT_ID")				//
        ->AddButton(L"BUTTON_TEXT_ID")				//
        ->AsynShow(m_hWnd, cb);						//ʾϢαģ̬ģ̬ʹShowModal
*/
#ifndef MSG_BOX_H_
#define MSG_BOX_H_
#include "build/stdafx.h"

class MsgForm;

//ֵ
enum MsgBoxRet { kMsgBtnClose = 0, kMsgBtn1 = 1, kMsgBtn2 = 2, kMsgBtn3 = 4, kMsgCheck = 64 };

//ͼ
enum MsgBoxIconType { kMsgIconQuestion = 0, kMsgIconTip, kMsgIconWarn, kMsgIconError, kMsgIconOK };

MsgForm* MsgBox();
MsgForm* MsgBox(std::wstring titleID, std::wstring inforID);

class MsgForm : public ui::WindowImplBase {
    struct MsgBoxButton {
        std::wstring text_;  //ı
        bool gray_;          //״̬ͼʽ
    };

public:
    typedef std::function<void(MsgBoxRet)> MsgboxCallback;
    typedef std::function<void(int)> MsgboxCallback2;

    MsgForm();
    virtual ~MsgForm();

public:
    MsgForm* SetTitle(std::wstring titleID);
    MsgForm* SetIcon(MsgBoxIconType type);
    MsgForm* SetInfor(std::wstring inforID, bool is_id = true);
    MsgForm* SetInfor2(std::wstring infor2) {
        infor2_ = infor2;
        return this;
    }
    MsgForm* SetPathInfo(std::wstring path_info) {
        path_info_ = path_info;
        return this;
    }
    MsgForm* SetCheckBox(std::wstring checkID, bool checked = false);
    MsgForm* AddButton(std::wstring strID, bool gray = false);
    int AsynShow(HWND parent_hwnd, const MsgboxCallback& msgbox_callback);
    int AsynShow(HWND parent_hwnd, const MsgboxCallback2& msgbox_callback);  // CheckBoxʹص

public:
    //ӿʵ
    virtual std::wstring GetSkinFolder() override;
    virtual std::wstring GetSkinFile() override;
    virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam) override;

public:
    //麯
    virtual std::wstring GetWindowClassName() const override;
    virtual UINT GetClassStyle() const override;
    virtual void OnFinalMessage(HWND hWnd);
    virtual void InitWindow() override;
    virtual bool Notify(ui::EventArgs* msg);

private:
    std::wstring GetWindowId() const;
    MsgBoxRet ShowModal(HWND hwnd);  //һʹAsynShowҪʹShowModalĻҪΪԪ࣬磺friend MainThread;
    void AdjustContent();            // λ
    void AdjustButtons();            // ťǵλ
    void OnClicked(MsgBoxRet ret);
    void ActiveWindow();

public:
    static const LPCTSTR kClassName;
    static const LPCTSTR kCheckBoxName;

private:
    std::wstring title_;  //ڱ

    MsgBoxIconType icon_;     //ͼ
    std::wstring infor_;      //ʾϢ
    std::wstring path_info_;  //ʾϢ
    std::wstring infor2_;     //ʾϢ
    bool is_use_infor_id_;

    bool has_check_;
    std::wstring check_;  //ѡ
    bool is_checked_;

    MsgBoxButton button_[3];  // 3ť
    int buttons_;             // ť

private:
    // TabKeyManager	 tabkey_manager_;
    MsgboxCallback msgbox_callback_;
    MsgboxCallback2 msgbox_callback2_;
};

#endif  // MSG_BOX_H_
