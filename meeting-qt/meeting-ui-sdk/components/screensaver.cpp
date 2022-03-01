/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "screensaver.h"
ScreenSaver::ScreenSaver(QObject *parent) : QObject(parent)
{
    m_pTimer = new QTimer(this);
    connect(m_pTimer, SIGNAL(timeout()), this, SLOT(activityTimeout()));
}

ScreenSaver::~ScreenSaver()
{
    if (m_pTimer->isActive())
    {
        m_pTimer->stop();
    }
}

bool ScreenSaver::screenSaverEnabled() const
{
    return m_pTimer->isActive();
}

void ScreenSaver::setScreenSaverEnabled(bool enabled)
{
    YXLOG(Info) << "setScreenSaverEnabled: " << enabled << YXLOGEnd;
    if (enabled && !m_pTimer->isActive())
    {
        m_pTimer->start(1000 * 40);
    }
    else if (!enabled && m_pTimer->isActive())
    {
        m_pTimer->stop();
    }
}

void ScreenSaver::activityTimeout()
{
//    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
//    mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);
    keybd_event(VK_CONTROL, 0, 0 ,0);
    keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP,0);
}
