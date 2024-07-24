// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 获取预约会议 信息
class _GetMeetingItemByNumApi extends HttpApi<NEMeetingItem> {
  String meetingNum;

  _GetMeetingItemByNumApi(this.meetingNum);

  @override
  String get method => 'GET';

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/info/$meetingNum';

  @override
  NEMeetingItem result(Map map) {
    return NEMeetingItem.fromJson(map);
  }

  @override
  Map data() => {};
}

class _GetMeetingItemByInviteCodeApi extends HttpApi<NEMeetingItem> {
  final String inviteCode;

  _GetMeetingItemByInviteCodeApi(this.inviteCode);

  @override
  String get method => 'GET';

  @override
  String path() => 'scene/meeting/v1/invite/info/$inviteCode';

  @override
  NEMeetingItem result(Map map) => NEMeetingItem.fromJson(map);

  @override
  Map data() => {};
}
