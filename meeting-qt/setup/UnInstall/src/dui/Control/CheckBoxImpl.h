/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */



template<typename InheritType>
CheckBoxTemplate<InheritType>::CheckBoxTemplate()
{
	m_selectedColorMap.SetControl(this);
	m_selectedImageMap.SetControl(this);
	m_selectedForeImageMap.SetControl(this);
}

template<typename InheritType>
bool CheckBoxTemplate<InheritType>::IsSelected() const
{
	return m_bSelected;
}

template<typename InheritType>
void CheckBoxTemplate<InheritType>::Selected(bool bSelected, bool bTriggerEvent)
{
	if( m_bSelected == bSelected ) return;
	m_bSelected = bSelected;

	if( m_pWindow != NULL ) {
		if (bTriggerEvent)
		{
			if (m_bSelected) {
				m_pWindow->SendNotify(this, EventType::SELECT);
			}
			else {
				m_pWindow->SendNotify(this, EventType::UNSELECT);
			}
		}
	}

	Invalidate();
}

template<typename InheritType>
void CheckBoxTemplate<InheritType>::Activate()
{
	if( !IsActivatable() ) 
		return;
	Selected(!m_bSelected, true);
}

template<typename InheritType>
std::wstring CheckBoxTemplate<InheritType>::GetSelectedStateImage(ControlStateType stateType)
{
	return m_selectedImageMap[stateType].imageAttribute.imageString;
}

template<typename InheritType>
void CheckBoxTemplate<InheritType>::SetSelectedStateImage(ControlStateType stateType, const std::wstring& pStrImage)
{
	m_selectedImageMap[stateType].SetImageString(pStrImage);
	if (GetFixedWidth() == DUI_LENGTH_AUTO || GetFixedHeight() == DUI_LENGTH_AUTO) {
		ArrangeAncestor();
	}
	else {
		Invalidate();
	}
}

template<typename InheritType>
void CheckBoxTemplate<InheritType>::SetSelectedTextColor(const std::wstring& dwTextColor)
{
	m_dwSelectedTextColor = dwTextColor;
	Invalidate();
}

template<typename InheritType>
std::wstring CheckBoxTemplate<InheritType>::GetSelectedTextColor()
{
	return m_dwSelectedTextColor;
}

template<typename InheritType>
void CheckBoxTemplate<InheritType>::SetSelectedStateColor(ControlStateType stateType, const std::wstring& stateColor)
{
	m_selectedColorMap[stateType] = stateColor;
	Invalidate();
}

template<typename InheritType>
std::wstring CheckBoxTemplate<InheritType>::GetSelectStateColor(ControlStateType stateType)
{
	return m_selectedColorMap[stateType];
}

template<typename InheritType>
std::wstring CheckBoxTemplate<InheritType>::GetSelectedForeStateImage(ControlStateType stateType)
{
	return m_selectedForeImageMap[stateType].imageAttribute.imageString;
}

template<typename InheritType>
void CheckBoxTemplate<InheritType>::SetSelectedForeStateImage(ControlStateType stateType, const std::wstring& pStrImage)
{
	m_selectedForeImageMap[stateType].SetImageString(pStrImage);
	if (GetFixedWidth() == DUI_LENGTH_AUTO || GetFixedHeight() == DUI_LENGTH_AUTO) {
		ArrangeAncestor();
	}
	else {
		Invalidate();
	}
}

template<typename InheritType>
void CheckBoxTemplate<InheritType>::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
{
	if( pstrName == _T("selected") ) Selected(pstrValue == _T("true"), true);
	else if( pstrName == _T("selectednormalimage") ) SetSelectedStateImage(ControlStateType::NORMAL, pstrValue);
	else if( pstrName == _T("selectedhotimage") ) SetSelectedStateImage(ControlStateType::HOT, pstrValue);
	else if( pstrName == _T("selectedpushedimage") ) SetSelectedStateImage(ControlStateType::PUSHED, pstrValue);
	else if( pstrName == _T("selecteddisabledimage") ) SetSelectedStateImage(ControlStateType::DISABLED, pstrValue);
	else if( pstrName == _T("selectedtextcolor") ) {
		SetSelectedTextColor(pstrValue);
	}
	else if( pstrName == _T("selectednormalcolor") ) SetSelectedStateColor(ControlStateType::NORMAL, pstrValue);
	else if( pstrName == _T("selectedhotcolor") ) SetSelectedStateColor(ControlStateType::HOT, pstrValue);
	else if( pstrName == _T("selectedpushedcolor") ) SetSelectedStateColor(ControlStateType::PUSHED, pstrValue);
	else if( pstrName == _T("selecteddisabledcolor") ) SetSelectedStateColor(ControlStateType::DISABLED, pstrValue);
	else if (pstrName == _T("selectedforenormalimage")) SetSelectedForeStateImage(ControlStateType::NORMAL, pstrValue);
	else if (pstrName == _T("selectedforehotimage")) SetSelectedForeStateImage(ControlStateType::HOT, pstrValue);
	else if (pstrName == _T("selectedforepushedimage")) SetSelectedForeStateImage(ControlStateType::PUSHED, pstrValue);
	else if (pstrName == _T("selectedforedisabledimage")) SetSelectedForeStateImage(ControlStateType::DISABLED, pstrValue);
	else __super::SetAttribute(pstrName, pstrValue);
}

template<typename InheritType>
void CheckBoxTemplate<InheritType>::PaintStatusColor(HDC hDC) 
{
	if (!IsSelected())
	{
		__super::PaintStatusColor(hDC);
		return;
	}

	m_selectedColorMap.PaintStatusColor(hDC, m_rcPaint, m_uButtonState);
}

template<typename InheritType>
void CheckBoxTemplate<InheritType>::PaintStatusImage(HDC hDC)
{
	if (!IsSelected())
	{
		__super::PaintStatusImage(hDC);
		return;
	}

	m_selectedImageMap.PaintStatusImage(hDC, m_uButtonState);
	m_selectedForeImageMap.PaintStatusImage(hDC, m_uButtonState);
}

template<typename InheritType>
void CheckBoxTemplate<InheritType>::PaintText(HDC hDC)
{
	if (!IsSelected())
	{
		__super::PaintText(hDC);
		return;
	}

	if( GetText().empty() ) return;
	UiRect rc = m_rcItem;
	rc.left += m_rcTextPadding.left;
	rc.right -= m_rcTextPadding.right;
	rc.top += m_rcTextPadding.top;
	rc.bottom -= m_rcTextPadding.bottom;

	std::wstring newTextColor = m_dwSelectedTextColor.empty() ? m_textColorMap[ControlStateType::NORMAL] : m_dwSelectedTextColor;
	DWORD dwTextColor = GlobalManager::ConvertTextColor(newTextColor);
	DWORD dwDisabledTextColor = GlobalManager::ConvertTextColor(m_textColorMap[ControlStateType::DISABLED]);
	RenderEngine::DrawText(hDC, rc, GetText(), IsEnabled()?dwTextColor:dwDisabledTextColor, \
		m_iFont, m_uTextStyle);
}

template<typename InheritType>
Image* CheckBoxTemplate<InheritType>::GetEstimateImage()
{
	Image* estimateImage = __super::GetEstimateImage();
	if (!estimateImage) {
		estimateImage = m_selectedImageMap.GetEstimateImage();
	}

	return estimateImage;
}



