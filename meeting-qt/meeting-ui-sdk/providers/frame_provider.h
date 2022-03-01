/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef VIDEO_SOURCE_H
#define VIDEO_SOURCE_H

#include <QAbstractVideoSurface>
#include <QDebug>
#include <QObject>
#include <QSize>
#include <QTimer>
#include <QVideoSurfaceFormat>
#include <atomic>

/**
 * @brief 视频数据源提供器，由 QML 实例化具体实例传递给 C++ 做数据渲染.
 */
class FrameProvider : public QObject {
    Q_OBJECT
    Q_PROPERTY(QAbstractVideoSurface* videoSurface READ videoSurface WRITE setVideoSurface)
    Q_PROPERTY(QString accountId READ accountId WRITE setAccountId NOTIFY accountIdChanged)
    Q_PROPERTY(bool subVideo READ subVideo WRITE setSubVideo NOTIFY subVideoChanged)

public:
    explicit FrameProvider(QObject* parent = nullptr);
    ~FrameProvider();

    QAbstractVideoSurface* videoSurface() const { return m_videoSurface; }
    void setVideoSurface(QAbstractVideoSurface* videoSurface);

    QString accountId() const;
    void setAccountId(const QString& accountId);

    bool subVideo() const;
    void setSubVideo(bool subVideo);

signals:
    void receivedVideoFrame(const QVideoFrame& frame, const QSize& videoSize);
    void providerInvalidated();
    void accountIdChanged();
    void streamFpsChanged(int istreamFps);
    void subVideoChanged();

public slots:
    void restart();
    void deliverFrame(const QString& accountId, const QVideoFrame& frame, const QSize& videoSize, bool sub);
    void statisticsStreamFps(bool bStart);

private:
    QVideoSurfaceFormat m_videoFormat;
    QAbstractVideoSurface* m_videoSurface;
    QString m_accountId;
    std::atomic_int m_iStreamFps;
    int m_iLastStreamFps = -1;
    QTimer m_timer;
    bool m_subVideo = false;
};

#endif  // VIDEO_SOURCE_H
