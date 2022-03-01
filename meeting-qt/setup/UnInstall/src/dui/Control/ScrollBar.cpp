/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "stdafx.h"
#include "ScrollBar.h"

namespace ui
{
	ScrollBar::ScrollBar()
	{
		m_cxyFixed.cx = DEFAULT_SCROLLBAR_SIZE;
		m_cxyFixed.cy = 0;
		ptLastMouse.x = ptLastMouse.y = 0;
		::ZeroMemory(&m_rcThumb, sizeof(m_rcThumb));
		::ZeroMemory(&m_rcButton1, sizeof(m_rcButton1));
		::ZeroMemory(&m_rcButton2, sizeof(m_rcButton2));
		m_bkStateImage.SetControl(this);
		m_thumbStateImage.SetControl(this);
		m_bFloat = true;
	}

	Box* ScrollBar::GetOwner() const
	{
		return m_pOwner;
	}

	void ScrollBar::SetOwner(ScrollableBox* pOwner)
	{
		m_pOwner = pOwner;
	}

	void ScrollBar::SetEnabled(bool bEnable)
	{
		Control::SetEnabled(bEnable);
		if( bEnable ) {
			m_uButton1State = ControlStateType::NORMAL;
			m_uButton2State = ControlStateType::NORMAL;
			m_uThumbState = ControlStateType::NORMAL;
		}
		else {
			m_uButton1State = ControlStateType::DISABLED;
			m_uButton2State = ControlStateType::DISABLED;
			m_uThumbState = ControlStateType::DISABLED;
		}
	}

	void ScrollBar::SetVisible_(bool bVisible)
	{
		if( m_bVisible == bVisible ) return;
		bool v = IsVisible();
		m_bVisible = bVisible;
		if( m_bFocused ) m_bFocused = false;
		if (!bVisible && m_pWindow && m_pWindow->GetFocus() == this) {
			m_pWindow->SetFocus(NULL) ;
		}
		if( IsVisible() != v ) {
			ArrangeSelf();
		}
	}

	bool ScrollBar::ButtonUp(EventArgs& msg)
	{
		bool ret = false;
		if( IsMouseFocused() ) {
			SetMouseFocused(false);
			Invalidate();
			UiRect pos = GetPos();
			if (::PtInRect(&pos, msg.ptMouse)) {
				m_uButtonState = ControlStateType::HOT;
				m_nHotAlpha = 255;
				Activate();
				ret = true;
			}
			else {
				m_uButtonState = ControlStateType::NORMAL;
				m_nHotAlpha = 0;
			}
		}

		UiRect ownerPos = m_pOwner->GetPos();
		if (m_bAutoHide && !::PtInRect(&ownerPos, msg.ptMouse)) {
			SetVisible(false);
		}

		return ret;
	}

	void ScrollBar::SetFocus()
	{
		if( m_pOwner != NULL ) m_pOwner->SetFocus();
		else Control::SetFocus();
	}

	bool ScrollBar::IsHorizontal()
	{
		return m_bHorizontal;
	}

	void ScrollBar::SetHorizontal(bool bHorizontal)
	{
		if( m_bHorizontal == bHorizontal ) return;

		m_bHorizontal = bHorizontal;
		if( m_bHorizontal ) {
			if( m_cxyFixed.cy == 0 ) {
				m_cxyFixed.cx = 0;
				m_cxyFixed.cy = DEFAULT_SCROLLBAR_SIZE;
			}
		}
		else {
			if( m_cxyFixed.cx == 0 ) {
				m_cxyFixed.cx = DEFAULT_SCROLLBAR_SIZE;
				m_cxyFixed.cy = 0;
			}
		}

		if( m_pOwner != NULL ) m_pOwner->Arrange(); else ArrangeAncestor();
	}

	int ScrollBar::GetScrollRange() const
	{
		return m_nRange;
	}

	void ScrollBar::SetScrollRange(int nRange)
	{
		if( m_nRange == nRange ) return;

		m_nRange = nRange;
		if( m_nRange < 0 ) m_nRange = 0;
		if( m_nScrollPos > m_nRange ) m_nScrollPos = m_nRange;

		if (m_nRange == 0) {
			SetVisible_(false);
		}
		else if (!m_bAutoHide && !IsVisible())
		{
			SetVisible(true);
		}
		SetPos(m_rcItem);
	}

