/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEINROOMSERVICELISTENER_H
#define NEINROOMSERVICELISTENER_H

#include <QObject>

#include "room_service_listener.h"

using namespace neroom;

class NEInRoomServiceListener : public INEInRoomServiceListener {
public:
    NEInRoomServiceListener();
    ~NEInRoomServiceListener();

    virtual void onRoomUserJoin(const std::string& userId) override;
    virtual void onRoomUserReadyLeave(const std::string& userId, uint32_t memberIndex) override;
    virtual void onRoomUserLeave(const std::string& userId) override;
    virtual void onRoomUserNameChanged(const std::string& userId, const std::string& name) override;
    virtual void onRoomHostChanged(std::list<std::string> userIds) override;
    virtual void onRoomActiveSpeakerVideoUserChanged(const std::string& userId, const std::string& displayName) override;
    virtual void onRoomUserVideoPinStatusChanged(const std::string& userId, bool isPinned) override;
    virtual void onRoomUserAudioStatusChanged(const std::string& userId, NEAudioStatus status) override;
    virtual void onRoomUserVideoStatusChanged(const std::string& userId, NEVideoStatus status) override;
    virtual void onRoomSilentModeChanged(bool inSilentMode) override;
    virtual void onRoomDurationChanged(const uint64_t& duration) override;
    virtual void onRoomStartTimeChanged(uint64_t startTime) override;
    virtual void onRoomLockStatusChanged(bool isLock) override;
    virtual void onRoomRaiseHandStatusChanged(const std::string& userId, NERaiseHandDetail raiseHandDetail) override;
    virtual void onRoomMuteNeedHandsUpChanged(bool bNeedHandsUp) override;
    virtual void onRoomLiveStreamStatusChanged(int liveState) override;
    virtual void onReceivedUserVideoFrame(const std::string& userId, const VideoFrame& frame, bool bSub) override;

    virtual void onPlayoutDeviceChanged(const std::string& deviceId, NEDeviceState deviceState) override;
    virtual void onRecordDeviceChanged(const std::string& deviceId, NEDeviceState deviceState) override;
    virtual void onDefaultPlayoutDeviceChanged(const std::string& deviceId) override;
    virtual void onDefaultRecordDeviceChanged(const std::string& deviceId) override;
    virtual void onCameraDeviceChanged(const std::string& deviceId, NEDeviceState deviceState) override;

    virtual void onLocalAudioVolumeIndication(int volume) override;
    virtual void onRoomRemoteAudioVolumeIndication(std::list<NERoomUserAudioVolumeInfo> volumeList, int totalVolume) override;

    virtual void onRoomUserScreenShareStatusChanged(const std::string& userId, NERoomScreenShareStatus status) override;

    virtual void onRoomUserWhiteboardShareStatusChanged(const std::string& userId, NERoomWhiteboardShareStatus status) override;

    virtual void onRoomUserWhiteBoardInteractionStatusChanged(const std::string& userId, bool enable) override;
};

#endif  // NEINROOMSERVICELISTENER_H
