/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "video_window.h"
#include "../components/macx_helpers.h"

VideoWindow::VideoWindow(QQuickItem* parent)
    : QQuickItem(parent) {
    connect(this, &QQuickItem::windowChanged, this, [this](QQuickWindow* pParentWindow) {
        if (pParentWindow) {
            if (m_pVideoWidget) {
                m_pVideoWidget->setParent(pParentWindow);
                m_pVideoWidget->setVisible(pParentWindow->isVisible() && isVisible());
            } else {
                m_pVideoWidget = new QQuickWindow(pParentWindow);
                m_pVideoWidget->setFlag(Qt::FramelessWindowHint, true);
                m_pVideoWidget->setFlag(Qt::WindowTransparentForInput, true);
                m_pVideoWidget->setColor(m_fillColor);
            }
            if (m_pItemWidget) {
#ifdef Q_OS_WIN32
                m_pItemWidget->setParent(nullptr);
#else
                m_pItemWidget->setParent(pParentWindow);
#endif
                m_pItemWidget->setVisible(pParentWindow->isVisible() && isVisible());
            } else {
#ifdef Q_OS_WIN32
                m_pItemWidget = new QQuickWindow();
#else
                m_pItemWidget = new QQuickWindow(pParentWindow);
#endif
                m_pItemWidget->setFlag(Qt::FramelessWindowHint, true);
                m_pItemWidget->setFlag(Qt::SubWindow, true);
                m_pItemWidget->setColor(Qt::transparent);
            }

            associationWidget(pParentWindow);
        } else {
            if (m_pVideoWidget) {
                m_pVideoWidget->setVisible(false);
                m_pVideoWidget->deleteLater();
                m_pVideoWidget = nullptr;
            }

            if (m_pItemWidget) {
                m_pItemWidget->setVisible(false);
                m_pItemWidget->deleteLater();
                m_pItemWidget = nullptr;
            }

            unAssociationWidget(pParentWindow);
        }
    });

    connect(this, &VideoWindow::visibleChanged, [this]() {
        if (m_pVideoWidget) {
            m_pVideoWidget->setVisible(isVisible());
        }
        if (m_pItemWidget) {
            m_pItemWidget->setVisible(isVisible());
        }
    });
}

VideoWindow::~VideoWindow() {
    if (m_pVideoWidget) {
        m_pVideoWidget->deleteLater();
        m_pVideoWidget = nullptr;
    }

    if (m_pItemWidget) {
        m_pItemWidget->deleteLater();
        m_pItemWidget = nullptr;
    }
}

QColor VideoWindow::fillColor() const {
    return m_fillColor;
}

void VideoWindow::setfillColor(QColor fillColor) {
    if (m_fillColor == fillColor)
        return;

    m_fillColor = fillColor;
    if (m_pVideoWidget) {
        m_pVideoWidget->setColor(m_fillColor);
    }

    emit fillColorChanged(m_fillColor);
}

QQuickItem* VideoWindow::frontItem() const {
    return m_pItem;
}

void VideoWindow::setFrontItem(QQuickItem* item) {
    if (item == m_pItem || !m_pItemWidget) {
        return;
    }

    if (m_pItem) {
        m_pItem->setParent(nullptr);
        m_pItem->setParentItem(nullptr);
        m_pItem->deleteLater();
        m_pItem = nullptr;
    }

    if (item) {
        m_pItem = item;
        m_pItemWidget->resize(m_pItem->size().toSize());
        adjustItemWidgetPosition();
        m_pItemWidget->setVisible(isVisible());
        m_pItem->setParentItem(m_pItemWidget->contentItem());
    }

    emit frontItemChanged(m_pItem);
}

void* VideoWindow::getWindowId() const {
    if (!m_pVideoWidget) {
        return nullptr;
    }

    return (void*)m_pVideoWidget->winId();
}

void VideoWindow::setVideoGeometry(int x, int y, int w, int h) {
    if (m_pVideoWidget) {
        m_pVideoWidget->setGeometry(x, y, w, h);
        m_pVideoWidget->setVisible(isVisible());
    }
}

