// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 预约直播
class NEMeetingItemLive {
  /// 当前房间是否可以直播，在预约房间的时候需要打开允许直播开关
  bool enable = false;

  ///登录 web 直播页的鉴权级别，0：不需要鉴权，1：需要登录，2：需要登录并且账号要与直播应用绑定。不填的话表示不需要鉴权
  NEMeetingLiveAuthLevel? liveWebAccessControlLevel =
      NEMeetingLiveAuthLevel.token;

  /// 直播地址
  String? liveUrl;

  /// hls 拉流地址
  String? hlsPullUrl;

  /// http 拉流地址
  String? httpPullUrl;

  /// rtmp 拉流地址
  String? rtmpPullUrl;

  /// 推流地址
  String? pushUrl;

  /// 直播聊天室id
  String? chatRoomId;

  /// 直播uid列表
  List<String>? liveAVRoomUids;

  /// 直播web聊天室是否可用
  bool? liveChatRoomEnable;

  /// 会议id
  String? meetingNum;

  /// 直播状态
  NEMeetingItemLiveStatus state = NEMeetingItemLiveStatus.invalid;

  /// 任务id
  String? taskId;

  /// 直播标题
  String? title;

  /// 是否使用独立的直播聊天室，如果不使用独立的直播聊天室，那么使用会议的聊天室作为直播聊天室
  bool? liveChatRoomIndependent;

  Map toJson() => {
        'enable': enable,
        'liveWebAccessControlLevel': liveWebAccessControlLevel?.value,
        'liveUrl': liveUrl,
        'hlsPullUrl': hlsPullUrl,
        'httpPullUrl': httpPullUrl,
        'rtmpPullUrl': rtmpPullUrl,
        'pushUrl': pushUrl,
        'chatRoomId': chatRoomId,
        'liveAVRoomUids': liveAVRoomUids,
        'liveChatRoomEnable': liveChatRoomEnable,
        'meetingNum': meetingNum,
        'state': state.index,
        'taskId': taskId,
        'title': title,
        'liveChatRoomIndependent': liveChatRoomIndependent,
      };

  NEMeetingItemLive();

  NEMeetingItemLive.fromJson(Map<dynamic, dynamic>? map) {
    if (map != null) {
      enable = map['enable'] as bool? ?? false;
      liveWebAccessControlLevel = LiveAuthLevelExtension.get(
          map['liveWebAccessControlLevel'] as int? ?? 0);
      liveUrl = map['liveUrl'] as String?;
      hlsPullUrl = map['hlsPullUrl'] as String?;
      httpPullUrl = map['httpPullUrl'] as String?;
      rtmpPullUrl = map['rtmpPullUrl'] as String?;
      pushUrl = map['pushUrl'] as String?;
      chatRoomId = map['chatRoomId'] as String?;
      liveAVRoomUids =
          (map['liveAVRoomUids'] as List?)?.map((e) => e as String).toList();
      liveChatRoomEnable = map['liveChatRoomEnable'] as bool?;
      meetingNum = map['meetingNum'] as String?;
      state = NEMeetingItemLiveStatus.values[map['state'] as int? ?? 0];
      taskId = map['taskId'] as String?;
      title = map['title'] as String?;
      liveChatRoomIndependent = map['liveChatRoomIndependent'] as bool?;
    }
  }
}
