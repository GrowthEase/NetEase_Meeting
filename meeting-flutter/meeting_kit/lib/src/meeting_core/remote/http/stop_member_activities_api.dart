// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 获取等候室房间配置
class _StopMemberActivitiesApi extends HttpApi<Map<String, dynamic>> {
  final int meetingId;

  _StopMemberActivitiesApi(this.meetingId);

  @override
  String get method => 'POST';

  @override
  String path() =>
      '/scene/meeting/v1/stop_member_activities?meetingId=${meetingId}';

  @override
  void result(Map map) => null;

  @override
  Map data() => {};
}
