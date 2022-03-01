/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"

namespace ui {
	Facade::Facade()
	{
		::ZeroMemory(&rcTextPadding, sizeof(rcTextPadding));
	}

	bool Facade::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
	{
		bool hasAttribute = true;
		if( pstrName == _T("itemfont") ) nFont = _ttoi(pstrValue.c_str());
		else if( pstrName == _T("itemalign") ) {
			if( pstrValue.find(_T("left")) != std::wstring::npos ) {
				uTextStyle &= ~(DT_CENTER | DT_RIGHT);
				uTextStyle |= DT_LEFT;
			}
			if( pstrValue.find(_T("center")) != std::wstring::npos ) {
				uTextStyle &= ~(DT_LEFT | DT_RIGHT);
				uTextStyle |= DT_CENTER;
			}
			if( pstrValue.find(_T("right")) != std::wstring::npos ) {
				uTextStyle &= ~(DT_LEFT | DT_CENTER);
				uTextStyle |= DT_RIGHT;
			}
		}
		else if( pstrName == _T("itemtextpadding") ) {
			UiRect rcTextPadding;
			LPTSTR pstr = NULL;
			rcTextPadding.left = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
			rcTextPadding.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
			rcTextPadding.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
			rcTextPadding.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
			SetItemTextPadding(rcTextPadding);
		}
		else if( pstrName == _T("itemtextcolor") ) {
			DWORD clrColor = GlobalManager::ConvertTextColor(pstrValue);
			SetItemTextColor(clrColor);
		}
		else if( pstrName == _T("itembkcolor") ) {
			SetItemBkColor(ControlStateType::NORMAL, pstrValue);
		}
		else if( pstrName == _T("itemnoramlimage") ) SetItemStateImage(ControlStateType::NORMAL, pstrValue);
		else if( pstrName == _T("itemaltbk") ) SetAlternateBk(pstrValue == _T("true"));
		else if( pstrName == _T("itemselectedtextcolor") ) {
			DWORD clrColor = GlobalManager::ConvertTextColor(pstrValue);
			SetSelectedItemTextColor(clrColor);
		}
		else if( pstrName == _T("itemselectedbkcolor") ) {
			SetSelectedItemBkColor(pstrValue);
		}
		else if( pstrName == _T("itemselectedimage") ) SetItemStateImage(ControlStateType::PUSHED, pstrValue);
		else if( pstrName == _T("itemhottextcolor") ) {
			DWORD clrColor = GlobalManager::ConvertTextColor(pstrValue);
			SetHotItemTextColor(clrColor);
		}
		else if( pstrName == _T("itemhotbkcolor") ) {
			SetItemBkColor(ControlStateType::HOT, pstrValue);
		}
		else if( pstrName == _T("itemhotimage") ) SetItemStateImage(ControlStateType::HOT, pstrValue);
		else if( pstrName == _T("itemdisabledtextcolor") ) {
			DWORD clrColor = GlobalManager::ConvertTextColor(pstrValue);
			SetDisabledItemTextColor(clrColor);
		}
		else if( pstrName == _T("itemdisabledbkcolor") ) {
			SetItemBkColor(ControlStateType::DISABLED, pstrValue);
		}
		else if( pstrName == _T("itemdisabledimage") ) SetItemStateImage(ControlStateType::DISABLED, pstrValue);
		else
		{
			hasAttribute = false;
		}

		return hasAttribute;
	}

	void Facade::SetItemFont(int index)
	{
		nFont = index;
		m_pOwner->Arrange();
	}

	void Facade::SetItemTextStyle(UINT uStyle)
	{
		uTextStyle = uStyle;
		m_pOwner->Arrange();
	}

	void Facade::SetItemTextPadding(UiRect rc)
	{
		rcTextPadding = rc;
		m_pOwner->Arrange();
	}

	UiRect Facade::GetItemTextPadding() const
	{
		return rcTextPadding;
	}

	void Facade::SetItemTextColor(DWORD dwTextColor)
	{
		dwTextColor = dwTextColor;
		m_pOwner->Invalidate();
	}

	void Facade::SetItemBkColor(ControlStateType stateType, const std::wstring& dwColor)
	{
		m_itemColorMap[stateType] = dwColor;
		m_pOwner->Invalidate();
	}

