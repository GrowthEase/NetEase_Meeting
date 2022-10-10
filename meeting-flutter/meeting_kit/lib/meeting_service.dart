// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library meeting_service;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:netease_common/netease_common.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data' show Uint8List;
import 'package:shared_preferences/shared_preferences.dart';

export 'package:netease_common/netease_common.dart' show NEResult, VoidResult;

part 'src/meeting_service/api/api_helper.dart';
part 'src/meeting_service/api/http_api_helper.dart';
part 'src/meeting_service/config/sdk_config.dart';
part 'src/meeting_service/config/server_config.dart';
part 'src/meeting_service/device_info.dart';
part 'src/meeting_service/executor/executors.dart';
part 'src/meeting_service/executor/http_executor.dart';
part 'src/meeting_service/local/sdk_preferences.dart';
part 'src/meeting_service/model/action_type.dart';
part 'src/meeting_service/model/av_state.dart';
part 'src/meeting_service/model/client_type.dart';
part 'src/meeting_service/model/impl/meeting_item_impl.dart';
part 'src/meeting_service/model/live_layout_type.dart';
part 'src/meeting_service/model/meeting_action.dart';
part 'src/meeting_service/model/meeting_item.dart';
part 'src/meeting_service/model/room_item_setting.dart';
part 'src/meeting_service/model/room_item_status.dart';
part 'src/meeting_service/model/room_item_live.dart';
part 'src/meeting_service/model/room_item_control.dart';
part 'src/meeting_service/model/member_info.dart';
part 'src/meeting_service/model/room_invitation.dart';
part 'src/meeting_service/model/request/create_meeting_req.dart';
part 'src/meeting_service/model/request/login_by_pwd_req.dart';
part 'src/meeting_service/model/response/anonymous_join_meeting_res.dart';
part 'src/meeting_service/model/response/account_settings.dart';
part 'src/meeting_service/remote/base_api.dart';
part 'src/meeting_service/remote/http/anonymous_join_meeting_api.dart';
part 'src/meeting_service/remote/http/cancel_meeting_api.dart';
part 'src/meeting_service/remote/http/create_meeting_api.dart';
part 'src/meeting_service/remote/http/delete_meeting_api.dart';
part 'src/meeting_service/remote/http/edit_meeting_api.dart';
part 'src/meeting_service/remote/http/get_config_api.dart';
part 'src/meeting_service/remote/http/download_beauty_license_api.dart';
part 'src/meeting_service/remote/http/get_meeting_item_by_id_api.dart';
part 'src/meeting_service/remote/http/get_meeting_list_by_status_api.dart';
part 'src/meeting_service/remote/http/login_by_pwd_api.dart';
part 'src/meeting_service/remote/http/schedule_meeting_api.dart';
part 'src/meeting_service/remote/http/get_settings_api.dart';
part 'src/meeting_service/remote/http/save_settings_api.dart';
part 'src/meeting_service/remote/http/room_invitation.dart';
part 'src/meeting_service/remote/http_api.dart';
part 'src/meeting_service/repository/auth_repository.dart';
part 'src/meeting_service/repository/global_error_repository.dart';
part 'src/meeting_service/repository/in_room_repository.dart';
part 'src/meeting_service/repository/meeting_repository.dart';
part 'src/meeting_service/repository/pre_room_repository.dart';
part 'src/meeting_service/repository/service_repository.dart';
part 'src/meeting_service/repository/settings_repository.dart';
part 'src/meeting_service/strings.dart';
part 'src/meeting_service/model/hands_up.dart';
part 'src/meeting_service/model/whiteboard_status.dart';
part 'src/meeting_service/model/room_item_live_status.dart';
part 'src/meeting_service/model/role_type.dart';
part 'src/meeting_service/model/live_level.dart';
part 'src/meeting_service/module_name.dart';
part 'src/meeting_service/model/request/generic_http_api_req.dart';
part 'src/meeting_service/model/room_role_configuration.dart';
part 'src/meeting_service/event_track/event_track.dart';
part 'src/meeting_service/model/constants.dart';
part 'src/meeting_service/model/create_meeting.dart';
part 'src/meeting_service/config/debug_options.dart';
part 'src/meeting_service/model/meeting_item_live.dart';
part 'src/meeting_service/meeting_constants.dart';

/// https://office.netease.com/doc/?identity=3963dc2ced7a48259860289c5d8970af
class MeetingErrorCode {
  /// 通用失败
  static const int failed = -1;

  /// 网络错误
  static const int networkError = -4;

  /// IM复用匿名登录失败，原因是不支持
  static const int loginErrorAnonymousLoginNotSupport = -8;

  /// 取消
  static const int cancelled = -9;

  /// 服务端错误码
  static const int success = 0;
  static const int paramsError = 300;
  static const int paramsNull = 301;
  static const int serverInnerError = 302;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int netTimeout = 408;
  static const int netError = 415;
  static const int serverError = 501;
  static const int versionNotCompatible = 513;
  static const int allocationAccountFail = 1000;
  static const int fetchAccountFail = 1001;
  static const int controlNotAllocationAccount = 1002;
  static const int phoneAlreadyRegister = 1003;
  static const int phoneNotRegister = 1004;
  static const int tokenError = 1005;
  static const int verifyError = 1006;
  static const int loginPasswordError = 1007;
  static const int passwordError = 1008;
  static const int tvAccountNotExist = 1009;
  static const int illegalPhone = 1010;
  static const int smsCodeOverLimit = 1011;
  static const int verifyInvalid = 1012;
  static const int accountNotExist = 1014;
  static const int roomLock = 1019;
  static const int roomNotExist = 2000;
  static const int roomMemberOverLimit = 2001;
  // static const int roomAlreadyExist = 2002;
  static const int nickError = 2003;
  static const int memberVideoError = 2004;
  static const int memberAudioError = 2005;
  static const int roomCidIsEmpty = 2006;
  static const int memberNotHasRoomId = 2007;
  static const int notJoinRoomCannotKick = 2008;
  static const int screenShareOverLimit = 2009;
  static const int notHostPermission = 2100;
  static const int memberNotInRoom = 2101;
  static const int controlCodeError = 2102;
  static const int audioNeedHandsUp = 2108;
  static const int allowSelfAudioOn = 2110;
  static const int audioAlreadyOn = 2111;
  static const int roomNotInProgress = 2200;
  static const int notSupport = 3003;
  static const int meetingAlreadyExists = 3100;
  static const int meetingNotExists = 3104;
  static const int meetingWBExists = 1006;

  /// 已有其他人共享白板
  static const int meetingNotInProgress = 1004;

  /// 会议不在进行中，或者会议不存在

  static String getMsg(String? msg, [String? defaultTips]) {
    if (msg == null || msg.isEmpty) {
      return (defaultTips == null || defaultTips.isEmpty)
          ? '网络连接失败，请检查你的网络连接！'
          : defaultTips;
    }
    return msg;
  }
}
