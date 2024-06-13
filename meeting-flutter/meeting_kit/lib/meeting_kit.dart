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
import 'package:uuid/uuid.dart';
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
        NEMeetingItemStatus,
        NEMeetingItemSetting,
        NEPreRoomLiveInfo,
        NEMeetingLiveAuthLevel,
        NERoomItemLiveState,
        NEMeetingRoleConfiguration,
        NEWatermarkConfig,
        NERoomInvitation,
        NEMeetingControl,
        NEMeetingAudioControl,
        NEMeetingVideoControl,
        NEAccountInfo,
        NEMeetingAttendeeOffType,
        NEMeetingWebAppItem,
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
        NEScheduledMemberExt,
        NEMeetingCorpInfo,
        NEMeetingIdpInfo,
        NERemoteHistoryMeeting,
        NEChatroomInfo,
        NERemoteHistoryMeetingDetail,
        NEMeetingAppNoticeTips,
        NEMeetingAppNoticeTipType,
        NELoginInfo,
        NEMeetingAppNoticeTip;
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
part 'src/meeting_kit/impl/meeting_message_channel_service_impl.dart';
part 'src/meeting_kit/meeting_invite_service.dart';
part 'src/meeting_kit/impl/meeting_invite_service_impl.dart';
part 'src/meeting_kit/impl/pre_meeting_service_impl.dart';
part 'src/meeting_kit/impl/settings_service_impl.dart';
part 'src/meeting_kit/values/meeting_kit_strings.dart';
part 'src/meeting_kit/meeting_service.dart';
part 'src/meeting_kit/meeting_message_channel_service.dart';
part 'src/meeting_kit/pre_meeting_service.dart';
part 'src/meeting_kit/settings_service.dart';
part 'src/meeting_kit/live_meeting_service.dart';
part 'src/meeting_kit/impl/live_meeting_service_impl.dart';
part 'src/meeting_kit/module_name.dart';
part 'src/meeting_kit/log/log_service.dart';
part 'src/meeting_kit/manager/local_history_meeting_manager.dart';
part 'src/meeting_kit/utils/rtc_utils.dart';
part 'src/meeting_kit/utils/meeting_service_util.dart';
part 'src/meeting_kit/utils/session_message_notify_card_data.dart';
part 'src/meeting_kit/utils/network_task_executor.dart';
part 'src/meeting_kit/utils/connectivity_manager.dart';
part 'src/meeting_kit/utils/meeting_invite_queue_util.dart';
part 'src/meeting_kit/meeting_context.dart';
part 'src/meeting_kit/report/meeting_report.dart';
part 'src/meeting_kit/screen_sharing_service.dart';
part 'src/meeting_kit/meeting_web_app_bridge.dart';
part 'src/meeting_kit/contacts_service.dart';
part 'src/meeting_kit/impl/contacts_service_impl.dart';

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

///
/// 提供会议SDK初始化时必要的参数和配置信息
///
class NEMeetingKitConfig {
  ///
  /// 会议AppKey
  ///
  final String? appKey;

  /// 企业码，如果填写则会使用企业码进行初始化
  ///
  final String? corpCode;

  ///
  /// 企业邮箱，如果填写则会使用企业邮箱进行初始化
  ///
  final String? corpEmail;

  ///
  /// 默认语言
  ///
  final NEMeetingLanguage? language;

  ///
  /// 私有化地址
  ///
  final String? serverUrl;

  final NEMeetingKitServerConfig? serverConfig;

  ///
  /// 额外字段
  ///
  final Map<String, dynamic>? extras;

  NEMeetingKitConfig({
    this.appKey,
    this.corpCode,
    this.corpEmail,
    this.serverConfig,
    this.serverUrl,
    this.extras,
    this.language,
  });

  @override
  bool operator ==(other) {
    if (other is! NEMeetingKitConfig) {
      return false;
    }
    return appKey == other.appKey &&
        corpCode == other.corpCode &&
        corpEmail == other.corpEmail &&
        serverConfig == other.serverConfig &&
        serverUrl == other.serverUrl &&
        language == other.language &&
        mapEquals(extras, other.extras);
  }

  @override
  int get hashCode => Object.hash(
        appKey,
        corpCode,
        corpEmail,
        serverUrl,
        serverConfig,
        language,
        extras,
      );

  String? get _initializeKey => appKey ?? corpCode ?? corpEmail;

  @override
  String toString() {
    return 'NEMeetingKitConfig{$_initializeKey, $serverUrl}';
  }
}

/// 会议SDK全局接口，提供初始化、管理其他会议相关子服务的能力
abstract class NEMeetingKit {
  static final NEMeetingKit _instance = _NEMeetingKitImpl();

