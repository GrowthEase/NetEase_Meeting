// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class MeetingBaseArguments {
  /// 会议号
  String meetingId;

  /// 会议昵称
  String? displayName;

  ///会议中的成员标签，自定义，最大长度1024个字符
  String? tag;

  /// 会议密码
  String? password;

  /// show Meeting time
  bool get showMeetingTime => options?.showMeetingTime ?? true;

  /// 邀请
  bool get noInvite => options?.noInvite ?? false;

  /// 聊天
  bool get noChat => options?.noChat ?? false;

  /// 是否为匿名入会
  bool get anonymous => options?.anonymous ?? false;

  bool get noSwitchCamera => options?.noSwitchCamera ?? false;

  bool get noSwitchAudioMode => options?.noSwitchAudioMode ?? false;

  /// 更多菜单
  List<NEMeetingMenuItem> get injectedMoreMenuItems => options?.injectedMoreMenuItems ?? <NEMeetingMenuItem>[];

  /// Toolbar菜单
  List<NEMeetingMenuItem> get injectedToolbarMenuItems => options?.injectedToolbarMenuItems ?? <NEMeetingMenuItem>[];

  /// 最小化
  bool get noMinimize => options?.noMinimize ?? false;

  /// 会议标题
  String get meetingTitle => options?.meetingTitle ?? '';

  /// 本地配置
  bool get videoMute => options?.videoMute ?? false;

  /// 关闭白板入口
  bool get noWhiteBoard => options?.noWhiteBoard ?? false;

  /// 创建会议，录制开关
  bool get noRecord => options?.noCloudRecord ?? true;

  /// 默认开启白板
  int get defaultWindowMode => options?.defaultWindowMode ?? WindowMode.gallery.value;

  int get joinTimeout {
    final timeout = options?.joinTimeout ?? 0;
    return timeout > 0 ? timeout : NEMeetingConstants.meetingJoinTimeout;
  }

  /// 页面退出恢复页面原始方向, 为空不恢复，由应用自己处理
  List<DeviceOrientation>? get restorePreferredOrientations => options?.restorePreferredOrientations;

  ValueNotifier<bool>? _videoMuteListenable;

  ValueListenable<bool> get videoMuteListenable {
    _videoMuteListenable ??= ValueNotifier(videoMute);
    return _videoMuteListenable!;
  }

  set videoMute(bool value) {
    checkOptions();
    options!.videoMute = value;
    _videoMuteListenable?.value = value;
  }

  /// 本地配置，从服务器同步，如果是全员静音需要改变
  bool get audioMute => options?.audioMute ?? false;

  ValueNotifier<bool>? _audioMuteListenable;

  ValueListenable<bool> get audioMuteListenable {
    _audioMuteListenable ??= ValueNotifier(audioMute);
    return _audioMuteListenable!;
  }

  set audioMute(bool value) {
    checkOptions();
    options!.audioMute = value;
    _audioMuteListenable?.value = value;
  }

  void checkOptions() {
    options ??= MeetingOptions();
  }

  /// 画廊
  bool get noGallery => options?.noGallery ?? false;

  MeetingOptions? options;

  String? nrtcAppKey;

  MeetingBaseArguments(
      {required this.meetingId,
        this.displayName,
        this.tag,
      this.password,
      this.options});
}