void VideoWindow::setVideoItem(QQuickItem* item) {
    if (m_pVideoItem) {
        m_pVideoItem->disconnect(this);
        m_pVideoItem = nullptr;
    }

    if (!item) {
        return;
    }

    m_pVideoItem = item;
    QPoint pt = m_pVideoItem->window()->contentItem()->mapFromItem(m_pVideoItem, QPointF(0, 0)).toPoint();
    setVideoGeometry(pt.x(), pt.y(), m_pVideoItem->width(), m_pVideoItem->height());
    if (m_pVideoWidget) {
        m_pVideoWidget->setVisible(isVisible());
    }
    connect(item, &QQuickItem::xChanged, this, [this]() {
        if (m_pVideoWidget) {
            QPoint pt = m_pVideoItem->window()->contentItem()->mapFromItem(m_pVideoItem, QPointF(0, 0)).toPoint();
            m_pVideoWidget->setX(pt.x());
        }
    });

    connect(item, &QQuickItem::yChanged, this, [this]() {
        if (m_pVideoWidget) {
            QPoint pt = m_pVideoItem->window()->contentItem()->mapFromItem(m_pVideoItem, QPointF(0, 0)).toPoint();
            m_pVideoWidget->setX(pt.y());
        }
    });

    connect(item, &QQuickItem::widthChanged, this, [this]() {
        if (m_pVideoWidget) {
            m_pVideoWidget->setWidth(m_pVideoItem->width());
        }
    });

    connect(item, &QQuickItem::heightChanged, this, [this]() {
        if (m_pVideoWidget) {
            m_pVideoWidget->setHeight(m_pVideoItem->height());
        }
    });
}

void VideoWindow::adjustItemWidgetFront() {
#ifndef Q_OS_WIN32
    return;
#endif
    if (!m_pItemWidget || !m_pVideoWidget || !m_pVideoWidget->parent()) {
        return;
    }
    if (m_pVideoWidget->parent()->flags() & Qt::WindowStaysOnTopHint) {
#ifdef Q_OS_WIN32
        ::SetWindowPos((HWND)m_pItemWidget->winId(), HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSIZE);
#else
#endif
    } else {
        m_pItemWidget->raise();
    }
}

void VideoWindow::adjustItemWidgetPosition() {
    if (m_pItemWidget) {
#ifdef Q_OS_WIN32
        QPoint point = mapToGlobal(QPointF(0, 0)).toPoint();
#else
        QPoint point = mapToScene(QPointF(0, 0)).toPoint();
#endif
        m_pItemWidget->setPosition(point.x(), point.y());
        adjustItemWidgetFront();
    }
}

void VideoWindow::associationWidget(QQuickWindow* pParent) {
    if (!pParent) {
        return;
    }
    connect(pParent, &QQuickWindow::activeChanged, this, [=]() {
        if (pParent->isActive() && m_pItemWidget && !m_pItemWidget->isActive()) {
            adjustItemWidgetFront();
        }
    });

    connect(pParent, &QQuickWindow::visibilityChanged, this, [=]() {
        QWindow::Visibility visibility = pParent->visibility();
        bool bVisible = true;
        if (QWindow::Minimized == visibility || QWindow::Hidden == visibility) {
            bVisible = false;
        }

        if (m_pItemWidget && m_pItem) {
            m_pItemWidget->setVisible(bVisible);
        }

        if (m_pVideoWidget && m_pVideoItem) {
            m_pVideoWidget->setVisible(bVisible);
        }
    });

    connect(pParent, &QQuickWindow::xChanged, this, [=]() { adjustItemWidgetPosition(); });

    connect(pParent, &QQuickWindow::yChanged, this, [=]() { adjustItemWidgetPosition(); });
}

void VideoWindow::unAssociationWidget(QQuickWindow* pParent) {
    if (!pParent) {
        return;
    }

    disconnect(pParent, &QQuickWindow::activeChanged, this, nullptr);
    disconnect(pParent, &QQuickWindow::visibleChanged, this, nullptr);
    disconnect(pParent, &QQuickWindow::xChanged, this, nullptr);
    disconnect(pParent, &QQuickWindow::yChanged, this, nullptr);
}
