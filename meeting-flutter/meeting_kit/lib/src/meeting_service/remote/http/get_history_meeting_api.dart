// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _GetHistoryMeetingApi extends HttpApi<NERemoteHistoryMeeting> {
  final int meetingId;

  _GetHistoryMeetingApi(this.meetingId);

  @override
  String path() {
    return 'scene/meeting/${ServiceRepository().appKey}/v1/meeting/history/$meetingId';
  }

  @override
  String get method => 'GET';

  @override
  NERemoteHistoryMeeting? result(Map? map) {
    if (map == null || map.isEmpty) return null;
    return NERemoteHistoryMeeting.fromJson(map);
  }

  @override
  Map data() {
    return {};
  }
}
