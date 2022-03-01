/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "frame_rate.h"
#include <QBrush>

FrameRate::FrameRate(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    setFlag(QQuickItem::ItemHasContents);
}

int FrameRate::value() const
{
    return m_value;
}

void FrameRate::paint(QPainter * painter)
{
    refreshFPS();

    QBrush brush(Qt::yellow);
    painter->setBrush(brush);
    painter->setRenderHint(QPainter::Antialiasing);
    painter->drawRoundedRect(0, 0, boundingRect().width(), boundingRect().height(), 0, 0);

    QFont font = painter->font();
    font.setPixelSize(qMin(width(), height()) * 0.6);
    painter->setFont(font);
    QPen pen = painter->pen();
    pen.setColor(Qt::red);
    painter->setPen(pen);
    painter->drawText(boundingRect(), Qt::AlignCenter, QString("FPS:%1").arg(m_value));

    update();
}

void FrameRate::qmlRegisterType()
{
    ::qmlRegisterType<FrameRate>("NetEase.Meeting.FrameRate", 1, 0, "FrameRate");
}

void FrameRate::refreshFPS()
{
    qint64 currentTime = QDateTime::currentDateTime().toMSecsSinceEpoch();
    m_frames.push_back(currentTime);

    while (m_frames[0] < (currentTime - 1000)) {
        m_frames.pop_front();
    }

    int currentCount = m_frames.length();
    m_value = (currentCount + m_cacheCount) / 2;

    if (currentCount != m_cacheCount) {
        emit valueChanged(m_value);
    }

    m_cacheCount = currentCount;
}
