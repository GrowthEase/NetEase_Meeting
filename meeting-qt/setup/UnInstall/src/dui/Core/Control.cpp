/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"
#include "shlwapi.h"
#include "../Animation/AnimationPlayer.h"

namespace ui {


Control::Control()
{
	m_colorMap.SetControl(this);
	m_imageMap.SetControl(this);
	m_foreImageMap.SetControl(this);
	m_animationManager.Init(this);
}

Control::~Control()
{
	m_pWindow->ReapObjects(this);
}

CursorType Control::GetCursorType() const
{
    return m_cursorType;
}

void Control::SetCursorType( CursorType flag )
{
	m_cursorType = flag;
}

void Control::Activate()
{

}

bool Control::IsActivatable() const
{
	if( !IsVisible() ) return false;
	if( !IsEnabled() ) return false;
	return true;
}

std::wstring Control::GetBkColor() const
{
	return m_dwBkColor;
}

void Control::SetBkColor(const std::wstring& dwColor)
{
	ASSERT(dwColor.empty() || !GlobalManager::GetTextColor(dwColor).empty());
	if( m_dwBkColor == dwColor ) return;

	m_dwBkColor = dwColor;
	Invalidate();
}

std::wstring Control::GetStateColor(ControlStateType stateType)
{
	return m_colorMap[stateType];
}

void Control::SetStateColor(ControlStateType stateType, const std::wstring& dwColor)
{
	ASSERT(!GlobalManager::GetTextColor(dwColor).empty());
	if( m_colorMap[stateType] == dwColor ) return;

	if (stateType == ControlStateType::HOT) {
		m_animationManager.SetFadeHot(true);
	}
	m_colorMap[stateType] = dwColor;
	Invalidate();
}

std::wstring Control::GetBkImage() const
{
	return m_diBkImage.imageAttribute.imageString;
}

std::string Control::GetUTF8BkImage() const
{
	int multiLength = WideCharToMultiByte(CP_UTF8, NULL, m_diBkImage.imageAttribute.imageString.c_str(), -1, NULL, 0, NULL, NULL);
	if (multiLength <= 0)
		return "";
	std::unique_ptr<char[]> strImage(new char[multiLength]);
	WideCharToMultiByte(CP_UTF8, NULL, m_diBkImage.imageAttribute.imageString.c_str(), -1, strImage.get(), multiLength, NULL, NULL);

	std::string res = strImage.get();

	return res;
}

void Control::SetBkImage(const std::wstring& pStrImage)
{
	StopGifPlay();
	m_diBkImage.SetImageString(pStrImage);
	if (GetFixedWidth() == DUI_LENGTH_AUTO || GetFixedHeight() == DUI_LENGTH_AUTO) {
		ArrangeAncestor();
	}
	else {
		Invalidate();
	}
}

void Control::SetUTF8BkImage(const std::string& pStrImage)
{
	int wideLength = MultiByteToWideChar(CP_UTF8, NULL, pStrImage.c_str(), -1, NULL, 0);
	if (wideLength <= 0) {
		SetBkImage(L"");
		return;
	}
	std::unique_ptr<wchar_t[]> strImage(new wchar_t[wideLength]);
	MultiByteToWideChar(CP_UTF8, NULL, pStrImage.c_str(), -1, strImage.get(), wideLength);
	SetBkImage(strImage.get());
}

std::wstring Control::GetStateImage(ControlStateType stateType)
{
	return m_imageMap[stateType].imageAttribute.imageString;
}

void Control::SetStateImage(ControlStateType stateType, const std::wstring& pStrImage)
{
	if (stateType == ControlStateType::HOT) {
		m_animationManager.SetFadeHot(true);
	}
	m_imageMap[stateType].SetImageString(pStrImage);
	if (GetFixedWidth() == DUI_LENGTH_AUTO || GetFixedHeight() == DUI_LENGTH_AUTO) {
		ArrangeAncestor();
	}
	else {
		Invalidate();
	}
}

std::wstring Control::GetForeStateImage(ControlStateType stateType)
{
	return m_foreImageMap[stateType].imageAttribute.imageString;
}

void Control::SetForeStateImage(ControlStateType stateType, const std::wstring& pStrImage)
{
	if (stateType == ControlStateType::HOT) {
		m_animationManager.SetFadeHot(true);
	}
	m_foreImageMap[stateType].SetImageString(pStrImage);
	Invalidate();
}

ControlStateType Control::GetState() const
{
	return m_uButtonState;
}

void Control::SetState(ControlStateType pStrState) 
{
	if (pStrState == ControlStateType::NORMAL) {
		m_nHotAlpha = 0;
	}
	else if (pStrState == ControlStateType::HOT) {
		m_nHotAlpha = 255;
	}

	m_uButtonState = pStrState;
	Invalidate();
}

Image* Control::GetEstimateImage()
{
	Image* estimateImage = nullptr;
	if (!m_diBkImage.imageAttribute.sImageName.empty()) {
		estimateImage = &m_diBkImage;
	}
	else {
		estimateImage = m_imageMap.GetEstimateImage();
	}

	return estimateImage;
}

std::wstring Control::GetBorderColor() const
{
    return m_dwBorderColor;
}

void Control::SetBorderColor(const std::wstring& dwBorderColor)
{
    if( m_dwBorderColor == dwBorderColor ) return;

    m_dwBorderColor = dwBorderColor;
    Invalidate();
}

int Control::GetBorderSize() const
{
    return m_nBorderSize;
}

void Control::SetBorderSize(int nSize)
{
    if( m_nBorderSize == nSize ) return;

    m_nBorderSize = nSize;
    Invalidate();
}

void Control::SetBorderSize( UiRect rc )
{
	m_rcBorderSize = rc;
	Invalidate();
}

CSize Control::GetBorderRound() const
{
    return m_cxyBorderRound;
}

void Control::SetBorderRound(CSize cxyRound)
{
    m_cxyBorderRound = cxyRound;
    Invalidate();
}

void Control::GetImage(Image& duiImage) const
{
	std::wstring sImageName = duiImage.imageAttribute.sImageName;
	std::wstring imageFullPath = sImageName;
	if (::PathIsRelative(sImageName.c_str())) {
		imageFullPath = GlobalManager::GetResourcePath() + m_pWindow->GetWindowResourcePath() + sImageName; 
	}
	imageFullPath = StringHelper::ReparsePath(imageFullPath);

	if (!duiImage.imageCache || duiImage.imageCache->sImageFullPath != imageFullPath) {
		duiImage.imageCache =  GlobalManager::GetImage(imageFullPath);
	}
}

bool Control::DrawImage(HDC hDC, Image& duiImage, const std::wstring& pStrModify, int fade)
{
	std::wstring sImageName = duiImage.imageAttribute.sImageName;
	if (sImageName.empty()) {
		return false;
	}

	GetImage(duiImage);

	if( !duiImage.imageCache ) {
		ASSERT(FALSE);
		duiImage.imageAttribute.Init();
		return false;    
	}

	ImageAttribute newImageAttribute = duiImage.imageAttribute;
	if (!pStrModify.empty()) {
		ImageAttribute::ModifyAttribute(newImageAttribute, pStrModify);
	}
	UiRect newRcDest = m_rcItem;
	if (newImageAttribute.rcDest.left != DUI_NOSET_VALUE && newImageAttribute.rcDest.top != DUI_NOSET_VALUE
		&& newImageAttribute.rcDest.right != DUI_NOSET_VALUE && newImageAttribute.rcDest.bottom != DUI_NOSET_VALUE) {
		newRcDest.left = m_rcItem.left + newImageAttribute.rcDest.left;
		newRcDest.right = m_rcItem.left + newImageAttribute.rcDest.right;
		newRcDest.top = m_rcItem.top + newImageAttribute.rcDest.top;
		newRcDest.bottom = m_rcItem.top + newImageAttribute.rcDest.bottom;
	}
	UiRect newRcSource = newImageAttribute.rcSource; 
	if (newRcSource.left == DUI_NOSET_VALUE || newRcSource.top == DUI_NOSET_VALUE
		|| newRcSource.right == DUI_NOSET_VALUE || newRcSource.bottom == DUI_NOSET_VALUE) {
		newRcSource.left = 0;
		newRcSource.top = 0;
		newRcSource.right = duiImage.imageCache->nX;
		newRcSource.bottom = duiImage.imageCache->nY;
	}

	if (m_diBkImage.imageCache && m_diBkImage.imageCache->IsGif() && m_bGifPlay && !m_diBkImage.IsPlaying()) {
		GifPlay();
	}
	else {
		int iFade = fade == DUI_NOSET_VALUE ? newImageAttribute.bFade : fade;
		ImageInfo* imageInfo = duiImage.imageCache.get();
		RenderEngine::GdiDrawImage(hDC, m_pWindow->GetCanvasTransparent(), m_rcPaint, duiImage.GetCurrentHBitmap(), imageInfo->IsAlpha(), 
			newRcDest, newRcSource, newImageAttribute.rcCorner, iFade, newImageAttribute.bTiledX, newImageAttribute.bTiledY);
	}

	return true;
}

UiRect Control::GetPos(bool bContainShadow) const
{
	UiRect pos = m_rcItem;
	if (m_pWindow && !bContainShadow) {
		UiRect shadowLength = m_pWindow->GetShadowLength();
		pos.Offset(-shadowLength.left, -shadowLength.top);
	}
	
	return pos;
}

void Control::SetPos(UiRect rc)
{
    if( rc.right < rc.left ) rc.right = rc.left;
    if( rc.bottom < rc.top ) rc.bottom = rc.top;

    UiRect invalidateRc = m_rcItem;
    if( ::IsRectEmpty(&invalidateRc) ) invalidateRc = rc;

    m_rcItem = rc;
    if( m_pWindow == NULL ) return;

    if( !m_bSetPos ) {
        m_bSetPos = true;
		//OnSize(this);
        m_bSetPos = false;
    }
    
    m_bIsArranged = false;
    invalidateRc.Union(m_rcItem);

    Control* pParent = this;
    UiRect rcTemp;
    UiRect rcParent;
    while( (pParent = pParent->GetParent()) != nullptr)
    {
        rcTemp = invalidateRc;
        rcParent = pParent->GetPos();
        if( !::IntersectRect(&invalidateRc, &rcTemp, &rcParent) ) 
        {
            return;
        }
    }
    m_pWindow->Invalidate(invalidateRc);
}

UiRect Control::GetMargin() const
{
    return m_rcMargin;
}

void Control::SetMargin(UiRect rcMargin)
{
    m_rcMargin = rcMargin;
    ArrangeAncestor();
}

std::wstring Control::GetToolTip() const
{
    return m_sToolTip;
}

std::string Control::GetUTF8ToolTip() const
{
	int multiLength = WideCharToMultiByte(CP_UTF8, NULL, m_sToolTip.c_str(), -1, NULL, 0, NULL, NULL);
	if (multiLength <= 0)
		return "";
	std::unique_ptr<char[]> strText(new char[multiLength]);
	WideCharToMultiByte(CP_UTF8, NULL, m_sToolTip.c_str(), -1, strText.get(), multiLength, NULL, NULL);

	std::string res = strText.get();

	return res;
}

void Control::SetToolTip(const std::wstring& pstrText)
{
	std::wstring strTemp(pstrText);
	StringHelper::ReplaceAll(_T("<n>"),_T("\r\n"), strTemp);
	m_sToolTip=strTemp;
}

void Control::SetUTF8ToolTip(const std::string& pstrText)
{
	int wideLength = MultiByteToWideChar(CP_UTF8, NULL, pstrText.c_str(), -1, NULL, 0);
	if (wideLength <= 0)
	{
		m_sToolTip = _T("");
		Invalidate();//为空则一律重刷
		return ;
	}
	std::unique_ptr<wchar_t[]> strText(new wchar_t[wideLength]);
	MultiByteToWideChar(CP_UTF8, NULL, pstrText.c_str(), -1, strText.get(), wideLength);

	if( m_sToolTip != strText.get() )
	{
		std::wstring strTemp(strText.get());
		StringHelper::ReplaceAll(_T("<n>"),_T("\r\n"), strTemp);
		m_sToolTip = strTemp;
		Invalidate();
	}
}

void Control::SetToolTipWidth( int nWidth )
{
	m_nTooltipWidth=nWidth;
}

int Control::GetToolTipWidth(void) const
{
	return m_nTooltipWidth;
}

bool Control::IsContextMenuUsed() const
{
    return m_bMenuUsed;
}

void Control::SetContextMenuUsed(bool bMenuUsed)
{
    m_bMenuUsed = bMenuUsed;
}

std::wstring Control::GetDataID() const
{
    return m_sUserData;
}

std::string Control::GetUTF8DataID() const
{
	int multiLength = WideCharToMultiByte(CP_UTF8, NULL, m_sUserData.c_str(), -1, NULL, 0, NULL, NULL);
	if (multiLength <= 0)
		return "";
	std::unique_ptr<char[]> strText(new char[multiLength]);
	WideCharToMultiByte(CP_UTF8, NULL, m_sUserData.c_str(), -1, strText.get(), multiLength, NULL, NULL);

	std::string res = strText.get();

	return res;
}

void Control::SetDataID(const std::wstring& pstrText)
{
    m_sUserData = pstrText;
}

void Control::SetUTF8DataID(const std::string& pstrText)
{
	int wideLength = MultiByteToWideChar(CP_UTF8, NULL, pstrText.c_str(), -1, NULL, 0);
	if (wideLength <= 0)
	{
		m_sUserData = _T("");
		return ;
	}
	std::unique_ptr<wchar_t[]> strText(new wchar_t[wideLength]);
	MultiByteToWideChar(CP_UTF8, NULL, pstrText.c_str(), -1, strText.get(), wideLength);

	m_sUserData = strText.get();
}

UserDataBase* Control::GetUserDataBase() const
{
	return m_sUserDataBase.get();
}

void Control::SetUserDataBase(UserDataBase* userDataBase)
{
	m_sUserDataBase.reset(userDataBase);
}

void Control::SetVisible_(bool bVisible)
{
	if( m_bVisible == bVisible ) return;
	bool v = IsVisible();
	m_bVisible = bVisible;
	if( m_bFocused ) m_bFocused = false;
	if (!bVisible && m_pWindow && m_pWindow->GetFocus() == this) {
		m_pWindow->SetFocus(NULL) ;
	}
	if( IsVisible() != v ) {
		ArrangeAncestor();
	}

	if (!IsVisible()) {
		StopGifPlay();
	}
}

void Control::SetVisible(bool bVisible)
{
	if (bVisible) {
		m_animationManager.Appear();
	}
	else {
		m_animationManager.Disappear();
	}
}

void Control::SetInternVisible(bool bVisible)
{
	m_bInternVisible = bVisible;
	if (!bVisible && m_pWindow && m_pWindow->GetFocus() == this) {
		m_pWindow->SetFocus(NULL) ;
	}

	if (!IsVisible()) {
		StopGifPlay();
	}
}

bool Control::IsEnabled() const
{
    return m_bEnabled;
}

void Control::SetEnabled(bool bEnabled)
{
    if( m_bEnabled == bEnabled ) return;

    m_bEnabled = bEnabled;
	if (m_bEnabled) {
		m_uButtonState = ControlStateType::NORMAL;
		m_nHotAlpha = 0;
	}
	else {
		m_uButtonState = ControlStateType::DISABLED;
	}
    Invalidate();
}

bool Control::IsMouseEnabled() const
{
    return m_bMouseEnabled;
}

void Control::SetMouseEnabled(bool bEnabled)
{
    m_bMouseEnabled = bEnabled;
}

bool Control::IsKeyboardEnabled() const
{
	return m_bKeyboardEnabled ;
}
void Control::SetKeyboardEnabled(bool bEnabled)
{
	m_bKeyboardEnabled = bEnabled ; 
}

bool Control::IsFocused() const
{
    return m_bFocused;
}

void Control::SetFocus()
{
	if( m_bNoFocus )
		return;
    if( m_pWindow != NULL ) m_pWindow->SetFocus(this);
}

Control* Control::FindControl(FINDCONTROLPROC Proc, LPVOID pData, UINT uFlags, CPoint scrollPos)
{
    if( (uFlags & UIFIND_VISIBLE) != 0 && !IsVisible() ) return NULL;
    if( (uFlags & UIFIND_ENABLED) != 0 && !IsEnabled() ) return NULL;
	if( (uFlags & UIFIND_HITTEST) != 0 && (!m_bMouseEnabled || !::PtInRect(&m_rcItem, * static_cast<LPPOINT>(pData))) ) return NULL;
    return Proc(this, pData);
}

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

void Control::HandleMessageTemplate(EventType eventType, WPARAM wParam, LPARAM lParam, TCHAR tChar, CPoint mousePos)
{
	EventArgs msg;
	msg.pSender = this;
	msg.Type = eventType;
	msg.chKey = tChar;
	msg.wParam = wParam;
	msg.lParam = lParam;
	msg.ptMouse = m_pWindow->GetLastMousePos();
	msg.wKeyState = MapKeyState();
	msg.dwTimestamp = ::GetTickCount();

	HandleMessageTemplate(msg);
}

void Control::HandleMessageTemplate(EventArgs& msg)
{
	if (msg.Type == EventType::INTERNAL_DBLCLICK || msg.Type == EventType::INTERNAL_CONTEXTMENU
		|| msg.Type == EventType::INTERNAL_SETFOCUS || msg.Type == EventType::INTERNAL_KILLFOCUS) {
		HandleMessage(msg);
		return;
	}
	bool ret = true;

	if (this == msg.pSender) {
		std::weak_ptr<nbase::WeakFlag> weakflag = GetWeakFlag();
		auto callback = OnEvent.find(msg.Type);
		if (callback != OnEvent.end()) {
			ret = callback->second(&msg);
		}
		if (weakflag.expired()) {
			return;
		}
		callback = OnEvent.find(EventType::ALL);
		if (callback != OnEvent.end()) {
			ret = callback->second(&msg);
		}
		if (weakflag.expired()) {
			return;
		}
		if (ret) {
			auto callback = OnXmlEvent.find(msg.Type);
			if (callback != OnXmlEvent.end()) {
				ret = callback->second(&msg);
			}
			if (weakflag.expired()) {
				return;
			}
			callback = OnXmlEvent.find(EventType::ALL);
			if (callback != OnXmlEvent.end()) {
				ret = callback->second(&msg);
			}
			if (weakflag.expired()) {
				return;
			}
		}
	}
	else {
		ASSERT(FALSE);
	}
	
    if(ret) {
		HandleMessage(msg);
	}
}

void Control::HandleMessage(EventArgs& msg)
{
	if( !IsMouseEnabled() && msg.Type > EventType::MOUSEBEGIN && msg.Type < EventType::MOUSEEND ) {
		if( m_pParent != NULL ) m_pParent->HandleMessageTemplate(msg);
		return;
	}
	else if( msg.Type == EventType::SETCURSOR )
	{
		if (m_cursorType == CursorType::HAND) {
			if (IsEnabled()) {
				::SetCursor(::LoadCursor(NULL, MAKEINTRESOURCE(IDC_HAND)));
			}
			else {
				::SetCursor(::LoadCursor(NULL, MAKEINTRESOURCE(IDC_ARROW)));
			}
			return;
		}
		else if (m_cursorType == CursorType::ARROW){
			::SetCursor(::LoadCursor(NULL, MAKEINTRESOURCE(IDC_ARROW)));
			return;
		}
		else if (m_cursorType == CursorType::IBEAM){
			::SetCursor(::LoadCursor(NULL, MAKEINTRESOURCE(IDC_IBEAM)));
			return;
		}
		else {
			ASSERT(FALSE);
		}
	}
	else if (msg.Type == EventType::INTERNAL_SETFOCUS)
    {
        m_bFocused = true;
        Invalidate();
    }
	else if (msg.Type == EventType::INTERNAL_KILLFOCUS)
    {
        m_bFocused = false;
        Invalidate();
    }
	else if (msg.Type == EventType::INTERNAL_CONTEXTMENU && IsEnabled())
    {
        if( IsContextMenuUsed() ) {
            m_pWindow->SendNotify(this, EventType::MENU, msg.wParam, msg.lParam);
            return;
        }
    }
	else if( msg.Type == EventType::MOUSEENTER ) {
		if (msg.pSender != this && m_pWindow) {
			if (!IsChild(this, m_pWindow->GetNewHover())) {
				return;
			}
		}
		MouseEnter(msg);
	}
	else if( msg.Type == EventType::MOUSELEAVE ) {
		if (msg.pSender != this && m_pWindow) {
			if (IsChild(this, m_pWindow->GetNewHover())) {
				return;
			}
		}
		MouseLeave(msg);
	}
	else if (msg.Type == EventType::BUTTONDOWN || msg.Type == EventType::INTERNAL_DBLCLICK)
	{
		ButtonDown(msg);
		return;
	}
	else if( msg.Type == EventType::BUTTONUP )
	{
		ButtonUp(msg);
		return;
	}

    if( m_pParent != NULL ) m_pParent->HandleMessageTemplate(msg);
}

bool Control::MouseEnter(EventArgs& msg)
{
	if( IsEnabled() ) {
		if ( m_uButtonState == ControlStateType::NORMAL) {
			m_uButtonState = ControlStateType::HOT;
			m_animationManager.MouseEnter();
			Invalidate();
			return true;
		}
	}

	return false;
}

bool Control::MouseLeave(EventArgs& msg)
{
	if( IsEnabled() ) {
		if (m_uButtonState == ControlStateType::HOT) {
			m_uButtonState = ControlStateType::NORMAL;
			m_animationManager.MouseLeave();
			Invalidate();
			return true;
		}
	}

	return false;
}

bool Control::ButtonDown(EventArgs& msg)
{
	bool ret = false;
	if( IsEnabled() ) {
		m_uButtonState = ControlStateType::PUSHED;
		SetMouseFocused(true);
		Invalidate();
		ret = true;
	}

	return ret;
}

bool Control::ButtonUp(EventArgs& msg)
{
	bool ret = false;
	if( IsMouseFocused() ) {
		SetMouseFocused(false);
		Invalidate();
		if( IsPointInWithScrollOffset(msg.ptMouse) ) {
			m_uButtonState = ControlStateType::HOT;
			m_nHotAlpha = 255;
			Activate();
			ret = true;
		}
		else {
			m_uButtonState = ControlStateType::NORMAL;
			m_nHotAlpha = 0;
		}
	}

	return ret;
}

bool Control::IsPointInWithScrollOffset(const CPoint& point) const
{
	CPoint scrollOffset = GetScrollOffset();
	CPoint newPoint = point;
	newPoint.Offset(scrollOffset);
	return m_rcItem.IsPointIn(newPoint);
}



void Control::GifPlay()
{
	if (!m_diBkImage.IsPlaying()) {
		m_diBkImage.SetCurrentFrame(0);
		m_diBkImage.SetPlaying(true);
		m_gifWeakFlag.Cancel();
		auto gifPlayCallback = std::bind(&Control::GifPlay, this);
		TimerManager::GetInstance()->AddCancelableTimer(m_gifWeakFlag.GetWeakFlag(), gifPlayCallback, 
			m_diBkImage.GetCurrentInterval(), TimerManager::REPEAT_FOREVER);
	}
	else {
		int lPause_pre = m_diBkImage.GetCurrentInterval();
		m_diBkImage.IncrementCurrentFrame();
		int lPause = m_diBkImage.GetCurrentInterval();
		if (lPause_pre != lPause) {
			m_gifWeakFlag.Cancel();
			auto gifPlayCallback = std::bind(&Control::GifPlay, this);
			TimerManager::GetInstance()->AddCancelableTimer(m_gifWeakFlag.GetWeakFlag(), gifPlayCallback, 
				lPause, TimerManager::REPEAT_FOREVER);
		}
	}

	Invalidate();
}

void Control::StopGifPlay(GifStopType type)
{
	if (m_diBkImage.imageCache && m_diBkImage.imageCache->IsGif()) {
		m_diBkImage.SetPlaying(false);
		m_gifWeakFlag.Cancel();
		switch (type)
		{
		case GifStopType::CUR:
			break;
		case GifStopType::FIRST:
			m_diBkImage.SetCurrentFrame(0);
			Invalidate();
			break;
		case GifStopType::END:
			{
				int numFrame = m_diBkImage.imageCache->GetFrameCount();
				numFrame = numFrame>0?numFrame-1:0;
				m_diBkImage.SetCurrentFrame(numFrame);
				Invalidate();
			}
			break;
		}
	}
}
void Control::StartGifPlayForUI(GifStopType type)
{
	m_bGifPlay = true;
	if (!m_diBkImage.IsPlaying() || type == GifStopType::FIRST) {
		if (type != GifStopType::CUR)
		{
			m_diBkImage.SetCurrentFrame(0);
		}
		m_diBkImage.SetPlaying(true);
		m_gifWeakFlag.Cancel();
		auto gifPlayCallback = std::bind(&Control::GifPlay, this);
		TimerManager::GetInstance()->AddCancelableTimer(m_gifWeakFlag.GetWeakFlag(), gifPlayCallback, 
			m_diBkImage.GetCurrentInterval(), TimerManager::REPEAT_FOREVER);
	}
	else {
		int lPause_pre = m_diBkImage.GetCurrentInterval();
		m_diBkImage.IncrementCurrentFrame();
		int lPause = m_diBkImage.GetCurrentInterval();
		if (lPause_pre != lPause) {
			m_gifWeakFlag.Cancel();
			auto gifPlayCallback = std::bind(&Control::GifPlay, this);
			TimerManager::GetInstance()->AddCancelableTimer(m_gifWeakFlag.GetWeakFlag(), gifPlayCallback, 
				lPause, TimerManager::REPEAT_FOREVER);
		}
	}

	Invalidate();
}
void Control::StopGifPlayForUI(GifStopType type)
{
	m_bGifPlay = false;
	StopGifPlay(type);
}

void Control::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
{
	if ( pstrName == _T("class") ) {
		SetClass(pstrValue);
	}
	else if( pstrName == _T("halign") ) {
		if (pstrValue == _T("left")) {
			SetHorAlignType(HorAlignType::LEFT);
		}
		else if (pstrValue == _T("center")) {
			SetHorAlignType(HorAlignType::CENTER);
		}
		else if (pstrValue == _T("right")) {
			SetHorAlignType(HorAlignType::RIGHT);
		}
		else {
			ASSERT(FALSE);
		}
	}
	else if( pstrName == _T("valign") ) {
		if (pstrValue == _T("top")) {
			SetVerAlignType(VerAlignType::TOP);
		}
		else if (pstrValue == _T("center")) {
			SetVerAlignType(VerAlignType::CENTER);
		}
		else if (pstrValue == _T("bottom")) {
			SetVerAlignType(VerAlignType::BOTTOM);
		}
		else {
			ASSERT(FALSE);
		}
	}
	else if( pstrName == _T("margin") ) {
        UiRect rcMargin;
        LPTSTR pstr = NULL;
        rcMargin.left = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
        rcMargin.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);    
        rcMargin.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);    
        rcMargin.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);    
        SetMargin(rcMargin);
    }
    else if( pstrName == _T("bkcolor") || pstrName == _T("bkcolor1") ) {
		LPCTSTR pValue = pstrValue.c_str();
        while( *pValue > _T('\0') && *pValue <= _T(' ') ) pValue = ::CharNext(pValue);
        SetBkColor(pValue);
    }
	else if( pstrName == _T("normalcolor") )	SetStateColor(ControlStateType::NORMAL, pstrValue);
	else if( pstrName == _T("hotcolor") )		SetStateColor(ControlStateType::HOT, pstrValue);
	else if( pstrName == _T("pushedcolor") )	SetStateColor(ControlStateType::PUSHED, pstrValue);
	else if( pstrName == _T("disabledcolor") )	SetStateColor(ControlStateType::DISABLED, pstrValue);
    else if( pstrName == _T("bordercolor") ) {
        SetBorderColor(pstrValue);
    }
	else if( pstrName == _T("bordersize") ) {
		std::wstring nValue = pstrValue;
		if(nValue.find(',') == std::wstring::npos)
		{
			SetBorderSize(_ttoi(pstrValue.c_str()));
			UiRect rcBorder;
			SetBorderSize(rcBorder);
		}
		else
		{
			UiRect rcBorder;
			LPTSTR pstr = NULL;
			rcBorder.left = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);
			rcBorder.top = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);
			rcBorder.right = _tcstol(pstr + 1, &pstr, 10);  ASSERT(pstr);
			rcBorder.bottom = _tcstol(pstr + 1, &pstr, 10); ASSERT(pstr);
			SetBorderSize(rcBorder);
		}
	}
	else if( pstrName == _T("leftbordersize") ) SetLeftBorderSize(_ttoi(pstrValue.c_str()));
	else if( pstrName == _T("topbordersize") ) SetTopBorderSize(_ttoi(pstrValue.c_str()));
	else if( pstrName == _T("rightbordersize") ) SetRightBorderSize(_ttoi(pstrValue.c_str()));
	else if( pstrName == _T("bottombordersize") ) SetBottomBorderSize(_ttoi(pstrValue.c_str()));
    else if( pstrName == _T("borderround") ) {
        CSize cxyRound;
        LPTSTR pstr = NULL;
        cxyRound.cx = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
        cxyRound.cy = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);     
        SetBorderRound(cxyRound);
    }
	else if( pstrName == _T("width") ) {
		if ( pstrValue == _T("stretch") ) {
			SetFixedWidth(DUI_LENGTH_STRETCH);
		}
		else if ( pstrValue == _T("auto") ) {
			SetFixedWidth(DUI_LENGTH_AUTO);
		}
		else {
			ASSERT(_ttoi(pstrValue.c_str()) >= 0);
			SetFixedWidth(_ttoi(pstrValue.c_str()));
		}
	}
	else if( pstrName == _T("height") ) {
		if ( pstrValue == _T("stretch") ) {
			SetFixedHeight(DUI_LENGTH_STRETCH);
		}
		else if ( pstrValue == _T("auto") ) {
			SetFixedHeight(DUI_LENGTH_AUTO);
		}
		else {
			ASSERT(_ttoi(pstrValue.c_str()) >= 0);
			SetFixedHeight(_ttoi(pstrValue.c_str()));
		}
	}
	else if( pstrName == _T("maxwidth") ) {
		if ( pstrValue == _T("stretch") ) {
			SetMaxWidth(DUI_LENGTH_STRETCH);
		}
		else if ( pstrValue == _T("auto") ) {
			SetMaxWidth(DUI_LENGTH_AUTO);
		}
		else {
			ASSERT(_ttoi(pstrValue.c_str()) >= 0);
			SetMaxWidth(_ttoi(pstrValue.c_str()));
		}
	}
	else if( pstrName == _T("maxheight") ) {
		if ( pstrValue == _T("stretch") ) {
			SetMaxHeight(DUI_LENGTH_STRETCH);
		}
		else if ( pstrValue == _T("auto") ) {
			SetMaxHeight(DUI_LENGTH_AUTO);
		}
		else {
			ASSERT(_ttoi(pstrValue.c_str()) >= 0);
			SetMaxHeight(_ttoi(pstrValue.c_str()));
		}
	}
    else if( pstrName == _T("bkimage") ) SetBkImage(pstrValue);
    else if( pstrName == _T("minwidth") ) SetMinWidth(_ttoi(pstrValue.c_str()));
    else if( pstrName == _T("minheight") ) SetMinHeight(_ttoi(pstrValue.c_str()));
    else if( pstrName == _T("name") ) SetName(pstrValue);
    else if( pstrName == _T("tooltip") ) SetToolTip(pstrValue);
    else if( pstrName == _T("dataid") ) SetDataID(pstrValue);
    else if( pstrName == _T("enabled") ) SetEnabled(pstrValue == _T("true"));
    else if( pstrName == _T("mouse") ) SetMouseEnabled(pstrValue == _T("true"));
	else if( pstrName == _T("keyboard") ) SetKeyboardEnabled(pstrValue == _T("true"));
    else if( pstrName == _T("visible") ) SetVisible_(pstrValue == _T("true"));
	else if( pstrName == _T("fadevisible") ) SetVisible(pstrValue == _T("true"));
    else if( pstrName == _T("float") ) SetFloat(pstrValue == _T("true"));
    else if( pstrName == _T("menu") ) SetContextMenuUsed(pstrValue == _T("true"));
	else if( pstrName == _T("nofocus") ) SetNoFocus();
	else if( pstrName == _T("alpha") ) SetAlpha(_ttoi(pstrValue.c_str()));
	else if( pstrName == _T("state") ) {
		if( pstrValue == _T("normal") ) SetState(ControlStateType::NORMAL);
		else if( pstrValue == _T("hot") ) SetState(ControlStateType::HOT);
		else if( pstrValue == _T("pushed") ) SetState(ControlStateType::PUSHED);
		else if( pstrValue == _T("disabled") ) SetState(ControlStateType::DISABLED);
		else ASSERT(FALSE);
	}
	else if( pstrName == _T("cursortype") ) {
		if (pstrValue == _T("arrow")) {
			SetCursorType(CursorType::ARROW);
		}
		else if ( pstrValue == _T("hand") ) {
			SetCursorType(CursorType::HAND);
		}
		else if (pstrValue == _T("ibeam")) {
			SetCursorType(CursorType::IBEAM);
		}
		else {
			ASSERT(FALSE);
		}
	}
	else if( pstrName == _T("normalimage") ) SetStateImage(ControlStateType::NORMAL, pstrValue);
	else if( pstrName == _T("hotimage") ) SetStateImage(ControlStateType::HOT, pstrValue);
	else if( pstrName == _T("pushedimage") ) SetStateImage(ControlStateType::PUSHED, pstrValue);
	else if( pstrName == _T("disabledimage") ) SetStateImage(ControlStateType::DISABLED, pstrValue);
	else if( pstrName == _T("forenormalimage") ) SetForeStateImage(ControlStateType::NORMAL, pstrValue);
	else if( pstrName == _T("forehotimage") ) SetForeStateImage(ControlStateType::HOT, pstrValue);
	else if( pstrName == _T("forepushedimage") ) SetForeStateImage(ControlStateType::PUSHED, pstrValue);
	else if( pstrName == _T("foredisabledimage") ) SetForeStateImage(ControlStateType::DISABLED, pstrValue);
	else if( pstrName == _T("renderoffset") ) {
		CPoint renderOffset;
		LPTSTR pstr = NULL;
		renderOffset.x = _tcstol(pstrValue.c_str(), &pstr, 10);  ASSERT(pstr);    
		renderOffset.y = _tcstol(pstr + 1, &pstr, 10);    ASSERT(pstr);     
		SetRenderOffset(renderOffset);
	}
	else if (pstrName == _T("fadealpha")) m_animationManager.SetFadeAlpha(pstrValue == _T("true"));
	else if (pstrName == _T("fadehot")) m_animationManager.SetFadeHot(pstrValue == _T("true"));
	else if (pstrName == _T("fadewidth")) m_animationManager.SetFadeWidth(pstrValue == _T("true"));
	else if (pstrName == _T("fadeheight")) m_animationManager.SetFadeHeight(pstrValue == _T("true"));
	else if (pstrName == _T("fadeinoutxfromleft")) m_animationManager.SetFadeInOutX(pstrValue == _T("true"), false);
	else if (pstrName == _T("fadeinoutxfromright")) m_animationManager.SetFadeInOutX(pstrValue == _T("true"), true);
	else if (pstrName == _T("fadeinoutyfromtop")) m_animationManager.SetFadeInOutY(pstrValue == _T("true"), false);
	else if (pstrName == _T("fadeinoutyfrombottom")) m_animationManager.SetFadeInOutY(pstrValue == _T("true"), true);
	else	ASSERT(FALSE);
}

