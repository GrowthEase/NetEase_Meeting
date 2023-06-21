// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingBaseArguments {
  /// 会议号
  String meetingNum;

  /// 会议昵称
  String? displayName;

  ///会议中的成员标签，自定义，最大长度1024个字符
  String? tag;

  /// 会议密码
  String? password;

  /// show Meeting time
  bool get showMeetingTime => options.showMeetingTime;

  /// 邀请
  bool get noInvite => options.noInvite;

  /// sip功能入口
  bool get noSip => options.noSip;

  /// 聊天
  bool get noChat => options.noChat;

  /// 直播
  bool get noLive => options.noLive;

  bool get noSwitchCamera => options.noSwitchCamera;

  bool get noSwitchAudioMode => options.noSwitchAudioMode;

  /// 更多菜单
  List<NEMeetingMenuItem> get injectedMoreMenuItems =>
      options.injectedMoreMenuItems;

  /// Toolbar菜单
  List<NEMeetingMenuItem> get injectedToolbarMenuItems =>
      options.injectedToolbarMenuItems;

  /// 最小化
  bool get noMinimize => options.noMinimize;

  /// 会议标题
  String get meetingTitle {
    var title = options.title;
    if (title != null && title.isNotEmpty) {
      return title;
    }
    title = NEMeetingUIKit()._config?.appName;
    if (title != null && title.isNotEmpty) {
      return title;
    }
    return NEMeetingUIKit().ofLocalizations().defaultMeetingTitle;
  }

  String? get iosBroadcastAppGroup =>
      NEMeetingUIKit()._config?.iosBroadcastAppGroup;

  /// 本地配置
  bool get videoMute => _videoMuteListenable.value;

  /// 关闭白板入口
  bool get noWhiteBoard => options.noWhiteBoard;

  /// 创建会议，录制开关
  bool get noRecord => options.noCloudRecord;

  /// 默认开启白板
  int get defaultWindowMode => options.defaultWindowMode;

  /// 本地配置是否开启会议剩余时间提示
  bool get showMeetingRemainingTip => options.showMeetingRemainingTip;

  int get joinTimeout {
    final timeout = options.joinTimeout;
    return timeout > 0 ? timeout : NEMeetingConstants.meetingJoinTimeout;
  }

  /// 页面退出恢复页面原始方向, 为空不恢复，由应用自己处理
  List<DeviceOrientation>? get restorePreferredOrientations =>
      options.restorePreferredOrientations;

  final _videoMuteListenable = ValueNotifier<bool>(true);

  ValueListenable<bool> get videoMuteListenable {
    return _videoMuteListenable;
  }

  set videoMute(bool value) {
    _videoMuteListenable.value = value;
  }

  /// 本地配置，从服务器同步，如果是全员静音需要改变
  bool get audioMute => _audioMuteListenable.value;

  bool get initialAudioMute => options.noAudio;

  bool get initialVideoMute => options.noVideo;

  final _audioMuteListenable = ValueNotifier(true);

  ValueListenable<bool> get audioMuteListenable {
    return _audioMuteListenable;
  }

  set audioMute(bool value) {
    _audioMuteListenable.value = value;
  }

  /// 画廊
  bool get noGallery => options.noGallery;

  NEMeetingUIOptions options;

  MeetingBaseArguments({
    required this.meetingNum,
    this.displayName,
    this.tag,
    this.password,
    required this.options,
  });
}
