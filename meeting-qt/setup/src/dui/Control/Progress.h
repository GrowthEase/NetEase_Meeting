/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CONTROL_PROGRESS_H_
#define UI_CONTROL_PROGRESS_H_

#pragma once

namespace ui
{
	class UILIB_API Progress : public LabelTemplate<Control>
	{
	public:
		Progress();

		bool IsHorizontal();
		void SetHorizontal(bool bHorizontal = true);
		bool IsStretchForeImage();
		void SetStretchForeImage(bool bStretchForeImage = true);
		int GetMinValue() const;
		void SetMinValue(int nMin);
		int GetMaxValue() const;
		void SetMaxValue(int nMax);
		double GetValue() const;
		void SetValue(double nValue);
		std::wstring GetProgressImage() const;
		void SetProgressImage(const std::wstring& pStrImage);
		std::wstring GetProgressColor() const
		{
			return m_dwProgressColor;
		}
		void SetProgressColor(const std::wstring& dwProgressColor);

		void SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue);
		void PaintStatusImage(HDC hDC);

		virtual UiRect GetProgressPos();

	protected:
		bool m_bHorizontal = true;
		bool m_bStretchForeImage = true;
		int m_nMax = 100;
		int m_nMin = 0;
		double m_nValue = 0;
		std::wstring m_dwProgressColor;
		Image m_progressImage;
		std::wstring m_progressImageModify;
	};

} // namespace ui

#endif // UI_CONTROL_PROGRESS_H_
