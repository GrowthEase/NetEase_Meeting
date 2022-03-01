/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CONTROL_LIST_H_
#define UI_CONTROL_LIST_H_

#pragma once
#include "Label.h"
#include "Box/VBox.h"
#include "Box/HBox.h"

namespace ui {
/////////////////////////////////////////////////////////////////////////////////////
//

typedef int (CALLBACK *PULVCompareFunc)(UINT_PTR, UINT_PTR, UINT_PTR);


class Facade
{
public:
	Facade();
	void SetOwner(Box* pOwner) 
	{	
		m_pOwner = pOwner;	
	}
	bool SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue);

	void SetItemFont(int index);
	void SetItemTextStyle(UINT uStyle);
	void SetItemTextPadding(UiRect rc);
	void SetItemTextColor(DWORD dwTextColor);
	
	void SetItemBkColor(ControlStateType stateType, const std::wstring& dwBkColor);
	std::wstring GetItemBkColor(ControlStateType stateType);

	void SetItemStateImage(ControlStateType stateType, const std::wstring& pStrImage);
	std::wstring GetItemStateImage(ControlStateType stateType);

	void SetAlternateBk(bool bAlternate);
	void SetSelectedItemTextColor(DWORD dwTextColor);
	void SetSelectedItemBkColor(const std::wstring& dwBkColor);
	void SetHotItemTextColor(DWORD dwTextColor);
	void SetDisabledItemTextColor(DWORD dwTextColor);
	UiRect GetItemTextPadding() const;
	DWORD GetItemTextColor() const;
	bool IsAlternateBk() const;
	DWORD GetSelectedItemTextColor() const;
	std::wstring GetSelectedItemBkColor() const;
	std::wstring GetSelectedItemImage() const;
	DWORD GetHotItemTextColor() const;
	std::wstring GetHotItemImage() const;
	DWORD GetDisabledItemTextColor() const;
	std::wstring GetDisabledItemImage() const;

public:
	Box* m_pOwner = nullptr;
	int nFont = -1;
	UINT uTextStyle = DT_VCENTER | DT_END_ELLIPSIS;
	UiRect rcTextPadding;
	DWORD dwTextColor = 0xFF000000;
	bool bAlternateBk = false;
	DWORD dwSelectedTextColor = 0xFF000000;
	DWORD dwHotTextColor = 0xFF000000;
	DWORD dwDisabledTextColor = 0xFFCCCCCC;
	StateColorMap m_itemColorMap;
	std::wstring dwSelectedBkColor;
	StateImageMap m_itemImageMap;
};

/////////////////////////////////////////////////////////////////////////////////////
//

class IListOwner
{
public:
    virtual Facade* GetFacade() = 0;
    virtual int GetCurSel() const = 0;
    virtual bool SelectItem(int iIndex, bool bTakeFocus = false, bool bTrigger = true) = 0;
	virtual void HandleMessageTemplate(EventArgs& event) = 0;
	virtual void EnsureVisible(const UiRect& rcItem) = 0;
	virtual void StopScroll() {}
};

class IListItem
{
public:
    virtual int GetIndex() const = 0;
    virtual void SetIndex(int iIndex) = 0;
    virtual IListOwner* GetOwner() = 0;
    virtual void SetOwner(IListOwner* pOwner) = 0;
    virtual bool IsSelected() const = 0;
    virtual bool Select(bool bSelect = true, bool trigger = true) = 0;
    virtual void DrawItemText(HDC hDC, const UiRect& rcItem) = 0;
};


/////////////////////////////////////////////////////////////////////////////////////
//

class UILIB_API ListBox : public ScrollableBox, public IListOwner
{
public:
    ListBox(Layout* pLayout = new VLayout, Facade* facade = new Facade);

