// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

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