	std::wstring Facade::GetItemBkColor(ControlStateType stateType)
	{
		return m_itemColorMap[stateType];
	}

	void Facade::SetItemStateImage(ControlStateType stateType, const std::wstring& pStrImage)
	{
		m_itemImageMap[stateType].SetImageString(pStrImage);
		m_pOwner->Invalidate();
	}

	std::wstring Facade::GetItemStateImage(ControlStateType stateType) 
	{
		return m_itemImageMap[stateType].imageAttribute.imageString;
	}

	void Facade::SetAlternateBk(bool bAlternate)
	{
		bAlternateBk = bAlternate;
		m_pOwner->Invalidate();
	}

	DWORD Facade::GetItemTextColor() const
	{
		return dwTextColor;
	}

	bool Facade::IsAlternateBk() const
	{
		return bAlternateBk;
	}

	void Facade::SetSelectedItemTextColor(DWORD dwTextColor)
	{
		dwSelectedTextColor = dwTextColor;
		m_pOwner->Invalidate();
	}

	void Facade::SetSelectedItemBkColor(const std::wstring& dwColor)
	{
		dwSelectedBkColor = dwColor;
		m_pOwner->Invalidate();
	}

	DWORD Facade::GetSelectedItemTextColor() const
	{
		return dwSelectedTextColor;
	}


	std::wstring Facade::GetSelectedItemBkColor() const
	{
		return dwSelectedBkColor;
	}

	void Facade::SetHotItemTextColor(DWORD dwTextColor)
	{
		dwHotTextColor = dwTextColor;
		m_pOwner->Invalidate();
	}

	DWORD Facade::GetHotItemTextColor() const
	{
		return dwHotTextColor;
	}

	void Facade::SetDisabledItemTextColor(DWORD dwTextColor)
	{
		dwDisabledTextColor = dwTextColor;
		m_pOwner->Invalidate();
	}

	DWORD Facade::GetDisabledItemTextColor() const
	{
		return dwDisabledTextColor;
	}

/////////////////////////////////////////////////////////////////////////////////////
//

	ListBox::ListBox(Layout* pLayout, Facade* facade) : 
		ScrollableBox(pLayout),
		m_Facade(facade)
	{
		m_Facade->SetOwner(this);
	}


	void ListBox::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
	{
		if (m_Facade->SetAttribute(pstrName, pstrValue))
		{

		}
		else if( pstrName == _T("scrollselect") ) 
		{
			SetScrollSelect(pstrValue == _T("true"));
		}
		else
		{
			ScrollableBox::SetAttribute(pstrName, pstrValue);
		}
	}

	bool ListBox::SetItemIndex(Control* pControl, std::size_t iIndex)
	{
		int iOrginIndex = GetItemIndex(pControl);
		if( iOrginIndex == -1 ) return false;
		if( iOrginIndex == (int)iIndex ) return true;

		IListItem* pSelectedListItem = NULL;
		if( m_iCurSel >= 0 ) pSelectedListItem = 
			dynamic_cast<IListItem*>(GetItemAt(m_iCurSel));
		if( !ScrollableBox::SetItemIndex(pControl, iIndex) ) return false;
		std::size_t iMinIndex = min((std::size_t)iOrginIndex, iIndex);
		std::size_t iMaxIndex = max((std::size_t)iOrginIndex, iIndex);
		for(std::size_t i = iMinIndex; i < iMaxIndex + 1; ++i) {
			Control* p = GetItemAt(i);
			IListItem* pListItem = dynamic_cast<IListItem*>(p);
			if( pListItem != NULL ) {
				pListItem->SetIndex(i);
			}
		}
		if( m_iCurSel >= 0 && pSelectedListItem != NULL ) m_iCurSel = pSelectedListItem->GetIndex();
		return true;
	}

	void ListBox::Previous()
	{
		if (m_iCurSel > 0)
		{
			SelectItem(m_iCurSel - 1);
		}
	}

	void ListBox::Next()
	{
		int count = GetCount();
		if (m_iCurSel < count - 1)
		{
			SelectItem(m_iCurSel + 1);
		}
	}

	void ListBox::ActiveItem()
	{
		if (m_iCurSel >= 0)
		{
			ListContainerElement* item = dynamic_cast<ListContainerElement*>( GetItemAt(m_iCurSel) );
			item->InvokeDoubleClickEvent();
		}
	}

