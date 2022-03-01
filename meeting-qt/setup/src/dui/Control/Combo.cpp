/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"

namespace ui {

/////////////////////////////////////////////////////////////////////////////////////
//
//

class CComboWnd : public Window
{
public:
    void Init(Combo* pOwner);
    std::wstring GetWindowClassName() const;
    void OnFinalMessage(HWND hWnd);

    LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam) override;

    void EnsureVisible(int iIndex);
    void Scroll(int dx, int dy);


	virtual UINT GetClassStyle() const;

public:
    Window m_pm;
    Combo* m_pOwner;
    ScrollableBox* m_pLayout;
    int m_iOldSel;
};


void CComboWnd::Init(Combo* pOwner)
{
    m_pOwner = pOwner;
    m_pLayout = NULL;
    m_iOldSel = m_pOwner->GetCurSel();

    // Position the popup window in absolute space
    CSize szDrop = m_pOwner->GetDropBoxSize();
    UiRect rcOwner = pOwner->GetPosWithScrollOffset();
    UiRect rc = rcOwner;
    rc.top = rc.bottom + 1;		// 父窗口left、bottom位置作为弹出窗口起点
    rc.bottom = rc.top + szDrop.cy;	// 计算弹出窗口高度
    if( szDrop.cx > 0 ) rc.right = rc.left + szDrop.cx;	// 计算弹出窗口宽度

    CSize szAvailable = { rc.right - rc.left, rc.bottom - rc.top };
    int cyFixed = 0;
    for( int it = 0; it < pOwner->GetCount(); it++ ) {
        Control* pControl = static_cast<Control*>(pOwner->GetItemAt(it));
        if( !pControl->IsVisible() ) continue;
        CSize sz = pControl->EstimateSize(szAvailable);
        cyFixed += sz.cy;
    }
    cyFixed += 2; // VBox 默认的Padding 调整
    rc.bottom = rc.top + MIN(cyFixed, szDrop.cy);

    ::MapWindowRect(pOwner->GetWindow()->GetHWND(), HWND_DESKTOP, &rc);

    MONITORINFO oMonitor = {};
    oMonitor.cbSize = sizeof(oMonitor);
    ::GetMonitorInfo(::MonitorFromWindow(GetHWND(), MONITOR_DEFAULTTOPRIMARY), &oMonitor);
    UiRect rcWork = oMonitor.rcWork;
    if( rc.bottom > rcWork.bottom ) {
        rc.left = rcOwner.left;
        rc.right = rcOwner.right;
        if( szDrop.cx > 0 ) rc.right = rc.left + szDrop.cx;
        rc.top = rcOwner.top - MIN(cyFixed, szDrop.cy);
        rc.bottom = rcOwner.top;
        ::MapWindowRect(pOwner->GetWindow()->GetHWND(), HWND_DESKTOP, &rc);
    }
    
    Create(pOwner->GetWindow()->GetHWND(), NULL, WS_POPUP, WS_EX_TOOLWINDOW, true, rc);
    // HACK: Don't deselect the parent's caption
    HWND hWndParent = m_hWnd;
    while( ::GetParent(hWndParent) != NULL ) hWndParent = ::GetParent(hWndParent);
    ::ShowWindow(m_hWnd, SW_SHOW);
    ::SendMessage(hWndParent, WM_NCACTIVATE, TRUE, 0L);
}

std::wstring CComboWnd::GetWindowClassName() const
{
    return _T("ComboWnd");
}

void CComboWnd::OnFinalMessage(HWND hWnd)
{
    m_pOwner->m_pWindow = NULL;
    m_pOwner->m_uButtonState = ControlStateType::NORMAL;
    m_pOwner->Invalidate();
    delete this;
}

