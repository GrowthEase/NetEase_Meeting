/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"


namespace ui {

RenderClip::~RenderClip()
{
	if (m_bClip) {
		ASSERT(::GetObjectType(m_hDC)==OBJ_DC || ::GetObjectType(m_hDC)==OBJ_MEMDC);
		ASSERT(::GetObjectType(m_hRgn)==OBJ_REGION);

		::SelectClipRgn(m_hDC, m_hOldRgn);
		::DeleteObject(m_hOldRgn);
		::DeleteObject(m_hRgn);
	}
}

void RenderClip::GenerateClip(HDC hDC, UiRect rcItem, bool clip)
{
	m_bClip = clip;
	if (m_bClip) {
		CPoint winOrg;
		GetWindowOrgEx(hDC, &winOrg);
		rcItem.Offset(-winOrg.x, -winOrg.y);
		m_hOldRgn = ::CreateRectRgnIndirect(&rcItem);
		::GetClipRgn(hDC, m_hOldRgn);
		m_hRgn = ::CreateRectRgnIndirect(&rcItem);
		::ExtSelectClipRgn(hDC, m_hRgn, RGN_AND);
		m_hDC = hDC;
	}
}

void RenderClip::GenerateRoundClip(HDC hDC, UiRect rcItem, int width, int height, bool clip)
{
	m_bClip = clip;
	if (m_bClip) {
		CPoint winOrg;
		GetWindowOrgEx(hDC, &winOrg);
		rcItem.Offset(-winOrg.x, -winOrg.y);
		m_hOldRgn = ::CreateRectRgnIndirect(&rcItem);
		::GetClipRgn(hDC, m_hOldRgn);
		m_hRgn = ::CreateRoundRectRgn(rcItem.left, rcItem.top, rcItem.right + 1, rcItem.bottom + 1, width, height);
		::ExtSelectClipRgn(hDC, m_hRgn, RGN_AND);
		m_hDC = hDC;
	}
}


/////////////////////////////////////////////////////////////////////////////////////
//
//

static inline void DrawFunction(HDC hdcDest, bool bCurCanvasTransparent, UiRect rcDest, HDC hdcSrc, UiRect rcSrc, bool alphaChannel, int uFade)
{
	//if (bCurCanvasTransparent || alphaChannel || uFade < 255) {
		BLENDFUNCTION ftn = { AC_SRC_OVER, 0, uFade, AC_SRC_ALPHA };
		::AlphaBlend(hdcDest, rcDest.left, rcDest.top, rcDest.GetWidth(), rcDest.GetHeight(), 
			hdcSrc, rcSrc.left, rcSrc.top, rcSrc.GetWidth(), rcSrc.GetHeight(), ftn);
	//}
	//else {
	//	if (rcSrc.GetWidth() == rcDest.GetWidth() && rcSrc.GetHeight() == rcDest.GetHeight()) {
	//		::BitBlt(hdcDest, rcDest.left, rcDest.top, rcDest.GetWidth(), rcDest.GetHeight(),
	//			hdcSrc, rcSrc.left, rcSrc.top, SRCCOPY);
	//	}
	//	else {
	//		::StretchBlt(hdcDest, rcDest.left, rcDest.top, rcDest.GetWidth(), rcDest.GetHeight(),
	//			hdcSrc, rcSrc.left, rcSrc.top, rcSrc.GetWidth(), rcSrc.GetHeight(), SRCCOPY);
	//	}
	//}
}

void RenderEngine::GdiDrawImage(HDC hDC, bool bCurCanvasTransparent, const UiRect& rcPaint, HBITMAP hBitmap, bool alphaChannel, 
	const UiRect& rcImageDest, const UiRect& rcImageSource, const UiRect& rcCorners, BYTE uFade, bool xtiled, bool ytiled)
{
	UiRect rcTestTemp;
	if( !::IntersectRect(&rcTestTemp, &rcImageDest, &rcPaint) ) return;

    ASSERT(::GetObjectType(hDC)==OBJ_DC || ::GetObjectType(hDC)==OBJ_MEMDC);

    if( hBitmap == NULL ) return;

	HDC hCloneDC = ::CreateCompatibleDC(hDC);
	HBITMAP hOldBitmap = (HBITMAP) ::SelectObject(hCloneDC, hBitmap);
    int stretchBltMode = ::SetStretchBltMode(hDC, HALFTONE);

    UiRect rcTemp;
	UiRect rcSource;
    UiRect rcDest;

    // middle
	rcDest.left = rcImageDest.left + rcCorners.left;
	rcDest.top = rcImageDest.top + rcCorners.top;
	rcDest.right = rcImageDest.right - rcCorners.right;
	rcDest.bottom = rcImageDest.bottom - rcCorners.bottom;
	rcSource.left = rcImageSource.left + rcCorners.left;
	rcSource.top = rcImageSource.top + rcCorners.top;
	rcSource.right = rcImageSource.right - rcCorners.right;
	rcSource.bottom = rcImageSource.bottom - rcCorners.bottom;
    if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
        if( !xtiled && !ytiled ) {
            DrawFunction(hDC, bCurCanvasTransparent, rcDest, hCloneDC, rcSource, alphaChannel, uFade);
        }
        else if( xtiled && ytiled ) {
            LONG lWidth = rcImageSource.right - rcImageSource.left - rcCorners.left - rcCorners.right;
            LONG lHeight = rcImageSource.bottom - rcImageSource.top - rcCorners.top - rcCorners.bottom;
            int iTimesX = (rcDest.right - rcDest.left + lWidth - 1) / lWidth;
            int iTimesY = (rcDest.bottom - rcDest.top + lHeight - 1) / lHeight;
            for( int j = 0; j < iTimesY; ++j ) {
                LONG lDestTop = rcDest.top + lHeight * j;
                LONG lDestBottom = rcDest.top + lHeight * (j + 1);
                LONG lDrawHeight = lHeight;
                if( lDestBottom > rcDest.bottom ) {
                    lDrawHeight -= lDestBottom - rcDest.bottom;
                    lDestBottom = rcDest.bottom;
                }
                for( int i = 0; i < iTimesX; ++i ) {
                    LONG lDestLeft = rcDest.left + lWidth * i;
                    LONG lDestRight = rcDest.left + lWidth * (i + 1);
                    LONG lDrawWidth = lWidth;
                    if( lDestRight > rcDest.right ) {
                        lDrawWidth -= lDestRight - rcDest.right;
                        lDestRight = rcDest.right;
                    }
					rcDest.left = rcDest.left + lWidth * i;
					rcDest.top = rcDest.top + lHeight * j;
					rcDest.right = rcDest.left + lDestRight - lDestLeft;
					rcDest.bottom = rcDest.top + lDestBottom - lDestTop;
					rcSource.left = rcImageSource.left + rcCorners.left;
					rcSource.top = rcImageSource.top + rcCorners.top;
					rcSource.right = rcSource.left + lDrawWidth;
					rcSource.bottom = rcSource.top + lDrawHeight;
                    DrawFunction(hDC, bCurCanvasTransparent, rcDest, hCloneDC, rcSource, alphaChannel, uFade);
                }
            }
        }
        else if( xtiled ) {
            LONG lWidth = rcImageSource.right - rcImageSource.left - rcCorners.left - rcCorners.right;
            int iTimes = (rcDest.right - rcDest.left + lWidth - 1) / lWidth;
            for( int i = 0; i < iTimes; ++i ) {
                LONG lDestLeft = rcDest.left + lWidth * i;
                LONG lDestRight = rcDest.left + lWidth * (i + 1);
                LONG lDrawWidth = lWidth;
                if( lDestRight > rcDest.right ) {
                    lDrawWidth -= lDestRight - rcDest.right;
                    lDestRight = rcDest.right;
                }
				rcDest.left = lDestLeft;
				rcDest.top = rcDest.top;
				rcDest.right = lDestRight;
				rcDest.bottom = rcDest.top + rcDest.bottom;
				rcSource.left = rcImageSource.left + rcCorners.left;
				rcSource.top = rcImageSource.top + rcCorners.top;
				rcSource.right = rcSource.left + lDrawWidth;
				rcSource.bottom = rcImageSource.bottom - rcCorners.bottom;
				DrawFunction(hDC, bCurCanvasTransparent, rcDest, hCloneDC, rcSource, alphaChannel, uFade);
            }
        }
        else { // ytiled
            LONG lHeight = rcImageSource.bottom - rcImageSource.top - rcCorners.top - rcCorners.bottom;
            int iTimes = (rcDest.bottom - rcDest.top + lHeight - 1) / lHeight;
            for( int i = 0; i < iTimes; ++i ) {
                LONG lDestTop = rcDest.top + lHeight * i;
                LONG lDestBottom = rcDest.top + lHeight * (i + 1);
                LONG lDrawHeight = lHeight;
                if( lDestBottom > rcDest.bottom ) {
                    lDrawHeight -= lDestBottom - rcDest.bottom;
                    lDestBottom = rcDest.bottom;
                }
				rcDest.left = rcDest.left;
				rcDest.top = rcDest.top + lHeight * i;
				rcDest.right = rcDest.left + rcDest.right;
				rcDest.bottom = rcDest.top + lDestBottom - lDestTop;
				rcSource.left = rcImageSource.left + rcCorners.left;
				rcSource.top = rcImageSource.top + rcCorners.top;
				rcSource.right = rcImageSource.right - rcCorners.right;
				rcSource.bottom = rcSource.top + lDrawHeight;
				DrawFunction(hDC, bCurCanvasTransparent, rcDest, hCloneDC, rcSource, alphaChannel, uFade);               
            }
        }
    }