	void ListBox::HandleMessage(EventArgs& event)
	{
		if( !IsMouseEnabled() && event.Type > EventType::MOUSEBEGIN && event.Type < EventType::MOUSEEND ) {
			if( m_pParent != NULL ) m_pParent->HandleMessageTemplate(event);
			else ScrollableBox::HandleMessage(event);
			return;
		}

		switch( event.Type ) {
		case EventType::BUTTONDOWN:
		case EventType::BUTTONUP:
			{
				return;
			}
		case EventType::KEYDOWN:
			switch( event.chKey ) {
			case VK_UP:
				SelectItem(FindSelectable(m_iCurSel - 1, false), true);
				return;
			case VK_DOWN:
				SelectItem(FindSelectable(m_iCurSel + 1, true), true);
				return;
			case VK_HOME:
				SelectItem(FindSelectable(0, false), true);
				return;
			case VK_END:
				SelectItem(FindSelectable(GetCount() - 1, true), true);
				return;
			}
			break;
		case EventType::SCROLLWHEEL:
			{
				int detaValue = event.wParam;
				if (detaValue > 0) {
					if( m_bScrollSelect ) {
						SelectItem(FindSelectable(m_iCurSel - 1, false), true);
						return;
					}
					break;
				}
				else {
					if( m_bScrollSelect ) {
						SelectItem(FindSelectable(m_iCurSel + 1, true), true);
						return;
					}
					break;
				}
			}
			break;
		}
		ScrollableBox::HandleMessage(event);
	}

	void ListBox::HandleMessageTemplate(EventArgs& event)
	{
		ScrollableBox::HandleMessageTemplate(event);
	}

	void ListBox::EnsureVisible(const UiRect& rcItem)
	{
		UiRect rcNewItem = rcItem;
		rcNewItem.Offset(-GetScrollPos().cx, -GetScrollPos().cy);
		UiRect rcList = GetPos();
		UiRect rcListInset = m_pLayout->GetPadding();

		rcList.left += rcListInset.left;
		rcList.top += rcListInset.top;
		rcList.right -= rcListInset.right;
		rcList.bottom -= rcListInset.bottom;

		//ScrollBar* pVerticalScrollBar = GetVerticalScrollBar();
		//if( pVerticalScrollBar && pVerticalScrollBar->IsVisible() ) rcList.right -= pVerticalScrollBar->GetFixedWidth();
		ScrollBar* pHorizontalScrollBar = GetHorizontalScrollBar();
		if( pHorizontalScrollBar && pHorizontalScrollBar->IsVisible() ) rcList.bottom -= pHorizontalScrollBar->GetFixedHeight();


		if( rcNewItem.left >= rcList.left && rcNewItem.top >= rcList.top 
			&& rcNewItem.right <= rcList.right && rcNewItem.bottom <= rcList.bottom) 
		{
			if (m_pParent && dynamic_cast<ListContainerElement*>(m_pParent) != NULL)
			{
				dynamic_cast<ListContainerElement*>(m_pParent)->GetOwner()->EnsureVisible(rcNewItem);
			}
			return;
		}

		int dx = 0;
		if( rcNewItem.left < rcList.left ) dx = rcNewItem.left - rcList.left;
		if( rcNewItem.right > rcList.right ) dx = rcNewItem.right - rcList.right;
		int dy = 0;
		if( rcNewItem.top < rcList.top ) dy = rcNewItem.top - rcList.top;
		if( rcNewItem.bottom > rcList.bottom ) dy = rcNewItem.bottom - rcList.bottom;

		CSize sz = GetScrollPos();
		SetScrollPos(CSize(sz.cx + dx, sz.cy + dy));
	}

	bool ListBox::Add(Control* pControl)
	{
		// Override the Add() method so we can add items specifically to
		// the intended widgets. Headers are assumed to be
		// answer the correct interface so we can add multiple list headers.
		// The list items should know about us
		IListItem* pListItem = dynamic_cast<IListItem*>(pControl);
		if( pListItem != NULL ) {
			pListItem->SetOwner(this);
			pListItem->SetIndex(GetCount());
		}
		return ScrollableBox::Add(pControl);
	}

