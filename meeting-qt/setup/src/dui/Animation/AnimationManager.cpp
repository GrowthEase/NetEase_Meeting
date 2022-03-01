/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"

namespace ui 
{

AnimationPlayer* AnimationManager::SetFadeHot(bool bFadeHot)
{
	AnimationPlayer* animationArgs = nullptr;
	if (bFadeHot) {
		animationArgs = new AnimationPlayer();
		animationArgs->SetStartValue(0);
		animationArgs->SetEndValue(255);
		animationArgs->SetSpeedUpRatio(0.3);
		animationArgs->SetSpeedDownRatio(0.7);
		animationArgs->SetTotalMillSeconds(300);
		std::function<void(int)> playCallback = std::bind(&Control::SetHotAlpha, m_pControl, std::placeholders::_1);
		animationArgs->SetCallback(playCallback);
		m_animationMap[AnimationType::FADE_HOT].reset(animationArgs);
	}
	else {
		m_animationMap.erase(AnimationType::FADE_HOT);
	}

	return animationArgs;
}

AnimationPlayer* AnimationManager::SetFadeAlpha(bool bFadeVisible)
{
	AnimationPlayer* animationArgs = nullptr;
	if (bFadeVisible) {
		animationArgs = new AnimationPlayer();
		animationArgs->SetStartValue(0);
		animationArgs->SetEndValue(255);
		animationArgs->SetSpeedUpRatio(0.3);
		animationArgs->SetSpeedDownRatio(0.7);
		animationArgs->SetTotalMillSeconds(300);
		std::function<void(int)> playCallback = std::bind(&Control::SetAlpha, m_pControl, std::placeholders::_1);
		animationArgs->SetCallback(playCallback);
		m_animationMap[AnimationType::FADE_ALPHA].reset(animationArgs);
		m_pControl->SetAlpha(0);
	}
	else {
		m_animationMap.erase(AnimationType::FADE_ALPHA);
		m_pControl->SetAlpha(255);
	}

	return animationArgs;
}

AnimationPlayer* AnimationManager::SetFadeWidth(bool bFadeWidth)
{
	AnimationPlayer* animationArgs = nullptr;
	if (bFadeWidth) {
		animationArgs = new AnimationPlayer();
		animationArgs->SetStartValue(0);
		CSize size = { 999999, 999999 };
		size = m_pControl->EstimateSize(size);
		ASSERT(size.cy > 0);
		animationArgs->SetEndValue(size.cx);
		animationArgs->SetSpeedUpRatio(0.3);
		animationArgs->SetSpeedUpfactorA(0.00084);
		animationArgs->SetSpeedDownRatio(0.7);
		std::function<void(int)> playCallback = std::bind(&Control::SetFixedWidth, m_pControl, std::placeholders::_1, true);
		animationArgs->SetCallback(playCallback);
		m_animationMap[AnimationType::FADE_WIDTH].reset(animationArgs);
	}
	else {
		m_animationMap.erase(AnimationType::FADE_WIDTH);
	}

	return animationArgs;
}

AnimationPlayer* AnimationManager::SetFadeHeight(bool bFadeHeight)
{
	AnimationPlayer* animationArgs = nullptr;
	if (bFadeHeight) {
		animationArgs = new AnimationPlayer();
		animationArgs->SetStartValue(0);
		CSize size = { 999999, 999999 };
		size = m_pControl->EstimateSize(size);
		ASSERT(size.cy > 0);
		animationArgs->SetEndValue(size.cy);
		animationArgs->SetSpeedUpRatio(0.3);
		animationArgs->SetSpeedUpfactorA(0.00084);
		animationArgs->SetSpeedDownRatio(0.7);
		std::function<void(int)> playCallback = std::bind(&Control::SetFixedHeight, m_pControl, std::placeholders::_1);
		animationArgs->SetCallback(playCallback);
		m_animationMap[AnimationType::FADE_HEIGHT].reset(animationArgs);
	}
	else {
		m_animationMap.erase(AnimationType::FADE_HEIGHT);
	}

	return animationArgs;
}

AnimationPlayer* AnimationManager::SetFadeInOutX(bool bFade, bool bIsFromRight)
{
	AnimationPlayer* animationArgs = nullptr;
	if (bFade) {
		animationArgs = new AnimationPlayer();
		CSize size = { 999999, 999999 };
		size = m_pControl->EstimateSize(size);
		if (size.cy <= 0) {
			size.cy = 100;
		}
		if (bIsFromRight) {
			animationArgs->SetStartValue(-size.cy);
		}
		else {
			animationArgs->SetStartValue(size.cy);
		}
		animationArgs->SetEndValue(0);
		animationArgs->SetSpeedUpRatio(0.3);
		animationArgs->SetSpeedUpfactorA(0.006);
		animationArgs->SetSpeedDownRatio(0.7);
		std::function<void(int)> playCallback = std::bind(&Control::SetRenderOffsetX, m_pControl, std::placeholders::_1);
		animationArgs->SetCallback(playCallback);
		m_animationMap[AnimationType::FADE_INOUT_X].reset(animationArgs);
	}
	else if (!bFade){
		m_animationMap.erase(AnimationType::FADE_INOUT_X);
	}

	return animationArgs;
}

AnimationPlayer* AnimationManager::SetFadeInOutY(bool bFade, bool bIsFromBottom)
{
	AnimationPlayer* animationArgs = nullptr;
	if (bFade) {
		animationArgs = new AnimationPlayer();
		CSize size = { 999999, 999999 };
		size = m_pControl->EstimateSize(size);
		if (size.cy <= 0) {
			size.cy = 100;
		}
		if (bIsFromBottom) {
			animationArgs->SetStartValue(-size.cy);
		}
		else {
			animationArgs->SetStartValue(size.cy);
		}
		animationArgs->SetEndValue(0);
		animationArgs->SetSpeedUpRatio(0.3);
		animationArgs->SetSpeedUpfactorA(0.006);
		animationArgs->SetSpeedDownRatio(0.7);
		std::function<void(int)> playCallback = std::bind(&Control::SetRenderOffsetY, m_pControl, std::placeholders::_1);
		animationArgs->SetCallback(playCallback);
		m_animationMap[AnimationType::FADE_INOUT_Y].reset(animationArgs);
	}
	else if (!bFade){
		m_animationMap.erase(AnimationType::FADE_INOUT_Y);
	}

	return animationArgs;
}

void AnimationManager::Appear()
{
	m_pControl->SetVisible_(true);
	if (IsAnimated(AnimationType::FADE_ALPHA)) {
		m_animationMap[AnimationType::FADE_ALPHA]->SetCompleteCallback(StdClosure());
		m_animationMap[AnimationType::FADE_ALPHA]->Continue();
	}
	if (IsAnimated(AnimationType::FADE_WIDTH)) {
		m_animationMap[AnimationType::FADE_WIDTH]->SetCompleteCallback(StdClosure());
		m_animationMap[AnimationType::FADE_WIDTH]->Continue();
	}
	if (IsAnimated(AnimationType::FADE_HEIGHT)) {
		m_animationMap[AnimationType::FADE_HEIGHT]->SetCompleteCallback(StdClosure());
		m_animationMap[AnimationType::FADE_HEIGHT]->Continue();
	}
	if (IsAnimated(AnimationType::FADE_INOUT_X)) {
		m_animationMap[AnimationType::FADE_INOUT_X]->SetCompleteCallback(StdClosure());
		m_animationMap[AnimationType::FADE_INOUT_X]->Continue();
	}
	if (IsAnimated(AnimationType::FADE_INOUT_Y)) {
		m_animationMap[AnimationType::FADE_INOUT_Y]->SetCompleteCallback(StdClosure());
		m_animationMap[AnimationType::FADE_INOUT_Y]->Continue();
	}
}

void AnimationManager::Disappear()
{
	bool handled = false;

	StdClosure completeCallback = std::bind(&Control::SetVisible_, m_pControl, false);
	completeCallback = m_pControl->ToWeakCallback(completeCallback);
	if (IsAnimated(AnimationType::FADE_ALPHA)) {
		m_animationMap[AnimationType::FADE_ALPHA]->SetCompleteCallback(completeCallback);
		m_animationMap[AnimationType::FADE_ALPHA]->ReverseContinue();
		handled = true;
	}
	if (IsAnimated(AnimationType::FADE_WIDTH)) {
		m_animationMap[AnimationType::FADE_WIDTH]->SetCompleteCallback(completeCallback);
		m_animationMap[AnimationType::FADE_WIDTH]->ReverseContinue();
		handled = true;
	}
	if (IsAnimated(AnimationType::FADE_HEIGHT)) {
		m_animationMap[AnimationType::FADE_HEIGHT]->SetCompleteCallback(completeCallback);
		m_animationMap[AnimationType::FADE_HEIGHT]->ReverseContinue();
		handled = true;
	}
	if (IsAnimated(AnimationType::FADE_INOUT_X)) {
		m_animationMap[AnimationType::FADE_INOUT_X]->SetCompleteCallback(completeCallback);
		m_animationMap[AnimationType::FADE_INOUT_X]->ReverseContinue();
		handled = true;
	}
	if (IsAnimated(AnimationType::FADE_INOUT_Y)) {
		m_animationMap[AnimationType::FADE_INOUT_Y]->SetCompleteCallback(completeCallback);
		m_animationMap[AnimationType::FADE_INOUT_Y]->ReverseContinue();
		handled = true;
	}

	if (!handled) {
		m_pControl->SetVisible_(false);
	}
}

void AnimationManager::MouseEnter()
{
	if (IsAnimated(AnimationType::FADE_HOT)) {
		m_animationMap[AnimationType::FADE_HOT]->Continue();
	}
}

void AnimationManager::MouseLeave()
{
	if (IsAnimated(AnimationType::FADE_HOT)) {
		m_animationMap[AnimationType::FADE_HOT]->ReverseContinue();
	}
}

}