// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef VIDEO_SOURCE_H
#define VIDEO_SOURCE_H

// TODO(Dylan)
#include <QDebug>
#include <QObject>
#include <QPointer>
#include <QSize>
#include <QTimer>
#include <QVideoFrame>
#include <QVideoSink>
#include <atomic>

/**
 * @brief 视频数据源提供器，由 QML 实例化具体实例传递给 C++ 做数据渲染.
 */
class FrameProvider : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVideoSink* videoSink READ videoSink WRITE setVideoSink NOTIFY videoSinkChanged)
    Q_PROPERTY(QString accountId READ accountId WRITE setAccountId NOTIFY accountIdChanged)
    Q_PROPERTY(bool subVideo READ subVideo WRITE setSubVideo NOTIFY subVideoChanged)
    Q_PROPERTY(QVector<float> yuv2rgbMatrix READ yuv2rgbMatrix WRITE setYuv2rgbMatrix NOTIFY yuv2rgbMatrixChanged)
    Q_PROPERTY(QString uuid READ uuid)

public:
    explicit FrameProvider(QObject* parent = nullptr);
    ~FrameProvider();

    QVideoSink* videoSink() const { return m_videoSink; }
    void setVideoSink(QVideoSink* videoSink);

    QString accountId() const;
    void setAccountId(const QString& accountId);

    bool subVideo() const;
    void setSubVideo(bool subVideo);

    QString uuid() const { return m_uuid; }

    QVector<float> yuv2rgbMatrix() const;
    void setYuv2rgbMatrix(const QVector<float>& yuv2rgbMatrix);

signals:
    void videoSinkChanged();
    void receivedVideoFrame(const QVideoFrame& frame, const QSize& videoSize);
    void providerInvalidated();
    void accountIdChanged();
    void streamFpsChanged(int istreamFps);
    void subVideoChanged();
    void yuv2rgbMatrixChanged(const QVector<float>& yuv2rgbMatrix);

public slots:
    void restart();
    void deliverFrame(const QString& accountId, const QVideoFrame& frame, const QSize& videoSize, bool sub);
    void statisticsStreamFps(bool bStart);

private:
    QPointer<QVideoSink> m_videoSink;
    QString m_accountId;
    std::atomic_int m_iStreamFps;
    int m_iLastStreamFps = -1;
    QTimer m_timer;
    bool m_subVideo = false;
    QString m_uuid;
    QVector<float> m_yuv2rgbMatrix;
};

#endif  // VIDEO_SOURCE_H
