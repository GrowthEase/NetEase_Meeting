// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:fluttermodule/meeting_kit_bridge.dart';
import 'package:fluttermodule/src/callback.dart';
import 'package:fluttermodule/src/service.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

class MeetingServiceBridge extends Service implements NEMeetingStatusListener {
  final MeetingKitBridge meetingKitBridge;

  late final NEMeetingOnInjectedMenuItemClickListener
      _meetingOnInjectedMenuItemClickListener;

  MeetingServiceBridge.asService(this.meetingKitBridge) {
    _handleListenToMeetingStatus();
    _handleMeetingOnInjectedMenuItemClicked();
  }

  @override
  String get name => 'meeting';

  String mapMethodName(String method) => name + '.' + method;

  @override
  Future handleCall(String method, arguments) {
    switch (method) {
      case 'startMeeting':
        return _handleStartMeeting(arguments);
      case 'joinMeeting':
        return _handleJoinMeeting(arguments);
      case 'anonymousJoinMeeting':
        return _handleAnonymousJoinMeeting(arguments);
      case 'getCurrentMeetingInfo':
        return _handleCurrentMeetingInfo();
      case 'leaveCurrentMeeting':
        return _handleLeaveCurrentMeeting(arguments as Map);
      case 'minimizeCurrentMeeting':
        return _handleMinimizeCurrentMeeting();
      case 'fullscreenCurrentMeeting':
        return _handleFullscreenCurrentMeeting();
      case 'updateInjectedMenuItem':
        return _handleUpdateInjectedMenuItem(arguments);
    }
    return super.handleCall(method, arguments);
  }

  void _handleListenToMeetingStatus() {
    meetingKitBridge.meetingService.addMeetingStatusListener(this);
  }

  void _handleMeetingOnInjectedMenuItemClicked() {
    _meetingOnInjectedMenuItemClickListener = (BuildContext context,
        NEMenuClickInfo clickInfo, NEMeetingInfo? meetingInfo) async {
      final didStateTransition = await meetingKitBridge.channel
          .invokeMethod(mapMethodName('notifyMeetOnInjectedMenuItemClicked'), {
        'clickInfo': clickInfo.toJson(),
        if (meetingInfo != null) 'meetingInfo': meetingInfo.toMap()
      });
      assert(didStateTransition is bool);
      return didStateTransition is bool ? didStateTransition : false;
    };
    meetingKitBridge.meetingService.setOnInjectedMenuItemClickListener(
        _meetingOnInjectedMenuItemClickListener);
  }

  Future<Map> _handleStartMeeting(arguments) async {
    assert(arguments is Map);
    assert(arguments['params'] is Map);
    assert(arguments['opts'] is Map);

    /// 不允许多个Flutter界面同时打开
    if (meetingKitBridge.inFlutterView) {
      return Callback.wrap('startMeeting', NEMeetingErrorCode.failed,
              msg: 'is in webView')
          .result;
    }
    return meetingKitBridge.meetingService
        .startMeeting(
      meetingKitBridge.buildContext,
      NEStartMeetingParams.fromMap(arguments['params'] as Map),
      NEMeetingOptions.fromJson(
          Map<String, dynamic>.from((arguments['opts'] ?? {}) as Map)),
    )
        .then((value) {
      return Callback.wrap('startMeeting', value.code, msg: value.msg).result;
    });
  }

  Future<Map> _handleJoinMeeting(arguments) async {
    assert(arguments is Map);
    assert(arguments['params'] is Map);
    assert(arguments['opts'] is Map);

    /// 不允许多个Flutter界面同时打开
    if (meetingKitBridge.inFlutterView) {
      return Callback.wrap('joinMeeting', NEMeetingErrorCode.failed,
              msg: 'is in webView')
          .result;
    }
    return meetingKitBridge.meetingService.joinMeeting(
      meetingKitBridge.buildContext,
      NEJoinMeetingParams.fromMap(arguments['params'] as Map),
      NEMeetingOptions.fromJson(
          (arguments['opts'] ?? {}) as Map<String, dynamic>),
      onPasswordPageRouteWillPush: () async {
        meetingKitBridge.channel.invokeMethod(mapMethodName('openMeetingPage'));
      },
    ).then((value) {
      return Callback.wrap('joinMeeting', value.code, msg: value.msg).result;
    });
  }

  Future<Map> _handleAnonymousJoinMeeting(arguments) async {
    assert(arguments is Map);
    assert(arguments['params'] is Map);
    assert(arguments['opts'] is Map);

    /// 不允许多个Flutter界面同时打开
    if (meetingKitBridge.inFlutterView) {
      return Callback.wrap('anonymousJoinMeeting', NEMeetingErrorCode.failed,
              msg: 'is in webView')
          .result;
    }
    return meetingKitBridge.meetingService.anonymousJoinMeeting(
      meetingKitBridge.buildContext,
      NEJoinMeetingParams.fromMap(arguments['params'] as Map),
      NEMeetingOptions.fromJson(
          (arguments['opts'] ?? {}) as Map<String, dynamic>),
      onPasswordPageRouteWillPush: () async {
        meetingKitBridge.channel.invokeMethod(mapMethodName('openMeetingPage'));
      },
    ).then((value) {
      return Callback.wrap('anonymousJoinMeeting', value.code, msg: value.msg)
          .result;
    });
  }

  Future _handleCurrentMeetingInfo() {
    Callback _callback;
    var meetingInfo = meetingKitBridge.meetingService.getCurrentMeetingInfo();
    if (meetingInfo != null) {
      _callback = Callback.success('getCurrentMeetingInfo',
          msg: 'getCurrentMeetingInfo', data: meetingInfo.toMap());
    } else {
      _callback =
          Callback.wrap('getCurrentMeetingInfo', NEMeetingErrorCode.failed);
    }
    return _callback.result;
  }

  Future _handleLeaveCurrentMeeting(arguments) {
    assert(arguments['closeIfHost'] is bool);
    final closeIfHost = arguments['closeIfHost'] as bool;
    return meetingKitBridge.meetingService
        .leaveCurrentMeeting(closeIfHost)
        .then((value) {
      return Callback.wrap('leaveCurrentMeeting', value.code, msg: value.msg)
          .result;
    });
  }

  Future _handleMinimizeCurrentMeeting() {
    return meetingKitBridge.meetingService
        .minimizeCurrentMeeting()
        .then((value) {
      return Callback.wrap('minimizeCurrentMeeting', value.code, msg: value.msg)
          .result;
    });
  }

  Future _handleFullscreenCurrentMeeting() {
    return meetingKitBridge.meetingService
        .fullscreenCurrentMeeting()
        .then((value) {
      return Callback.wrap('fullscreenCurrentMeeting', value.code,
              msg: value.msg)
          .result;
    });
  }

  Future _handleUpdateInjectedMenuItem(arguments) async {
    assert(arguments is Map);
    return meetingKitBridge.meetingService
        .updateInjectedMenuItem(buildMenuItem(arguments))
        .then((value) {
      return Callback.wrap('updateInjectedMenuItem', value.code, msg: value.msg)
          .result;
    });
  }

  @override
  void onMeetingStatusChanged(NEMeetingEvent event) {
    meetingKitBridge.channel.invokeMethod(
        mapMethodName('notifyMeetingStatusChanged'),
        {'status': event.status, 'arg': event.arg});
  }
}
