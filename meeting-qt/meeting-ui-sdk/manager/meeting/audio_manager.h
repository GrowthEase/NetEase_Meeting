/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef AUDIOMANAGER_H
#define AUDIOMANAGER_H

#include <QObject>

#include "controller/audio_ctrl_interface.h"
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
    Q_PROPERTY(bool handsUpStatus READ handsUpStatus WRITE setHandsUpStatus)

    void onUserAudioStatusChanged(const std::string& accountId, NEMeeting::DeviceStatus deviceStatus);
    void onActiveSpeakerChanged(const std::string& accountId, const std::string& nickname);
    void onRemoteUserAudioStats(const std::vector<AudioStats>& videoStats);
    void onError(uint32_t errorCode, const std::string& errorMessage);
    void onHandsUpStatusChanged(const std::string& accountId, NEHandsUpStatus handsUpStatus);

public:
    int localAudioStatus() const;
    void setLocalAudioStatus(const int& localAudioStatus);

    QString activeSpeaker() const;
    void setActiveSpeaker(const QString& activeSpeaker);

    QString activeSpeakerNickname() const;
    void setActiveSpeakerNickname(const QString& activeSpeakerNickname);

    bool handsUpStatus() const;
    void setHandsUpStatus(bool handsUp);

signals:
    void localAudioStatusChanged();
    void activeSpeakerChanged();
    void activeSpeakerNicknameChanged();
    void remoteUserAudioStats(const QJsonArray& userStats);
    void userAudioStatusChanged(const QString& changedAccountId, NEMeeting::DeviceStatus deviceStatus);
    void error(int errorCode, const QString& errorMessage);
    void handsupStatusChanged(const QString& accountId, NEMeeting::HandsUpStatus status);
public slots:
    void muteLocalAudio(bool mute);
    void muteRemoteAudio(const QString& accountId, bool mute, bool bAllowOpenByself = true);

    void allowRemoteMemberHandsUp(const QString& accountId, bool bAllowHandsUp);
    void handsUpToSpeak(bool bHandsUp);
    void onUserAudioStatusChangedUI(const QString& changedAccountId, NEMeeting::DeviceStatus deviceStatus);
    void onActiveSpeakerChangedUI(const QString& accountId, const QString& nickname);
    void onHandsUpStatusChangedUI(const QString& accountId, NEMeeting::HandsUpStatus status);

private:
    INEInRoomAudioController* m_audioController = nullptr;
    NEMeeting::DeviceStatus m_localAudioStatus = NEMeeting::DEVICE_ENABLED;
    QString m_activeSpeaker;
    QString m_activeSpeakerNickname;
    bool m_bHandsUp = false;
};

Q_DECLARE_METATYPE(NEMeeting::HandsUpStatus)

#endif  // AUDIOMANAGER_H
