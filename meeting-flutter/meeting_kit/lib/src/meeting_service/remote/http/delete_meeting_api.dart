// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 删除预约会议
class _DeleteMeetingApi extends HttpApi<void> {
  int meetingId;

  _DeleteMeetingApi(this.meetingId);

  @override
  String path() => 'scene/meeting/v1/sdk/meeting/schedule/cancel';

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() => {'meetingId': meetingId};
}
