// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library meeting_control;

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:yunxin_base/yunxin_base.dart';
import 'package:yunxin_room_kit/room_service.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:provider/provider.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';
import 'package:yunxin_meeting_assets/yunxin_meeting_assets.dart';
import 'package:yunxin_meeting/meeting_sdk_interface.dart';
import 'package:yunxin_meeting/meeting_plugin.dart';

part 'src/meeting_control/model/join_control_type.dart';
part 'src/meeting_control/model/response/tv_info.dart';
part 'src/meeting_control/model/tv_status.dart';
part 'src/meeting_control/model/request/get_tv_info_request.dart';
part 'src/meeting_control/remote/http/get_tv_info_api.dart';
part 'src/meeting_control/remote/nim/send/meeting_base_data.dart';
part 'src/meeting_control/remote/nim/send/create_meeting_data.dart';
part 'src/meeting_control/remote/nim/send/modify_tv_nick_data.dart';
part 'src/meeting_control/remote/nim/send/join_meeting_data.dart';
part 'src/meeting_control/remote/nim/send/cancel_meeting_data.dart';
part 'src/meeting_control/remote/nim/send/audio_control_data.dart';
part 'src/meeting_control/remote/nim/send/video_control_data.dart';
part 'src/meeting_control/remote/nim/send/hands_up_control_data.dart';
part 'src/meeting_control/remote/nim/send/remove_attendee_data.dart';
part 'src/meeting_control/remote/nim/send/host_audio_control_data.dart';
part 'src/meeting_control/remote/nim/send/finish_meeting_data.dart';
part 'src/meeting_control/remote/nim/send/change_focus_data.dart';
part 'src/meeting_control/remote/nim/send/change_host_data.dart';
part 'src/meeting_control/remote/nim/send/request_tv_status_data.dart';
part 'src/meeting_control/remote/nim/send/self_audio_control_data.dart';
part 'src/meeting_control/remote/nim/send/host_reject_audio_hands_up_data.dart';
part 'src/meeting_control/remote/nim/send/self_video_control_data.dart';
part 'src/meeting_control/remote/nim/send/host_video_control_data.dart';
part 'src/meeting_control/remote/nim/send/action_data.dart';
part 'src/meeting_control/remote/nim/send/modify_nick_data.dart';
part 'src/meeting_control/remote/nim/send/notify_tv_update_data.dart';
part 'src/meeting_control/remote/nim/send/request_joiners_from_tv_data.dart';
part 'src/meeting_control/remote/nim/send/leave_meeting_data.dart';
part 'src/meeting_control/remote/nim/send/request_upadte_data.dart';
part 'src/meeting_control/remote/nim/send/disconnect_tv_data.dart';
part 'src/meeting_control/remote/nim/send/show_type_data.dart';
part 'src/meeting_control/remote/nim/send/request_members_data.dart';
part 'src/meeting_control/remote/nim/send/feedback_data.dart';
part 'src/meeting_control/remote/nim/send/turn_page_data.dart';
part 'src/meeting_control/remote/nim/send/sync_control_data.dart';
part 'src/meeting_control/remote/nim/receive/control_action_factory.dart';
part 'src/meeting_control/ui/action/callback_action.dart';
part 'src/meeting_control/ui/arguments/control_arguments.dart';
part 'src/meeting_control/ui/arguments/control_more_menu_arguments.dart';
part 'src/meeting_control/ui/state/control_base_state.dart';
part 'src/meeting_control/ui/store/show_type_model.dart';
part 'src/meeting_control/ui/store/store.dart';
part 'src/meeting_control/ui/page/control_home_page.dart';
part 'src/meeting_control/ui/page/control_meeting_page.dart';
part 'src/meeting_control/ui/page/control_meet_create_page.dart';
part 'src/meeting_control/ui/page/control_meet_join_page.dart';
part 'src/meeting_control/ui/page/control_meet_members_page.dart';
part 'src/meeting_control/ui/page/control_pair_page.dart';
part 'src/meeting_control/ui/page/control_show_type_page.dart';
part 'src/meeting_control/ui/page/control_more_page.dart';
part 'src/meeting_control/ui/consts.dart';
part 'src/meeting_control/values/strings.dart';
part 'src/meeting_control/values/dimem.dart';
part 'src/meeting_control/control_code.dart';
part 'src/meeting_control/ui/event/event_name.dart';
part 'src/meeting_control/control_profile.dart';
part 'src/meeting_control/ui/nav/control_nav.dart';
part 'src/meeting_control/model/control_menu_item.dart';
part 'src/meeting_control/repository/control_in_meeting_repository.dart';
part 'src/meeting_control/remote/nim/control_api.dart';
part 'src/meeting_control/remote/model/control_req.dart';
part 'src/meeting_control/repository/control_pair_repository.dart';
part 'src/meeting_control/ui/arguments/control_meeting_arguments.dart';
part 'src/meeting_control/ui/arguments/control_meeting_waiting_arguments.dart';
part 'src/meeting_control/ui/page/control_meeting_waiting_page.dart';
part 'src/meeting_control/ui/page/control_nick_setting_page.dart';
part 'src/meeting_control/ui/arguments/control_members_arguments.dart';
part 'src/meeting_control/ui/arguments/control_options.dart';
part 'src/meeting_control/remote/nim/send/lock_status_change_data.dart';
part 'src/meeting_control/listener/control_message_listener.dart';
part 'src/meeting_control/constant/tc_protocol.dart';
part 'src/meeting_control/ui/menu/control_menus.dart';
part 'src/meeting_control/service/meeting_control_ui_service.dart';
part 'src/meeting_control/ui/arguments/control_join_meeting_info.dart';
part 'src/meeting_control/module_name.dart';
part 'src/meeting_control/values/integration_core_test.dart';
part 'src/meeting_control/ui/arguments/controller_meeting_base_arguments.dart';
part 'src/meeting_control/ui/arguments/controller_meeting_options.dart';
part 'src/meeting_control/ui/arguments/controller_meeting_waiting_arguments.dart';
part 'src/meeting_control/model/window_mode.dart';
part 'src/meeting_control/service/control_in_meeting_service.dart';

