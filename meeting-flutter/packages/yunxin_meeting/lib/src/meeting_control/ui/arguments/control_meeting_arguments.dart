// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControlMeetingArguments extends ControllerMeetingBaseArguments {
  String? pairId;
  TVStatus? tvStatus;
  String? fromRoute;

  ValueNotifier<int>? _showTypeListenable;

  final ControlJoinMeetingInfo meetingInfo;

  ControlMeetingArguments({
    required this.meetingInfo,
    ControllerMeetingOptions? options,
    this.pairId,
    this.tvStatus,
    this.fromRoute,
  }) : super(meetingId: meetingInfo.meetingId, options: options);

  int get avRoomUid => meetingInfo.avRoomUid;

  ValueListenable<int>? get showTypeListenable {
    _showTypeListenable ??= ValueNotifier(showType);
    return _showTypeListenable;
  }

  set showType(int value) {
    _showTypeListenable?.value = value;
    tvStatus!.showType = value;
  }

  int get showType => tvStatus!.showType;

}
