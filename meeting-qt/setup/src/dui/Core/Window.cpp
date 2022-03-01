/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"
#include <shlwapi.h>

#pragma comment(lib, "shlwapi.lib")

namespace ui {


	/////////////////////////////////////////////////////////////////////////////////////
	//
	//

	static UINT MapKeyState()
	{
		UINT uState = 0;
		if( ::GetKeyState(VK_CONTROL) < 0 ) uState |= MK_CONTROL;
		if( ::GetKeyState(VK_RBUTTON) < 0 ) uState |= MK_LBUTTON;
		if( ::GetKeyState(VK_LBUTTON) < 0 ) uState |= MK_RBUTTON;
		if( ::GetKeyState(VK_SHIFT) < 0 ) uState |= MK_SHIFT;
		if( ::GetKeyState(VK_MENU) < 0 ) uState |= MK_ALT;
		return uState;
	}

	typedef struct tagFINDTABINFO
	{
		Control* pFocus;
		Control* pLast;
		bool bForward;
		bool bNextIsIt;
	} FINDTABINFO;

	typedef struct tagFINDSHORTCUT
	{
		TCHAR ch;
		bool bPickNext;
	} FINDSHORTCUT;

	void ImageAttribute::SetImageString(const std::wstring& imageStr)
	{
		Init();
		imageString = imageStr;
		sImageName = imageStr;
		ModifyAttribute(*this, imageStr);
	}

	void ImageAttribute::ModifyAttribute(ImageAttribute& imageAttribute, const std::wstring& imageStr)
	{
		std::wstring sItem;
		std::wstring sValue;
		LPTSTR pstr = NULL;

		LPCTSTR pStrImage = imageStr.c_str();
		while( *pStrImage != _T('\0') ) {
			sItem.clear();
			sValue.clear();
			while( *pStrImage > _T('\0') && *pStrImage <= _T(' ') ) pStrImage = ::CharNext(pStrImage);
			while( *pStrImage != _T('\0') && *pStrImage != _T('=') && *pStrImage > _T(' ') ) {
				LPTSTR pstrTemp = ::CharNext(pStrImage);
				while( pStrImage < pstrTemp) {
					sItem += *pStrImage++;
				}
			}
			while( *pStrImage > _T('\0') && *pStrImage <= _T(' ') ) pStrImage = ::CharNext(pStrImage);
			if( *pStrImage++ != _T('=') ) break;
			while( *pStrImage > _T('\0') && *pStrImage <= _T(' ') ) pStrImage = ::CharNext(pStrImage);
			if( *pStrImage++ != _T('\'') ) break;
			while( *pStrImage != _T('\0') && *pStrImage != _T('\'') ) {
				LPTSTR pstrTemp = ::CharNext(pStrImage);
				while( pStrImage < pstrTemp) {
					sValue += *pStrImage++;
				}
			}
			if( *pStrImage++ != _T('\'') ) break;
			if( !sValue.empty() ) {
				if( sItem == _T("file") || sItem == _T("res") ) {
					imageAttribute.sImageName = sValue;
				}
				else if( sItem == _T("dest") ) {
					imageAttribute.rcDest.left = _tcstol(sValue.c_str(), &pstr, 10);  ASSERT(pstr);    
					imageAttribute.rcDest.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);
					imageAttribute.rcDest.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);
					imageAttribute.rcDest.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);
				}
				else if( sItem == _T("source") ) {
					imageAttribute.rcSource.left = _tcstol(sValue.c_str(), &pstr, 10);  ASSERT(pstr);    
					imageAttribute.rcSource.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
					imageAttribute.rcSource.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
					imageAttribute.rcSource.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);  
				}
				else if( sItem == _T("corner") ) {
					imageAttribute.rcCorner.left = _tcstol(sValue.c_str(), &pstr, 10);  ASSERT(pstr);    
					imageAttribute.rcCorner.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
					imageAttribute.rcCorner.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
					imageAttribute.rcCorner.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);
				}
				else if( sItem == _T("fade") ) {
					imageAttribute.bFade = (BYTE)_tcstoul(sValue.c_str(), &pstr, 10);
				}
				else if( sItem == _T("xtiled") ) {
					imageAttribute.bTiledX = (_tcscmp(sValue.c_str(), _T("true")) == 0);
				}
				else if( sItem == _T("ytiled") ) {
					imageAttribute.bTiledY = (_tcscmp(sValue.c_str(), _T("true")) == 0);
				}
			}
			if( *pStrImage++ != _T(' ') ) break;
		}
	}


//////////////////////////////////////////////////////////////////////////
///


HWND Window::GetHWND() const 
{ 
    return m_hWnd; 
}

UINT Window::GetClassStyle() const
{
    return 0;
}

std::wstring Window::GetSuperClassName() const
{
    return std::wstring();
}

HWND Window::Create(HWND hwndParent, LPCTSTR pstrName, DWORD dwStyle, DWORD dwExStyle, bool isLayeredWindow, const UiRect& rc)
{
    if( !GetSuperClassName().empty() && !RegisterSuperclass() ) return NULL;
    if( GetSuperClassName().empty() && !RegisterWindowClass() ) return NULL;
	std::wstring className = GetWindowClassName();
	m_bIsLayeredWindow = isLayeredWindow;
	if (m_bIsLayeredWindow) {
		dwExStyle |= WS_EX_LAYERED;
	}
	m_hWnd = ::CreateWindowEx(dwExStyle, className.c_str(), pstrName, dwStyle, 
		rc.left, rc.top, rc.GetWidth(), rc.GetHeight(), hwndParent, NULL, ::GetModuleHandle(NULL), this);
	LONG windowLong = GetWindowLong( m_hWnd, GWL_STYLE );
	if( windowLong & WS_CAPTION )
	{
		SetWindowLong( m_hWnd, GWL_STYLE, windowLong & ~WS_CAPTION );
	}
	ASSERT(m_hWnd!=NULL);
    return m_hWnd;
}

HWND Window::Subclass(HWND hWnd)
{
    ASSERT(::IsWindow(hWnd));
    ASSERT(m_hWnd==NULL);
    m_OldWndProc = SubclassWindow(hWnd, __WndProc);
    if( m_OldWndProc == NULL ) return NULL;
    m_bSubclassed = true;
    m_hWnd = hWnd;
    ::SetWindowLongPtr(hWnd, GWLP_USERDATA, reinterpret_cast<LPARAM>(this));
    return m_hWnd;
}

void Window::Unsubclass()
{
    ASSERT(::IsWindow(m_hWnd));
    if( !::IsWindow(m_hWnd) ) return;
    if( !m_bSubclassed ) return;
    SubclassWindow(m_hWnd, m_OldWndProc);
    m_OldWndProc = ::DefWindowProc;
    m_bSubclassed = false;
}

void Window::ShowWindow(bool bShow /*= true*/, bool bTakeFocus /*= false*/)
{
    ASSERT(::IsWindow(m_hWnd));
    if( !::IsWindow(m_hWnd) ) return;
    ::ShowWindow(m_hWnd, bShow ? (bTakeFocus ? SW_SHOWNORMAL : SW_SHOWNOACTIVATE) : SW_HIDE);
}

UINT Window::ShowModal()
{
    ASSERT(::IsWindow(m_hWnd));
    UINT nRet = 0;
    HWND hWndParent = GetWindowOwner(m_hWnd);
    ::ShowWindow(m_hWnd, SW_SHOWNORMAL);
    ::EnableWindow(hWndParent, FALSE);
    MSG msg = { 0 };
	HWND hTempWnd = m_hWnd;
    while( ::IsWindow(hTempWnd) && ::GetMessage(&msg, NULL, 0, 0) ) {
        if( msg.message == WM_CLOSE && msg.hwnd == m_hWnd ) {
            nRet = msg.wParam;
            ::EnableWindow(hWndParent, TRUE);
            ::SetFocus(hWndParent);
        }
        if( !GlobalManager::TranslateMessage(&msg) ) {
            ::TranslateMessage(&msg);
            ::DispatchMessage(&msg);
        }
        if( msg.message == WM_QUIT ) break;
    }
    ::EnableWindow(hWndParent, TRUE);
    ::SetFocus(hWndParent);
    if( msg.message == WM_QUIT ) ::PostQuitMessage(msg.wParam);
    return nRet;
}

void Window::Close(UINT nRet)
{
    ASSERT(::IsWindow(m_hWnd));
    if( !::IsWindow(m_hWnd) ) return;
	PostMessage(WM_CLOSE, (WPARAM)nRet, 0L);
}

