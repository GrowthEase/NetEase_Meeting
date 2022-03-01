/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"

namespace ui 
{

#define WM_USER_DEFINED_TIMER	(WM_USER + 9999)
#define TIMER_INTERVAL	16
#define TIMER_PRECISION	1

HWND TimerManager::m_hideWnd = NULL;

TimerManager::TimerManager()
{
	QueryPerformanceFrequency(&m_liPerfFreq); 

	HINSTANCE hinst = ::GetModuleHandle(NULL);

	WNDCLASSEXW wc = {0};
	wc.cbSize = sizeof(wc);
	wc.lpfnWndProc = WndProcThunk;
	wc.hInstance = hinst;
	wc.lpszClassName = L"UI_ANIMATION_TIMERMANAGER_H_";
	::RegisterClassExW(&wc);

	m_hideWnd = ::CreateWindowW(L"UI_ANIMATION_TIMERMANAGER_H_", 0, 0, 0, 0, 0, 0, HWND_MESSAGE, 0, hinst, 0);
}

LRESULT TimerManager::WndProcThunk(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam)
{
	if (message == WM_USER_DEFINED_TIMER) {
		TimerManager::GetInstance()->Poll();
		return 1;
	}

	return ::DefWindowProcW(hwnd, message, wparam, lparam);
}

void TimerManager::TimeCallback(UINT uTimerID, UINT uMsg, DWORD_PTR dwUser, DWORD_PTR dw1, DWORD_PTR dw2)
{
	::PostMessage(m_hideWnd, WM_USER_DEFINED_TIMER, 0, 0);
}

bool TimerManager::AddCancelableTimer(const std::weak_ptr<nbase::WeakFlag>& weakFlag, const TIMERINFO::TimerCallback& callback, UINT uElapse, int iRepeatTime)
{
	ASSERT(uElapse > 0);

	TIMERINFO pTimer;
	pTimer.timerCallback = callback;
	pTimer.uPause = uElapse * m_liPerfFreq.QuadPart / 1000;
	QueryPerformanceCounter(&pTimer.dwTimeEnd);
	pTimer.dwTimeEnd.QuadPart += pTimer.uPause;
	pTimer.iRepeatTime = iRepeatTime;
	pTimer.weakFlag = weakFlag;
	m_aTimers.push(pTimer);
	
	if (m_oldTimerId == 0 || m_isMinPause == false) {
		timeKillEvent(m_oldTimerId);
		m_oldTimerId = ::timeSetEvent(TIMER_INTERVAL, TIMER_PRECISION, &TimerManager::TimeCallback, NULL, TIME_PERIODIC);
		ASSERT(m_oldTimerId);
		m_isMinPause = true;
	}


	return true;
}

void TimerManager::Poll()
{
	LARGE_INTEGER currentTime;
	QueryPerformanceCounter(&currentTime);
	while (!m_aTimers.empty()) {
		LONGLONG detaTime = m_aTimers.top().dwTimeEnd.QuadPart - currentTime.QuadPart;
		if (detaTime <= 0) {
			TIMERINFO it = m_aTimers.top();
			m_aTimers.pop();

			if (!it.weakFlag.expired()) {
				it.timerCallback();
				bool rePush = false;
				if (it.iRepeatTime > 0) {
					it.iRepeatTime--;
					if (it.iRepeatTime > 0) {
						rePush = true;
					}
				}
				else if (it.iRepeatTime == REPEAT_FOREVER) {
					rePush = true;
				}

				if (rePush) {
					TIMERINFO rePushTimerInfo = it;
					rePushTimerInfo.dwTimeEnd.QuadPart = currentTime.QuadPart + it.uPause;
					m_aTimers.push(rePushTimerInfo);
				}
			}
		}
		else if (detaTime > 0 && detaTime < m_liPerfFreq.QuadPart) {
			if (!m_isMinPause) {
				timeKillEvent(m_oldTimerId);
				m_oldTimerId = ::timeSetEvent(TIMER_INTERVAL, TIMER_PRECISION, &TimerManager::TimeCallback, NULL, TIME_PERIODIC);
				ASSERT(m_oldTimerId);
				m_isMinPause = true;
			}

			break;
		}
		else {
			double newDetaTime = double(detaTime) * 1000 / m_liPerfFreq.QuadPart;
			timeKillEvent(m_oldTimerId);
			m_oldTimerId = ::timeSetEvent(int(newDetaTime + 2 * TIMER_PRECISION), TIMER_PRECISION, &TimerManager::TimeCallback, NULL, TIME_PERIODIC);
			ASSERT(m_oldTimerId);
			m_isMinPause = false;
			break;
		}
	}

	if (m_aTimers.empty()) {
		timeKillEvent(m_oldTimerId);
		m_oldTimerId = 0;
	}
}

}