/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"

namespace ui {

WindowBuilder::WindowBuilder()
{

}

Box* WindowBuilder::Create(STRINGorID xml, CreateControlCallback pCallback, 
	Window* pManager, Box* pParent, Box* userDefinedBox)
{
	//资源ID为0-65535，两个字节；字符串指针为4个字节
	//字符串以<开头认为是XML字符串，否则认为是XML文件

	if( HIWORD(xml.m_lpstr) != NULL ) {
		if( *(xml.m_lpstr) == _T('<') ) {
			if( !m_xml.Load(xml.m_lpstr) ) return NULL;
		}
		else if (GlobalManager::IsUseZip())
		{
			std::wstring sFile = GlobalManager::GetResourcePath();
			sFile += xml.m_lpstr;
			HGLOBAL hGlobal = GlobalManager::GetData(sFile);
			if (hGlobal)
			{
				std::string src((LPSTR)GlobalLock(hGlobal), GlobalSize(hGlobal));
				std::wstring string_resourse;
				StringHelper::MBCSToUnicode(src.c_str(), string_resourse, CP_UTF8);
				GlobalFree(hGlobal);
				if (!m_xml.Load(string_resourse.c_str())) return NULL;
			}
			else
			{
				if (!m_xml.LoadFromFile(xml.m_lpstr)) return NULL;
			}
		}
		else
		{
			if( !m_xml.LoadFromFile(xml.m_lpstr) ) return NULL;
		}
	}
	else {
		ASSERT(FALSE);
	}

	return Create(pCallback, pManager, pParent, userDefinedBox);
}

Box* WindowBuilder::Create(CreateControlCallback pCallback, Window* pManager, Box* pParent, Box* userDefinedBox)
{
	m_createControlCallback = pCallback;
	CMarkupNode root = m_xml.GetRoot();
	if( !root.IsValid() ) return NULL;

	if( pManager ) {
		std::wstring pstrClass;
		int nAttributes = 0;
		std::wstring pstrName;
		std::wstring pstrValue;
		LPTSTR pstr = NULL;
		pstrClass = root.GetName();

		if( pstrClass == _T("Global") )
		{
			int nAttributes = root.GetAttributeCount();
			for( int i = 0; i < nAttributes; i++ ) {
				pstrName = root.GetAttributeName(i);
				pstrValue = root.GetAttributeValue(i);
				if( pstrName == _T("disabledfontcolor") ) {
					GlobalManager::SetDefaultDisabledTextColor(pstrValue);
				} 
				else if( pstrName == _T("defaultfontcolor") ) {	
					GlobalManager::SetDefaultTextColor(pstrValue);
				}
				else if( pstrName == _T("linkfontcolor") ) {
					DWORD clrColor = GlobalManager::ConvertTextColor(pstrValue);
					GlobalManager::SetDefaultLinkFontColor(clrColor);
				} 
				else if( pstrName == _T("linkhoverfontcolor") ) {
					DWORD clrColor = GlobalManager::ConvertTextColor(pstrValue);
					GlobalManager::SetDefaultLinkHoverFontColor(clrColor);
				} 
				else if( pstrName == _T("selectedcolor") ) {
					DWORD clrColor = GlobalManager::ConvertTextColor(pstrValue);
					GlobalManager::SetDefaultSelectedBkColor(clrColor);
				}
			}
		}
		else if( pstrClass == _T("Window") ) {
			if( pManager->GetHWND() ) {
				int nAttributes = root.GetAttributeCount();
				for( int i = 0; i < nAttributes; i++ ) {
					pstrName = root.GetAttributeName(i);
					pstrValue = root.GetAttributeValue(i);
					if( pstrName == _T("size") ) {
						LPTSTR pstr = NULL;
						int cx = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
						int cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr); 
						pManager->SetInitSize(cx, cy);
					} 
					else if( pstrName == _T("heightpercent") ) {
						double heightPercent = _ttof(pstrValue.c_str());
						pManager->SetHeightPercent(heightPercent);

						MONITORINFO oMonitor = {}; 
						oMonitor.cbSize = sizeof(oMonitor);
						::GetMonitorInfo(::MonitorFromWindow(pManager->GetHWND(), MONITOR_DEFAULTTOPRIMARY), &oMonitor);
						int windowHeight = int((oMonitor.rcWork.bottom - oMonitor.rcWork.top) * heightPercent);
						int minHeight = pManager->GetMinInfo().cy;
						int maxHeight = pManager->GetMaxInfo().cy;
						if (minHeight != 0 && windowHeight < minHeight) {
							windowHeight = minHeight;
						}
						if (maxHeight != 0 && windowHeight > maxHeight) {
							windowHeight = maxHeight;
						}

						CSize xy = pManager->GetInitSize();
						pManager->SetInitSize(xy.cx, windowHeight);
					}
					else if( pstrName == _T("sizebox") ) {
						UiRect rcSizeBox;
						LPTSTR pstr = NULL;
						rcSizeBox.left = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
						rcSizeBox.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
						rcSizeBox.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
						rcSizeBox.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
						pManager->SetSizeBox(rcSizeBox);
					}
					else if( pstrName == _T("caption") ) {
						UiRect rcCaption;
						LPTSTR pstr = NULL;
						rcCaption.left = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
						rcCaption.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
						rcCaption.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
						rcCaption.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
						pManager->SetCaptionRect(rcCaption);
					}
					else if( pstrName == _T("textid") ) {
						pManager->SetTextId(pstrValue);
					}
					else if( pstrName == _T("roundcorner") ) {
						LPTSTR pstr = NULL;
						int cx = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
						int cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr); 
						pManager->SetRoundCorner(cx, cy);
					} 
					else if( pstrName == _T("mininfo") ) {
						LPTSTR pstr = NULL;
						int cx = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
						int cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr); 
						pManager->SetMinInfo(cx, cy);
					}
					else if( pstrName == _T("maxinfo") ) {
						LPTSTR pstr = NULL;
						int cx = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
						int cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr); 
						pManager->SetMaxInfo(cx, cy);
					}
					else if( pstrName == _T("shadowattached") ) {
						pManager->SetShadowAttached(pstrValue == _T("true"));
					}
					else if (pstrName == _T("custom_shadow")) {
						UiRect rc;
						LPTSTR pstr = NULL;
						rc.left = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);
						rc.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);
						rc.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);
						rc.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);
						pManager->SetCustomShadowRect(rc);
					}
				}
			}
		}

		if( pstrClass == _T("Global") ) {
			for( CMarkupNode node = root.GetChild() ; node.IsValid(); node = node.GetSibling() ) {
				pstrClass = node.GetName();
				if( pstrClass == _T("Image") ) {
					ASSERT(FALSE);	//废弃
				}
				else if( pstrClass == _T("Font") ) {
					nAttributes = node.GetAttributeCount();
					std::wstring pFontName;
					int size = 12;
					bool bold = false;
					bool underline = false;
					bool italic = false;
					for( int i = 0; i < nAttributes; i++ ) {
						pstrName = node.GetAttributeName(i);
						pstrValue = node.GetAttributeValue(i);
						if( pstrName == _T("name") ) {
							pFontName = pstrValue;
						}
						else if( pstrName == _T("size") ) {
							size = _tcstol(pstrValue.c_str(), &pstr, 10);
						}
						else if( pstrName == _T("bold") ) {
							bold = (pstrValue == _T("true"));
						}
						else if( pstrName == _T("underline") ) {
							underline = (pstrValue == _T("true"));
						}
						else if( pstrName == _T("italic") ) {
							italic = (pstrValue == _T("true"));
						}
						else if( pstrName == _T("default") ) {
							ASSERT(FALSE);//废弃
						}
					}
					if( !pFontName.empty() ) {
						GlobalManager::AddFont(pFontName, size, bold, underline, italic);
						//if( defaultfont ) pManager->SetDefaultFont(pFontName, size, bold, underline, italic);
					}
				}
				else if( pstrClass == _T("Class") ) {
					nAttributes = node.GetAttributeCount();
					std::wstring pControlName;
					std::wstring pControlValue;
					for( int i = 0; i < nAttributes; i++ ) {
						pstrName = node.GetAttributeName(i);
						pstrValue = node.GetAttributeValue(i);
						if( pstrName == _T("name") ) {
							pControlName = pstrValue;
						}
						else if( pstrName == _T("value") ) {
							pControlValue = pstrValue;
						}
					}
					if( !pControlName.empty() ) {
						GlobalManager::AddClass(pControlName, pControlValue);
					}
				}
				else if( pstrClass == _T("TextColor") ) {
					nAttributes = node.GetAttributeCount();
					std::wstring pName;
					std::wstring pValue;
					for( int i = 0; i < nAttributes; i++ ) {
						pstrName = node.GetAttributeName(i);
						pstrValue = node.GetAttributeValue(i);
						if( pstrName == _T("name") ) {
							pName = pstrValue;
						}
						else if( pstrName == _T("value") ) {
							pValue = pstrValue;
						}
					}
					if( !pName.empty()) {
						GlobalManager::AddTextColor(pName, pValue);
					}
				}
			}
		}
		else if ( pstrClass == _T("Window") )
		{
			for( CMarkupNode node = root.GetChild() ; node.IsValid(); node = node.GetSibling() ) {
				pstrClass = node.GetName();
				if( pstrClass == _T("Class") ) {
					nAttributes = node.GetAttributeCount();
					std::wstring pControlName;
					std::wstring pControlValue;
					for( int i = 0; i < nAttributes; i++ ) {
						pstrName = node.GetAttributeName(i);
						pstrValue = node.GetAttributeValue(i);
						if( pstrName == _T("name") ) {
							pControlName = pstrValue;
						}
						else if( pstrName == _T("value") ) {
							pControlValue = pstrValue;
						}
					}
					if( !pControlName.empty() ) {
						ASSERT( GlobalManager::GetClassAttributes(pControlName).empty() );	//窗口中的Class不能与全局的重名
						pManager->AddClass(pControlName, pControlValue);
					}
				}
			}
		}
	}

	for( CMarkupNode node = root.GetChild() ; node.IsValid(); node = node.GetSibling() ) {
		std::wstring pstrClass = node.GetName();
		if( pstrClass == _T("Image") || pstrClass == _T("Font")
			|| pstrClass == _T("Class") || pstrClass == _T("TextColor") ) {

		}
		else {
			if (!userDefinedBox) {
				return (Box*)_Parse(&root, pParent, pManager);
			}
			else {
				int nAttributes = node.GetAttributeCount();
				for( int i = 0; i < nAttributes; i++ ) {
					ASSERT(i == 0 || _tcscmp(node.GetAttributeName(i), _T("class")) != 0);	//class必须是第一个属性
					userDefinedBox->SetAttribute(node.GetAttributeName(i), node.GetAttributeValue(i));
				}
				
				_Parse(&node, userDefinedBox, pManager);
				
				return userDefinedBox;
			}
		}
	}

	return nullptr;
}