    // left-top
    if( rcCorners.left > 0 && rcCorners.top > 0 ) {
        rcDest.left = rcImageDest.left;
        rcDest.top = rcImageDest.top;
        rcDest.right = rcImageDest.left + rcCorners.left;
        rcDest.bottom = rcImageDest.top + rcCorners.top;
		rcSource.left = rcImageSource.left;
		rcSource.top = rcImageSource.top;
		rcSource.right = rcImageSource.left + rcCorners.left;
		rcSource.bottom = rcImageSource.top + rcCorners.top;
        if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
            DrawFunction(hDC, bCurCanvasTransparent, rcDest, hCloneDC, rcSource, alphaChannel, uFade);
        }
    }
    // top
    if( rcCorners.top > 0 ) {
        rcDest.left = rcImageDest.left + rcCorners.left;
        rcDest.top = rcImageDest.top;
        rcDest.right = rcImageDest.right - rcCorners.right;
        rcDest.bottom = rcImageDest.top + rcCorners.top;
		rcSource.left = rcImageSource.left + rcCorners.left;
		rcSource.top = rcImageSource.top;
		rcSource.right = rcImageSource.right - rcCorners.right;
		rcSource.bottom = rcImageSource.top + rcCorners.top;
        if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
           DrawFunction(hDC, bCurCanvasTransparent, rcDest, hCloneDC, rcSource, alphaChannel, uFade);
        }
    }
    // right-top
    if( rcCorners.right > 0 && rcCorners.top > 0 ) {
        rcDest.left = rcImageDest.right - rcCorners.right;
        rcDest.top = rcImageDest.top;
        rcDest.right = rcImageDest.right;
        rcDest.bottom = rcImageDest.top + rcCorners.top;
		rcSource.left = rcImageSource.right - rcCorners.right;
		rcSource.top = rcImageSource.top;
		rcSource.right = rcImageSource.right;
		rcSource.bottom = rcImageSource.top + rcCorners.top;
        if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
            DrawFunction(hDC, bCurCanvasTransparent, rcDest, hCloneDC, rcSource, alphaChannel, uFade);
        }
    }
    // left
    if( rcCorners.left > 0 ) {
        rcDest.left = rcImageDest.left;
        rcDest.top = rcImageDest.top + rcCorners.top;
        rcDest.right = rcImageDest.left + rcCorners.left;
        rcDest.bottom = rcImageDest.bottom - rcCorners.bottom;
		rcSource.left = rcImageSource.left;
		rcSource.top = rcImageSource.top + rcCorners.top;
		rcSource.right = rcImageSource.left + rcCorners.left;
		rcSource.bottom = rcImageSource.bottom - rcCorners.bottom;
        if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
            DrawFunction(hDC, bCurCanvasTransparent, rcDest, hCloneDC, rcSource, alphaChannel, uFade);
        }
    }
    // right
    if( rcCorners.right > 0 ) {
        rcDest.left = rcImageDest.right - rcCorners.right;
        rcDest.top = rcImageDest.top + rcCorners.top;
        rcDest.right = rcImageDest.right;
        rcDest.bottom = rcImageDest.bottom - rcCorners.bottom;
		rcSource.left = rcImageSource.right - rcCorners.right;
		rcSource.top = rcImageSource.top + rcCorners.top;
		rcSource.right = rcImageSource.right;
		rcSource.bottom = rcImageSource.bottom - rcCorners.bottom;
        if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
            DrawFunction(hDC, bCurCanvasTransparent, rcDest, hCloneDC, rcSource, alphaChannel, uFade);
        }
    }
    // left-bottom
    if( rcCorners.left > 0 && rcCorners.bottom > 0 ) {
        rcDest.left = rcImageDest.left;
        rcDest.top = rcImageDest.bottom - rcCorners.bottom;
        rcDest.right = rcImageDest.left + rcCorners.left;
        rcDest.bottom = rcImageDest.bottom;
		rcSource.left = rcImageSource.left;
		rcSource.top = rcImageSource.bottom - rcCorners.bottom;
		rcSource.right = rcImageSource.left + rcCorners.left;
		rcSource.bottom = rcImageSource.bottom;
        if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
            DrawFunction(hDC, bCurCanvasTransparent, rcDest, hCloneDC, rcSource, alphaChannel, uFade);
        }
    }
    // bottom
    if( rcCorners.bottom > 0 ) {
        rcDest.left = rcImageDest.left + rcCorners.left;
        rcDest.top = rcImageDest.bottom - rcCorners.bottom;
        rcDest.right = rcImageDest.right - rcCorners.right;
        rcDest.bottom = rcImageDest.bottom;
		rcSource.left = rcImageSource.left + rcCorners.left;
		rcSource.top = rcImageSource.bottom - rcCorners.bottom;
		rcSource.right = rcImageSource.right - rcCorners.right;
		rcSource.bottom = rcImageSource.bottom;
        if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
            DrawFunction(hDC, bCurCanvasTransparent, rcDest, hCloneDC, rcSource, alphaChannel, uFade);
        }
    }
    // right-bottom
    if( rcCorners.right > 0 && rcCorners.bottom > 0 ) {
        rcDest.left = rcImageDest.right - rcCorners.right;
        rcDest.top = rcImageDest.bottom - rcCorners.bottom;
		rcDest.right = rcImageDest.right;
		rcDest.bottom = rcImageDest.bottom;
		rcSource.left = rcImageSource.right - rcCorners.right;
		rcSource.top = rcImageSource.bottom - rcCorners.bottom;
		rcSource.right = rcImageSource.right;
		rcSource.bottom = rcImageSource.bottom;
        if( ::IntersectRect(&rcTemp, &rcPaint, &rcDest) ) {
			DrawFunction(hDC, bCurCanvasTransparent, rcDest, hCloneDC, rcSource, alphaChannel, uFade);
        }
    }    

	::SetStretchBltMode(hDC, stretchBltMode);
    ::SelectObject(hCloneDC, hOldBitmap);
    ::DeleteDC(hCloneDC);
}

