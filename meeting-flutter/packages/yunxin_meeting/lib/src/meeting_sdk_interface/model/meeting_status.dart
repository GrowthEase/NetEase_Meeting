// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
class NEMeetingConstants {
  /// 会议密码最小长度
  static const int meetingPasswordMinLen = 4;

  /// 会议密码最大长度
  static const int meetingPasswordMaxLen = 20;

  /// 入会超时时间，单位 ms
  static const int meetingJoinTimeout = 45 * 1000;
}

/// 描述对应状态的额外信息, 与对外文档一致
class NEMeetingCode {
  /// 无效状态，占位用
  static const int undefined = -1;

  /// 当前正在从会议中断开，原因为用户主动断开
  static const int self = 0;

  /// 当前正在从会议中断开，原因为被会议主持人移除
  static const int removedByHost = 1;

  /// 当前正在从会议中断开，原因为会议被主持人关闭
  static const int closeByHost = 2;

  /// disconnecting by login other device
  static const int loginOnOtherDevice = 3;

  /// disconnecting by self & self is host
  static const int closeBySelfAsHost = 4;

  /// disconnecting by self & self is host
  static const int authInfoExpired = 5;

  /// 房间不存在
  static const int roomNotExist = 7;

  /// 同步房间信息失败
  static const int syncDataError = 8;

  /// rtc 模块初始化失败
  static const int rtcInitError = 9;

  /// 加入频道失败
  static const int joinChannelError = 10;

  /// 加入会议超时
  static const int joinTimeout = 11;

  ///
  /// 正在等待验证会议密码
  /// @since 1.2.1
  ///
  static const int verifyPassword = 20;
}

/// 描述会议状态变更事件
class NEMeetingStatus {
  /// 当前会议状态
  final int event;

  /// 该状态附带的额外参数
  final int arg;

  NEMeetingStatus(this.event, {this.arg = NEMeetingCode.undefined});
}

/// 会议状态事件
class NEMeetingEvent {
  /// 创建或加入会议失败
  static const int failed = -1;

  /// 当前未处于任何会议中
  static const int idle = 0;

  /// 当前正在等待加入会议，原因由 [NEMeetingStatus.arg] 描述，可能为以下原因：
  /// * [NEMeetingCode.verifyPassword]
  static const int waiting = 1;

  /// 当前正在创建或加入会议
  static const int connecting = 2;

  /// 当前处于会议中
  static const int inMeeting = 3;

  /// 当前处于最小化会议
  static const int inMeetingMinimized = 4;

  /// 当前正在从会议中断开，断开原因由 [NEMeetingStatus.arg] 描述，可能为以下原因：
  /// * [NEMeetingCode.self]
  /// * [NEMeetingCode.removedByHost]
  /// * [NEMeetingCode.closeByHost]
  static const int disconnecting = 5;

  /// 未知
  static const int unknown = 100;
}
