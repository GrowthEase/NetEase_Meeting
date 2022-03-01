/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CORE_PLACE_HOLDER_H_
#define UI_CORE_PLACE_HOLDER_H_

#pragma once


namespace ui 
{

class PlaceHolder : public nbase::SupportWeakCallback
{
public:
	PlaceHolder();
	virtual ~PlaceHolder();

	UI_FORBID_COPY(PlaceHolder)

	Box* GetParent() const
	{
		return m_pParent;
	}

	std::wstring GetName() const;
	std::string GetUTF8Name() const;
	void SetName(const std::wstring& pstrName);
	void SetUTF8Name(const std::string&  pstrName);

	virtual Window* GetWindow() const;
	virtual void SetWindow(Window* pManager, Box* pParent, bool bInit = true);
	virtual void SetWindow(Window* pManager);

	virtual void Init();
	virtual void DoInit();

	virtual CSize EstimateSize(CSize szAvailable);
	
	HorAlignType GetHorAlignType() const
	{
		return m_horAlignType;
	}
	void SetHorAlignType(HorAlignType horAlignType)
	{
		m_horAlignType = horAlignType;
	}

	VerAlignType GetVerAlignType() const
	{
		return m_verAlignType;
	}
	void SetVerAlignType(VerAlignType verAlignType)
	{
		m_verAlignType = verAlignType;
	}

	virtual bool IsVisible() const;
	bool IsFloat() const;
	void SetFloat(bool bFloat = true);

	int GetFixedWidth() const;
	void SetFixedWidth(int cx, bool arrange = true);
	int GetFixedHeight() const;
	void SetFixedHeight(int cy);
	int GetMinWidth() const;
	void SetMinWidth(int cx);
	int GetMaxWidth() const;
	void SetMaxWidth(int cx);
	int GetMinHeight() const;
	void SetMinHeight(int cy);
	int GetMaxHeight() const;
	void SetMaxHeight(int cy);
	int GetWidth() const;
	int GetHeight() const;

	virtual	UiRect GetPos(bool bContainShadow = true) const;
	virtual void SetPos(UiRect rc);

	virtual void Arrange();
	virtual void ArrangeAncestor();
	
	void Invalidate() const;
	UiRect GetPosWithScrollOffset() const;
	bool IsArranged() const;
	CPoint GetScrollOffset() const;

	void SetReEstimateSize(bool reEstimateSize)
	{
		m_bReEstimateSize = reEstimateSize;
	}
	bool GetReEstimateSize() const
	{
		return m_bReEstimateSize;
	}

protected:
	virtual void ArrangeSelf();

protected:
	Window* m_pWindow = nullptr;
	std::wstring m_sName;
	CSize m_cxyFixed{ DUI_LENGTH_STRETCH, DUI_LENGTH_STRETCH };
	CSize m_cxyMin{ -1, -1 };
	CSize m_cxyMax{ 9999999, 9999999 };
	Box* m_pParent = nullptr;
	UiRect m_rcItem;
	HorAlignType m_horAlignType = HorAlignType::LEFT;
	VerAlignType m_verAlignType = VerAlignType::TOP;
	bool m_bFloat = false;
	bool m_bReEstimateSize = true;
	bool m_bVisible = true;
	bool m_bInternVisible = true;
	bool m_bIsArranged = true;
};


bool IsChild(PlaceHolder* pAncestor, PlaceHolder* pChild);


} // namespace ui

#endif // UI_CORE_PLACE_HOLDER_H_