	int ScrollBar::GetScrollPos() const
	{
		return m_nScrollPos;
	}

	void ScrollBar::SetScrollPos(int nPos)
	{
		if( m_nScrollPos == nPos ) return;

		m_nScrollPos = nPos;
		if( m_nScrollPos < 0 ) m_nScrollPos = 0;
		if( m_nScrollPos > m_nRange ) m_nScrollPos = m_nRange;
		SetPos(m_rcItem);
	}

	int ScrollBar::GetLineSize() const
	{
		return m_nLineSize;
	}

	void ScrollBar::SetLineSize(int nSize)
	{
		m_nLineSize = nSize;
	}

	int ScrollBar::GetThumbMinLength() const
	{
		return m_nThumbMinLength;
	}

	void ScrollBar::SetThumbMinLength(int nThumbMinLength)
	{
		m_nThumbMinLength = nThumbMinLength;
	}

	bool ScrollBar::GetShowButton1()
	{
		return m_bShowButton1;
	}

	void ScrollBar::SetShowButton1(bool bShow)
	{
		m_bShowButton1 = bShow;
		SetPos(m_rcItem);
	}

	std::wstring ScrollBar::GetButton1StateImage(ControlStateType stateType)
	{
		return m_button1StateImage[stateType].imageAttribute.imageString;
	}

	void ScrollBar::SetButton1StateImage(ControlStateType stateType, const std::wstring& pStrImage)
	{
		m_button1StateImage[stateType].SetImageString(pStrImage);
		Invalidate();
	}

	bool ScrollBar::GetShowButton2()
	{
		return m_bShowButton2;
	}

	void ScrollBar::SetShowButton2(bool bShow)
	{
		m_bShowButton2 = bShow;
		SetPos(m_rcItem);
	}

	std::wstring ScrollBar::GetButton2StateImage(ControlStateType stateType)
	{
		return m_button2StateImage[stateType].imageAttribute.imageString;
	}

	void ScrollBar::SetButton2StateImage(ControlStateType stateType, const std::wstring& pStrImage)
	{
		m_button2StateImage[stateType].SetImageString(pStrImage);
		Invalidate();
	}

	std::wstring ScrollBar::GetThumbStateImage(ControlStateType stateType)
	{
		return m_thumbStateImage[stateType].imageAttribute.imageString;
	}

	void ScrollBar::SetThumbStateImage(ControlStateType stateType, const std::wstring& pStrImage)
	{
		m_thumbStateImage[stateType].SetImageString(pStrImage);
		Invalidate();
	}

	std::wstring ScrollBar::GetRailStateImage(ControlStateType stateType)
	{
		return m_railStateImage[stateType].imageAttribute.imageString;
	}

	void ScrollBar::SetRailStateImage(ControlStateType stateType, const std::wstring& pStrImage)
	{
		m_railStateImage[stateType].SetImageString(pStrImage);
		Invalidate();
	}

	std::wstring ScrollBar::GetBkStateImage(ControlStateType stateType)
	{
		return m_bkStateImage[stateType].imageAttribute.imageString;
	}

	void ScrollBar::SetBkStateImage(ControlStateType stateType, const std::wstring& pStrImage)
	{
		m_bkStateImage[stateType].SetImageString(pStrImage);
		Invalidate();
	}

	void ScrollBar::SetAutoHideScroll(bool hide)
	{
		if (m_bAutoHide != hide)
		{
			m_bAutoHide = hide;
		}
	}

