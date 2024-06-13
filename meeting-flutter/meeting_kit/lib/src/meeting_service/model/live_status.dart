// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 会议直播状态
enum NEMeetingItemLiveStatus {
  /// 无效状态
  invalid,

  /// 会议直播初始状态，未开始
  init,

  /// 已开始直播
  started,

  /// 已结束直播
  ended,
}
