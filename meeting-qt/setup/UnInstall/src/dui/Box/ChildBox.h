/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CORE_CHILDBOX_H_
#define UI_CORE_CHILDBOX_H_

#pragma once

namespace ui
{
	class UILIB_API ChildBox : public Box
	{
	public:
		ChildBox();

		void Init();
		virtual void SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue) override;
		void SetChildLayoutXML(std::wstring pXML);
		std::wstring GetChildLayoutXML();

	private:
		std::wstring m_pstrXMLFile;
	};
} // namespace ui
#endif // UI_CORE_CHILDBOX_H_