CMarkup* WindowBuilder::GetMarkup()
{
    return &m_xml;
}

void WindowBuilder::GetLastErrorMessage(LPTSTR pstrMessage, SIZE_T cchMax) const
{
    return m_xml.GetLastErrorMessage(pstrMessage, cchMax);
}

void WindowBuilder::GetLastErrorLocation(LPTSTR pstrSource, SIZE_T cchMax) const
{
    return m_xml.GetLastErrorLocation(pstrSource, cchMax);
}

Control* WindowBuilder::_Parse(CMarkupNode* pRoot, Control* pParent, Window* pManager)
{
    Control* pReturn = NULL;
    for( CMarkupNode node = pRoot->GetChild() ; node.IsValid(); node = node.GetSibling() ) {
        std::wstring pstrClass = node.GetName();
		if( pstrClass == _T("Image") || pstrClass == _T("Font")
			|| pstrClass == _T("Class") || pstrClass == _T("TextColor") ) {
				continue;
		}

        Control* pControl = NULL;
        if( pstrClass == _T("Include") ) {
            if( !node.HasAttributes() ) continue;
            int count = 1;
            LPTSTR pstr = NULL;
            TCHAR szValue[500] = { 0 };
            SIZE_T cchLen = lengthof(szValue) - 1;
            if ( node.GetAttributeValue(_T("count"), szValue, cchLen) )
                count = _tcstol(szValue, &pstr, 10);
            cchLen = lengthof(szValue) - 1;
            if ( !node.GetAttributeValue(_T("source"), szValue, cchLen) ) continue;
            for ( int i = 0; i < count; i++ ) {
                WindowBuilder builder;
                pControl = builder.Create((LPCTSTR)szValue, m_createControlCallback, pManager, (Box*)pParent);
            }
            continue;
        }
        else {
			pControl = GetUiLibControl(pstrClass);
			bool ret = AttachXmlEvent(pstrClass, node, pParent);
			if (ret) {
				continue;
			}
			
            // User-supplied control factory
            if( pControl == NULL ) {
				pControl = GlobalManager::CreateControl(pstrClass);
            }

            if( pControl == NULL && m_createControlCallback ) {
                pControl = m_createControlCallback(pstrClass);
            }
        }

		if( pControl == NULL )
		{
			ASSERT(FALSE);
			continue;
		}

		pControl->SetWindow(pManager);
		// Process attributes
		if( node.HasAttributes() ) {
			// Set ordinary attributes
			int nAttributes = node.GetAttributeCount();
			for( int i = 0; i < nAttributes; i++ ) {
				ASSERT(i == 0 || _tcscmp(node.GetAttributeName(i), _T("class")) != 0);	//class必须是第一个属性
				pControl->SetAttribute(node.GetAttributeName(i), node.GetAttributeValue(i));
			}
		}

        // Add children
        if( node.HasChildren() ) {
            _Parse(&node, (Box*)pControl, pManager);
        }

		// Attach to parent
        // 因为某些属性和父窗口相关，比如selected，必须先Add到父窗口
		if( pParent != NULL ) {
			IContainer* pContainer = dynamic_cast<IContainer*>(pParent);
			ASSERT(pContainer);
			if( pContainer == NULL ) return NULL;
			if( !pContainer->Add(pControl) ) {
				ASSERT(FALSE);
				delete pControl;
				continue;
			}
		}
        
        // Return first item
        if( pReturn == NULL ) pReturn = pControl;
    }
    return pReturn;
}

