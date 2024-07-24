// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:fluttermodule/meeting_kit_bridge.dart';
import 'package:fluttermodule/src/callback.dart';
import 'package:fluttermodule/src/service.dart';
import 'package:netease_meeting_kit/meeting_plugin.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

class ScreenSharingServiceBridge extends Service {
  final MeetingKitBridge meetingKitBridge;

  late final NEScreenSharingStatusListener _screenSharingStatusListener;

  ScreenSharingServiceBridge.asService(this.meetingKitBridge) {
    _handleListenToScreenSharingStatus();
  }

  @override
  String get name => 'screenSharing';

  String mapMethodName(String method) => name + '.' + method;

  @override
  Future handleCall(String method, arguments) {
    switch (method) {
      case 'startScreenShare':
        return _handleStartScreenShare(arguments);
      case 'stopScreenShare':
        return _handleStopScreenShare();
    }
    return super.handleCall(method, arguments);
  }

  void _handleListenToScreenSharingStatus() {
    _screenSharingStatusListener = (NEScreenSharingEvent event) {
      meetingKitBridge.channel.invokeMethod(
          mapMethodName('notifyScreenSharingStatusChanged'),
          {'status': event.event, 'arg': event.arg});
    };
  }

  Future<Map> _handleStartScreenShare(arguments) async {
    assert(arguments is Map);
    assert(arguments['params'] is Map);
    assert(arguments['opts'] is Map);

    meetingKitBridge.screenSharingService
        .addScreenSharingStatusListener(_screenSharingStatusListener);

    NEScreenSharingParams params =
        NEScreenSharingParams.fromMap(arguments['params'] as Map);
    NEScreenSharingOptions options = NEScreenSharingOptions.fromMap(
        (arguments['opts'] ?? {}) as Map<String, dynamic>);

    return meetingKitBridge.screenSharingService
        .startScreenShare(params, options)
        .then((value) {
      return Callback.wrap('startScreenSharing', value.code,
              msg: value.msg, data: value.data)
          .result;
    });
  }

  Future _handleStopScreenShare() {
    return meetingKitBridge.screenSharingService
        .stopScreenShare()
        .then((value) {
      Future.delayed(Duration(milliseconds: 300), () {
        meetingKitBridge.screenSharingService
            .removeScreenSharingStatusListener(_screenSharingStatusListener);
      });
      if (Platform.isAndroid) {
        NEMeetingPlugin().getNotificationService().stopForegroundService();
      }
      return value.isSuccess()
          ? Callback.success('stopScreenSharing')
          : Callback.wrap('stopScreenSharing', NEMeetingErrorCode.failed);
    });
  }
}
