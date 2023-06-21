// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library meeting_kit;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:netease_common/netease_common.dart';

import 'package:netease_roomkit/netease_roomkit.dart'
    hide
        NERtcServerRecordMode,
        NERtcVideoView,
        NERtcVideoRenderer,
        NEAuthService;

import 'meeting_service.dart';

export 'package:netease_meeting_core/meeting_service.dart'
    show
        NEMeetingItem,
        NEMeetingState,
        NEMeetingItemSettings,
        NEPreRoomLiveInfo,
        NELiveAuthLevel,
        NERoomItemLiveState,
        NEMeetingRoleConfiguration,
        NERoomInvitation,
        NERoomControl,
        NERoomAudioControl,
        NERoomVideoControl,
        NERoomAttendeeOffType;

part 'src/meeting_kit/meeting_account_service.dart';
part 'src/meeting_kit/impl/meeting_account_service_impl.dart';
part 'src/meeting_kit/impl/meeting_kit_impl.dart';
part 'src/meeting_kit/impl/meeting_service_impl.dart';
part 'src/meeting_kit/impl/pre_meeting_service_impl.dart';
part 'src/meeting_kit/impl/settings_service_impl.dart';
part 'src/meeting_kit/values/meeting_kit_strings.dart';
part 'src/meeting_kit/meeting_service.dart';
part 'src/meeting_kit/pre_meeting_service.dart';
part 'src/meeting_kit/settings_service.dart';
part 'src/meeting_kit/live_meeting_service.dart';
part 'src/meeting_kit/impl/live_meeting_service_impl.dart';
part 'src/meeting_kit/module_name.dart';
part 'src/meeting_kit/log/log_service.dart';
part 'src/meeting_kit/utils/rtc_utils.dart';
part 'src/meeting_kit/utils/network_task_executor.dart';
part 'src/meeting_kit/meeting_context.dart';

class NEMeetingServerConfig {
  static const _serverUrlKey = 'serverUrl';

  String? meetingServer;

  NEMeetingServerConfig();

  factory NEMeetingServerConfig.fromJson(Map json) {
    return NEMeetingServerConfig()
      ..meetingServer = json[_serverUrlKey] as String?;
  }

  Map toJson() => {
        if (meetingServer != null) _serverUrlKey: meetingServer,
      };
}

class NEMeetingKitServerConfig {
  static const _meetingServerConfigKey = 'meeting';

  NEMeetingServerConfig? meetingServerConfig;
  NEServerConfig? roomKitServerConfig;

  NEMeetingKitServerConfig();

  NEMeetingKitServerConfig.fromJson(Map json) {
    meetingServerConfig =
        NEMeetingServerConfig.fromJson(json[_meetingServerConfigKey]);
    roomKitServerConfig = NEServerConfig.fromJson(json);
  }

  Map toJson() => {
        if (roomKitServerConfig != null) ...(roomKitServerConfig!.toJson()),
        if (meetingServerConfig != null)
          _meetingServerConfigKey: meetingServerConfig!.toJson(),
      };
}

/// 提供会议SDK初始化时必要的参数和配置信息
class NEMeetingKitConfig {
  /// 房间App Key，不能为空
  final String appKey;

  NEMeetingKitServerConfig? serverConfig;

  final String? serverUrl;

  /// 日志参数配置
  final ALoggerConfig aLoggerConfig;

  final Map<String, dynamic>? extras;

  NEMeetingKitConfig({
    required this.appKey,
    this.serverConfig,
    this.serverUrl,
    this.extras,
    ALoggerConfig? aLoggerConfig,
  }) : aLoggerConfig = aLoggerConfig ?? const ALoggerConfig();

  @override
  bool operator ==(other) {
    if (other is! NEMeetingKitConfig) {
      return false;
    }
    return appKey == other.appKey &&
        serverConfig == other.serverConfig &&
        serverUrl == other.serverUrl &&
        aLoggerConfig == other.aLoggerConfig &&
        mapEquals(extras, other.extras);
  }

  @override
  int get hashCode => Object.hash(
        appKey,
        serverUrl,
        serverConfig,
        aLoggerConfig,
        extras,
      );

  @override
  String toString() {
    return 'NEMeetingKitConfig{$appKey, $serverUrl}';
  }
}

/// 会议SDK全局接口，提供初始化、管理其他会议相关子服务的能力
abstract class NEMeetingKit {
  static final NEMeetingKit _instance = _NEMeetingKitImpl();

  /// 获取会议SDK实例
  static NEMeetingKit get instance => _instance;

  ValueNotifier<bool> get loginStatusChangeNotifier;

  NEMeetingKitConfig? get config;

  /// 初始化SDK
  /// * [config]   初始化配置对象
  Future<NEResult<void>> initialize(NEMeetingKitConfig config);

