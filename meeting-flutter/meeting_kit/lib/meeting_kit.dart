// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library meeting_kit;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
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

import 'package:netease_meeting_kit/meeting_core.dart';

import 'meeting_feedback.dart';

export 'package:netease_common/netease_common.dart' show NEResult, VoidResult;
export 'package:netease_meeting_kit/meeting_plugin.dart'
    show NEForegroundServiceConfig;
export 'package:netease_meeting_kit/meeting_core.dart'
    hide SDKConfig
    show
        NEMeetingErrorCode,
        NEMeetingKitConfig,
        NEMeetingLanguage,
        NEAccountServiceListener,
        NEMeetingItem,
        NEMeetingType,
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
        NEMeetingItemLive,
        NEMeetingInterpretationSettings,
        NEMeetingInterpreter,
        NEInterpretationLanguages,
        NEServiceBundle,
        NEMeetingAppNoticeTip,
        NEMeetingInviteInfo,
        NEMeetingInviteStatus,
        NEMeetingSessionMessage,
        NEMeetingGetMessageHistoryParams,
        NEMeetingSessionTypeEnum,
        NEMeetingMessageSearchOrder,
        NEMeetingRecentSession,
        NEMeetingMessageChannelListener,
        InviteJoinActionType,
        NotifyCardData,
        CardData,
        NotifyCard,
        Header,
        NELocalHistoryMeeting,
        NEJoinMeetingParams,
        NEStartMeetingParams,
        NEMeetingTranscriptionMessage,
        NEMeetingTranscriptionInterval,
        NEMeetingTranscriptionInfo,
        NEMeetingASRTranslationLanguage,
        NESettingsChangedListener,
        LocalHistoryMeetingManager,
        ConnectivityManager,
        ConnectivityWatcher,
        ConnectivityChangedBuilder,
        NEFeedback;
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
part 'src/meeting_kit/meeting_service.dart';
part 'src/meeting_kit/meeting_message_channel_service.dart';
part 'src/meeting_kit/pre_meeting_service.dart';
part 'src/meeting_kit/settings_service.dart';
part 'src/meeting_kit/module_name.dart';
part 'src/meeting_kit/utils/rtc_utils.dart';
part 'src/meeting_kit/utils/network_task_executor.dart';
part 'src/meeting_kit/screen_sharing_service.dart';
part 'src/meeting_kit/meeting_web_app_bridge.dart';
part 'src/meeting_kit/contacts_service.dart';
part 'src/meeting_kit/impl/contacts_service_impl.dart';
part 'src/meeting_kit/feedback_service.dart';
part 'src/meeting_kit/impl/feedback_service_impl.dart';

/// 会议SDK全局接口，提供初始化、管理其他会议相关子服务的能力
abstract class NEMeetingKit {
  static final NEMeetingKit _instance = _NEMeetingKitImpl();

  ///
  /// 获取会议SDK实例
  ///
  static NEMeetingKit get instance => _instance;

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

  ///
  /// 获取意见反馈服务。
  ///
  NEFeedbackService getFeedbackService();

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
  /// 更新APNS推送token（仅iOS有效）
  ///
  /// * [data] APNS Token
  /// * [key]  自定义本端推送内容, 设置key可对应业务服务器自定义推送文案; 传"" 清空配置, null 则不更改
  ///
  Future<NEResult<String?>> updateApnsToken(String data, String? key);

  ///
  /// 获取设备 ID
  ///
  Future<String> get deviceId;
}
