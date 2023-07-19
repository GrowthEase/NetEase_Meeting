// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_COMPONENTS_MEETING_NEM_AUDIO_CONTROLLER_H_
#define MEETING_PLUGINS_COMPONENTS_MEETING_NEM_AUDIO_CONTROLLER_H_

#include <QDebug>
#include <QObject>
#include <QPointer>
#include <string>
#include <vector>
#include "meeting/audio_ctrl_interface.h"

class NEMAudioController : public QObject, public nem_sdk::IAudioEventHandler {
    Q_OBJECT
    Q_ENUMS(AudioDeviceStatus)

public:
    explicit NEMAudioController(QObject* parent = nullptr);

    enum AudioDeviceStatus {
        AUDIO_DEVICE_ENABLED = 1,       // Device enabled
        AUDIO_DEVICE_DISABLED_BY_SELF,  // Disabled by self
        AUDIO_DEVICE_DISABLED_BY_HOST,  // Disabled by host
        AUDIO_DEVICE_NEEDS_TO_CONFIRM   // Needs to confirm
    };

    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)
    Q_PROPERTY(AudioDeviceStatus localAudioStatus READ localAudioStatus WRITE setLocalAudioStatus NOTIFY localAudioStatusChanged)

    Q_INVOKABLE bool muteLocalAudio(bool muted);

    bool isValid() const;
    void setIsValid(bool isValid);

    nem_sdk::IAudioController* audioController() const;
    void setAudioController(nem_sdk::IAudioController* audioController);

    AudioDeviceStatus localAudioStatus() const;
    void setLocalAudioStatus(const AudioDeviceStatus& localAudioStatus);

Q_SIGNALS:
    void isValidChanged();
    void localAudioStatusChanged();
    void userAudioStatusChanged(const QString& accountId, AudioDeviceStatus status);

protected:
    void onUserAudioStatusChanged(const std::string& accountId, nem_sdk::DeviceStatus device_status) override;
    void onActiveSpeakerChanged(const std::string& accountId, const std::string& nickname) override;
    void onRemoteUserAudioStats(const std::vector<nem_sdk::AudioStats>& videoStats) override;
    void onHandsUpStatusChanged(const std::string& accountId, int handsUpStatus) override;
    void onError(uint32_t errorCode, const std::string& errorMessage) override;

private:
    bool m_isValid = false;
    nem_sdk::IAudioController* m_audioController = nullptr;
    AudioDeviceStatus m_localAudioStatus = AUDIO_DEVICE_ENABLED;
};

#endif  // MEETING_PLUGINS_COMPONENTS_MEETING_NEM_AUDIO_CONTROLLER_H_