	bool ListBox::AddAt(Control* pControl, int iIndex)
	{
		// Override the AddAt() method so we can add items specifically to
		// the intended widgets. Headers and are assumed to be
		// answer the correct interface so we can add multiple list headers.

		if (!ScrollableBox::AddAt(pControl, iIndex)) return false;

		// The list items should know about us
		IListItem* pListItem = dynamic_cast<IListItem*>(pControl);
		if( pListItem != NULL ) {
			pListItem->SetOwner(this);
			pListItem->SetIndex(iIndex);
		}

		for(int i = iIndex + 1; i < GetCount(); ++i) {
			Control* p = GetItemAt(i);
			pListItem = dynamic_cast<IListItem*>(p);
			if( pListItem != NULL ) {
				pListItem->SetIndex(i);
			}
		}
		if( m_iCurSel >= iIndex ) m_iCurSel += 1;
		return true;
	}

	bool ListBox::Remove(Control* pControl)
	{
		int iIndex = GetItemIndex(pControl);
		if (iIndex == -1) return false;

		return RemoveAt(iIndex);
	}

	bool ListBox::RemoveAt(int iIndex)
	{
		if (!ScrollableBox::RemoveAt(iIndex)) return false;

		for(int i = iIndex; i < GetCount(); ++i) {
			Control* p = GetItemAt(i);
			IListItem* pListItem = dynamic_cast<IListItem*>(p);
			if( pListItem != NULL ) pListItem->SetIndex(i);
		}

		if( iIndex == m_iCurSel && m_iCurSel >= 0 ) {
			int iSel = m_iCurSel;
			m_iCurSel = -1;
			SelectItem(FindSelectable(iSel, false));
		}
		else if( iIndex < m_iCurSel ) m_iCurSel -= 1;
		return true;
	}

	void ListBox::RemoveAll()
	{
		m_iCurSel = -1;
		ScrollableBox::RemoveAll();
	}

	BOOL ListBox::SortItems(PULVCompareFunc pfnCompare, UINT_PTR dwData)
	{
		if (!pfnCompare)
			return FALSE;
		
		if (m_items.size() == 0)
		{
			return true;
		}

		m_pCompareFunc = pfnCompare;
		qsort_s(&(*m_items.begin()), m_items.size(), sizeof(Control*), ListBox::ItemComareFunc, this);	
		IListItem *pItem = NULL;
		for (std::size_t i = 0; i < m_items.size(); ++i)
		{
			pItem = dynamic_cast<IListItem*>(static_cast<Control*>(m_items[i]));
			if (pItem)
			{
				pItem->SetIndex(i);
				pItem->Select(false);
			}
		}
		SelectItem(-1);
		SetPos(GetPos());
		Invalidate();

		return TRUE;
	}

	int __cdecl ListBox::ItemComareFunc(void *pvlocale, const void *item1, const void *item2)
	{
		ListBox *pThis = (ListBox*)pvlocale;
		if (!pThis || !item1 || !item2)
			return 0;
		return pThis->ItemComareFunc(item1, item2);
	}

	int __cdecl ListBox::ItemComareFunc(const void *item1, const void *item2)
	{
		Control *pControl1 = *(Control**)item1;
		Control *pControl2 = *(Control**)item2;
		return m_pCompareFunc((UINT_PTR)pControl1, (UINT_PTR)pControl2, m_compareData);
	}

	int ListBox::GetCurSel() const
	{
		return m_iCurSel;
	}

	bool ListBox::ButtonDown(EventArgs& msg)
	{
		bool ret = __super::ButtonDown(msg);
		StopScroll();
		
		return ret;
	}

	void ListBox::StopScroll()
	{
		m_scrollAnimation.Reset();
	}

