// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef AUDIOMANAGER_H
#define AUDIOMANAGER_H

#include <QObject>

#include "controller/audio_controller.h"
#include "manager/auth_manager.h"
#include "manager/meeting_manager.h"
#include "utils/singleton.h"

using namespace neroom;

class AudioManager : public QObject {
    Q_OBJECT
private:
    explicit AudioManager(QObject* parent = nullptr);

public:
    SINGLETONG(AudioManager);

    Q_PROPERTY(int localAudioStatus READ localAudioStatus WRITE setLocalAudioStatus NOTIFY localAudioStatusChanged)
    Q_PROPERTY(QString activeSpeaker READ activeSpeaker WRITE setActiveSpeaker NOTIFY activeSpeakerChanged)
    Q_PROPERTY(QString activeSpeakerNickname READ activeSpeakerNickname WRITE setActiveSpeakerNickname NOTIFY activeSpeakerNicknameChanged)

    Q_INVOKABLE void openSystemMicrophoneSettings();

    void onUserAudioStatusChanged(const std::string& accountId, NEMeeting::DeviceStatus deviceStatus);
    void onActiveSpeakerChanged(const std::string& accountId, const std::string& nickname);
    void onUserSpeakerChanged(const std::list<std::string>& nickname);
    void onRemoteUserAudioStats(const std::vector<NEAudioStats>& videoStats);
    void onError(uint32_t errorCode, const std::string& errorMessage);

    bool startAudioDump();
    bool stopAudioDump();
    bool enableAudioVolumeIndication(bool enable);
    std::shared_ptr<NEMeetingAudioController> getAudioController();

public:
    int localAudioStatus() const;
    void setLocalAudioStatus(const int& localAudioStatus);

    QString activeSpeaker() const;
    void setActiveSpeaker(const QString& activeSpeaker);

    QString activeSpeakerNickname() const;
    void setActiveSpeakerNickname(const QString& activeSpeakerNickname);

    bool hasMicrophonePermission();
signals:
    void localAudioStatusChanged();
    void activeSpeakerChanged();
    void activeSpeakerNicknameChanged();
    void remoteUserAudioStats(const QJsonArray& userStats);
    void userAudioStatusChanged(const QString& changedAccountId, NEMeeting::DeviceStatus deviceStatus);
    void error(int errorCode, const QString& errorMessage);
    void showPermissionWnd();
    void userSpeakerChanged(const QString& nickName);

public slots:
    void muteLocalAudio(bool mute);
    void muteRemoteAudio(const QString& accountId, bool mute, bool bAllowOpenByself = true);
    void onUserAudioStatusChangedUI(const QString& changedAccountId, NEMeeting::DeviceStatus deviceStatus);
    void onActiveSpeakerChangedUI(const QString& accountId, const QString& nickname);
    void onUserSpeakerChangedUI(const QStringList& accountId);

private:
    std::shared_ptr<NEMeetingAudioController> m_audioController = nullptr;
    NEMeeting::DeviceStatus m_localAudioStatus = NEMeeting::DEVICE_DISABLED_BY_DELF;
    QString m_activeSpeaker;
    QString m_activeSpeakerNickname;
};

#endif  // AUDIOMANAGER_H