void Window::CenterWindow()
{
    ASSERT(::IsWindow(m_hWnd));
    ASSERT((GetWindowStyle(m_hWnd)&WS_CHILD)==0);
    UiRect rcDlg;
    ::GetWindowRect(m_hWnd, &rcDlg);
    UiRect rcArea;
    UiRect rcCenter;
	HWND hWnd = GetHWND();
    HWND hWndCenter = ::GetWindowOwner(m_hWnd);
	if (hWndCenter!=NULL)
		hWnd=hWndCenter;

	// 处理多显示器模式下屏幕居中
	MONITORINFO oMonitor = {};
	oMonitor.cbSize = sizeof(oMonitor);
	::GetMonitorInfo(::MonitorFromWindow(hWnd, MONITOR_DEFAULTTONEAREST), &oMonitor);
	rcArea = oMonitor.rcWork;

    if( hWndCenter == NULL )
		rcCenter = rcArea;
	else if( ::IsIconic(hWndCenter) )
		rcCenter = rcArea;
	else
		::GetWindowRect(hWndCenter, &rcCenter);

    int DlgWidth = rcDlg.right - rcDlg.left;
    int DlgHeight = rcDlg.bottom - rcDlg.top;

    // Find dialog's upper left based on rcCenter
    int xLeft = (rcCenter.left + rcCenter.right) / 2 - DlgWidth / 2;
    int yTop = (rcCenter.top + rcCenter.bottom) / 2 - DlgHeight / 2;

    // The dialog is outside the screen, move it inside
    if( xLeft < rcArea.left ) xLeft = rcArea.left;
    else if( xLeft + DlgWidth > rcArea.right ) xLeft = rcArea.right - DlgWidth;
    if( yTop < rcArea.top ) yTop = rcArea.top;
    else if( yTop + DlgHeight > rcArea.bottom ) yTop = rcArea.bottom - DlgHeight;
    ::SetWindowPos(m_hWnd, NULL, xLeft, yTop, -1, -1, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
}

void Window::SetIcon(UINT nRes)
{
    HICON hIcon = (HICON)::LoadImage(::GetModuleHandle(NULL), MAKEINTRESOURCE(nRes), IMAGE_ICON, ::GetSystemMetrics(SM_CXICON), ::GetSystemMetrics(SM_CYICON), LR_DEFAULTCOLOR | LR_SHARED);
    ASSERT(hIcon);
    ::SendMessage(m_hWnd, WM_SETICON, (WPARAM) TRUE, (LPARAM) hIcon);
    hIcon = (HICON)::LoadImage(::GetModuleHandle(NULL), MAKEINTRESOURCE(nRes), IMAGE_ICON, ::GetSystemMetrics(SM_CXSMICON), ::GetSystemMetrics(SM_CYSMICON), LR_DEFAULTCOLOR | LR_SHARED);
    ASSERT(hIcon);
    ::SendMessage(m_hWnd, WM_SETICON, (WPARAM) FALSE, (LPARAM) hIcon);
}

bool Window::RegisterWindowClass()
{
    WNDCLASS wc = { 0 };
    wc.style = GetClassStyle();
    wc.cbClsExtra = 0;
    wc.cbWndExtra = 0;
    wc.hIcon = NULL;
    wc.lpfnWndProc = Window::__WndProc;
    wc.hInstance = ::GetModuleHandle(NULL);
    wc.hCursor = ::LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = NULL;
    wc.lpszMenuName  = NULL;
	std::wstring className = GetWindowClassName();
    wc.lpszClassName = className.c_str();
    ATOM ret = ::RegisterClass(&wc);
    ASSERT(ret!=NULL || ::GetLastError()==ERROR_CLASS_ALREADY_EXISTS);
    return ret != NULL || ::GetLastError() == ERROR_CLASS_ALREADY_EXISTS;
}

bool Window::RegisterSuperclass()
{
    // Get the class information from an existing
    // window so we can subclass it later on...
    WNDCLASSEX wc = { 0 };
    wc.cbSize = sizeof(WNDCLASSEX);
	std::wstring superClassName = GetSuperClassName();
    if( !::GetClassInfoEx(NULL, superClassName.c_str(), &wc) ) {
        if( !::GetClassInfoEx(::GetModuleHandle(NULL), superClassName.c_str(), &wc) ) {
            ASSERT(!"Unable to locate window class");
            return false;
        }
    }
    m_OldWndProc = wc.lpfnWndProc;
    wc.lpfnWndProc = Window::__ControlProc;
    wc.hInstance = ::GetModuleHandle(NULL);
	std::wstring className = GetWindowClassName();
    wc.lpszClassName = className.c_str();
    ATOM ret = ::RegisterClassEx(&wc);
    ASSERT(ret!=NULL || ::GetLastError()==ERROR_CLASS_ALREADY_EXISTS);
    return ret != NULL || ::GetLastError() == ERROR_CLASS_ALREADY_EXISTS;
}

LRESULT CALLBACK Window::__WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    Window* pThis = NULL;
    if( uMsg == WM_NCCREATE ) {
        LPCREATESTRUCT lpcs = reinterpret_cast<LPCREATESTRUCT>(lParam);
        pThis = static_cast<Window*>(lpcs->lpCreateParams);
        pThis->m_hWnd = hWnd;
        ::SetWindowLongPtr(hWnd, GWLP_USERDATA, reinterpret_cast<LPARAM>(pThis));
    } 
    else {
        pThis = reinterpret_cast<Window*>(::GetWindowLongPtr(hWnd, GWLP_USERDATA));
        if( uMsg == WM_NCDESTROY && pThis != NULL ) {
            LRESULT lRes = ::CallWindowProc(pThis->m_OldWndProc, hWnd, uMsg, wParam, lParam);
            ::SetWindowLongPtr(pThis->m_hWnd, GWLP_USERDATA, 0L);
            if( pThis->m_bSubclassed ) pThis->Unsubclass();
            pThis->OnFinalMessage(hWnd);
            return lRes;
        }
    }

    if( pThis != NULL) {
        return pThis->HandleMessage(uMsg, wParam, lParam);
    } 
    else {
        return ::DefWindowProc(hWnd, uMsg, wParam, lParam);
    }
}

LRESULT CALLBACK Window::__ControlProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    Window* pThis = NULL;
    if( uMsg == WM_NCCREATE ) {
        LPCREATESTRUCT lpcs = reinterpret_cast<LPCREATESTRUCT>(lParam);
        pThis = static_cast<Window*>(lpcs->lpCreateParams);
        ::SetProp(hWnd, _T("WndX"), (HANDLE) pThis);
        pThis->m_hWnd = hWnd;
    } 
    else {
        pThis = reinterpret_cast<Window*>(::GetProp(hWnd, _T("WndX")));
        if( uMsg == WM_NCDESTROY && pThis != NULL ) {
            LRESULT lRes = ::CallWindowProc(pThis->m_OldWndProc, hWnd, uMsg, wParam, lParam);
            if( pThis->m_bSubclassed ) pThis->Unsubclass();
            ::SetProp(hWnd, _T("WndX"), NULL);
            pThis->m_hWnd = NULL;
            pThis->OnFinalMessage(hWnd);
            return lRes;
        }
    }
    if( pThis != NULL ) {
        return pThis->HandleMessage(uMsg, wParam, lParam);
    } 
    else {
        return ::DefWindowProc(hWnd, uMsg, wParam, lParam);
    }
}

LRESULT Window::SendMessage(UINT uMsg, WPARAM wParam /*= 0*/, LPARAM lParam /*= 0*/)
{
    ASSERT(::IsWindow(m_hWnd));
    return ::SendMessage(m_hWnd, uMsg, wParam, lParam);
} 

LRESULT Window::PostMessage(UINT uMsg, WPARAM wParam /*= 0*/, LPARAM lParam /*= 0*/)
{
    ASSERT(::IsWindow(m_hWnd));
    return ::PostMessage(m_hWnd, uMsg, wParam, lParam);
}

void Window::OnFinalMessage(HWND /*hWnd*/)
{
	SendNotify(EventType::WINDOWCLOSE);
}



/////////////////////////////////////////////////////////////////////////////////////
//
//

void Window::SetWindowResourcePath(const std::wstring& strPath)
{
	m_pStrWindowResourcePath = strPath;
	if( m_pStrWindowResourcePath.empty() ) return;
	TCHAR cEnd = m_pStrWindowResourcePath.at(m_pStrWindowResourcePath.length() - 1);
	if( cEnd != _T('\\') && cEnd != _T('/') ) m_pStrWindowResourcePath += _T('\\');
}

std::wstring Window::GetWindowResourcePath()
{
	return m_pStrWindowResourcePath;
}