  ///
  /// 获取会议SDK实例
  ///
  static NEMeetingKit get instance => _instance;

  // todo
  ValueNotifier<bool> get loginStatusChangeNotifier;

  // todo
  NEMeetingKitConfig? get config;

  ///
  /// 初始化会议组件，只有在完成初始化后才能调用会议组件的其他接口。
  /// 可通过 [NEMeetingKitConfig.appKey] 初始化。也可以
  /// 通过企业代码[NEMeetingKitConfig.corpCode]或企业邮箱
  /// [NEMeetingKitConfig.corpEmail] 进行初始化，
  /// 通过企业信息初始化成功后会返回 [NEMeetingCorpInfo]。
  ///
  /// * [config]   初始化配置对象
  Future<NEResult<NEMeetingCorpInfo?>> initialize(NEMeetingKitConfig config);

  /// 查询会议SDK当前是否已经完成初始化
  bool get isInitialized;

  /// 登录鉴权。在已登录状态下可以创建和加入会议，但在未登录状态下只能加入会议
  ///
  /// * [username]   登录账号
  /// * [password]   登录密码
  ///
  @Deprecated('请使用[NEAccountService.loginByPassword]代替')
  Future<NEResult<void>> loginWithNEMeeting(String username, String password);

  /// 登录鉴权。在已登录状态下可以创建和加入会议，但在未登录状态下只能加入会议
  ///
  /// * [accountId]   登录账号
  /// * [token]     登录令牌
  @Deprecated('请使用[NEAccountService.loginByToken]代替')
  Future<NEResult<void>> loginWithToken(String accountId, String token);

  ///
  /// 自动登录鉴权
  ///
  @Deprecated('请使用[NEAccountService.tryAutoLogin]代替')
  Future<NEResult<void>> tryAutoLogin();

  ///
  /// 登出当前已登录的账号
  ///
  @Deprecated('请使用[NEAccountService.logout]代替')
  Future<NEResult<void>> logout();

  ///
  /// 获取用于创建或加入会议的会议服务。
  ///
  NEMeetingService getMeetingService();

  ///
  /// 获取用于登录登出、查询账号信息的账号服务。
  ///
  NEAccountService getAccountService();

  ///
  /// 获取会议设置服务。
  ///
  NESettingsService getSettingsService();

  ///
  /// 获取会前服务。
  ///
  NEPreMeetingService getPreMeetingService();

  ///
  /// 获取会议外投屏服务。
  ///
  NEScreenSharingService getScreenSharingService();

  ///
  /// 获取会议邀请服务。
  ///
  NEMeetingInviteService getMeetingInviteService();

  ///
  /// 获取会议消息通知服务。
  ///
  NEMeetingMessageChannelService getMeetingMessageChannelService();

  ///
  /// 获取通讯录服务。
  ///
  NEContactsService getContactsService();

  /// 添加登录状态监听器
  ///
  /// [listener] 监听器
  @Deprecated('请使用[NEAccountService.addListener]代替')
  void addAuthListener(NEAuthListener listener);

  /// 移除登录状态监听器
  ///
  /// [listener] 监听器
  @Deprecated('请使用[NEAccountService.removeListener]代替')
  void removeAuthListener(NEAuthListener listener);

  ///
  /// 切换语言
  /// * [language] 目标语言，类型为[NEMeetingLanguage]。如果设置为空，则使用当前系统语言。
  ///
  Future<NEResult<void>> switchLanguage(NEMeetingLanguage? language);

  ///
  /// 获取组件日志目录
  ///
  Future<String?> getSDKLogPath();

  ///
  /// 获取公告提示
  ///
  Future<NEResult<NEMeetingAppNoticeTips>> getAppNoticeTips();

  ///
  /// 当前语言
  ///
  //todo remove
  NEMeetingLanguage get currentLanguage;

  // todo
  ValueListenable<Locale> get localeListenable;

  // todo
  NEMeetingKitLocalizations get localizations =>
      NEMeetingKitLocalizations.ofLocale(localeListenable.value);

  ///
  /// 匿名登录。该方法可支持在不登录正式账号的情况下，临时加入会议。
  /// * 匿名账号池是共享的，不能保证每次登录都是同一个匿名账号。
  /// * 匿名登录后，如果不再使用匿名账号，需要业务方手动调用[logout]接口登出。
  ///
  Future<NEResult<void>> anonymousLogin();

  ///
  /// 上传日志并返回日志下载地址
  ///
  Future<NEResult<String?>> uploadLog();

  ///
  /// 获取设备 ID
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

  /// 企业不存在
  static const int corpNotFound = 1834;

  /// 账号需要重置密码才能允许登录
  static const int accountPasswordNeedReset = 3426;

