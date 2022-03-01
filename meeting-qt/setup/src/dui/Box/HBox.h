/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CORE_HBOX_H_
#define UI_CORE_HBOX_H_

#pragma once

namespace ui
{
	class UILIB_API HLayout : public Layout
	{
	public:
		HLayout();
		virtual CSize ArrangeChild(const std::vector<Control*>& m_items, UiRect rc) override;
		virtual CSize AjustSizeByChild(const std::vector<Control*>& m_items, CSize szAvailable) override;
	};

	class UILIB_API HBox : public Box
	{
	public:
		HBox();
	};
}
#endif // UI_CORE_HBOX_H_
