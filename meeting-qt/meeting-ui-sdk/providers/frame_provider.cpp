/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "frame_provider.h"
#include <QDebug>

FrameProvider::FrameProvider(QObject* parent)
    : QObject(parent)
    , m_videoFormat(QSize(0, 0), QVideoFrame::Format_YUV420P)
    , m_videoSurface(nullptr)
    , m_iStreamFps(0) {
    m_timer.callOnTimeout([this]() {
        int istreamFps = m_iStreamFps / 2;
        m_iStreamFps = 0;
        if (istreamFps < 25 && m_iLastStreamFps != istreamFps) {
            m_iLastStreamFps = istreamFps;
            YXLOG(Info) << "deliver Frame, m_accountId: " << m_accountId.toStdString() << ", FPS: " << istreamFps << YXLOGEnd;
        } else if (istreamFps >= 25 && -1 != m_iLastStreamFps) {
            m_iLastStreamFps = -1;
            YXLOG(Info) << "deliver Frame, m_accountId: " << m_accountId.toStdString() << ", FPS: " << istreamFps << YXLOGEnd;
        }
        emit streamFpsChanged(istreamFps);
    });

    YXLOG(Info) << "Frame provider created: " << this << YXLOGEnd;
}

FrameProvider::~FrameProvider() {
    YXLOG(Info) << "Frame provider invalidated: " << this << ", m_videoSurface: " << m_videoSurface << YXLOGEnd;
    m_videoSurface = nullptr;
    disconnect(this, &FrameProvider::receivedVideoFrame, 0, 0);
    emit providerInvalidated();
}

void FrameProvider::deliverFrame(const QString& accountId, const QVideoFrame& frame, const QSize& videoSize, bool sub) {
    if (nullptr == m_videoSurface) {
        return;
    }

    if (accountId != m_accountId || (sub != m_subVideo)) {
        return;
    }

    if (m_videoFormat.frameSize() != videoSize) {
        // Video size changed
        m_videoSurface->stop();
        m_videoFormat.setFrameSize(videoSize);
        m_videoSurface->start(m_videoFormat);
    }

    if (!m_timer.isActive() && videoSize.height() <= 720 && videoSize.width() <= 1280) {
        statisticsStreamFps(true);
    } else if (m_timer.isActive() && accountId.isEmpty() && videoSize.height() > 720 && videoSize.width() > 1280) {
        statisticsStreamFps(false);
    }

    m_iStreamFps++;
    m_videoSurface->present(frame);
}

QString FrameProvider::accountId() const {
    return m_accountId;
}

void FrameProvider::setAccountId(const QString& accountId) {
    m_accountId = accountId;
}

bool FrameProvider::subVideo() const {
    return m_subVideo;
}

void FrameProvider::setSubVideo(bool subVideo) {
    if (subVideo != m_subVideo) {
        m_subVideo = subVideo;
        emit subVideoChanged();
    }
}

void FrameProvider::setVideoSurface(QAbstractVideoSurface* videoSurface) {
    if (m_videoSurface == videoSurface)
        return;

    if (m_videoSurface && m_videoSurface->isActive())
        m_videoSurface->stop();

    m_videoSurface = videoSurface;

    if (m_videoSurface)
        m_videoSurface->start(m_videoFormat);
}

void FrameProvider::restart() {
    if (nullptr == m_videoSurface) {
        return;
    }

    m_videoSurface->stop();
    m_videoSurface->start(m_videoFormat);
}

void FrameProvider::statisticsStreamFps(bool bStart) {
    if (bStart && m_timer.isActive() || !bStart && !m_timer.isActive())
        return;

    m_iStreamFps = 0;
    m_iLastStreamFps = -1;
    if (bStart) {
        if (m_videoFormat.frameSize().height() > 720 && m_videoFormat.frameSize().width() > 1280) {
            return;
        }
        m_timer.start(2000);
    } else {
        m_timer.stop();
        emit streamFpsChanged(m_iStreamFps);
    }
}