Window::Window()
{
	LOGFONT lf = { 0 };
	::GetObject(::GetStockObject(DEFAULT_GUI_FONT), sizeof(LOGFONT), &lf);
	lf.lfCharSet = DEFAULT_CHARSET;
	if (GlobalManager::GetDefaultFontName().length()>0)
	{
		_tcscpy_s(lf.lfFaceName, LF_FACESIZE, GlobalManager::GetDefaultFontName().c_str());
	}
	HFONT hDefaultFont = ::CreateFontIndirect(&lf);
	m_DefaultFontInfo.hFont = hDefaultFont;
	m_DefaultFontInfo.sFontName = lf.lfFaceName;
	m_DefaultFontInfo.iSize = -lf.lfHeight;
	m_DefaultFontInfo.bBold = (lf.lfWeight >= FW_BOLD);
	m_DefaultFontInfo.bUnderline = (lf.lfUnderline == TRUE);
	m_DefaultFontInfo.bItalic = (lf.lfItalic == TRUE);
	::ZeroMemory(&m_DefaultFontInfo.tm, sizeof(m_DefaultFontInfo.tm));
}

Window::~Window()
{
	// Delete the control-tree structures
	for( auto it = m_aDelayedCleanup.begin(); it != m_aDelayedCleanup.end(); it++ ) delete *it;

	delete m_pRoot;
	::DeleteObject(m_DefaultFontInfo.hFont);
	RemoveAllClass();
	RemoveAllOptionGroups();

	// Reset other parts...
	if( m_hwndTooltip != NULL ) ::DestroyWindow(m_hwndTooltip);
	if( m_hDcBackground != NULL ) ::DeleteDC(m_hDcBackground);
	if( m_hbmpBackground != NULL ) ::DeleteObject(m_hbmpBackground);
	if( m_hDcPaint != NULL ) ::ReleaseDC(m_hWnd, m_hDcPaint);

	GlobalManager::RemovePreMessage(this);
}

void Window::Init(HWND hWnd)
{
	m_hWnd = hWnd;
	ASSERT(::IsWindow(hWnd));
	// Remember the window context we came from
	m_hDcPaint = ::GetDC(hWnd);
	// We'll want to filter messages globally too
	GlobalManager::AddPreMessage(this);
}

HWND Window::GetTooltipWindow() const
{
	return m_hwndTooltip;
}

HDC Window::GetPaintDC() const
{
	return m_hDcPaint;
}

void Window::SetShadowAttached(bool bShadowAttached)
{
	m_shadow.SetShadowAttached(bShadowAttached);
}

UiRect Window::GetShadowLength() const
{
	return m_shadow.GetShadowLength();
}

UiRect Window::GetPos(bool bContainShadow) const
{
	UiRect rcPos;
	::GetWindowRect(m_hWnd, &rcPos);
	if (!bContainShadow) {
		UiRect padding = m_shadow.GetShadowLength();
		rcPos.left += padding.left;
		rcPos.right -= padding.right;
		rcPos.top += padding.top;
		rcPos.bottom -= padding.bottom;
	}
	return rcPos;
}

void Window::SetPos(const UiRect& rc, UINT uFlags, HWND hWndInsertAfter, bool bContainShadow)
{
	UiRect newRc = rc;
	ASSERT(::IsWindow(m_hWnd));
	if (!bContainShadow) {
		newRc.Inflate(m_shadow.GetShadowLength());
	}
	::SetWindowPos(m_hWnd, hWndInsertAfter, newRc.left, newRc.top, newRc.GetWidth(), newRc.GetHeight(), uFlags);
}

CSize Window::GetMinInfo(bool bContainShadow) const
{
	CSize xy = m_szMinWindow;
	if (!bContainShadow) {
		if (xy.cx != 0) {
			xy.cx -= m_shadow.GetShadowLength().left + m_shadow.GetShadowLength().right;
		}
		if (xy.cy != 0) {
			xy.cy -= m_shadow.GetShadowLength().top + m_shadow.GetShadowLength().bottom;
		}
	}

	return xy;
}

void Window::SetMinInfo(int cx, int cy, bool bContainShadow)
{
	ASSERT(cx >= 0 && cy >= 0);

	if (!bContainShadow) {
		if (cx != 0) {
			cx += m_shadow.GetShadowLength().left + m_shadow.GetShadowLength().right;
		}
		if (cy != 0) {
			cy += m_shadow.GetShadowLength().top + m_shadow.GetShadowLength().bottom;
		}
	}
	m_szMinWindow.cx = cx;
	m_szMinWindow.cy = cy;
}

CSize Window::GetMaxInfo(bool bContainShadow) const
{
	CSize xy = m_szMaxWindow;
	if (!bContainShadow) {
		if (xy.cx != 0) {
			xy.cx -= m_shadow.GetShadowLength().left + m_shadow.GetShadowLength().right;
		}
		if (xy.cy != 0) {
			xy.cy -= m_shadow.GetShadowLength().top + m_shadow.GetShadowLength().bottom;
		}
	}

	return xy;
}

void Window::SetMaxInfo(int cx, int cy, bool bContainShadow)
{
	ASSERT(cx >= 0 && cy >= 0);

	if (!bContainShadow) {
		if (cx != 0) {
			cx += m_shadow.GetShadowLength().left + m_shadow.GetShadowLength().right;
		}
		if (cy != 0) {
			cy += m_shadow.GetShadowLength().top + m_shadow.GetShadowLength().bottom;
		}
	}
	m_szMaxWindow.cx = cx;
	m_szMaxWindow.cy = cy;
}

CSize Window::GetInitSize(bool bContainShadow) const
{
	CSize xy = m_szInitWindowSize;
	if (!bContainShadow) {
		if (xy.cx != 0) {
			xy.cx -= m_shadow.GetShadowLength().left + m_shadow.GetShadowLength().right;
		}
		if (xy.cy != 0) {
			xy.cy -= m_shadow.GetShadowLength().top + m_shadow.GetShadowLength().bottom;
		}
	}

	return xy;
}

void Window::SetInitSize(int cx, int cy, bool bContainShadow)
{
	if (!bContainShadow) {
		cx += m_shadow.GetShadowLength().left + m_shadow.GetShadowLength().right;
		cy += m_shadow.GetShadowLength().top + m_shadow.GetShadowLength().bottom;
	}
	m_szInitWindowSize.cx = cx;
	m_szInitWindowSize.cy = cy;
	if( m_pRoot == NULL && m_hWnd != NULL ) {
		::SetWindowPos(m_hWnd, NULL, 0, 0, m_szInitWindowSize.cx, m_szInitWindowSize.cy, SWP_NOZORDER | SWP_NOMOVE | SWP_NOACTIVATE);
	}
}

POINT Window::GetMousePos() const
{
	return m_ptLastMousePos;
}

UiRect Window::GetSizeBox()
{
	return m_rcSizeBox;
}

void Window::SetSizeBox(const UiRect& rcSizeBox)
{
	m_rcSizeBox = rcSizeBox;
}

UiRect Window::GetCaptionRect() const
{
	return m_rcCaption;
}

void Window::SetCaptionRect(UiRect& rcCaption)
{
	m_rcCaption = rcCaption;
}

CSize Window::GetRoundCorner() const
{
	return m_szRoundCorner;
}

void Window::SetRoundCorner(int cx, int cy)
{
	m_szRoundCorner.cx = cx;
	m_szRoundCorner.cy = cy;
}

UiRect Window::GetMaximizeInfo() const
{
	return m_rcMaximizeInfo;
}

void Window::SetMaximizeInfo(UiRect& rcMaximize)
{
	m_rcMaximizeInfo = rcMaximize;
}
UiRect Window::GetCustomShadowRect() const
{
	return m_rcCustomShadow;
}
void Window::SetCustomShadowRect(UiRect& rc)
{
	m_rcCustomShadow = rc;
}

bool Window::PreMessageHandler(UINT uMsg, WPARAM wParam, LPARAM lParam, LRESULT& /*lRes*/)
{
	for (auto it = m_aPreMessageFilters.begin(); it != m_aPreMessageFilters.end(); it++)
	{
		bool bHandled = false;
		(*it)->MessageHandler(uMsg, wParam, lParam, bHandled);
		if( bHandled ) {
			return true;
		}
	}
	switch( uMsg ) {
	case WM_SYSKEYDOWN:
		{
			if( m_pFocus != NULL ) {
				m_pFocus->HandleMessageTemplate(EventType::SYSKEY, 0, 0, wParam);
			}
		}
		break;
	}
	return false;
}

LRESULT Window::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	bool handled = false;
	LRESULT ret = DoHandlMessage(uMsg, wParam, lParam, handled);
	if (handled) {
		return ret;
	}
	else {
		return CallWindowProc(uMsg, wParam, lParam);
	}
}

