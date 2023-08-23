// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NEMeetingController_H
#define NEMeetingController_H

#include "base_type_defines.h"
#include "listeners/meeting_service_listener.h"
#include "meeting_controller_define.h"
#include "meeting_lifecycle_observer.h"
#include "modules/http/http_request.h"
#include "room_context_interface.h"

class NEMeetingController {
public:
    NEMeetingController();
    ~NEMeetingController();

    void setObserver(const std::shared_ptr<IMeetingLifecycleObserver>& observer) { m_observer = observer; }

    bool startRoom(const nem_sdk_interface::NEStartMeetingParams& param,
                   const NERoomOptions& option,
                   const neroom::NECallback<>& callback = neroom::NECallback<>());
    bool joinRoom(const nem_sdk_interface::NEJoinMeetingParams& param,
                  const NERoomOptions& option,
                  const neroom::NECallback<>& callback = neroom::NECallback<>(),
                  const QVariant& extraInfo = QVariant());
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
    std::shared_ptr<IMeetingLifecycleObserver> m_observer;
};

#endif  // NEMeetingController_H
