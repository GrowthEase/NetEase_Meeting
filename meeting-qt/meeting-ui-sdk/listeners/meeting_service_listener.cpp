/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "meeting_service_listener.h"
#include "manager/device_manager.h"
#include "manager/live_manager.h"
#include "manager/meeting/audio_manager.h"
#include "manager/meeting/members_manager.h"
#include "manager/meeting/share_manager.h"
#include "manager/meeting/video_manager.h"
#include "manager/meeting/whiteboard_manager.h"
#include "manager/meeting_manager.h"

NEInRoomServiceListener::NEInRoomServiceListener() {}

NEInRoomServiceListener::~NEInRoomServiceListener() {}

void NEInRoomServiceListener::onRoomUserJoin(const std::string& userId) {
    MembersManager::getInstance()->onAfterUserJoined(userId, true);
}

void NEInRoomServiceListener::onRoomUserReadyLeave(const std::string& userId, uint32_t memberIndex) {
    MembersManager::getInstance()->onBeforeUserLeave(userId, memberIndex);
}

void NEInRoomServiceListener::onRoomUserLeave(const std::string& userId) {
    MembersManager::getInstance()->onAfterUserLeft(userId, true);
}

void NEInRoomServiceListener::onRoomUserNameChanged(const std::string& userId, const std::string& name) {
    MembersManager::getInstance()->onMemberNicknameChanged(userId, name);
}

void NEInRoomServiceListener::onRoomHostChanged(std::list<std::string> userIds) {
    if (userIds.size() <= 0) {
        return;
    }

    std::string userId = userIds.front();
    MembersManager::getInstance()->onHostChanged(userId);
}

void NEInRoomServiceListener::onRoomActiveSpeakerVideoUserChanged(const std::string& userId, const std::string& displayName) {
    AudioManager::getInstance()->onActiveSpeakerChanged(userId, displayName);
}

void NEInRoomServiceListener::onRoomUserVideoPinStatusChanged(const std::string& userId, bool isPinned) {
    VideoManager::getInstance()->onFocusVideoChanged(userId, isPinned);
}

void NEInRoomServiceListener::onRoomUserAudioStatusChanged(const std::string& userId, NEAudioStatus status) {
    AudioManager::getInstance()->onUserAudioStatusChanged(userId, (NEMeeting::DeviceStatus)status);
}

void NEInRoomServiceListener::onRoomUserVideoStatusChanged(const std::string& userId, NEVideoStatus status) {
    VideoManager::getInstance()->onUserVideoStatusChanged(userId, (NEMeeting::DeviceStatus)status);
}

void NEInRoomServiceListener::onRoomSilentModeChanged(bool inSilentMode) {
    MeetingManager::getInstance()->onRoomMuteStatusChanged(inSilentMode);
}

void NEInRoomServiceListener::onRoomDurationChanged(const uint64_t& duration) {
    MeetingManager::getInstance()->onRoomDurationChanged(duration);
}

void NEInRoomServiceListener::onRoomStartTimeChanged(uint64_t startTime) {
    MeetingManager::getInstance()->onRoomStartTimeChanged(startTime);
}

void NEInRoomServiceListener::onRoomLockStatusChanged(bool isLock) {
    MeetingManager::getInstance()->onRoomLockStatusChanged(isLock);
}

void NEInRoomServiceListener::onRoomRaiseHandStatusChanged(const std::string& userId, NERaiseHandDetail raiseHandDetail) {
    AudioManager::getInstance()->onHandsUpStatusChanged(userId, raiseHandDetail.status);
}

void NEInRoomServiceListener::onRoomMuteNeedHandsUpChanged(bool bNeedHandsUp) {
    MeetingManager::getInstance()->onRoomMuteNeedHandsUpChanged(bNeedHandsUp);
}

void NEInRoomServiceListener::onRoomLiveStreamStatusChanged(int liveState) {
    LiveManager::getInstance()->onLiveStreamStatusChanged(liveState);
}

void NEInRoomServiceListener::onReceivedUserVideoFrame(const std::string& userId, const VideoFrame& frame, bool bSub) {
    VideoManager::getInstance()->onReceivedUserVideoFrame(userId, frame, bSub);
}

void NEInRoomServiceListener::onPlayoutDeviceChanged(const std::string& deviceId, NEDeviceState deviceState) {
    DeviceManager::getInstance()->onPlayoutDeviceChanged(deviceId, deviceState);
}

void NEInRoomServiceListener::onRecordDeviceChanged(const std::string& deviceId, NEDeviceState deviceState) {
    DeviceManager::getInstance()->onRecordDeviceChanged(deviceId, deviceState);
}

void NEInRoomServiceListener::onDefaultPlayoutDeviceChanged(const std::string& deviceId) {
    DeviceManager::getInstance()->onDefualtPlayoutDeviceChanged(deviceId);
}

void NEInRoomServiceListener::onDefaultRecordDeviceChanged(const std::string& deviceId) {
    DeviceManager::getInstance()->onDefualtRecordDeviceChanged(deviceId);
}

void NEInRoomServiceListener::onCameraDeviceChanged(const std::string& deviceId, NEDeviceState deviceState) {
    DeviceManager::getInstance()->onCameraDeviceChanged(deviceId, deviceState);
}

void NEInRoomServiceListener::onLocalAudioVolumeIndication(int volume) {
    DeviceManager::getInstance()->onLocalVolumeIndication(volume);
}

void NEInRoomServiceListener::onRoomRemoteAudioVolumeIndication(std::list<NERoomUserAudioVolumeInfo> volumeList, int totalVolume) {
    // do nonthing
}

void NEInRoomServiceListener::onRoomUserScreenShareStatusChanged(const std::string& usdrId, NERoomScreenShareStatus status) {
    ShareManager::getInstance()->onRoomUserScreenShareStatusChanged(usdrId, status);
}

void NEInRoomServiceListener::onRoomUserWhiteboardShareStatusChanged(const std::string& userId, NERoomWhiteboardShareStatus status) {
    WhiteboardManager::getInstance()->onRoomUserWhiteboardShareStatusChanged(userId, status);
}

void NEInRoomServiceListener::onRoomUserWhiteBoardInteractionStatusChanged(const std::string& userId, bool enable) {
    WhiteboardManager::getInstance()->onRoomUserWhiteboardDrawEnableStatusChanged(userId, enable);
}
