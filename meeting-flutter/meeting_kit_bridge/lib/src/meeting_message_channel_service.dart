// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:fluttermodule/meeting_kit_bridge.dart';
import 'package:fluttermodule/src/callback.dart';
import 'package:fluttermodule/src/service.dart';
import 'package:netease_meeting_kit/meeting_core.dart';

class MeetingMessageChannelServiceBridge extends Service
    implements NEMeetingMessageChannelListener {
  final MeetingKitBridge meetingKitBridge;

  MeetingMessageChannelServiceBridge.asService(this.meetingKitBridge) {
    meetingKitBridge.meetingMessageChannelService
        .addMeetingMessageChannelListener(this);
  }

  @override
  String get name => 'meetingMessageChannel';

  String mapMethodName(String method) => name + '.' + method;

  @override
  Future handleCall(String method, arguments) {
    switch (method) {
      case 'queryUnreadMessageList':
        return _handleQueryUnreadMessageList(arguments);
      case 'clearUnreadCount':
        return _handleClearUnreadCount(arguments);
      case 'deleteAllSessionMessage':
        return _handleDeleteAllSessionMessage(arguments);
      case 'getSessionMessagesHistory':
        return _handleGetSessionMessagesHistory(arguments);
    }
    return super.handleCall(method, arguments);
  }

  Future<Map> _handleQueryUnreadMessageList(arguments) async {
    assert(arguments['sessionId'] is String);
    return meetingKitBridge.meetingMessageChannelService
        .queryUnreadMessageList(
      arguments['sessionId'],
    )
        .then((value) {
      final data = value.data?.map((e) => e.toMap()).toList();
      return Callback.wrap(
        'queryUnreadMessageList',
        value.code,
        msg: value.msg,
        data: data,
      ).result;
    });
  }

  Future<Map> _handleClearUnreadCount(arguments) async {
    assert(arguments['sessionId'] is String);
    return meetingKitBridge.meetingMessageChannelService
        .clearUnreadCount(
      arguments['sessionId'],
    )
        .then((value) {
      return Callback.wrap('clearUnreadCount', value.code, msg: value.msg)
          .result;
    });
  }

  Future<Map> _handleDeleteAllSessionMessage(arguments) async {
    assert(arguments['sessionId'] is String);
    return meetingKitBridge.meetingMessageChannelService
        .deleteAllSessionMessage(
      arguments['sessionId'],
    )
        .then((value) {
      return Callback.wrap(
        'deleteAllSessionMessage',
        value.code,
        msg: value.msg,
      ).result;
    });
  }

  Future<Map> _handleGetSessionMessagesHistory(arguments) async {
    assert(arguments['param'] is Map);
    final param = NEMeetingGetMessageHistoryParams.fromMap(
        arguments['param'] as Map<String, dynamic>);
    return meetingKitBridge.meetingMessageChannelService
        .getSessionMessagesHistory(param)
        .then((value) {
      final data = value.data?.map((e) => e.toMap()).toList();
      return Callback.wrap(
        'getSessionMessagesHistory',
        value.code,
        msg: value.msg,
        data: data,
      ).result;
    });
  }

  @override
  void onSessionMessageAllDeleted(
      String sessionId, NEMeetingSessionTypeEnum sessionType) {
    meetingKitBridge.channel
        .invokeMethod(mapMethodName('notifyMeetingSessionMessageAllDeleted'), {
      'sessionId': sessionId,
      'sessionType': sessionType.value,
    });
  }

  @override
  void onSessionMessageDeleted(NEMeetingSessionMessage message) {
    meetingKitBridge.channel.invokeMethod(
      mapMethodName('notifyMeetingSessionMessageDeleted'),
      message.toMap(),
    );
  }

  @override
  void onSessionMessageReceived(NEMeetingSessionMessage message) {
    meetingKitBridge.channel.invokeMethod(
      mapMethodName('notifyMeetingSessionMessageReceived'),
      message.toMap(),
    );
  }

  @override
  void onSessionMessageRecentChanged(List<NEMeetingRecentSession> messages) {
    meetingKitBridge.channel.invokeMethod(
      mapMethodName('notifyMeetingSessionMessageRecentChanged'),
      [
        for (var message in messages) message.toMap(),
      ],
    );
  }
}
