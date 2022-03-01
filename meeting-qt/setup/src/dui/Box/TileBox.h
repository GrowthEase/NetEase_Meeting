/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CORE_TILEBOX_H_
#define UI_CORE_TILEBOX_H_

#pragma once

namespace ui
{
	class UILIB_API TileLayout : public Layout
	{
	public:
		TileLayout();
		virtual CSize ArrangeChild(const std::vector<Control*>& m_items, UiRect rc) override;
		virtual CSize AjustSizeByChild(const std::vector<Control*>& m_items, CSize szAvailable) override;

		virtual bool SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue) override;

		CSize GetItemSize() const;
		void SetItemSize(CSize szItem);
		int GetColumns() const;
		void SetColumns(int nCols);

	protected:
		CSize m_szItem;
		int m_nColumns = 1;
	};

	class UILIB_API TileBox : public Box
	{
	public:
		TileBox();
	};
}
#endif // UI_CORE_TILEBOX_H_
