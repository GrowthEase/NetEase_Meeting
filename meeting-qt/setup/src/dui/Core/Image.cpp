/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"
#include "Image.h"

namespace ui {

int ImageInfo::GetInterval(int index)
{
	int interval = ((long*) (m_propertyItem->value))[index] * 10;
	if (interval == 0) {
		interval = 100;
	}
	return interval;
}

ImageInfo::~ ImageInfo()
{
	for (auto it = m_vecBitmap.begin(); it != m_vecBitmap.end(); it++) {
		::DeleteObject(*it) ; 
	}

	GlobalManager::RemoveFromImageCache(sImageFullPath);
}

std::unique_ptr<ImageInfo> ImageInfo::LoadImage(const std::wstring& imageFullPath)
{
	std::unique_ptr<Gdiplus::Bitmap> gdiplusBitmap(Gdiplus::Bitmap::FromFile(imageFullPath.c_str()));
	return LoadImageByBitmap(gdiplusBitmap, imageFullPath);
}
std::unique_ptr<ImageInfo> ImageInfo::LoadImage(HGLOBAL hGlobal, const std::wstring& imageFullPath)
{
	if (hGlobal == NULL)
	{
		return nullptr;
	}
	IStream* stream = NULL;
	GlobalLock(hGlobal);
	CreateStreamOnHGlobal(hGlobal, true, &stream);
	if (stream == NULL)
	{
		GlobalUnlock(hGlobal);
		return nullptr;
	}
	std::unique_ptr<Gdiplus::Bitmap> gdiplusBitmap(Gdiplus::Bitmap::FromStream(stream));
	stream->Release();
	GlobalUnlock(hGlobal);
	return LoadImageByBitmap(gdiplusBitmap, imageFullPath);
}
std::unique_ptr<ImageInfo> ImageInfo::LoadImageByBitmap(std::unique_ptr<Gdiplus::Bitmap>& gdiplusBitmap, const std::wstring& imageFullPath)
{
	Gdiplus::Status status;
	status = gdiplusBitmap->GetLastStatus();
	ASSERT(status == Gdiplus::Ok);
	if (status != Gdiplus::Ok) {
		return nullptr;
	}

	UINT nCount	= gdiplusBitmap->GetFrameDimensionsCount();
	std::unique_ptr<GUID[]> pDimensionIDs(new GUID[ nCount ]);
	gdiplusBitmap->GetFrameDimensionsList( pDimensionIDs.get(), nCount );
	int iFrameCount = gdiplusBitmap->GetFrameCount( &pDimensionIDs.get()[0] );
	std::unique_ptr<ImageInfo>data(new ImageInfo);
	
	if (iFrameCount > 1) {
		int iSize = gdiplusBitmap->GetPropertyItemSize(PropertyTagFrameDelay);
		Gdiplus::PropertyItem* propertyItem = (Gdiplus::PropertyItem*) malloc(iSize);
		status = gdiplusBitmap->GetPropertyItem(PropertyTagFrameDelay, iSize, propertyItem);
		ASSERT(status == Gdiplus::Ok);
		if (status != Gdiplus::Ok) {
			return nullptr;
		}
		data->SetPropertyItem(propertyItem);
	}

	for (int i = 0; i < iFrameCount; i++) {
		status = gdiplusBitmap->SelectActiveFrame(&Gdiplus::FrameDimensionTime, i);
		ASSERT(status == Gdiplus::Ok);
		if (status != Gdiplus::Ok) {
			return nullptr;
		}
		
		HBITMAP hBitmap;
		status = gdiplusBitmap->GetHBITMAP(Gdiplus::Color(), &hBitmap);
		ASSERT(status == Gdiplus::Ok);
		if (status != Gdiplus::Ok) {
			return nullptr;
		}
		data->PushBackHBitmap(hBitmap);
	}

	data->nX = gdiplusBitmap->GetWidth();
	data->nY = gdiplusBitmap->GetHeight();
	data->sImageFullPath = imageFullPath;
	Gdiplus::PixelFormat format = gdiplusBitmap->GetPixelFormat();
	data->SetAlpha((format & PixelFormatAlpha) != 0);
	if ((format & PixelFormatIndexed) != 0) {
		int  palSize = gdiplusBitmap->GetPaletteSize();
		if( palSize > 0 )
		{
			Gdiplus::ColorPalette *palette = (Gdiplus::ColorPalette*)malloc(palSize );;
			status = gdiplusBitmap->GetPalette( palette , palSize );
			if (status == Gdiplus::Ok)
			{
				data->SetAlpha((palette->Flags & Gdiplus::PaletteFlagsHasAlpha) != 0);
			}
			free(palette);
		}
	}
	
	if (format == PixelFormat32bppARGB) {
		for (int frameIndex = 0; frameIndex < iFrameCount; frameIndex++) {
			HBITMAP bitmap = data->GetHBitmap(frameIndex);
			BITMAP bm;
			::GetObject( bitmap, sizeof( bm ), &bm );
			LPBYTE imageBits = (LPBYTE)bm.bmBits;
			for(int i = 0; i < bm.bmHeight; ++i) {
				for(int j = 0; j < bm.bmWidthBytes; j+=4) {
					int x = i * bm.bmWidthBytes + j;
					if (imageBits[x + 3] != 255) {
						data->SetAlpha(true);
						return data;
					}
				}
			}
		}

		data->SetAlpha(false);
		return data;
	}

	return data;
}

bool StateImageMap::PaintStatusImage(HDC hDC, ControlStateType stateType, const std::wstring& m_sImageModify)
{
	if (m_pControl) {
		int bFadeHot = m_pControl->GetAnimationManager().IsAnimated(AnimationType::FADE_HOT);
		int hotAlpha = m_pControl->GetHotAlpha();
		if (bFadeHot) {
			if (stateType == ControlStateType::NORMAL || stateType == ControlStateType::HOT) {
				std::wstring normalImagePath = m_stateImageMap[ControlStateType::NORMAL].imageAttribute.sImageName;
				std::wstring hotImagePath = m_stateImageMap[ControlStateType::HOT].imageAttribute.sImageName;
				if (normalImagePath.empty() || hotImagePath.empty()
					|| normalImagePath != hotImagePath
					|| !m_stateImageMap[ControlStateType::NORMAL].imageAttribute.rcSource.Equal(m_stateImageMap[ControlStateType::HOT].imageAttribute.rcSource)) {
					m_pControl->DrawImage(hDC, m_stateImageMap[ControlStateType::NORMAL], m_sImageModify);
					int hotFade = m_stateImageMap[ControlStateType::HOT].imageAttribute.bFade;
					hotFade = int(hotFade * (double)hotAlpha / 255);
					return m_pControl->DrawImage(hDC, m_stateImageMap[ControlStateType::HOT], m_sImageModify, hotFade);
				}
				else {
					int normalFade = m_stateImageMap[ControlStateType::NORMAL].imageAttribute.bFade;
					int hotFade = m_stateImageMap[ControlStateType::HOT].imageAttribute.bFade;
					int blendFade = int((1 - (double)hotAlpha / 255) * normalFade + (double)hotAlpha / 255 * hotFade);
					return m_pControl->DrawImage(hDC, m_stateImageMap[ControlStateType::HOT], m_sImageModify, blendFade);
				}
			}
		}
	}

	if (stateType == ControlStateType::PUSHED && m_stateImageMap[ControlStateType::PUSHED].imageAttribute.imageString.empty()) {
		stateType = ControlStateType::HOT;
		m_stateImageMap[ControlStateType::HOT].imageAttribute.bFade = 255;
	}
	if (stateType == ControlStateType::HOT && m_stateImageMap[ControlStateType::HOT].imageAttribute.imageString.empty()) {
		stateType = ControlStateType::NORMAL;
	}
	if (stateType == ControlStateType::DISABLED && m_stateImageMap[ControlStateType::DISABLED].imageAttribute.imageString.empty()) {
		stateType = ControlStateType::NORMAL;
	}

	return m_pControl->DrawImage(hDC, m_stateImageMap[stateType], m_sImageModify);
}

Image* StateImageMap::GetEstimateImage()
{
	Image* estimateImage = nullptr;
	if (!m_stateImageMap[ControlStateType::NORMAL].imageAttribute.sImageName.empty()){
		estimateImage = &m_stateImageMap[ControlStateType::NORMAL];
	}
	else if (!m_stateImageMap[ControlStateType::HOT].imageAttribute.sImageName.empty()) {
		estimateImage = &m_stateImageMap[ControlStateType::HOT];
	}
	else if (!m_stateImageMap[ControlStateType::PUSHED].imageAttribute.sImageName.empty()) {
		estimateImage = &m_stateImageMap[ControlStateType::PUSHED];
	}
	else if (!m_stateImageMap[ControlStateType::DISABLED].imageAttribute.sImageName.empty()) {
		estimateImage = &m_stateImageMap[ControlStateType::DISABLED];
	}

	return estimateImage;
}

void StateColorMap::PaintStatusColor(HDC hDC, UiRect rcPaint, ControlStateType stateType)
{
	if (m_pControl) {
		int bFadeHot = m_pControl->GetAnimationManager().IsAnimated(AnimationType::FADE_HOT);
		int hotAlpha = m_pControl->GetHotAlpha();
		if (bFadeHot) {
			if ((stateType == ControlStateType::NORMAL || stateType == ControlStateType::HOT)
				&& !m_stateColorMap[ControlStateType::HOT].empty()) {
				RenderEngine::DrawColor(hDC, rcPaint, m_stateColorMap[ControlStateType::NORMAL]);

				if (hotAlpha > 0) {
					RenderEngine::DrawColor(hDC, rcPaint, m_stateColorMap[ControlStateType::HOT], hotAlpha);
				}

				return;
			}
		}
	}


	if (stateType == ControlStateType::PUSHED && m_stateColorMap[ControlStateType::PUSHED].empty()) {
		stateType = ControlStateType::HOT;
	}
	if (stateType == ControlStateType::HOT && m_stateColorMap[ControlStateType::HOT].empty()) {
		stateType = ControlStateType::NORMAL;
	}
	if (stateType == ControlStateType::DISABLED && m_stateColorMap[ControlStateType::DISABLED].empty()) {
		stateType = ControlStateType::NORMAL;
	}

	RenderEngine::DrawColor(hDC, rcPaint, m_stateColorMap[stateType]);
}

}