	void ScrollBar::SetPos(UiRect rc)
	{
		Control::SetPos(rc);
		rc = m_rcItem;

		if( m_bHorizontal ) {
			int cx = rc.right - rc.left;
			if( m_bShowButton1 ) cx -= m_cxyFixed.cy;
			if( m_bShowButton2 ) cx -= m_cxyFixed.cy;
			if( cx > m_cxyFixed.cy ) {
				m_rcButton1.left = rc.left;
				m_rcButton1.top = rc.top;
				if( m_bShowButton1 ) {
					m_rcButton1.right = rc.left + m_cxyFixed.cy;
					m_rcButton1.bottom = rc.top + m_cxyFixed.cy;
				}
				else {
					m_rcButton1.right = m_rcButton1.left;
					m_rcButton1.bottom = m_rcButton1.top;
				}

				m_rcButton2.top = rc.top;
				m_rcButton2.right = rc.right;
				if( m_bShowButton2 ) {
					m_rcButton2.left = rc.right - m_cxyFixed.cy;
					m_rcButton2.bottom = rc.top + m_cxyFixed.cy;
				}
				else {
					m_rcButton2.left = m_rcButton2.right;
					m_rcButton2.bottom = m_rcButton2.top;
				}

				m_rcThumb.top = rc.top;
				m_rcThumb.bottom = rc.top + m_cxyFixed.cy;
				if( m_nRange > 0 ) {
					int cxThumb = cx * (rc.right - rc.left) / (m_nRange + rc.right - rc.left);
					if( cxThumb < m_nThumbMinLength ) cxThumb = m_nThumbMinLength;

					m_rcThumb.left = m_nScrollPos * (cx - cxThumb) / m_nRange + m_rcButton1.right;
					m_rcThumb.right = m_rcThumb.left + cxThumb;
					if( m_rcThumb.right > m_rcButton2.left ) {
						m_rcThumb.left = m_rcButton2.left - cxThumb;
						m_rcThumb.right = m_rcButton2.left;
					}
				}
				else {
					m_rcThumb.left = m_rcButton1.right;
					m_rcThumb.right = m_rcButton2.left;
				}
			}
			else {
				int cxButton = (rc.right - rc.left) / 2;
				if( cxButton > m_cxyFixed.cy ) cxButton = m_cxyFixed.cy;
				m_rcButton1.left = rc.left;
				m_rcButton1.top = rc.top;
				if( m_bShowButton1 ) {
					m_rcButton1.right = rc.left + cxButton;
					m_rcButton1.bottom = rc.top + m_cxyFixed.cy;
				}
				else {
					m_rcButton1.right = m_rcButton1.left;
					m_rcButton1.bottom = m_rcButton1.top;
				}

				m_rcButton2.top = rc.top;
				m_rcButton2.right = rc.right;
				if( m_bShowButton2 ) {
					m_rcButton2.left = rc.right - cxButton;
					m_rcButton2.bottom = rc.top + m_cxyFixed.cy;
				}
				else {
					m_rcButton2.left = m_rcButton2.right;
					m_rcButton2.bottom = m_rcButton2.top;
				}

				::ZeroMemory(&m_rcThumb, sizeof(m_rcThumb));
			}
		}
		else {
			int cy = rc.bottom - rc.top;
			if( m_bShowButton1 ) cy -= m_cxyFixed.cx;
			if( m_bShowButton2 ) cy -= m_cxyFixed.cx;
			if( cy > m_cxyFixed.cx ) {
				m_rcButton1.left = rc.left;
				m_rcButton1.top = rc.top;
				if( m_bShowButton1 ) {
					m_rcButton1.right = rc.left + m_cxyFixed.cx;
					m_rcButton1.bottom = rc.top + m_cxyFixed.cx;
				}
				else {
					m_rcButton1.right = m_rcButton1.left;
					m_rcButton1.bottom = m_rcButton1.top;
				}

				m_rcButton2.left = rc.left;
				m_rcButton2.bottom = rc.bottom;
				if( m_bShowButton2 ) {
					m_rcButton2.top = rc.bottom - m_cxyFixed.cx;
					m_rcButton2.right = rc.left + m_cxyFixed.cx;
				}
				else {
					m_rcButton2.top = m_rcButton2.bottom;
					m_rcButton2.right = m_rcButton2.left;
				}

				m_rcThumb.left = rc.left;
				m_rcThumb.right = rc.left + m_cxyFixed.cx;
				if( m_nRange > 0 ) {
					int cyThumb = cy * (rc.bottom - rc.top) / (m_nRange + rc.bottom - rc.top);
					if( cyThumb < m_nThumbMinLength ) cyThumb = m_nThumbMinLength;

					m_rcThumb.top = m_nScrollPos * (cy - cyThumb) / m_nRange + m_rcButton1.bottom;
					m_rcThumb.bottom = m_rcThumb.top + cyThumb;
					if( m_rcThumb.bottom > m_rcButton2.top ) {
						m_rcThumb.top = m_rcButton2.top - cyThumb;
						m_rcThumb.bottom = m_rcButton2.top;
					}
				}
				else {
					m_rcThumb.top = m_rcButton1.bottom;
					m_rcThumb.bottom = m_rcButton2.top;
				}
			}
			else {
				int cyButton = (rc.bottom - rc.top) / 2;
				if( cyButton > m_cxyFixed.cx ) cyButton = m_cxyFixed.cx;
				m_rcButton1.left = rc.left;
				m_rcButton1.top = rc.top;
				if( m_bShowButton1 ) {
					m_rcButton1.right = rc.left + m_cxyFixed.cx;
					m_rcButton1.bottom = rc.top + cyButton;
				}
				else {
					m_rcButton1.right = m_rcButton1.left;
					m_rcButton1.bottom = m_rcButton1.top;
				}

				m_rcButton2.left = rc.left;
				m_rcButton2.bottom = rc.bottom;
				if( m_bShowButton2 ) {
					m_rcButton2.top = rc.bottom - cyButton;
					m_rcButton2.right = rc.left + m_cxyFixed.cx;
				}
				else {
					m_rcButton2.top = m_rcButton2.bottom;
					m_rcButton2.right = m_rcButton2.left;
				}

				::ZeroMemory(&m_rcThumb, sizeof(m_rcThumb));
			}
		}
	}