	bool ListBox::SelectItem(int iIndex, bool bTakeFocus, bool bTrigger)
	{
		if( iIndex == m_iCurSel ) return true;

		int iOldSel = m_iCurSel;
		// We should first unselect the currently selected item
		if( m_iCurSel >= 0 ) {
			Control* pControl = GetItemAt(m_iCurSel);
			if( pControl != NULL) {
				IListItem* pListItem = dynamic_cast<IListItem*>(pControl);
				if( pListItem != NULL ) pListItem->Select(false, bTrigger);
			}

			m_iCurSel = -1;
		}
		if( iIndex < 0 ) return false;

		Control* pControl = GetItemAt(iIndex);
		if( pControl == NULL ) return false;
		if( !pControl->IsVisible() ) return false;
		if( !pControl->IsEnabled() ) return false;

		IListItem* pListItem = dynamic_cast<IListItem*>(pControl);
		if( pListItem == NULL ) return false;
		m_iCurSel = iIndex;
		if( !pListItem->Select(true, bTrigger) ) {
			m_iCurSel = -1;
			return false;
		}
		if (GetItemAt(m_iCurSel))
		{
			UiRect rcItem = GetItemAt(m_iCurSel)->GetPos();
			EnsureVisible(rcItem);
		}
		if( bTakeFocus ) pControl->SetFocus();
		if( m_pWindow != NULL && bTrigger) {
			m_pWindow->SendNotify(this, EventType::SELECT, m_iCurSel, iOldSel);
		}

		return true;
	}

	bool ListBox::ScrollItemToTop(const std::wstring& itemName)
	{
		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			if ((*it)->GetName() == itemName) {
				if (GetScrollRange().cy != 0) {
					CSize scrollPos = GetScrollPos();
					scrollPos.cy = (*it)->GetPos().top - m_pLayout->GetInternalPos().top;
					if (scrollPos.cy >= 0) {
						SetScrollPos(scrollPos);
						return true;
					}
					else {
						return false;
					}
				}
				else {
					return false;
				}
			}
		}

		return false;
	}

	Control* ListBox::GetTopItem()
	{
		int listTop = GetPos().top + m_pLayout->GetPadding().top + GetScrollPos().cy;
		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			if ((*it)->IsVisible() && !(*it)->IsFloat() && (*it)->GetPos().bottom >= listTop) {
				return (*it);
			}
		}

		return nullptr;
	}

	bool ListBox::GetScrollSelect()
	{
		return m_bScrollSelect;
	}

	void ListBox::SetScrollSelect(bool bScrollSelect)
	{
		m_bScrollSelect = bScrollSelect;
	}

/////////////////////////////////////////////////////////////////////////////////////
//
//

ListContainerElement::ListContainerElement()
{

}

IListOwner* ListContainerElement::GetOwner()
{
    return m_pOwner;
}

void ListContainerElement::SetOwner(IListOwner* pOwner)
{
    m_pOwner = pOwner;
}

void ListContainerElement::SetVisible(bool bVisible)
{
    Box::SetVisible(bVisible);
    if( !IsVisible() && m_bSelected)
    {
        m_bSelected = false;
        if( m_pOwner != NULL ) m_pOwner->SelectItem(-1);
    }
}

int ListContainerElement::GetIndex() const
{
    return m_iIndex;
}

void ListContainerElement::SetIndex(int iIndex)
{
    m_iIndex = iIndex;
}

bool ListContainerElement::IsSelected() const
{
    return m_bSelected;
}

bool ListContainerElement::Select(bool bSelect, bool trigger)
{
    if( !IsEnabled() ) return false;
    //if( bSelect == m_bSelected ) return true;
    m_bSelected = bSelect;
    if( bSelect && m_pOwner != NULL ) m_pOwner->SelectItem(m_iIndex, false, trigger);
    Invalidate();
	if (trigger) {
		if (bSelect) {
			m_pWindow->SendNotify(this, EventType::SELECT);
		}
		else {
			m_pWindow->SendNotify(this, EventType::UNSELECT);
		}
	}

    return true;
}

void ListContainerElement::Activate()
{
	Select();
	m_pWindow->SendNotify(this, EventType::CLICK);
}

void ListContainerElement::InvokeDoubleClickEvent()
{
	if( m_pWindow != NULL ) m_pWindow->SendNotify(this, EventType::DOUBLECLICK);
}

