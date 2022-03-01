// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library meeting_sdk;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:yunxin_base/yunxin_base.dart';
import 'package:yunxin_meeting/meeting_control.dart';
import 'package:yunxin_meeting/meeting_core.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yunxin_meeting/meeting_plugin.dart';
import 'package:yunxin_room_kit/room_kit.dart';
import 'package:yunxin_meeting/meeting_sdk_interface.dart';

export 'package:yunxin_room_kit/room_kit.dart';


part 'src/meeting_sdk/meeting_account_service.dart';
part 'src/meeting_sdk/control_service.dart';
part 'src/meeting_sdk/impl/meeting_account_service_impl.dart';
part 'src/meeting_sdk/impl/control_service_impl.dart';
part 'src/meeting_sdk/impl/meeting_sdk_impl.dart';
part 'src/meeting_sdk/impl/meeting_service_impl.dart';
part 'src/meeting_sdk/impl/pre_meeting_service_impl.dart';
part 'src/meeting_sdk/impl/settings_service_impl.dart';
part 'src/meeting_sdk/meeting_sdk_strings.dart';
part 'src/meeting_sdk/meeting_service.dart';
part 'src/meeting_sdk/pre_meeting_service.dart';
part 'src/meeting_sdk/proxy/control_pair_page_proxy.dart';
part 'src/meeting_sdk/proxy/meeting_page_proxy.dart';
part 'src/meeting_sdk/proxy/beauty_page_proxy.dart';
part 'src/meeting_sdk/settings_service.dart';
part 'src/meeting_sdk/live_meeting_service.dart';
part 'src/meeting_sdk/impl/live_meeting_service_impl.dart';
part 'src/meeting_sdk/module_name.dart';
part 'src/meeting_sdk/utils/meeting_utils.dart';

/// SDK API的通用回调接口。会议SDK提供的接口多为异步实现，在调用这些接口时，需要提供一个该接口的实现作为回调参数。
// ignore: comment_references
/// - [errorCode]    错误码，参见 [NEMeetingError] 中的定义
/// - [errorMessage] 错误描述，可能为空
/// - [result]       返回值，具体数据类型视不同API而定，可能为空
typedef NECompleteListener = void Function({required int errorCode, String? errorMessage, Object? result});

/// 提供会议SDK初始化时必要的参数和配置信息
class NEMeetingSDKConfig {
  /// 房间App Key，不能为空
  final String appKey;

  /// 是否复用IM通道
  final bool reuseNIM;

  /// 日志参数配置
  final ALoggerConfig aLoggerConfig;

  final Map<String,dynamic>? extras;
  
  /// 企业域名，当前可空
  final String? domain;

  /// 应用名称，显示在会议页面的标题栏中
  final String appName;

  /// Broadcast Upload Extension的App Group名称，iOS屏幕共享时使用
  final String? iosBroadcastAppGroup;

  @deprecated
  /// 指定开启或关闭日志输出
  final bool enableDebugLog;

  @deprecated
  /// 指定日志文件的大小，以字节为单位
  final int logSize;

  /// 是否检查并使用asset资源目录下的私有化服务器配置文件，默认为false。
  final bool useAssetServerConfig;

  /// 前台服务配置
  late final NEForegroundServiceConfig config;

  NEMeetingSDKConfig({
    required this.appKey,
    this.reuseNIM = false,
    this.useAssetServerConfig = false,
    this.domain,
    this.appName = NEMeetingSDKStrings.defaultAppName,
    this.enableDebugLog = true,
    this.logSize = 0,
    this.iosBroadcastAppGroup,
    this.extras,
    NEForegroundServiceConfig? config,
    ALoggerConfig? aLoggerConfig,
  }) : aLoggerConfig = aLoggerConfig ?? const ALoggerConfig() {
    this.config = config ?? NEForegroundServiceConfig();
  }

