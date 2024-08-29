// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

///
/// 提供创建和加入会议时必要的基本配置信息和选项开关，通过这些配置和选项可控制入会时的行为，如音视频的开启状态等
///
class NEMeetingOptions {
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
  late final bool? showMeetingTime;

  /// 配置是否始终在视频画面上显示名字，默认显示
  late final bool? showNameInVideo;

  /// 配置是否在会议界面中显示聊天入口
  late final bool noChat;

  /// 配置是否在会议界面中显示直播入口
  late final bool noLive;

  /// 配置是否在会议界面中显示邀请入口
  late final bool noInvite;

  /// 配置是否显示 **sip功能菜单**
  late final bool noSip;

  /// 配置是否开启最小化会议页面入口
  late final bool noMinimize;

  /// 配置会中退后台是否自动小窗，默认自动小窗，仅iOS有效
  late final bool enablePictureInPicture;

  /// 配置是否开启画廊入口
  late final bool noGallery;

  /// 配置会议中是否显示"切换摄像头"按钮
  late final bool noSwitchCamera;

  /// 配置会议中是否显示"切换音频模式"按钮
  late final bool noSwitchAudioMode;

  /// 配置会议中是否显示"共享白板"按钮
  late final bool noWhiteBoard;

  ///
  /// 是否开启透明白板模式
  ///
  late final bool? enableTransparentWhiteboard;

  /// 配置会议中是否开启前置摄像头视频镜像，默认开启
  late final bool? enableFrontCameraMirror;

  /// 配置会议中是否显示"改名"菜单
  late final bool noRename;

  /// 配置默认会议模式[WindowMode]
  late final int defaultWindowMode;

  /// 会议中的"会议号"显示规则
  late final int meetingIdDisplayOption;

  /// 配置是否展示云录制菜单按钮, SDKConfig支持云录制时有效
  late final bool showCloudRecordMenuItem;

  /// 配置是否展示云录制过程中的UI提示
  late final bool showCloudRecordingUI;

  /// "Toolbar"自定义菜单
  late final List<NEMeetingMenuItem>? fullToolbarMenuItems;

  /// "更多"自定义菜单，可添加监听器处理菜单点击事件
  late final List<NEMeetingMenuItem>? fullMoreMenuItems;

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

  ///
  /// 是否开启麦克风静音检测，默认开启。
  /// 开启该功能后，SDK在检测到麦克风有音频输入，
  /// 但此时处于静音打开的状态时，会提示用户关闭静音。
  ///
  late final bool detectMutedMic;

  ///
  /// 本地静音时，是否关闭静音包发送。默认为true，即关闭静音包。
  ///
  late final bool unpubAudioOnMute;

  ///
  /// 配置会议中主页是否显示屏幕共享者的摄像头画面，当前正在共享的内容画面不受影响。
  /// 如果设置为关闭，屏幕共享者的摄像头画面会被隐藏，不会遮挡共享内容画面。
  /// 默认为 true，即显示。
  ///
  late final bool showScreenShareUserVideo;

  ///
  /// 配置会议中主页是否显示白板共享者的摄像头画面。
  /// 如果设置为开启，白板共享者的摄像头画面会以小窗口的方法覆盖在白板画面上显示。
  /// 默认为 false，即不显示。
  ///
  late final bool showWhiteboardShareUserVideo;

  ///
  /// 配置会议中是否显示麦克风浮窗，默认为显示
  ///
  late final bool showFloatingMicrophone;

  /// 聊天室相关配置
  late final NEMeetingChatroomConfig? chatroomConfig;

  ///
  /// 开启/关闭音频共享功能。
  /// 开启后，在发起屏幕共享时，会同时自动开启设备的音频共享；
  /// 关闭后，在发起屏幕共享时，不会自动打开音频共享，但可以通过UI手动开启音频共享。
  /// 该设置默认为开启。
  ///
  late final bool enableAudioShare;

  ///
  /// 配置会议是否默认开启等候室。如果初始设置为不开启，管理员也可以后续在会中手动开启/关闭等候室。
  /// 开启等候室后，参会者需要管理员同意后才能加入会议。
  ///
  /// 仅创建会议时有效
  late final bool enableWaitingRoom;

