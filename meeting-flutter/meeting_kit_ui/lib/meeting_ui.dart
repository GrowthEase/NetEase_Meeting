// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library meeting_ui;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_core/meeting_kit.dart';
import 'package:netease_meeting_core/meeting_service.dart';
import 'dart:math';
import 'package:netease_meeting_ui/meeting_plugin.dart';
import 'package:netease_meeting_ui/meeting_localization.dart';
import 'package:uuid/uuid.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart' as isg;
import 'package:open_filex/open_filex.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock/wakelock.dart';
import 'package:pedantic/pedantic.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:netease_meeting_assets/netease_meeting_assets.dart';
import 'package:netease_roomkit/netease_roomkit.dart';
import 'package:netease_roomkit_interface/netease_roomkit_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:async/async.dart';

export 'package:netease_meeting_core/meeting_kit.dart';
export 'package:netease_meeting_ui/meeting_plugin.dart'
    show NEForegroundServiceConfig;
export 'package:netease_meeting_ui/meeting_localization.dart';

part 'src/meeting_ui/arguments/meeting_arguments.dart';
part 'src/meeting_ui/arguments/meeting_options.dart';
part 'src/meeting_ui/arguments/members_arguments.dart';
part 'src/meeting_ui/arguments/chatroom_arguments.dart';
part 'src/meeting_ui/option/meeting_options.dart';
part 'src/meeting_ui/pages/proxy/meeting_page_proxy.dart';
part 'src/meeting_ui/pages/proxy/beauty_page_proxy.dart';
part 'src/meeting_ui/pages/proxy/virtual_background_page_proxy.dart';
part 'src/meeting_ui/pages/meeting_members_page.dart';
part 'src/meeting_ui/pages/meeting_page.dart';
part 'src/meeting_ui/pages/meeting_chatroom_page.dart';
part 'src/meeting_ui/pages/meeting_info_page.dart';
part 'src/meeting_ui/pages/meeting_invite_page.dart';
part 'src/meeting_ui/state/meeting_state.dart';
part 'src/meeting_ui/values/colors.dart';
part 'src/meeting_ui/widget/meeting_duration.dart';
part 'src/meeting_ui/widget/slider_widget.dart';
part 'src/meeting_ui/widget/round_slider_trackshape.dart';
part 'src/meeting_ui/widget/dots_indicator.dart';
part 'src/meeting_ui/service/meeting_ui_kit.dart';
part 'src/meeting_ui/pages/meeting_waiting_page.dart';
part 'src/meeting_ui/arguments/meeting_waiting_arguments.dart';
part 'src/meeting_ui/arguments/meeting_base_arguments.dart';
part 'src/meeting_ui/const/consts.dart';
part 'src/meeting_ui/values/integration_core_test.dart';
part 'src/meeting_ui/pages/meeting_beauty_setting_page.dart';
part 'src/meeting_ui/pages/meeting_live_page.dart';
part 'src/meeting_ui/pages/meeting_live_setting_page.dart';
part 'src/meeting_ui/pages/meeting_pre_virtual_background_page.dart';
part 'src/meeting_ui/pages/meeting_chat_message_detail.dart';
part 'src/meeting_ui/arguments/live_arguments.dart';
part 'src/meeting_ui/menu/meeting_menus.dart';
part 'src/meeting_ui/menu/base_widgets.dart';
part 'src/meeting_ui/widget/popup_menu_widget.dart';
part 'src/meeting_ui/widget/triangle_painter.dart';
part 'src/meeting_ui/widget/localizations.dart';
part 'src/meeting_ui/widget/draggable_positioned.dart';
part 'src/meeting_ui/module_name.dart';
part 'src/meeting_ui/option/window_mode.dart';
part 'src/meeting_ui/pages/meeting_whiteboard_page.dart';
part 'src/meeting_ui/pages/meeting_virtual_background_page.dart';
part 'src/meeting_ui/service/in_meeting_service.dart';
part 'src/meeting_ui/service/meeting_context.dart';
part 'src/meeting_ui/widget/animated_micphone_volume.dart';
part 'src/meeting_ui/service/menu/menu_item.dart';
part 'src/meeting_ui/service/menu/menu_item_util.dart';
part 'src/meeting_ui/service/menu/menu_items.dart';
part 'src/meeting_ui/service/model/meeting_status.dart';

part 'src/meeting_ui/uikit/lifecycle/state_lifecycle.dart';
part 'src/meeting_ui/uikit/state/lifecycle_base_state.dart';
part 'src/meeting_ui/uikit/state/base_state.dart';
part 'src/meeting_ui/uikit/loading.dart';
part 'src/meeting_ui/uikit/nav_utils.dart';
part 'src/meeting_ui/uikit/dialog_utils.dart';
part 'src/meeting_ui/uikit/mask_text_input.dart';
part 'src/meeting_ui/uikit/clear_icon_button.dart';
part 'src/meeting_ui/uikit/toast_utils.dart';
part 'src/meeting_ui/uikit/invite_dialog.dart';
part 'src/meeting_ui/values/event_name.dart';
part 'src/meeting_ui/uikit/style/app_style_util.dart';
part 'src/meeting_ui/uikit/permission/permission_helper.dart';
part 'src/meeting_ui/uikit/helpers.dart';

class MeetingCore {
  static MeetingCore? _instance;
  static const _tag = 'MeetingCore';

  factory MeetingCore() {
    return _instance ??= MeetingCore._internal();
  }

  MeetingCore._internal();

  NEForegroundServiceConfig? _foregroundConfig;

  set foregroundConfig(NEForegroundServiceConfig? value) {
    _foregroundConfig = value;
  }

  Future<NEForegroundServiceConfig?> getForegroundConfig() async {
    if (_foregroundConfig != null) return _foregroundConfig;
    if (Platform.isAndroid) {
      final sdkInt = await DeviceInfoPlugin()
              .androidInfo
              .then((value) => value.version.sdkInt) ??
          0;
      // // Android Q以上屏幕共享需要一个前台Service
      if (sdkInt >= 29) {
        return NEForegroundServiceConfig(
          contentTitle:
              NEMeetingUIKit().ofLocalizations().notificationContentTitle,
          contentText:
              NEMeetingUIKit().ofLocalizations().notificationContentText,
          ticker: NEMeetingUIKit().ofLocalizations().notificationContentTicker,
          channelId: NEMeetingUIKit().ofLocalizations().notificationChannelId,
          channelName:
              NEMeetingUIKit().ofLocalizations().notificationChannelName,
          channelDesc:
              NEMeetingUIKit().ofLocalizations().notificationChannelDesc,
        );
      }
    }
    return null;
  }

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