  ///
  /// 切换语言
  ///
  Future<NEResult<void>> switchLanguage(NEMeetingLanguage? language);

  ValueListenable<Locale> get localeListenable;

  NEMeetingKitLocalizations get localizations =>
      NEMeetingKitLocalizations.ofLocale(localeListenable.value);

  /// 注册登录状态监听器
  ///
  /// [listener] 监听器.
  void addAuthListener(NEMeetingAuthListener listener);

  /// 注销登录状态监听器
  ///
  /// [listener] 监听器.
  void removeAuthListener(NEMeetingAuthListener listener);

  /// 登录鉴权。在已登录状态下可以创建和加入会议，但在未登录状态下只能加入会议
  ///
  /// * [accountId]   登录accountId
  /// * [token]     登录令牌
  Future<NEResult<void>> loginWithToken(String accountId, String token);

  /// 登录鉴权。在已登录状态下可以创建和加入会议，但在未登录状态下只能加入会议
  ///
  /// * [username]   登录账号
  /// * [password]   登录密码
  Future<NEResult<void>> loginWithNEMeeting(String username, String password);

  ///
  /// 匿名登录。该方法可支持在不登录正式账号的情况下，临时加入会议。
  /// * 匿名账号池是共享的，不能保证每次登录都是同一个匿名账号。
  /// * 匿名登录后，如果不再使用匿名账号，需要业务方手动调用[logout]接口登出。
  ///
  Future<NEResult<void>> anonymousLogin();

  Future<NEResult<void>> tryAutoLogin();

  /// 获取用于创建或加入会议的会议服务。
  NEMeetingService getMeetingService();

  /// 获取用于查询账号信息的账号服务
  NEMeetingAccountService getAccountService();

  /// 获取会议设置服务
  NESettingsService getSettingsService();

  /// 获取会议前服务
  NEPreMeetingService getPreMeetingService();

  /// 获取会议直播服务
  NELiveMeetingService getLiveMeetingService();

  /// 注销当前已登录的账号
  ///
  Future<NEResult<void>> logout();
}

/// SDK通用错误码
class NEMeetingErrorCode {
  /// 取消操作
  static const int cancelled = -9;

  /// SDK没有登录
  static const int noAuth = -7;

  /// 创建或加入会议失败，原因为当前已经处于一个会议中
  static const int alreadyInMeeting = -6;

  /// 接口调用失败，原因为参数错误
  static const int paramError = -5;

  /// 创建会议失败，原因为当前已经存在一个使用相同会议ID的会议。调用方此时可以加入该会议或者等待该会议结束后重新创建
  static const int meetingAlreadyExist = -4;

  /// 接口调用失败，原因为无网络连接
  static const int noNetwork = -3;

  /// 对应接口调用失败
  static const int failed = -1;

  /// 对应接口调用成功
  static const int success = MeetingErrorCode.success;

  /// 开启了IM复用，请先登录IM
  static const int reuseIMNotLogin = NEErrorCode.reuseIMNotLogin;

  /// 开启了IM复用，IM账号不匹配
  static const int reuseIMAccountNotMatch = NEErrorCode.reuseIMAccountNotMatch;

  /// IM复用不支持匿名加入会议
  static const int reuseIMNotSupportAnonymousLogin = 112001;

  /// ==================== ERROR CODE FROM SERVER ====================
  /// 会议被锁定
  static const int meetingLocked = NEErrorCode.roomLocked;

  /// 会议密码错误
  static const int badPassword = NEErrorCode.badPassword;

  /// 会议不存在
  static const int meetingNotExist = MeetingErrorCode.meetingNotExists;

  /// room 不存在
  static const int meetingNotInProgress = NEErrorCode.roomNotExit;
}

/// 房间登陆状态回调
abstract class NEMeetingAuthListener {
  /// 被踢出
  void onKickOut();

  /// 账号信息过期通知，原因为用户修改了密码，应用层随后应该重新登录
  void onAuthInfoExpired();
}

///
/// 组件支持的语言类型
///
class NEMeetingLanguage {
  static const automatic =
      NEMeetingLanguage._(Locale('*'), NERoomLanguage.automatic);
  static const chinese =
      NEMeetingLanguage._(Locale('zh', 'CN'), NERoomLanguage.chinese);
  static const english =
      NEMeetingLanguage._(Locale('en', 'US'), NERoomLanguage.english);
  static const japanese =
      NEMeetingLanguage._(Locale('ja', 'JP'), NERoomLanguage.japanese);

  final Locale locale;
  final NERoomLanguage roomLang;

  const NEMeetingLanguage._(this.locale, this.roomLang);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NEMeetingLanguage &&
          runtimeType == other.runtimeType &&
          locale == other.locale;

  @override
  int get hashCode => locale.hashCode;
}