LRESULT Window::DoHandlMessage(UINT uMsg, WPARAM wParam, LPARAM lParam, bool& handled)
{
	handled = false;
	// Cycle through listeners
	for (auto it = m_aMessageFilters.begin(); it != m_aMessageFilters.end(); it++)
	{
		bool bHandled = false;
		LRESULT lResult = (*it)->MessageHandler(uMsg, wParam, lParam, bHandled);
		if( bHandled && uMsg != WM_MOUSEMOVE ) {
			handled = true;
			return lResult;
		}
	}
	// Custom handling of events
	switch( uMsg ) {
	case WM_APP + 1:
		{
			for (auto it = m_aDelayedCleanup.begin(); it != m_aDelayedCleanup.end(); it++)	delete *it;
			m_aDelayedCleanup.clear();
		}
		break;
	case WM_CLOSE:
		{
			// Make sure all matching "closing" events are sent
			if( m_pEventHover != NULL ) {
				m_pEventHover->HandleMessageTemplate(EventType::MOUSELEAVE);
			}
			if( m_pEventClick != NULL ) {
				m_pEventClick->HandleMessageTemplate(EventType::BUTTONUP);
			}

			SetFocus(NULL);

			// Hmmph, the usual Windows tricks to avoid
			// focus loss...
			HWND hwndParent = GetWindowOwner(m_hWnd);
			if( hwndParent != NULL ) ::SetFocus(hwndParent);
		}
		break;
	case WM_ERASEBKGND:
		{
			handled = true;
			return 1;
		}
	case WM_PAINT:
		{
			Paint();
			handled = true;
			return 0;
			
		}
		// If any of the painting requested a resize again, we'll need
		// to invalidate the entire window once more.
		if( m_bIsArranged ) {
			::InvalidateRect(m_hWnd, NULL, FALSE);
		}
		handled = true;
		return 0;
	case WM_SIZE:
		{
			if( m_pFocus != NULL ) {
				m_pFocus->HandleMessageTemplate(EventType::WINDOWSIZE);
			}
			if( m_pRoot != NULL ) m_pRoot->Arrange();

			if (wParam == SIZE_MAXIMIZED) {
				m_shadow.MaximizedOrRestored(true);
			}
			else if (wParam == SIZE_RESTORED) {
				m_shadow.MaximizedOrRestored(false);
			}
		}
		handled = true;
		return 0;
	case WM_MOUSEHOVER:
		{
			m_bMouseTracking = false;
			POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
			Control* pHover = FindControl(pt);
			if( pHover == NULL ) break;
			// Generate mouse hover event
			if( m_pEventHover != NULL ) {
				m_pEventHover->HandleMessageTemplate(EventType::MOUSEHOVER, 0, 0, 0, pt);
			}
			// Create tooltip information
			std::wstring sToolTip = pHover->GetToolTip();
			//if( sToolTip.empty() ) {
			//	handled = true;
			//	return 0;
			//}
			::ZeroMemory(&m_ToolTip, sizeof(TOOLINFO));
			m_ToolTip.cbSize = sizeof(TOOLINFO);
			m_ToolTip.uFlags = TTF_IDISHWND;
			m_ToolTip.hwnd = m_hWnd;
			m_ToolTip.uId = (UINT_PTR) m_hWnd;
			m_ToolTip.hinst = ::GetModuleHandle(NULL);
			m_ToolTip.lpszText = const_cast<LPTSTR>( (LPCTSTR) sToolTip.c_str() );
			m_ToolTip.rect = pHover->GetPos();
			if( m_hwndTooltip == NULL ) {
				m_hwndTooltip = ::CreateWindowEx(0, TOOLTIPS_CLASS, NULL, WS_POPUP | TTS_NOPREFIX | TTS_ALWAYSTIP, CW_USEDEFAULT, 
					CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, m_hWnd, NULL, ::GetModuleHandle(NULL), NULL);
				::SendMessage(m_hwndTooltip, TTM_ADDTOOL, 0, (LPARAM) &m_ToolTip);
			}
			::SendMessage( m_hwndTooltip,TTM_SETMAXTIPWIDTH,0, pHover->GetToolTipWidth());
			::SendMessage(m_hwndTooltip, TTM_SETTOOLINFO, 0, (LPARAM) &m_ToolTip);
			::SendMessage(m_hwndTooltip, TTM_TRACKACTIVATE, TRUE, (LPARAM) &m_ToolTip);
		}
		handled = true;
		return 0;
	case WM_MOUSELEAVE:
		{
			if( m_hwndTooltip != NULL ) ::SendMessage(m_hwndTooltip, TTM_TRACKACTIVATE, FALSE, (LPARAM) &m_ToolTip);
			if( m_bMouseTracking ) ::SendMessage(m_hWnd, WM_MOUSEMOVE, 0, (LPARAM) -1);
			m_bMouseTracking = false;
		}
		break;
	case WM_MOUSEMOVE:
		{
			// Start tracking this entire window again...
			if( !m_bMouseTracking ) {
				TRACKMOUSEEVENT tme = { 0 };
				tme.cbSize = sizeof(TRACKMOUSEEVENT);
				tme.dwFlags = TME_HOVER | TME_LEAVE;
				tme.hwndTrack = m_hWnd;
				tme.dwHoverTime = m_hwndTooltip == NULL ? 400UL : (DWORD) ::SendMessage(m_hwndTooltip, TTM_GETDELAYTIME, TTDT_INITIAL, 0L);
				_TrackMouseEvent(&tme);
				m_bMouseTracking = true;
			}
			// Generate the appropriate mouse messages
			POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
			m_ptLastMousePos = pt;
			m_pNewHover = FindControl(pt);
			if (m_pNewHover != NULL && m_pNewHover->GetWindow() != this) break;

			if (m_pNewHover != m_pEventHover && m_pEventHover != NULL) {
				m_pEventHover->HandleMessageTemplate(EventType::MOUSELEAVE, 0, 0, 0, pt);
				m_pEventHover = NULL;
				if( m_hwndTooltip != NULL ) ::SendMessage(m_hwndTooltip, TTM_TRACKACTIVATE, FALSE, (LPARAM) &m_ToolTip);
			}
			if (m_pNewHover != m_pEventHover && m_pNewHover != NULL) {
				m_pNewHover->HandleMessageTemplate(EventType::MOUSEENTER, 0, 0, 0, pt);
				m_pEventHover = m_pNewHover;
			}
			if( m_pEventClick != NULL ) {
				m_pEventClick->HandleMessageTemplate(EventType::MOUSEMOVE, 0, 0, 0, pt);
			}
			else if (m_pNewHover != NULL) {
				m_pNewHover->HandleMessageTemplate(EventType::MOUSEMOVE, 0, 0, 0, pt);
			}
		}
		break;
	case WM_LBUTTONDOWN:
		{
			// We alway set focus back to our app (this helps
			// when Win32 child windows are placed on the dialog
			// and we need to remove them on focus change).
			::SetFocus(m_hWnd);
			POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
			m_ptLastMousePos = pt;
			Control* pControl = FindControl(pt);
			if( pControl == NULL ) break;
			if( pControl->GetWindow() != this ) break;
			m_pEventClick = pControl;
			pControl->SetFocus();
			SetCapture();

			pControl->HandleMessageTemplate(EventType::BUTTONDOWN, wParam, lParam, 0, pt);
		}
		break;
	case WM_LBUTTONDBLCLK:
		{
			::SetFocus(m_hWnd);
			POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
			m_ptLastMousePos = pt;
			Control* pControl = FindControl(pt);
			if( pControl == NULL ) break;
			if( pControl->GetWindow() != this ) break;
			SetCapture();

			pControl->HandleMessageTemplate(EventType::INTERNAL_DBLCLICK, wParam, lParam, 0, pt);
			m_pEventClick = pControl;
		}
		break;
	case WM_LBUTTONUP:
		{
			POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
			m_ptLastMousePos = pt;
			if( m_pEventClick == NULL ) break;
			ReleaseCapture();

			m_pEventClick->HandleMessageTemplate(EventType::BUTTONUP, wParam, lParam, 0, pt);
			m_pEventClick = NULL;
		}
		break;
	case WM_SETFOCUS:
		{
			
		}
		break;
	case WM_KILLFOCUS:
		{
			POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
			m_ptLastMousePos = pt;
			if( m_pEventClick == NULL || typeid(*m_pEventClick) != typeid(ScrollBar)) break;
			ReleaseCapture();

			m_pEventClick->HandleMessageTemplate(EventType::BUTTONUP, wParam, lParam, 0, pt);
			m_pEventClick = NULL;
		}
		break;
	case WM_RBUTTONDOWN:
		{
			::SetFocus(m_hWnd);
			POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
			m_ptLastMousePos = pt;
			Control* pControl = FindControl(pt);
			if( pControl == NULL ) break;
			if( pControl->GetWindow() != this ) break;
			pControl->SetFocus();
			SetCapture();

			pControl->HandleMessageTemplate(EventType::RBUTTONDOWN, wParam, lParam, 0, pt);
			m_pEventClick = pControl;
		}
		break;
	case WM_CONTEXTMENU:
		{
			POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
			::ScreenToClient(m_hWnd, &pt);
			m_ptLastMousePos = pt;
			if( m_pEventClick == NULL ) break;
			ReleaseCapture();

			m_pEventClick->HandleMessageTemplate(EventType::INTERNAL_CONTEXTMENU, wParam, (LPARAM)m_pEventClick, 0, pt);
			m_pEventClick = NULL;
		}
		break;
	case WM_MOUSEWHEEL:
		{
			POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
			::ScreenToClient(m_hWnd, &pt);
			m_ptLastMousePos = pt;
			Control* pControl = FindControl(pt);
			if( pControl == NULL ) break;
			if( pControl->GetWindow() != this ) break;
			int zDelta = (int) (short) HIWORD(wParam);

			pControl->HandleMessageTemplate(EventType::SCROLLWHEEL, zDelta, lParam);
		}
		break;
	case WM_CHAR:
		{
			if( m_pFocus == NULL ) break;

			m_pFocus->HandleMessageTemplate(EventType::CHAR, wParam, lParam, wParam);
		}
		break;
	case WM_KEYDOWN:
		{
			if( m_pFocus == NULL ) break;

			m_pFocus->HandleMessageTemplate(EventType::KEYDOWN, wParam, lParam, wParam);
			m_pEventKey = m_pFocus;
		}
		break;
	case WM_KEYUP:
		{
			if( m_pEventKey == NULL ) break;

			m_pEventKey->HandleMessageTemplate(EventType::KEYUP, wParam, lParam, wParam);
			m_pEventKey = NULL;
		}
		break;
	case WM_SETCURSOR:
		{
			if( LOWORD(lParam) != HTCLIENT ) break;
			if( m_bMouseCapture ) {
				handled = true;
				return 0;
			}

			POINT pt = { 0 };
			::GetCursorPos(&pt);
			::ScreenToClient(m_hWnd, &pt);
			m_ptLastMousePos = pt;
			Control* pControl = FindControl(pt);
			if( pControl == NULL ) break;
			//if( (pControl->GetControlFlags() & UIFLAG_SETCURSOR) == 0 ) break;

			pControl->HandleMessageTemplate(EventType::SETCURSOR, wParam, lParam, 0, pt);
		}
		handled = true;
		return 0;
	case WM_NOTIFY:
		{
			LPNMHDR lpNMHDR = (LPNMHDR) lParam;
			if( lpNMHDR != NULL ) return ::SendMessage(lpNMHDR->hwndFrom, OCM__BASE + uMsg, wParam, lParam);
			handled = true;
			return 0;
		}
		break;
	case WM_COMMAND:
		{
			if( lParam == 0 ) break;
			HWND hWndChild = (HWND) lParam;
			handled = true;
			return ::SendMessage(hWndChild, OCM__BASE + uMsg, wParam, lParam);
		}
		break;
	case WM_CTLCOLOREDIT:
	case WM_CTLCOLORSTATIC:
		{
			// Refer To: http://msdn.microsoft.com/en-us/library/bb761691(v=vs.85).aspx
			// Read-only or disabled edit controls do not send the WM_CTLCOLOREDIT message; instead, they send the WM_CTLCOLORSTATIC message.
			if( lParam == 0 ) break;
			HWND hWndChild = (HWND) lParam;
			handled = true;
			return ::SendMessage(hWndChild, OCM__BASE + uMsg, wParam, lParam);
		}
		break;

	default:
		break;
	}

	return 0;
}