void Control::SetClass(const std::wstring& pstrClass)
{
	std::list<std::wstring> splitList = StringHelper::Split(pstrClass, L" ");
	for (auto it = splitList.begin(); it != splitList.end(); it++) {
		std::wstring pDefaultAttributes = GlobalManager::GetClassAttributes((*it));
		if ( pDefaultAttributes.empty() ) {
			pDefaultAttributes = m_pWindow->GetClassAttributes(*it);
		}
		ASSERT(!pDefaultAttributes.empty());
		if( !pDefaultAttributes.empty() ) {
			ApplyAttributeList(pDefaultAttributes);
		}
	}
}

void Control::ApplyAttributeList(const std::wstring& strList)
{
    std::wstring sItem;
    std::wstring sValue;
	LPCTSTR pstrList = strList.c_str();
    while( *pstrList != _T('\0') ) {
        sItem.clear();
        sValue.clear();
        while( *pstrList != _T('\0') && *pstrList != _T('=') ) {
            LPTSTR pstrTemp = ::CharNext(pstrList);
            while( pstrList < pstrTemp) {
                sItem += *pstrList++;
            }
        }
        ASSERT( *pstrList == _T('=') );
        if( *pstrList++ != _T('=') ) return;
        ASSERT( *pstrList == _T('\"') );
        if( *pstrList++ != _T('\"') ) return;
        while( *pstrList != _T('\0') && *pstrList != _T('\"') ) {
            LPTSTR pstrTemp = ::CharNext(pstrList);
            while( pstrList < pstrTemp) {
                sValue += *pstrList++;
            }
        }
        ASSERT( *pstrList == _T('\"') );
        if( *pstrList++ != _T('\"') ) return;
        SetAttribute(sItem, sValue);
        if( *pstrList++ != _T(' ') ) return;
    }
    return;
}

