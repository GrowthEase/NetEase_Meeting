/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "stdafx.h"
#include "Progress.h"

namespace ui
{
	Progress::Progress()
	{
		m_uTextStyle = DT_SINGLELINE | DT_CENTER;
		SetFixedHeight(12);
	}

	bool Progress::IsHorizontal()
	{
		return m_bHorizontal;
	}

	void Progress::SetHorizontal(bool bHorizontal)
	{
		if( m_bHorizontal == bHorizontal ) return;

		m_bHorizontal = bHorizontal;
		Invalidate();
	}

	int Progress::GetMinValue() const
	{
		return m_nMin;
	}

	void Progress::SetMinValue(int nMin)
	{
		m_nMin = nMin;
		Invalidate();
	}

	int Progress::GetMaxValue() const
	{
		return m_nMax;
	}

	void Progress::SetMaxValue(int nMax)
	{
		m_nMax = nMax;
		Invalidate();
	}

	double Progress::GetValue() const
	{
		return m_nValue;
	}

	void Progress::SetValue(double nValue)
	{
		m_nValue = nValue;
		Invalidate();
	}

	std::wstring Progress::GetProgressImage() const
	{
		return m_progressImage.imageAttribute.imageString;
	}

	void Progress::SetProgressImage(const std::wstring& pStrImage)
	{
		m_progressImage.SetImageString(pStrImage);
		Invalidate();
	}

	void Progress::SetProgressColor(const std::wstring& dwProgressColor)
	{
		ASSERT(!GlobalManager::GetTextColor(dwProgressColor).empty());
		if( m_dwProgressColor == dwProgressColor ) return;

		m_dwProgressColor = dwProgressColor;
		Invalidate();
	}

	void Progress::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
	{
		if( pstrName == _T("hor") ) SetHorizontal(pstrValue == _T("true"));
		else if( pstrName == _T("min") ) SetMinValue(_ttoi(pstrValue.c_str()));
		else if( pstrName == _T("max") ) SetMaxValue(_ttoi(pstrValue.c_str()));
		else if( pstrName == _T("value") ) SetValue(_ttoi(pstrValue.c_str()));
		else if( pstrName == _T("isstretchfore")) SetStretchForeImage(pstrValue == _T("true"));
		else if( pstrName == _T("progresscolor") ) {
			LPCTSTR pValue = pstrValue.c_str();
			while( *pValue > _T('\0') && *pValue <= _T(' ') ) pValue = ::CharNext(pValue);
			SetProgressColor(pValue);
		}
		else if (pstrName == _T("progressimage")) SetProgressImage(pstrValue);
		else Label::SetAttribute(pstrName, pstrValue);
	}

	void Progress::PaintStatusImage(HDC hDC)
	{
		if( m_nMax <= m_nMin ) m_nMax = m_nMin + 1;
		if( m_nValue > m_nMax ) m_nValue = m_nMax;
		if( m_nValue < m_nMin ) m_nValue = m_nMin;

		UiRect rc = GetProgressPos();
		if (!m_dwProgressColor.empty()) {
			DWORD dwProgressColor = GlobalManager::ConvertTextColor(m_dwProgressColor);
			if( dwProgressColor != 0 ) {
				UiRect rcProgressColor = m_rcItem;
				if( m_bHorizontal ) {
					rcProgressColor.right = rcProgressColor.left + rc.right;
				}
				else {
					rcProgressColor.top = rcProgressColor.top + rc.top;
				}
				RenderEngine::DrawColor(hDC, rcProgressColor, dwProgressColor);
			}
		}

		if (!m_progressImage.imageAttribute.imageString.empty()) {
			m_progressImageModify.clear();
			if (m_bStretchForeImage)
				m_progressImageModify = StringHelper::Printf(_T("dest='%d,%d,%d,%d'"), rc.left, rc.top, rc.right, rc.bottom);
			else
				m_progressImageModify = StringHelper::Printf(_T("dest='%d,%d,%d,%d' source='%d,%d,%d,%d'")
				, rc.left, rc.top, rc.right, rc.bottom
				, rc.left, rc.top, rc.right, rc.bottom);

			if (!DrawImage(hDC, m_progressImage, m_progressImageModify)) {

			}
			else return;
		}
	}

	UiRect Progress::GetProgressPos()
	{
		UiRect rc;
		if( m_bHorizontal ) {
			rc.right = int((m_nValue - m_nMin) * (m_rcItem.right - m_rcItem.left) / (m_nMax - m_nMin));
			rc.bottom = m_rcItem.bottom - m_rcItem.top;
		}
		else {
			rc.top = int((m_nMax - m_nValue) * (m_rcItem.bottom - m_rcItem.top) / (m_nMax - m_nMin));
			rc.right = m_rcItem.right - m_rcItem.left;
			rc.bottom = m_rcItem.bottom - m_rcItem.top;
		}
		
		return rc;
	}

	bool Progress::IsStretchForeImage()
	{
		return m_bStretchForeImage;
	}

	void Progress::SetStretchForeImage( bool bStretchForeImage /*= true*/ )
	{
		if (m_bStretchForeImage==bStretchForeImage)		return;
		m_bStretchForeImage=bStretchForeImage;
		Invalidate();
	}
}
