// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 获取预约会议参会者列表
class _GetScheduledMembersApi extends HttpApi<List<NEScheduledMember>> {
  String meetingNum;

  _GetScheduledMembersApi(this.meetingNum);

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/info/$meetingNum/scheduled-members';

  @override
  String get method => 'GET';

  @override
  List<NEScheduledMember> parseResult(dynamic data) {
    return (data as List).map((e) => NEScheduledMember.fromJson(e)).toList();
  }

  @override
  Map data() => {};
}
