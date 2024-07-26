// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEMeetingServiceImpl extends NEMeetingService
    with _AloggerMixin
    implements NEMeetingStatusListener {
  static final _NEMeetingServiceImpl _instance = _NEMeetingServiceImpl._();

  factory _NEMeetingServiceImpl() => _instance;

  _NEMeetingServiceImpl._() {
    addMeetingStatusListener(this);
  }

  @override
  void addMeetingStatusListener(NEMeetingStatusListener listener) {
    NEMeetingUIKit.instance.addMeetingStatusListener(listener);
  }

  @override
  Future<NEResult<void>> fullscreenCurrentMeeting() {
    return NEMeetingUIKit.instance.fullscreenCurrentMeeting();
  }

  @override
  NEMeetingInfo? getCurrentMeetingInfo() {
    return NEMeetingUIKit.instance.getCurrentMeetingInfo();
  }

  @override
  int getMeetingStatus() {
    return NEMeetingUIKit.instance.getMeetingStatus();
  }

  @override
  Future<NEResult<void>> leaveCurrentMeeting(bool closeIfHost) {
    return NEMeetingUIKit.instance.leaveCurrentMeeting(closeIfHost);
  }

  @override
  Future<NEResult<void>> minimizeCurrentMeeting() {
    return NEMeetingUIKit.instance.minimizeCurrentMeeting();
  }

  @override
  void removeMeetingStatusListener(NEMeetingStatusListener listener) {
    NEMeetingUIKit.instance.removeMeetingStatusListener(listener);
  }

  @override
  void setOnInjectedMenuItemClickListener(
      NEMeetingOnInjectedMenuItemClickListener listener) {
    NEMeetingUIKit.instance.setOnInjectedMenuItemClickListener(listener);
  }

  @override
  Future<NEResult<void>> updateInjectedMenuItem(NEMeetingMenuItem? item) {
    return NEMeetingUIKit.instance.updateInjectedMenuItem(item);
  }

  @override
  Future<NEResult<void>> anonymousJoinMeeting(
    BuildContext context,
    NEJoinMeetingParams param,
    NEMeetingOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
  }) {
    return NEMeetingUIKit.instance.anonymousJoinMeeting(
      context,
      param,
      opts,
      onPasswordPageRouteWillPush: onPasswordPageRouteWillPush,
      onMeetingPageRouteWillPush: onMeetingPageRouteWillPush,
      onMeetingPageRouteDidPush: onMeetingPageRouteDidPush,
    );
  }

  @override
  Future<NEResult<void>> joinMeeting(
      BuildContext context, NEJoinMeetingParams param, NEMeetingOptions opts,
      {PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
      MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
      MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
      Widget? backgroundWidget}) {
    return NEMeetingUIKit.instance.joinMeeting(
      context,
      param,
      opts,
      onPasswordPageRouteWillPush: onPasswordPageRouteWillPush,
      onMeetingPageRouteWillPush: onMeetingPageRouteWillPush,
      onMeetingPageRouteDidPush: onMeetingPageRouteDidPush,
      backgroundWidget: backgroundWidget,
    );
  }

  @override
  Future<NEResult<void>> startMeeting(
      BuildContext context, NEStartMeetingParams param, NEMeetingOptions opts,
      {MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
      MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
      Widget? backgroundWidget}) {
    return NEMeetingUIKit.instance.startMeeting(
      context,
      param,
      opts,
      onMeetingPageRouteWillPush: onMeetingPageRouteWillPush,
      onMeetingPageRouteDidPush: onMeetingPageRouteDidPush,
      backgroundWidget: backgroundWidget,
    );
  }

  @override
  void onMeetingStatusChanged(NEMeetingEvent event) {
    if (event.status == NEMeetingStatus.idle) {
      FeedbackRepository().commitFeedbackTask();
    }
  }
}
