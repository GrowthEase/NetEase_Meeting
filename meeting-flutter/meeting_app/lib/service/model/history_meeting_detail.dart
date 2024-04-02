// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/model/chatroom_info.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

class HistoryMeetingDetail {
  ChatroomInfo? chatroomInfo;
  List<NEMeetingWebAppItem>? pluginInfoList;

  HistoryMeetingDetail.fromJson(Map json) {
    if (json.containsKey('chatroom')) {
      chatroomInfo = ChatroomInfo.fromJson(json['chatroom']);
    }
    if (json.containsKey('pluginInfoList')) {
      pluginInfoList = [];
      json['pluginInfoList'].forEach((v) {
        pluginInfoList!.add(NEMeetingWebAppItem.fromMap(v));
      });
    }
  }
}
