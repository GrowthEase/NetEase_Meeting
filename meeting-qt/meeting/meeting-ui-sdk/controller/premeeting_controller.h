// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef PREMEETING_CONTROLLER_H
#define PREMEETING_CONTROLLER_H

#include "base_type_defines.h"

class NEPreMeetingController {
public:
    using NEEmptyCallback = neroom::NECallback<>;
    using NEScheduleRoomItemCallback = neroom::NECallback<nem_sdk_interface::NEMeetingItem>;
    using NEEditRoomCallback = NEEmptyCallback;
    using NECancelRoomCallback = NEEmptyCallback;
    using NEGetRoomListCallback = neroom::NECallback<std::list<nem_sdk_interface::NEMeetingItem>>;

public:
    NEPreMeetingController();
    ~NEPreMeetingController();

    bool scheduleRoom(const nem_sdk_interface::NEMeetingItem& item, const NEScheduleRoomItemCallback& callback);
    bool editRoom(const nem_sdk_interface::NEMeetingItem& item, const NEEditRoomCallback& callback);
    bool cancelRoom(const int64_t& roomUniqueId, const NECancelRoomCallback& callback);
    bool getRoomItemByUniqueId(const int64_t& roomUniqueId, nem_sdk_interface::NEMeetingItem& item);
    bool getRoomList(std::list<nem_sdk_interface::NEMeetingItemStatus> status, const NEGetRoomListCallback& callback);

private:
    void initRoomProProperties(QJsonObject& object);

private:
    std::list<nem_sdk_interface::NEMeetingItem> m_meetingList;
};

#endif  // PREMEETING_CONTROLLER_H