	void ScrollBar::HandleMessage(EventArgs& event)
	{
		ASSERT(m_pOwner);

		if( !IsMouseEnabled() && event.Type > EventType::MOUSEBEGIN && event.Type < EventType::MOUSEEND ) {
			if( m_pOwner != NULL ) m_pOwner->HandleMessageTemplate(event);
			return;
		}

		if( event.Type == EventType::INTERNAL_SETFOCUS )
		{
			return;
		}
		else if( event.Type == EventType::INTERNAL_KILLFOCUS )
		{
			return;
		}
		else if( event.Type == EventType::BUTTONDOWN || event.Type == EventType::INTERNAL_DBLCLICK )
		{
			if( !IsEnabled() ) return;

			m_nLastScrollOffset = 0;
			m_nScrollRepeatDelay = 0;

			auto callback = std::bind(&ScrollBar::ScrollTimeHandle, this);
			TimerManager::GetInstance()->AddCancelableTimer(weakFlagOwner.GetWeakFlag(), callback, 50, TimerManager::REPEAT_FOREVER);

			if( ::PtInRect(&m_rcButton1, event.ptMouse) ) {
				m_uButton1State = ControlStateType::PUSHED;
				if( !m_bHorizontal ) {
					if( m_pOwner != NULL ) m_pOwner->LineUp(); 
					else SetScrollPos(m_nScrollPos - m_nLineSize);
				}
				else {
					if( m_pOwner != NULL ) m_pOwner->LineLeft(); 
					else SetScrollPos(m_nScrollPos - m_nLineSize);
				}
			}
			else if( ::PtInRect(&m_rcButton2, event.ptMouse) ) {
				m_uButton2State = ControlStateType::PUSHED;
				if( !m_bHorizontal ) {
					if( m_pOwner != NULL ) m_pOwner->LineDown(); 
					else SetScrollPos(m_nScrollPos + m_nLineSize);
				}
				else {
					if( m_pOwner != NULL ) m_pOwner->LineRight(); 
					else SetScrollPos(m_nScrollPos + m_nLineSize);
				}
			}
			else if( ::PtInRect(&m_rcThumb, event.ptMouse) ) {
				m_uThumbState = ControlStateType::PUSHED;
				SetMouseFocused(true);
				ptLastMouse = event.ptMouse;
				m_nLastScrollPos = m_nScrollPos;
			}
			else {
				if( !m_bHorizontal ) {
					if( event.ptMouse.y < m_rcThumb.top ) {
						if( m_pOwner != NULL ) m_pOwner->PageUp(); 
						else SetScrollPos(m_nScrollPos + m_rcItem.top - m_rcItem.bottom);
					}
					else if ( event.ptMouse.y > m_rcThumb.bottom ){
						if( m_pOwner != NULL ) m_pOwner->PageDown(); 
						else SetScrollPos(m_nScrollPos - m_rcItem.top + m_rcItem.bottom);                    
					}
				}
				else {
					if( event.ptMouse.x < m_rcThumb.left ) {
						if( m_pOwner != NULL ) m_pOwner->PageLeft(); 
						else SetScrollPos(m_nScrollPos + m_rcItem.left - m_rcItem.right);
					}
					else if ( event.ptMouse.x > m_rcThumb.right ){
						if( m_pOwner != NULL ) m_pOwner->PageRight(); 
						else SetScrollPos(m_nScrollPos - m_rcItem.left + m_rcItem.right);                    
					}
				}
			}
			ButtonDown(event);
			return;
		}
		else if( event.Type == EventType::BUTTONUP )
		{
			m_nScrollRepeatDelay = 0;
			m_nLastScrollOffset = 0;

			weakFlagOwner.Cancel();

			if(IsMouseFocused()) {
				if( ::PtInRect(&m_rcItem, event.ptMouse) ) {
					m_uThumbState = ControlStateType::HOT;
				}
				else {
					m_uThumbState = ControlStateType::NORMAL;
				}
			}
			else if( m_uButton1State == ControlStateType::PUSHED ) {
				m_uButton1State = ControlStateType::NORMAL;
				Invalidate();
			}
			else if( m_uButton2State == ControlStateType::PUSHED ) {
				m_uButton2State = ControlStateType::NORMAL;
				Invalidate();
			}
			ButtonUp(event);

			return;
		}
		else if (event.Type == EventType::MOUSEENTER)
		{
			MouseEnter(event);
		}
		else if (event.Type == EventType::MOUSELEAVE)
		{
			MouseLeave(event);
		}
		else if( event.Type == EventType::MOUSEMOVE )
		{
			if(IsMouseFocused()) {
				if( !m_bHorizontal ) {

					int vRange = m_rcItem.bottom - m_rcItem.top - m_rcThumb.bottom + m_rcThumb.top;
					if (m_bShowButton1) {
						vRange -= m_cxyFixed.cx;
					}
					if (m_bShowButton2) {
						vRange -= m_cxyFixed.cx;
					}

					if (vRange != 0)
						m_nLastScrollOffset = (event.ptMouse.y - ptLastMouse.y) * m_nRange / vRange;
					
				}
				else {

					int hRange = m_rcItem.right - m_rcItem.left - m_rcThumb.right + m_rcThumb.left;
					if (m_bShowButton1) {
						hRange -= m_cxyFixed.cy;
					}
					if (m_bShowButton2) {
						hRange -= m_cxyFixed.cy;
					}

					if (hRange != 0)
						m_nLastScrollOffset = (event.ptMouse.x - ptLastMouse.x) * m_nRange / hRange;
				}
			}

			return;
		}
		else if( event.Type == EventType::INTERNAL_CONTEXTMENU )
		{
			return;
		}
		else if (event.Type == EventType::SETCURSOR) {
			if (m_cursorType == CursorType::HAND) {
				::SetCursor(::LoadCursor(NULL, MAKEINTRESOURCE(IDC_HAND)));
				return;
			}
			else if (m_cursorType == CursorType::ARROW){
				::SetCursor(::LoadCursor(NULL, MAKEINTRESOURCE(IDC_ARROW)));
				return;
			}
			else {
				ASSERT(FALSE);
			}
		}

		if( m_pOwner != NULL ) m_pOwner->HandleMessageTemplate(event);
	}