	virtual void SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue) override;

	virtual void HandleMessage(EventArgs& event) override;
	
	virtual void HandleMessageTemplate(EventArgs& event) override;

    int GetCurSel() const;
	virtual bool ButtonDown(EventArgs& msg) override;
	virtual void StopScroll() override;
    virtual bool SelectItem(int iIndex, bool bTakeFocus = false, bool bTrigger = true);
	virtual bool ScrollItemToTop(const std::wstring& itemName);
	virtual Control* GetTopItem();
	void EnsureVisible(const UiRect& rcItem);
	bool SetItemIndex(Control* pControl, std::size_t iIndex);

	void Previous(); //选中上一项
	void Next(); //选中下一项
	void ActiveItem(); //触发选中项的 双击 事件

    bool Add(Control* pControl);
    bool AddAt(Control* pControl, int iIndex);
    bool Remove(Control* pControl);
    bool RemoveAt(int iIndex);
    void RemoveAll();

	BOOL SortItems(PULVCompareFunc pfnCompare, UINT_PTR dwData);
	static int __cdecl ItemComareFunc(void *pvlocale, const void *item1, const void *item2);
	int __cdecl ItemComareFunc(const void *item1, const void *item2);

	bool GetScrollSelect();
	void SetScrollSelect(bool bScrollSelect);
	Facade* GetFacade()
	{
		return m_Facade.get();
	}

	void AttachSelect(const EventCallback& callback)
	{
		OnEvent[EventType::SELECT] += callback;
	}

private:
    std::unique_ptr<Facade> m_Facade;
	bool m_bScrollSelect = false;
    int m_iCurSel = -1;
	PULVCompareFunc m_pCompareFunc = nullptr;
	UINT_PTR m_compareData = NULL;
};

/////////////////////////////////////////////////////////////////////////////////////
//

class UILIB_API ListContainerElement : public Box, public IListItem
{
public:
    ListContainerElement();

    int GetIndex() const;
    void SetIndex(int iIndex);

    IListOwner* GetOwner();
    void SetOwner(IListOwner* pOwner);
    void SetVisible(bool bVisible = true);

    bool IsSelected() const;
    bool Select(bool bSelect = true, bool trigger = true) override;

	virtual void Activate() override;
	void InvokeDoubleClickEvent();

    virtual void HandleMessage(EventArgs& event) override;
    void SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue) override;
    void Paint(HDC hDC, const UiRect& rcPaint) override;

    void DrawItemText(HDC hDC, const UiRect& rcItem);    
    void DrawItemBk(HDC hDC, const UiRect& rcItem);


	void AttachClick(const EventCallback& callback)
	{
		OnEvent[EventType::CLICK] += callback;
	}

	void AttachSelect(const EventCallback& callback)
	{
		OnEvent[EventType::SELECT] += callback;
	}

	void AttachUnSelect(const EventCallback& callback)
	{
		OnEvent[EventType::UNSELECT] += callback;
	}

	void AttachDoubleClick(const EventCallback& callback)
	{
		OnEvent[EventType::DOUBLECLICK] += callback;
	}

	void AttachReturn(const EventCallback& callback)
	{
		OnEvent[EventType::RETURN] += callback;
	}

protected:
    int m_iIndex = -1;
    bool m_bSelected = false;
    IListOwner* m_pOwner = nullptr;
};


/////////////////////////////////////////////////////////////////////////////////////
//
//

class UILIB_API CListElementUI : public LabelTemplate<Control>, public IListItem
{
public:
	CListElementUI();

	int GetIndex() const;
	void SetIndex(int iIndex);

	IListOwner* GetOwner();
	void SetOwner(IListOwner* pOwner);
	void SetVisible(bool bVisible = true);

	bool IsSelected() const;
	bool Select(bool bSelect = true, bool trigger = true) override;

	void DrawItemBk(HDC hDC, const UiRect& rcItem);

protected:
	int m_iIndex = -1;
	bool m_bSelected = false;
	IListOwner* m_pOwner = nullptr;
};


/////////////////////////////////////////////////////////////////////////////////////
//

class UILIB_API ListLabelElement : public CListElementUI
{
public:
	ListLabelElement();

	void HandleMessage(EventArgs& event);
	void Paint(HDC hDC, const UiRect& rcPaint) override;

	void DrawItemText(HDC hDC, const UiRect& rcItem);
};




} // namespace ui

#endif // UI_CONTROL_LIST_H_
