// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 会议状态，
enum MeetingState {
  /// 初始状态
  init,

  /// 加入中
  joining,

  /// 已加入
  joined,

  closing,

  /// 手动关闭
  closed,
}
