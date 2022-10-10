// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

///
/// 提供创建和加入会议时必要的基本配置信息和选项开关，通过这些配置和选项可控制入会时的行为，如音视频的开启状态等
///
class NEMeetingUIOptions {
  /// 会议标题
  late final String? title;

  /// 配置入会时是否关闭本端视频，默认为true，即关闭视频，但在房间中可重新打开
  late final bool noVideo;

  /// 配置入会时是否关闭本端音频，默认为true，即关闭音频，但在房间中可重新打开
  late final bool noAudio;

  /// 音频选项
  late final NERoomAudioProfile? audioProfile;

  /// 额外选项
  late final Map<String, dynamic> extras;

  /// 配置是否在会议界面中显示会议时长
  late final bool showMeetingTime;

  /// 配置是否在会议界面中显示聊天入口
  late final bool noChat;

  /// 配置是否在会议界面中显示邀请入口
  late final bool noInvite;

  /// 配置是否显示 **sip功能菜单**
  late final bool noSip;

  /// 配置是否开启最小化会议页面入口
  late final bool noMinimize;

  /// 配置是否开启画廊入口
  late final bool noGallery;

  /// 配置会议中是否显示"切换摄像头"按钮
  late final bool noSwitchCamera;

  /// 配置会议中是否显示"切换音频模式"按钮
  late final bool noSwitchAudioMode;

  /// 配置会议中是否显示"共享白板"按钮
  late final bool noWhiteBoard;

  /// 配置会议中是否显示"改名"菜单
  late final bool noRename;

  /// 配置会议中是否显示显示云端录制状态
  late final bool noCloudRecord;

  /// 配置默认会议模式[WindowMode]
  late final int defaultWindowMode;

  /// 会议中的"会议号"显示规则
  late final int meetingIdDisplayOption;

  /// "Toolbar"自定义菜单
  late final List<NEMeetingMenuItem> injectedToolbarMenuItems;

  /// "更多"自定义菜单，可添加监听器处理菜单点击事件
  late final List<NEMeetingMenuItem> injectedMoreMenuItems;

  /// 页面退出恢复页面原始方向
  late final List<DeviceOrientation> restorePreferredOrientations;

  /// 入会超时时间，单位为毫秒
  late final int joinTimeout;

  /// 配置是否显示 [NEJoinMeetingParams.tag] 字段。
  late final bool showMemberTag;

  /// 配置会议中成员列表是否显示"全体关闭/打开视频"，默认为true，即不显示
  late final bool noMuteAllVideo;

  /// 配置会议中成员列表是否显示"全体禁音/解除全体静音"，默认为false，即显示
  late final bool noMuteAllAudio;

  /// 配置会议中是否开启剩余时间提醒
  late final bool showMeetingRemainingTip;

  /// 聊天室相关配置
  late final NEMeetingChatroomConfig? chatroomConfig;

  NEMeetingUIOptions.fromJson(Map<String, dynamic> json) {
    title = json['title'] as String?;
    noVideo = (json['noVideo'] ?? true) as bool;
    noAudio = (json['noAudio'] ?? true) as bool;
    noMuteAllVideo = (json['noMuteAllVideo'] ?? true) as bool;
    noMuteAllAudio = (json['noMuteAllAudio'] ?? false) as bool;
    showMeetingTime = (json['showMeetingTime'] ?? true) as bool;
    noChat = (json['noChat'] ?? false) as bool;
    noInvite = (json['noInvite'] ?? false) as bool;
    noSip = (json['noSip'] ?? false) as bool;
    noMinimize = (json['noMinimize'] ?? true) as bool;
    noGallery = (json['noGallery'] ?? false) as bool;
    noSwitchCamera = (json['noSwitchCamera'] ?? false) as bool;
    noSwitchAudioMode = (json['noSwitchAudioMode'] ?? false) as bool;
    noWhiteBoard = (json['noWhiteBoard'] ?? false) as bool;
    noRename = (json['noRename'] ?? false) as bool;
    noCloudRecord = (json['noCloudRecord'] ?? true) as bool;
    defaultWindowMode = (json['defaultWindowMode'] ?? 0) as int;
    meetingIdDisplayOption = (json['meetingIdDisplayOption'] ?? gallery) as int;
    restorePreferredOrientations = <DeviceOrientation>[];
    injectedToolbarMenuItems =
        buildMenuItemList(json['fullToolbarMenuItems'] as List?) ??
            NEMenuItems.defaultToolbarMenuItems;
    injectedMoreMenuItems =
        buildMenuItemList(json['fullMoreMenuItems'] as List?) ??
            NEMenuItems.defaultMoreMenuItems;
    joinTimeout =
        (json['joinTimeout'] as int?) ?? NEMeetingConstants.meetingJoinTimeout;
    audioProfile = json['audioProfile'] == null
        ? null
        : NERoomAudioProfile.fromJson(
            Map<String, dynamic>.from(json['audioProfile'] as Map));
    showMemberTag = (json['showMemberTag'] ?? false) as bool;
    showMeetingRemainingTip =
        (json['showMeetingRemainingTip'] ?? false) as bool;
    chatroomConfig =
        NEMeetingChatroomConfig.fromJson(json['chatroomConfig'] as Map?);
    extras = (json['extras'] ?? <String, dynamic>{}) as Map<String, dynamic>;
  }