	bool ScrollBar::MouseEnter(EventArgs& msg)
	{
		bool ret = __super::MouseEnter(msg);
		if (ret) {
			m_uButton1State = ControlStateType::HOT;
			m_uButton2State = ControlStateType::HOT;
			m_uThumbState = ControlStateType::HOT;
		}

		return ret;
	}

	bool ScrollBar::MouseLeave(EventArgs& msg)
	{
		bool ret = __super::MouseLeave(msg);
		if (ret) {
			m_uButton1State = ControlStateType::NORMAL;
			m_uButton2State = ControlStateType::NORMAL;
			m_uThumbState = ControlStateType::NORMAL;
		}

		return ret;
	}

	void ScrollBar::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
	{
		if( pstrName == _T("button1normalimage") ) SetButton1StateImage(ControlStateType::NORMAL, pstrValue);
		else if( pstrName == _T("button1hotimage") ) SetButton1StateImage(ControlStateType::HOT, pstrValue);
		else if( pstrName == _T("button1pushedimage") ) SetButton1StateImage(ControlStateType::PUSHED, pstrValue);
		else if( pstrName == _T("button1disabledimage") ) SetButton1StateImage(ControlStateType::DISABLED, pstrValue);
		else if( pstrName == _T("button2normalimage") ) SetButton2StateImage(ControlStateType::NORMAL, pstrValue);
		else if( pstrName == _T("button2hotimage") ) SetButton2StateImage(ControlStateType::HOT, pstrValue);
		else if( pstrName == _T("button2pushedimage") ) SetButton2StateImage(ControlStateType::PUSHED, pstrValue);
		else if( pstrName == _T("button2disabledimage") ) SetButton2StateImage(ControlStateType::DISABLED, pstrValue);
		else if( pstrName == _T("thumbnormalimage") ) SetThumbStateImage(ControlStateType::NORMAL, pstrValue);
		else if( pstrName == _T("thumbhotimage") ) SetThumbStateImage(ControlStateType::HOT, pstrValue);
		else if( pstrName == _T("thumbpushedimage") ) SetThumbStateImage(ControlStateType::PUSHED, pstrValue);
		else if( pstrName == _T("thumbdisabledimage") ) SetThumbStateImage(ControlStateType::DISABLED, pstrValue);
		else if( pstrName == _T("railnormalimage") ) SetRailStateImage(ControlStateType::NORMAL, pstrValue);
		else if( pstrName == _T("railhotimage") ) SetRailStateImage(ControlStateType::HOT, pstrValue);
		else if( pstrName == _T("railpushedimage") ) SetRailStateImage(ControlStateType::PUSHED, pstrValue);
		else if( pstrName == _T("raildisabledimage") ) SetRailStateImage(ControlStateType::DISABLED, pstrValue);
		else if( pstrName == _T("bknormalimage") ) SetBkStateImage(ControlStateType::NORMAL, pstrValue);
		else if( pstrName == _T("bkhotimage") ) SetBkStateImage(ControlStateType::HOT, pstrValue);
		else if( pstrName == _T("bkpushedimage") ) SetBkStateImage(ControlStateType::PUSHED, pstrValue);
		else if( pstrName == _T("bkdisabledimage") ) SetBkStateImage(ControlStateType::DISABLED, pstrValue);
		else if( pstrName == _T("hor") ) SetHorizontal(pstrValue == _T("true"));
		else if( pstrName == _T("linesize") ) SetLineSize(_ttoi(pstrValue.c_str()));
		else if( pstrName == _T("thumbminlength") ) SetThumbMinLength(_ttoi(pstrValue.c_str()));
		else if( pstrName == _T("range") ) SetScrollRange(_ttoi(pstrValue.c_str()));
		else if( pstrName == _T("value") ) SetScrollPos(_ttoi(pstrValue.c_str()));
		else if( pstrName == _T("showbutton1") ) SetShowButton1(pstrValue == _T("true"));
		else if( pstrName == _T("showbutton2") ) SetShowButton2(pstrValue == _T("true"));
		else if( pstrName == _T("autohidescroll") ) SetAutoHideScroll(pstrValue == _T("true"));
		else Control::SetAttribute(pstrName, pstrValue);
	}

