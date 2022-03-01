/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CORE_TABBOX_H_
#define UI_CORE_TABBOX_H_

#pragma once

namespace ui
{
	class UILIB_API TabBox : public Box
	{
	public:
		TabBox();

		virtual bool Add(Control* pControl) override;
		virtual bool AddAt(Control* pControl, std::size_t iIndex) override;
		virtual bool Remove(Control* pControl) override;
		virtual void RemoveAll() override;
		int GetCurSel() const;
		bool SelectItem(int iIndex);
		bool SelectItem(Control* pControl);
		bool SelectItem(std::wstring pControlName);
		virtual void SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue) override;

		void SetFadeSwitch(bool bFadeSwitch);
		bool IsFadeSwitch() 
		{
			return m_bFadeSwith;
		}
	
	protected:
		void ShowTabItem(std::size_t it);
		void HideTabItem(std::size_t it);

	protected:
		int m_iCurSel = -1;
		bool m_bFadeSwith = false;
	};
}
#endif // UI_CORE_TABBOX_H_
