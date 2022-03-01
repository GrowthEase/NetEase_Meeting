/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef VIDEO_WINDOW_H
#define VIDEO_WINDOW_H

#include <QQuickItem>

class VideoWindow : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QColor fillColor READ fillColor WRITE setfillColor NOTIFY fillColorChanged)
    Q_PROPERTY(QQuickItem* frontItem READ frontItem WRITE setFrontItem NOTIFY frontItemChanged)

public:
    explicit VideoWindow(QQuickItem *parent = nullptr);
    ~VideoWindow();

    // 设置视频窗口相对父窗口的位置和大小
    Q_INVOKABLE void setVideoGeometry(int x, int y, int w, int h);
    Q_INVOKABLE void setVideoItem(QQuickItem* item);

    QQuickItem* frontItem() const;
    QColor fillColor() const;

public slots:
    void setfillColor(QColor fillColor);
    void setFrontItem(QQuickItem* item);
    void* getWindowId() const;

signals:
    void fillColorChanged(QColor fillColor);
    void frontItemChanged(const QQuickItem* item);

private:
    void adjustItemWidgetFront();
    void adjustItemWidgetPosition();
    void associationWidget(QQuickWindow* pParent);
    void unAssociationWidget(QQuickWindow* pParent);

private:
    QQuickWindow* m_pVideoWidget = nullptr;
    QQuickWindow* m_pItemWidget = nullptr;
    QQuickItem* m_pItem = nullptr;
    QQuickItem* m_pVideoItem = nullptr;
    QColor m_fillColor = Qt::black;
};

#endif // VIDEO_WINDOW_H