Control* WindowBuilder::GetUiLibControl(const std::wstring& pstrClass)
{
	Control* pControl = nullptr;
	SIZE_T cchLen = pstrClass.length();
	switch( cchLen ) {
	case 3:
		if( pstrClass == DUI_CTR_BOX )					  pControl = new Box;
		break;
	case 4:
		if( pstrClass == DUI_CTR_HBOX )					  pControl = new HBox;
		else if( pstrClass == DUI_CTR_VBOX )			  pControl = new VBox;
		break;
	case 5:
		if( pstrClass == DUI_CTR_COMBO )                  pControl = new Combo;
		else if( pstrClass == DUI_CTR_LABEL )             pControl = new Label;
		break;
	case 6:
		if( pstrClass == DUI_CTR_BUTTON )                 pControl = new Button;
		else if( pstrClass == DUI_CTR_OPTION )            pControl = new Option;
		else if( pstrClass == DUI_CTR_SLIDER )            pControl = new Slider;
		else if( pstrClass == DUI_CTR_TABBOX )			  pControl = new TabBox;
		break;
	case 7:
		if( pstrClass == DUI_CTR_CONTROL )                pControl = new Control;
		else if( pstrClass == DUI_CTR_TILEBOX )		  	  pControl = new TileBox;
		//else if( pstrClass == DUI_CTR_ACTIVEX )           pControl = new ActiveX;
		break;
	case 8:
		if( pstrClass == DUI_CTR_PROGRESS )               pControl = new Progress;
		else if( pstrClass == DUI_CTR_RICHEDIT )          pControl = new RichEdit;
		else if( pstrClass == DUI_CTR_CHECKBOX )		  pControl = new CheckBox;
		//else if( pstrClass == DUI_CTR_DATETIME )		  pControl = new DateTime;
		else if( pstrClass == DUI_CTR_TREEVIEW )		  pControl = new TreeView;
		else if( pstrClass == DUI_CTR_TREENODE )		  pControl = new TreeNode;
		else if( pstrClass == DUI_CTR_HLISTBOX )		  pControl = new ListBox(new HLayout, new Facade);
		else if( pstrClass == DUI_CTR_VLISTBOX )          pControl = new ListBox(new VLayout, new Facade);
		else if ( pstrClass == DUI_CTR_CHILDBOX )		  pControl = new ChildBox;
		else if( pstrClass == DUI_CTR_LABELBOX )          pControl = new LabelBox;
		break;
	case 9:
		if( pstrClass == DUI_CTR_SCROLLBAR )			  pControl = new ScrollBar; 
		else if( pstrClass == DUI_CTR_BUTTONBOX )         pControl = new ButtonBox;
		else if( pstrClass == DUI_CTR_OPTIONBOX )         pControl = new OptionBox;
		break;
	case 10:
		//if( pstrClass == DUI_CTR_WEBBROWSER )			  pControl = new WebBrowser;
		break;
	case 11:
		if( pstrClass == DUI_CTR_TILELISTBOX )			  pControl = new ListBox(new TileLayout, new Facade);
		else if( pstrClass == DUI_CTR_CHECKBOXBOX )		  pControl = new CheckBoxBox;
		break;
	case 14:
		break;
	case 15:
		break;
	case 16:
		if( pstrClass == DUI_CTR_LISTLABELELEMENT )		  pControl = new ListLabelElement;
		break;
	case 20:
		if( pstrClass == DUI_CTR_LISTCONTAINERELEMENT )   pControl = new ListContainerElement;
		break;
	}

	return pControl;
}


