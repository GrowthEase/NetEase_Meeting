// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NEMeetingUserController_H
#define NEMeetingUserController_H

#include "base_type_defines.h"
using namespace neroom;

class NEMeetingUserController {
public:
    NEMeetingUserController();
    ~NEMeetingUserController();

    bool changeMyName(const std::string& name, const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool makeHost(const std::string& userId, const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool removeUser(const std::string& userId, const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool raiseMyHand(bool bRaise, const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool lowerHand(const std::string& userId, const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool lowerAllHands(const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool muteParticipantAudioAndVideo(const std::string& userId, bool mute, const neroom::NECallback<>& callback = neroom::NECallback<>());
};

#endif  // NEMeetingUserController_H
