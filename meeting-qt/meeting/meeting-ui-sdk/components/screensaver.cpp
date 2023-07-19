// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "screensaver.h"
ScreenSaver::ScreenSaver(QObject* parent)
    : QObject(parent) {
    m_pTimer = new QTimer(this);
    connect(m_pTimer, SIGNAL(timeout()), this, SLOT(activityTimeout()));
}

ScreenSaver::~ScreenSaver() {
    if (m_pTimer->isActive()) {
        m_pTimer->stop();
    }
}

bool ScreenSaver::screenSaverEnabled() const {
    return m_pTimer->isActive();
}

void ScreenSaver::setScreenSaverEnabled(bool enabled) {
    YXLOG(Info) << "setScreenSaverEnabled: " << enabled << YXLOGEnd;
    if (enabled && !m_pTimer->isActive()) {
        m_pTimer->start(1000 * 40);
    } else if (!enabled && m_pTimer->isActive()) {
        m_pTimer->stop();
    }
}

void ScreenSaver::activityTimeout() {
#if defined(_WIN32)
    keybd_event(VK_RCONTROL, 0, 0, 0);
    keybd_event(VK_RCONTROL, 0, KEYEVENTF_KEYUP, 0);
#endif
}