const int audioUnAllMute = 0;
const int audioAllMute = 1;

class MeetingControl {
  static const _tag = 'MeetingControl';
  static final GlobalKey<NavigatorState> controlNavigatorKey = GlobalKey();
  static MeetingControl? _instance;
  factory MeetingControl() {
    return _instance ??= MeetingControl._internal();
  }
  MeetingControl._internal();

  final StreamController<ControlMenuItem> _controlSettingController =
      StreamController<ControlMenuItem>.broadcast();

  Stream<ControlMenuItem> get controlSettingStream =>
      _controlSettingController.stream;

  void notifySettingClick(ControlMenuItem menuItem) {
    Alog.d(
        tag: _tag,
        moduleName: _moduleName,
        content:
            'meeting control notifyStatusChange menuItem = ${menuItem.title}');
    _controlSettingController.add(menuItem);
  }

  bool _isAlreadyOpenControl = false;

  bool get isAlreadyOpenControl => _isAlreadyOpenControl;

  set isAlreadyOpenControl(bool value) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'meeting control set isAlreadyOpenControl = $value');
    _isAlreadyOpenControl = value;
  }

  final StreamController<ControlResult> _controlStartMeetingController =
      StreamController<ControlResult>.broadcast();

  Stream<ControlResult> get controlStartMeetingStream =>
      _controlStartMeetingController.stream;

  final StreamController<ControlResult> _controlJoinMeetingController =
      StreamController<ControlResult>.broadcast();

  Stream<ControlResult> get controlJoinMeetingStream =>
      _controlJoinMeetingController.stream;

  final StreamController<int> _controlUnbindController =
      StreamController<int>.broadcast();

  Stream<int> get controlUnbindStream => _controlUnbindController.stream;

  final StreamController<TCProtocolUpgrade> _tvProtocolUpgradeController =
      StreamController<TCProtocolUpgrade>.broadcast();

  Stream<TCProtocolUpgrade> get tvProtocolUpgradeStream =>
      _tvProtocolUpgradeController.stream;

  void notifyStartMeetingResult(ControlResult result) {
    Alog.d(
        tag: _tag,
        moduleName: _moduleName,
        content:
            'meeting sdk notifyControlStartMeetingResult errorCode = ${result.code}, errorMessage = ${result.message} ');
    _controlStartMeetingController.add(result);
  }

  void notifyJoinMeetingResult(ControlResult result) {
    Alog.d(
        tag: _tag,
        moduleName: _moduleName,
        content:
            'meeting sdk notifyControlJoinMeetingResult errorCode = ${result.code}, errorMessage = ${result.message} ');
    _controlJoinMeetingController.add(result);
  }

  void notifyUnbind(int unbindType) {
    Alog.d(
        tag: _tag,
        moduleName: _moduleName,
        content: 'meeting sdk notifyControlUnbind unbindType = $unbindType');
    _controlUnbindController.add(unbindType);
  }

  void notifyTCProtocolUpgrade(TCProtocolUpgrade protocolUpgrade){
    Alog.d(
        tag: _tag,
        moduleName: _moduleName,
        content:
            'meeting sdk notifyProtocolUpgrade protocolUpgrade = ${protocolUpgrade.toString()}');
    _tvProtocolUpgradeController.add(protocolUpgrade);
  }
}

/// Control result.
class ControlResult {
  int code;
  String? message;
  ControlResult(this.code, this.message);
}

class UnbindType {
  static const int tvUnbind = 1;
  static const int forceUnbind = 2;
}

class TCProtocolUpgrade {
  String controllerProtocolVersion;
  String tvProtocolVersion;
  bool isCompatible;

  TCProtocolUpgrade(this.controllerProtocolVersion, this.tvProtocolVersion,
      this.isCompatible);

  @override
  String toString() {
    return 'TCProtocolUpgrade{controllerProtocolVersion: $controllerProtocolVersion, tvVersion: $tvProtocolVersion, isCompatible: $isCompatible}';
  }
}
