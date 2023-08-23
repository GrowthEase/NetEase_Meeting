// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef DESKTOPPROVIDER_H
#define DESKTOPPROVIDER_H

#include <QDebug>
#include <QGuiApplication>
#include <QObject>
#include <QPixmap>
#include <QPointer>
#include <QScreen>
#include <QTimer>
#include <QVideoFrame>
#include <QVideoSink>

class ScreenProvider : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVideoSink* videoSink READ videoSink WRITE setVideoSink NOTIFY videoSinkChanged)
    Q_PROPERTY(int screenIndex READ screenIndex WRITE setScreenIndex)
    Q_PROPERTY(bool capture READ capture WRITE setCapture NOTIFY captureChanged)

public:
    explicit ScreenProvider(QObject* parent = nullptr);
    ~ScreenProvider();

    QVideoSink* videoSink() const { return m_videoSink; }
    void setVideoSink(QVideoSink* videoSink);

    int screenIndex() const;
    void setScreenIndex(int screenIndex);

    bool capture() const;
    void setCapture(bool capture);

signals:
    void videoSinkChanged();
    void providerInvalidated();
    void captureChanged();
    void screenPictureReceived(const QVideoFrame& frame, const QSize& videoSize);

public slots:
    void timeout();
    void deliverFrame(const QVideoFrame& frame, const QSize& videoSize);

private:
    QPointer<QVideoSink> m_videoSink;
    QTimer m_captureTimer;
    int m_screenIndex = 0;
    bool m_capture = false;
};

#endif  // DESKTOPPROVIDER_H