LRESULT CComboWnd::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    if( uMsg == WM_CREATE ) {
        m_pm.Init(m_hWnd);
        // The trick is to add the items to the new container. Their owner gets
        // reassigned by this operation - which is why it is important to reassign
        // the items back to the righfull owner/manager when the window closes.
        m_pLayout = new ScrollableBox(new VLayout);
        //m_pm.UseParentResource(m_pOwner->GetWindow());
        m_pLayout->SetWindow(&m_pm, NULL, true);
        m_pLayout->GetLayout()->SetPadding(UiRect(1, 1, 1, 1));
        m_pLayout->SetBkColor(L"bk_wnd_lightcolor");
        m_pLayout->SetBorderColor(L"combobox_border");
        m_pLayout->SetBorderSize(UiRect(1, 1, 1, 1));
        m_pLayout->SetAutoDestroy(false);
        m_pLayout->EnableScrollBar();
        m_pLayout->ApplyAttributeList(m_pOwner->GetDropBoxAttributeList());
        for( int i = 0; i < m_pOwner->GetCount(); i++ ) {
            m_pLayout->Add(static_cast<Control*>(m_pOwner->GetItemAt(i)));
        }
        m_pm.AttachDialog(m_pLayout);
        m_pm.SetWindowResourcePath(m_pOwner->GetWindow()->GetWindowResourcePath());
		m_pm.SetShadowAttached(false);
        return 0;
    }
    else if( uMsg == WM_CLOSE ) {
        m_pOwner->SetWindow(m_pOwner->GetWindow(), m_pOwner->GetParent(), false);
        m_pOwner->SetPos(m_pOwner->GetPos());
        m_pOwner->SetFocus();
    }
    else if( uMsg == WM_LBUTTONUP ) {
        POINT pt = { 0 };
        ::GetCursorPos(&pt);
        ::ScreenToClient(m_pm.GetHWND(), &pt);
        Control* pControl = m_pm.FindControl(pt);
        if( pControl && typeid(*pControl) != typeid(ScrollBar) ) PostMessage(WM_KILLFOCUS);
    }
    else if( uMsg == WM_KEYDOWN ) {
        switch( wParam ) {
        case VK_ESCAPE:
            m_pOwner->SelectItem(m_iOldSel, true);
            EnsureVisible(m_iOldSel);
            // FALL THROUGH...
        case VK_RETURN:
            PostMessage(WM_KILLFOCUS);
            break;
        default:
			m_pOwner->Control::HandleMessageTemplate(EventType::KEYDOWN, wParam, lParam, wParam);
            EnsureVisible(m_pOwner->GetCurSel());
            return 0;
        }
    }
    else if( uMsg == WM_MOUSEWHEEL ) {
        int zDelta = (int) (short) HIWORD(wParam);
		m_pOwner->Control::HandleMessageTemplate(EventType::SCROLLWHEEL, zDelta, lParam);

        EnsureVisible(m_pOwner->GetCurSel());
        return 0;
    }
    else if( uMsg == WM_KILLFOCUS ) {
        if( m_hWnd != (HWND) wParam ) PostMessage(WM_CLOSE);
    }

	bool handled = false;
	LRESULT ret = m_pm.DoHandlMessage(uMsg, wParam, lParam, handled);
	if (handled) {
		return ret;
	}
	else {
	    return CallWindowProc(uMsg, wParam, lParam);	
	}
}

void CComboWnd::EnsureVisible(int iIndex)
{
    if( m_pOwner->GetCurSel() < 0 ) return;
    m_pLayout->FindSelectable(m_pOwner->GetCurSel(), false);
    UiRect rcItem = m_pLayout->GetItemAt(iIndex)->GetPos();
    UiRect rcList = m_pLayout->GetPos();
    ScrollBar* pHorizontalScrollBar = m_pLayout->GetHorizontalScrollBar();
    if( pHorizontalScrollBar && pHorizontalScrollBar->IsVisible() ) rcList.bottom -= pHorizontalScrollBar->GetFixedHeight();
    if( rcItem.top >= rcList.top && rcItem.bottom < rcList.bottom ) return;
    int dx = 0;
    if( rcItem.top < rcList.top ) dx = rcItem.top - rcList.top;
    if( rcItem.bottom > rcList.bottom ) dx = rcItem.bottom - rcList.bottom;
    Scroll(0, dx);
}

void CComboWnd::Scroll(int dx, int dy)
{
    if( dx == 0 && dy == 0 ) return;
    CSize sz = m_pLayout->GetScrollPos();
    m_pLayout->SetScrollPos(CSize(sz.cx + dx, sz.cy + dy));
}

UINT CComboWnd::GetClassStyle() const
{
	return __super::GetClassStyle() | CS_DROPSHADOW;
}

////////////////////////////////////////////////////////


Combo::Combo()
{
    m_szDropBox = CSize(0, 150);
    ::ZeroMemory(&m_rcTextPadding, sizeof(m_rcTextPadding));
	m_Facade.SetOwner(this);
}

void Combo::DoInit()
{
}

int Combo::GetCurSel() const
{
    return m_iCurSel;
}