bool WindowBuilder::AttachXmlEvent(const std::wstring& pstrClass, CMarkupNode& node, Control* pParent)
{
	if (pstrClass != L"Event" && pstrClass != L"BubbledEvent") {
		return false;
	}
	auto nAttributes = node.GetAttributeCount();
	std::wstring pType;
	std::wstring pReceiver;
	std::wstring pApplyAttribute;
	std::wstring pstrName;
	std::wstring pstrValue;
	for( int i = 0; i < nAttributes; i++ ) {
		pstrName = node.GetAttributeName(i);
		pstrValue = node.GetAttributeValue(i);
		ASSERT(i != 0 || pstrName == _T("type"));
		ASSERT(i != 1 || pstrName == _T("receiver"));
		ASSERT(i != 2 || pstrName == _T("applyattribute"));
		if( pstrName == _T("type") ) {
			pType = pstrValue;
		}
		else if( pstrName == _T("receiver") ) {
			pReceiver = pstrValue;
		}
		else if( pstrName == _T("applyattribute") ) {
			pApplyAttribute = pstrValue;
		}
	}

	auto typeList = StringHelper::Split(pType, L" ");
	auto receiverList = StringHelper::Split(pReceiver, L" ");
	for (auto itType = typeList.begin(); itType != typeList.end(); itType++) {
		for (auto itReceiver = receiverList.begin(); itReceiver != receiverList.end(); itReceiver++) {
			EventType eventType = StringToEnum(*itType);
			auto callback = std::bind(&Control::OnApplyAttributeList, pParent, *itReceiver, pApplyAttribute, std::placeholders::_1);
			if (pstrClass == L"Event") {
				pParent->AttachXmlEvent(eventType, callback);
			}
			else if (pstrClass == L"BubbledEvent") {
				if (Box* tmpParent = dynamic_cast<Box*>(pParent)) {
					tmpParent->AttachXmlBubbledEvent(eventType, callback);
				}
				else {
					ASSERT(FALSE);
				}

			}
		}
	}

	return true;
}


} // namespace ui
