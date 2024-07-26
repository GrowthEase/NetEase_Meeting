// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 取消预约会议
class _CancelMeetingApi extends HttpApi<void> {
  int meetingId;
  bool cancelRecurringMeeting;

  _CancelMeetingApi(this.meetingId, this.cancelRecurringMeeting);

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/cancel/$meetingId?cancelRecurringMeeting=$cancelRecurringMeeting';

  @override
  String get method => 'DELETE';

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() => {};
}
