/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "stdafx.h"
#include "ChildBox.h"

namespace ui
{
	ChildBox::ChildBox()
	{

	}

	void ChildBox::Init()
	{
		if (!m_pstrXMLFile.empty())
		{
			Box* pChildWindow = static_cast<Box*>(GlobalManager::CreateBoxWithCache(m_pstrXMLFile.c_str(), CreateControlCallback()));
			if (pChildWindow) {
				this->Add(pChildWindow);
			}
			else {
				ASSERT(FALSE);
				this->RemoveAll();
			}
		}
	}

	void ChildBox::SetAttribute( const::std::wstring& pstrName, const std::wstring& pstrValue )
	{
		if( pstrName == _T("xmlfile") )
			SetChildLayoutXML(pstrValue);
		else
			Box::SetAttribute(pstrName,pstrValue);
	}

	void ChildBox::SetChildLayoutXML( std::wstring pXML )
	{
		m_pstrXMLFile=pXML;
	}

	std::wstring ChildBox::GetChildLayoutXML()
	{
		return m_pstrXMLFile;
	}

} // namespace ui
