#ifndef _MEETING_MANAGER_DEFINE_H_
#define _MEETING_MANAGER_DEFINE_H_

#include "meeting-ui-sdk/modules/http/http_request.h"

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
    std::string roomArchiveId;
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
    std::string inviteUrl;
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

#endif  // _MEETING_MANAGER_DEFINE_H_
