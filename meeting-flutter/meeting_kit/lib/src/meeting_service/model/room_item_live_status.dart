// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 会议直播状态
enum NERoomItemLiveState {
  /// 无效状态
  invalid,

  /// 直播未开始
  init,

  /// 直播已经开始
  started,

  /// 已结束
  ended,
}