void ListContainerElement::HandleMessage(EventArgs& event)
{
    if( !IsMouseEnabled() && event.Type > EventType::MOUSEBEGIN && event.Type < EventType::MOUSEEND ) {
        if( m_pOwner != NULL ) m_pOwner->HandleMessageTemplate(event);
        else Box::HandleMessage(event);
        return;
    }
	else if( event.Type == EventType::INTERNAL_DBLCLICK ) {
		if( IsActivatable() ) {
			InvokeDoubleClickEvent();
		}
        return;
    }
    else if( event.Type == EventType::KEYDOWN && IsEnabled() ) {
        if( event.chKey == VK_RETURN ) {
			if( IsActivatable() ) {
				if( m_pWindow != NULL ) m_pWindow->SendNotify(this, EventType::RETURN);
			}
            return;
        }
    }
	else if (event.Type == EventType::INTERNAL_CONTEXTMENU && IsEnabled()) {
		Select();
		m_pWindow->SendNotify(this, EventType::MENU);
		Invalidate();

		return;
	}

	Box::HandleMessage(event);


    // An important twist: The list-item will send the event not to its immediate
    // parent but to the "attached" list. A list may actually embed several components
    // in its path to the item, but key-presses etc. needs to go to the actual list.
    //if( m_pOwner != NULL ) m_pOwner->HandleMessage(event); else Control::HandleMessage(event);
}

void ListContainerElement::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
{
    if( pstrName == _T("selected") ) Select();
    else Box::SetAttribute(pstrName, pstrValue);
}

void ListContainerElement::Paint(HDC hDC, const UiRect& rcPaint)
{
    if( !::IntersectRect(&m_rcPaint, &rcPaint, &m_rcItem) ) return;
    DrawItemBk(hDC, m_rcItem);
    Box::Paint(hDC, rcPaint);
}

void ListContainerElement::DrawItemText(HDC hDC, const UiRect& rcItem)
{
    return;
}

