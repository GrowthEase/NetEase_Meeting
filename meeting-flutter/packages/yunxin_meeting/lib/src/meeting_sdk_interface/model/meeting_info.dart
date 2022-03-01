// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'in_meeting_user_info.dart';

/// 会议信息
class NEMeetingInfo {
  /// 预定成功后， 服务器生成唯一id
  final int meetingUniqueId;

  /// 当前会议ID
  final String meetingId;

  /// 当前会议短号ID
  final String? shortMeetingId;

  /// 当前会议SIP ID
  final String? sipCid;

  /// 会议类型
  final int type;

  /// 会议主题
  final String subject;

  /// 会议密码
  final String? password;

  /// 会议开始时间
  final int startTime;

  /// 会议预约开始时间
  final int scheduleStartTime;

  /// 会议预约结束时间
  final int scheduleEndTime;

  /// 会议当前持续时间
  final int duration;

  /// 当前用户是否为主持人
  final bool isHost;

  /// 当前会议是否被锁定
  final bool isLocked;

  /// 当前主持人id
  final String hostUserId;

  final List<NEInMeetingUserInfo> userList;

  NEMeetingInfo({
    required this.meetingUniqueId,
    required this.meetingId,
    this.shortMeetingId,
    this.sipCid,
    required this.type,
    required this.subject,
    this.password,
    required this.startTime,
    this.scheduleStartTime = 0,
    this.scheduleEndTime = 0,
    required this.duration,
    required this.isHost,
    required this.isLocked,
    required this.hostUserId,
    required this.userList,
  });


  Map<String, dynamic> toMap() => {
        'meetingUniqueId': meetingUniqueId,
        'meetingId': meetingId,
        'shortMeetingId': shortMeetingId,
        'sipId': sipCid,
        'type': type,
        'isLocked': isLocked,
        'isHost': isHost,
        'password': password,
        'subject': subject,
        'startTime': startTime,
        'scheduleStartTime': scheduleStartTime,
        'scheduleEndTime': scheduleEndTime,
        'duration': duration,
        'hostUserId': hostUserId,
        'userList': userList.map((e) => e.toMap()).toList(growable: false),
      };

  @override
  String toString() {
    return 'NEMeetingInfo{meetingUniqueId: $meetingUniqueId, meetingId: $meetingId, shortMeetingId: $shortMeetingId, sipCid: $sipCid, type: $type, subject: $subject, password: $password, startTime: $startTime, scheduleStartTime: $scheduleStartTime, scheduleEndTime: $scheduleEndTime, duration: $duration, isHost: $isHost, isLocked: $isLocked, hostUserId: $hostUserId, userList: $userList}';
  }
}