	void ScrollBar::ScrollTimeHandle()
	{
		++m_nScrollRepeatDelay;
		if(m_uThumbState == ControlStateType::PUSHED) {
			if( !m_bHorizontal ) {
				if( m_pOwner != NULL ) m_pOwner->SetScrollPos(CSize(m_pOwner->GetScrollPos().cx, \
					m_nLastScrollPos + m_nLastScrollOffset)); 
				else SetScrollPos(m_nLastScrollPos + m_nLastScrollOffset);
			}
			else {
				if( m_pOwner != NULL ) m_pOwner->SetScrollPos(CSize(m_nLastScrollPos + m_nLastScrollOffset, \
					m_pOwner->GetScrollPos().cy)); 
				else SetScrollPos(m_nLastScrollPos + m_nLastScrollOffset);
			}
			Invalidate();
		}
		else if( m_uButton1State == ControlStateType::PUSHED ) {
			if( m_nScrollRepeatDelay <= 5 ) return;
			if( !m_bHorizontal ) {
				if( m_pOwner != NULL ) m_pOwner->LineUp(); 
				else SetScrollPos(m_nScrollPos - m_nLineSize);
			}
			else {
				if( m_pOwner != NULL ) m_pOwner->LineLeft(); 
				else SetScrollPos(m_nScrollPos - m_nLineSize);
			}
		}
		else if( m_uButton2State == ControlStateType::PUSHED ) {
			if( m_nScrollRepeatDelay <= 5 ) return;
			if( !m_bHorizontal ) {
				if( m_pOwner != NULL ) m_pOwner->LineDown(); 
				else SetScrollPos(m_nScrollPos + m_nLineSize);
			}
			else {
				if( m_pOwner != NULL ) m_pOwner->LineRight(); 
				else SetScrollPos(m_nScrollPos + m_nLineSize);
			}
		}
		else {
			if( m_nScrollRepeatDelay <= 5 ) return;
			POINT pt = { 0 };
			::GetCursorPos(&pt);
			::ScreenToClient(m_pWindow->GetHWND(), &pt);
			if( !m_bHorizontal ) {
				if( pt.y < m_rcThumb.top ) {
					if( m_pOwner != NULL ) m_pOwner->PageUp(); 
					else SetScrollPos(m_nScrollPos + m_rcItem.top - m_rcItem.bottom);
				}
				else if ( pt.y > m_rcThumb.bottom ){
					if( m_pOwner != NULL ) m_pOwner->PageDown(); 
					else SetScrollPos(m_nScrollPos - m_rcItem.top + m_rcItem.bottom);                    
				}
			}
			else {
				if( pt.x < m_rcThumb.left ) {
					if( m_pOwner != NULL ) m_pOwner->PageLeft(); 
					else SetScrollPos(m_nScrollPos + m_rcItem.left - m_rcItem.right);
				}
				else if ( pt.x > m_rcThumb.right ){
					if( m_pOwner != NULL ) m_pOwner->PageRight(); 
					else SetScrollPos(m_nScrollPos - m_rcItem.left + m_rcItem.right);                    
				}
			}
		}
		return;
	}

