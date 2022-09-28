// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 会议状态
enum NEMeetingState {
  /// 无效状态
  invalid,

  /// 会议初始状态，没有人入会
  init,

  /// 已开始
  started,

  /// 已结束， 可以再次入会
  ended,

  /// 已取消
  cancel,

  /// 已回收， 不能再次入会
  recycled,
}

extension _MeetingStateExtension on NEMeetingState {
  static NEMeetingState fromState(int state) {
    switch (state) {
      case 1:
        return NEMeetingState.init;
      case 2:
        return NEMeetingState.started;
      case 3:
        return NEMeetingState.ended;
      case 4:
        return NEMeetingState.cancel;
      case 5:
        return NEMeetingState.recycled;
      default:
        return NEMeetingState.invalid;
    }
  }
}
