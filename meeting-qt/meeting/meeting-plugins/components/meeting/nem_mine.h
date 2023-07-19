// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_COMPONENTS_MEETING_NEM_MINE_H_
#define MEETING_PLUGINS_COMPONENTS_MEETING_NEM_MINE_H_

#include <QObject>
#include "nem_audio_controller.h"
#include "nem_video_controller.h"

class NEMMine : public QObject {
    Q_OBJECT

public:
    explicit NEMMine(QObject* parent = nullptr);

    Q_PROPERTY(QString accountId READ accountId WRITE setAccountId NOTIFY accountIdChanged)
    Q_PROPERTY(NEMAudioController::AudioDeviceStatus audioStatus READ audioStatus NOTIFY audioStatusChanged)
    Q_PROPERTY(NEMVideoController::VideoDeviceStatus videoStatus READ videoStatus NOTIFY videoStatusChanged)
    Q_PROPERTY(bool sharing READ sharing WRITE setSharing NOTIFY sharingChanged)

    QString accountId() const;
    void setAccountId(const QString& accountId);

    NEMAudioController::AudioDeviceStatus audioStatus() const;
    void setAudioStatus(const NEMAudioController::AudioDeviceStatus& audioStatus);

    NEMVideoController::VideoDeviceStatus videoStatus() const;
    void setVideoStatus(const NEMVideoController::VideoDeviceStatus& videoStatus);

    bool sharing() const;
    void setSharing(bool sharing);

Q_SIGNALS:
    void accountIdChanged();
    void audioStatusChanged();
    void videoStatusChanged();
    void sharingChanged();

public Q_SLOTS:
    void userAudioStatusChanged(const QString& accountId, NEMAudioController::AudioDeviceStatus status);
    void userVideoStatusChanged(const QString& accountId, NEMVideoController::VideoDeviceStatus status);
    void sharingStatusChanged(const QString& accountId, bool sharing, bool paused);

private:
    QString m_accountId;
    NEMAudioController::AudioDeviceStatus m_audioStatus = NEMAudioController::AUDIO_DEVICE_ENABLED;
    NEMVideoController::VideoDeviceStatus m_videoStatus = NEMVideoController::VIDEO_DEVICE_ENABLED;
    bool m_sharing = false;
};

#endif  // MEETING_PLUGINS_COMPONENTS_MEETING_NEM_MINE_H_
