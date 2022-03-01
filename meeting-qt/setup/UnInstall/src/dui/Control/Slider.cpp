/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"
#include "Slider.h"

namespace ui
{
	Slider::Slider()
	{
		m_uTextStyle = DT_SINGLELINE | DT_CENTER;
	}

	int Slider::GetChangeStep()
	{
		return m_nStep;
	}

	void Slider::SetChangeStep(int step)
	{
		m_nStep = step;
	}

	void Slider::SetThumbSize(CSize szXY)
	{
		m_szThumb = szXY;
	}

	UiRect Slider::GetThumbRect() const
	{
		if( m_bHorizontal ) {
			int left = int(m_rcItem.left + (m_rcItem.right - m_rcItem.left - m_szThumb.cx) * (m_nValue - m_nMin) / (m_nMax - m_nMin));
			int top = (m_rcItem.bottom + m_rcItem.top - m_szThumb.cy) / 2;
			return UiRect(left, top, left + m_szThumb.cx, top + m_szThumb.cy); 
		}
		else {
			int left = (m_rcItem.right + m_rcItem.left - m_szThumb.cx) / 2;
			int top = int(m_rcItem.bottom - m_szThumb.cy - (m_rcItem.bottom - m_rcItem.top - m_szThumb.cy) * (m_nValue - m_nMin) / (m_nMax - m_nMin));
			return UiRect(left, top, left + m_szThumb.cx, top + m_szThumb.cy); 
		}
	}

	std::wstring Slider::GetThumbStateImage(ControlStateType stateType)
	{
		return m_thumbStateImage[stateType].imageAttribute.imageString;
	}

	void Slider::SetThumbStateImage(ControlStateType stateType, const std::wstring& pStrImage)
	{
		m_thumbStateImage[stateType].SetImageString(pStrImage);
		Invalidate();
	}

	UiRect Slider::GetProgressBarPadding() const
	{
		return m_progressBarPadding;
	}

	void Slider::SetProgressBarPadding(UiRect rc)
	{
		m_progressBarPadding = rc;
		if (GetFixedWidth() == DUI_LENGTH_AUTO || GetFixedHeight() == DUI_LENGTH_AUTO) {
			ArrangeAncestor();
		}
		else {
			Invalidate();
		}
	}

	void Slider::HandleMessage(EventArgs& event)
	{
		if( !IsMouseEnabled() && event.Type > EventType::MOUSEBEGIN && event.Type < EventType::MOUSEEND ) {
			if( m_pParent != NULL ) m_pParent->HandleMessageTemplate(event);
			else Progress::HandleMessage(event);
			return;
		}

		if( event.Type == EventType::BUTTONDOWN || event.Type == EventType::INTERNAL_DBLCLICK )
		{
			if( IsEnabled() ) {
				CPoint newPtMouse = event.ptMouse;
				newPtMouse.Offset(GetScrollOffset());
				UiRect rcThumb = GetThumbRect();
				if( rcThumb.IsPointIn(newPtMouse) ) {
					SetMouseFocused(true);
				}
			}
			return;
		}
		if( event.Type == EventType::BUTTONUP )
		{
			if(IsMouseFocused()) {
				SetMouseFocused(false);
			}
			if( IsEnabled() ) {
				if( m_bHorizontal ) {
					if( event.ptMouse.x >= m_rcItem.right - m_szThumb.cx / 2 ) m_nValue = m_nMax;
					else if( event.ptMouse.x <= m_rcItem.left + m_szThumb.cx / 2 ) m_nValue = m_nMin;
					else m_nValue = m_nMin + double((m_nMax - m_nMin) * (event.ptMouse.x - m_rcItem.left - m_szThumb.cx / 2 )) / (m_rcItem.right - m_rcItem.left - m_szThumb.cx);
				}
				else {
					if( event.ptMouse.y >= m_rcItem.bottom - m_szThumb.cy / 2 ) m_nValue = m_nMin;
					else if( event.ptMouse.y <= m_rcItem.top + m_szThumb.cy / 2  ) m_nValue = m_nMax;
					else m_nValue = m_nMin + double((m_nMax - m_nMin) * (m_rcItem.bottom - event.ptMouse.y - m_szThumb.cy / 2 )) / (m_rcItem.bottom - m_rcItem.top - m_szThumb.cy);
				}
				m_pWindow->SendNotify(this, EventType::VALUECHANGE);
				Invalidate();
			}
			return;
		}
		if( event.Type == EventType::INTERNAL_CONTEXTMENU )
		{
			return;
		}
		if( event.Type == EventType::SCROLLWHEEL ) 
		{
			int detaValue = event.wParam;
			if (detaValue > 0 ) {
				SetValue(GetValue() + GetChangeStep());
				m_pWindow->SendNotify(this, EventType::VALUECHANGE);
				return;
			}
			else {
				SetValue(GetValue() - GetChangeStep());
				m_pWindow->SendNotify(this, EventType::VALUECHANGE);
				return;
			}
		}
		if( event.Type == EventType::MOUSEMOVE )
		{
			if (IsMouseFocused()) {
				if( m_bHorizontal ) {
					if( event.ptMouse.x >= m_rcItem.right - m_szThumb.cx / 2 ) m_nValue = m_nMax;
					else if( event.ptMouse.x <= m_rcItem.left + m_szThumb.cx / 2 ) m_nValue = m_nMin;
					else m_nValue = m_nMin + double((m_nMax - m_nMin) * (event.ptMouse.x - m_rcItem.left - m_szThumb.cx / 2 )) / (m_rcItem.right - m_rcItem.left - m_szThumb.cx);
				}
				else {
					if( event.ptMouse.y >= m_rcItem.bottom - m_szThumb.cy / 2 ) m_nValue = m_nMin;
					else if( event.ptMouse.y <= m_rcItem.top + m_szThumb.cy / 2  ) m_nValue = m_nMax;
					else m_nValue = m_nMin + double((m_nMax - m_nMin) * (m_rcItem.bottom - event.ptMouse.y - m_szThumb.cy / 2 )) / (m_rcItem.bottom - m_rcItem.top - m_szThumb.cy);
				}
				Invalidate();
			}
			return;
		}

		Progress::HandleMessage(event);
	}