void ListContainerElement::DrawItemBk(HDC hDC, const UiRect& rcItem)
{
    //ASSERT(m_pOwner);
    if( m_pOwner == NULL ) return;
    Facade* pInfo = m_pOwner->GetFacade();
    std::wstring iBackColor;

	if (IsSelected() || m_uButtonState == ControlStateType::PUSHED) {
		iBackColor = pInfo->dwSelectedBkColor;
		RenderEngine::DrawColor(hDC, m_rcItem, iBackColor);
	}
	else {
		if( m_uButtonState == ControlStateType::NORMAL ) {
			if( !pInfo->bAlternateBk || m_iIndex % 2 == 0 ) 
			{
				pInfo->m_itemColorMap.PaintStatusColor(hDC, m_rcItem, m_uButtonState);
			}
		}
		else {
			pInfo->m_itemColorMap.PaintStatusColor(hDC, m_rcItem, m_uButtonState);
		}
	}

    if( !IsEnabled() ) {
        if( !DrawImage(hDC, pInfo->m_itemImageMap[ControlStateType::DISABLED]) ) {

		}
        else return;
    }

    if( IsSelected() || m_uButtonState == ControlStateType::PUSHED ) {
		if( !DrawImage(hDC, pInfo->m_itemImageMap[ControlStateType::PUSHED]) ) {

		}
		else return;
    }

    if( m_uButtonState == ControlStateType::HOT ) {
        if( !DrawImage(hDC, pInfo->m_itemImageMap[ControlStateType::HOT]) ) {

		}
        else return;
    }

	if( !pInfo->bAlternateBk || m_iIndex % 2 == 0 ) {
		if( !DrawImage(hDC, pInfo->m_itemImageMap[ControlStateType::NORMAL]) ) {

		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////
//
//

CListElementUI::CListElementUI()
{
	m_cxyFixed.cx = m_cxyFixed.cy = DUI_LENGTH_STRETCH;
}

IListOwner* CListElementUI::GetOwner()
{
	return m_pOwner;
}

void CListElementUI::SetOwner(IListOwner* pOwner)
{
	m_pOwner = pOwner;
}

void CListElementUI::SetVisible(bool bVisible)
{
	Label::SetVisible(bVisible);
	if( !IsVisible() && m_bSelected)
	{
		m_bSelected = false;
		if( m_pOwner != NULL ) m_pOwner->SelectItem(-1);
	}
}

int CListElementUI::GetIndex() const
{
	return m_iIndex;
}

void CListElementUI::SetIndex(int iIndex)
{
	m_iIndex = iIndex;
}

bool CListElementUI::IsSelected() const
{
	return m_bSelected;
}

bool CListElementUI::Select(bool bSelect, bool trigger)
{
	if( !IsEnabled() ) return false;
	if( bSelect == m_bSelected ) return true;
	m_bSelected = bSelect;
	if( bSelect && m_pOwner != NULL ) m_pOwner->SelectItem(m_iIndex);
	Invalidate();

	return true;
}

void CListElementUI::DrawItemBk(HDC hDC, const UiRect& rcItem)
{
	ASSERT(m_pOwner);
	if( m_pOwner == NULL ) return;
	Facade* pInfo = m_pOwner->GetFacade();
	std::wstring iBackColor;

	if (IsSelected() || m_uButtonState == ControlStateType::PUSHED) {
		iBackColor = pInfo->dwSelectedBkColor;
		RenderEngine::DrawColor(hDC, m_rcItem, iBackColor);
	}
	else {
		if( m_uButtonState == ControlStateType::NORMAL ) {
			if( !pInfo->bAlternateBk || m_iIndex % 2 == 0 ) 
			{
				pInfo->m_itemColorMap.PaintStatusColor(hDC, m_rcItem, m_uButtonState);
			}
		}
		else {
			pInfo->m_itemColorMap.PaintStatusColor(hDC, m_rcItem, m_uButtonState);
		}
	}

	if( !IsEnabled() ) {
		if( !DrawImage(hDC, pInfo->m_itemImageMap[ControlStateType::DISABLED]) ) {

		}
		else return;
	}

	if( IsSelected() || m_uButtonState == ControlStateType::PUSHED ) {
		if( !DrawImage(hDC, pInfo->m_itemImageMap[ControlStateType::PUSHED]) ) {

		}
		else return;
	}

	if( m_uButtonState == ControlStateType::HOT ) {
		if( !DrawImage(hDC, pInfo->m_itemImageMap[ControlStateType::HOT]) ) {

		}
		else return;
	}

	if( !pInfo->bAlternateBk || m_iIndex % 2 == 0 ) {
		if( !DrawImage(hDC, pInfo->m_itemImageMap[ControlStateType::NORMAL]) ) {

		}
	}

}

/////////////////////////////////////////////////////////////////////////////////////
//
//

ListLabelElement::ListLabelElement()
{
	m_cxyFixed.cy = DUI_LENGTH_AUTO;
}

void ListLabelElement::HandleMessage(EventArgs& event)
{
	if( !IsMouseEnabled() && event.Type > EventType::MOUSEBEGIN && event.Type < EventType::MOUSEEND ) {
		if( m_pOwner != NULL ) m_pOwner->HandleMessageTemplate(event);
		else CListElementUI::HandleMessage(event);
		return;
	}

	if( event.Type == EventType::BUTTONDOWN || event.Type == EventType::RBUTTONDOWN )
	{
		if( IsEnabled() ) {
			m_pWindow->SendNotify(this, EventType::CLICK);
			Select();
			Invalidate();
		}
		return;
	}
	if( event.Type == EventType::MOUSEMOVE ) 
	{
		return;
	}
	if( event.Type == EventType::BUTTONUP )
	{
		return;
	}

	CListElementUI::HandleMessage(event);
}

void ListLabelElement::Paint(HDC hDC, const UiRect& rcPaint)
{
	if( !::IntersectRect(&m_rcPaint, &rcPaint, &m_rcItem) ) return;
	DrawItemBk(hDC, m_rcItem);
	DrawItemText(hDC, m_rcItem);
}

void ListLabelElement::DrawItemText(HDC hDC, const UiRect& rcItem)
{
	if( GetText().empty() ) return;

	if( m_pOwner == NULL ) return;
	Facade* pInfo = m_pOwner->GetFacade();
	DWORD iTextColor = pInfo->dwTextColor;
	if( m_uButtonState == ControlStateType::HOT ) {
		iTextColor = pInfo->dwHotTextColor;
	}
	if( IsSelected() ) {
		iTextColor = pInfo->dwSelectedTextColor;
	}
	if( !IsEnabled() ) {
		iTextColor = pInfo->dwDisabledTextColor;
	}
	UiRect rcText = rcItem;
	rcText.left += pInfo->rcTextPadding.left;
	rcText.right -= pInfo->rcTextPadding.right;
	rcText.top += pInfo->rcTextPadding.top;
	rcText.bottom -= pInfo->rcTextPadding.bottom;

	RenderEngine::DrawText(hDC, rcText, GetText(), iTextColor, \
		pInfo->nFont, DT_SINGLELINE | pInfo->uTextStyle);
}

} // namespace ui
