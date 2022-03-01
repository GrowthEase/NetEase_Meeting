// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library meeting_core;

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:yunxin_room_kit/room_kit.dart';
import 'package:nertc/nertc.dart';
import 'dart:math';
import 'package:yunxin_meeting/meeting_plugin.dart';
import 'package:flutter_newebview/webview_flutter.dart';
import 'package:wakelock/wakelock.dart';
import 'package:pedantic/pedantic.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:yunxin_base/yunxin_base.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';
import 'package:yunxin_meeting_assets/yunxin_meeting_assets.dart';
import 'package:yunxin_meeting/meeting_sdk_interface.dart';


part 'src/meeting_core/arguments/meeting_arguments.dart';
part 'src/meeting_core/arguments/meeting_options.dart';
part 'src/meeting_core/arguments/members_arguments.dart';
part 'src/meeting_core/arguments/chatroom_arguments.dart';
part 'src/meeting_core/option/meeting_options.dart';
part 'src/meeting_core/pages/meeting_members_page.dart';
part 'src/meeting_core/pages/meeting_page.dart';
part 'src/meeting_core/pages/meeting_chatroom_page.dart';
part 'src/meeting_core/pages/meeting_info_page.dart';
part 'src/meeting_core/state/meeting_state.dart';
part 'src/meeting_core/values/strings.dart';
part 'src/meeting_core/widget/meeting_duration.dart';
part 'src/meeting_core/widget/slider_widget.dart';
part 'src/meeting_core/widget/round_slider_trackshape.dart';
part 'src/meeting_core/widget/dots_indicator.dart';
part 'src/meeting_core/service/meeting_ui_service.dart';
part 'src/meeting_core/pages/meeting_waiting_page.dart';
part 'src/meeting_core/arguments/meeting_waiting_arguments.dart';
part 'src/meeting_core/arguments/meeting_base_arguments.dart';
part 'src/meeting_core/const/consts.dart';
part 'src/meeting_core/values/integration_core_test.dart';
part 'src/meeting_core/pages/meeting_beauty_setting_page.dart';
part 'src/meeting_core/pages/meeting_live_page.dart';
part 'src/meeting_core/pages/meeting_live_setting_page.dart';
part 'src/meeting_core/arguments/live_arguments.dart';
part 'src/meeting_core/menu/meeting_menus.dart';
part 'src/meeting_core/menu/base_widgets.dart';
part 'src/meeting_core/widget/popup_menu_widget.dart';
part 'src/meeting_core/widget/triangle_painter.dart';
part 'src/meeting_core/module_name.dart';
part 'src/meeting_core/option/window_mode.dart';
part 'src/meeting_core/pages/meeting_whiteboard_page.dart';
part 'src/meeting_core/service/in_meeting_service.dart';

class MeetingCore {
  static MeetingCore? _instance;
  static const _tag = 'MeetingCore';

  factory MeetingCore() {
    return _instance ??= MeetingCore._internal();
  }

  MeetingCore._internal();

  NEForegroundServiceConfig? foregroundConfig;

  NEMeetingStatus _meetingStatus = NEMeetingStatus(NEMeetingEvent.idle);

  NEMeetingStatus get meetingStatus => _meetingStatus;

  final StreamController<NEMeetingStatus> _meetingStatusController =
      StreamController<NEMeetingStatus>.broadcast();

  Stream<NEMeetingStatus> get meetingStatusStream =>
      _meetingStatusController.stream;

  void notifyStatusChange(NEMeetingStatus status) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'meeting sdk notifyStatusChange status = ${status.event}');
    _meetingStatus = status;
    _meetingStatusController.add(status);
  }
}