  /// 开启/关闭语音激励
  late final bool? enableSpeakerSpotlight;

  ///
  /// 是否允许SDK请求电话权限，默认允许。在获取电话权限后，SDK会监听系统电话状态，在接听来电或拨打电话时，
  /// 会自动断开会议内的音视频（不会退出会议），并在系统电话结束后，自动重新连接会议的音视频。
  /// 仅对 Android 平台有效。
  ///
  late final bool noReadPhoneState;

  /// 配置会议中是否展示 web 小应用，如签到应用。默认展示。
  late final bool noWebApps;

  ///
  /// 配置会议中是否展示通知中心菜单，默认展示。
  ///
  late final bool noNotifyCenter;

  /// 是否允许访客入会，仅创建会议时有效
  late final bool enableGuestJoin;

  /// 配置会中是否展示“字幕”菜单，默认展示。
  late final bool noCaptions;

  /// 配置入会后是否自动开启“字幕”，默认不开启。
  late final bool autoEnableCaptionsOnJoin;

  /// 配置会中是否展示“转写”菜单，默认展示。
  late final bool noTranscription;

  /// 云录制配置，仅创建会议时有效
  late final NECloudRecordConfig? cloudRecordConfig;

  /// 配置新聊天消息提醒类型
  late final NEChatMessageNotificationType? chatMessageNotificationType;

  /// 配置会中插件通知弹窗持续时间，单位毫秒(ms)，默认5000ms；value=0时，不显示通知弹窗；value<0时，弹窗不自动消失。
  late final int pluginNotifyDuration;

  /// 配置是否在会议界面中显示未加入成员,默认展示。
  late final bool? showNotYetJoinedMembers;

  /// 配置主持人和联席主持人是否可以直接开关参会者的音视频，不需要参会者同意，默认需要参会者同意。
  late final bool enableDirectMemberMediaControlByHost;

