// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEGuestServiceImpl extends NEGuestService with _AloggerMixin {
  @override
  Future<NEResult<void>> joinMeetingAsGuest(BuildContext context,
      NEGuestJoinMeetingParams param, NEMeetingOptions opts,
      {PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
      MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
      MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
      Widget? backgroundWidget}) {
    return NEMeetingUIKit.instance.guestJoinMeeting(
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
  Future<VoidResult> requestSmsCodeForGuestJoin(
    String meetingNum,
    String phoneNumber,
  ) {
    apiLogger.i('requestSmsCodeForVerify: $meetingNum, $phoneNumber');
    return GuestRepository().requestSmsCodeForVerify(meetingNum, phoneNumber);
  }
}
