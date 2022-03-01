/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "stdafx.h"
#include "TileBox.h"

namespace ui
{
	TileLayout::TileLayout()
	{
		m_szItem.cx = m_szItem.cy = 0;
	}

	CSize TileLayout::ArrangeChild(const std::vector<Control*>& m_items, UiRect rc)
	{
		// Position the elements
		if( m_szItem.cx > 0 ) m_nColumns = (rc.right - rc.left) / m_szItem.cx;
		if( m_nColumns == 0 ) m_nColumns = 1;

		int cyNeeded = 0;
		int cxWidth = rc.GetWidth() / m_nColumns;
		int deviation = rc.GetWidth() - cxWidth * m_nColumns;
		int cyHeight = 0;
		int iCount = 0;
		POINT ptTile = { rc.left, rc.top };
		int iPosX = rc.left;

		for( auto it = m_items.begin(); it != m_items.end(); it++ ) {
			auto pControl = *it;
			if( !pControl->IsVisible() ) continue;
			if( pControl->IsFloat() ) {
				SetFloatPos(pControl, rc);

				continue;
			}

			// Determine size
			UiRect rcTile(ptTile.x, ptTile.y, ptTile.x + cxWidth, ptTile.y);
			if (deviation > 0) {
				rcTile.right += 1;
				deviation--;
			}
			if( (iCount % m_nColumns) == 0 )
			{
				int iIndex = iCount;

				for( auto it = m_items.begin(); it != m_items.end(); it++ ) {
					auto pLineControl = *it;
					if( !pLineControl->IsVisible() ) continue;
					if( pLineControl->IsFloat() ) continue;

					UiRect rcMargin = pLineControl->GetMargin();
					CSize szAvailable = { rcTile.right - rcTile.left - rcMargin.left - rcMargin.right, 9999 };
					if( iIndex == iCount || (iIndex + 1) % m_nColumns == 0 ) {
						szAvailable.cx -= m_iChildMargin / 2;
					}
					else {
						szAvailable.cx -= m_iChildMargin;
					}

					if( szAvailable.cx < pControl->GetMinWidth() ) szAvailable.cx = pControl->GetMinWidth();
					if( pControl->GetMaxWidth() >= 0 && szAvailable.cx > pControl->GetMaxWidth() ) szAvailable.cx = pControl->GetMaxWidth();

					CSize szTile = pLineControl->EstimateSize(szAvailable);
					if( szTile.cx < pControl->GetMinWidth() ) szTile.cx = pControl->GetMinWidth();
					if( pControl->GetMaxWidth() >= 0 && szTile.cx > pControl->GetMaxWidth() ) szTile.cx = pControl->GetMaxWidth();
					if( szTile.cy < pControl->GetMinHeight() ) szTile.cy = pControl->GetMinHeight();
					if( szTile.cy > pControl->GetMaxHeight() ) szTile.cy = pControl->GetMaxHeight();

					cyHeight = MAX(cyHeight, szTile.cy + rcMargin.top + rcMargin.bottom);
					if( (++iIndex % m_nColumns) == 0) break;
				}
			}

			UiRect rcMargin = pControl->GetMargin();

			rcTile.left += rcMargin.left + m_iChildMargin / 2;
			rcTile.right -= rcMargin.right + m_iChildMargin / 2;
			if( (iCount % m_nColumns) == 0 ) {
				rcTile.left -= m_iChildMargin / 2;
			}

			if( ( (iCount + 1) % m_nColumns) == 0 ) {
				rcTile.right += m_iChildMargin / 2;
			}

			// Set position
			rcTile.top = ptTile.y + rcMargin.top;
			rcTile.bottom = ptTile.y + cyHeight;

			CSize szAvailable = { rcTile.right - rcTile.left, rcTile.bottom - rcTile.top };
			CSize szTile = pControl->EstimateSize(szAvailable);
			if( szTile.cx == DUI_LENGTH_STRETCH ) szTile.cx = szAvailable.cx;
			if( szTile.cy == DUI_LENGTH_STRETCH ) szTile.cy = szAvailable.cy;
			if( szTile.cx < pControl->GetMinWidth() ) szTile.cx = pControl->GetMinWidth();
			if( pControl->GetMaxWidth() >= 0 && szTile.cx > pControl->GetMaxWidth() ) szTile.cx = pControl->GetMaxWidth();
			if( szTile.cy < pControl->GetMinHeight() ) szTile.cy = pControl->GetMinHeight();
			if( szTile.cy > pControl->GetMaxHeight() ) szTile.cy = pControl->GetMaxHeight();
			UiRect rcPos((rcTile.left + rcTile.right - szTile.cx) / 2, (rcTile.top + rcTile.bottom - szTile.cy) / 2,
				(rcTile.left + rcTile.right - szTile.cx) / 2 + szTile.cx, (rcTile.top + rcTile.bottom - szTile.cy) / 2 + szTile.cy);
			pControl->SetPos(rcPos);

			if( (++iCount % m_nColumns) == 0 ) {
				ptTile.x = iPosX;
				ptTile.y += cyHeight + m_iChildMargin;
				cyHeight = 0;
			}
			else {
				ptTile.x += rcTile.GetWidth();
			}
			cyNeeded = rcTile.bottom - rc.top;
		}

		CSize size = {rc.right - rc.left, cyNeeded};
		return size;
	}

