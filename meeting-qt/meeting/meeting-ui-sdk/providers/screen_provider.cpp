// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "screen_provider.h"

ScreenProvider::ScreenProvider(QObject* parent)
    : QObject(parent) {
    m_captureTimer.setSingleShot(true);
    m_captureTimer.setInterval(300);
    connect(&m_captureTimer, &QTimer::timeout, this, &ScreenProvider::timeout);
    connect(this, &ScreenProvider::screenPictureReceived, this, &ScreenProvider::deliverFrame);
}

ScreenProvider::~ScreenProvider() {
    m_captureTimer.disconnect(this);
    m_captureTimer.stop();
    emit providerInvalidated();
}

void ScreenProvider::setVideoSink(QVideoSink* videoSink) {
    if (m_videoSink == videoSink)
        return;
    m_videoSink = videoSink;
    emit videoSinkChanged();
}

void ScreenProvider::timeout() {
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
    // QVideoFrame frame(image);
    QVideoFrameFormat frameFormat(image.size(), QVideoFrameFormat::pixelFormatFromImageFormat(image.format()));
    QVideoFrame frame(frameFormat);
    if (frame.map(QVideoFrame::WriteOnly)) {
        std::copy(image.bits(), image.bits() + frame.mappedBytes(0), frame.bits(0));
        frame.unmap();
    }
    emit screenPictureReceived(frame, image.size());
    m_captureTimer.start();
}

void ScreenProvider::deliverFrame(const QVideoFrame& frame, const QSize& videoSize) {
    if (m_videoSink)
        m_videoSink->setVideoFrame(frame);
}

bool ScreenProvider::capture() const {
    return m_capture;
}

void ScreenProvider::setCapture(bool capture) {
    m_capture = capture;
    if (m_capture)
        m_captureTimer.start();
    else
        m_captureTimer.stop();
}

int ScreenProvider::screenIndex() const {
    return m_screenIndex;
}

void ScreenProvider::setScreenIndex(int screenIndex) {
    m_screenIndex = screenIndex;
}
