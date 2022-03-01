/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "screen_provider.h"

ScreenProvider::ScreenProvider(QObject *parent)
    : QObject(parent)
    , m_videoFormat(QSize(0, 0), QVideoFrame::Format_ARGB32)
    , m_videoSurface(nullptr)
{
    m_captureTimer.setSingleShot(true);
    m_captureTimer.setInterval(300);
    connect(&m_captureTimer, &QTimer::timeout, this, &ScreenProvider::timeout);
    connect(this, &ScreenProvider::screenPictureReceived, this, &ScreenProvider::deliverFrame);
}

ScreenProvider::~ScreenProvider()
{
    m_captureTimer.disconnect(this);
    m_captureTimer.stop();
    emit providerInvalidated();
}

void ScreenProvider::setVideoSurface(QAbstractVideoSurface *videoSurface)
{
    if (m_videoSurface == videoSurface)
        return;

    if (m_videoSurface && m_videoSurface->isActive())
        m_videoSurface->stop();

    m_videoSurface = videoSurface;

    if (m_videoSurface) {
        m_videoSurface->start(m_videoFormat);
    }
}

void ScreenProvider::timeout()
{
    auto screens = QGuiApplication::screens();
    if (m_screenIndex > screens.size() - 1 || m_screenIndex < 0) {
        // 移除某个屏幕的时候，这里停止捕获
        m_captureTimer.stop();
        return;
    }
    auto screen = screens.at(m_screenIndex);
#ifdef Q_OS_WIN32
    QPixmap pixmap = screen->grabWindow(0);
#else
    QPixmap pixmap = screen->grabWindow(0, screen->geometry().x(), screen->geometry().y(), screen->geometry().width(), screen->geometry().height());
#endif
    QImage image(pixmap.toImage().convertToFormat(QImage::Format_RGB32));
    QVideoFrame frame(image);

    emit screenPictureReceived(frame, image.size());
    m_captureTimer.start();
}

void ScreenProvider::deliverFrame(const QVideoFrame& frame, const QSize &videoSize)
{
    if (m_videoFormat.frameSize() != videoSize) {
        m_videoSurface->stop();
        m_videoFormat.setFrameSize(videoSize);
        m_videoSurface->start(m_videoFormat);
    }

    if (m_videoSurface)
        m_videoSurface->present(frame);
}

bool ScreenProvider::capture() const
{
    return m_capture;
}

void ScreenProvider::setCapture(bool capture)
{
    m_capture = capture;
    if (m_capture)
        m_captureTimer.start();
    else
        m_captureTimer.stop();
}

int ScreenProvider::screenIndex() const
{
    return m_screenIndex;
}

void ScreenProvider::setScreenIndex(int screenIndex)
{
    m_screenIndex = screenIndex;
}
