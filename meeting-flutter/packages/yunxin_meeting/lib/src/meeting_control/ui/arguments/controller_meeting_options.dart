// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControllerMeetingOptions {
  /// 会议标题
  String? meetingTitle;

  /// ios broadcast app group
  String? iosBroadcastAppGroup;

  /// 本地配置
  bool videoMute = false;

  /// 本地配置，从服务器同步，如果是全员静音需要改变
  bool audioMute = false;

  /// show Meeting time
  bool showMeetingTime;

  /// 邀请
  bool noInvite;

  /// 聊天
  bool noChat;

  /// 是否为匿名入会, 转场页面重试需要
  bool anonymous;

  /// "Toolbar"自定义菜单
  List<NEMeetingMenuItem>? injectedToolbarMenuItems;

  /// "更多"自定义菜单，可添加监听器处理菜单点击事件
  List<NEMeetingMenuItem>? injectedMoreMenuItems;

  /// 最小化
  bool noMinimize;

  /// 画廊
  bool noGallery;

  /// 配置会议中是否显示"切换摄像头"按钮
  bool noSwitchCamera;

  /// 配置会议中是否显示"切换音频模式"按钮
  bool noSwitchAudioMode;

  /// 配置会议中是否显示"改名"菜单
  bool noRename;

  /// 会议中的"会议号"显示规则
  final int meetingIdDisplayOption;

  /// 配置会议中是否显示"共享白板"按钮
  bool noWhiteBoard;

  /// 是否打开云端录制开关
  bool noCloudRecord;

  /// 配置默认会议模式[WhiteBoardUtil]
  int defaultWindowMode;

  /// 页面退出恢复页面原始方向
  List<DeviceOrientation>? restorePreferredOrientations;

  Map<String,dynamic>? extras;

  bool get isLongMeetingIdEnabled => meetingIdDisplayOption == MeetingIdDisplayOption.displayAll
      || meetingIdDisplayOption == MeetingIdDisplayOption.displayLongIdOnly;

  bool get isShortMeetingIdEnabled => meetingIdDisplayOption == MeetingIdDisplayOption.displayAll
      || meetingIdDisplayOption == MeetingIdDisplayOption.displayShortIdOnly;

  ControllerMeetingOptions(
      {this.meetingTitle,
      this.iosBroadcastAppGroup,
      this.videoMute = false,
      this.audioMute = false,
      this.showMeetingTime = true,
      this.noInvite = false,
      this.noChat = false,
      this.anonymous = false,
      this.noMinimize = true,
      this.noGallery = false,
      this.noSwitchCamera = false,
      this.noSwitchAudioMode = false,
      this.noWhiteBoard = false,
      this.noRename = false,
      this.noCloudRecord = true,
      this.defaultWindowMode = _gallery,
      this.meetingIdDisplayOption = MeetingIdDisplayOption.displayAll,
      this.injectedToolbarMenuItems,
      this.injectedMoreMenuItems,
      this.restorePreferredOrientations,
      this.extras});
}

class ControlMeetingIdDisplayOption {

  static const int displayAll = 0;

  static const int displayLongIdOnly = 1;

  static const int displayShortIdOnly = 2;

}
