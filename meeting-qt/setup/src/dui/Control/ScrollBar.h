/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CONTROL_SCROLLBAR_H_
#define UI_CONTROL_SCROLLBAR_H_

#pragma once

namespace ui
{
	class UILIB_API ScrollBar : public Control
	{
	public:
		ScrollBar();

		Box* GetOwner() const;
		void SetOwner(ScrollableBox* pOwner);

		void SetEnabled(bool bEnable = true);
		void SetFocus();
		virtual void SetVisible_(bool bVisible) override;
		virtual bool ButtonUp(EventArgs& msg) override;

		bool IsHorizontal();
		void SetHorizontal(bool bHorizontal = true);
		int GetScrollRange() const;
		bool IsValid()
		{
			return GetScrollRange() != 0;
		}
		void SetScrollRange(int nRange);
		int GetScrollPos() const;
		void SetScrollPos(int nPos);
		int GetLineSize() const;
		void SetLineSize(int nSize);
		int GetThumbMinLength() const;
		void SetThumbMinLength(int nThumbMinLength);

		bool GetShowButton1();
		void SetShowButton1(bool bShow);
		std::wstring GetButton1StateImage(ControlStateType stateType);
		void SetButton1StateImage(ControlStateType stateType, const std::wstring& pStrImage);

		bool GetShowButton2();
		void SetShowButton2(bool bShow);
		std::wstring GetButton2StateImage(ControlStateType stateType);
		void SetButton2StateImage(ControlStateType stateType, const std::wstring& pStrImage);

		std::wstring GetThumbStateImage(ControlStateType stateType);
		void SetThumbStateImage(ControlStateType stateType, const std::wstring& pStrImage);

		std::wstring GetRailStateImage(ControlStateType stateType);
		void SetRailStateImage(ControlStateType stateType, const std::wstring& pStrImage);

		std::wstring GetBkStateImage(ControlStateType stateType);
		void SetBkStateImage(ControlStateType stateType, const std::wstring& pStrImage);

		bool IsAutoHideScroll(){return m_bAutoHide;}
		void SetAutoHideScroll(bool hide);

		void SetPos(UiRect rc);
		void HandleMessage(EventArgs& event);
		bool MouseEnter(EventArgs& msg);
		bool MouseLeave(EventArgs& msg);
		void SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue);

		void Paint(HDC hDC, const UiRect& rcPaint) override;

		void PaintBk(HDC hDC);
		void PaintButton1(HDC hDC);
		void PaintButton2(HDC hDC);
		void PaintThumb(HDC hDC);
		void PaintRail(HDC hDC);

		ControlStateType GetThumbState()
		{
			return m_uThumbState;
		}

	private:
		void ScrollBar::ScrollTimeHandle();

	protected:
		enum
		{ 
			DEFAULT_SCROLLBAR_SIZE = 16,
		};

		bool m_bHorizontal = false;
		int m_nRange = 100;
		int m_nScrollPos = 0;
		int m_nLineSize = 8;
		int m_nThumbMinLength = 40;
		ScrollableBox* m_pOwner = nullptr;
		POINT ptLastMouse;
		int m_nLastScrollPos = 0;
		int m_nLastScrollOffset = 0;
		int m_nScrollRepeatDelay = 0;

		bool m_bShowButton1 = true;
		UiRect m_rcButton1;
		ControlStateType m_uButton1State = ControlStateType::NORMAL;

		bool m_bShowButton2 = true;
		UiRect m_rcButton2;
		ControlStateType m_uButton2State = ControlStateType::NORMAL;

		UiRect m_rcThumb;
		ControlStateType m_uThumbState = ControlStateType::NORMAL;

		std::wstring m_sImageModify;

		bool m_bAutoHide = true;

		StateImageMap m_bkStateImage;
		StateImageMap m_button1StateImage;
		StateImageMap m_button2StateImage;
		StateImageMap m_thumbStateImage;
		StateImageMap m_railStateImage;
		nbase::WeakCallbackFlag weakFlagOwner;
	};
}

#endif // UI_CONTROL_SCROLLBAR_H_