bool Control::OnApplyAttributeList(const std::wstring& receiver, const std::wstring& strList, EventArgs* eventArgs)
{
	Control* receiverControl;
	if (receiver.substr(0, 2) == L".\\" || receiver.substr(0, 2) == L"./") {
		receiverControl = ((Box*)this)->FindSubControl(receiver.substr(2));
	}
	else {
		receiverControl = GetWindow()->FindControl(receiver);
	}

	if (receiverControl) {
		receiverControl->ApplyAttributeList(strList);
	}
	else {
		ASSERT(FALSE);
	}

	return true;
}

CSize Control::EstimateSize(CSize szAvailable)
{
	CSize imageSize = m_cxyFixed;
	if (GetFixedWidth() == DUI_LENGTH_AUTO || GetFixedHeight() == DUI_LENGTH_AUTO) {
		if (!m_bReEstimateSize) {
			return m_szEstimateSize;
		}
		Image* image = GetEstimateImage();
		if (image) {
			auto imageAttribute = image->imageAttribute;
			if (imageAttribute.rcSource.left != DUI_NOSET_VALUE && imageAttribute.rcSource.top != DUI_NOSET_VALUE
				&& imageAttribute.rcSource.right != DUI_NOSET_VALUE && imageAttribute.rcSource.bottom != DUI_NOSET_VALUE) {
				if ((GetFixedWidth() != imageAttribute.rcSource.right - imageAttribute.rcSource.left)) {
					SetFixedWidth(imageAttribute.rcSource.right - imageAttribute.rcSource.left);	
				}
				if ((GetFixedHeight() != imageAttribute.rcSource.bottom - imageAttribute.rcSource.top)) {
					SetFixedHeight(imageAttribute.rcSource.bottom - imageAttribute.rcSource.top);	
				}
				return m_cxyFixed;
			}

			GetImage(*image);
			if (image->imageCache) {
				if (GetFixedWidth() == DUI_LENGTH_AUTO) {
					imageSize.cx = image->imageCache->nX;
				}
				if (GetFixedHeight() == DUI_LENGTH_AUTO) {
					imageSize.cy = image->imageCache->nY;
				}
			}
		}

		m_bReEstimateSize = false;
		CSize textSize = EstimateText(szAvailable, m_bReEstimateSize);
		if (GetFixedWidth() == DUI_LENGTH_AUTO && imageSize.cx < textSize.cx) {
			imageSize.cx = textSize.cx;
		}
		if (GetFixedHeight() == DUI_LENGTH_AUTO && imageSize.cy < textSize.cy) {
			imageSize.cy = textSize.cy;
		}

		m_szEstimateSize = imageSize;
	}

	return imageSize;
}

