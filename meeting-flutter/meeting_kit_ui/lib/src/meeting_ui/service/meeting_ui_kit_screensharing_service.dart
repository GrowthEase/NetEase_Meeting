// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 屏幕共享服务接口，用于创建和管理屏幕共享、添加共享状态监听等。可通过 [NEMeetingUIKit.instance.get] 获取对应的服务实例
abstract class NEMeetingUIKitScreenSharingService {
  static final NEMeetingUIKitScreenSharingService _instance =
      _NEMeetingUIKitScreenSharingServiceImpl();

  /// 获取会议NEMeetingUIKitScreenSharingService SDK实例
  static NEMeetingUIKitScreenSharingService get instance => _instance;

  /// 开启一个开启屏幕共享，只有完成SDK的登录鉴权操作才允许开启屏幕共享。
  ///
  /// * [param] 屏幕共享参数对象，不能为空
  /// * [opts]  屏幕共享选项对象，可空；当未指定时，会使用默认的选项
  ///
  Future<NEResult<String>> startScreenShare(
    NEScreenSharingParams param,
    NEScreenSharingOptions opts,
  );

  ///
  /// 停止屏幕共享
  /// 回调接口。该回调不会返回额外的结果数据
  ///
  Future<NEResult<void>> stopScreenShare();

  ///
  /// 添加共享屏幕状态监听实例，用于接收共享屏幕状态变更通知
  ///
  /// [listener] 要添加的监听实例
  ///
  void addScreenSharingStatusListener(NEScreenSharingStatusListener listener);

  ///
  /// 移除对应的会议共享屏幕状态的监听实例
  ///
  /// [listener] 要移除的监听实例
  ///
  void removeScreenSharingStatusListener(
      NEScreenSharingStatusListener listener);
}

class _NEMeetingUIKitScreenSharingServiceImpl
    extends NEMeetingUIKitScreenSharingService
    with _AloggerMixin, WidgetsBindingObserver {
  _NEMeetingUIKitScreenSharingServiceImpl() {}

  NEScreenSharingService _inviteService =
      NEMeetingKit.instance.getScreenSharingService();

  @override
  void addScreenSharingStatusListener(NEScreenSharingStatusListener listener) {
    _inviteService.addScreenSharingStatusListener(listener);
  }

  @override
  void removeScreenSharingStatusListener(
      NEScreenSharingStatusListener listener) {
    _inviteService.removeScreenSharingStatusListener(listener);
  }

  @override
  Future<NEResult<String>> startScreenShare(
      NEScreenSharingParams param, NEScreenSharingOptions opts) {
    return _inviteService.startScreenShare(param, opts);
  }

  @override
  Future<NEResult<void>> stopScreenShare() {
    return _inviteService.stopScreenShare();
  }
}