void RenderEngine::DrawColor(HDC hDC, const UiRect& rc, DWORD color, BYTE uFade)
{
	int newColor = color;
	if (uFade < 255) {
		int alpha = color >> 24;
		newColor = color % 0xffffff;
		alpha *= double(uFade) / 255;
		newColor += alpha << 24;
	}
	Gdiplus::Graphics graphics(hDC);
	Gdiplus::Color gdiPlusColor(newColor);
	Gdiplus::SolidBrush brush(gdiPlusColor);
	Gdiplus::RectF fillRect(rc.left, rc.top, rc.GetWidth(), rc.GetHeight());
	graphics.FillRectangle(&brush, fillRect);
}

void RenderEngine::DrawColor(HDC hDC, const UiRect& rc, const std::wstring& colorStr, BYTE uFade)
{
	if (colorStr.empty()) {
		return;
	}

	DWORD dwColor = GlobalManager::ConvertTextColor(colorStr);
	RenderEngine::DrawColor(hDC, rc, dwColor, uFade);
}

void RenderEngine::DrawLine( HDC hDC, const UiRect& rc, int nSize, DWORD dwPenColor)
{
	Gdiplus::Graphics graphics( hDC );
	Gdiplus::Pen pen(Gdiplus::Color(dwPenColor), (Gdiplus::REAL)nSize);
	graphics.DrawLine(&pen, Gdiplus::Point(rc.left, rc.top), Gdiplus::Point(rc.right, rc.bottom));
}