CSize Control::EstimateText(CSize szAvailable, bool& reEstimateSize)
{
	return CSize();
}

void Control::AlphaPaint(HDC hDC, const UiRect& rcPaint)
{
	if (m_nAlpha == 0) {
		return;
	}

	UiRect unionRect;
	if( !::IntersectRect(&unionRect, &rcPaint, &m_rcItem) ) return;

	RenderClip rectClip;
	rectClip.GenerateClip(hDC, m_rcItem, m_bClip);

	bool clip = false;
	if (m_cxyBorderRound.cx > 0 || m_cxyBorderRound.cy > 0) {
		clip = true;
	}
	RenderClip roundClip;
	roundClip.GenerateRoundClip(hDC, m_rcItem, m_cxyBorderRound.cx, m_cxyBorderRound.cy, clip);

	if (!IsAlpha()) {
		CPoint oldWinOrg;
		GetWindowOrgEx(hDC, &oldWinOrg);
		CPoint newWinOrg = oldWinOrg;
		newWinOrg.Offset(m_renderOffset.x, m_renderOffset.y);
		::SetWindowOrgEx(hDC, newWinOrg.x, newWinOrg.y,NULL);
		Paint(hDC, rcPaint);
		::SetWindowOrgEx(hDC, oldWinOrg.x, oldWinOrg.y, NULL);
	}
	else {
		CSize size;
		size.cx = m_rcItem.right - m_rcItem.left;
		size.cy = m_rcItem.bottom - m_rcItem.top;
		HDC hCloneDC = ::CreateCompatibleDC(hDC);
		BITMAPINFO bmi = { 0 };
		bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
		bmi.bmiHeader.biWidth = size.cx;
		bmi.bmiHeader.biHeight = size.cy;
		bmi.bmiHeader.biPlanes = 1;
		bmi.bmiHeader.biBitCount = 32;
		bmi.bmiHeader.biCompression = BI_RGB;
		bmi.bmiHeader.biSizeImage = size.cx * size.cy * sizeof(DWORD);
		LPDWORD pDest = NULL;
		HBITMAP hBitmap = ::CreateDIBSection(hDC, &bmi, DIB_RGB_COLORS, (LPVOID*) &pDest, NULL, 0);
		HBITMAP hOldBitmap = (HBITMAP) ::SelectObject(hCloneDC, hBitmap);

		bool oldCanvasTransParent = m_pWindow->SelectCanvasTransparent(true);
		CPoint oldWinOrg;
		GetWindowOrgEx(hDC, &oldWinOrg);
		CPoint newWinOrg = oldWinOrg;
		newWinOrg.Offset(m_rcItem.left + m_renderOffset.x, m_rcItem.top + m_renderOffset.y);
		::SetWindowOrgEx(hCloneDC, newWinOrg.x, newWinOrg.y,NULL);
		Paint(hCloneDC, m_rcItem);
		::SetWindowOrgEx(hCloneDC, oldWinOrg.x, oldWinOrg.y, NULL);
		m_pWindow->SelectCanvasTransparent(oldCanvasTransParent);

		BLENDFUNCTION bf = { AC_SRC_OVER, 0, m_nAlpha, AC_SRC_ALPHA };
		::AlphaBlend(hDC, m_rcItem.left, m_rcItem.top, m_rcItem.right - m_rcItem.left, m_rcItem.bottom - m_rcItem.top, hCloneDC,
			0, 0, m_rcItem.right - m_rcItem.left, m_rcItem.bottom - m_rcItem.top, bf);

		::SelectObject(hCloneDC, hOldBitmap);
		::DeleteObject(hBitmap);
		::DeleteDC(hCloneDC);
	}
}

