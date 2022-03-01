// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

/// 提供创建会议时必要的额外参数，如会议ID、用户会议昵称,tag等
class NEStartMeetingParams extends NEStartRoomParams {
  NEStartMeetingParams({
    String? meetingId,
    required String displayName,
    String? password,
    String? tag,
    NERoomScene? scene,
  }) : super(
          roomId: meetingId,
          displayName: displayName,
          password: password,
          tag: tag,
          scene: scene,
        );

  NEStartMeetingParams.fromMap(Map map,)
      : this(
          meetingId: map['meetingId'] as String?,
          displayName: (map['displayName'] ?? '') as String,
          password: map['password'] as String?,
          tag: map['tag'] as String?,
          scene: map['scene'] as NERoomScene?,
        );
}

/// 提供加入会议时必要的额外参数，如会议ID、用户会议昵称,tag等
class NEJoinMeetingParams extends NEJoinRoomParams {
  NEJoinMeetingParams({
    required String meetingId,
    required String displayName,
    String? password,
    String? tag,
  }) : super(
          roomId: meetingId,
          displayName: displayName,
          password: password,
          tag: tag,
        );

  NEJoinMeetingParams.fromMap(Map map)
      : this(
          meetingId: map['meetingId'] as String,
          displayName: (map['displayName'] ?? '') as String,
          password: map['password'] as String?,
          tag: map['tag'] as String?,
        );
}

enum NEMeetingMode {
  none,

  uncheck,

  checked,
}

/// 提供创建和加入会议时必要的基本配置信息和选项开关，通过这些配置和选项可控制入会时的行为，如音视频的开启状态等
///
/// See also:
/// * [NEStartMeetingOptions]
/// * [NEJoinMeetingOptions]
class NEMeetingOptions extends NERoomOptions {
  /// 配置入会时是否关闭本端视频，默认为true，即关闭视频，但在会议中可重新打开
  @override
  late final bool noVideo;

  /// 配置入会时是否关闭本端音频，默认为true，即关闭音频，但在会议中可重新打开
  @override
  late final bool noAudio;

  /// 配置是否在会议界面中显示会议时长
  late final bool showMeetingTime;

  /// 配置是否在会议界面中显示聊天入口
  late final bool noChat;

  /// 配置是否在会议界面中显示邀请入口
  late final bool noInvite;

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

  /// 配置默认会议模式[WhiteBoardUtil]
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

  /// 额外选项
  @override
  late final Map<String, dynamic> extras;

  NEMeetingOptions.fromJson(Map<String, dynamic> json) {
    noVideo = (json['noVideo'] ?? true) as bool;
    noAudio = (json['noAudio'] ?? true) as bool;
    showMeetingTime = (json['showMeetingTime'] ?? true) as bool;
    noChat = (json['noChat'] ?? false) as bool;
    noInvite = (json['noInvite'] ?? false) as bool;
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
    injectedToolbarMenuItems = buildMenuItemList(json['fullToolbarMenuItems'] as List?) ?? NEMenuItems.defaultToolbarMenuItems;
    injectedMoreMenuItems = buildMenuItemList(json['fullMoreMenuItems'] as List?) ?? NEMenuItems.defaultMoreMenuItems;
    joinTimeout = (json['joinTimeout'] as int?) ?? NEMeetingConstants.meetingJoinTimeout;;
    extras = (json['extras'] ?? <String, dynamic>{}) as Map<String, dynamic>;
  }

  NEMeetingOptions({
    bool? noVideo,
    bool? noAudio,
    bool? showMeetingTime,
    bool? noChat,
    bool? noInvite,
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
    List<DeviceOrientation>? restorePreferredOrientations,
    List<NEMeetingMenuItem>? injectedToolbarMenuItems,
    List<NEMeetingMenuItem>? injectedMoreMenuItems,
    Map<String, dynamic>? extras,
  }) {
    this.noVideo = noVideo ?? true;
    this.noAudio = noAudio ?? true;
    this.showMeetingTime = showMeetingTime ?? true;
    this.noChat = noChat ?? false;
    this.noInvite = noInvite ?? false;
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
    this.restorePreferredOrientations = restorePreferredOrientations ?? <DeviceOrientation>[];
    this.injectedToolbarMenuItems = injectedToolbarMenuItems ?? NEMenuItems.defaultToolbarMenuItems;
    this.injectedMoreMenuItems = injectedMoreMenuItems ?? NEMenuItems.defaultMoreMenuItems;
    this.extras = extras ?? <String, dynamic>{};
  }
}

/// 自定义菜单按钮点击事件回调，通过 [NEMeetingService.setOnInjectedMenuItemClickListener] 设置回调监听
///
/// [NEMeetingMenuItem] 为当前点击的菜单项
///
/// [NEMeetingInfo] 为当前会议信息
typedef NEMeetingOnInjectedMenuItemClickListener = Future<bool> Function(
BuildContext context,NEMenuClickInfo clickInfo, NEMeetingInfo? meetingInfo);

