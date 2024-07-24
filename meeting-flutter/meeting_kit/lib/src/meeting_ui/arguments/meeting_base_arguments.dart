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

  /// 会议最小化背景 widget
  Widget? backgroundWidget;

  /// show Meeting time
  bool? get showMeetingTime => options.showMeetingTime;

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
      options.fullMoreMenuItems;

  /// Toolbar菜单
  List<NEMeetingMenuItem> get injectedToolbarMenuItems {
    final items = <NEMeetingMenuItem>[...options.fullToolbarMenuItems];
    final index = items.indexOf(NEMenuItems.microphone);
    if (index != -1 &&
        options.fullMoreMenuItems.contains(NEMenuItems.disconnectAudio) &&
        !options.fullToolbarMenuItems.contains(NEMenuItems.disconnectAudio)) {
      items.insert(
          index,
          options.fullMoreMenuItems
              .firstWhere((e) => e == NEMenuItems.disconnectAudio));
    }
    return items;
  }

  /// 最小化
  bool get noMinimize => options.noMinimize;

  /// 后台画中画
  bool get enablePictureInPicture => options.enablePictureInPicture;

  /// 会议标题
  String get meetingTitle {
    var title = options.title;
    if (title != null && title.isNotEmpty) {
      return title;
    }
    title = CoreRepository().initedConfig?.appName;
    if (title != null && title.isNotEmpty) {
      return title;
    }
    return NEMeetingUIKit.instance.getUIKitLocalizations().meetingDefalutTitle;
  }

  String? get iosBroadcastAppGroup =>
      CoreRepository().initedConfig?.iosBroadcastAppGroup;

  /// 本地配置
  bool get videoMute => _videoMuteListenable.value;

  /// 关闭白板入口
  bool get noWhiteBoard => options.noWhiteBoard;

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

  final _videoMuteListenable = ValueNotifier(true);

  ValueListenable<bool> get videoMuteListenable {
    return _videoMuteListenable;
  }

  set videoMute(bool value) {
    _videoMuteListenable.value = value;
  }

  /// 本地配置，从服务器同步，如果是全员静音需要改变
  bool get audioMute => _audioMuteListenable.value;

  final bool initialAudioMute;
  final bool initialVideoMute;
  final bool initialIsInPIPView;

  final _audioMuteListenable = ValueNotifier(true);
  ValueListenable<bool> get audioMuteListenable {
    return _audioMuteListenable;
  }

  set audioMute(bool value) {
    _audioMuteListenable.value = value;
  }

  /// 画廊
  bool get noGallery => options.noGallery;

  NEMeetingOptions options;

  MeetingBaseArguments({
    required this.meetingNum,
    this.displayName,
    this.tag,
    this.password,
    required this.options,
    this.backgroundWidget,
    this.initialAudioMute = true,
    this.initialVideoMute = true,
    this.initialIsInPIPView = false,
  });
}