	UiRect Slider::GetProgressPos()
	{
		UiRect rc;
		if( m_bHorizontal ) {
			rc.right = int((m_nValue - m_nMin) * (m_rcItem.right - m_rcItem.left - m_szThumb.cx) / (m_nMax - m_nMin) + m_szThumb.cx / 2 + 0.5);
			rc.bottom = m_rcItem.bottom - m_rcItem.top;
		}
		else {
			rc.top = int((m_nMax - m_nValue) * (m_rcItem.bottom - m_rcItem.top - m_szThumb.cy) / (m_nMax - m_nMin) + m_szThumb.cy / 2 + 0.5);
			rc.right = m_rcItem.right - m_rcItem.left;
			rc.bottom = m_rcItem.bottom - m_rcItem.top;
		}

		return rc;
	}

	void Slider::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
	{
		if( pstrName == _T("thumbnormalimage") ) SetThumbStateImage(ControlStateType::NORMAL, pstrValue);
		else if( pstrName ==  _T("thumbhotimage") ) SetThumbStateImage(ControlStateType::HOT, pstrValue);
		else if( pstrName == _T("thumbpushedimage") ) SetThumbStateImage(ControlStateType::PUSHED, pstrValue);
		else if( pstrName == _T("thumbdisabledimage") ) SetThumbStateImage(ControlStateType::DISABLED, pstrValue);
		else if( pstrName == _T("thumbsize") ) {
			CSize szXY;
			LPTSTR pstr = NULL;
			szXY.cx = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
			szXY.cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr); 
			SetThumbSize(szXY);
		}
		else if( pstrName == _T("step") ) {
			SetChangeStep(_ttoi(pstrValue.c_str()));
		}
		else if (pstrName == _T("progressbarpadding")) {
			UiRect rcPadding;
			LPTSTR pstr = NULL;
			rcPadding.left = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);
			rcPadding.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);
			rcPadding.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);
			rcPadding.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);
			SetProgressBarPadding(rcPadding);
		}
		else Progress::SetAttribute(pstrName, pstrValue);
	}

	void Slider::PaintStatusImage(HDC hDC)
	{
		m_rcItem.Deflate(m_progressBarPadding);
		Progress::PaintStatusImage(hDC);
		m_rcItem.Inflate(m_progressBarPadding);

		UiRect rcThumb = GetThumbRect();
		rcThumb.left -= m_rcItem.left;
		rcThumb.top -= m_rcItem.top;
		rcThumb.right -= m_rcItem.left;
		rcThumb.bottom -= m_rcItem.top;
		if (IsMouseFocused()) {
			m_sImageModify.clear();
			m_sImageModify = StringHelper::Printf(_T("dest='%d,%d,%d,%d'"), rcThumb.left, rcThumb.top, rcThumb.right, rcThumb.bottom);
			if( !DrawImage(hDC, m_thumbStateImage[ControlStateType::PUSHED], m_sImageModify) ) {

			}
			else return;
		}
		else if( m_uButtonState == ControlStateType::HOT ) {
			m_sImageModify.clear();
			m_sImageModify = StringHelper::Printf(_T("dest='%d,%d,%d,%d'"), rcThumb.left, rcThumb.top, rcThumb.right, rcThumb.bottom);
			if( !DrawImage(hDC, m_thumbStateImage[ControlStateType::HOT], m_sImageModify) ) {

			}
			else return;
		}

		m_sImageModify.clear();
		m_sImageModify = StringHelper::Printf(_T("dest='%d,%d,%d,%d'"), rcThumb.left, rcThumb.top, rcThumb.right, rcThumb.bottom);
		if( !DrawImage(hDC, m_thumbStateImage[ControlStateType::NORMAL], m_sImageModify) ) {

		}
		else return;
	}
}
