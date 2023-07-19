// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_PROVIDERS_NEM_FRAME_PROVIDER_H_
#define MEETING_PLUGINS_PROVIDERS_NEM_FRAME_PROVIDER_H_

#include <QAbstractVideoSurface>
#include <QDebug>
#include <QObject>
#include <QSize>
#include <QVideoSurfaceFormat>

class NEMFrameProvider : public QObject {
    Q_OBJECT
    Q_PROPERTY(QAbstractVideoSurface* videoSurface READ videoSurface WRITE setVideoSurface)
    Q_PROPERTY(VideoQuality videoQuality READ videoQuality WRITE setVideoQuality NOTIFY videoQualityChanged)

public:
    explicit NEMFrameProvider(QObject* parent = nullptr);
    ~NEMFrameProvider();

    enum VideoQuality { VIDEO_QUALITY_HIGH, VIDEO_QUALITY_LOW };

    QAbstractVideoSurface* videoSurface() const { return m_videoSurface; }
    void setVideoSurface(QAbstractVideoSurface* videoSurface);

    VideoQuality videoQuality() const;
    void setVideoQuality(const VideoQuality& videoQuality);

Q_SIGNALS:
    void newFrame(const QVideoFrame& frame, const QSize& videoSize);
    void providerInvalidated();
    void accountIdChanged();
    void videoQualityChanged();

public slots:
    void deliverFrame(const QVideoFrame& frame, const QSize& videoSize);

private:
    QVideoSurfaceFormat m_videoFormat;
    QAbstractVideoSurface* m_videoSurface;
    VideoQuality m_videoQuality;
};

#endif  // MEETING_PLUGINS_PROVIDERS_NEM_FRAME_PROVIDER_H_
