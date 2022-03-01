/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "stdafx.h"

namespace ui
{

//////////////////////////////////////////////////////////////////////////

LPBYTE WindowImplBase::m_lpResourceZIPBuffer=NULL;

void WindowImplBase::OnFinalMessage( HWND hWnd )
{
	__super::OnFinalMessage(hWnd);
	RemovePreMessageFilter(this);
	ReapObjects(GetRoot());
	delete this;
}

UINT WindowImplBase::GetClassStyle() const
{
	return CS_DBLCLKS;
}

UILIB_RESOURCETYPE WindowImplBase::GetResourceType() const
{
	return UILIB_FILE;
}

std::wstring WindowImplBase::GetZIPFileName() const
{
	return _T("");
}

std::wstring WindowImplBase::GetResourceID() const
{
	return _T("");
}

Control* WindowImplBase::CreateControl(const std::wstring& pstrClass)
{
	return NULL;
}

LRESULT WindowImplBase::MessageHandler(UINT uMsg, WPARAM wParam, LPARAM /*lParam*/, bool& /*bHandled*/)
{
	return FALSE;
}

LRESULT WindowImplBase::OnClose(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::OnDestroy(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::OnNcActivate(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
{
	if( ::IsIconic(GetHWND()) ) bHandled = FALSE;
	return (wParam == 0) ? TRUE : FALSE;
}

LRESULT WindowImplBase::OnNcCalcSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	LPRECT pRect=NULL;

	if ( wParam == TRUE)
	{
		LPNCCALCSIZE_PARAMS pParam = (LPNCCALCSIZE_PARAMS)lParam;
		pRect=&pParam->rgrc[0];
	}
	else
	{
		pRect=(LPRECT)lParam;
	}

	if (::IsZoomed(m_hWnd))
	{	
		// 最大化时，计算当前显示器最适合宽高度
		MONITORINFO oMonitor = { sizeof(MONITORINFO) };
		::GetMonitorInfo(::MonitorFromWindow(m_hWnd, MONITOR_DEFAULTTONEAREST), &oMonitor);
		UiRect rcWork = oMonitor.rcWork;
		//UiRect rcMonitor = oMonitor.rcMonitor;
		//rcWork.Offset(-oMonitor.rcMonitor.left, -oMonitor.rcMonitor.top);

		//pRect->right = pRect->left + rcWork.GetWidth();
		//pRect->bottom = pRect->top + rcWork.GetHeight();

		UiRect rcMaximize = GetMaximizeInfo();
		if (rcMaximize.GetWidth() > 0 && rcMaximize.GetHeight() > 0)
		{
			pRect->left	= rcWork.left + rcMaximize.left;
			pRect->top	= rcWork.top + rcMaximize.top;
			pRect->right = pRect->left + rcMaximize.GetWidth();
			pRect->bottom = pRect->top + rcMaximize.GetHeight();
		} 
		else
		{
			pRect->left = rcWork.left;
			pRect->top  = rcWork.top;
			pRect->right = rcWork.right;
			pRect->bottom = rcWork.bottom;
		}

		return WVR_REDRAW;
	}

	return 0;
}

LRESULT WindowImplBase::OnNcPaint(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
{
	return 0;
}

LRESULT WindowImplBase::OnNcHitTest(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	POINT pt; pt.x = GET_X_LPARAM(lParam); pt.y = GET_Y_LPARAM(lParam);
	::ScreenToClient(GetHWND(), &pt);

	UiRect rcClient;
	::GetClientRect(GetHWND(), &rcClient);
	
	rcClient.Deflate(m_shadow.GetShadowLength());
	
	if( !::IsZoomed(GetHWND()) )
	{
		UiRect rcSizeBox = GetSizeBox();
		if( pt.y < rcClient.top + rcSizeBox.top )
		{
			if (pt.y >= rcClient.top) {
				if (pt.x < rcClient.left + rcSizeBox.left) return HTTOPLEFT;
				else if (pt.x > rcClient.right - rcSizeBox.right) return HTTOPRIGHT;
				else return HTTOP;
			}
			else return HTCLIENT;
		}
		else if( pt.y > rcClient.bottom - rcSizeBox.bottom )
		{
			if (pt.y <= rcClient.bottom) {
				if (pt.x < rcClient.left + rcSizeBox.left) return HTBOTTOMLEFT;
				else if (pt.x > rcClient.right - rcSizeBox.right) return HTBOTTOMRIGHT;
				else return HTBOTTOM;
			}
			else return HTCLIENT;
		}

		if (pt.x < rcClient.left + rcSizeBox.left) {
			if (pt.x >= rcClient.left) return HTLEFT;
			else return HTCLIENT;
		}
		if (pt.x > rcClient.right - rcSizeBox.right) {
			if (pt.x <= rcClient.right) return HTRIGHT;
			else return HTCLIENT;
		}
	}

	UiRect rcCaption = GetCaptionRect();
	if( pt.x >= rcClient.left + rcCaption.left && pt.x < rcClient.right - rcCaption.right \
		&& pt.y >= rcClient.top + rcCaption.top && pt.y < rcClient.top + rcCaption.bottom ) {
			Control* pControl = static_cast<Control*>(FindControl(pt));
			if( pControl && dynamic_cast<Button*>(pControl) == NULL)
				return HTCAPTION;
	}

	return HTCLIENT;
}

LRESULT WindowImplBase::OnGetMinMaxInfo(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	LPMINMAXINFO lpMMI = (LPMINMAXINFO) lParam;
	MONITORINFO oMonitor = {};
	oMonitor.cbSize = sizeof(oMonitor);
	::GetMonitorInfo(::MonitorFromWindow(GetHWND(), MONITOR_DEFAULTTONEAREST), &oMonitor);
	UiRect rcWork = oMonitor.rcWork;
	UiRect rcMonitor = oMonitor.rcMonitor;
	rcWork.Offset(-oMonitor.rcMonitor.left, -oMonitor.rcMonitor.top);

	UiRect rcMaximize = GetMaximizeInfo();
	if (rcMaximize.GetWidth() > 0 && rcMaximize.GetHeight() > 0)
	{
		lpMMI->ptMaxPosition.x	= rcWork.left + rcMaximize.left;
		lpMMI->ptMaxPosition.y	= rcWork.top + rcMaximize.top;
		lpMMI->ptMaxSize.x = rcMaximize.GetWidth();
		lpMMI->ptMaxSize.y = rcMaximize.GetHeight();
	} 
	else
	{
		// 计算最大化时，正确的原点坐标
		lpMMI->ptMaxPosition.x	= rcWork.left;
		lpMMI->ptMaxPosition.y	= rcWork.top;
		lpMMI->ptMaxSize.x = rcWork.GetWidth();
		lpMMI->ptMaxSize.y = rcWork.GetHeight();
	}

	if (GetMaxInfo().cx != 0) {
		lpMMI->ptMaxTrackSize.x = GetMaxInfo(true).cx;
	}
	if (GetMaxInfo().cy != 0) {
		lpMMI->ptMaxTrackSize.y = GetMaxInfo(true).cy;
	}
	if (GetMinInfo().cx != 0) {
		lpMMI->ptMinTrackSize.x = GetMinInfo(true).cx;
	}
	if (GetMinInfo().cy != 0) {
		lpMMI->ptMinTrackSize.y = GetMinInfo(true).cy;
	}

	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::OnMouseWheel(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::OnMouseHover(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::OnSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	CSize szRoundCorner = GetRoundCorner();
	if( !::IsIconic(GetHWND()) && (szRoundCorner.cx != 0 || szRoundCorner.cy != 0) ) {
		UiRect rcWnd;
		::GetWindowRect(GetHWND(), &rcWnd);
		rcWnd.Offset(-rcWnd.left, -rcWnd.top);
		rcWnd.right++; rcWnd.bottom++;
		HRGN hRgn = ::CreateRoundRectRgn(rcWnd.left, rcWnd.top, rcWnd.right, rcWnd.bottom, szRoundCorner.cx, szRoundCorner.cy);
		::SetWindowRgn(GetHWND(), hRgn, TRUE);
		::DeleteObject(hRgn);
	}

	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::OnChar(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::OnSysCommand(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	if (wParam == SC_CLOSE)
	{
		bHandled = TRUE;
		SendMessage(WM_CLOSE);
		return 0;
	}
	BOOL bZoomed = ::IsZoomed(GetHWND());
	LRESULT lRes = Window::HandleMessage(uMsg, wParam, lParam);
	if( ::IsZoomed(GetHWND()) != bZoomed )
	{
	}

	return lRes;
}

LRESULT WindowImplBase::OnCreate(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	Init(m_hWnd);
	AddPreMessageFilter(this);
	SetWindowResourcePath(GetSkinFolder());

	WindowBuilder builder;
	switch(GetResourceType())
	{
	case UILIB_ZIP:
		ASSERT(FALSE);
		break;
	case UILIB_ZIPRESOURCE:
		{
			ASSERT(FALSE);
		}
		break;
	}

	Box* pRoot=NULL;
	if (GetResourceType()==UILIB_RESOURCE)
	{
		STRINGorID xml(_ttoi(GetSkinFile().c_str()));
		auto callback = std::bind(&WindowImplBase::CreateControl, this, std::placeholders::_1);
		pRoot = (Box*)builder.Create(xml, callback, this);
	}
	else {
		auto callback = std::bind(&WindowImplBase::CreateControl, this, std::placeholders::_1);
		pRoot = (Box*)builder.Create((GetWindowResourcePath() + GetSkinFile()).c_str(), callback, this);
	}
	ASSERT(pRoot);
	if (pRoot == NULL)
	{
		MessageBox(NULL,_T("加载资源文件失败"),_T("Duilib"),MB_OK|MB_ICONERROR);
		return -1;
	}
	
	pRoot = m_shadow.AttachShadow(pRoot);

	AttachDialog(pRoot);

	InitWindow();

	if (pRoot->GetFixedWidth() == DUI_LENGTH_AUTO || pRoot->GetFixedHeight() == DUI_LENGTH_AUTO) {
		CSize maxSize = {99999, 99999};
		CSize need_size = pRoot->EstimateSize(maxSize);
		if( need_size.cx < pRoot->GetMinWidth() ) need_size.cx = pRoot->GetMinWidth();
		if( pRoot->GetMaxWidth() >= 0 && need_size.cx > pRoot->GetMaxWidth() ) need_size.cx = pRoot->GetMaxWidth();
		if( need_size.cy < pRoot->GetMinHeight() ) need_size.cy = pRoot->GetMinHeight();
		if( need_size.cy > pRoot->GetMaxHeight() ) need_size.cy = pRoot->GetMaxHeight();

		::MoveWindow(m_hWnd, 0, 0, need_size.cx, need_size.cy, FALSE);
	}

	Control* closeControl = (Control*)FindControl(L"closebtn");
	if (closeControl)
	{
		Button* closeBtn = dynamic_cast<Button*>(closeControl);
		ASSERT(closeBtn);
		closeBtn->AttachClick(std::bind(&WindowImplBase::BtnClick, this, std::placeholders::_1));
	}
	Control* minControl = (Control*)FindControl(L"minbtn");
	if (minControl)
	{
		Button* minBtn = dynamic_cast<Button*>(minControl);
		ASSERT(minBtn);
		minBtn->AttachClick(std::bind(&WindowImplBase::BtnClick, this, std::placeholders::_1));
	}
	Control* maxControl = (Control*)FindControl(L"maxbtn");
	if (maxControl)
	{
		Button* maxBtn = dynamic_cast<Button*>(maxControl);
		ASSERT(maxBtn);
		maxBtn->AttachClick(std::bind(&WindowImplBase::BtnClick, this, std::placeholders::_1));
	}
	Control* restoreControl = (Control*)FindControl(L"restorebtn");
	if (restoreControl)
	{
		Button* restoreBtn = dynamic_cast<Button*>(restoreControl);
		ASSERT(restoreBtn);
		restoreBtn->AttachClick(std::bind(&WindowImplBase::BtnClick, this, std::placeholders::_1));
	}

	return 0;
}

LRESULT WindowImplBase::OnKeyDown(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::OnKillFocus(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::OnSetFocus(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::OnLButtonDown(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::OnLButtonUp(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::OnMouseMove(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	bHandled = FALSE;
	return 0;
}

LRESULT WindowImplBase::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	LRESULT lRes = 0;
	BOOL bHandled = TRUE;
	switch (uMsg)
	{
	case WM_CREATE:			lRes = OnCreate(uMsg, wParam, lParam, bHandled); break;
	case WM_CLOSE:			lRes = OnClose(uMsg, wParam, lParam, bHandled); break;
	case WM_DESTROY:		lRes = OnDestroy(uMsg, wParam, lParam, bHandled); break;
	case WM_NCACTIVATE:		lRes = OnNcActivate(uMsg, wParam, lParam, bHandled); break;
	case WM_NCCALCSIZE:		lRes = OnNcCalcSize(uMsg, wParam, lParam, bHandled); break;
	case WM_NCPAINT:		lRes = OnNcPaint(uMsg, wParam, lParam, bHandled); break;
	case WM_NCHITTEST:		lRes = OnNcHitTest(uMsg, wParam, lParam, bHandled); break;
	case WM_GETMINMAXINFO:	lRes = OnGetMinMaxInfo(uMsg, wParam, lParam, bHandled); break;
	case WM_MOUSEWHEEL:		lRes = OnMouseWheel(uMsg, wParam, lParam, bHandled); break;
	case WM_SIZE:			lRes = OnSize(uMsg, wParam, lParam, bHandled); break;
	case WM_CHAR:		lRes = OnChar(uMsg, wParam, lParam, bHandled); break;
	case WM_SYSCOMMAND:		lRes = OnSysCommand(uMsg, wParam, lParam, bHandled); break;
	case WM_KEYDOWN:		lRes = OnKeyDown(uMsg, wParam, lParam, bHandled); break;
	case WM_KILLFOCUS:		lRes = OnKillFocus(uMsg, wParam, lParam, bHandled); break;
	case WM_SETFOCUS:		lRes = OnSetFocus(uMsg, wParam, lParam, bHandled); break;
	case WM_LBUTTONUP:		lRes = OnLButtonUp(uMsg, wParam, lParam, bHandled); break;
	case WM_LBUTTONDOWN:	lRes = OnLButtonDown(uMsg, wParam, lParam, bHandled); break;
	case WM_MOUSEMOVE:		lRes = OnMouseMove(uMsg, wParam, lParam, bHandled); break;
	case WM_MOUSEHOVER:	lRes = OnMouseHover(uMsg, wParam, lParam, bHandled); break;
	default:				bHandled = FALSE; break;
	}

	if (bHandled) return lRes;

	return Window::HandleMessage(uMsg, wParam, lParam);
}

LONG WindowImplBase::GetStyle()
{
	LONG styleValue = ::GetWindowLong(GetHWND(), GWL_STYLE);
	styleValue &= ~WS_CAPTION;

	return styleValue;
}

bool WindowImplBase::BtnClick(EventArgs* msg)
{
	std::wstring sCtrlName = msg->pSender->GetName();
	if( sCtrlName == _T("closebtn") )
	{
		Close();
	}
	else if( sCtrlName == _T("minbtn"))
	{ 
		SendMessage(WM_SYSCOMMAND, SC_MINIMIZE, 0); 
	}
	else if( sCtrlName == _T("maxbtn"))
	{ 
		SendMessage(WM_SYSCOMMAND, SC_MAXIMIZE, 0); 
	}
	else if( sCtrlName == _T("restorebtn"))
	{ 
		SendMessage(WM_SYSCOMMAND, SC_RESTORE, 0); 
	}

	return true;
}

}