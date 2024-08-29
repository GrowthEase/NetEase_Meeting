// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class _MeetingSecurityCtrlApi extends HttpApi<void> {
  final Map<String, bool> body;

  final String roomUuid;

  _MeetingSecurityCtrlApi(this.body, this.roomUuid);

  @override
  String path() {
    return 'scene/apps/${ServiceRepository().appKey}/v1/rooms/$roomUuid/securityCtrl';
  }

  @override
  Map data() => body;

  @override
  void result(Map map) {}

  @override
  String get method => 'PUT';
}