void Control::Paint(HDC hDC, const UiRect& rcPaint)
{
    if( !::IntersectRect(&m_rcPaint, &rcPaint, &m_rcItem) ) return;

	PaintBkColor(hDC);
	PaintBkImage(hDC);
	PaintStatusColor(hDC);
	PaintStatusImage(hDC);
	PaintText(hDC);
	PaintBorder(hDC);
}

void Control::PaintBkColor(HDC hDC)
{
	if (m_dwBkColor.empty()) {
		return;
	}

	DWORD dwBackColor = GlobalManager::ConvertTextColor(m_dwBkColor);
	if( dwBackColor != 0 ) {
		if( dwBackColor >= 0xFF000000 ) RenderEngine::DrawColor(hDC, m_rcPaint, dwBackColor);
		else RenderEngine::DrawColor(hDC, m_rcItem, dwBackColor);
	}
}

void Control::PaintBkImage(HDC hDC)
{
    DrawImage(hDC, m_diBkImage);
}

void Control::PaintStatusColor(HDC hDC)
{
	m_colorMap.PaintStatusColor(hDC, m_rcPaint, m_uButtonState);
}

void Control::PaintStatusImage(HDC hDC)
{
	m_imageMap.PaintStatusImage(hDC, m_uButtonState);
	m_foreImageMap.PaintStatusImage(hDC, m_uButtonState);
}

