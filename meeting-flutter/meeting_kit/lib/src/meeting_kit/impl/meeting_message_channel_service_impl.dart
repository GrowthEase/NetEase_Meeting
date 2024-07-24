// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEMeetingMessageChannelServiceImpl extends NEMeetingMessageChannelService
    with _AloggerMixin {
  static final _NEMeetingMessageChannelServiceImpl _instance =
      _NEMeetingMessageChannelServiceImpl._();

  factory _NEMeetingMessageChannelServiceImpl() => _instance;

  _NEMeetingMessageChannelServiceImpl._() {}

  @override
  void addMeetingMessageChannelListener(
      NEMeetingMessageChannelListener listener) {
    MessageChannelRepository().addMeetingMessageChannelListener(listener);
  }

  @override
  void removeMeetingMessageChannelListener(
      NEMeetingMessageChannelListener listener) {
    MessageChannelRepository().removeMeetingMessageChannelListener(listener);
  }

  @override
  Future<NEResult<List<NEMeetingSessionMessage>>> queryUnreadMessageList(
      String sessionId) {
    return MessageChannelRepository().queryUnreadMessageList(sessionId);
  }

  @override
  Future<VoidResult> clearUnreadCount(String sessionId) {
    return MessageChannelRepository().clearUnreadCount(sessionId);
  }

  @override
  Future<VoidResult> deleteAllSessionMessage(String sessionId) {
    return MessageChannelRepository().deleteAllSessionMessage(sessionId);
  }

  @override
  Future<NEResult<List<NEMeetingSessionMessage>>> getSessionMessagesHistory(
      NEMeetingGetMessageHistoryParams param) {
    return MessageChannelRepository().getSessionMessagesHistory(param);
  }
}
