// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class MeetingWaitingArguments extends MeetingBaseArguments {
  MeetingWaitingArguments.verifyPassword(this.initWaitCode,
      {this.initWaitMsg,
      required String meetingId,
      String? displayName,
      String? password,
      int? audioAllMute,
      MeetingOptions? options})
      : super(
            meetingId: meetingId,
            displayName: displayName,
            password: password,
            options: options) {
    waitingType = _MeetingWaitingType.verifyPassword;
  }

  int initWaitCode;

  String? initWaitMsg;

  late _MeetingWaitingType waitingType;
}

enum _MeetingWaitingType {
  /// need verify password to join
  verifyPassword,
}
