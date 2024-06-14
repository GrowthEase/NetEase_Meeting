// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _GetSecurityNoticeApi extends HttpApi<NEMeetingAppNoticeTips> {
  /// 时间戳
  final String time;

  _GetSecurityNoticeApi(this.time);

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/tips?time=$time';

  @override
  String get method => 'GET';

  @override
  NEMeetingAppNoticeTips result(Map map) {
    return NEMeetingAppNoticeTips.fromJson(map);
  }

  @override
  Map data() => {};
}
