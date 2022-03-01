/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "stdafx.h"


namespace ui
{

EventType StringToEnum(const std::wstring& messageType)
{
	if (messageType == EVENTSTR_ALL) {
		return EventType::ALL;
	}
	else if (messageType == EVENTSTR_KEYDOWN) {
		return EventType::KEYDOWN;
	}
	else if (messageType == EVENTSTR_KEYUP) {
		return EventType::KEYUP;
	}
	else if (messageType == EVENTSTR_CHAR) {
		return EventType::CHAR;
	}
	else if (messageType == EVENTSTR_SYSKEY) {
		return EventType::SYSKEY;
	}
	else if (messageType == EVENTSTR_SETFOCUS) {
		return EventType::SETFOCUS;
	}
	else if (messageType == EVENTSTR_KILLFOCUS) {
		return EventType::KILLFOCUS;
	}
	else if (messageType == EVENTSTR_SETCURSOR) {
		return EventType::SETCURSOR;
	}
	else if (messageType == EVENTSTR_MOUSEMOVE) {
		return EventType::MOUSEMOVE;
	}
	else if (messageType == EVENTSTR_MOUSEENTER) {
		return EventType::MOUSEENTER;
	}
	else if (messageType == EVENTSTR_MOUSELEAVE) {
		return EventType::MOUSELEAVE;
	}
	else if (messageType == EVENTSTR_MOUSEHOVER) {
		return EventType::MOUSEHOVER;
	}
	else if (messageType == EVENTSTR_BUTTONDOWN) {
		return EventType::BUTTONDOWN;
	}
	else if (messageType == EVENTSTR_BUTTONUP) {
		return EventType::BUTTONUP;
	}
	else if (messageType == EVENTSTR_RBUTTONDOWN) {
		return EventType::RBUTTONDOWN;
	}
	else if (messageType == EVENTSTR_DOUBLECLICK) {
		return EventType::DOUBLECLICK;
	}
	else if (messageType == EVENTSTR_SELECT) {
		return EventType::SELECT;
	}
	else if (messageType == EVENTSTR_UNSELECT) {
		return EventType::UNSELECT;
	}
	else if (messageType == EVENTSTR_MENU) {
		return EventType::MENU;
	}
	else if (messageType == EVENTSTR_SCROLLWHEEL) {
		return EventType::SCROLLWHEEL;
	}
	else if (messageType == EVENTSTR_SCROLLAPPEAR) {
		return EventType::SCROLLAPPEAR;
	}
	else if (messageType == EVENTSTR_SCROLLDISAPPEAR) {
		return EventType::SCROLLDISAPPEAR;
	}
	else if (messageType == EVENTSTR_SCROLLUPOVER) {
		return EventType::SCROLLUPOVER;
	}
	else if (messageType == EVENTSTR_SCROLLDOWNOVER) {
		return EventType::SCROLLDOWNOVER;
	}
	else if (messageType == EVENTSTR_SCROLLCHANGE) {
		return EventType::SCROLLCHANGE;
	}
	else if (messageType == EVENTSTR_VALUECHANGE) {
		return EventType::VALUECHANGE;
	}
	else if (messageType == EVENTSTR_RETURN) {
		return EventType::RETURN;
	}
	else if (messageType == EVENTSTR_TAB) {
		return EventType::TAB;
	}
	else if (messageType == EVENTSTR_WINDOWINIT) {
		return EventType::WINDOWINIT;
	}
	else if (messageType == EVENTSTR_WINDOWCLOSE) {
		return EventType::WINDOWCLOSE;
	}
	else if (messageType == EVENTSTR_SHOWACTIVEX) {
		return EventType::SHOWACTIVEX;
	}
	else {
		ASSERT(FALSE);
		return EventType::NONE;
	}
}

}