	void ScrollBar::Paint(HDC hDC, const UiRect& rcPaint)
	{
		if( !::IntersectRect(&m_rcPaint, &rcPaint, &m_rcItem) ) return;
		PaintBk(hDC);
		PaintButton1(hDC);
		PaintButton2(hDC);
		PaintThumb(hDC);
		PaintRail(hDC);
	}

	void ScrollBar::PaintBk(HDC hDC)
	{
		m_bkStateImage.PaintStatusImage(hDC, m_uButtonState);
	}

	void ScrollBar::PaintButton1(HDC hDC)
	{
		if( !m_bShowButton1 ) return;

		m_sImageModify.clear();
		m_sImageModify = StringHelper::Printf(_T("dest='%d,%d,%d,%d'"), m_rcButton1.left - m_rcItem.left, \
			m_rcButton1.top - m_rcItem.top, m_rcButton1.right - m_rcItem.left, m_rcButton1.bottom - m_rcItem.top);

		if( m_uButton1State == ControlStateType::DISABLED ) {
			if( !DrawImage(hDC, m_button1StateImage[ControlStateType::DISABLED], m_sImageModify) ) {

			}
			else return;
		}
		else if( m_uButton1State == ControlStateType::PUSHED ) {
			if( !DrawImage(hDC, m_button1StateImage[ControlStateType::PUSHED], m_sImageModify) ) {

			}
			else return;

			if( !DrawImage(hDC, m_button1StateImage[ControlStateType::HOT], m_sImageModify) ) {

			}
			else return;
		}
		else if( m_uButton1State == ControlStateType::HOT || m_uThumbState == ControlStateType::PUSHED ) {
			if( !DrawImage(hDC, m_button1StateImage[ControlStateType::HOT], m_sImageModify) ) {

			}
			else return;
		}

		if( !DrawImage(hDC, m_button1StateImage[ControlStateType::NORMAL], m_sImageModify) ) {

		}
		else return;
	}

