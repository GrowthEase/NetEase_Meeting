// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 预约直播
class NEMeetingItemLive {
  /// 当前房间是否可以直播，在预约房间的时候需要打开允许直播开关
  bool enable = false;

  ///登录 web 直播页的鉴权级别，0：不需要鉴权，1：需要登录，2：需要登录并且账号要与直播应用绑定。不填的话表示不需要鉴权
  int? liveWebAccessControlLevel = NELiveAuthLevel.token.index;

  /// 直播地址
  String? liveUrl;

  Map toJson() => {
        'enable': enable,
        'liveUrl': liveUrl,
        'liveWebAccessControlLevel': liveWebAccessControlLevel
      };

  NEMeetingItemLive();

  NEMeetingItemLive.fromJson(Map<dynamic, dynamic>? map) {
    enable = (map?['enable'] ?? false) as bool;
    liveWebAccessControlLevel = map?['liveWebAccessControlLevel'] as int?;
  }
}