bool Combo::SelectItem(int iIndex, bool bTakeFocus, bool bTrigger)
{
    if( m_pWindow != NULL ) m_pWindow->Close();
    if( iIndex == m_iCurSel ) return true;
    int iOldSel = m_iCurSel;
    if( m_iCurSel >= 0 ) {
        Control* pControl = static_cast<Control*>(m_items[m_iCurSel]);
        if( !pControl ) return false;
        IListItem* pListItem = dynamic_cast<IListItem*>(pControl);
        if( pListItem != NULL ) pListItem->Select(false);
        m_iCurSel = -1;
    }
    if( iIndex < 0 ) return false;
    if( m_items.size() == 0 ) return false;
    if( (std::size_t)iIndex >= m_items.size() ) iIndex = m_items.size() - 1;
    Control* pControl = static_cast<Control*>(m_items[iIndex]);
    if( !pControl || !pControl->IsVisible() ) return false;
    IListItem* pListItem = dynamic_cast<IListItem*>(pControl);
    if( pListItem == NULL ) return false;
    m_iCurSel = iIndex;
    if( m_pWindow != NULL || bTakeFocus ) pControl->SetFocus();
    pListItem->Select(true);
    if( m_pWindow != NULL && bTrigger) m_pWindow->SendNotify(this, EventType::SELECT, m_iCurSel, iOldSel);
    Invalidate();

    return true;
}

