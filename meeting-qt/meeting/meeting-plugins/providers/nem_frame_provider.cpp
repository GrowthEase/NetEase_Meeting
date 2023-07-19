// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_frame_provider.h"
#include <QDebug>

NEMFrameProvider::NEMFrameProvider(QObject* parent)
    : QObject(parent)
    , m_videoFormat(QSize(0, 0), QVideoFrame::Format_YUV420P)
    , m_videoSurface(nullptr) {
    connect(this, &NEMFrameProvider::newFrame, this, &NEMFrameProvider::deliverFrame);
}

NEMFrameProvider::~NEMFrameProvider() {
    disconnect(this, &NEMFrameProvider::newFrame, 0, 0);
    emit providerInvalidated();
}

void NEMFrameProvider::deliverFrame(const QVideoFrame& frame, const QSize& videoSize) {
    if (m_videoSurface && m_videoFormat.frameSize() != videoSize) {
        // Video size changed
        m_videoSurface->stop();
        m_videoFormat.setFrameSize(videoSize);
        m_videoSurface->start(m_videoFormat);
    }
    if (m_videoSurface)
        m_videoSurface->present(frame);
}

NEMFrameProvider::VideoQuality NEMFrameProvider::videoQuality() const {
    return m_videoQuality;
}

void NEMFrameProvider::setVideoQuality(const VideoQuality& videoQuality) {
    if (m_videoQuality != videoQuality) {
        m_videoQuality = videoQuality;
        Q_EMIT videoQualityChanged();
    }
}

void NEMFrameProvider::setVideoSurface(QAbstractVideoSurface* videoSurface) {
    if (m_videoSurface == videoSurface)
        return;
    if (m_videoSurface && m_videoSurface->isActive())
        m_videoSurface->stop();
    m_videoSurface = videoSurface;
    if (m_videoSurface)
        m_videoSurface->start(m_videoFormat);
}