void Window::Paint()
{
	if (::IsIconic(m_hWnd) || !m_pRoot) {
		PAINTSTRUCT ps = { 0 };
		::BeginPaint(m_hWnd, &ps);
		::EndPaint(m_hWnd, &ps);
		return;
	}

	if (m_bIsArranged && m_pRoot->IsArranged() && (m_pRoot->GetFixedWidth() == DUI_LENGTH_AUTO || m_pRoot->GetFixedHeight() == DUI_LENGTH_AUTO))
	{
		CSize maxSize = { 99999, 99999 };
		CSize need_size = m_pRoot->EstimateSize(maxSize);
		if (need_size.cx < m_pRoot->GetMinWidth()) need_size.cx = m_pRoot->GetMinWidth();
		if (m_pRoot->GetMaxWidth() >= 0 && need_size.cx > m_pRoot->GetMaxWidth()) need_size.cx = m_pRoot->GetMaxWidth();
		if (need_size.cy < m_pRoot->GetMinHeight()) need_size.cy = m_pRoot->GetMinHeight();
		if (need_size.cy > m_pRoot->GetMaxHeight()) need_size.cy = m_pRoot->GetMaxHeight();
		UiRect rect;
		::GetWindowRect(m_hWnd, &rect);
		::MoveWindow(m_hWnd, rect.left, rect.top, need_size.cx, need_size.cy, TRUE);
	}

	// Should we paint?
	UiRect rcPaint;
	if (!::GetUpdateRect(m_hWnd, &rcPaint, FALSE) && !m_bFirstLayout) {
		return;
	}

	UiRect rcClient;
	::GetClientRect(m_hWnd, &rcClient);
	UiRect rect;
	::GetWindowRect(m_hWnd, &rect);

	//使用层窗口时，窗口部分在屏幕外时，获取到的无效区域仅仅是屏幕内的部分，这里做修正处理
	int cxScreen = GetSystemMetrics(SM_CXSCREEN);
	int cyScreen = GetSystemMetrics(SM_CYSCREEN);
	if (rect.left < 0 && rcPaint.left == 0 - rect.left)
	{
		rcPaint.left = rcClient.left;
	}
	if (rect.top < 0 && rcPaint.top == 0 - rect.top)
	{
		rcPaint.top = rcClient.top;
	}
	if (rect.right > cxScreen && rcPaint.right == cxScreen - rect.left)
	{
		rcPaint.right = rcClient.right;
	}
	if (rect.bottom > cyScreen && rcPaint.bottom == cyScreen - rect.top)
	{
		rcPaint.bottom = rcClient.bottom;
	}

	PAINTSTRUCT ps = { 0 };
	::BeginPaint(m_hWnd, &ps);

	if (m_bIsArranged)
	{
		m_bIsArranged = false;
		if (!::IsRectEmpty(&rcClient))
		{
			if (m_pRoot->IsArranged())
			{
				m_pRoot->SetPos(rcClient);
				if (m_hDcBackground != NULL) ::DeleteDC(m_hDcBackground);
				if (m_hbmpBackground != NULL) ::DeleteObject(m_hbmpBackground);
				m_hDcBackground = NULL;
				m_hbmpBackground = NULL;
				m_pBmpBackgroundBits = NULL;
			}
			else
			{
				Control* pControl = NULL;
				while ((pControl = m_pRoot->FindControl(__FindControlFromUpdate, NULL, UIFIND_VISIBLE | UIFIND_ME_FIRST)) != nullptr)
				{
					pControl->SetPos(pControl->GetPos());
				}
			}

			if (m_bFirstLayout) {
				m_bFirstLayout = false;
				SendNotify(m_pRoot, EventType::WINDOWINIT);
			}
		}
	}

	int width = rcClient.right - rcClient.left;
	int height = rcClient.bottom - rcClient.top;
	if (m_hbmpBackground == NULL)
	{
		m_hDcBackground = ::CreateCompatibleDC(m_hDcPaint);
		BITMAPINFO bmi;
		::ZeroMemory(&bmi, sizeof(BITMAPINFO));
		bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
		bmi.bmiHeader.biWidth = width;
		bmi.bmiHeader.biHeight = height;
		bmi.bmiHeader.biPlanes = 1;
		bmi.bmiHeader.biBitCount = 32;
		bmi.bmiHeader.biCompression = BI_RGB;
		bmi.bmiHeader.biSizeImage = width * height * 4;
		bmi.bmiHeader.biClrUsed = 0;
		m_hbmpBackground = ::CreateDIBSection(m_hDcPaint, &bmi, DIB_RGB_COLORS,
			(void**)&m_pBmpBackgroundBits, NULL, 0);

		m_bIsCanvasTransparent = !m_shadow.IsShadowAttached();
		rcPaint.left = 0;
		rcPaint.top = 0;
		rcPaint.right = width;
		rcPaint.bottom = height;
		ASSERT(m_hDcBackground);
		ASSERT(m_hbmpBackground);
	}

	unsigned int * bmpBackgroundBits = (unsigned int *)m_pBmpBackgroundBits;
	int mirrorTop = height - rcPaint.bottom;
	int mirrorBottom = height - rcPaint.top;
	int morrorLeft = rcPaint.left;
	int morrorRight = rcPaint.right;
	for (int i = mirrorTop; i < mirrorBottom; ++i) {
		::memset(bmpBackgroundBits + i * width + morrorLeft, 0, (morrorRight - morrorLeft) * 4);
	}

	HBITMAP hbmp_old = (HBITMAP)::SelectObject(m_hDcBackground, m_hbmpBackground);
	RenderClip rectClip;
	rectClip.GenerateClip(m_hDcBackground, rcPaint, true);
	m_pRoot->Paint(m_hDcBackground, rcPaint);

	if (m_shadow.IsShadowAttached()) {
		//补救下由于gdi绘制造成的透明层为0
		UiRect newPaint = rcPaint;
		UiRect rootPaddingPos = m_pRoot->GetPaddingPos();
		newPaint.Intersect(rootPaddingPos);
		int newMirrorTop = height - newPaint.bottom;
		int newMirrorBottom = height - newPaint.top;
		int newMorrorLeft = newPaint.left;
		int newMorrorRight = newPaint.right;
		UiRect rootPadding = m_pRoot->GetLayout()->GetPadding();
		//考虑圆角
		rootPadding.left += 4;
		rootPadding.top += 4;
		rootPadding.right += 4;
		rootPadding.bottom += 4;
		UiRect rootPos = m_pRoot->GetPos();
		for (int i = newMirrorTop; i < newMirrorBottom; i++) {
			for (int j = newMorrorLeft; j < newMorrorRight; j++) {
				if (!(j < rootPadding.left && i < rootPadding.top)
					&& !(j < rootPadding.left && i >= rootPos.bottom - rootPadding.bottom)
					&& !(j >= rootPos.right - rootPadding.right && i < rootPadding.top)
					&& !(j >= rootPos.right - rootPadding.right && i >= rootPos.bottom - rootPadding.bottom)) {
					BYTE* alpha = (BYTE*)(bmpBackgroundBits + i * width + j) + 3;
					*alpha = 255;
				}
			}
		}
	}
	else
	{
		UiRect custom_shadow_rc = GetCustomShadowRect();
		if (custom_shadow_rc.left > 0 || custom_shadow_rc.top > 0 || custom_shadow_rc.right > 0 || custom_shadow_rc.bottom > 0)
		{
			UiRect newPaint = rcPaint;
			UiRect rootPaddingPos = m_pRoot->GetPaddingPos();
			rootPaddingPos.Deflate(custom_shadow_rc);
			newPaint.Intersect(rootPaddingPos);
			int newMirrorTop = height - newPaint.bottom;
			int newMirrorBottom = height - newPaint.top;
			int newMorrorLeft = newPaint.left;
			int newMorrorRight = newPaint.right;
			UiRect rootPos = m_pRoot->GetPos();
			for (int i = newMirrorTop; i < newMirrorBottom; i++) {
				for (int j = newMorrorLeft; j < newMorrorRight; j++) {
					BYTE* alpha = (BYTE*)(bmpBackgroundBits + i * width + j) + 3;
					*alpha = 255;
				}
			}
		}
	}

	UiRect rcWnd;
	::GetWindowRect(m_hWnd, &rcWnd);
	POINT pt = { rcWnd.left, rcWnd.top };
	CSize szWindow = { rcClient.right - rcClient.left, rcClient.bottom - rcClient.top };
	POINT ptSrc = { 0, 0 };
	BLENDFUNCTION blendPixelFunction = { AC_SRC_OVER, 0, m_pRoot->GetAlpha(), AC_SRC_ALPHA };
	if (m_bIsLayeredWindow) {
		::UpdateLayeredWindow(m_hWnd, NULL, &pt, &szWindow, m_hDcBackground, &ptSrc, 0, &blendPixelFunction, ULW_ALPHA);
	}
	else {
		::BitBlt(ps.hdc, rcPaint.left, rcPaint.top, rcPaint.GetWidth(),
			rcPaint.GetHeight(), m_hDcBackground, rcPaint.left, rcPaint.top, SRCCOPY);
	}
	::EndPaint(m_hWnd, &ps);
	::SelectObject(m_hDcBackground, hbmp_old);
}

