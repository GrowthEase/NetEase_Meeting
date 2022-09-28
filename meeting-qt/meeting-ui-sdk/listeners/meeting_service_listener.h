// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NEINROOMSERVICELISTENER_H
#define NEINROOMSERVICELISTENER_H

#include <QObject>

#include "room_listener.h"
using namespace neroom;

/**
 * @brief 视频帧数据
 */
typedef struct tagVideoFrame {
    uint32_t type;
    uint32_t width;
    uint32_t height;
    uint32_t count;
    uint32_t rotation;
    uint32_t* offset;
    uint32_t* stride;
    void* data;
} VideoFrame;

/**
 * @brief 音频统计数据
 */
typedef struct tagNEAudioStats {
    std::string userUuid; /**< 用户Id */
    uint32_t bitRate;     /**< （上次统计后）发送/接收码率(Kbps) */
    uint32_t lossRate;    /**< 特定时间内的音频丢包率 (%) */
    uint32_t volume;      /**< 音量，范围为 0（最低）- 100（最高） */
} NEAudioStats;

class NEInRoomServiceListener : public INERoomListener, public INERoomRtcStatsListener {
public:
    NEInRoomServiceListener();
    ~NEInRoomServiceListener();

    virtual void onMemberRoleChanged(const std::string& userUuid, const std::string& beforeRole, const std::string& afterRole) override;
    virtual void onMemberJoinRoom(const std::vector<SharedMemberPtr>& members) override;
    virtual void onMemberLeaveRoom(const std::vector<SharedMemberPtr>& members) override;
    virtual void onRoomEnded(NERoomEndReason reason) override;
    virtual void onMemberJoinRtcChannel(const std::vector<SharedMemberPtr>& members) override;
    virtual void onMemberLeaveRtcChannel(const std::vector<SharedMemberPtr>& members) override;
    virtual void onMemberJoinChatroom(const std::vector<SharedMemberPtr>& members) override;
    virtual void onMemberLeaveChatroom(const std::vector<SharedMemberPtr>& members) override;
    virtual void onMemberAudioMuteChanged(const SharedMemberPtr& member, bool mute, const SharedMemberPtr& trigger) override;
    virtual void onMemberVideoMuteChanged(const SharedMemberPtr& member, bool mute, const SharedMemberPtr& trigger) override;
    virtual void onMemberScreenShareStateChanged(const SharedMemberPtr& member, bool isSharing, const SharedMemberPtr& trigger) override;
    virtual void onMemberWhiteboardStateChanged(const SharedMemberPtr& member, bool isSharing, const SharedMemberPtr& trigger) override;
    virtual void onReceiveChatroomMessages(const std::vector<SharedChatMessagePtr>& messages) override;
    virtual void onChatroomMessageAttachmentProgress(const std::string& messageUuid, int64_t transferred, int64_t total) override;
    virtual void onRtcChannelError(int code, const std::string& msg) override;
    virtual void onMemberPropertiesChanged(const std::string& userUuid, const std::map<std::string, std::string>& properties) override;
    virtual void onRoomPropertiesChanged(const std::map<std::string, std::string>& properties) override;
    virtual void onVideoFrameData(const std::string& userUuid,
                                  bool bSubVideo,
                                  void* data,
                                  uint32_t type,
                                  uint32_t width,
                                  uint32_t height,
                                  uint32_t count,
                                  uint32_t offset[4],
                                  uint32_t stride[4],
                                  uint32_t rotation) override;
    virtual void onRoomLiveStateChanged(NERoomLiveState state) override;
    virtual void onMemberNameChanged(const SharedMemberPtr& member, const std::string& name) override;
    virtual void onRoomLockStateChanged(bool locked) override;
    virtual void onRtcVirtualBackgroundSourceEnabled(bool enabled, NERoomVirtualBackgroundSourceStateReason reason) override;

    virtual void onLocalAudioStats(const std::vector<NERoomRtcAudioSendStats>& stats) override;
    virtual void onRemoteAudioStats(const std::map<std::string, std::vector<NERoomRtcAudioRecvStats>>& stats) override;
    virtual void onRtcVideoStats(const std::vector<NEVideoStats>& stats) override;
    virtual void onNetworkQuality(const std::vector<NERoomRtcNetworkQualityInfo>& quality) override;
    virtual void onRtcUserVideoStart(const std::string& userUuid) override;
    virtual void onRtcUserVideoStop(const std::string& userUuid) override;

    virtual void onCameraDeviceChanged(const std::string& deviceId, bool bAdd) override;
    virtual void onPlayoutDeviceChanged(const std::string& deviceId, bool bAdd) override;
    virtual void onRecordDeviceChanged(const std::string& deviceId, bool bAdd) override;
    virtual void onDefaultPlayoutDeviceChanged(const std::string& deviceId) override;
    virtual void onDefaultRecordDeviceChanged(const std::string& deviceId) override;
    virtual void onRoomConnectStateChanged(NEConnectState state) override;

    virtual void onLocalAudioVolumeIndication(int volume) override;
    virtual void onRtcRemoteAudioVolumeIndication(std::list<NEMemberVolumeInfo> volumeList, int totalVolume) override;
    virtual void onRtcDisconnect() override;
    virtual void onMemberPropertiesDeleted(const std::string& userUuid, const std::map<std::string, std::string>& properties) override;
    virtual void onRoomPropertiesDeleted(const std::map<std::string, std::string>& properties) override;

private:
    void activeSpeakerVideoUser(const std::vector<NEAudioStats>& stats);
    uint64_t m_nActiveSwitchTimestamp = 0;
    std::string m_activeSpeaker;
};

#endif  // NEINROOMSERVICELISTENER_H
