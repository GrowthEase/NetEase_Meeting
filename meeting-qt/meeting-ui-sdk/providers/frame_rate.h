/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef FRAMERATE_H
#define FRAMERATE_H

#include <QQuickPaintedItem>
#include <QPainter>

class FrameRate : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(int value READ value NOTIFY valueChanged)
public:
    explicit FrameRate(QQuickItem *parent = 0);
    int value() const;
    void paint(QPainter *);
    static void qmlRegisterType();

signals:
    void valueChanged(int);

private:
    void refreshFPS();

private:
    int             m_value = -1;
    int             m_cacheCount = 0;
    QVector<qint64> m_frames;
};

#endif // FRAMERATE_H
