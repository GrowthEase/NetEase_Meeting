// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 登录/非登录 均可调用，获取会议信息
class _GetMeetingInfoForGuestJoinApi extends HttpApi<MeetingInfo> {
  final String meetingNum;
  final String? phoneNum;
  final String? smsCode;

  _GetMeetingInfoForGuestJoinApi(
    this.meetingNum, {
    this.phoneNum,
    this.smsCode,
  });

  @override
  String get method => 'GET';

  @override
  String path() {
    var queries = '';
    if (phoneNum != null && smsCode != null) {
      queries = '?phoneNum=${phoneNum}&verifyCode=${smsCode}';
    }
    return 'scene/meeting/v2/meetingInfoForGuest/$meetingNum${queries}';
  }

  @override
  MeetingInfo result(Map map) => MeetingInfo.fromMap(map);

  @override
  Map data() => {};
}

class _GetMobileCheckCodeForGuestJoinApi extends HttpApi<void> {
  /// 会议号
  final String meetingNum;

  /// 手机号
  final String mobile;

  _GetMobileCheckCodeForGuestJoinApi(this.meetingNum, this.mobile);

  @override
  String get method => 'GET';

  @override
  String path() {
    return 'scene/meeting/v2/smsForGuestJoinWithMeetingNum/${meetingNum}?phoneNum=${mobile}';
  }

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() {
    return const {};
  }

  @override
  bool checkLoginState() {
    return false;
  }
}