  NEMeetingUIOptions({
    this.title,
    bool? noVideo,
    bool? noAudio,
    bool? showMeetingTime,
    bool? noChat,
    bool? noInvite,
    bool? noSip,
    bool? noMinimize,
    bool? noGallery,
    bool? noSwitchAudioMode,
    bool? noSwitchCamera,
    bool? noWhiteBoard,
    bool? noRename,
    bool? noCloudRecord,
    int? defaultWindowMode = gallery,
    int? meetingIdDisplayOption,
    int? joinTimeout,
    bool? audioAINSEnabled,
    bool? showMemberTag,
    bool? noMuteAllVideo,
    bool? noMuteAllAudio,
    bool? showMeetingRemainingTip,
    this.chatroomConfig,
    this.audioProfile,
    List<DeviceOrientation>? restorePreferredOrientations,
    List<NEMeetingMenuItem>? injectedToolbarMenuItems,
    List<NEMeetingMenuItem>? injectedMoreMenuItems,
    Map<String, dynamic>? extras,
  }) {
    this.noVideo = noVideo ?? true;
    this.noAudio = noAudio ?? true;
    this.noMuteAllVideo = noMuteAllVideo ?? true;
    this.noMuteAllAudio = noMuteAllAudio ?? false;
    this.showMeetingTime = showMeetingTime ?? true;
    this.noChat = noChat ?? false;
    this.noInvite = noInvite ?? false;
    this.noSip = noSip ?? false;
    this.noMinimize = noMinimize ?? true;
    this.noGallery = noGallery ?? false;
    this.noSwitchAudioMode = noSwitchAudioMode ?? false;
    this.noSwitchCamera = noSwitchCamera ?? false;
    this.noWhiteBoard = noWhiteBoard ?? false;
    this.noRename = noRename ?? false;
    this.noCloudRecord = noCloudRecord ?? true;
    this.defaultWindowMode = defaultWindowMode ?? gallery;
    this.meetingIdDisplayOption = meetingIdDisplayOption ?? 0;
    this.joinTimeout = joinTimeout ?? NEMeetingConstants.meetingJoinTimeout;
    this.restorePreferredOrientations =
        restorePreferredOrientations ?? <DeviceOrientation>[];
    this.injectedToolbarMenuItems =
        injectedToolbarMenuItems ?? NEMenuItems.defaultToolbarMenuItems;
    this.injectedMoreMenuItems =
        injectedMoreMenuItems ?? NEMenuItems.defaultMoreMenuItems;
    this.extras = extras ?? <String, dynamic>{};
    this.showMemberTag = showMemberTag ?? false;
    this.showMeetingRemainingTip = showMeetingRemainingTip ?? false;
  }

  bool get isLongMeetingIdEnabled =>
      meetingIdDisplayOption == MeetingIdDisplayOption.displayAll ||
      meetingIdDisplayOption == MeetingIdDisplayOption.displayLongIdOnly;

  bool get isShortMeetingIdEnabled =>
      meetingIdDisplayOption == MeetingIdDisplayOption.displayAll ||
      meetingIdDisplayOption == MeetingIdDisplayOption.displayShortIdOnly;
}

class MeetingIdDisplayOption {
  static const int displayAll = 0;

  static const int displayLongIdOnly = 1;

  static const int displayShortIdOnly = 2;
}
