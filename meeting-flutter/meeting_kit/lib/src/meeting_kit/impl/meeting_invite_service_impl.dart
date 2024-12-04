// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEMeetingInviteServiceImpl extends NEMeetingInviteService
    with _AloggerMixin, EventTrackMixin {
  static final _NEMeetingInviteServiceImpl _instance =
      _NEMeetingInviteServiceImpl._();

  factory _NEMeetingInviteServiceImpl() => _instance;

  final meetingInviteService =
      NEMeetingUIKit.instance.getMeetingInviteService();

  _NEMeetingInviteServiceImpl._() {}

  @override
  Future<NEResult<void>> acceptInvite(
    BuildContext context,
    NEJoinMeetingParams param,
    NEMeetingOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    int? startTime,
    Widget? backgroundWidget,
  }) async {
    apiLogger.i('acceptInvite param: $param, opts: $opts');
    return meetingInviteService.acceptInvite(
      context,
      param,
      opts,
      onPasswordPageRouteWillPush: onPasswordPageRouteWillPush,
      onMeetingPageRouteWillPush: onMeetingPageRouteWillPush,
      onMeetingPageRouteDidPush: onMeetingPageRouteDidPush,
      startTime: startTime,
      backgroundWidget: backgroundWidget,
    );
  }

  @override
  Future<NEResult<VoidResult>> rejectInvite(int meetingId) {
    apiLogger.i('rejectInvite meetingId: $meetingId');
    return meetingInviteService.rejectInvite(meetingId);
  }

  @override
  void addMeetingInviteStatusListener(NEMeetingInviteStatusListener listener) {
    apiLogger.i('addMeetingInviteStatusListener, listener: $listener');
    meetingInviteService.addMeetingInviteStatusListener(listener);
  }

  @override
  void removeMeetingInviteStatusListener(
      NEMeetingInviteStatusListener listener) {
    apiLogger.i('removeMeetingInviteStatusListener, listener: $listener');
    meetingInviteService.removeMeetingInviteStatusListener(listener);
  }

  @override
  Future<NEResult<NERoomSIPCallInfo?>> callOutRoomSystem(
      NERoomSystemDevice device) {
    apiLogger.i('callOutRoomSystem, meetingNum: device: $device');
    return meetingInviteService.callOutRoomSystem(device);
  }
}
