/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CONTROL_BUTTON_H_
#define UI_CONTROL_BUTTON_H_

#pragma once

namespace ui
{


template<typename InheritType = Control>
class UILIB_API ButtonTemplate : public LabelTemplate<InheritType>
{
public:
	ButtonTemplate();

	virtual void Activate() override;
	virtual void HandleMessage(EventArgs& event) override;

	void AttachClick(const EventCallback& callback)
	{
		OnEvent[EventType::CLICK] += callback;
	}

};


#include "ButtonImpl.h"

typedef ButtonTemplate<Control> Button;
typedef ButtonTemplate<Box> ButtonBox;



}	// namespace ui

#endif // UI_CONTROL_BUTTON_H_