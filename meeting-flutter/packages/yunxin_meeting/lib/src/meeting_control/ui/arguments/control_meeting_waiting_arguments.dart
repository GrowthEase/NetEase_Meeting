// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControlMeetingWaitingArguments extends ControllerMeetingWaitingArguments {
  String? pairId;
  TVStatus? tvStatus;

  ControlMeetingWaitingArguments.verifyPassword(int initWaitCode,
      {required String meetingId,
        String? displayName,
        String? password,
        ControllerMeetingOptions? options,
        int? audioAllMute,
        this.pairId,
        this.tvStatus,})
      : super.verifyPassword(initWaitCode,
      meetingId: meetingId,
      displayName: displayName,
      password: password,
      audioAllMute: audioAllMute,
      options: options);
}
