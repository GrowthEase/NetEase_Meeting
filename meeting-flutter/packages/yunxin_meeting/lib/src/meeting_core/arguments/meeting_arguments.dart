// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 会议页面参数
class MeetingArguments extends MeetingBaseArguments {
  /// join info
  final JoinRoomInfo joinmeetingInfo;

  late int requestTimeStamp;

  MeetingArguments(
      {required this.joinmeetingInfo,
        String? displayName,
      String? password,
      MeetingOptions? options})
      : super(
            meetingId: joinmeetingInfo.meetingId,
            displayName: displayName,
            password: password,
            options: options) {
    requestTimeStamp = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String get meetingId => joinmeetingInfo.meetingId;

  int get createTime => joinmeetingInfo.createTime;
}
