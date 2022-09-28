// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NEMeetingController_H
#define NEMeetingController_H

#include "base_type_defines.h"
#include "listeners/meeting_service_listener.h"
#include "modules/http/http_request.h"
#include "room_context_interface.h"

typedef struct tagNERoomParams {
    std::string roomId;
    std::string shortRoomId;
    std::string displayName;
    std::string tag;
    std::string password;
} NERoomParams;

typedef struct tagNERoomOptions {
    bool noVideo = true;
    bool noAudio = true;
    bool noAutoOpenWhiteboard = true;
    bool noCloudRecord = true;
    bool noChat = true;
    bool noSip = true;
} NERoomOptions;

typedef struct tagNERoomInfo {
    std::string roomId;
    std::string roomUniqueId;
    std::string shortRoomId;
    std::string subject;
    std::string password;
    std::string hostAccountId;
    std::string focusAccountId;
    std::string screenSharingUserId;
    std::string speakerUserId;
    std::string displayName;
    std::string sipId;
    std::string extraData;
    std::string liveUrl;
    std::string creatorUserId;
    std::string creatorUserName;
    bool audioAllMute = false;
    bool videoAllmute = false;
    bool allowSelfAudioOn = true;
    bool allowSelfVideoOn = true;
    bool isOpenChatroom = true;
    bool lock = false;
    bool enableLive = false;
    uint64_t scheduleTimeBegin = 0;
    uint64_t scheduleTimeEnd = 0;
    uint64_t startTime = 0;
    uint64_t remainingSeconds = 0;
    NEMeetingType type = unknownType;
} NERoomInfo;

class NEMeetingController {
public:
    NEMeetingController();
    ~NEMeetingController();

    bool startRoom(const nem_sdk_interface::NEStartMeetingParams& param,
                   const NERoomOptions& option,
                   const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool joinRoom(const nem_sdk_interface::NEJoinMeetingParams& param,
                  const NERoomOptions& option,
                  const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool leaveCurrentRoom(bool finish = false, const neroom::NECallback<>& callback = neroom::NECallback<>());
    NERoomInfo& getRoomInfo() { return m_roomInfo; }
    neroom::INERoomContext* getRoomContext();
    void initRoomInfo();

    void resetRoomContext();
    void updateDisplayName(const std::string& displayName);
    void updateFocusAccountId(const std::string& focusUserId);
    void updateHostAccountId(const std::string& hostAccountId);
    void updateIsLock(bool lock);
    void updateAudioAllMute(bool audioAllMute);
    void updateVideoAllmute(bool videoAllmute);
    void updateAllowSelfAudioOn(bool allowSelfAudioOn);
    void updateAllowSelfVideoOn(bool allowSelfVideoOn);
    NEInRoomServiceListener* getRoomServiceListener() const { return m_pRoomListener; }

private:
    void initRoomProperties(QJsonObject& object);

private:
    NEInRoomServiceListener* m_pRoomListener = nullptr;
    neroom::INERoomContext* m_pRoomContext = nullptr;
    NERoomInfo m_roomInfo;
};

#endif  // NEMeetingController_H
