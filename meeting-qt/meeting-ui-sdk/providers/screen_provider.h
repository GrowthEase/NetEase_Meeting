/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef DESKTOPPROVIDER_H
#define DESKTOPPROVIDER_H

#include <QTimer>
#include <QDebug>
#include <QObject>
#include <QPixmap>
#include <QScreen>
#include <QGuiApplication>
#include <QVideoSurfaceFormat>
#include <QAbstractVideoSurface>

class ScreenProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QAbstractVideoSurface *videoSurface READ videoSurface WRITE setVideoSurface)
    Q_PROPERTY(int screenIndex READ screenIndex WRITE setScreenIndex)
    Q_PROPERTY(bool capture READ capture WRITE setCapture NOTIFY captureChanged)

public:
    explicit ScreenProvider(QObject *parent = nullptr);
    ~ScreenProvider();

    QAbstractVideoSurface* videoSurface() const { return m_videoSurface; }
    void setVideoSurface(QAbstractVideoSurface* videoSurface);

    int screenIndex() const;
    void setScreenIndex(int screenIndex);

    bool capture() const;
    void setCapture(bool capture);

signals:
    void providerInvalidated();
    void captureChanged();
    void screenPictureReceived(const QVideoFrame& frame, const QSize& videoSize);

public slots:
    void timeout();
    void deliverFrame(const QVideoFrame& frame, const QSize& videoSize);

private:
    QVideoSurfaceFormat     m_videoFormat;
    QAbstractVideoSurface*  m_videoSurface;
    QTimer                  m_captureTimer;
    int                     m_screenIndex = 0;
    bool                    m_capture = false;
};

#endif // DESKTOPPROVIDER_H
