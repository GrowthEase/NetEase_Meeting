// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class MessageChannelRepository with _AloggerMixin {
  static final MessageChannelRepository _instance =
      MessageChannelRepository._();

  factory MessageChannelRepository() => _instance;

  final NEMessageChannelService _messageChannelService =
      NERoomKit.instance.messageChannelService;

  final Set<NEMeetingMessageChannelListener> _listenerSet =
      <NEMeetingMessageChannelListener>{};

  /// 缓存会议内的会话消息列表
  Map<int, Set<NEMeetingSessionMessage>?> _messageMapCache = {};

  MessageChannelRepository._() {
    NERoomKit.instance.messageChannelService
        .addMessageChannelCallback(NEMessageChannelCallback(
      onSessionMessageReceivedCallback: (message) {
        if (message.data != null) {
          try {
            final data = NotifyCardData.fromMap(jsonDecode(message.data!));

            /// App邀请消息在meeting_invite_repository中处理
            if (data.data?.type == NENotifyCenterCardType.meetingInvite) {
              return;
            }
            commonLogger.i(
                'receive session message: ${message.data},_listenerSet: ${_listenerSet.length}');
            final customSessionMessage = NEMeetingSessionMessage(
              sessionId: message.sessionId,
              sessionType: NEMeetingSessionTypeEnumExtension.toType(
                  message.sessionType?.value),
              messageId: message.messageId,
              data: message.data,
              time: message.time,
            );

            /// 缓存会议内的插件消息
            if (data.data?.pluginId != null &&
                data.data?.meetingId != null &&
                data.data?.meetingId != 0) {
              _messageMapCache[data.data!.meetingId!] ??= {};
              _messageMapCache[data.data!.meetingId!]
                  ?.add(customSessionMessage);
            }
            for (var listener in _listenerSet) {
              listener.onSessionMessageReceived(customSessionMessage);
            }
          } catch (e) {}
        }
      },
      onSessionMessageRecentChangedCallback:
          (List<NERoomRecentSession> recentSessionChangeMessageList) {
        commonLogger.i(
            'receive recent session message: $recentSessionChangeMessageList');
        for (var listener in _listenerSet) {
          listener.onSessionMessageRecentChanged(recentSessionChangeMessageList
              .map((e) => NEMeetingRecentSession(
                    e.sessionId,
                    e.fromAccount,
                    e.fromNick,
                    NEMeetingSessionTypeEnumExtension.toType(
                        e.sessionType?.value),
                    e.recentMessageId,
                    e.unreadCount,
                    e.content,
                    e.time,
                  ))
              .toList());
        }
      },
      onSessionMessageDeletedCallback: (message) {
        _listenerSet.forEach((element) {
          element.onSessionMessageDeleted(NEMeetingSessionMessage(
            sessionId: message?.sessionId,
            sessionType: NEMeetingSessionTypeEnumExtension.toType(
                message?.sessionType?.value),
            messageId: message?.messageId,
            data: message?.data,
            time: message?.time,
          ));
        });
      },
      onSessionMessageAllDeletedCallback: (sessionId, sessionType) {
        _listenerSet.forEach((element) {
          element.onSessionMessageAllDeleted(sessionId,
              NEMeetingSessionTypeEnumExtension.toType(sessionType.value));
        });
      },
    ));
  }

  Future<NEResult<List<NEMeetingSessionMessage>>> queryUnreadMessageList(
      String sessionId) {
    return _messageChannelService
        .queryUnreadMessageList(sessionId,
            sessionType: NERoomSessionTypeEnumExtension.toType(
                NEMeetingSessionTypeEnum.P2P.value))
        .then(
          (value) => NEResult(
            code: value.code,
            msg: value.msg,
            data: value.data
                ?.map(
                  (e) => NEMeetingSessionMessage(
                    sessionId: e.sessionId,
                    sessionType: NEMeetingSessionTypeEnumExtension.toType(
                        e.sessionType?.value),
                    messageId: e.messageId,
                    time: e.time,
                    data: e.data,
                  ),
                )
                .toList(),
          ),
        );
  }

  void addMeetingMessageChannelListener(
      NEMeetingMessageChannelListener listener) {
    _listenerSet.add(listener);

    /// 会议内的缓存会话消息列表
    if (_messageMapCache.isNotEmpty) {
      _messageMapCache.forEach((key, value) {
        value?.forEach((element) {
          listener.onSessionMessageReceived(element);
        });
      });
      _messageMapCache.clear(); // 使用 clear 方法一次性移除所有映射项
    }
  }

  void removeMeetingMessageChannelListener(
      NEMeetingMessageChannelListener listener) {
    _listenerSet.remove(listener);
    _messageMapCache.clear();
  }

  Future<VoidResult> clearUnreadCount(String sessionId) {
    return _messageChannelService.clearUnreadCount(
      sessionId,
      sessionType: NERoomSessionTypeEnumExtension.toType(
          NEMeetingSessionTypeEnum.P2P.value),
    );
  }

  Future<VoidResult> deleteAllSessionMessage(String sessionId) {
    return _messageChannelService.deleteAllSessionMessage(
      sessionId,
      sessionType: NERoomSessionTypeEnumExtension.toType(
          NEMeetingSessionTypeEnum.P2P.value),
    );
  }

  Future<NEResult<List<NEMeetingSessionMessage>>> getSessionMessagesHistory(
      NEMeetingGetMessageHistoryParams param) {
    return _messageChannelService
        .getSessionMessagesHistory(
          NERoomGetMessagesHistoryParam(
            sessionId: param.sessionId,
            sessionType: NERoomSessionTypeEnum.P2P,
            limit: param.limit ?? 100,
            fromTime: param.fromTime,
            toTime: param.toTime,
            order: NEMessageSearchOrderExtension.toType(param.order?.index),
          ),
        )
        .then(
          (value) => NEResult(
            code: value.code,
            msg: value.msg,
            data: value.data
                ?.map(
                  (e) => NEMeetingSessionMessage(
                    sessionId: e.sessionId,
                    sessionType: NEMeetingSessionTypeEnumExtension.toType(
                        e.sessionType?.value),
                    messageId: e.messageId,
                    time: e.time,
                    data: e.data,
                  ),
                )
                .toList(),
          ),
        );
  }
}
