// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library meeting_kit;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:netease_common/netease_common.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:netease_roomkit/netease_roomkit.dart'
    hide
        NERtcServerRecordMode,
        NERtcVideoView,
        NERtcVideoRenderer,
        NEAuthService;
import 'package:webview_flutter_android/webview_flutter_android.dart';

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
        NEWatermarkConfig,
        NERoomInvitation,
        NERoomControl,
        NERoomAudioControl,
        NERoomVideoControl,
        NEAccountInfo,
        NERoomAttendeeOffType,
        NEMeetingWebAppItem,
        NEMeetingWebAppList,
        NEMeetingRecurringRuleType,
        NEMeetingFrequencyUnitType,
        NEMeetingRecurringEndRuleType,
        NEMeetingRecurringWeekday,
        NEMeetingRecurringRule,
        NEMeetingCustomizedFrequency,
        NEMeetingRecurringEndRule,
        SDKConfig,
        NEContact,
        MeetingRoles,
        NEScheduledMember,
        NEScheduledMemberExt;
export 'package:netease_roomkit/netease_roomkit.dart'
    show
        NEServerConfig,
        NERoomKitServerConfig,
        NEIMServerConfig,
        NERtcServerConfig,
        NEWhiteboardServerConfig,
        NEChatroomType,
        NEChatroomMessageSearchOrder,
        NEChatroomHistoryMessageSearchOption;

part 'src/meeting_kit/meeting_account_service.dart';
part 'src/meeting_kit/impl/screen_sharing_service_impl.dart';
part 'src/meeting_kit/impl/meeting_account_service_impl.dart';
part 'src/meeting_kit/impl/meeting_kit_impl.dart';
part 'src/meeting_kit/impl/meeting_service_impl.dart';
part 'src/meeting_kit/meeting_invite_service.dart';
part 'src/meeting_kit/impl/meeting_invite_service_impl.dart';
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
part 'src/meeting_kit/utils/session_message_notify_card_data.dart';
part 'src/meeting_kit/utils/network_task_executor.dart';
part 'src/meeting_kit/utils/connectivity_manager.dart';
part 'src/meeting_kit/utils/meeting_invite_queue_util.dart';
part 'src/meeting_kit/meeting_context.dart';
part 'src/meeting_kit/report/meeting_report.dart';
part 'src/meeting_kit/screen_sharing_service.dart';
part 'src/meeting_kit/meeting_web_app_bridge.dart';
part 'src/meeting_kit/meeting_nos_service.dart';
part 'src/meeting_kit/impl/meeting_nos_service_impl.dart';

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

  ///
  /// 当前语言
  ///
  NEMeetingLanguage get currentLanguage;

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

  /// 注册session监听器
  ///
  /// [listener] 监听器.
  void addReceiveSessionMessageListener(
      NEMeetingMessageSessionListener listener);

  /// 注销session状态监听器
  ///
  /// [listener] 监听器.
  void removeReceiveSessionMessageListener(
      NEMeetingMessageSessionListener listener);

  /// 获取指定会话的未读消息列表
  /// sessionId 会话id
  /// sessionType 会话类型
  /// 消息列表
  ///
  Future<NEResult<List<NEMeetingCustomSessionMessage>>> queryUnreadMessageList(
      String sessionId,
      {NEMeetingSessionTypeEnum sessionType = NEMeetingSessionTypeEnum.P2P});

  ///使用前提：
  ///已在云信控制台[开启动态查询历史消息功能](https://doc.yunxin.163.com/messaging/docs/TI3NTU1NDA?platform=android#开启动态查询历史消息功能d)。
  /// [param] 查询参数
  /// 消息列表
  ///
  Future<NEResult<List<NEMeetingCustomSessionMessage>>>
      getSessionMessagesHistory(NEMeetingGetMessagesHistoryParam param);

  ///  sessionId 会话id
  ///  sessionType 会话类型
  ///  清理未读消息数
  ///
  Future<VoidResult> clearUnreadCount(String sessionId,
      {NEMeetingSessionTypeEnum sessionType = NEMeetingSessionTypeEnum.P2P});

  ///  sessionId 会话id
  ///  sessionType 会话类型
  ///  删除所有消息
  ///
  Future<VoidResult> deleteAllSessionMessage(String sessionId,
      {NEMeetingSessionTypeEnum sessionType = NEMeetingSessionTypeEnum.P2P});

  /// 登录鉴权。在已登录状态下可以创建和加入会议，但在未登录状态下只能加入会议
  ///
  /// * [accountId]   登录accountId
  /// * [token]     登录令牌
  Future<NEResult<void>> loginWithToken(String accountId, String token,
      {int? startTime});

  /// 登录鉴权。在已登录状态下可以创建和加入会议，但在未登录状态下只能加入会议
  ///
  /// * [username]   登录账号
  /// * [password]   登录密码
  Future<NEResult<void>> loginWithNEMeeting(String username, String password,
      {int? startTime});

  ///
  /// 匿名登录。该方法可支持在不登录正式账号的情况下，临时加入会议。
  /// * 匿名账号池是共享的，不能保证每次登录都是同一个匿名账号。
  /// * 匿名登录后，如果不再使用匿名账号，需要业务方手动调用[logout]接口登出。
  ///
  Future<NEResult<void>> anonymousLogin();

  Future<NEResult<void>> tryAutoLogin();

  /// 获取用于创建或加入会议的会议服务。
  NEMeetingService getMeetingService();

  /// 获取用于邀请服务服务。
  NEMeetingInviteService getMeetingInviteService();

  /// 获取用于屏幕共享的会议服务。
  NEScreenSharingService getScreenSharingService();

  /// 获取用于查询账号信息的账号服务
  NEMeetingAccountService getAccountService();

  /// 获取会议设置服务
  NESettingsService getSettingsService();

  /// 获取会议前服务
  NEPreMeetingService getPreMeetingService();

  /// 获取会议直播服务
  NELiveMeetingService getLiveMeetingService();

  /// 获取文件服务
  NEMeetingNosService getNosService();

  /// 注销当前已登录的账号
  Future<NEResult<void>> logout();

  /// 上传日志并返回日志下载地址
  Future<NEResult<String?>> uploadLog();

  ///
  /// 获取设备Id
  ///
  Future<String> get deviceId;

  ///
  /// 埋点上报
  ///
  Future<dynamic> reportEvent(Event event, {String? userId});
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

  /// 会议已回收
  static const int meetingRecycled = MeetingErrorCode.meetingRecycled;

  /// 会议不存在
  static const int meetingNotExist = MeetingErrorCode.meetingNotExists;

  /// room 不存在
  static const int meetingNotInProgress = NEErrorCode.roomNotExist;

  /// 鉴权过期，如密码重置
  static const int authExpired = NEErrorCode.authExpired;

  /// 聊天室不存在
  static const int chatroomNotExists = 110001;
}