void Control::PaintText(HDC hDC)
{
    return;
}

void Control::PaintBorder(HDC hDC)
{
	if (m_dwBorderColor.empty()) {
		return;
	}
	DWORD dwBorderColor = 0;
	if (!m_dwBorderColor.empty())
	{
		dwBorderColor = GlobalManager::ConvertTextColor(m_dwBorderColor);
	}

	if(dwBorderColor != 0)
	{
		if(m_rcBorderSize.left > 0 || m_rcBorderSize.top > 0 || m_rcBorderSize.right > 0 || m_rcBorderSize.bottom > 0)
		{
			UiRect rcBorder;

			if(m_rcBorderSize.left > 0){
				rcBorder		= m_rcItem;
				rcBorder.right = rcBorder.left = m_rcItem.left + m_rcBorderSize.left / 2;
				if (m_rcBorderSize.left == 1) {
					rcBorder.bottom -= 1;
				}
				RenderEngine::DrawLine(hDC,rcBorder,m_rcBorderSize.left, dwBorderColor);
			}
			if(m_rcBorderSize.top > 0){
				rcBorder		= m_rcItem;
				rcBorder.bottom = rcBorder.top = m_rcItem.top + m_rcBorderSize.top / 2;
				if (m_rcBorderSize.top == 1) {
					rcBorder.right -= 1;
				}
				RenderEngine::DrawLine(hDC,rcBorder, m_rcBorderSize.top, dwBorderColor);
			}
			if(m_rcBorderSize.right > 0){
				rcBorder		= m_rcItem;
				rcBorder.left = rcBorder.right = m_rcItem.right - (m_rcBorderSize.right + 1) / 2;
				if (m_rcBorderSize.right == 1) {
					rcBorder.bottom -= 1;
				}
				RenderEngine::DrawLine(hDC,rcBorder, m_rcBorderSize.right, dwBorderColor);
			}
			if(m_rcBorderSize.bottom > 0){
				rcBorder = m_rcItem;
				rcBorder.top = rcBorder.bottom = m_rcItem.bottom - (m_rcBorderSize.bottom + 1) / 2;
				if (m_rcBorderSize.bottom == 1) {
					rcBorder.right -= 1;
				}
				RenderEngine::DrawLine(hDC, rcBorder, m_rcBorderSize.bottom, dwBorderColor);
			}
		}
		else if(m_nBorderSize > 0)
		{
			UiRect drawRect = m_rcItem;
			int deltaValue = m_nBorderSize / 2;
			drawRect.top += deltaValue;
			drawRect.bottom -= deltaValue;
			if (m_nBorderSize % 2 != 0) {
				drawRect.bottom -= 1;
			}
			drawRect.left += deltaValue;
			drawRect.right -= deltaValue;
			if (m_nBorderSize % 2 != 0) {
				drawRect.right -= 1;
			}
			RenderEngine::DrawRect(hDC, drawRect, m_nBorderSize, dwBorderColor);
		}
		
	}
}