/// 提供创建会议时必要的配置信息和选项开关，如音频、视频开关
class NEStartMeetingOptions extends NEMeetingOptions{
  NEStartMeetingOptions({
    bool? noVideo,
    bool? noAudio,
    bool? showMeetingTime,
    bool? noChat,
    bool? noInvite,
    bool? noMinimize,
    bool? noSwitchCamera,
    bool? noSwitchAudioMode,
    bool? noWhiteBoard,
    bool? noRename,
    bool? noRecord,
    int? defaultWindowMode,
    int? joinTimeout,
    List<DeviceOrientation>? restorePreferredOrientations,
    List<NEMeetingMenuItem>? injectedToolbarMenuItems,
    List<NEMeetingMenuItem>? injectedMoreMenuItems,
  }) : super(
          noVideo: noVideo,
          noAudio: noAudio,
          showMeetingTime: showMeetingTime,
          noChat: noChat,
          noInvite: noInvite,
          noMinimize: noMinimize,
          noSwitchCamera: noSwitchCamera,
          noSwitchAudioMode: noSwitchAudioMode,
          noWhiteBoard: noWhiteBoard,
          noRename: noRename,
          noCloudRecord: noRecord,
          defaultWindowMode: defaultWindowMode,
          joinTimeout: joinTimeout,
          restorePreferredOrientations: restorePreferredOrientations,
          injectedToolbarMenuItems: injectedToolbarMenuItems,
          injectedMoreMenuItems: injectedMoreMenuItems,
        );

  NEStartMeetingOptions.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

/// 提供加入会议时必要的配置信息和选项开关，如音频、视频开关
class NEJoinMeetingOptions extends NEMeetingOptions {
  NEJoinMeetingOptions({
    bool? noVideo,
    bool? noAudio,
    bool? showMeetingTime,
    bool? noChat,
    bool? noInvite,
    bool? noMinimize,
    bool? noSwitchCamera,
    bool? noSwitchAudioMode,
    bool? noWhiteBoard,
    bool? noRename,
    int? defaultWindowMode,
    int? joinTimeout,
    List<DeviceOrientation>? restorePreferredOrientations,
    List<NEMeetingMenuItem>? injectedToolbarMenuItems,
    List<NEMeetingMenuItem>? injectedMoreMenuItems,
  }) : super(
          noVideo: noVideo,
          noAudio: noAudio,
          showMeetingTime: showMeetingTime,
          noChat: noChat,
          noInvite: noInvite,
          noMinimize: noMinimize,
          noSwitchCamera: noSwitchCamera,
          noSwitchAudioMode: noSwitchAudioMode,
          noWhiteBoard: noWhiteBoard,
          noRename: noRename,
          defaultWindowMode: defaultWindowMode,
          joinTimeout: joinTimeout,
          restorePreferredOrientations: restorePreferredOrientations,
          injectedToolbarMenuItems: injectedToolbarMenuItems,
          injectedMoreMenuItems: injectedMoreMenuItems,
        );

  NEJoinMeetingOptions.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

/// 回调接口，用于监听会议状态变更事件
/// * [status] 会议状态事件对象
typedef NERoomStatusListener = void Function(NEMeetingStatus status);

/// 提供会议相关的服务接口，诸如创建会议、加入会议、添加会议状态监听等。可通过 [NEMeetingSDK.getMeetingService] 获取对应的服务实例
abstract class NEMeetingService {
  /// 添加会议状态监听实例，用于接收会议状态变更通知
  ///
  /// * [listener] 要添加的监听实例
  void addListener(NERoomStatusListener listener);

  /// 移除对应的会议状态的监听实例
  ///
  /// * [listener] 要移除的监听实例
  void removeListener(NERoomStatusListener listener);

  /// 创建一个新的会议，只有完成SDK的登录鉴权操作才允许创建会议。创建会议成功后，SDK会拉起会议页面，调用方不用做其他操作
  ///
  /// * [context] UI上下文对象
  /// * [param] 会议参数对象，不能为空
  /// * [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  /// * [listener] 回调接口，该回调不会返回额外的结果数据
  void startMeeting(
      BuildContext context, NEStartMeetingParams param, NEStartMeetingOptions opts, NECompleteListener listener);

  /// 加入一个当前正在进行中的会议，已登录或未登录均可加入会议。加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作
  ///
  /// * [context] UI上下文对象
  /// * [param] 会议参数对象，不能为空
  /// * [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  /// * [listener] 回调接口，该回调不会返回额外的结果数据
  void joinMeeting(
      BuildContext context, NEJoinMeetingParams param, NEJoinMeetingOptions opts, NECompleteListener listener);

  /// 获取当前会议详情。如果当前无正在进行中的会议，则回调数据对象为空
  NEMeetingInfo? getCurrentMeetingInfo();

  /// 离开当前进行中的会议
  Future<NEResult<void>> leaveCurrentMeeting(bool closeIfHost);

  /// 设置菜单项点击事件回调
  void setOnInjectedMenuItemClickListener(NEMeetingOnInjectedMenuItemClickListener listener);

  /// 获取当前会议状态
  NEMeetingStatus getMeetingStatus();

  /// 订阅会议内某一音频流
  ///
  /// * [accountId] 订阅或者取消订阅的id
  /// * [subscribe] true：订阅， false：取消订阅
  Future<NEResult<void>> subscribeRemoteAudioStream(String accountId, bool subscribe);

  /// 批量订阅会议内音频流
  ///
  /// * [accountIds] 订阅或者取消订阅的id列表
  /// * [subscribe] true：订阅， false：取消订阅
  Future<NEResult<List<String>>> subscribeRemoteAudioStreams(List<String> accountIds, bool subscribe);

  /// 订阅会议内全部音频流
  ///
  /// * [subscribe] true：订阅， false：取消订阅
  Future<NEResult<void>> subscribeAllRemoteAudioStreams(bool subscribe);

  /// 开启音频dump
  Future<NEResult<void>> startAudioDump();

  /// 关闭音频dump
  Future<NEResult<void>> stopAudioDump();
}