	CSize TileLayout::AjustSizeByChild(const std::vector<Control*>& m_items, CSize szAvailable)
	{
		CSize size = m_pOwner->Control::EstimateSize(szAvailable);
		size.cy = 0;

		if( m_szItem.cx > 0 ) m_nColumns = m_pOwner->GetFixedWidth() / m_szItem.cx;
		if( m_nColumns == 0 ) m_nColumns = 1;
		int rows = m_pOwner->GetCount() / m_nColumns;
		if (m_pOwner->GetCount() % m_nColumns != 0)
		{
			rows += 1;
		}
		if (m_items.size() > 0)
		{
			int childMarginTotal;
			if (m_items.size() % m_nColumns == 0)
			{
				childMarginTotal = (m_items.size() / m_nColumns - 1) * m_iChildMargin;
			}
			else
			{
				childMarginTotal = (m_items.size() / m_nColumns) * m_iChildMargin;
			}
			Control* pControl = static_cast<Control*>(m_items[0]);
			size.cy += pControl->GetFixedHeight() * rows + m_rcPadding.top + m_rcPadding.bottom + childMarginTotal;
		}

		return size;
	}

	bool TileLayout::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
	{
		bool hasAttribute = true;
		if( pstrName == _T("itemsize") ) {
			CSize szItem;
			LPTSTR pstr = NULL;
			szItem.cx = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
			szItem.cy = _tcstol(pstr + 1, &pstr, 10);   ASSERT(pstr);     
			SetItemSize(szItem);
		}
		else if( pstrName == _T("columns")) 
		{
			SetColumns(_ttoi(pstrValue.c_str()));
		}
		else 
		{
			hasAttribute = Layout::SetAttribute(pstrName, pstrValue);
		}

		return hasAttribute;
	}

	CSize TileLayout::GetItemSize() const
	{
		return m_szItem;
	}

	void TileLayout::SetItemSize(CSize szItem)
	{
		if( m_szItem.cx != szItem.cx || m_szItem.cy != szItem.cy ) {
			m_szItem = szItem;
			m_pOwner->Arrange();
		}
	}

	int TileLayout::GetColumns() const
	{
		return m_nColumns;
	}

	void TileLayout::SetColumns(int nCols)
	{
		if( nCols <= 0 ) return;
		m_nColumns = nCols;
		m_pOwner->Arrange();
	}


	TileBox::TileBox() : 
		Box(new TileLayout())
	{
	}
}