int Control::GetLeftBorderSize() const
{
	return m_rcBorderSize.left;
}

void Control::SetLeftBorderSize( int nSize )
{
	m_rcBorderSize.left = nSize;
	Invalidate();
}

int Control::GetTopBorderSize() const
{
	return m_rcBorderSize.top;
}

void Control::SetTopBorderSize( int nSize )
{
	m_rcBorderSize.top = nSize;
	Invalidate();
}

int Control::GetRightBorderSize() const
{
	return m_rcBorderSize.right;
}

void Control::SetRightBorderSize( int nSize )
{
	m_rcBorderSize.right = nSize;
	Invalidate();
}

int Control::GetBottomBorderSize() const
{
	return m_rcBorderSize.bottom;
}

void Control::SetBottomBorderSize( int nSize )
{
	m_rcBorderSize.bottom = nSize;
	Invalidate();
}

void Control::SetNoFocus()
{
	m_bNoFocus = true;
}

void Control::SetAlpha(int alpha)
{
	ASSERT(alpha >= 0 && alpha <= 255);
	m_nAlpha = alpha;
	Invalidate();
}

void Control::SetHotAlpha(int nHotAlpha)
{
	ASSERT(nHotAlpha >= 0 && nHotAlpha <= 255);
	m_nHotAlpha = nHotAlpha;
	Invalidate();
}



} // namespace ui