  /// 企业不支持 SSO 登录
  static const int corpNotSupportSSO = 112002;

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

class NEMeetingSessionMessage {
  late final String? sessionId;
  late final NEMeetingSessionTypeEnum? sessionType;
  late final String? messageId;
  late final NotifyCardData? data;

  /// 时间戳，单位为ms
  late final int time;

  NEMeetingSessionMessage({
    this.sessionId,
    this.sessionType,
    this.messageId,
    this.data,
    int? time,
  }) : time = time ?? 0;

  NEMeetingSessionMessage.fromMap(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    sessionType = NEMeetingSessionTypeEnumExtension.toType(json['sessionType']);
    messageId = json['messageId'];
    time = json['time'] ?? 0;
    data = json['data'] != null ? NotifyCardData.fromMap(json['data']) : null;
  }

  toMap() {
    final Map<String, dynamic> dataMap = Map<String, dynamic>();
    dataMap['sessionId'] = sessionId;
    dataMap['sessionType'] = sessionType?.value;
    dataMap['messageId'] = messageId;
    dataMap['time'] = time;
    if (data != null) {
      dataMap['data'] = data!.toMap();
    }
    return dataMap;
  }
}

/// 查询自定义消息历史的参数
class NEMeetingGetMessageHistoryParams {
  /// 获取聊天对象的Id（好友帐号，群ID等） 会话Id
  final String sessionId;

  /// 查询开启时间点
  int? fromTime;

  /// 查询截止时间点
  int? toTime;

  /// 条数限制
  /// 限制0~100，否则414。其中0会被转化为100
  int? limit;

  /// 查询方向,默认从大到小排序
  NEMeetingMessageSearchOrder? order = NEMeetingMessageSearchOrder.kDesc;

  NEMeetingGetMessageHistoryParams(
      {required this.sessionId,
      this.fromTime,
      this.toTime,
      this.limit,
      this.order});

  NEMeetingGetMessageHistoryParams.fromMap(Map<String, dynamic> json)
      : sessionId = json['sessionId'] ?? '',
        fromTime = json['fromTime'] ?? 0,
        toTime = json['toTime'] ?? 0,
        limit = json['limit'] ?? 0,
        order = NEMeetingMessageSearchOrderExtension.toType(
            json['order'] ?? NEMeetingMessageSearchOrder.kDesc);
}

extension NEMeetingMessageSearchOrderExtension on NEMessageSearchOrder {
  static NEMeetingMessageSearchOrder toType(int? type) =>
      (NEMeetingMessageSearchOrder.values.firstWhere(
        (element) => element.index == type,
        orElse: () => NEMeetingMessageSearchOrder.kDesc,
      ));
}

/// 会话消息类型
///
enum NEMeetingSessionTypeEnum {
  /// 未知
  None(-1),

  /// 个人会话
  P2P(0);

  final int value;
  const NEMeetingSessionTypeEnum(this.value);
}

/// 消息查询方向
///
enum NEMeetingMessageSearchOrder {
  /// 从小到大,降序
  kDesc,

  /// 从大到小,升序
  kAsc,
}

/// 会议消息类型
extension NEMeetingSessionTypeEnumExtension on NEMeetingSessionTypeEnum {
  static NEMeetingSessionTypeEnum toType(int? type) =>
      (NEMeetingSessionTypeEnum.values.firstWhere(
        (element) => element.value == type,
        orElse: () => NEMeetingSessionTypeEnum.None,
      ));
}

/// 最近联系人消息变更
class NEMeetingRecentSession {
  ///  获取聊天对象的Id（好友帐号，群ID等）
  /// [sessionId] 会话Id
  ///
  final String? sessionId;

  /// 获取与该联系人的最后一条消息的发送方的帐号
  /// [fromAccount] 发送者帐号
  final String? fromAccount;

  /// 获取与该联系人的最后一条消息的发送方的昵称
  /// [fromNick]发送者昵称
  ///
  final String? fromNick;

  /// 会话类型
  ///
  final NEMeetingSessionTypeEnum? sessionType;

  /// 最近一条消息的UUID
  final String? recentMessageId;

  /// 该联系人的未读消息条数
  /// 未读数
  final int unreadCount;

  /// 最近一条消息的缩略内容
  final String? content;

  /// 最近一条消息的时间，单位为ms
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

  toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['sessionId'] = sessionId;
    data['fromAccount'] = fromAccount;
    data['fromNick'] = fromNick;
    data['sessionType'] = sessionType?.value;
    data['recentMessageId'] = recentMessageId;
    data['unreadCount'] = unreadCount;
    data['content'] = content;
    data['time'] = time;
    return data;
  }
}