LRESULT Window::CallWindowProc(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	return ::CallWindowProc(m_OldWndProc, m_hWnd, uMsg, wParam, lParam);
}

void Window::SetArrange(bool bArrange)
{
	m_bIsArranged = bArrange;
}

void Window::Invalidate(const UiRect& rcItem)
{
	::InvalidateRect(m_hWnd, &rcItem, FALSE);
	// Invalidating a layered window will not trigger a WM_PAINT message,
	// thus we have to post WM_PAINT by ourselves.
	if (::GetWindowLong(m_hWnd, GWL_EXSTYLE) & WS_EX_LAYERED)
	{
		::PostMessage(m_hWnd, WM_PAINT, (LPARAM)&rcItem, (WPARAM)FALSE);
	}
}

bool Window::AttachDialog(Box* pRoot)
{
	ASSERT(::IsWindow(m_hWnd));
	// Reset any previous attachment
	SetFocus(NULL);
	m_pEventKey = NULL;
	m_pEventHover = NULL;
	m_pEventClick = NULL;
	// Remove the existing control-tree. We might have gotten inside this function as
	// a result of an event fired or similar, so we cannot just delete the objects and
	// pull the internal memory of the calling code. We'll delay the cleanup.
	if( m_pRoot != NULL ) {
		AddDelayedCleanup(m_pRoot);
	}
	// Set the dialog root element
	m_pRoot = pRoot;
	// Go ahead...
	m_bIsArranged = true;
	m_bFirstLayout = true;
	m_bFocusNeeded = true;
	// Initiate all control
	return InitControls(m_pRoot);
}

bool Window::InitControls(Control* pControl, Box* pParent /*= NULL*/)
{
	ASSERT(pControl);
	if( pControl == NULL ) return false;
	pControl->SetWindow(this, pParent != NULL ? pParent : pControl->GetParent(), true);
	pControl->FindControl(__FindControlFromNameHash, this, UIFIND_ALL);
	return true;
}

void Window::ReapObjects(Control* pControl)
{
	if (!pControl) {
		return;
	}
	if( pControl == m_pEventKey ) m_pEventKey = NULL;
	if( pControl == m_pEventHover ) m_pEventHover = NULL;
	if( pControl == m_pEventClick ) m_pEventClick = NULL;
	if( pControl == m_pFocus ) m_pFocus = NULL;
	std::wstring sName = pControl->GetName();
	if( !sName.empty() ) {
		auto it = m_mNameHash.find(sName);
		if (it != m_mNameHash.end())
		{
			m_mNameHash.erase(it);
		}
	}
}

bool Window::AddOptionGroup(const std::wstring& strGroupName, Control* pControl)
{
	auto it = m_mOptionGroup.find(strGroupName);
	if( it != m_mOptionGroup.end() ) {
		auto it2 = std::find(it->second.begin(), it->second.end(), pControl);
		if (it2 != it->second.end())
		{
			return false;
		}
		it->second.push_back(pControl);
	}
	else {
		m_mOptionGroup[strGroupName].push_back(pControl);
	}
	return true;
}

std::vector<Control*>* Window::GetOptionGroup(const std::wstring& strGroupName)
{
	auto it = m_mOptionGroup.find(strGroupName);
	if( it != m_mOptionGroup.end() ) return &(it->second);
	return NULL;
}

void Window::RemoveOptionGroup(const std::wstring& strGroupName, Control* pControl)
{
	ASSERT(!strGroupName.empty());
	ASSERT(pControl);
	auto it = m_mOptionGroup.find(strGroupName);
	if( it != m_mOptionGroup.end() ) {
		auto it2 = std::find(it->second.begin(), it->second.end(), pControl);
		if (it2 != it->second.end())
		{
			it->second.erase(it2);
		}

		if( it->second.empty() ) {
			m_mOptionGroup.erase(it);
		}
	}
}

void Window::RemoveAllOptionGroups()
{
	m_mOptionGroup.clear();
}

Control* Window::GetFocus() const
{
	return m_pFocus;
}

