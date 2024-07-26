// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 回调接口，用于监听消息变更事件
mixin class NEMeetingMessageChannelListener {
  /// 接收到自定义消息时会回调该方法
  /// [message] 自定义会话消息
  void onSessionMessageReceived(NEMeetingSessionMessage message) {}

  /// 会话消息未读数变更时会回调该方法
  /// [messages] 会话消息未读数列表
  void onSessionMessageRecentChanged(List<NEMeetingRecentSession> messages) {}

  /// 会话消息被删除时会回调该方法
  ///  [message] 自定义会话消息
  void onSessionMessageDeleted(NEMeetingSessionMessage message) {}

  /// 会话消息全部被删除时会回调该方法
  /// [sessionId] 会话id
  /// [sessionType] 会话类型
  void onSessionMessageAllDeleted(
      String sessionId, NEMeetingSessionTypeEnum sessionType) {}
}
