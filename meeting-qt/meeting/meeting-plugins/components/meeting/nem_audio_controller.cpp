// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_audio_controller.h"

NEMAudioController::NEMAudioController(QObject* parent)
    : QObject(parent) {}

bool NEMAudioController::muteLocalAudio(bool muted) {
    if (m_audioController) {
        return m_audioController->setLocalAudioStatus(muted) == nem_sdk::kNEMNoError;
    }
    return false;
}

bool NEMAudioController::isValid() const {
    return m_isValid;
}

void NEMAudioController::setIsValid(bool isValid) {
    if (m_isValid != isValid) {
        m_isValid = isValid;
        Q_EMIT isValidChanged();
    }
}

nem_sdk::IAudioController* NEMAudioController::audioController() const {
    return m_audioController;
}

void NEMAudioController::setAudioController(nem_sdk::IAudioController* audioController) {
    if (m_audioController != audioController) {
        m_audioController = audioController;
        if (m_audioController != nullptr) {
            m_audioController->setAudioEventHandler(this);
            setIsValid(true);
        }
    }
}

NEMAudioController::AudioDeviceStatus NEMAudioController::localAudioStatus() const {
    return m_localAudioStatus;
}

void NEMAudioController::setLocalAudioStatus(const AudioDeviceStatus& localAudioStatus) {
    if (m_localAudioStatus != localAudioStatus) {
        m_localAudioStatus = localAudioStatus;
        Q_EMIT localAudioStatusChanged();
    }
}

void NEMAudioController::onUserAudioStatusChanged(const std::string& accountId, nem_sdk::DeviceStatus device_status) {
    Q_EMIT userAudioStatusChanged(QString::fromStdString(accountId), AudioDeviceStatus(device_status));
}

void NEMAudioController::onActiveSpeakerChanged(const std::string& accountId, const std::string& nickname) {}

void NEMAudioController::onRemoteUserAudioStats(const std::vector<nem_sdk::AudioStats>& videoStats) {}

void NEMAudioController::onHandsUpStatusChanged(const std::string& accountId, int handsUpStatus) {}

void NEMAudioController::onError(uint32_t errorCode, const std::string& errorMessage) {}
