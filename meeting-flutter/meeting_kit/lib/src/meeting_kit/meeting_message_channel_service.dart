// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 提供会议消息通知相关的服务接口，诸如查询自定义消息历史、查询未读数、添加消息监听监听等。可通过 [NEMeetingKit.getMeetingMessageChannelService()] 获取对应的服务实例
abstract class NEMeetingMessageChannelService {
  ///
  /// 添加自定义消息监听
  /// [listener] 消息监听器
  ///
  void addMeetingMessageChannelListener(
      NEMeetingMessageChannelListener listener);

  ///
  /// 移除自定义消息监听
  /// [listener] 消息监听器
  ///
  void removeMeetingMessageChannelListener(
      NEMeetingMessageChannelListener listener);

  ///
  /// 获取指定会话的未读消息列表
  /// [sessionId] 会话id
  /// return 消息列表
  ///
  Future<NEResult<List<NEMeetingSessionMessage>>> queryUnreadMessageList(
      String sessionId);

  ///
  /// 清除指定会话的未读消息数
  /// 该接口会触发 NEMeetingMessageChannelListener.onSessionMessageRecentChanged 回调通知。
  /// [sessionId] 会话id
  ///
  Future<VoidResult> clearUnreadCount(String sessionId);

  ///
  ///  删除指定会话的所有消息
  ///  该接口会触发 NEMeetingMessageChannelListener.onSessionMessageAllDeleted 回调通知。
  ///  [sessionId] 会话id
  ///
  Future<VoidResult> deleteAllSessionMessage(String sessionId);

  ///
  /// 获取指定会话的历史消息
  /// [param] 查询参数
  /// return  消息历史列表
  ///
  Future<NEResult<List<NEMeetingSessionMessage>>> getSessionMessagesHistory(
      NEMeetingGetMessageHistoryParams param);
}
