// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 会议历史详情
class NERemoteHistoryMeetingDetail {
  /// 聊天室历史
  NEChatroomInfo? chatroomInfo;

  /// 小应用历史
  List<NEMeetingWebAppItem>? pluginInfoList;

  NERemoteHistoryMeetingDetail.fromJson(Map json) {
    if (json.containsKey('chatroom')) {
      chatroomInfo = NEChatroomInfo.fromJson(json['chatroom']);
    }
    if (json.containsKey('pluginInfoList')) {
      pluginInfoList = [];
      json['pluginInfoList'].forEach((v) {
        pluginInfoList!.add(NEMeetingWebAppItem.fromMap(v));
      });
    }
  }

  Map<String, dynamic> toJson() => {
        'chatroomInfo': chatroomInfo?.toJson(),
        'pluginInfoList': pluginInfoList?.map((e) => e.toMap()).toList(),
      };
}