  NEMeetingOptions.fromJson(Map<String, dynamic> json) {
    title = json['title'] as String?;
    noVideo = (json['noVideo'] ?? true) as bool;
    noAudio = (json['noAudio'] ?? true) as bool;
    noMuteAllVideo = (json['noMuteAllVideo'] ?? true) as bool;
    noMuteAllAudio = (json['noMuteAllAudio'] ?? false) as bool;
    showMeetingTime = json['showMeetingTime'] as bool?;
    showNameInVideo = json['showNameInVideo'] as bool?;
    noChat = (json['noChat'] ?? false) as bool;
    noLive = (json['noLive'] ?? false) as bool;
    noInvite = (json['noInvite'] ?? false) as bool;
    noSip = (json['noSip'] ?? false) as bool;
    noMinimize = (json['noMinimize'] ?? true) as bool;
    enablePictureInPicture = (json['enablePictureInPicture'] ?? false) as bool;
    noGallery = (json['noGallery'] ?? false) as bool;
    noSwitchCamera = (json['noSwitchCamera'] ?? false) as bool;
    noSwitchAudioMode = (json['noSwitchAudioMode'] ?? false) as bool;
    noWhiteBoard = (json['noWhiteBoard'] ?? false) as bool;
    noRename = (json['noRename'] ?? false) as bool;
    if (json['cloudRecordConfig'] != null) {
      cloudRecordConfig = NECloudRecordConfig.fromJson(
          Map<String, dynamic>.from(json['cloudRecordConfig'] as Map));
    } else if (json['noCloudRecord'] != null) {
      /// 兼容老版本
      var enable = !((json['noCloudRecord'] ?? true) as bool);
      cloudRecordConfig = NECloudRecordConfig(enable: enable);
    } else {
      cloudRecordConfig = null;
    }
    defaultWindowMode = (json['defaultWindowMode'] ?? 0) as int;
    meetingIdDisplayOption = (json['meetingIdDisplayOption'] ?? gallery) as int;
    restorePreferredOrientations = <DeviceOrientation>[];
    fullToolbarMenuItems =
        buildMenuItemList(json['fullToolbarMenuItems'] as List?);
    fullMoreMenuItems = buildMenuItemList(json['fullMoreMenuItems'] as List?);
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
    detectMutedMic = (json['detectMutedMic'] ?? true) as bool;
    unpubAudioOnMute = (json['unpubAudioOnMute'] ?? true) as bool;
    showScreenShareUserVideo =
        (json['showScreenShareUserVideo'] ?? true) as bool;
    showWhiteboardShareUserVideo =
        (json['showWhiteboardShareUserVideo'] ?? false) as bool;
    showFloatingMicrophone = (json['showFloatingMicrophone'] ?? true) as bool;
    enableTransparentWhiteboard = json['enableTransparentWhiteboard'] as bool?;
    enableFrontCameraMirror = json['enableFrontCameraMirror'] as bool?;
    enableAudioShare = (json['enableAudioShare'] ?? false) as bool;
    showCloudRecordMenuItem = (json['showCloudRecordMenuItem'] ?? true) as bool;
    showCloudRecordingUI = (json['showCloudRecordingUI'] ?? true) as bool;
    enableWaitingRoom = (json['enableWaitingRoom'] ?? false) as bool;
    enableSpeakerSpotlight = json['enableSpeakerSpotlight'] as bool?;
    noReadPhoneState = (json['noReadPhoneState'] ?? false) as bool;
    noWebApps = (json['noWebApps'] ?? false) as bool;
    noNotifyCenter = (json['noNotifyCenter'] ?? false) as bool;
    enableGuestJoin = (json['enableGuestJoin'] ?? false) as bool;
    noCaptions = (json['noCaptions'] ?? false) as bool;
    noTranscription = (json['noTranscription'] ?? false) as bool;
    autoEnableCaptionsOnJoin =
        (json['autoEnableCaptionsOnJoin'] ?? false) as bool;
    chatMessageNotificationType =
        NEChatMessageNotificationTypeExtension.mapValueToEnum(
            json['chatMessageNotificationType']);
    pluginNotifyDuration = json['pluginNotifyDuration'] ?? 5000;
    showNotYetJoinedMembers = json['showNotYetJoinedMembers'] as bool?;
    enableDirectMemberMediaControlByHost =
        (json['enableDirectMemberMediaControlByHost'] ?? false) as bool;
  }

  NEMeetingOptions({
    this.title,
    this.noVideo = true,
    this.noAudio = true,
    this.noMuteAllVideo = true,
    this.noMuteAllAudio = false,
    this.showMeetingTime,
    this.showNameInVideo = true,
    this.noChat = false,
    this.noInvite = false,
    this.noSip = false,
    this.noMinimize = true,
    this.enablePictureInPicture = false,
    this.noGallery = false,
    this.noSwitchAudioMode = false,
    this.noSwitchCamera = false,
    this.noWhiteBoard = false,
    this.noRename = false,
    this.defaultWindowMode = gallery,
    this.meetingIdDisplayOption = NEMeetingIdDisplayOption.displayAll,
    this.joinTimeout = NEMeetingConstants.meetingJoinTimeout,
    this.restorePreferredOrientations = const <DeviceOrientation>[],
    this.showMemberTag = false,
    this.showMeetingRemainingTip = false,
    this.detectMutedMic = true,
    this.unpubAudioOnMute = true,
    this.showScreenShareUserVideo = true,
    this.showWhiteboardShareUserVideo = false,
    this.showFloatingMicrophone = true,
    this.enableTransparentWhiteboard,
    this.enableFrontCameraMirror,
    this.enableAudioShare = false,
    this.noLive = false,
    this.extras = const <String, dynamic>{},
    this.chatroomConfig,
    this.audioProfile,
    this.showCloudRecordMenuItem = true,
    this.showCloudRecordingUI = true,
    this.enableWaitingRoom = false,
    this.enableSpeakerSpotlight,
    this.noReadPhoneState = false,
    this.noWebApps = false,
    this.noNotifyCenter = false,
    this.enableGuestJoin = false,
    this.noCaptions = false,
    this.noTranscription = false,
    this.autoEnableCaptionsOnJoin = false,
    this.cloudRecordConfig,
    this.chatMessageNotificationType,
    this.pluginNotifyDuration = 5000,
    this.showNotYetJoinedMembers,
    this.fullToolbarMenuItems,
    this.fullMoreMenuItems,
    this.enableDirectMemberMediaControlByHost = false,
  });

