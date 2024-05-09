// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 根据meetingId获取会议信息
class _GetMeetingItemByIdApi extends HttpApi<NEMeetingItem> {
  int meetingId;

  _GetMeetingItemByIdApi(this.meetingId);

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/info/meeting/$meetingId';

  @override
  String get method => 'GET';

  @override
  NEMeetingItem parseResult(dynamic data) {
    return NEMeetingItem.fromJson(data);
  }

  @override
  Map data() => {};
}
