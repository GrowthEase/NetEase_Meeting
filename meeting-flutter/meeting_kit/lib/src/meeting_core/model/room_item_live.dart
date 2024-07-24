// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 房间前直播信息
class NEPreRoomLiveInfo {
  final NERoomItemLive delegate;

  NEPreRoomLiveInfo() : delegate = NERoomItemLive();

  NEPreRoomLiveInfo.fromJson(Map? map)
      : delegate = NERoomItemLive.fromJson(map);

  /// 设置是否开启直播
  set enable(bool enable) => delegate.enable = enable;

  bool get enable => delegate.enable;

  /// 获取直播级别
  NEMeetingLiveAuthLevel get webAccessControlLevel =>
      LiveAuthLevelExtension.get(delegate.liveWebAccessControlLevel);

  /// 设置直播级别
  set webAccessControlLevel(NEMeetingLiveAuthLevel level) =>
      delegate.liveWebAccessControlLevel = level.index;

  String? get liveUrl => delegate.liveUrl;

  Map toJson() => {
        'enable': enable,
        'liveWebAccessControlLevel': webAccessControlLevel.value,
      };
}

/// 全量直播信息
///
class NERoomItemLive {
  /// 当前房间是否可以直播，在预约房间的时候需要打开允许直播开关
  bool enable = false;

  ///登录 web 直播页的鉴权级别，0：不需要鉴权，1：需要登录，2：需要登录并且账号要与直播应用绑定。不填的话表示不需要鉴权
  int liveWebAccessControlLevel = NEMeetingLiveAuthLevel.token.index;

  /// 直播标题
  String? title;

  /// 直播密码
  String? password;

  ///是否使用独立的直播聊天室，如果不使用独立的直播聊天室，那么使用会议的聊天室作为直播聊天室
  bool liveChatRoomIndependent = false;

  /// hls 拉流地址
  String? hlsPullUrl;

  /// http 拉流地址
  String? httpPullUrl;

  /// rtmp 拉流地址
  String? rtmpPullUrl;

  /// 直播地址
  String? liveUrl;

  /// 推流地址
  // String? _pushUrl;
  //
  // set pushUrl(String? pushUrl) {
  //   _pushUrl = pushUrl;
  // }
  //
  // String? get pushUrl => _pushUrl;

  /// 直播聊天室id
  String? chatRoomId;

  /// 直播uid列表
  List<int>? liveAVRoomUids;

  /// 视图模式
  int? liveLayout;

  /// 直播web聊天室是否可用
  bool liveChatRoomEnable = true;

  /// 会议id
  String? roomId;

  /// 直播状态
  NERoomItemLiveState? state;

  /// 任务id
  // String? _taskId;
  //
  // set taskId(String? taskId) {
  //   _taskId = taskId;
  // }
  //
  // String? get taskId => _taskId;

  Map toJson() => {
        'enable': enable,
        'liveWebAccessControlLevel': liveWebAccessControlLevel,
        if (hlsPullUrl != null) 'hlsPullUrl': hlsPullUrl,
        if (httpPullUrl != null) 'httpPullUrl': httpPullUrl,
        if (rtmpPullUrl != null) 'rtmpPullUrl': rtmpPullUrl,
        if (liveUrl != null) 'liveUrl': liveUrl,
        // if (_pushUrl != null) 'pushUrl': _pushUrl,
        if (chatRoomId != null) 'chatRoomId': chatRoomId,
        if (liveAVRoomUids != null) 'liveAVRoomUids': liveAVRoomUids,
        'liveChatRoomEnable': liveChatRoomEnable,
        if (roomId != null) 'meetingId': roomId,
        if (state != null) 'state': state?.index,
        // if (_taskId != null) 'taskId': _taskId,
        if (title != null) 'title': title,
        if (password != null) 'password': password,
        'liveChatRoomIndependent': liveChatRoomIndependent,
        'liveLayout': liveLayout ?? LiveLayoutType.none,
      };

  NERoomItemLive();

  NERoomItemLive.fromJson(Map<dynamic, dynamic>? map) {
    if (map != null) {
      enable = map['enable'] as bool;
      liveWebAccessControlLevel = (map['liveWebAccessControlLevel'] ??
          NEMeetingLiveAuthLevel.token.index) as int;
      hlsPullUrl = map['hlsPullUrl'] as String?;
      httpPullUrl = map['httpPullUrl'] as String?;
      rtmpPullUrl = map['rtmpPullUrl'] as String?;
      liveUrl = map['liveUrl'] as String?;
      chatRoomId = map['chatRoomId'] as String?;
      liveAVRoomUids = (map['liveAVRoomUids'] as List?)?.cast<int>();
      liveChatRoomEnable = (map['liveChatRoomEnable'] ?? true) as bool;
      roomId = map['meetingId'] as String?;
      var stateValue = (map['state'] ?? 0) as int;
      state = stateValue >= 0 && stateValue < NERoomItemLiveState.values.length
          ? NERoomItemLiveState.values[stateValue]
          : NERoomItemLiveState.invalid;
      title = map['title'] as String?;
      password = map['password'] as String?;
      liveChatRoomIndependent =
          (map['liveChatRoomIndependent'] ?? false) as bool;
      liveLayout = (map['liveLayout'] ?? LiveLayoutType.none) as int;
    }
  }

  NERoomItemLive copy() {
    final copy = NERoomItemLive();
    copy
      ..enable = enable
      ..liveWebAccessControlLevel = liveWebAccessControlLevel
      ..hlsPullUrl = hlsPullUrl
      ..httpPullUrl = httpPullUrl
      ..rtmpPullUrl = rtmpPullUrl
      ..liveUrl = liveUrl
      // .._pushUrl = _pushUrl
      ..chatRoomId = chatRoomId
      ..liveAVRoomUids = liveAVRoomUids
      ..liveChatRoomEnable = liveChatRoomEnable
      ..roomId = roomId
      ..state = state
      // .._taskId = _taskId
      ..title = title
      ..password = password
      ..liveChatRoomIndependent = liveChatRoomIndependent
      ..liveLayout = liveLayout;
    return copy;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NERoomItemLive &&
          runtimeType == other.runtimeType &&
          enable == other.enable &&
          liveWebAccessControlLevel == other.liveWebAccessControlLevel &&
          title == other.title &&
          password == other.password &&
          hlsPullUrl == other.hlsPullUrl &&
          httpPullUrl == other.httpPullUrl &&
          rtmpPullUrl == other.rtmpPullUrl &&
          liveUrl == other.liveUrl &&
          chatRoomId == other.chatRoomId &&
          liveAVRoomUids == other.liveAVRoomUids &&
          liveLayout == other.liveLayout &&
          liveChatRoomEnable == other.liveChatRoomEnable &&
          state == other.state;

  @override
  int get hashCode =>
      enable.hashCode ^
      liveWebAccessControlLevel.hashCode ^
      title.hashCode ^
      password.hashCode ^
      hlsPullUrl.hashCode ^
      httpPullUrl.hashCode ^
      rtmpPullUrl.hashCode ^
      liveUrl.hashCode ^
      chatRoomId.hashCode ^
      liveAVRoomUids.hashCode ^
      liveLayout.hashCode ^
      liveChatRoomEnable.hashCode ^
      state.hashCode;
}
