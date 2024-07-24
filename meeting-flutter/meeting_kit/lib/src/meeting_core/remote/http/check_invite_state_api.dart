// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class _CheckInviteStateApi extends HttpApi<bool> {
  int meetingId;

  _CheckInviteStateApi(this.meetingId);

  @override
  String get method => 'GET';

  @override
  String path() => 'scene/meeting/v1/meeting/$meetingId/invite-state';

  @override
  bool result(Map map) {
    return map['inviteValid'] as bool? ?? false;
  }

  @override
  Object? data() {
    return null;
  }
}