	void ScrollBar::PaintButton2(HDC hDC)
	{
		if( !m_bShowButton2 ) return;

		m_sImageModify.clear();
		m_sImageModify = StringHelper::Printf(_T("dest='%d,%d,%d,%d'"), m_rcButton2.left - m_rcItem.left, \
			m_rcButton2.top - m_rcItem.top, m_rcButton2.right - m_rcItem.left, m_rcButton2.bottom - m_rcItem.top);

		if( m_uButton2State == ControlStateType::DISABLED ) {
			if( !DrawImage(hDC, m_button2StateImage[ControlStateType::DISABLED], m_sImageModify) ) {

			}
			else return;
		}
		else if( m_uButton2State == ControlStateType::PUSHED ) {
			if( !DrawImage(hDC, m_button2StateImage[ControlStateType::PUSHED], m_sImageModify) ) {

			}
			else return;
			
			if( !DrawImage(hDC, m_button2StateImage[ControlStateType::HOT], m_sImageModify) ) {

			}
			else return;
		}
		else if( m_uButton2State == ControlStateType::HOT || m_uThumbState == ControlStateType::PUSHED ) {
			if( !DrawImage(hDC, m_button2StateImage[ControlStateType::HOT], m_sImageModify) ) {

			}
			else return;
		}

		if( !DrawImage(hDC, m_button2StateImage[ControlStateType::NORMAL], m_sImageModify) ) {

		}
		else return;
	}

	void ScrollBar::PaintThumb(HDC hDC)
	{
		if( m_rcThumb.left == 0 && m_rcThumb.top == 0 && m_rcThumb.right == 0 && m_rcThumb.bottom == 0 ) return;

		m_sImageModify.clear();
		m_sImageModify = StringHelper::Printf(_T("dest='%d,%d,%d,%d'"), m_rcThumb.left - m_rcItem.left, \
			m_rcThumb.top - m_rcItem.top, m_rcThumb.right - m_rcItem.left, m_rcThumb.bottom - m_rcItem.top);

		m_thumbStateImage.PaintStatusImage(hDC, m_uThumbState, m_sImageModify);
	}

	void ScrollBar::PaintRail(HDC hDC)
	{
		if( m_rcThumb.left == 0 && m_rcThumb.top == 0 && m_rcThumb.right == 0 && m_rcThumb.bottom == 0 ) return;

		m_sImageModify.clear();
		if( !m_bHorizontal ) {
			m_sImageModify = StringHelper::Printf(_T("dest='%d,%d,%d,%d'"), m_rcThumb.left - m_rcItem.left, \
				(m_rcThumb.top + m_rcThumb.bottom) / 2 - m_rcItem.top - m_cxyFixed.cx / 2, \
				m_rcThumb.right - m_rcItem.left, \
				(m_rcThumb.top + m_rcThumb.bottom) / 2 - m_rcItem.top + m_cxyFixed.cx - m_cxyFixed.cx / 2);
		}
		else {
			m_sImageModify = StringHelper::Printf(_T("dest='%d,%d,%d,%d'"), \
				(m_rcThumb.left + m_rcThumb.right) / 2 - m_rcItem.left - m_cxyFixed.cy / 2, \
				m_rcThumb.top - m_rcItem.top, \
				(m_rcThumb.left + m_rcThumb.right) / 2 - m_rcItem.left + m_cxyFixed.cy - m_cxyFixed.cy / 2, \
				m_rcThumb.bottom - m_rcItem.top);
		}

		if( m_uThumbState == ControlStateType::DISABLED ) {
			if( !DrawImage(hDC, m_railStateImage[ControlStateType::DISABLED], m_sImageModify) ) {

			}
			else return;
		}
		else if( m_uThumbState == ControlStateType::PUSHED ) {
			if( !DrawImage(hDC, m_railStateImage[ControlStateType::PUSHED], m_sImageModify) ) {

			}
			else return;

			if( !DrawImage(hDC, m_railStateImage[ControlStateType::HOT], m_sImageModify) ) {

			}
			else return;
		}
		else if( m_uThumbState == ControlStateType::HOT ) {
			if( !DrawImage(hDC, m_railStateImage[ControlStateType::HOT], m_sImageModify) ) {

			}
			else return;
		}

		if( !DrawImage(hDC, m_railStateImage[ControlStateType::NORMAL], m_sImageModify) ) {

		}
		else return;
	}
}
