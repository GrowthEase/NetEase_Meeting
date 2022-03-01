/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CONTROL_COMBO_H_
#define UI_CONTROL_COMBO_H_

#pragma once

namespace ui {
/////////////////////////////////////////////////////////////////////////////////////
//

class CComboWnd;

class UILIB_API Combo : public Box, public IListOwner
{
    friend class CComboWnd;
public:
    Combo();

    void DoInit();

    std::wstring GetText() const;

    std::wstring GetDropBoxAttributeList();
    void SetDropBoxAttributeList(const std::wstring& pstrList);
    CSize GetDropBoxSize() const;
    void SetDropBoxSize(CSize szDropBox);

    int GetCurSel() const;  
    virtual bool SelectItem(int iIndex, bool bTakeFocus = false, bool bTrigger = true) override;
	void EnsureVisible(const UiRect& rcItem)
	{
	}
    bool SetItemIndex(Control* pControl, std::size_t iIndex);
    virtual bool Add(Control* pControl) override;
	virtual bool AddAt(Control* pControl, std::size_t iIndex) override;
    virtual bool Remove(Control* pControl) override;
    virtual bool RemoveAt(std::size_t iIndex) override;
    virtual void RemoveAll() override;

    virtual void Activate() override;

    UiRect GetTextPadding() const;
    void SetTextPadding(UiRect rc);

    Facade* GetFacade();

    virtual void SetPos(UiRect rc) override;
    virtual void HandleMessage(EventArgs& event) override;
	virtual void HandleMessageTemplate(EventArgs& event) override;
    virtual void SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue) override;
    
	virtual void Paint(HDC hDC, const UiRect& rcPaint) override;
    virtual void PaintText(HDC hDC) override;

protected:
    CComboWnd* m_pWindow = nullptr;
    int m_iCurSel = -1;
    UiRect m_rcTextPadding;
    std::wstring m_sDropBoxAttributes;
    CSize m_szDropBox;
	ControlStateType m_uButtonState = ControlStateType::NORMAL;
	Facade m_Facade;
};

} // namespace ui

#endif // UI_CONTROL_COMBO_H_
