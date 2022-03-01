/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */


#ifndef LICENCE_BOX_H_
#define LICENCE_BOX_H_

#include "build/stdafx.h"


class LicenceForm : public ui::WindowImplBase
{
public:
    enum LicenceType 
	{
		USER_AGREEMENT = 0, 
		PRIVACY_POLICY = 1
	};
    LicenceForm();
	virtual ~LicenceForm();

	static LicenceForm* GetInstance();
    static void setLicenceType(LicenceType type);

public:
	//接口实现
	virtual std::wstring GetSkinFolder() override;
	virtual std::wstring GetSkinFile() override;
	virtual ui::UILIB_RESOURCETYPE GetResourceType() const;
	virtual std::wstring GetZIPFileName() const;
	virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam) override;

public:
	//覆盖虚函数
	virtual std::wstring GetWindowClassName() const override;
	virtual UINT GetClassStyle() const override;
	virtual void OnFinalMessage( HWND hWnd );
	virtual void InitWindow() override;
	virtual bool Notify(ui::EventArgs* msg);

private:
	virtual std::wstring GetWindowId() const;
    std::wstring GetLicenceText();

public:
	static const LPCTSTR kClassName;
	static const LPCTSTR kCheckBoxName;

private:
	std::wstring		edit_text_;	//输入内容
	ui::RichEdit*	    edit_;
    static LicenceType curLicenceType;
};

#endif // LICENCE_BOX_H_