  @override
  bool operator ==(other) {
    if (other is! NEMeetingSDKConfig) {
      return false;
    }
    return appKey == other.appKey &&
        domain == other.domain &&
        appName == other.appName &&
        useAssetServerConfig == other.useAssetServerConfig &&
        enableDebugLog == other.enableDebugLog &&
        logSize == other.logSize &&
        aLoggerConfig == other.aLoggerConfig &&
        reuseNIM == other.reuseNIM &&
        mapEquals(extras, other.extras)
        ;
  }

  @override
  int get hashCode => hashValues(
        appKey,
        domain,
        appName,
        useAssetServerConfig,
        enableDebugLog,
        logSize,
        reuseNIM,
        config,
        aLoggerConfig,
        extras,
      );

  @override
  String toString() {
    return 'NEMeetingSDKConfig{appKey: $appKey, domain: $domain, appName: $appName, iosBroadcastAppGroup: $iosBroadcastAppGroup, useAssetServerConfig: $useAssetServerConfig, enableDebugLog: $enableDebugLog, logSize: $logSize, reuseNIM: $reuseNIM, config: $config, aLoggerConfig: $aLoggerConfig}';
  }
}

/// 会议SDK全局接口，提供初始化、管理其他会议相关子服务的能力
abstract class NEMeetingSDK {
  static final NEMeetingSDK _instance = _NEMeetingSDKImpl();

  /// 获取会议SDK实例
  static NEMeetingSDK get instance => _instance;

  ValueListenable<bool> get loginStatusChangeNotifier;

  NEMeetingSDKConfig? get config;

  /// 初始化SDK
  ///
  /// * [config]   初始化配置对象
  /// * [listener] 回调接口，该回调不会返回额外的结果数据
  void initialize(NEMeetingSDKConfig config, NECompleteListener listener);

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
  /// * [listener]  回调接口，该回调不会返回额外的结果数据
  void loginWithToken(String accountId, String token, NECompleteListener listener);

  /// 登录鉴权。在已登录状态下可以创建和加入会议，但在未登录状态下只能加入会议
  ///
  /// * [username]   登录账号
  /// * [password]   登录密码
  /// * [listener]  回调接口，该回调不会返回额外的结果数据
  void loginWithNEMeeting(String username, String password, NECompleteListener listener);

  /// 登录鉴权。在已登录状态下可以创建和加入会议，但在未登录状态下只能加入会议
  ///
  /// * [ssoToken]  登录SSO令牌
  /// * [listener]  回调接口，该回调不会返回额外的结果数据
  void loginWithSSOToken(String ssoToken, NECompleteListener listener);

  void tryAutoLogin(NECompleteListener listener);

  /// 获取用于创建或加入会议的会议服务。
  NEMeetingService getMeetingService();

  /// 获取用于查询账号信息的账号服务
  NEMeetingAccountService getAccountService();

  /// 获取会议设置服务
  NESettingsService getSettingsService();

  /// 获取遥控器服务
  NEControlService getControlService();

  /// 获取会议前服务
  NEPreMeetingService getPreMeetingService();

  /// 获取会议直播服务
  NELiveMeetingService getLiveMeetingService();

  /// 注销当前已登录的账号
  ///
  /// * [listener] 回调接口，该回调不会返回额外的结果数据
  void logout(NECompleteListener listener);
}

/// SDK通用错误码，供 [NECompleteListener] 回调方法使用
class NEMeetingErrorCode {
  /// 需要验证会议密码
  static const int meetingPasswordRequired = -100;

  /// 遥控器打开状态，不能进入会议;会议非idle,遥控器不能使用
  static const int alreadyOpenControl = -10;

  /// 取消操作
  static const int cancelled = -9;

  /// 会议密码错误
  static const int meetingPasswordError = -8;

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

  /// SDK登录鉴权请求失败
  static const int loginError = -2;

  /// 对应接口调用失败
  static const int failed = -1;

  /// 对应接口调用成功
  static const int success = RoomErrorCode.success;
}

/// 会议登陆状态回调
abstract class NEMeetingAuthListener  extends NERoomAuthListener{}
