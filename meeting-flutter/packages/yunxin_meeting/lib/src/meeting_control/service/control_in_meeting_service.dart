// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControlInMeetingService {
  static final ControlInMeetingService _instance = ControlInMeetingService._();

  factory ControlInMeetingService() => _instance;

  ControlInMeetingService._();

  MeetingInfo? _meetingInfo;

  late int _startTime = 0;

  late int _duration = 0;
  late int _durationInitialTime = 0;

  void updateMeetingInfo(MeetingInfo meetingInfo, {InMeetingMemberInfo? selfMemberInfo, int startTime = 0, int duration = 0, int? durationInitialTime}) {
    _meetingInfo = meetingInfo;
    _startTime = startTime;
    _duration = duration;
    _durationInitialTime = durationInitialTime ?? DateTime.now().millisecondsSinceEpoch;
  }
  
  void resetMeetingInfo() {
    _meetingInfo = null;
    _startTime = 0;
    _duration = 0;
    _durationInitialTime = 0;
  }

  NEMeetingInfo? get currentMeetingInfo {

    final meetingInfo = _meetingInfo;
    if (meetingInfo != null) {
      return NEMeetingInfo(
        meetingUniqueId: meetingInfo.meetingUniqueId,
        meetingId: meetingInfo.meetingId,
        shortMeetingId: meetingInfo.shortMeetingId,
        sipCid: meetingInfo.sipCid,
        type: meetingInfo.type,
        subject: meetingInfo.subject,
        password: meetingInfo.password,
        startTime: _startTime,
        duration: _duration + DateTime.now().millisecondsSinceEpoch - _durationInitialTime,
        scheduleStartTime: meetingInfo.scheduleStartTime,
        scheduleEndTime: meetingInfo.scheduleEndTime,
        isHost: meetingInfo.hostAccountId == UserProfile.accountId,
        isLocked: JoinControlType.isLock(meetingInfo.joinControlType),
        hostUserId: meetingInfo.hostAccountId,
        userList: meetingInfo.members
            .map((e) => NEInMeetingUserInfo(e.accountId, e.nickName,e.tag))
            .toList(growable: false),
      );
    }
    return null;
  }
}