  bool get isLongMeetingIdEnabled =>
      meetingIdDisplayOption == NEMeetingIdDisplayOption.displayAll ||
      meetingIdDisplayOption == NEMeetingIdDisplayOption.displayLongIdOnly;

  bool get isShortMeetingIdEnabled =>
      meetingIdDisplayOption == NEMeetingIdDisplayOption.displayAll ||
      meetingIdDisplayOption == NEMeetingIdDisplayOption.displayShortIdOnly;

  /// 拷贝函数
  NEMeetingOptions copyWith({
    bool? noVideo,
    bool? noAudio,
  }) {
    return NEMeetingOptions(
      title: title,
      noVideo: noVideo ?? this.noVideo,
      noAudio: noAudio ?? this.noAudio,
      noMuteAllVideo: noMuteAllVideo,
      noMuteAllAudio: noMuteAllAudio,
      showMeetingTime: showMeetingTime,
      showNameInVideo: showNameInVideo,
      noChat: noChat,
      noInvite: noInvite,
      noSip: noSip,
      noMinimize: noMinimize,
      enablePictureInPicture: enablePictureInPicture,
      noGallery: noGallery,
      noSwitchCamera: noSwitchCamera,
      noSwitchAudioMode: noSwitchAudioMode,
      noWhiteBoard: noWhiteBoard,
      enableTransparentWhiteboard: enableTransparentWhiteboard,
      enableFrontCameraMirror: enableFrontCameraMirror,
      noRename: noRename,
      defaultWindowMode: defaultWindowMode,
      meetingIdDisplayOption: meetingIdDisplayOption,
      restorePreferredOrientations: restorePreferredOrientations,
      joinTimeout: joinTimeout,
      showMemberTag: showMemberTag,
      noLive: noLive,
      showMeetingRemainingTip: showMeetingRemainingTip,
      detectMutedMic: detectMutedMic,
      unpubAudioOnMute: unpubAudioOnMute,
      showScreenShareUserVideo: showScreenShareUserVideo,
      showWhiteboardShareUserVideo: showWhiteboardShareUserVideo,
      showFloatingMicrophone: showFloatingMicrophone,
      chatroomConfig: chatroomConfig,
      audioProfile: audioProfile,
      enableAudioShare: enableAudioShare,
      enableWaitingRoom: enableWaitingRoom,
      enableSpeakerSpotlight: enableSpeakerSpotlight,
      noReadPhoneState: noReadPhoneState,
      noWebApps: noWebApps,
      noNotifyCenter: noNotifyCenter,
      enableGuestJoin: enableGuestJoin,
      showCloudRecordMenuItem: showCloudRecordMenuItem,
      showCloudRecordingUI: showCloudRecordingUI,
      cloudRecordConfig: cloudRecordConfig,
      fullToolbarMenuItems: fullToolbarMenuItems,
      fullMoreMenuItems: fullMoreMenuItems,
      noCaptions: noCaptions,
      noTranscription: noTranscription,
      autoEnableCaptionsOnJoin: autoEnableCaptionsOnJoin,
      chatMessageNotificationType: chatMessageNotificationType,
      pluginNotifyDuration: pluginNotifyDuration,
      showNotYetJoinedMembers: showNotYetJoinedMembers,
      enableDirectMemberMediaControlByHost:
          enableDirectMemberMediaControlByHost,
    );
  }
}

/// 控制会议内"会议号"的显示规则
class NEMeetingIdDisplayOption {
  /// 长短号存在时都显示，默认规则
  static const int displayAll = 0;

  /// 不管是否存在短号，都只显示长号
  static const int displayLongIdOnly = 1;

  /// 长短号都存在时，只显示短号；若无短号，则显示长号
  static const int displayShortIdOnly = 2;
}
