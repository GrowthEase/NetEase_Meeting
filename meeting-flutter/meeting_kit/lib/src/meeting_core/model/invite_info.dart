// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 房间邀请信息
class NEMeetingInviteInfo {
  /// 会议号
  String? meetingNum;

  /// 邀请者名称
  String? inviterName;

  /// 邀请者头像
  String? inviterAvatar;

  /// 会议主题
  String? subject;

  /// 会前邀请，当在预约会议被添加时触发，则为true；会中主动邀请，则为false
  bool? preMeetingInvitation;

  /// fromMap 解析
  NEMeetingInviteInfo.fromMap(Map? map) {
    meetingNum = map?['meetingNum'] ?? '';
    inviterName = map?['inviterName'] ?? '';
    inviterAvatar = map?['inviterIcon'] ?? '';
    subject = map?['subject'] ?? '';
    preMeetingInvitation = map?['outOfMeeting'] ?? false;
  }

  toMap() {
    return {
      'meetingNum': meetingNum,
      'inviterName': inviterName,
      'inviterAvatar': inviterAvatar,
      'subject': subject,
      'outOfMeeting': preMeetingInvitation
    };
  }
}

///
/// 成员被邀请的状态
///
enum NEMeetingInviteStatus {
  ///
  /// 未知
  ///
  unknown,

  ///
  /// 等待呼叫
  ///
  waitingCall,

  ///
  /// 呼叫中
  ///
  calling,

  ///
  /// 已拒接
  ///
  rejected,

  ///
  /// 未接听
  ///
  noAnswer,

  ///
  /// 呼叫异常
  ///
  error,

  ///
  /// 已移除
  ///
  removed,

  ///
  /// 已取消
  ///
  canceled,

  ///
  /// 待入会
  ///
  waitingJoined,
}
