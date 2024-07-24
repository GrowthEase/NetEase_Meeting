// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:fluttermodule/meeting_kit_bridge.dart';
import 'package:fluttermodule/src/callback.dart';
import 'package:fluttermodule/src/service.dart';
import 'package:netease_meeting_kit/meeting_core.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

class MeetingInviteServiceBridge extends Service
    implements NEMeetingInviteStatusListener {
  final MeetingKitBridge meetingKitBridge;

  MeetingInviteServiceBridge.asService(this.meetingKitBridge) {
    meetingKitBridge.meetingInviteService.addMeetingInviteStatusListener(this);
  }

  @override
  String get name => 'meetingInvite';

  String mapMethodName(String method) => name + '.' + method;

  @override
  Future handleCall(String method, arguments) {
    switch (method) {
      case 'rejectInvite':
        return _handleRejectInvite(arguments);
      case 'acceptInvite':
        return _handleAcceptInviteMeeting(arguments);
    }
    return super.handleCall(method, arguments);
  }

  Future<Map> _handleRejectInvite(arguments) async {
    return meetingKitBridge.meetingInviteService
        .rejectInvite(
      arguments['meetingId'] as int,
    )
        .then((value) {
      return Callback.wrap('rejectInvite', value.code, msg: value.msg).result;
    });
  }

  Future<Map> _handleAcceptInviteMeeting(arguments) async {
    assert(arguments is Map);

    /// 当前已经在Flutter界面，不允许打开会议页面
    if (meetingKitBridge.inFlutterView) {
      return Callback.wrap('acceptInvite', NEMeetingErrorCode.failed,
              msg: 'is in webView')
          .result;
    }
    assert(arguments['params'] is Map);
    assert(arguments['opts'] is Map);
    final params = NEJoinMeetingParams.fromMap(arguments['params'] as Map);
    final options = NEMeetingOptions.fromJson(
        (arguments['opts'] ?? {}) as Map<String, dynamic>);
    return meetingKitBridge.meetingInviteService
        .acceptInvite(
      meetingKitBridge.buildContext,
      params,
      options,
    )
        .then((value) {
      return Callback.wrap('acceptInvite', value.code, msg: value.msg).result;
    });
  }

  @override
  void onMeetingInviteStatusChanged(NEMeetingInviteStatus status,
      String? meetingId, NEMeetingInviteInfo inviteInfo) {
    meetingKitBridge.channel.invokeMethod(
        mapMethodName('notifyMeetingInviteStatusChanged'), {
      'status': status.index,
      'meetingId': meetingId,
      'inviteInfo': inviteInfo.toMap()
    });
  }
}
