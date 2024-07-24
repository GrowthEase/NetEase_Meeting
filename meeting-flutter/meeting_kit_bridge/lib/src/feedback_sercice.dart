// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:fluttermodule/meeting_kit_bridge.dart';
import 'package:fluttermodule/src/callback.dart';
import 'package:fluttermodule/src/service.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

class FeedbackServiceBridge extends Service {
  final MeetingKitBridge meetingKitBridge;

  FeedbackServiceBridge.asService(this.meetingKitBridge);
  @override
  String get name => 'feedback';

  String mapMethodName(String method) => name + '.' + method;

  @override
  Future handleCall(String method, arguments) {
    switch (method) {
      case 'feedback':
        return _handleFeedback(arguments);
      case 'loadFeedbackView':
        return _handleLoadFeedbackView();
    }
    return super.handleCall(method, arguments);
  }

  Future _handleFeedback(arguments) {
    assert(arguments is Map);
    return meetingKitBridge.feedbackService
        .feedback(NEFeedback.fromMap(arguments as Map))
        .then((value) {
      return Callback.wrap('feedback', value.code, msg: value.msg).result;
    });
  }

  Future<Map> _handleLoadFeedbackView() async {
    /// 当前已经在会议中，不允许打开意见反馈页面
    if (NEMeetingKit.instance.getMeetingService().getCurrentMeetingInfo() !=
        null) {
      return Callback.wrap(
              'loadFeedbackView', NEMeetingErrorCode.alreadyInMeeting)
          .result;
    }

    /// 不允许多个Flutter界面同时打开
    if (meetingKitBridge.inFlutterView) {
      return Callback.wrap('loadFeedbackView', NEMeetingErrorCode.failed)
          .result;
    }
    final page = meetingKitBridge.feedbackService.loadFeedbackView();
    Navigator.push(meetingKitBridge.buildContext,
            NEMeetingPageRoute(botToastInit: true, builder: (context) => page))
        .then((value) {
      meetingKitBridge.inFlutterView = false;
      SystemNavigator.pop();
    });
    meetingKitBridge.inFlutterView = true;
    return Callback.wrap('loadFeedbackView', NEMeetingErrorCode.success).result;
  }
}
