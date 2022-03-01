/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CORE_IMAGEDECODE_H_
#define UI_CORE_IMAGEDECODE_H_

#pragma once

#include <GdiPlus.h>
#include "Utils/Utils.h"

namespace ui {

class ImageInfo
{
public:
	ImageInfo()
	{

	}

	~ImageInfo();
	
	int nX;
	int nY;
	std::wstring sImageFullPath;


	void SetAlpha(bool bAlphaChannel) {
		m_bAlphaChannel = bAlphaChannel;
	}

	bool IsAlpha() {
		return m_bAlphaChannel;
	}

	void SetPropertyItem(Gdiplus::PropertyItem* propertyItem) {
		m_propertyItem.reset(propertyItem);
	}

	void PushBackHBitmap(HBITMAP hBitmap) {
		m_vecBitmap.push_back(hBitmap);
	}

	HBITMAP GetHBitmap(int index) {
		return m_vecBitmap[index];
	}

	int GetFrameCount() {
		return m_vecBitmap.size();
	}

	int IsGif() {
		return m_vecBitmap.size() > 1;
	}

	//毫秒为单位 
	int GetInterval(int index);
	 
	static std::unique_ptr<ImageInfo> LoadImage(const std::wstring& imageFullPath);
	static std::unique_ptr<ImageInfo> LoadImage(HGLOBAL hGlobal, const std::wstring& imageFullPath);

private:
	static std::unique_ptr<ImageInfo> LoadImageByBitmap(std::unique_ptr<Gdiplus::Bitmap>& gdiplus_bitmap, const std::wstring& imageFullPath);
	std::unique_ptr<Gdiplus::PropertyItem> m_propertyItem;
	bool m_bAlphaChannel = false;
	std::vector<HBITMAP> m_vecBitmap;
};


struct ImageAttribute
{
public:
	ImageAttribute()
	{
		Init();
	}

	void Init()
	{
		imageString.clear();
		sImageName.clear();
		bFade = 0xFF;
		bTiledX = false;
		bTiledY = false;
		rcDest.left = rcDest.top = rcDest.right = rcDest.bottom = DUI_NOSET_VALUE;
		rcSource.left = rcSource.top = rcSource.right = rcSource.bottom = DUI_NOSET_VALUE;
		rcCorner.left = rcCorner.top = rcCorner.right = rcCorner.bottom = 0;
	}

	void SetImageString (const std::wstring& imageStr);
	static void ModifyAttribute(ImageAttribute& imageAttribute, const std::wstring& imageStr);

	std::wstring imageString;
	std::wstring sImageName;
	UiRect rcDest;
	UiRect rcSource;
	UiRect rcCorner;
	BYTE bFade;
	bool bTiledX;
	bool bTiledY;
};


class Image
{
public:
	Image()
		: imageAttribute(),
		m_iCurrentFrame(0),
		m_bPlaying(false),
		imageCache()
	{

	}

	void SetImageString(const std::wstring& imageString)
	{
		imageAttribute.Init();
		imageAttribute.SetImageString(imageString);
		m_iCurrentFrame = 0;
		m_bPlaying = false;
		imageCache.reset();
	}

	void IncrementCurrentFrame() {
		m_iCurrentFrame++;
		if (m_iCurrentFrame == imageCache->GetFrameCount()) {
			m_iCurrentFrame = 0;
		}
	}

	void SetCurrentFrame(int iCurrentFrame) {
		m_iCurrentFrame = iCurrentFrame;
	}

	bool IsPlaying()
	{
		return m_bPlaying;
	}

	void SetPlaying(bool playing)
	{
		m_bPlaying = playing;
	}

	HBITMAP GetCurrentHBitmap() {
		return imageCache->GetHBitmap(m_iCurrentFrame);
	}

	int GetCurrentInterval() {
		return imageCache->GetInterval(m_iCurrentFrame);
	}

	ImageAttribute imageAttribute;
	int m_iCurrentFrame;
	bool m_bPlaying;
	std::shared_ptr<ImageInfo> imageCache;
};

class StateImageMap
{
public:
	StateImageMap()
	{

	}

	void SetControl(Control* control)
	{
		m_pControl = control;
	}

	Image& operator[](ControlStateType stateType)
	{
		return m_stateImageMap[stateType];
	}

	bool PaintStatusImage(HDC hDC, ControlStateType stateType, const std::wstring& m_sImageModify = L"");
	Image* GetEstimateImage();

private:
	Control* m_pControl = nullptr;
	std::map<ControlStateType, Image> m_stateImageMap;
};

class StateColorMap
{
public:
	StateColorMap()
	{

	}

	void SetControl(Control* control)
	{
		m_pControl = control;
	}

	std::wstring& operator[](ControlStateType stateType)
	{
		return m_stateColorMap[stateType];
	}

	void PaintStatusColor(HDC hDC, UiRect rcPaint, ControlStateType stateType);

private:
	Control* m_pControl = nullptr;
	std::map<ControlStateType, std::wstring> m_stateColorMap;
};


} // namespace ui

#endif // UI_CORE_IMAGEDECODE_H_
