// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "frame_provider.h"
#include <QDebug>
#include <QUuid>
#ifdef Q_OS_WIN32
#elif defined Q_OS_MACX
#include "components/macx_helpers.h"
#endif

FrameProvider::FrameProvider(QObject* parent)
    : QObject(parent)
    , m_iStreamFps(0) {
    m_uuid = QUuid::createUuid().toString();

    static QString productName;
#if defined(Q_OS_MACX)
    MacXHelpers helper;
    if (productName.isEmpty()) {
        productName = helper.getDeviceName();
        YXLOG(Info) << "productName: " << productName.toStdString() << YXLOGEnd;
    }
#endif
    if (productName.contains("MacBookPro", Qt::CaseInsensitive)) {  // MacBookPro
        if (productName.contains("MacBookPro17,1", Qt::CaseInsensitive)) {
            // 专用参数
            m_yuv2rgbMatrix = {1.15, 1.15, 1.15, 0.4, -0.4, 1.90, 1.65, -0.75, 0.1};
        } else {
            m_yuv2rgbMatrix = {1.15, 1.15, 1.15, 0.4, -0.4, 1.90, 1.65, -0.75, 0.1};
        }
    } else {
        m_yuv2rgbMatrix = {1.150, 1.150, 1.150, 0, -0.8, 1.8, 2.1, -1.1, -0.2};
    }

    m_timer.callOnTimeout([this]() {
        int istreamFps = m_iStreamFps / 2;
        m_iStreamFps = 0;
        if (istreamFps < 25 && m_iLastStreamFps != istreamFps) {
            m_iLastStreamFps = istreamFps;
            // YXLOG(Info) << "deliver Frame, m_accountId: " << m_accountId.toStdString() << ", FPS: " << istreamFps << YXLOGEnd;
        } else if (istreamFps >= 25 && -1 != m_iLastStreamFps) {
            m_iLastStreamFps = -1;
            // YXLOG(Info) << "deliver Frame, m_accountId: " << m_accountId.toStdString() << ", FPS: " << istreamFps << YXLOGEnd;
        }
        emit streamFpsChanged(istreamFps);
    });

    YXLOG(Info) << "Frame provider created: " << this << YXLOGEnd;
}

FrameProvider::~FrameProvider() {
    disconnect(this, &FrameProvider::receivedVideoFrame, 0, 0);
    emit providerInvalidated();
}

void FrameProvider::deliverFrame(const QString& accountId, const QVideoFrame& frame, const QSize& videoSize, bool sub) {
    if (!m_videoSink)
        return;

    if ((accountId != m_accountId && !accountId.isEmpty()) || (sub != m_subVideo)) {
        return;
    }

    if (!m_timer.isActive() && videoSize.height() <= 720 && videoSize.width() <= 1280) {
        statisticsStreamFps(true);
    } else if (m_timer.isActive() && accountId.isEmpty() && videoSize.height() > 720 && videoSize.width() > 1280) {
        statisticsStreamFps(false);
    }

    m_iStreamFps++;
    m_videoSink->setVideoFrame(frame);
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

QVector<float> FrameProvider::yuv2rgbMatrix() const {
    return m_yuv2rgbMatrix;
}

void FrameProvider::setYuv2rgbMatrix(const QVector<float>& yuv2rgbMatrix) {
    m_yuv2rgbMatrix == yuv2rgbMatrix;
    emit yuv2rgbMatrixChanged(m_yuv2rgbMatrix);
}

void FrameProvider::setVideoSink(QVideoSink* videoSink) {
    if (m_videoSink == videoSink)
        return;
    m_videoSink = videoSink;
    emit videoSinkChanged();
}

void FrameProvider::restart() {}

void FrameProvider::statisticsStreamFps(bool bStart) {
    if (bStart && m_timer.isActive() || !bStart && !m_timer.isActive())
        return;

    m_iStreamFps = 0;
    m_iLastStreamFps = -1;
    if (bStart) {
        if (m_videoSink && m_videoSink->videoSize().height() <= 720 && m_videoSink->videoSize().width() <= 1280)
            return;
        m_timer.start(2000);
    } else {
        m_timer.stop();
        emit streamFpsChanged(m_iStreamFps);
    }
}
