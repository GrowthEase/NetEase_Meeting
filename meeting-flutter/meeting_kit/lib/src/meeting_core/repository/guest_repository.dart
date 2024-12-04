// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

final class GuestRepository with _AloggerMixin {
  static final GuestRepository _instance = GuestRepository._();

  factory GuestRepository() {
    return _instance;
  }

  GuestRepository._();

  Future<NEResult<MeetingInfo>> getMeetingInfoForGuestJoin(
    String meetingNum, {
    String? phoneNum,
    String? smsCode,
  }) {
    return HttpApiHelper.execute(
      _GetMeetingInfoForGuestJoinApi(
        meetingNum,
        phoneNum: phoneNum,
        smsCode: smsCode,
      ),
    );
  }

  Future<VoidResult> requestSmsCodeForVerify(
      String meetingNum, String phoneNumber) {
    return HttpApiHelper.execute(
        _GetMobileCheckCodeForGuestJoinApi(meetingNum, phoneNumber));
  }
}
