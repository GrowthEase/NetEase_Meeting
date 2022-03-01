/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"

namespace ui
{
	Layout::Layout()
	{
		::ZeroMemory(&m_rcPadding, sizeof(m_rcPadding));
	}

	void Layout::SetOwner(Box* pOwner)
	{
		m_pOwner = pOwner;
	}

	bool Layout::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
	{
		bool hasAttribute = true;
		if( pstrName == _T("padding") ) {
			UiRect rcPadding;
			LPTSTR pstr = NULL;
			rcPadding.left = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
			rcPadding.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
			rcPadding.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
			rcPadding.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
			SetPadding(rcPadding);
		}
		else if( pstrName == _T("childmargin") ) 
		{
			SetChildMargin(_ttoi(pstrValue.c_str()));
		}
		else
		{
			hasAttribute = false;
		}

		return hasAttribute;
	}

	CSize Layout::ArrangeChild(const std::vector<Control*>& m_items, UiRect rc)
	{
		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			Control* pControl = *it;
			if( !pControl->IsVisible() ) continue;
			SetFloatPos(pControl, rc);
		}

		CSize size = {0, 0};
		return size;
	}

	void Layout::SetFloatPos(Control* pControl, UiRect containerRect)
	{
		if( !pControl->IsVisible() ) return;
		
		int childLeft = 0;
		int childRight = 0;
		int childTop = 0;
		int childBottm = 0;
		UiRect rcMargin = pControl->GetMargin();
		int iPosLeft = containerRect.left + rcMargin.left;
		int iPosRight = containerRect.right - rcMargin.right;
		int iPosTop = containerRect.top + rcMargin.top;
		int iPosBottom = containerRect.bottom - rcMargin.bottom;
		CSize szAvailable = { iPosRight - iPosLeft, iPosBottom - iPosTop };
		CSize childSize = pControl->EstimateSize(szAvailable);
		if (pControl->GetFixedWidth() == DUI_LENGTH_AUTO && pControl->GetFixedHeight() == DUI_LENGTH_AUTO
			&& pControl->GetMaxWidth() == DUI_LENGTH_STRETCH) {
			int maxwidth = MAX(0, szAvailable.cx);
			if (childSize.cx > maxwidth) {
				pControl->SetFixedWidth(maxwidth, false);
				childSize = pControl->EstimateSize(szAvailable);
				pControl->SetFixedWidth(DUI_LENGTH_AUTO, false);
			}
		}
		if( childSize.cx == DUI_LENGTH_STRETCH ) {
			childSize.cx = MAX(0, szAvailable.cx);
		}
		if( childSize.cx < pControl->GetMinWidth() ) childSize.cx = pControl->GetMinWidth();
		if( pControl->GetMaxWidth() >= 0 && childSize.cx > pControl->GetMaxWidth() ) childSize.cx = pControl->GetMaxWidth();

		if(childSize.cy == DUI_LENGTH_STRETCH) {
			childSize.cy = MAX(0, szAvailable.cy);
		}
		if( childSize.cy < pControl->GetMinHeight() ) childSize.cy = pControl->GetMinHeight();
		if( childSize.cy > pControl->GetMaxHeight() ) childSize.cy = pControl->GetMaxHeight();


		int childWidth = childSize.cx;
		int childHeight = childSize.cy;
		HorAlignType horAlignType = pControl->GetHorAlignType();
		VerAlignType verAlignType = pControl->GetVerAlignType();

		if (horAlignType == HorAlignType::LEFT) {
			childLeft = iPosLeft;
			childRight = childLeft + childWidth;
		}
		else if (horAlignType == HorAlignType::RIGHT) {
			childRight = iPosRight;
			childLeft = childRight - childWidth;
		}
		else if (horAlignType == HorAlignType::CENTER) {
			childLeft = iPosLeft + (iPosRight - iPosLeft - childWidth) / 2;
			childRight = childLeft + childWidth;
		}

		if (verAlignType == VerAlignType::TOP) {
			childTop = iPosTop;
			childBottm = childTop + childHeight;
		}
		else if (verAlignType == VerAlignType::BOTTOM) {
			childBottm = iPosBottom;
			childTop = childBottm - childHeight;
		}
		else if (verAlignType == VerAlignType::CENTER) {
			childTop = iPosTop + (iPosBottom - iPosTop - childHeight) / 2;
			childBottm = childTop + childHeight;
		}

		UiRect childPos(childLeft, childTop, childRight, childBottm);
		pControl->SetPos(childPos);
	}

	CSize Layout::AjustSizeByChild(const std::vector<Control*>& m_items, CSize szAvailable)
	{
		CSize maxSize = {-9999, -9999};
		CSize itemSize;
		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			if (!(*it)->IsVisible())
			{
				continue;
			}
			itemSize = (*it)->EstimateSize(szAvailable);
			if( itemSize.cx < (*it)->GetMinWidth() ) itemSize.cx = (*it)->GetMinWidth();
			if( (*it)->GetMaxWidth() >= 0 && itemSize.cx > (*it)->GetMaxWidth() ) itemSize.cx = (*it)->GetMaxWidth();
			if( itemSize.cy < (*it)->GetMinHeight() ) itemSize.cy = (*it)->GetMinHeight();
			if( itemSize.cy > (*it)->GetMaxHeight() ) itemSize.cy = (*it)->GetMaxHeight();
			maxSize.cx = MAX(itemSize.cx + (*it)->GetMargin().left + (*it)->GetMargin().right, maxSize.cx);
			maxSize.cy = MAX(itemSize.cy + (*it)->GetMargin().top + (*it)->GetMargin().bottom, maxSize.cy);
		}
		maxSize.cx += m_rcPadding.left + m_rcPadding.right;
		maxSize.cy += m_rcPadding.top + m_rcPadding.bottom;
		return maxSize;
	}

	UiRect Layout::GetPadding() const
	{
		return m_rcPadding;
	}

	void Layout::SetPadding(UiRect rcPadding)
	{
		m_rcPadding = rcPadding;
		m_pOwner->Arrange();
	}

	int Layout::GetChildMargin() const
	{
		return m_iChildMargin;
	}

	void Layout::SetChildMargin(int iMargin)
	{
		m_iChildMargin = iMargin;
		m_pOwner->Arrange();
	}

	UiRect Layout::GetInternalPos() const
	{
		UiRect internalPos = m_pOwner->GetPos();
		internalPos.Deflate(m_rcPadding);
		return internalPos;
	}

	/////////////////////////////////////////////////////////////////////////////////////
	//
	//

	Box::Box(Layout* pLayout) :
		m_pLayout(pLayout)
	{
		m_pLayout->SetOwner(this);
	}

	Box::~Box()
	{
		m_bDelayedDestroy = false;
		RemoveAll();
	}

	void Box::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
	{
		if (m_pLayout->SetAttribute(pstrName, pstrValue))
		{

		}
		else if( pstrName == _T("clip") ) SetClip(pstrValue == _T("true"));
		else if( pstrName == _T("mousechild") ) SetMouseChildEnabled(pstrValue == _T("true"));
		else Control::SetAttribute(pstrName, pstrValue);
	}

	void Box::SetPos(UiRect rc)
	{
		Control::SetPos(rc);
		rc.left += m_pLayout->GetPadding().left;
		rc.top += m_pLayout->GetPadding().top;
		rc.right -= m_pLayout->GetPadding().right;
		rc.bottom -= m_pLayout->GetPadding().bottom;

		CSize requiredSize;
		if( m_items.size() == 0) 
		{
			requiredSize.cx = 0;
			requiredSize.cy = 0;
		}
		else
		{
			requiredSize = m_pLayout->ArrangeChild(m_items, rc);
		}
	}

	UiRect Box::GetPaddingPos() const
	{
		UiRect pos = GetPos();
		UiRect padding = m_pLayout->GetPadding();
		pos.left += padding.left;
		pos.top += padding.top;
		pos.right -= padding.right;
		pos.bottom -= padding.bottom;

		return pos;
	}

	void Box::Paint(HDC hDC, const UiRect& rcPaint)
	{
		UiRect rcTemp;
		if( !::IntersectRect(&rcTemp, &rcPaint, &m_rcItem) ) return;

		Control::Paint(hDC, rcPaint);
		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			Control* pControl = *it;
			if( !pControl->IsVisible() ) continue;
			pControl->AlphaPaint(hDC, rcPaint);
		}
	}

	Control* Box::GetItemAt(std::size_t iIndex) const
	{
		if( iIndex < 0 || iIndex >= m_items.size() ) return NULL;
		return static_cast<Control*>(m_items[iIndex]);
	}

	int Box::GetItemIndex(Control* pControl) const
	{
		auto it = std::find(m_items.begin(), m_items.end(), pControl);
		if (it == m_items.end())
		{
			return -1;
		}
		return it - m_items.begin();
	}

	bool Box::SetItemIndex(Control* pControl, std::size_t iIndex)
	{
		if( iIndex < 0 || iIndex >= m_items.size() ) return false;
		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			if( *it == pControl ) {
				Arrange();            
				m_items.erase(it);
				m_items.insert(m_items.begin() + iIndex, pControl);
				return true;
			}
		}

		return false;
	}

	int Box::GetCount() const
	{
		return m_items.size();
	}

	bool Box::Add(Control* pControl)
	{
		if( pControl == NULL) return false;

		if( m_pWindow != NULL ) m_pWindow->InitControls(pControl, this);
		if( IsVisible() ) Arrange();
		else pControl->SetInternVisible(false);
		m_items.push_back(pControl);   
		return true;
	}

	bool Box::AddAt(Control* pControl, std::size_t iIndex)
	{
		if( pControl == NULL) return false;
		if( iIndex < 0 || iIndex > m_items.size() ) {
			ASSERT(FALSE);
			return false;
		}
		if( m_pWindow != NULL ) m_pWindow->InitControls(pControl, this);
		if( IsVisible() ) Arrange();
		else pControl->SetInternVisible(false);
		m_items.insert(m_items.begin() + iIndex, pControl);
		return true;
	}

	bool Box::Remove(Control* pControl)
	{
		if( pControl == NULL) return false;

		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			if( *it == pControl ) {
				Arrange();
				if( m_bAutoDestroy ) {
					if( m_bDelayedDestroy && m_pWindow ) m_pWindow->AddDelayedCleanup(pControl);             
					else delete pControl;
				}
				m_items.erase(it);
				return true;
			}
		}
		return false;
	}

	bool Box::RemoveAt(std::size_t iIndex)
	{
		Control* pControl = GetItemAt(iIndex);
		if (pControl != NULL) {
			return Box::Remove(pControl);
		}

		return false;
	}

	void Box::RemoveAll()
	{
		if (m_bAutoDestroy) {
			for (auto& it : m_items) {
				if( m_bDelayedDestroy && m_pWindow ) m_pWindow->AddDelayedCleanup(it);             
				else delete it;
			}
		}

		m_items.clear();
		Arrange();
	}

	void Box::SwapChild(Control* child1, Control* child2)
	{
		ASSERT(std::find(m_items.begin(), m_items.end(), child1) != m_items.end());
		ASSERT(std::find(m_items.begin(), m_items.end(), child2) != m_items.end());

		std::vector<Control*>::iterator it1, it2;
		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			if (*it == child1 || *it == child2) {
				Control* child = (*it == child1) ? child2 : child1;
				it = m_items.erase(it);
				it = m_items.insert(it, child);
			}
		}
	}

	void Box::ResetChildIndex(Control* child, std::size_t newIndex)
	{
		ASSERT(std::find(m_items.begin(), m_items.end(), child) != m_items.end());

		std::size_t oldIndex = 0;
		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			if (*it == child) {
				m_items.erase(it);
				if (oldIndex >= newIndex) {
					AddAt(child, newIndex);
				}
				else {
					AddAt(child, newIndex - 1);
				}

				break;
			}
			oldIndex++;
		}
	}

	bool Box::IsAutoDestroy() const
	{
		return m_bAutoDestroy;
	}

	void Box::SetAutoDestroy(bool bAuto)
	{
		m_bAutoDestroy = bAuto;
	}

	bool Box::IsDelayedDestroy() const
	{
		return m_bDelayedDestroy;
	}

	void Box::SetDelayedDestroy(bool bDelayed)
	{
		m_bDelayedDestroy = bDelayed;
	}

	CSize Box::EstimateSize(CSize szAvailable)
	{
		CSize fixedSize = m_cxyFixed;
		if (GetFixedWidth() == DUI_LENGTH_AUTO || GetFixedHeight() == DUI_LENGTH_AUTO) {
			if (!m_bReEstimateSize) {
				return m_szEstimateSize;
			}
			szAvailable.cx -= m_pLayout->GetPadding().left + m_pLayout->GetPadding().right;
			szAvailable.cy -= m_pLayout->GetPadding().top + m_pLayout->GetPadding().bottom;
			CSize sizeByChild = m_pLayout->AjustSizeByChild(m_items, szAvailable);
			if (GetFixedWidth() == DUI_LENGTH_AUTO) {
				fixedSize.cx = sizeByChild.cx;
			}
			if (GetFixedHeight() == DUI_LENGTH_AUTO) {
				fixedSize.cy = sizeByChild.cy;
			}

			m_bReEstimateSize = false;
			for (auto& it : m_items) {
				if (!it->IsVisible()) {
					continue;
				}
				if (it->GetFixedWidth() == DUI_LENGTH_AUTO || it->GetFixedHeight() == DUI_LENGTH_AUTO) {
					if (it->GetReEstimateSize()) {
						m_bReEstimateSize = true;
						break;
					}
				}
			}
			
			m_szEstimateSize = fixedSize;
		}

		return fixedSize;
	}

	bool Box::IsMouseChildEnabled() const
	{
		return m_bMouseChildEnabled;
	}

	void Box::SetMouseChildEnabled(bool bEnable)
	{
		m_bMouseChildEnabled = bEnable;
	}

	Layout* Box::GetLayout() const
	{
		return m_pLayout.get();
	}

	void Box::RetSetLayout(Layout* pLayout)
	{
		m_pLayout.reset(pLayout);
	}

	void Box::SetVisible(bool bVisible)
	{
		//if( m_bVisible == bVisible ) return;
		Control::SetVisible(bVisible);
		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			(*it)->SetInternVisible(IsVisible());
		}
	}

	// 逻辑上，对于Container控件不公开此方法
	// 调用此方法的结果是，内部子控件隐藏，控件本身依然显示，背景等效果存在
	void Box::SetInternVisible(bool bVisible)
	{
		Control::SetInternVisible(bVisible);
		if( m_items.empty() ) return;
		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			// 控制子控件显示状态
			// InternVisible状态应由子控件自己控制
			(*it)->SetInternVisible(IsVisible());
		}
	}

	void Box::SetEnabled(bool bEnabled)
	{
		if( m_bEnabled == bEnabled ) return;

		m_bEnabled = bEnabled;

		Control::SetEnabled(bEnabled);
		if( m_items.empty() ) return;
		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			(*it)->SetEnabled(bEnabled);
		}

		Invalidate();
	}

	int Box::FindSelectable(int iIndex, bool bForward /*= true*/) const
	{
		// NOTE: This is actually a helper-function for the list/combo/ect controls
		//       that allow them to find the next enabled/available selectable item
		if( GetCount() == 0 ) return -1;
		iIndex = CLAMP(iIndex, 0, GetCount() - 1);
		if( bForward ) {
			for( int i = iIndex; i < GetCount(); i++ ) {
				if( dynamic_cast<IListItem*>(GetItemAt(i)) != NULL 
					&& GetItemAt(i)->IsVisible()
					&& GetItemAt(i)->IsEnabled() ) return i;
			}
			return -1;
		}
		else {
			for( int i = iIndex; i >= 0; --i ) {
				if( dynamic_cast<IListItem*>(GetItemAt(i)) != NULL 
					&& GetItemAt(i)->IsVisible()
					&& GetItemAt(i)->IsEnabled() ) return i;
			}
			return FindSelectable(0, true);
		}
	}

	void Box::SetWindow(Window* pManager, Box* pParent, bool bInit)
	{
		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			(*it)->SetWindow(pManager, this, bInit);
		}

		Control::SetWindow(pManager, pParent, bInit);
	}

	Control* Box::FindControl(FINDCONTROLPROC Proc, LPVOID pData, UINT uFlags, CPoint scrollPos)
	{
		// Check if this guy is valid
		if( (uFlags & UIFIND_VISIBLE) != 0 && !IsVisible() ) return NULL;
		if( (uFlags & UIFIND_ENABLED) != 0 && !IsEnabled() ) return NULL;
		if( (uFlags & UIFIND_HITTEST) != 0 ) {
			if( !::PtInRect(&m_rcItem, *(static_cast<LPPOINT>(pData))) ) return NULL;
			if( !m_bMouseChildEnabled ) {
				Control* pResult = NULL;
				//if( m_pVerticalScrollBar != NULL ) pResult = m_pVerticalScrollBar->FindControl(Proc, pData, uFlags);
				//if( pResult == NULL && m_pHorizontalScrollBar != NULL ) pResult = m_pHorizontalScrollBar->FindControl(Proc, pData, uFlags);
				if( pResult == NULL ) pResult = Control::FindControl(Proc, pData, uFlags);
				return pResult;
			}
		}

		Control* pResult = NULL;
		//if( m_pVerticalScrollBar != NULL ) pResult = m_pVerticalScrollBar->FindControl(Proc, pData, uFlags);
		//if( pResult == NULL && m_pHorizontalScrollBar != NULL ) pResult = m_pHorizontalScrollBar->FindControl(Proc, pData, uFlags);
		if( pResult != NULL ) return pResult;

		if( (uFlags & UIFIND_ME_FIRST) != 0 ) {
			Control* pControl = Control::FindControl(Proc, pData, uFlags);
			if( pControl != NULL ) return pControl;
		}
		UiRect rc = m_rcItem;
		rc.left += m_pLayout->GetPadding().left;
		rc.top += m_pLayout->GetPadding().top;
		rc.right -= m_pLayout->GetPadding().right;
		rc.bottom -= m_pLayout->GetPadding().bottom;
		//if( m_pVerticalScrollBar && m_pVerticalScrollBar->IsValid() ) rc.right -= m_pVerticalScrollBar->GetFixedWidth();
		//if( m_pHorizontalScrollBar && m_pHorizontalScrollBar->IsValid() ) rc.bottom -= m_pHorizontalScrollBar->GetFixedHeight();

		if( (uFlags & UIFIND_TOP_FIRST) != 0 ) {
			for( int it = m_items.size() - 1; it >= 0; it-- ) {
				Control* pControl;
				if ((uFlags & UIFIND_HITTEST) != 0) {
					CPoint newPoint = *(static_cast<LPPOINT>(pData));
					newPoint.Offset(scrollPos);
					pControl = m_items[it]->FindControl(Proc, &newPoint, uFlags);
				}
				else {
					pControl = m_items[it]->FindControl(Proc, pData, uFlags);
				}
				if( pControl != NULL ) {
					if( (uFlags & UIFIND_HITTEST) != 0 && !pControl->IsFloat() && !::PtInRect(&rc, *(static_cast<LPPOINT>(pData))) )
						continue;
					else 
						return pControl;
				}            
			}
		}
		else {
			for (auto it = m_items.begin(); it != m_items.end(); it++) {
				Control* pControl;
				if ((uFlags & UIFIND_HITTEST) != 0) {
					CPoint newPoint = *(static_cast<LPPOINT>(pData));
					newPoint.Offset(scrollPos);
					pControl = (*it)->FindControl(Proc, &newPoint, uFlags);
				}
				else {
					pControl = (*it)->FindControl(Proc, pData, uFlags);
				}
				if( pControl != NULL ) {
					if( (uFlags & UIFIND_HITTEST) != 0 && !pControl->IsFloat() && !::PtInRect(&rc, *(static_cast<LPPOINT>(pData))) )
						continue;
					else 
						return pControl;
				} 
			}
		}

		if( pResult == NULL && (uFlags & UIFIND_ME_FIRST) == 0 ) pResult = Control::FindControl(Proc, pData, uFlags);
		return pResult;
	}

	Control* Box::FindSubControl( const std::wstring& pstrSubControlName )
	{
		Control* pSubControl=NULL;
		pSubControl=static_cast<Control*>(GetWindow()->FindSubControlByName(this,pstrSubControlName));
		return pSubControl;
	}

	void Box::HandleMessageTemplate(EventArgs& msg)
	{
		if (msg.Type == EventType::INTERNAL_DBLCLICK || msg.Type == EventType::INTERNAL_CONTEXTMENU
			|| msg.Type == EventType::INTERNAL_SETFOCUS || msg.Type == EventType::INTERNAL_KILLFOCUS) {
				HandleMessage(msg);
				return;
		}
		bool ret = true;

		std::weak_ptr<nbase::WeakFlag> weakflag = GetWeakFlag();
		if (this == msg.pSender) {
			auto callback = OnEvent.find(msg.Type);
			if (callback != OnEvent.end()) {
				ret = callback->second(&msg);
			}
			if (weakflag.expired()) {
				return;
			}
			callback = OnEvent.find(EventType::ALL);
			if (callback != OnEvent.end()) {
				ret = callback->second(&msg);
			}
			if (weakflag.expired()) {
				return;
			}
			if (ret) {
				auto callback = OnXmlEvent.find(msg.Type);
				if (callback != OnXmlEvent.end()) {
					ret = callback->second(&msg);
				}
				if (weakflag.expired()) {
					return;
				}
				callback = OnXmlEvent.find(EventType::ALL);
				if (callback != OnXmlEvent.end()) {
					ret = callback->second(&msg);
				}
				if (weakflag.expired()) {
					return;
				}
			}

		}

		auto callback = OnBubbledEvent.find(msg.Type);
		if (callback != OnBubbledEvent.end()) {
			ret = callback->second(&msg);
		}
		if (weakflag.expired()) {
			return;
		}
		callback = OnBubbledEvent.find(EventType::ALL);
		if (callback != OnBubbledEvent.end()) {
			ret = callback->second(&msg);
		}
		if (weakflag.expired()) {
			return;
		}
		if (ret) {
			auto callback = OnXmlBubbledEvent.find(msg.Type);
			if (callback != OnXmlBubbledEvent.end()) {
				ret = callback->second(&msg);
			}
			if (weakflag.expired()) {
				return;
			}
			callback = OnXmlBubbledEvent.find(EventType::ALL);
			if (callback != OnXmlBubbledEvent.end()) {
				ret = callback->second(&msg);
			}
			if (weakflag.expired()) {
				return;
			}
		}

		if(ret) {
			HandleMessage(msg);
		}
	}

	/////////////////////////////////////////////////////////////////////////////////////
	//
	//

	void ScrollableBox::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
	{
		if( pstrName == _T("vscrollbar") ) {
			EnableScrollBar(pstrValue == _T("true"), GetHorizontalScrollBar() != NULL);
		}
		else if( pstrName == _T("vscrollbarstyle") ) {
			EnableScrollBar(true, GetHorizontalScrollBar() != NULL);
			if( GetVerticalScrollBar() ) GetVerticalScrollBar()->ApplyAttributeList(pstrValue);
		}
		else if( pstrName == _T("hscrollbar") ) {
			EnableScrollBar(GetVerticalScrollBar() != NULL, pstrValue == _T("true"));
		}
		else if( pstrName == _T("hscrollbarstyle") ) {
			EnableScrollBar(GetVerticalScrollBar() != NULL, true);
			if( GetHorizontalScrollBar() ) GetHorizontalScrollBar()->ApplyAttributeList(pstrValue);
		}
		else if( pstrName == _T("scrollbarpadding") ) {
			UiRect rcScrollbarPadding;
			LPTSTR pstr = NULL;
			rcScrollbarPadding.left = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
			rcScrollbarPadding.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
			rcScrollbarPadding.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
			rcScrollbarPadding.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
			SetScrollBarPadding(rcScrollbarPadding);
		}
		else if( pstrName == _T("vscrollunit") ) SetVerScrollUnitPixels(_ttoi(pstrValue.c_str()));
		else if( pstrName == _T("scrollbarfloat") ) SetScrollBarFloat(pstrValue == _T("true"));
		else if( pstrName == _T("defaultdisplayscrollbar") ) SetDefaultDisplayScrollbar(pstrValue == _T("true"));
		else if( pstrName == _T("holdend") ) SetHoldEnd(pstrValue == _T("true"));
		else Box::SetAttribute(pstrName, pstrValue);
	}

	void ScrollableBox::SetPos(UiRect rc)
	{
		bool isEndDown = false;
		if (GetHoldEnd() && IsVScrollBarValid() && GetScrollRange().cy - GetScrollPos().cy == 0) {
			isEndDown = true;
		}
		SetPosInternally(rc);
		if (isEndDown && IsVScrollBarValid()) {
			EndDown(false, false);
		}
	}

	void ScrollableBox::SetPosInternally(UiRect rc)
	{
		Control::SetPos(rc);
		UiRect rawRect = rc;
		rc.left += m_pLayout->GetPadding().left;
		rc.top += m_pLayout->GetPadding().top;
		rc.right -= m_pLayout->GetPadding().right;
		rc.bottom -= m_pLayout->GetPadding().bottom;

		CSize requiredSize;
		if( m_items.size() == 0) 
		{
			requiredSize.cx = 0;
			requiredSize.cy = 0;
		}
		else
		{
			UiRect childSize = rc;
			if (!m_bScrollBarFloat && m_pVerticalScrollBar && m_pVerticalScrollBar->IsValid())
			{
				childSize.right -= m_pVerticalScrollBar->GetFixedWidth();
			}

			requiredSize = m_pLayout->ArrangeChild(m_items, childSize);
		}

		ProcessScrollBar(rawRect, requiredSize.cx, requiredSize.cy);
	}

	void ScrollableBox::HandleMessage(EventArgs& event)
	{
		if( !IsMouseEnabled() && event.Type > EventType::MOUSEBEGIN && event.Type < EventType::MOUSEEND ) {
			if( m_pParent != NULL ) m_pParent->HandleMessageTemplate(event);
			else Box::HandleMessage(event);
			return;
		}
		
		if( m_pVerticalScrollBar != NULL && m_pVerticalScrollBar->IsValid() && m_pVerticalScrollBar->IsEnabled() )
		{
			if( event.Type == EventType::KEYDOWN ) 
			{
				switch( event.chKey ) {
				case VK_DOWN:
					LineDown();
					return;
				case VK_UP:
					LineUp();
					return;
				case VK_NEXT:
					PageDown();
					return;
				case VK_PRIOR:
					PageUp();
					return;
				case VK_HOME:
					HomeUp();
					return;
				case VK_END:
					EndDown();
					return;
				}
			}
			else if( event.Type == EventType::SCROLLWHEEL )
			{
				int detaValue = event.wParam;
				if (detaValue > 0 ) {
					LineUp(abs(detaValue));
					return;
				}
				else {
					LineDown(abs(detaValue));
					return;
				}
			}
		}
		else if( m_pHorizontalScrollBar != NULL && m_pHorizontalScrollBar->IsValid() && m_pHorizontalScrollBar->IsEnabled() ) {
			if( event.Type == EventType::KEYDOWN ) 
			{
				switch( event.chKey ) {
				case VK_DOWN:
					LineRight();
					return;
				case VK_UP:
					LineLeft();
					return;
				case VK_NEXT:
					PageRight();
					return;
				case VK_PRIOR:
					PageLeft();
					return;
				case VK_HOME:
					HomeLeft();
					return;
				case VK_END:
					EndRight();
					return;
				}
			}
			else if( event.Type == EventType::SCROLLWHEEL )
			{
				int detaValue = event.wParam;
				if (detaValue > 0 ) {
					LineLeft();
					return;
				}
				else {
					LineRight();
					return;
				}
			}
		}
		
		Box::HandleMessage(event);
	}

	bool ScrollableBox::MouseEnter(EventArgs& msg)
	{
		bool ret = __super::MouseEnter(msg);
		if (ret && m_pVerticalScrollBar != NULL && m_pVerticalScrollBar->IsValid() && m_pVerticalScrollBar->IsEnabled())
		{
			if (m_pVerticalScrollBar->IsAutoHideScroll()) {
				m_pVerticalScrollBar->SetVisible(true);
			}
		}

		return ret;
	}

	bool ScrollableBox::MouseLeave(EventArgs& msg)
	{
		bool ret = __super::MouseLeave(msg);
		if (ret && m_pVerticalScrollBar != NULL && m_pVerticalScrollBar->IsValid() && m_pVerticalScrollBar->IsEnabled())
		{
			if (m_pVerticalScrollBar->GetThumbState() == ControlStateType::NORMAL
				&& m_pVerticalScrollBar->IsAutoHideScroll())
			{
				m_pVerticalScrollBar->SetVisible(false);
			}
		}

		return ret;
	}

	void ScrollableBox::Paint(HDC hDC, const UiRect& rcPaint)
	{
		UiRect rcTemp;
		if( !::IntersectRect(&rcTemp, &rcPaint, &m_rcItem) ) return;

		Control::Paint(hDC, rcPaint);

		for (auto it = m_items.begin(); it != m_items.end(); it++) {
			Control* pControl = *it;
			if( !pControl->IsVisible() ) continue;
			if (pControl->IsFloat()) {
				pControl->AlphaPaint(hDC, rcPaint);	
			}
			else {
				CSize scrollPos = GetScrollPos();
				UiRect newRcPaint = rcPaint;
				newRcPaint.Offset(scrollPos.cx, scrollPos.cy);
				newRcPaint.Offset(GetRenderOffset().x, GetRenderOffset().y);
				CPoint oldWinOrg;
				GetWindowOrgEx(hDC, &oldWinOrg);
				CPoint newWinOrg = oldWinOrg;
				newWinOrg.Offset(scrollPos.cx, scrollPos.cy);
				::SetWindowOrgEx(hDC, newWinOrg.x, newWinOrg.y,NULL);
				pControl->AlphaPaint(hDC, newRcPaint);	
				::SetWindowOrgEx(hDC, oldWinOrg.x, oldWinOrg.y, NULL);
			}
		}

		if( m_pHorizontalScrollBar && m_pHorizontalScrollBar->IsVisible()) {
			m_pHorizontalScrollBar->AlphaPaint(hDC, rcPaint);
		}
		
		if( m_pVerticalScrollBar && m_pVerticalScrollBar->IsVisible()) {
			m_pVerticalScrollBar->AlphaPaint(hDC, rcPaint);
		}
		
	}

	CSize ScrollableBox::GetScrollPos() const
	{
		CSize sz = {0, 0};
		if( m_pVerticalScrollBar && m_pVerticalScrollBar->IsValid() ) sz.cy = m_pVerticalScrollBar->GetScrollPos();
		if( m_pHorizontalScrollBar && m_pHorizontalScrollBar->IsValid() ) sz.cx = m_pHorizontalScrollBar->GetScrollPos();
		return sz;
	}

	CSize ScrollableBox::GetScrollRange() const
	{
		CSize sz = {0, 0};
		if( m_pVerticalScrollBar && m_pVerticalScrollBar->IsValid() ) sz.cy = m_pVerticalScrollBar->GetScrollRange();
		if( m_pHorizontalScrollBar && m_pHorizontalScrollBar->IsValid() ) sz.cx = m_pHorizontalScrollBar->GetScrollRange();
		return sz;
	}

	void ScrollableBox::SetScrollPos(CSize szPos)
	{
		if (szPos.cy < 0) {
			szPos.cy = 0;
			m_scrollAnimation.Reset();
		}
		else if (szPos.cy > GetScrollRange().cy) {
			szPos.cy = GetScrollRange().cy;
			m_scrollAnimation.Reset();
		}

		int cx = 0;
		int cy = 0;
		if( m_pVerticalScrollBar && m_pVerticalScrollBar->IsValid() ) {
			int iLastScrollPos = m_pVerticalScrollBar->GetScrollPos();
			m_pVerticalScrollBar->SetScrollPos(szPos.cy);
			cy = m_pVerticalScrollBar->GetScrollPos() - iLastScrollPos;
		}

		if( m_pHorizontalScrollBar && m_pHorizontalScrollBar->IsValid() ) {
			int iLastScrollPos = m_pHorizontalScrollBar->GetScrollPos();
			m_pHorizontalScrollBar->SetScrollPos(szPos.cx);
			cx = m_pHorizontalScrollBar->GetScrollPos() - iLastScrollPos;
		}

		if( cx == 0 && cy == 0 ) return;
		Invalidate();
		if( m_pWindow != NULL )
		{
			m_pWindow->SendNotify(this, EventType::SCROLLCHANGE);

			if (GetScrollPos().cy == 0) {
				m_pWindow->SendNotify(this, EventType::SCROLLUPOVER);
			}

			if (GetScrollPos().cy == GetScrollRange().cy) {
				m_pWindow->SendNotify(this, EventType::SCROLLDOWNOVER);
			}
		}
	}

	void ScrollableBox::SetScrollPosY(int y)
	{
		CSize scrollPos = GetScrollPos();
		scrollPos.cy = y;
		SetScrollPos(scrollPos);
	}

	void ScrollableBox::LineUp(int detaValue)
	{
		int cyLine = GetVerScrollUnitPixels();
		if (cyLine == 0) {
			cyLine = 20;
		}
		if (detaValue != DUI_NOSET_VALUE) {
			cyLine = min(cyLine, detaValue);
		}

		CSize scrollPos = GetScrollPos();
		if (scrollPos.cy <= 0) {
			return;
		}

		m_scrollAnimation.SetStartValue(scrollPos.cy);
		if (m_scrollAnimation.IsPlaying()) {
			if (m_scrollAnimation.GetEndValue() > m_scrollAnimation.GetStartValue()) {
				m_scrollAnimation.SetEndValue(scrollPos.cy - cyLine);
			}
			else {
				m_scrollAnimation.SetEndValue(m_scrollAnimation.GetEndValue() - cyLine);
			}
		}
		else {
			m_scrollAnimation.SetEndValue(scrollPos.cy - cyLine);
		}
		m_scrollAnimation.SetSpeedUpRatio(0);
		m_scrollAnimation.SetSpeedDownfactorA(-0.012);
		m_scrollAnimation.SetSpeedDownRatio(0.5);
		m_scrollAnimation.SetTotalMillSeconds(DUI_NOSET_VALUE);
		m_scrollAnimation.SetCallback(std::bind(&ScrollableBox::SetScrollPosY, this, std::placeholders::_1));
		m_scrollAnimation.Start();
	}

	void ScrollableBox::LineDown(int detaValue)
	{
		int cyLine = GetVerScrollUnitPixels();
		if (cyLine == 0) {
			cyLine = 20;
		}
		if (detaValue != DUI_NOSET_VALUE) {
			cyLine = min(cyLine, detaValue);
		}

		CSize scrollPos = GetScrollPos();
		if (scrollPos.cy >= GetScrollRange().cy) {
			return;
		}
		m_scrollAnimation.SetStartValue(scrollPos.cy);
		if (m_scrollAnimation.IsPlaying()) {
			if (m_scrollAnimation.GetEndValue() < m_scrollAnimation.GetStartValue()) {
				m_scrollAnimation.SetEndValue(scrollPos.cy + cyLine);
			}
			else {
				m_scrollAnimation.SetEndValue(m_scrollAnimation.GetEndValue() + cyLine);
			}
		}
		else {
			m_scrollAnimation.SetEndValue(scrollPos.cy + cyLine);
		}
		m_scrollAnimation.SetSpeedUpRatio(0);
		m_scrollAnimation.SetSpeedDownfactorA(-0.012);
		m_scrollAnimation.SetSpeedDownRatio(0.5);
		m_scrollAnimation.SetTotalMillSeconds(DUI_NOSET_VALUE);
		m_scrollAnimation.SetCallback(std::bind(&ScrollableBox::SetScrollPosY, this, std::placeholders::_1));
		m_scrollAnimation.Start();
	}

	void ScrollableBox::PageUp()
	{
		CSize sz = GetScrollPos();
		int iOffset = m_rcItem.bottom - m_rcItem.top - m_pLayout->GetPadding().top - m_pLayout->GetPadding().bottom;
		if( m_pHorizontalScrollBar && m_pHorizontalScrollBar->IsValid() ) iOffset -= m_pHorizontalScrollBar->GetFixedHeight();
		sz.cy -= iOffset;
		SetScrollPos(sz);
	}

	void ScrollableBox::PageDown()
	{
		CSize sz = GetScrollPos();
		int iOffset = m_rcItem.bottom - m_rcItem.top - m_pLayout->GetPadding().top - m_pLayout->GetPadding().bottom;
		if( m_pHorizontalScrollBar && m_pHorizontalScrollBar->IsValid() ) iOffset -= m_pHorizontalScrollBar->GetFixedHeight();
		sz.cy += iOffset;
		SetScrollPos(sz);
	}

	void ScrollableBox::HomeUp()
	{
		CSize sz = GetScrollPos();
		sz.cy = 0;
		SetScrollPos(sz);
	}

	void ScrollableBox::EndDown(bool arrange, bool withAnimation)
	{
		if (arrange) {
			SetPosInternally(GetPos());
		}
	
		int renderOffsetY = GetScrollRange().cy - GetScrollPos().cy + (m_renderOffsetYAnimation.GetEndValue() - GetRenderOffset().y);
		if (withAnimation == true && IsVScrollBarValid() && renderOffsetY > 0) {
			PlayRenderOffsetYAnimation(-renderOffsetY);
		}

		CSize sz = GetScrollPos();
		sz.cy = GetScrollRange().cy;
		SetScrollPos(sz);
	}

	void ScrollableBox::ReomveLastItemAnimation()
	{
		int startRangY = GetScrollRange().cy;
		SetPosInternally(GetPos());
		int endRangY = GetScrollRange().cy;

		int renderOffsetY = endRangY - startRangY + (m_renderOffsetYAnimation.GetEndValue() - GetRenderOffset().y);
		if (renderOffsetY < 0) {
			PlayRenderOffsetYAnimation(-renderOffsetY);
		}
	}

	bool ScrollableBox::IsAtEnd() const
	{
		return GetScrollRange().cy <= GetScrollPos().cy;
	}

	void ScrollableBox::PlayRenderOffsetYAnimation(int renderY)
	{
		m_renderOffsetYAnimation.SetStartValue(renderY);
		m_renderOffsetYAnimation.SetEndValue(0);
		m_renderOffsetYAnimation.SetSpeedUpRatio(0.3);
		m_renderOffsetYAnimation.SetSpeedUpfactorA(0.003);
		m_renderOffsetYAnimation.SetSpeedDownRatio(0.7);
		m_renderOffsetYAnimation.SetTotalMillSeconds(DUI_NOSET_VALUE);
		m_renderOffsetYAnimation.SetMaxTotalMillSeconds(650);
		std::function<void(int)> playCallback = std::bind(&ScrollableBox::SetRenderOffsetY, this, std::placeholders::_1);
		m_renderOffsetYAnimation.SetCallback(playCallback);
		m_renderOffsetYAnimation.Start();
	}

	void ScrollableBox::LineLeft()
	{
		CSize sz = GetScrollPos();
		sz.cx -= 8;
		SetScrollPos(sz);
	}

	void ScrollableBox::LineRight()
	{
		CSize sz = GetScrollPos();
		sz.cx += 8;
		SetScrollPos(sz);
	}

	void ScrollableBox::PageLeft()
	{
		CSize sz = GetScrollPos();
		int iOffset = m_rcItem.right - m_rcItem.left - m_pLayout->GetPadding().left - m_pLayout->GetPadding().right;
		//if( m_pVerticalScrollBar && m_pVerticalScrollBar->IsValid() ) iOffset -= m_pVerticalScrollBar->GetFixedWidth();
		sz.cx -= iOffset;
		SetScrollPos(sz);
	}

	void ScrollableBox::PageRight()
	{
		CSize sz = GetScrollPos();
		int iOffset = m_rcItem.right - m_rcItem.left - m_pLayout->GetPadding().left - m_pLayout->GetPadding().right;
		//if( m_pVerticalScrollBar && m_pVerticalScrollBar->IsValid() ) iOffset -= m_pVerticalScrollBar->GetFixedWidth();
		sz.cx += iOffset;
		SetScrollPos(sz);
	}

	void ScrollableBox::HomeLeft()
	{
		CSize sz = GetScrollPos();
		sz.cx = 0;
		SetScrollPos(sz);
	}

	void ScrollableBox::EndRight()
	{
		CSize sz = GetScrollPos();
		sz.cx = GetScrollRange().cx;
		SetScrollPos(sz);
	}

	void ScrollableBox::EnableScrollBar(bool bEnableVertical, bool bEnableHorizontal)
	{
		if( bEnableVertical && !m_pVerticalScrollBar ) {
			m_pVerticalScrollBar.reset(new ScrollBar);
			m_pVerticalScrollBar->SetVisible_(false);
			m_pVerticalScrollBar->SetScrollRange(0);
			m_pVerticalScrollBar->SetOwner(this);
			m_pVerticalScrollBar->SetWindow(m_pWindow, NULL, false);
			m_pVerticalScrollBar->SetClass(_T("vscrollbar"));
		}
		else if( !bEnableVertical && m_pVerticalScrollBar ) {
			m_pVerticalScrollBar.reset();
		}

		if( bEnableHorizontal && !m_pHorizontalScrollBar ) {
			m_pHorizontalScrollBar.reset(new ScrollBar);
			m_pHorizontalScrollBar->SetVisible_(false);
			m_pHorizontalScrollBar->SetScrollRange(0);
			m_pHorizontalScrollBar->SetHorizontal(true);
			m_pHorizontalScrollBar->SetOwner(this);
			m_pHorizontalScrollBar->SetWindow(m_pWindow, NULL, false);
			m_pHorizontalScrollBar->SetClass(_T("hscrollbar"));
		}
		else if( !bEnableHorizontal && m_pHorizontalScrollBar ) {
			m_pHorizontalScrollBar.reset();
		}

		Arrange();
	}

	ScrollBar* ScrollableBox::GetVerticalScrollBar() const
	{
		return m_pVerticalScrollBar.get();
	}

	ScrollBar* ScrollableBox::GetHorizontalScrollBar() const
	{
		return m_pHorizontalScrollBar.get();
	}

	bool ScrollableBox::IsVScrollBarValid() const
	{
		if (m_pVerticalScrollBar) {
			return m_pVerticalScrollBar->IsValid();
		}
		return false;
	}

	bool ScrollableBox::IsHScrollBarValid() const
	{
		if (m_pHorizontalScrollBar) {
			return m_pHorizontalScrollBar->IsValid();
		}
		return false;
	}

	void ScrollableBox::ProcessScrollBar(UiRect rc, int cxRequired, int cyRequired)
	{
		UiRect rcScrollBarPos = rc;
		rcScrollBarPos.left += m_rcScrollBarPadding.left;
		rcScrollBarPos.top += m_rcScrollBarPadding.top;
		rcScrollBarPos.right -= m_rcScrollBarPadding.right;
		rcScrollBarPos.bottom -= m_rcScrollBarPadding.bottom;
		if( m_pHorizontalScrollBar != NULL && m_pHorizontalScrollBar->IsValid() ) {
			UiRect rcHorScrollBarPos(rcScrollBarPos.left, rcScrollBarPos.bottom, rcScrollBarPos.right, rcScrollBarPos.bottom + m_pHorizontalScrollBar->GetFixedHeight());
			m_pHorizontalScrollBar->SetPos(rcHorScrollBarPos);
		}

		if( m_pVerticalScrollBar == NULL ) return;

		rc.left += m_pLayout->GetPadding().left;
		rc.top += m_pLayout->GetPadding().top;
		rc.right -= m_pLayout->GetPadding().right;
		rc.bottom -= m_pLayout->GetPadding().bottom;
		if( cyRequired > rc.bottom - rc.top && !m_pVerticalScrollBar->IsValid()) {
			//m_pVerticalScrollBar->SetVisible(true);
			m_pVerticalScrollBar->SetScrollRange(cyRequired - (rc.bottom - rc.top));
			m_pVerticalScrollBar->SetScrollPos(0);
			m_bScrollProcess = true;
			SetPos(m_rcItem);
			m_bScrollProcess = false;

			if( m_pWindow != NULL ) {		
				m_pWindow->SendNotify(this, EventType::SCROLLAPPEAR);
			}

			return;
		}
		// No scrollbar required
		if( !m_pVerticalScrollBar->IsValid() ) return;

		// Scroll not needed anymore?
		int cyScroll = cyRequired - (rc.bottom - rc.top);
		if( cyScroll <= 0 && !m_bScrollProcess) {
			//m_pVerticalScrollBar->SetVisible(false);
			m_pVerticalScrollBar->SetScrollPos(0);
			m_pVerticalScrollBar->SetScrollRange(0);
			SetPos(m_rcItem);

			if( m_pWindow != NULL ) {		
				m_pWindow->SendNotify(this, EventType::SCROLLDISAPPEAR);
			}
		}
		else
		{
			UiRect rcVerScrollBarPos(rcScrollBarPos.right - m_pVerticalScrollBar->GetFixedWidth(), rcScrollBarPos.top, rcScrollBarPos.right, rcScrollBarPos.bottom);
			m_pVerticalScrollBar->SetPos(rcVerScrollBarPos);

			if( m_pVerticalScrollBar->GetScrollRange() != cyScroll ) {
				int iScrollPos = m_pVerticalScrollBar->GetScrollPos();
				m_pVerticalScrollBar->SetScrollRange(::abs(cyScroll));
				if( !m_pVerticalScrollBar->IsValid() ) {
					//m_pVerticalScrollBar->SetVisible(false);
					m_pVerticalScrollBar->SetScrollPos(0);
				}
				else {
					if( m_pWindow != NULL ) {		
						m_pWindow->SendNotify(this, EventType::SCROLLAPPEAR);
					}
				}

				if( iScrollPos > m_pVerticalScrollBar->GetScrollPos() ) {
					SetPos(m_rcItem);
				}
			}
		}
	}

	void ScrollableBox::SetMouseEnabled(bool bEnabled)
	{
		if( m_pVerticalScrollBar != NULL ) m_pVerticalScrollBar->SetMouseEnabled(bEnabled);
		if( m_pHorizontalScrollBar != NULL ) m_pHorizontalScrollBar->SetMouseEnabled(bEnabled);
		Box::SetMouseEnabled(bEnabled);
	}

	void ScrollableBox::SetWindow(Window* pManager, Box* pParent, bool bInit)
	{
		if( m_pVerticalScrollBar != NULL ) m_pVerticalScrollBar->SetWindow(pManager, this, bInit);
		if( m_pHorizontalScrollBar != NULL ) m_pHorizontalScrollBar->SetWindow(pManager, this, bInit);
		Box::SetWindow(pManager, pParent, bInit);
	}

	Control* ScrollableBox::FindControl(FINDCONTROLPROC Proc, LPVOID pData, UINT uFlags, CPoint scrollPos)
	{
		// Check if this guy is valid
		if( (uFlags & UIFIND_VISIBLE) != 0 && !IsVisible() ) return NULL;
		if( (uFlags & UIFIND_ENABLED) != 0 && !IsEnabled() ) return NULL;
		if( (uFlags & UIFIND_HITTEST) != 0 ) {
			if( !::PtInRect(&m_rcItem, *(static_cast<LPPOINT>(pData))) ) return NULL;
			if( !m_bMouseChildEnabled ) {
				Control* pResult = NULL;
				if( m_pVerticalScrollBar != NULL ) pResult = m_pVerticalScrollBar->FindControl(Proc, pData, uFlags);
				if( pResult == NULL && m_pHorizontalScrollBar != NULL ) pResult = m_pHorizontalScrollBar->FindControl(Proc, pData, uFlags);
				if( pResult == NULL ) pResult = Control::FindControl(Proc, pData, uFlags);
				return pResult;
			}
		}

		Control* pResult = NULL;
		if( m_pVerticalScrollBar != NULL ) pResult = m_pVerticalScrollBar->FindControl(Proc, pData, uFlags);
		if( pResult == NULL && m_pHorizontalScrollBar != NULL ) pResult = m_pHorizontalScrollBar->FindControl(Proc, pData, uFlags);
		if( pResult != NULL ) return pResult;

		CPoint newScrollPos(GetScrollPos().cx, GetScrollPos().cy);
		return Box::FindControl(Proc, pData, uFlags, newScrollPos);
	}

} // namespace ui
