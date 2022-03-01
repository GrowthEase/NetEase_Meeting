/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_ANIMATION_ANIMATIONMANAGER_H_
#define UI_ANIMATION_ANIMATIONMANAGER_H_

#pragma once

namespace ui 
{

class UILIB_API AnimationManager
{
public:
	void Init(Control* control)
	{
		m_pControl = control;
	}

	bool IsAnimated(AnimationType animationType) const
	{
		return m_animationMap.find(animationType) != m_animationMap.end();
	}

	AnimationPlayer* SetFadeHot(bool bFadeHot);
	AnimationPlayer* SetFadeAlpha(bool bFadeVisible);
	AnimationPlayer* SetFadeWidth(bool bFadeWidth);
	AnimationPlayer* SetFadeHeight(bool bFadeHeight);
	AnimationPlayer* SetFadeInOutX(bool bFade, bool bIsFromRight);
	AnimationPlayer* SetFadeInOutY(bool bFade, bool bIsFromBottom);

	void Appear();
	void Disappear();
	void MouseEnter();
	void MouseLeave();

private:
	Control* m_pControl = nullptr;
	std::map<AnimationType, std::unique_ptr<AnimationPlayer>> m_animationMap;
};

} // namespace ui

#endif // UI_ANIMATION_ANIMATIONMANAGER_H_
