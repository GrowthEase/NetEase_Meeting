/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"
#include <zmouse.h>
#include "shlwapi.h"
#include "dui/Utils/unzip.h"




namespace ui {

/////////////////////////////////////////////////////////////////////////////////////
GlobalManager::MapStringToImagePtr GlobalManager::m_mImageHash;
std::vector<TFontInfo*> GlobalManager::m_aCustomFonts;
std::map<std::wstring, std::wstring> GlobalManager::m_mapTextColor;
std::map<std::wstring, std::wstring> GlobalManager::m_GlobalClass;
std::wstring GlobalManager::m_pStrDefaultFontName;
std::wstring GlobalManager::m_pStrResourcePath;
short GlobalManager::m_H = 180;
short GlobalManager::m_S = 100;
short GlobalManager::m_L = 100;
std::vector<Window*> GlobalManager::m_aPreMessages;
std::wstring GlobalManager::m_dwDefaultDisabledColor = L"textdefaultdisablecolor";
std::wstring GlobalManager::m_dwDefaultFontColor = L"textdefaultcolor";
DWORD GlobalManager::m_dwDefaultLinkFontColor = 0xFF0000FF;
DWORD GlobalManager::m_dwDefaultLinkHoverFontColor = 0xFFD3215F;
DWORD GlobalManager::m_dwDefaultSelectedBkColor = 0xFFBAE4FF;
std::map<std::wstring, std::unique_ptr<WindowBuilder>> GlobalManager::m_winowBuilderMap;
CreateControlCallback GlobalManager::m_createControlCallback;

static ULONG_PTR g_gdiplusToken;
static Gdiplus::GdiplusStartupInput g_gdiplusStartupInput;
static HZIP g_hzip = NULL;

void GlobalManager::Startup(const std::wstring& resourcePath, const CreateControlCallback& callback)
{
	ui::GlobalManager::SetResourcePath(resourcePath);
	m_createControlCallback = callback;
	ui::WindowBuilder dialog_builder;
	ui::Window paint_manager;
	dialog_builder.Create(L"global.xml", CreateControlCallback(), &paint_manager);

	if (g_hzip)
	{
		HGLOBAL hGlobal = GetData(m_pStrResourcePath + L"gdstrings.ini");
		if (hGlobal)
		{
			ui::MutiLanSupport::GetInstance()->LoadStringTable(hGlobal);
			GlobalFree(hGlobal);
		}
	} 
	else
	{
		ui::MutiLanSupport::GetInstance()->LoadStringTable(resourcePath + L"\\gdstrings.ini");
	}

	GdiplusStartup(&g_gdiplusToken, &g_gdiplusStartupInput, NULL);	// 初始化GDI+
	// Boot Windows Common Controls (for the ToolTip control)
	::InitCommonControls();
}

void GlobalManager::Shutdown()
{
	if (g_hzip)
	{
		CloseZip(g_hzip);
		g_hzip = NULL;
	}
	Gdiplus::GdiplusShutdown(g_gdiplusToken);	// 反初始化GDI+
}

std::wstring GlobalManager::GetCurrentPath()
{
    TCHAR tszModule[MAX_PATH + 1] = { 0 };
    ::GetCurrentDirectory(MAX_PATH, tszModule);
    return tszModule;
}

std::wstring GlobalManager::GetResourcePath()
{
    return m_pStrResourcePath;
}

void GlobalManager::SetCurrentPath(const std::wstring& strPath)
{
    ::SetCurrentDirectory(strPath.c_str());
}

void GlobalManager::SetResourcePath(const std::wstring& strPath)
{
    m_pStrResourcePath = strPath;
    if( m_pStrResourcePath.empty() ) return;
    TCHAR cEnd = m_pStrResourcePath.at(m_pStrResourcePath.length() - 1);
    if( cEnd != _T('\\') && cEnd != _T('/') ) m_pStrResourcePath += _T('\\');
}

void GlobalManager::MessageLoop()
{
	MSG msg = { 0 };
	while( ::GetMessage(&msg, NULL, 0, 0) ) {
		if( !GlobalManager::TranslateMessage(&msg) ) {
			::TranslateMessage(&msg);
			try{
				::DispatchMessage(&msg);
			} catch(...) {
				//DUITRACE(_T("EXCEPTION: %s(%d)\n"), __FILET__, __LINE__);
				throw "GlobalManager::MessageLoop";
			}
		}
	}
}


bool GlobalManager::TranslateMessage(const LPMSG pMsg)
{
	// Pretranslate Message takes care of system-wide messages, such as
	// tabbing and shortcut key-combos. We'll look for all messages for
	// each window and any child control attached.
	UINT uStyle = GetWindowStyle(pMsg->hwnd);
	UINT uChildRes = uStyle & WS_CHILD;	
	LRESULT lRes = 0;
	if (uChildRes != 0)
	{
		HWND hWndParent = ::GetParent(pMsg->hwnd);

		for( auto it = m_aPreMessages.begin(); it != m_aPreMessages.end(); it++ ) {
			auto pT = *it;    
			HWND hTempParent = hWndParent;
			while(hTempParent)
			{
				if(pMsg->hwnd == pT->GetHWND() || hTempParent == pT->GetHWND())
				{
					if (pT->TranslateAccelerator(pMsg))
						return true;

					if( pT->PreMessageHandler(pMsg->message, pMsg->wParam, pMsg->lParam, lRes) ) 
						return true;

					return false;
				}
				hTempParent = GetParent(hTempParent);
			}
		}
	}
	else
	{
		for( auto it = m_aPreMessages.begin(); it != m_aPreMessages.end(); it++ ) {
			auto pT = *it;
			if(pMsg->hwnd == pT->GetHWND())
			{
				if (pT->TranslateAccelerator(pMsg))
					return true;

				if( pT->PreMessageHandler(pMsg->message, pMsg->wParam, pMsg->lParam, lRes) ) 
					return true;

				return false;
			}
		}
	}
	return false;
}

void GlobalManager::AddTextColor(const std::wstring& strName, const std::wstring& strValue)
{
	m_mapTextColor[strName] = strValue;
}

std::wstring GlobalManager::GetTextColor(const std::wstring& strName)
{
	ASSERT(!m_mapTextColor[strName].empty());
	return m_mapTextColor[strName];
}

DWORD GlobalManager::ConvertTextColor(const std::wstring& strName)
{
	if (strName.empty()) {
		return 0;
	}
	std::wstring strValue = GlobalManager::GetTextColor(strName);
	strValue = strValue.substr(1);
	LPTSTR pstr = NULL;
	DWORD dwBackColor = _tcstoul(strValue.c_str(), &pstr, 16);

	return dwBackColor;
}

void GlobalManager::AddClass(const std::wstring& strClassName, const std::wstring& strControlAttrList)
{
	ASSERT(!strClassName.empty());
	ASSERT(!strControlAttrList.empty());
	m_GlobalClass[strClassName] = strControlAttrList;
}

std::wstring GlobalManager::GetClassAttributes(const std::wstring& strClassName)
{
	auto it = m_GlobalClass.find(strClassName);
	if (it != m_GlobalClass.end())
	{
		return it->second;
	}

	return L"";
}

std::shared_ptr<ImageInfo> GlobalManager::GetImage(const std::wstring& bitmap)
{
	std::wstring imageFullPath = StringHelper::ReparsePath(bitmap);
	if (IsUseZip())
	{
		imageFullPath = GetZipFilePath(imageFullPath);
	}
	std::shared_ptr<ImageInfo> sharedImage;
	auto it = m_mImageHash.find(imageFullPath);
	if (it == m_mImageHash.end()) {
		std::unique_ptr<ImageInfo> data;
		if (IsUseZip())
		{
			HGLOBAL hGlobal = GetData(imageFullPath);
			if (hGlobal)
			{
				data = ImageInfo::LoadImage(hGlobal, imageFullPath);
				GlobalFree(hGlobal);
			}
		}
		if (!data)
		{
			data = ImageInfo::LoadImage(imageFullPath);
		}
		if( !data ) return sharedImage;
		sharedImage.reset(data.release());
		m_mImageHash[imageFullPath] = sharedImage;
	}
	else {
		sharedImage = it->second.lock();
	}

	return sharedImage;
}

HFONT GlobalManager::AddFont(const std::wstring& strFontName, int nSize, bool bBold, bool bUnderline, bool bItalic)
{
	static bool bOsOverXp = IsOsOverXp();
	std::wstring fontName = strFontName;
	if ( fontName == L"system" )
	{
		fontName = bOsOverXp ? L"微软雅黑" : L"新宋体";
	}

	LOGFONT lf = { 0 };
	::GetObject(::GetStockObject(DEFAULT_GUI_FONT), sizeof(LOGFONT), &lf);
	_tcscpy(lf.lfFaceName, fontName.c_str());
	lf.lfCharSet = DEFAULT_CHARSET;
	lf.lfHeight = -nSize;
	if( bBold ) lf.lfWeight += FW_BOLD;
	if( bUnderline ) lf.lfUnderline = TRUE;
	if( bItalic ) lf.lfItalic = TRUE;
	HFONT hFont = ::CreateFontIndirect(&lf);
	if( hFont == NULL ) return NULL;

	TFontInfo* pFontInfo = new TFontInfo;
	if( !pFontInfo ) return false;
	pFontInfo->hFont = hFont;
	pFontInfo->sFontName = fontName;
	pFontInfo->iSize = nSize;
	pFontInfo->bBold = bBold;
	pFontInfo->bUnderline = bUnderline;
	pFontInfo->bItalic = bItalic;
	::ZeroMemory(&pFontInfo->tm, sizeof(pFontInfo->tm));

	m_aCustomFonts.push_back(pFontInfo);

	return hFont;
}

bool GlobalManager::IsOsOverXp()
{
	OSVERSIONINFO os = { sizeof(OSVERSIONINFO) };
	::GetVersionEx(&os);
	return (os.dwMajorVersion >= 6);
}

Box* GlobalManager::CreateBox(const std::wstring& xmlPath, CreateControlCallback callback)
{
	WindowBuilder winBuilder;
	Box* box = winBuilder.Create(xmlPath.c_str(), callback);
	ASSERT(box);

	return box;
}

Box* GlobalManager::CreateBoxWithCache(const std::wstring& xmlPath, CreateControlCallback callback)
{
	Box* box = nullptr;
	auto it = m_winowBuilderMap.find(xmlPath);
	if (it == m_winowBuilderMap.end()) {
		WindowBuilder* winBuilder = new WindowBuilder();
		box = winBuilder->Create(xmlPath.c_str(), callback);
		if (box) {
			m_winowBuilderMap[xmlPath].reset(winBuilder);
		}
		else {
			ASSERT(FALSE);
		}
	}
	else {
		box = it->second->Create(callback);
	}

	return box;
}

void GlobalManager::FillBox(Box* userDefinedBox, const std::wstring& xmlPath, CreateControlCallback callback)
{
	WindowBuilder winBuilder;
	Box* box = winBuilder.Create(xmlPath.c_str(), callback, userDefinedBox->GetWindow(), nullptr, userDefinedBox);
	ASSERT(box);

	return;
}

void GlobalManager::FillBoxWithCache(Box* userDefinedBox, const std::wstring& xmlPath, CreateControlCallback callback)
{
	Box* box = nullptr;
	auto it = m_winowBuilderMap.find(xmlPath);
	if (it == m_winowBuilderMap.end()) {
		WindowBuilder* winBuilder = new WindowBuilder();
		box = winBuilder->Create(xmlPath.c_str(), callback, userDefinedBox->GetWindow(), nullptr, userDefinedBox);
		if (box) {
			m_winowBuilderMap[xmlPath].reset(winBuilder);
		}
		else {
			ASSERT(FALSE);
		}
	}
	else {
		box = it->second->Create(callback, userDefinedBox->GetWindow(), nullptr, userDefinedBox);
	}

	return;
}

