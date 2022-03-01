/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CONTROL_LABEL_H_
#define UI_CONTROL_LABEL_H_

#pragma once


namespace ui
{
	template<typename InheritType = Control>
	class UILIB_API LabelTemplate : public InheritType
	{
	public:
		LabelTemplate();

		// 文本相关
		virtual std::wstring GetText() const;
		virtual std::string GetUTF8Text() const;
		virtual void SetText(const std::wstring& pstrText);
		virtual void SetUTF8Text(const std::string& pstrText);
		virtual void SetTextId(const std::wstring& strTextId);

		void SetTextStyle(UINT uStyle);
		UINT GetTextStyle() const;

		void SetStateTextColor(ControlStateType stateType, const std::wstring& dwTextColor);
		std::wstring GetStateTextColor(ControlStateType stateType);

		void SetFont(int index);
		int GetFont() const;
		UiRect GetTextPadding() const;
		void SetTextPadding(UiRect rc);
		bool IsSingleLine();
		void SetSingleLine(bool bSingleLine);
		bool IsLineLimit();
		void SetLineLimit(bool bLineLimit);

		virtual CSize EstimateText(CSize szAvailable, bool& reEstimateSize) override;

		virtual void SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue) override;

		virtual void PaintText(HDC hDC) override;

	protected:
		StateColorMap m_textColorMap;
		std::wstring m_sText;
		std::wstring m_TextId;
		int		m_iFont = 1;
		UINT	m_uTextStyle = DT_LEFT | DT_TOP | DT_END_ELLIPSIS | DT_NOCLIP | DT_SINGLELINE;
		UiRect	m_rcTextPadding;
		bool    m_bSingleLine = true;
		bool    m_bLineLimit = false;
		int						m_hAlign = DT_LEFT;
		int						m_vAlign = DT_CENTER;
		std::wstring			m_TextValue;
	};

	#include "LabelImpl.h"

	typedef LabelTemplate<Control> Label;
	typedef LabelTemplate<Box> LabelBox;
}

#endif // UI_CONTROL_LABEL_H_