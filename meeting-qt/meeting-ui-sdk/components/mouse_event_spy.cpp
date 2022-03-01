/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "mouse_event_spy.h"
#include <QEvent>
#include <QCursor>

MouseEventSpy::MouseEventSpy(QObject *parent) : QObject(parent)
{
    connect(&m_mousePosTimer, &QTimer::timeout, this, &MouseEventSpy::timeout);
    m_mousePosTimer.start(200);
}

MouseEventSpy::~MouseEventSpy()
{
    m_mousePosTimer.stop();
    disconnect(&m_mousePosTimer, &QTimer::timeout, this, &MouseEventSpy::timeout);
}

void MouseEventSpy::timeout()
{
    QPoint mouseLoc = QCursor::pos();
    if (m_lastMousePos != mouseLoc) {
        m_lastMousePos = mouseLoc;
        emit mousePosDetected(mouseLoc.x(), mouseLoc.y());
    }
}
