/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"

namespace ui
{


PlaceHolder::PlaceHolder()
{

}

PlaceHolder::~PlaceHolder()
{
	
}

std::wstring PlaceHolder::GetName() const
{
	return m_sName;
}

std::string PlaceHolder::GetUTF8Name() const
{
	int multiLength = WideCharToMultiByte(CP_UTF8, NULL, m_sName.c_str(), -1, NULL, 0, NULL, NULL);
	if (multiLength <= 0)
		return "";
	std::unique_ptr<char[]> strName(new char[multiLength]);
	WideCharToMultiByte(CP_UTF8, NULL, m_sName.c_str(), -1, strName.get(), multiLength, NULL, NULL);

	std::string res = strName.get();

	return res;
}

void PlaceHolder::SetName(const std::wstring& pstrName)
{
	m_sName = pstrName;
}

void PlaceHolder::SetUTF8Name(const std::string&  pstrName)
{
	int wideLength = MultiByteToWideChar(CP_UTF8, NULL, pstrName.c_str(), -1, NULL, 0);
	if (wideLength <= 0)
	{
		m_sName = _T("");
		return;
	}
	std::unique_ptr<wchar_t[]> strName(new wchar_t[wideLength]);
	MultiByteToWideChar(CP_UTF8, NULL, pstrName.c_str(), -1, strName.get(), wideLength);

	m_sName = strName.get();
}

Window* PlaceHolder::GetWindow() const
{
	return m_pWindow;
}

void PlaceHolder::SetWindow(Window* pManager, Box* pParent, bool bInit)
{
	m_pWindow = pManager;
	m_pParent = pParent;
	if (bInit && m_pParent) Init();
}

void PlaceHolder::SetWindow(Window* pManager)
{
	m_pWindow = pManager;
}

void PlaceHolder::Init()
{
	DoInit();
}

void PlaceHolder::DoInit()
{

}

CSize PlaceHolder::EstimateSize(CSize szAvailable)
{
	return m_cxyFixed;
}

bool PlaceHolder::IsVisible() const
{
	return m_bVisible && m_bInternVisible;
}

bool PlaceHolder::IsFloat() const
{
	return m_bFloat;
}

void PlaceHolder::SetFloat(bool bFloat)
{
	if (m_bFloat == bFloat) return;

	m_bFloat = bFloat;
	ArrangeAncestor();
}

int PlaceHolder::GetFixedWidth() const
{
	return m_cxyFixed.cx;
}

void PlaceHolder::SetFixedWidth(int cx, bool arrange)
{
	if (cx < 0 && cx != DUI_LENGTH_STRETCH && cx != DUI_LENGTH_AUTO) {
		ASSERT(FALSE);
		return;
	}
	if (m_cxyFixed.cx != cx)
	{
		m_cxyFixed.cx = cx;

		if (arrange) {
			ArrangeAncestor();
		}
		else {
			m_bReEstimateSize = true;
		}
	}
	//if( !m_bFloat ) ArrangeAncestor();
	//else Arrange();
}

int PlaceHolder::GetFixedHeight() const
{
	return m_cxyFixed.cy;
}

void PlaceHolder::SetFixedHeight(int cy)
{
	if (cy < 0 && cy != DUI_LENGTH_STRETCH && cy != DUI_LENGTH_AUTO) {
		ASSERT(FALSE);
		return;
	}
	if (m_cxyFixed.cy != cy)
	{
		m_cxyFixed.cy = cy;

		ArrangeAncestor();
	}
	//if( !m_bFloat ) ArrangeAncestor();
	//else Arrange();
}

int PlaceHolder::GetMinWidth() const
{
	return m_cxyMin.cx;
}

void PlaceHolder::SetMinWidth(int cx)
{
	if (m_cxyMin.cx == cx) return;

	if (cx < 0) return;
	m_cxyMin.cx = cx;
	if (!m_bFloat) ArrangeAncestor();
	else Arrange();
}

int PlaceHolder::GetMaxWidth() const
{
	return m_cxyMax.cx;
}

void PlaceHolder::SetMaxWidth(int cx)
{
	if (m_cxyMax.cx == cx) return;

	m_cxyMax.cx = cx;
	if (!m_bFloat) ArrangeAncestor();
	else Arrange();
}

int PlaceHolder::GetMinHeight() const
{
	return m_cxyMin.cy;
}

void PlaceHolder::SetMinHeight(int cy)
{
	if (m_cxyMin.cy == cy) return;

	if (cy < 0) return;
	m_cxyMin.cy = cy;
	if (!m_bFloat) ArrangeAncestor();
	else Arrange();
}

int PlaceHolder::GetMaxHeight() const
{
	return m_cxyMax.cy;
}

void PlaceHolder::SetMaxHeight(int cy)
{
	if (m_cxyMax.cy == cy) return;

	m_cxyMax.cy = cy;
	if (!m_bFloat) ArrangeAncestor();
	else Arrange();
}

int PlaceHolder::GetWidth() const
{
	return m_rcItem.right - m_rcItem.left;
}

int PlaceHolder::GetHeight() const
{
	return m_rcItem.bottom - m_rcItem.top;
}

UiRect PlaceHolder::GetPos(bool bContainShadow) const
{
	return m_rcItem;
}

void PlaceHolder::SetPos(UiRect rc)
{
	m_rcItem = rc;
}

void PlaceHolder::Arrange()
{
	if (GetFixedWidth() == DUI_LENGTH_AUTO || GetFixedHeight() == DUI_LENGTH_AUTO)
	{
		ArrangeAncestor();
	}
	else
	{
		ArrangeSelf();
	}
}

void PlaceHolder::ArrangeAncestor()
{
	m_bReEstimateSize = true;
	if (!m_pWindow || !m_pWindow->GetRoot())
	{
		if (GetParent()) {
			GetParent()->ArrangeSelf();
		}
		else {
			ArrangeSelf();
		}
	}
	else
	{
		Control* parent = GetParent();
		while (parent && (parent->GetFixedWidth() == DUI_LENGTH_AUTO || parent->GetFixedHeight() == DUI_LENGTH_AUTO))
		{
			parent->SetReEstimateSize(true);
			parent = parent->GetParent();
		}
		if (parent)
		{
			parent->ArrangeSelf();
		}
		else	//说明root具有AutoAdjustSize属性
		{
			m_pWindow->GetRoot()->ArrangeSelf();
		}
	}

}

void PlaceHolder::ArrangeSelf()
{
	if (!IsVisible()) return;
	m_bReEstimateSize = true;
	m_bIsArranged = true;
	Invalidate();

	if (m_pWindow != NULL) m_pWindow->SetArrange(true);
}

void PlaceHolder::Invalidate() const
{
	if (!IsVisible()) return;

	UiRect invalidateRc = GetPosWithScrollOffset();
	if (m_pWindow != NULL) m_pWindow->Invalidate(invalidateRc);
}

UiRect PlaceHolder::GetPosWithScrollOffset() const
{
	UiRect pos = GetPos();
	pos.Offset(-GetScrollOffset().x, -GetScrollOffset().y);
	return pos;
}

CPoint PlaceHolder::GetScrollOffset() const
{
	CPoint scrollPos;
	Control* parent = GetParent();
	ListBox* lbParent = dynamic_cast<ListBox*>(parent);
	if (lbParent && lbParent->IsVScrollBarValid() && IsFloat()) {
		return scrollPos;
	}
	while (parent && (!dynamic_cast<ListBox*>(parent) || !dynamic_cast<ListBox*>(parent)->IsVScrollBarValid()))
	{
		parent = parent->GetParent();
	}

	if (parent) {	//说明控件在Listbox内部
		ListBox* listbox = (ListBox*)parent;
		scrollPos.x = listbox->GetScrollPos().cx;
		scrollPos.y = listbox->GetScrollPos().cy;
	}

	return scrollPos;
}

bool PlaceHolder::IsArranged() const
{
	return m_bIsArranged;
}


bool IsChild(PlaceHolder* pAncestor, PlaceHolder* pControl)
{
	while (pControl && pControl != pAncestor)
	{
		pControl = pControl->GetParent();
	}

	return pControl != nullptr;
}


}