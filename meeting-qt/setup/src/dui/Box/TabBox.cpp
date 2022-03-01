/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "stdafx.h"
#include "TabBox.h"

namespace ui
{
	TabBox::TabBox()
	{
		m_bClip = true;
	}

	bool TabBox::Add(Control* pControl)
	{
		bool ret = Box::Add(pControl);
		if( !ret ) return ret;

		if(m_iCurSel == -1 && pControl->IsVisible())
		{
			m_iCurSel = GetItemIndex(pControl);
		}
		else
		{
			if (!IsFadeSwitch()) {
				pControl->SetVisible(false);
			}
			pControl->SetMouseEnabled(false);
			if (Box* box = dynamic_cast<Box*>(pControl)) {
				box->SetMouseChildEnabled(false);
			}
			pControl->SetAlpha(0);
		}

		return ret;
	}

	bool TabBox::AddAt(Control* pControl, std::size_t iIndex)
	{
		bool ret = Box::AddAt(pControl, iIndex);
		if( !ret ) return ret;

		if(m_iCurSel == -1 && pControl->IsVisible())
		{
			m_iCurSel = GetItemIndex(pControl);
		}
		else if( m_iCurSel != -1 && iIndex <= (std::size_t)m_iCurSel )
		{
			m_iCurSel += 1;
		}
		else
		{
			if (!IsFadeSwitch()) {
				pControl->SetVisible(false);
			}
			pControl->SetMouseEnabled(false);
			if (Box* box = dynamic_cast<Box*>(pControl)) {
				box->SetMouseChildEnabled(false);
			}
			pControl->SetAlpha(0);
		}

		return ret;
	}

	bool TabBox::Remove(Control* pControl)
	{
		if( pControl == NULL) return false;

		int index = GetItemIndex(pControl);
		bool ret = Box::Remove(pControl);
		if( !ret ) return false;

		if( m_iCurSel == index)
		{
			if( GetCount() > 0 )
			{
				m_iCurSel=0;
				if (!IsFadeSwitch()) {
					GetItemAt(m_iCurSel)->SetVisible(true);
				}
				pControl->SetMouseEnabled(true);
				if (Box* box = dynamic_cast<Box*>(pControl)) {
					box->SetMouseChildEnabled(true);
				}
				pControl->SetAlpha(255);
			}
			else
				m_iCurSel=-1;
			ArrangeAncestor();
		}
		else if( m_iCurSel > index )
		{
			m_iCurSel -= 1;
		}

		return ret;
	}

	void TabBox::RemoveAll()
	{
		m_iCurSel = -1;
		Box::RemoveAll();
		ArrangeAncestor();
	}

	int TabBox::GetCurSel() const
	{
		return m_iCurSel;
	}
	
	bool TabBox::SelectItem(int iIndex)
	{
		if( iIndex < 0 || (std::size_t)iIndex >= m_items.size() ) return false;
		if( iIndex == m_iCurSel ) return true;

		int iOldSel = m_iCurSel;
		m_iCurSel = iIndex;
		for( std::size_t it = 0; it < m_items.size(); it++ )
		{
			if( (int)it == iIndex ) {
				ShowTabItem(it);

				if (!IsFadeSwitch()) {
					m_items[it]->SetVisible();
				}
				else {
					int startValue = 0;
					int endValue = 0;
					if (m_iCurSel < iOldSel) {
						startValue = GetPos().GetWidth();
						endValue = 0;
					}
					else {
						startValue = -GetPos().GetWidth();
						endValue = 0;
					}

					auto player = m_items[it]->GetAnimationManager().SetFadeInOutX(true, true);
					player->SetStartValue(startValue);
					player->SetEndValue(endValue);
					player->SetSpeedUpfactorA(0.01);
					player->SetCompleteCallback(StdClosure());
					player->Start();
				}
			}
			else {
				if ((int)it != iOldSel) {
					HideTabItem(it);
					if (!IsFadeSwitch()) {
						m_items[it]->SetVisible(false);
					}
				}
				else {
					if (!IsFadeSwitch()) {
						HideTabItem(it);
						m_items[it]->SetVisible(false);
					}
					else {
						int startValue = 0;
						int endValue = 0;
						if (m_iCurSel < iOldSel) {
							startValue = 0;
							endValue = -GetPos().GetWidth();
						}
						else {
							startValue = 0;
							endValue = GetPos().GetWidth();
						}

						auto player = m_items[it]->GetAnimationManager().SetFadeInOutX(true, true);
						player->SetStartValue(startValue);
						player->SetEndValue(endValue);
						player->SetSpeedUpfactorA(0.01);
						StdClosure compelteCallback = std::bind(&TabBox::HideTabItem, this, it);
						compelteCallback = ToWeakCallback(compelteCallback);
						player->SetCompleteCallback(compelteCallback);
						player->Start();
					}
				}
			}
		}		

		if( m_pWindow != NULL ) {
			m_pWindow->SendNotify(this, EventType::SELECT, m_iCurSel, iOldSel);
		}
		return true;
	}

	void TabBox::HideTabItem(std::size_t it)
	{
		m_items[it]->SetMouseEnabled(false);
		if (Box* box = dynamic_cast<Box*>(this->m_items[it])) {
			box->SetMouseChildEnabled(false);
		}
		m_items[it]->SetAlpha(0);
	}

	void TabBox::ShowTabItem(std::size_t it)
	{
		m_items[it]->SetMouseEnabled(true);
		if (Box* box = dynamic_cast<Box*>(this->m_items[it])) {
			box->SetMouseChildEnabled(true);
		}
		m_items[it]->SetAlpha(255);
	}

	bool TabBox::SelectItem( Control* pControl )
	{
		int iIndex = GetItemIndex(pControl);
		if (iIndex==-1)
			return false;
		else
			return SelectItem(iIndex);
	}

	bool TabBox::SelectItem(std::wstring pControlName)
	{
		Control* pControl = FindSubControl(pControlName);
		ASSERT(pControl);
		return SelectItem(pControl);
	}

	void TabBox::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
	{
		if( pstrName == _T("selectedid") ) SelectItem(_ttoi(pstrValue.c_str()));
		else if( pstrName == _T("fadeswitch") ) SetFadeSwitch(pstrValue == _T("true"));
		else Box::SetAttribute(pstrName, pstrValue);
	}

	void TabBox::SetFadeSwitch(bool bFadeSwitch)
	{
		m_bFadeSwith = bFadeSwitch;
	}
}