void RenderEngine::DrawRect(HDC hDC, const UiRect& rc, int nSize, DWORD dwPenColor)
{
	Gdiplus::Graphics graphics( hDC );
	Gdiplus::Pen pen(Gdiplus::Color(dwPenColor), (Gdiplus::REAL)nSize);
	graphics.DrawRectangle(&pen, rc.left, rc.top, rc.GetWidth(), rc.GetHeight());
}

void RenderEngine::DrawText(HDC hDC, UiRect& rc, const std::wstring& strText, DWORD dwTextColor, int iFont, UINT uStyle, BYTE uFade, bool bLineLimit)
{
	ASSERT(::GetObjectType(hDC)==OBJ_DC || ::GetObjectType(hDC)==OBJ_MEMDC);
    if( strText.empty() ) return;

	Gdiplus::Graphics graphics( hDC );
	Gdiplus::Font font(hDC, GlobalManager::GetFont(iFont));
	Gdiplus::RectF rectF((Gdiplus::REAL)rc.left, (Gdiplus::REAL)rc.top, (Gdiplus::REAL)(rc.right - rc.left), (Gdiplus::REAL)(rc.bottom - rc.top));
	if (uFade == 255) {
		uFade = 254;
	}
	Gdiplus::SolidBrush tBrush(Gdiplus::Color(uFade, GetBValue(dwTextColor), GetGValue(dwTextColor), GetRValue(dwTextColor)));

	Gdiplus::StringFormat stringFormat = Gdiplus::StringFormat::GenericTypographic();
	if ((uStyle & DT_END_ELLIPSIS) != 0) {
		stringFormat.SetTrimming(Gdiplus::StringTrimmingEllipsisCharacter);
	}

	int formatFlags = 0;
	if ((uStyle & DT_NOCLIP) != 0) {
		formatFlags |= Gdiplus::StringFormatFlagsNoClip;
	}
	if ((uStyle & DT_SINGLELINE) != 0) {
		formatFlags |= Gdiplus::StringFormatFlagsNoWrap;
	}
	if (bLineLimit) {
		formatFlags |= Gdiplus::StringFormatFlagsLineLimit;
	}
	stringFormat.SetFormatFlags(formatFlags);

	if ((uStyle & DT_LEFT) != 0) {
		stringFormat.SetAlignment(Gdiplus::StringAlignmentNear);
	}
	else if ((uStyle & DT_CENTER) != 0) {
		stringFormat.SetAlignment(Gdiplus::StringAlignmentCenter);
	}
	else if ((uStyle & DT_RIGHT) != 0) {
		stringFormat.SetAlignment(Gdiplus::StringAlignmentFar);
	}
	else {
		stringFormat.SetAlignment(Gdiplus::StringAlignmentNear);
	}

	if ((uStyle & DT_TOP) != 0) {
		stringFormat.SetLineAlignment(Gdiplus::StringAlignmentNear);
	}
	else if ((uStyle & DT_VCENTER) != 0) {
		TFontInfo* fontInfo = GlobalManager::GetTFontInfo(iFont);
		if (fontInfo->sFontName == L"新宋体") {
			if (rectF.Height >= fontInfo->iSize + 2) {
				rectF.Offset(0, 1);
			}
		}
		stringFormat.SetLineAlignment(Gdiplus::StringAlignmentCenter);
	}
	else if ((uStyle & DT_BOTTOM) != 0) {
		stringFormat.SetLineAlignment(Gdiplus::StringAlignmentFar);
	}
	else {
		stringFormat.SetLineAlignment(Gdiplus::StringAlignmentNear);
	}

	graphics.DrawString(strText.c_str(), strText.length(), &font, rectF, &stringFormat, &tBrush);
}