void Window::SetFocus(Control* pControl)
{
	// Paint manager window has focus?
	HWND hFocusWnd = ::GetFocus();
	if( hFocusWnd != m_hWnd && pControl != m_pFocus ) ::SetFocus(m_hWnd);
	// Already has focus?
	if( pControl == m_pFocus ) return;
	// Remove focus from old control
	if( m_pFocus != NULL ) 
	{
		m_pFocus->HandleMessageTemplate(EventType::INTERNAL_KILLFOCUS);
		Control* tmp = m_pFocus;
		m_pFocus = NULL;
		SendNotify( tmp, EventType::KILLFOCUS );
	}
	if( pControl == NULL ) return;
	// Set focus to new control
	if( pControl != NULL 
		&& pControl->GetWindow() == this 
		&& pControl->IsVisible() 
		&& pControl->IsEnabled() ) 
	{
		m_pFocus = pControl;

		if (m_pFocus)
		{
			m_pFocus->HandleMessageTemplate(EventType::INTERNAL_SETFOCUS);
		}
		if (m_pFocus)
		{
			SendNotify(m_pFocus, EventType::SETFOCUS);
		}
	}
}

void Window::SetFocusNeeded(Control* pControl)
{
	::SetFocus(m_hWnd);
	if( pControl == NULL ) return;
	if( m_pFocus != NULL ) {
		m_pFocus->HandleMessageTemplate(EventType::INTERNAL_KILLFOCUS);
		SendNotify(m_pFocus, EventType::KILLFOCUS);
		m_pFocus = NULL;
	}
	FINDTABINFO info = { 0 };
	info.pFocus = pControl;
	info.bForward = false;
	m_pFocus = nullptr; //m_pRoot->FindControl(__FindControlFromTab, &info, UIFIND_VISIBLE | UIFIND_ENABLED | UIFIND_ME_FIRST);
	m_bFocusNeeded = true;
	if( m_pRoot != NULL ) m_pRoot->Arrange();
}

void Window::SetCapture()
{
	::SetCapture(m_hWnd);
	m_bMouseCapture = true;
}

void Window::ReleaseCapture()
{
	::ReleaseCapture();
	m_bMouseCapture = false;
}

bool Window::IsCaptured() const
{
	return m_bMouseCapture;
}

//bool Window::SetNextTabControl(bool bForward)
//{
//	// If we're in the process of restructuring the layout we can delay the
//	// focus calulation until the next repaint.
//	if( m_bIsArranged && bForward ) {
//		m_bFocusNeeded = true;
//		::InvalidateRect(m_hWnd, NULL, FALSE);
//		return true;
//	}
//	// Find next/previous tabbable control
//	FINDTABINFO info1 = { 0 };
//	info1.pFocus = m_pFocus;
//	info1.bForward = bForward;
//	Control* pControl = m_pRoot->FindControl(__FindControlFromTab, &info1, UIFIND_VISIBLE | UIFIND_ENABLED | UIFIND_ME_FIRST);
//	if( pControl == NULL ) {  
//		if( bForward ) {
//			// Wrap around
//			FINDTABINFO info2 = { 0 };
//			info2.pFocus = bForward ? NULL : info1.pLast;
//			info2.bForward = bForward;
//			pControl = m_pRoot->FindControl(__FindControlFromTab, &info2, UIFIND_VISIBLE | UIFIND_ENABLED | UIFIND_ME_FIRST);
//		}
//		else {
//			pControl = info1.pLast;
//		}
//	}
//	if( pControl != NULL ) SetFocus(pControl);
//	m_bFocusNeeded = false;
//	return true;
//}

bool Window::AddPreMessageFilter(IUIMessageFilter* pFilter)
{
	ASSERT(std::find(m_aPreMessageFilters.begin(), m_aPreMessageFilters.end(), pFilter) == m_aPreMessageFilters.end());
	m_aPreMessageFilters.push_back(pFilter);
	return true;
}

bool Window::RemovePreMessageFilter(IUIMessageFilter* pFilter)
{
	for (auto it = m_aPreMessageFilters.begin(); it != m_aPreMessageFilters.end(); it++) {
		if( *it == pFilter ) {
			m_aPreMessageFilters.erase(it);
			return true;
		}
	}
	return false;
}

bool Window::AddMessageFilter(IUIMessageFilter* pFilter)
{
	ASSERT(std::find(m_aMessageFilters.begin(), m_aMessageFilters.end(), pFilter) == m_aMessageFilters.end());
	m_aMessageFilters.push_back(pFilter);
	return true;
}

bool Window::RemoveMessageFilter(IUIMessageFilter* pFilter)
{
	for (auto it = m_aMessageFilters.begin(); it != m_aMessageFilters.end(); it++) {
		if( *it == pFilter ) {
			m_aMessageFilters.erase(it);
			return true;
		}
	}
	return false;
}

void Window::AddDelayedCleanup(Control* pControl)
{
	pControl->SetWindow(this, NULL, false);
	m_aDelayedCleanup.push_back(pControl);
	::PostMessage(m_hWnd, WM_APP + 1, 0, 0L);
}

bool Window::SendNotify(EventType eventType, WPARAM wParam, LPARAM lParam)
{
	EventArgs msg;
	msg.pSender = nullptr;
	msg.Type = eventType;
	msg.ptMouse = GetMousePos();
	msg.dwTimestamp = ::GetTickCount();
	msg.wParam = wParam;
	msg.lParam = lParam;

	auto callback = OnEvent.find(msg.Type);
	if (callback != OnEvent.end()) {
		callback->second(&msg);
	}

	callback = OnEvent.find(EventType::ALL);
	if (callback != OnEvent.end()) {
		callback->second(&msg);
	}

	return true;
}

bool Window::SendNotify(Control* pControl, EventType msgType, WPARAM wParam, LPARAM lParam)
{
	EventArgs msg;
	msg.pSender = pControl;
	msg.Type = msgType;
	msg.ptMouse = GetMousePos();
	msg.dwTimestamp = ::GetTickCount();
	msg.wParam = wParam;
	msg.lParam = lParam;
	pControl->HandleMessageTemplate(msg);

	return true;
}

TFontInfo* Window::GetDefaultFontInfo()
{
	if( m_DefaultFontInfo.tm.tmHeight == 0 ) {
		HFONT hOldFont = (HFONT) ::SelectObject(m_hDcPaint, m_DefaultFontInfo.hFont);
		::GetTextMetrics(m_hDcPaint, &m_DefaultFontInfo.tm);
		::SelectObject(m_hDcPaint, hOldFont);
	}
	return &m_DefaultFontInfo;
}

void Window::AddClass(const std::wstring& strClassName, const std::wstring& strControlAttrList)
{
	ASSERT(!strClassName.empty());
	ASSERT(!strControlAttrList.empty());
	m_DefaultAttrHash[strClassName] = strControlAttrList;
}

const std::map<std::wstring, std::wstring>* Window::GetClassMap()
{
	return &m_DefaultAttrHash;
}

std::wstring Window::GetClassAttributes(const std::wstring& strClassName) const
{
	auto it = m_DefaultAttrHash.find(strClassName);
	if (it != m_DefaultAttrHash.end())
	{
		return it->second;
	}

	return L"";
}

bool Window::RemoveClass(const std::wstring& strClassName)
{
	auto it = m_DefaultAttrHash.find(strClassName);
	if (it != m_DefaultAttrHash.end())
	{
		m_DefaultAttrHash.erase(it);
		return true;
	}
	return false;
}


void Window::RemoveAllClass()
{
	m_DefaultAttrHash.clear();
}

Control* Window::GetRoot() const
{
	return m_pRoot;
}

Control* Window::FindControl(POINT pt) const
{
	ASSERT(m_pRoot);
	return m_pRoot->FindControl(__FindControlFromPoint, &pt, UIFIND_VISIBLE | UIFIND_HITTEST | UIFIND_TOP_FIRST);
}

Control* Window::FindControl(const std::wstring& strName) const
{
	ASSERT(m_pRoot);
	Control* findedControl = NULL; 
	auto it = m_mNameHash.find(strName);
	if (it != m_mNameHash.end())
	{
		findedControl = it->second;
	}

	return findedControl;
}

Control* Window::FindSubControlByPoint(Control* pParent, POINT pt) const
{
	if( pParent == NULL ) pParent = GetRoot();
	ASSERT(pParent);
	return pParent->FindControl(__FindControlFromPoint, &pt, UIFIND_VISIBLE | UIFIND_HITTEST | UIFIND_TOP_FIRST);
}

Control* Window::FindSubControlByName(Control* pParent, const std::wstring& strName) const
{
	if( pParent == NULL ) pParent = GetRoot();
	ASSERT(pParent);
	return pParent->FindControl(__FindControlFromName, (LPVOID)strName.c_str(), UIFIND_ALL);
}

