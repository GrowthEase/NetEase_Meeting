// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/**
 * 提供会议邀请相关的接口，诸如接受邀请、拒绝邀请、添加邀请状态监听等。可通过 [NEMeetingUIKit.instance.getInviteService()] 获取对应的服务实例。
 */
abstract class NEMeetingUIKitInviteService {
  static final NEMeetingUIKitInviteService _instance =
      _NEMeetingUIKitInviteServiceImpl();

  /// 获取会议NEMeetingUIKitInviteService SDK实例
  static NEMeetingUIKitInviteService get instance => _instance;

  ///
  /// 拒绝会议邀请，只有完成SDK的登录鉴权操作才允许该操作。
  /// * [meetingId] 会议唯一Id
  ///
  Future<NEResult<VoidResult>> rejectInvite(int meetingId);

  /// 接受邀请，加入一个当前正在进行中的会议
  ///
  ///   [context] 当前上下文对象
  ///   [param] 会议参数对象，不能为空
  ///   [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  ///
  /// 该回调会返回一个[NERoomContext]房间上下文实例，该实例支持会议相关扩展 [NEMeetingContext]
  Future<NEResult<void>> acceptInvite(
    BuildContext context,
    NEJoinMeetingUIParams param,
    NEMeetingUIOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    int? startTime,
    Widget? backgroundWidget,
  });

  ///
  /// 添加邀请状态监听实例，用于接收邀请状态变更通知
  /// [listener] 要添加的监听实例
  ///
  void addMeetingInviteStatusListener(NEMeetingInviteStatusListener listener);

  ///
  /// 移除对应的邀请状态监听实例
  /// [listener] 要移除的监听实例
  ///
  void removeMeetingInviteStatusListener(
      NEMeetingInviteStatusListener listener);
}

class _NEMeetingUIKitInviteServiceImpl extends NEMeetingUIKitInviteService
    with _AloggerMixin, WidgetsBindingObserver {
  _NEMeetingUIKitInviteServiceImpl() {}

  NEMeetingInviteService _inviteService =
      NEMeetingKit.instance.getMeetingInviteService();

  @override
  Future<NEResult<void>> acceptInvite(
    BuildContext context,
    NEJoinMeetingUIParams param,
    NEMeetingUIOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    int? startTime,
    Widget? backgroundWidget,
  }) {
    apiLogger.i('acceptInvite $param $opts $startTime $backgroundWidget');
    if (param.trackingEvent == null) {
      param.trackingEvent =
          IntervalEvent(kEventJoinMeeting, startTime: startTime)
            ..addParam(kEventParamMeetingNum, param.meetingNum)
            ..addParam(kEventParamType, 'normal');
    }
    final event = param.trackingEvent!;

    final joinOpts = NEJoinMeetingOptions(
        // enableMyAudioDeviceOnJoinRtc: opts.detectMutedMic,
        );
    return MeetingUIServiceHelper().joinMeetingUIInner(
      context,
      param,
      joinOpts,
      opts,
      () {
        return NEMeetingKit.instance.getMeetingInviteService().acceptInvite(
              param,
              joinOpts,
            );
      },
      onPasswordPageRouteWillPush: onPasswordPageRouteWillPush,
      onMeetingPageRouteWillPush: onMeetingPageRouteWillPush,
      onMeetingPageRouteDidPush: onMeetingPageRouteDidPush,
      backgroundWidget: backgroundWidget,
    ).thenReport(event, onlyFailure: true);
  }

  @override
  void addMeetingInviteStatusListener(NEMeetingInviteStatusListener listener) {
    _inviteService.addMeetingInviteStatusListener(listener);
  }

  @override
  Future<NEResult<VoidResult>> rejectInvite(int meetingId) {
    return _inviteService.rejectInvite(meetingId);
  }

  @override
  void removeMeetingInviteStatusListener(
      NEMeetingInviteStatusListener listener) {
    _inviteService.removeMeetingInviteStatusListener(listener);
  }
}