 Control* GlobalManager::CreateControl(const std::wstring& controlStr)
{
	if (m_createControlCallback) {
		return m_createControlCallback(controlStr);
	}

	return nullptr;
}

TFontInfo* GlobalManager::GetTFontInfo(std::size_t index)
{
	ASSERT(index >= 0 || index < m_aCustomFonts.size());
	TFontInfo* pFontInfo = static_cast<TFontInfo*>(m_aCustomFonts[index]);
	return pFontInfo;
}

HFONT GlobalManager::GetFont(std::size_t index)
{
	return GetTFontInfo(index)->hFont;
}

HFONT GlobalManager::GetFont(const std::wstring& strFontName, int nSize, bool bBold, bool bUnderline, bool bItalic)
{
	for( auto it = m_aCustomFonts.begin(); it != m_aCustomFonts.end(); it++ ) {
		auto pFontInfo = *it;
		if( pFontInfo->sFontName == strFontName && pFontInfo->iSize == nSize && 
			pFontInfo->bBold == bBold && pFontInfo->bUnderline == bUnderline && pFontInfo->bItalic == bItalic) 
			return pFontInfo->hFont;
	}
	return NULL;
}

TFontInfo* GlobalManager::GetFontInfo(std::size_t index, HDC hDcPaint)
{
	ASSERT(index >= 0 || index < m_aCustomFonts.size());
	TFontInfo* pFontInfo = static_cast<TFontInfo*>(m_aCustomFonts[index]);
	if( pFontInfo->tm.tmHeight == 0 ) {
		HFONT hOldFont = (HFONT) ::SelectObject(hDcPaint, pFontInfo->hFont);
		::GetTextMetrics(hDcPaint, &pFontInfo->tm);
		::SelectObject(hDcPaint, hOldFont);
	}
	return pFontInfo;
}

TFontInfo* GlobalManager::GetFontInfo(HFONT hFont, HDC hDcPaint)
{
	for( auto it = m_aCustomFonts.begin(); it != m_aCustomFonts.end(); it++ ) {
		auto pFontInfo = *it;
		if( pFontInfo->hFont == hFont ) {
			if( pFontInfo->tm.tmHeight == 0 ) {
				HFONT hOldFont = (HFONT) ::SelectObject(hDcPaint, pFontInfo->hFont);
				::GetTextMetrics(hDcPaint, &pFontInfo->tm);
				::SelectObject(hDcPaint, hOldFont);
			}
			return pFontInfo;
		}
	}

	ASSERT(FALSE);
	return NULL;
}

bool GlobalManager::FindFont(HFONT hFont)
{
	for( auto it = m_aCustomFonts.begin(); it != m_aCustomFonts.end(); it++ ) {
		auto pFontInfo = *it;
		if( pFontInfo->hFont == hFont ) return true;
	}
	return false;
}

bool GlobalManager::FindFont(const std::wstring& strFontName, int nSize, bool bBold, bool bUnderline, bool bItalic)
{
	for( auto it = m_aCustomFonts.begin(); it != m_aCustomFonts.end(); it++ ) {
		auto pFontInfo = *it;
		if( pFontInfo->sFontName == strFontName && pFontInfo->iSize == nSize && 
			pFontInfo->bBold == bBold && pFontInfo->bUnderline == bUnderline && pFontInfo->bItalic == bItalic) 
			return true;
	}
	return false;
}

bool GlobalManager::RemoveFontAt(std::size_t index)
{
	if( index < 0 || index >= m_aCustomFonts.size() ) return false;
	TFontInfo* pFontInfo = static_cast<TFontInfo*>(m_aCustomFonts[index]);
	::DeleteObject(pFontInfo->hFont);
	delete pFontInfo;
	m_aCustomFonts.erase(m_aCustomFonts.begin() + index);
	return true;
}

void GlobalManager::RemoveAllFonts()
{
	for( auto it = m_aCustomFonts.begin(); it != m_aCustomFonts.end(); it++ ) {
		auto pFontInfo = *it;
		::DeleteObject(pFontInfo->hFont);
		delete pFontInfo;
	}
	m_aCustomFonts.clear();
}

std::wstring GlobalManager::GetDefaultDisabledTextColor()
{
	return m_dwDefaultDisabledColor;
}

void GlobalManager::SetDefaultDisabledTextColor(const std::wstring& dwColor)
{
	m_dwDefaultDisabledColor = dwColor;
}

std::wstring GlobalManager::GetDefaultTextColor()
{
	return m_dwDefaultFontColor;
}

void GlobalManager::SetDefaultTextColor(const std::wstring& dwColor)
{
	m_dwDefaultFontColor = dwColor;
}

DWORD GlobalManager::GetDefaultLinkFontColor()
{
	return m_dwDefaultLinkFontColor;
}

void GlobalManager::SetDefaultLinkFontColor(DWORD dwColor)
{
	m_dwDefaultLinkFontColor = dwColor;
}

DWORD GlobalManager::GetDefaultLinkHoverFontColor()
{
	return m_dwDefaultLinkHoverFontColor;
}

void GlobalManager::SetDefaultLinkHoverFontColor(DWORD dwColor)
{
	m_dwDefaultLinkHoverFontColor = dwColor;
}

DWORD GlobalManager::GetDefaultSelectedBkColor()
{
	return m_dwDefaultSelectedBkColor;
}

void GlobalManager::SetDefaultSelectedBkColor(DWORD dwColor)
{
	m_dwDefaultSelectedBkColor = dwColor;
}





bool GlobalManager::ImageCacheKeyCompare::operator()(const std::wstring& key1, const std::wstring& key2) const
{
	int l1 = key1.length();
	int l2 = key2.length();
	if (l1 != l2)
		return l1 < l2;

	LPCWSTR s1b = key1.c_str();
	LPCWSTR s2b = key2.c_str();
	LPCWSTR s1c = s1b + l1;
	LPCWSTR s2c = s2b + l2;

	// 逆向比较
	while (--s1c >= s1b && --s2c >= s2b && *s1c == *s2c);
	// 两个串都已经比光了，那么肯定相等，返回false
	if (s1c < s1b) {
		return false;
	}
	return *s1c < *s2c;
}
bool GlobalManager::IsUseZip()
{
	return g_hzip != NULL;
}
bool GlobalManager::OpenResZip(void *z, unsigned int len, const std::string& password)
{
	if (g_hzip)
	{
		CloseZip(g_hzip);
		g_hzip = NULL;
	}
	g_hzip = OpenZip(z, len, password.c_str());
	return g_hzip != NULL;
}
bool GlobalManager::OpenResZip(const std::wstring& path, const std::string& password)
{
	if (g_hzip)
	{
		CloseZip(g_hzip);
		g_hzip = NULL;
	}
	g_hzip = OpenZip(path.c_str(), password.c_str());
	return g_hzip != NULL;
}
HGLOBAL GlobalManager::GetData(const std::wstring& path)
{
	HGLOBAL hGlobal = NULL;
	std::wstring file_path = GetZipFilePath(path);
	if (g_hzip && !file_path.empty())
	{
		ZIPENTRY ze;
		int i = 0;
		if (FindZipItem(g_hzip, file_path.c_str(), true, &i, &ze) == ZR_OK)
		{
			if (ze.index >= 0)
			{
				hGlobal = GlobalAlloc(GMEM_MOVEABLE | GMEM_NODISCARD, ze.unc_size);
				if (hGlobal)
				{
					TCHAR *pData = (TCHAR*)GlobalLock(hGlobal);
					if (pData)
					{
						ZRESULT res = UnzipItem(g_hzip, ze.index, pData, ze.unc_size);
						GlobalUnlock(hGlobal);
						if (res != ZR_OK)
						{
							GlobalFree(hGlobal);
							hGlobal = NULL;
						}
					}
					else
					{
						GlobalFree(hGlobal);
						hGlobal = NULL;
					}
				}
			}
		}
	}
	return hGlobal;
}
std::wstring GlobalManager::GetZipFilePath(const std::wstring& path)
{
	std::wstring file_path = path;
	StringHelper::ReplaceAll(L"\\", L"/", file_path);
	StringHelper::ReplaceAll(L"//", L"/", file_path);
	for (unsigned int i = 0; i < file_path.size();)
	{
		bool start_node = false;
		if (i==0 || file_path.at(i-1)==L'/')
		{
			start_node = true;
		}
		WCHAR wch = file_path.at(i);
		if (start_node && wch == L'/')//"//"
		{
			file_path.erase(i, 1);
			continue;
		}
		if (start_node && wch == L'.')
		{
			if (i + 1 < file_path.size() && file_path.at(i+1)==L'/')// "./"
			{
				file_path.erase(i, 2);
				continue;
			}
			else if (i + 2 < file_path.size() && file_path.at(i + 1) == L'.' && file_path.at(i + 2) == L'/')// "../"
			{
				file_path.erase(i, 2);
				int i_erase = i - 2;
				if (i_erase < 0)
				{
					ASSERT(0);
				}
				while (i_erase > 0 && file_path.at(i_erase) != L'/')
					i_erase--;
				file_path.erase(i_erase, i-i_erase);
				i = i_erase;
				continue;
			}
		}
		i++;
	}
	return file_path;
}


} // namespace ui
