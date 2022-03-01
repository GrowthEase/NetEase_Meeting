/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CONTROL_SLIDER_H_
#define UI_CONTROL_SLIDER_H_

#pragma once

namespace ui
{
	class UILIB_API Slider : public Progress
	{
	public:
		Slider();

		int GetChangeStep();
		void SetChangeStep(int step);
		void SetThumbSize(CSize szXY);
		UiRect GetThumbRect() const;
		std::wstring GetThumbStateImage(ControlStateType stateType);
		void SetThumbStateImage(ControlStateType stateType, const std::wstring& pStrImage);

		void HandleMessage(EventArgs& event);
		void SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue);
		void PaintStatusImage(HDC hDC);

		void AttachValueChange(const EventCallback& callback)
		{
			OnEvent[EventType::VALUECHANGE] += callback;
		}
		
		virtual UiRect GetProgressPos() override;

		UiRect GetProgressBarPadding() const;
		void SetProgressBarPadding(UiRect rc);

	protected:
		CSize m_szThumb{ 10, 10 };
		ControlStateType m_uButtonState = ControlStateType::NORMAL;
		int m_nStep = 1;
		std::wstring m_sImageModify;
		StateImageMap m_thumbStateImage;
		UiRect	m_progressBarPadding;
	};
}

#endif // UI_CONTROL_SLIDER_H_