UiRect RenderEngine::MeasureText(HDC hDC, const std::wstring& strText, int iFont, UINT uStyle, int width)
{
	Gdiplus::Graphics graphics( hDC );
	Gdiplus::Font font(hDC, GlobalManager::GetFont(iFont));
	Gdiplus::RectF bounds;

	Gdiplus::StringFormat stringFormat = Gdiplus::StringFormat::GenericTypographic();
	int formatFlags = 0;
	if ((uStyle & DT_SINGLELINE) != 0) {
		formatFlags |= Gdiplus::StringFormatFlagsNoWrap;
	}
	stringFormat.SetFormatFlags(formatFlags);

	if (width == DUI_NOSET_VALUE) {
		graphics.MeasureString(strText.c_str(), strText.length(), &font, Gdiplus::PointF(), &stringFormat, &bounds);
	}
	else {
		Gdiplus::REAL height = 0;
		if ((uStyle & DT_SINGLELINE) != 0) {
			Gdiplus::RectF rectF((Gdiplus::REAL)0, (Gdiplus::REAL)0, (Gdiplus::REAL)0, (Gdiplus::REAL)0);
			graphics.MeasureString(L"测试", 2, &font, rectF, &stringFormat, &bounds);
			height = bounds.Height;
		}
		Gdiplus::RectF rectF((Gdiplus::REAL)0, (Gdiplus::REAL)0, (Gdiplus::REAL)width, height);
		graphics.MeasureString(strText.c_str(), strText.length(), &font, rectF, &stringFormat, &bounds);
	}
	
	UiRect rc(int(bounds.GetLeft()), int(bounds.GetTop()), int(bounds.GetRight() + 1), int(bounds.GetBottom() + 1));

	return rc;
}


} // namespace ui
