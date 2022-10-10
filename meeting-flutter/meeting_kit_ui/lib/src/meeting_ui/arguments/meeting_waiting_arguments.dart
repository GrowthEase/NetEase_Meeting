// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingWaitingArguments {
  MeetingWaitingArguments.verifyPassword(
    this.initWaitCode,
    this.initWaitMsg,
    this.joinParams,
    this.joinOpts,
  ) {
    waitingType = _MeetingWaitingType.verifyPassword;
  }

  int initWaitCode;

  String? initWaitMsg;

  final NEJoinMeetingParams joinParams;

  final NEJoinMeetingOptions joinOpts;

  late _MeetingWaitingType waitingType;
}

enum _MeetingWaitingType {
  /// need verify password to join
  verifyPassword,
}