/// 房间登陆状态回调
abstract class NEMeetingAuthListener {
  /// 被踢出
  void onKickOut();

  /// 账号信息过期通知，原因为用户修改了密码，应用层随后应该重新登录
  void onAuthInfoExpired();

  /// 断线重连成功
  void onReconnected();
}

/// 自定义会话监听器
abstract mixin class NEMeetingMessageSessionListener {
  /// 接收到自定义消息
  void onReceiveSessionMessage(NEMeetingCustomSessionMessage message) {}

  /// 最近会话聊天记录变更
  void onChangeRecentSession(List<NEMeetingRecentSession> messages) {}

  /// 自定义消息被删除
  void onDeleteSessionMessage(NEMeetingCustomSessionMessage message) {}

  /// 自定义消息全部被删除
  void onDeleteAllSessionMessage(
      String sessionId, NEMeetingSessionTypeEnum sessionType) {}
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

class NEMeetingCustomSessionMessage {
  late final String? sessionId;
  late final NEMeetingSessionTypeEnum? sessionType;
  late final String? messageId;
  late final NotifyCardData? data;
  late final int time;

  NEMeetingCustomSessionMessage({
    this.sessionId,
    this.sessionType,
    this.messageId,
    this.data,
    int? time,
  }) : time = time ?? 0;

  NEMeetingCustomSessionMessage.fromMap(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    sessionType = NEMeetingSessionTypeEnumExtension.toType(json['sessionType']);
    messageId = json['messageId'];
    time = json['time'] ?? 0;
    data = json['data'] != null ? NotifyCardData.fromMap(json['data']) : null;
  }
}

/// 查询消息的参数
class NEMeetingGetMessagesHistoryParam {
  /// 会话ID
  final String sessionId;

  // /**
  //  * 会话类型
  //  */
  // final NEMeetingSessionTypeEnum sessionType;

  /// 开始时间（时间戳小）
  int? fromTime;

  /// 结束时间（时间戳大）
  int? toTime;

  /// 条数限制
  /// 限制0~100，否则414。其中0会被转化为100
  int? limit;

  /// 查询方向,默认从大到小排序
  NEMeetingMessageSearchOrder? order = NEMeetingMessageSearchOrder.kDesc;

  NEMeetingGetMessagesHistoryParam(
      {required this.sessionId,
      this.fromTime,
      this.toTime,
      this.limit,
      this.order});
}

/// 会话消息类型
///
enum NEMeetingSessionTypeEnum {
  /// 未知
  None,

  /// 通话场景
  P2P
}

/// 会话消息类型
///
enum NEMeetingMessageSearchOrder { kDesc, kAsc }

/// 会议消息类型
extension NEMeetingSessionTypeEnumExtension on NEMeetingSessionTypeEnum {
  static NEMeetingSessionTypeEnum toType(int? type) =>
      (NEMeetingSessionTypeEnum.values.firstWhere(
        (element) => element.index - 1 == type,
        orElse: () => NEMeetingSessionTypeEnum.None,
      ));
}

/// 最近联系人消息变更
class NEMeetingRecentSession {
  ///  获取聊天对象的Id（好友帐号，群ID等）
  /// [sessionId] 最近联系人帐号
  ///
  final String? sessionId;

  /// 获取与该联系人的最后一条消息的发送方的帐号
  /// [fromAccount] 发送者帐号
  final String? fromAccount;

  /// 获取与该联系人的最后一条消息的发送方的昵称
  /// [fromNick]发送者昵称
  ///
  final String? fromNick;

  /// 获取会话类型
  ///
  final NEMeetingSessionTypeEnum? sessionType;

  /// 最近一条消息的UUID
  final String? recentMessageId;

  /// 获取该联系人的未读消息条数
  /// 未读数
  final int unreadCount;

  /// 获取最近一条消息的缩略内容。<br></br>
  /// 对于文本消息，返回文本内容。<br></br>
  /// 对于其他消息，返回一个简单的说明内容。如需展示更详细，或其他需求，可根据[.getAttachment]生成。
  /// 缩略内容
  ///
  final String? content;

  /// 获取最近一条消息的时间，单位为ms
  ///
  final int time;

  NEMeetingRecentSession(
      this.sessionId,
      this.fromAccount,
      this.fromNick,
      this.sessionType,
      this.recentMessageId,
      this.unreadCount,
      this.content,
      this.time);
}
