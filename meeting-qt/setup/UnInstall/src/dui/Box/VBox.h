/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CORE_VBOX_H_
#define UI_CORE_VBOX_H_

#pragma once

namespace ui
{
	class UILIB_API VLayout : public Layout
	{
	public:
		VLayout();
		virtual CSize ArrangeChild(const std::vector<Control*>& m_items, UiRect rc) override;
		virtual CSize AjustSizeByChild(const std::vector<Control*>& m_items, CSize szAvailable) override;
	};

	class UILIB_API VBox : public Box
	{
	public:
		VBox();
	};
}
#endif // UI_CORE_VBOX_H_