bool Combo::SetItemIndex(Control* pControl, std::size_t iIndex)
{
    int iOrginIndex = GetItemIndex(pControl);
    if( iOrginIndex == -1 ) return false;
    if( iOrginIndex == (int)iIndex ) return true;

    IListItem* pSelectedListItem = NULL;
    if( m_iCurSel >= 0 ) pSelectedListItem = 
        dynamic_cast<IListItem*>(GetItemAt(m_iCurSel));
    if( !Box::SetItemIndex(pControl, iIndex) ) return false;
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

bool Combo::Add(Control* pControl)
{
    IListItem* pListItem = dynamic_cast<IListItem*>(pControl);
    if( pListItem != NULL ) 
    {
        pListItem->SetOwner(this);
        pListItem->SetIndex(m_items.size());
    }
    return Box::Add(pControl);
}

bool Combo::AddAt(Control* pControl, std::size_t iIndex)
{
    if (!Box::AddAt(pControl, iIndex)) return false;

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
    if( m_iCurSel >= 0 && (std::size_t)m_iCurSel >= iIndex ) m_iCurSel += 1;
    return true;
}

bool Combo::Remove(Control* pControl)
{
    int iIndex = GetItemIndex(pControl);
    if (iIndex == -1) return false;

    if (!Box::RemoveAt(iIndex)) return false;

    for(int i = iIndex; i < GetCount(); ++i) {
        Control* p = GetItemAt(i);
        IListItem* pListItem = dynamic_cast<IListItem*>(p);
        if( pListItem != NULL ) {
            pListItem->SetIndex(i);
        }
    }

    if( iIndex == m_iCurSel && m_iCurSel >= 0 ) {
        int iSel = m_iCurSel;
        m_iCurSel = -1;
        SelectItem(FindSelectable(iSel, false));
    }
    else if( iIndex < m_iCurSel ) m_iCurSel -= 1;
    return true;
}

bool Combo::RemoveAt(std::size_t iIndex)
{
    if (!Box::RemoveAt(iIndex)) return false;

    for(int i = iIndex; i < GetCount(); ++i) {
        Control* p = GetItemAt(i);
        IListItem* pListItem = dynamic_cast<IListItem*>(p);
        if( pListItem != NULL ) pListItem->SetIndex(i);
    }

    if( (int)iIndex == m_iCurSel && m_iCurSel >= 0 ) {
        int iSel = m_iCurSel;
        m_iCurSel = -1;
        SelectItem(FindSelectable(iSel, false));
    }
    else if( m_iCurSel >= 0 && iIndex < (std::size_t)m_iCurSel ) m_iCurSel -= 1;
    return true;
}

void Combo::RemoveAll()
{
    m_iCurSel = -1;
    Box::RemoveAll();
}

void Combo::HandleMessage(EventArgs& event)
{
    if( !IsMouseEnabled() && event.Type > EventType::MOUSEBEGIN && event.Type < EventType::MOUSEEND ) {
        if( m_pParent != NULL ) m_pParent->HandleMessageTemplate(event);
        else __super::HandleMessage(event);
        return;
    }
    if( event.Type == EventType::MOUSEMOVE )
    {
        return;
    }
    if( event.Type == EventType::KEYDOWN )
    {
        switch( event.chKey ) {
        //case VK_F4:
        //    Activate();
        //    return;
        case VK_UP:
            SelectItem(FindSelectable(m_iCurSel - 1, false));
            return;
        case VK_DOWN:
            SelectItem(FindSelectable(m_iCurSel + 1, true));
            return;
        case VK_PRIOR:
            SelectItem(FindSelectable(m_iCurSel - 1, false));
            return;
        case VK_NEXT:
            SelectItem(FindSelectable(m_iCurSel + 1, true));
            return;
        case VK_HOME:
            SelectItem(FindSelectable(0, false));
            return;
        case VK_END:
            SelectItem(FindSelectable(GetCount() - 1, true));
            return;
        }
    }
	if( event.Type == EventType::INTERNAL_CONTEXTMENU )
    {
        return;
    }

    __super::HandleMessage(event);
}

void Combo::HandleMessageTemplate(EventArgs& event)
{
	Box::HandleMessageTemplate(event);
}

void Combo::Activate()
{
    if( !IsActivatable() ) return;
    if( m_pWindow ) return;
    m_pWindow = new CComboWnd();
    ASSERT(m_pWindow);
    m_pWindow->Init(this);
    if( m_pWindow != NULL ) m_pWindow->SendNotify(this, EventType::CLICK);
    Invalidate();
}

std::wstring Combo::GetText() const
{
    if( m_iCurSel < 0 ) return _T("");
    ListLabelElement* pControl = static_cast<ListLabelElement*>(m_items[m_iCurSel]);
    return pControl->GetText();
}

std::wstring Combo::GetDropBoxAttributeList()
{
    return m_sDropBoxAttributes;
}

void Combo::SetDropBoxAttributeList(const std::wstring& pstrList)
{
    m_sDropBoxAttributes = pstrList;
}

CSize Combo::GetDropBoxSize() const
{
    return m_szDropBox;
}

void Combo::SetDropBoxSize(CSize szDropBox)
{
    m_szDropBox = szDropBox;
}

UiRect Combo::GetTextPadding() const
{
    return m_rcTextPadding;
}

void Combo::SetTextPadding(UiRect rc)
{
    m_rcTextPadding = rc;
    Invalidate();
}

Facade* Combo::GetFacade()
{
    return &m_Facade;
}

void Combo::SetPos(UiRect rc)
{
    // Put all elements out of sight
    UiRect rcNull;
	for( auto it = m_items.begin(); it != m_items.end(); it++ ) {
		auto pControl = *it;
		pControl->SetPos(rcNull);
	}

    // Position this control
    Control::SetPos(rc);
}

void Combo::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
{
	if (m_Facade.SetAttribute(pstrName, pstrValue))
	{

	}
    else if( pstrName == _T("dropbox") ) SetDropBoxAttributeList(pstrValue);
	else if( pstrName == _T("vscrollbar") ) {}
	else if( pstrName == _T("dropboxsize"))
	{
		CSize szDropBoxSize;
		LPTSTR pstr = NULL;
		szDropBoxSize.cx = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
		szDropBoxSize.cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
		SetDropBoxSize(szDropBoxSize);
	}
    else Box::SetAttribute(pstrName, pstrValue);
}

void Combo::Paint(HDC hDC, const UiRect& rcPaint)
{
	RECT rcTemp = { 0 };
	if( !::IntersectRect(&rcTemp, &rcPaint, &m_rcItem) ) return;

	Control::Paint(hDC, rcPaint);
}

void Combo::PaintText(HDC hDC)
{
    UiRect rcText = m_rcItem;
    rcText.left += m_rcTextPadding.left;
    rcText.right -= m_rcTextPadding.right;
    rcText.top += m_rcTextPadding.top;
    rcText.bottom -= m_rcTextPadding.bottom;

    if( m_iCurSel >= 0 ) {
        Control* pControl = static_cast<Control*>(m_items[m_iCurSel]);
        IListItem* pElement = dynamic_cast<IListItem*>(pControl);
        if( pElement != NULL ) {
            pElement->DrawItemText(hDC, rcText);
        }
        else {
            UiRect rcOldPos = pControl->GetPos();
            pControl->SetPos(rcText);
            pControl->AlphaPaint(hDC, rcText);
            pControl->SetPos(rcOldPos);
        }
    }
}

} // namespace ui
