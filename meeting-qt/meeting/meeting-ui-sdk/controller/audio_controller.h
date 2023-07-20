// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef AUDIO_CONTROLLER_H
#define AUDIO_CONTROLLER_H

#include "controller/rtc_ctrl_interface.h"

using namespace neroom;

class NEMeetingAudioController {
public:
    NEMeetingAudioController();
    ~NEMeetingAudioController();

    bool muteMyAudio(bool mute, neroom::NECallback<> callback);
    bool muteAllParticipantsAudio(bool allowUnmuteSelf, neroom::NECallback<> callback);
    bool unmuteAllParticipantsAudio(neroom::NECallback<> callback);
    bool muteParticipantAudio(const std::string& userId, bool mute, neroom::NECallback<> callback);
    bool subscribeRemoteAudioStream(const std::vector<std::string>& userIdList);
    bool unsubscribeRemoteAudioStream(const std::vector<std::string>& userIdList);
    bool subscribeAllRemoteAudioStream();
    bool unsubscribeAllRemoteAudioStream();
    bool enableAudioVolumeIndication(bool enable, int interval);
    bool enumPlayoutDevices(std::vector<NEDeviceBaseInfo>& deviceList);
    bool enumRecordDevices(std::vector<NEDeviceBaseInfo>& deviceList);
    bool getDefaultPlayoutDevice(NEDeviceBaseInfo& deviceInfo);
    bool getDefaultRecordDevice(NEDeviceBaseInfo& deviceInfo);
    bool getSelectedPlayoutDevice(std::string& deviceId);
    bool getSelectedRecordDevice(std::string& deviceId);
    bool selectPlayoutDevice(const std::string& deviceId);
    bool selectRecordDevice(const std::string& deviceId);
    uint32_t getRecordDeviceVolume();
    bool setRecordDeviceVolume(uint32_t volume);
    uint32_t getPlayoutDeviceVolume();
    bool setPlayoutDeviceVolume(uint32_t volume);
    bool startRecordDeviceTest();
    bool stopRecordDeviceTest();
    bool startPlayoutDeviceTest(const std::string& mediaFile);
    bool stopPlayoutDeviceTest();
    bool adjustRecordingSignalVolume(uint32_t volume);
    bool adjustPlaybackSignalVolume(uint32_t volume);
    bool setPlayoutDeviceMute(bool mute);
    virtual bool getPlayoutDeviceMute();
    bool setRecordDeviceMute(bool mute);
    virtual bool getRecordDeviceMute();
    int enumPlayoutDevices();
    int enumRecordDevices();
    bool startAudioDump();
    bool stopAudioDump();
    bool enableAudioAI(bool enable);
    bool enableAudioVolumeAutoAdjust(bool enable);
    /*    bool setAudioProfile(NEAudioProfileType profileType, NEAudioScenarioType scenarioType) */;
    bool enableAudioEchoCancellation(bool enable);
    //    bool setAudioDeviceAutoSelectType(NEAudioDeviceAutoSelectType type) ;
    // bool setExternalAudioSource(bool enabled, int sample_rate, int channels) ;
    // bool pushExternalAudioFrame(const NEAudioFrame& frame) ;
};

#endif  // AUDIO_CONTROLLER_H
