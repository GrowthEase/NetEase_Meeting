/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CONTROL_OPTION_H_
#define UI_CONTROL_OPTION_H_

#pragma once

namespace ui
{


template<typename InheritType = Control>
class UILIB_API CheckBoxTemplate : public ButtonTemplate<InheritType>
{
public:
	CheckBoxTemplate();

	virtual void Activate() override;

	std::wstring GetSelectedStateImage(ControlStateType stateType);
	void SetSelectedStateImage(ControlStateType stateType, const std::wstring& pStrImage);

	void SetSelectedTextColor(const std::wstring& dwTextColor);
	std::wstring GetSelectedTextColor();

	void SetSelectedStateColor(ControlStateType stateType, const std::wstring& stateColor);
	std::wstring GetSelectStateColor(ControlStateType stateType);

	std::wstring GetSelectedForeStateImage(ControlStateType stateType);
	void SetSelectedForeStateImage(ControlStateType stateType, const std::wstring& pStrImage);

	bool IsSelected() const;
	virtual void Selected(bool bSelected, bool bTriggerEvent = false);

	virtual void SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue) override;

	virtual void PaintStatusColor(HDC hDC) override;
	virtual void PaintStatusImage(HDC hDC) override;
	virtual void PaintText(HDC hDC) override;

	virtual Image* GetEstimateImage() override;

	void AttachSelect(const EventCallback& callback)
	{
		OnEvent[EventType::SELECT] += callback;
	}

	void AttachUnSelect(const EventCallback& callback)
	{
		OnEvent[EventType::UNSELECT] += callback;
	}

protected:
	bool			m_bSelected = false;
	std::wstring	m_dwSelectedTextColor;
	StateColorMap	m_selectedColorMap;
	StateImageMap	m_selectedImageMap;
	StateImageMap	m_selectedForeImageMap;

private:
	void AttachClick(const EventCallback& callback);
};


#include "CheckBoxImpl.h"

typedef CheckBoxTemplate<Control> CheckBox;
typedef CheckBoxTemplate<Box> CheckBoxBox;



} // namespace ui

#endif // UI_CONTROL_OPTION_H_