Control* Window::FindSubControlByClass(Control* pParent, const type_info& typeinfo, int iIndex)
{
	if( pParent == NULL ) pParent = GetRoot();
	ASSERT(pParent);
	m_aFoundControls.clear();
	m_aFoundControls.resize(iIndex + 1);
	return pParent->FindControl(__FindControlFromClass, (LPVOID)&typeinfo, UIFIND_ALL);
}

std::vector<Control*>* Window::FindSubControlsByClass(Control* pParent, const type_info& typeinfo)
{
	if( pParent == NULL ) pParent = GetRoot();
	ASSERT(pParent);
	m_aFoundControls.clear();
	pParent->FindControl(__FindControlsFromClass, (LPVOID)&typeinfo, UIFIND_ALL);
	return &m_aFoundControls;
}


std::vector<Control*>* Window::GetSubControlsByClass()
{
	return &m_aFoundControls;
}

Control* CALLBACK Window::__FindControlFromNameHash(Control* pThis, LPVOID pData)
{
	Window* pManager = static_cast<Window*>(pData);
	std::wstring sName = pThis->GetName();
	if( sName.empty() ) return NULL;
	// Add this control to the hash list
	pManager->m_mNameHash[sName] = pThis;
	return NULL; // Attempt to add all controls
}

Control* CALLBACK Window::__FindControlFromCount(Control* /*pThis*/, LPVOID pData)
{
	int* pnCount = static_cast<int*>(pData);
	(*pnCount)++;
	return NULL;  // Count all controls
}

Control* CALLBACK Window::__FindControlFromPoint(Control* pThis, LPVOID pData)
{
	LPPOINT pPoint = static_cast<LPPOINT>(pData);
	UiRect pos = pThis->GetPos();
	return ::PtInRect(&pos, *pPoint) ? pThis : NULL;
}

//Control* CALLBACK Window::__FindControlFromTab(Control* pThis, LPVOID pData)
//{
//	FINDTABINFO* pInfo = static_cast<FINDTABINFO*>(pData);
//	if( pInfo->pFocus == pThis ) {
//		if( pInfo->bForward ) pInfo->bNextIsIt = true;
//		return pInfo->bForward ? NULL : pInfo->pLast;
//	}
//	if( (pThis->GetControlFlags() & UIFLAG_TABSTOP) == 0 ) return NULL;
//	pInfo->pLast = pThis;
//	if( pInfo->bNextIsIt ) return pThis;
//	if( pInfo->pFocus == NULL ) return pThis;
//	return NULL;  // Examine all controls
//}

//Control* CALLBACK Window::__FindControlFromShortcut(Control* pThis, LPVOID pData)
//{
//	if( !pThis->IsVisible() ) return NULL; 
//	FINDSHORTCUT* pFS = static_cast<FINDSHORTCUT*>(pData);
//	if( pFS->ch == toupper(pThis->GetShortcut()) ) pFS->bPickNext = true;
//	if( typeid(*pThis) == typeid(Label) ) return NULL;   // Labels never get focus!
//	return pFS->bPickNext ? pThis : NULL;
//}

Control* CALLBACK Window::__FindControlFromUpdate(Control* pThis, LPVOID pData)
{
	return pThis->IsArranged() ? pThis : NULL;
}

Control* CALLBACK Window::__FindControlFromName(Control* pThis, LPVOID pData)
{
	LPCTSTR pstrName = static_cast<LPCTSTR>(pData);
	const std::wstring& sName = pThis->GetName();
	if( sName.empty() ) return NULL;
	return (_tcsicmp(sName.c_str(), pstrName) == 0) ? pThis : NULL;
}

Control* CALLBACK Window::__FindControlFromClass(Control* pThis, LPVOID pData)
{
	type_info* pTypeInfo = static_cast<type_info*>(pData);
	std::vector<Control*>* pFoundControls = pThis->GetWindow()->GetSubControlsByClass();
	if( typeid(*pThis) == *pTypeInfo ) {
		int iIndex = -1;
		while( (*pFoundControls)[++iIndex] != NULL ) ;
		if( (std::size_t)iIndex < pFoundControls->size() ) (*pFoundControls)[iIndex] = pThis;
	}
	if( (*pFoundControls)[pFoundControls->size() - 1] != NULL ) return pThis; 
	return NULL;
}

Control* CALLBACK Window::__FindControlsFromClass(Control* pThis, LPVOID pData)
{
	type_info* pTypeInfo = static_cast<type_info*>(pData);
	if( typeid(*pThis) == *pTypeInfo ) 
		pThis->GetWindow()->GetSubControlsByClass()->push_back(pThis);
	return NULL;
}

bool Window::TranslateAccelerator(LPMSG pMsg)
{
	for (auto it = m_aTranslateAccelerator.begin(); it != m_aTranslateAccelerator.end(); it++) {
		LRESULT lResult = (*it)->TranslateAccelerator(pMsg);
		if( lResult == S_OK ) return true;
	}
	return false;
}

bool Window::AddTranslateAccelerator(ITranslateAccelerator *pTranslateAccelerator)
{
	ASSERT(std::find(m_aTranslateAccelerator.begin(), m_aTranslateAccelerator.end(), pTranslateAccelerator) == m_aTranslateAccelerator.end());
	m_aTranslateAccelerator.push_back(pTranslateAccelerator);
	return true;
}

bool Window::RemoveTranslateAccelerator(ITranslateAccelerator *pTranslateAccelerator)
{
	for (auto it = m_aTranslateAccelerator.begin(); it != m_aTranslateAccelerator.end(); it++) {
		if (*it == pTranslateAccelerator)
		{
			m_aTranslateAccelerator.erase(it);
			return true;
		}
	}
	return false;
}

void Window::KillFocus()
{
	if( m_pFocus != NULL ) 
	{
		m_pFocus->HandleMessageTemplate(EventType::INTERNAL_KILLFOCUS);
		SendNotify(m_pFocus, EventType::KILLFOCUS);
		m_pFocus = NULL;
	}
}


UiRect Window::Shadow::GetShadowLength() const
{
	if (IsShadowAttached()) {
		return m_rcShadowLength;
	}
	else {
		return UiRect(0, 0, 0, 0);
	}
}

Box* Window::Shadow::AttachShadow(Box* pRoot)
{
	if (!IsShadowAttached()) {
		return pRoot;
	}

	m_pRoot = new Box();
	m_pRoot->GetLayout()->SetPadding(GetShadowLength());
	int rootWidth = pRoot->GetFixedWidth();
	if (rootWidth != DUI_LENGTH_AUTO) {
		rootWidth += GetShadowLength().left + GetShadowLength().right;
	}
	m_pRoot->SetFixedWidth(rootWidth);
	int rootHeight = pRoot->GetFixedHeight();
	if (rootHeight != DUI_LENGTH_AUTO) {
		rootHeight += GetShadowLength().top + GetShadowLength().bottom;
	}
	m_pRoot->SetFixedHeight(rootHeight);
	CSize size = { 3, 3 };
	pRoot->SetBorderRound(size);
	m_pRoot->Add(pRoot);
	m_pRoot->SetBkImage(L"file='../public/bk/bk_shadow.png' corner='30,30,30,30'");

	return m_pRoot;
}

void Window::Shadow::SetFocus(bool bFocused)
{
	if (!IsShadowAttached()) {
		return;
	}

	if (bFocused) {
		if (m_pRoot) {
			m_pRoot->SetBkImage(L"file='../public/bk/bk_focus_shadow.png' corner='30,30,30,30'");
		}
	}
	else {
		if (m_pRoot) {
			m_pRoot->SetBkImage(L"file='../public/bk/bk_nofocus_shadow.png' corner='30,30,30,30'");
		}
	}
}

void Window::Shadow::MaximizedOrRestored(bool isMaximized)
{
	if (!IsShadowAttached()) {
		return;
	}

	if (isMaximized && m_pRoot) {
		m_rcShadowLength = UiRect(0, 0, 0, 0);
		m_pRoot->GetLayout()->SetPadding(GetShadowLength());
		Control* control = m_pRoot->GetItemAt(0);
		CSize size = { 0, 0 };
		control->SetBorderRound(size);
	}
	else if (!isMaximized && m_pRoot) {
		m_rcShadowLength = UiRect(14, 14, 14, 14);
		m_pRoot->GetLayout()->SetPadding(GetShadowLength());
		Control* control = m_pRoot->GetItemAt(0);
		CSize size = { 3, 3 };
		control->SetBorderRound(size);
	}
}


} // namespace ui
