// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

const _kComponent = 'MeetingKit';
const _kVersion = SDKConfig.sdkVersionName;
const _kFramework = 'Flutter';

const _kEventLogin = "${_kComponent}_login";
const _kLoginStepAccountInfo = "account_info";
const _kLoginStepRoomKitLogin = "roomkit_login";
const _kLoginTypeToken = "token";
const _kLoginTypePassword = "password";
const _kLoginTypeAnonymous = "anonymous";

const kEventStartMeeting = "${_kComponent}_start_meeting";
const kMeetingStepCreateRoom = "create_room";
const kMeetingStepJoinRoom = "join_room";
const kMeetingStepJoinRtc = "join_rtc";
const kMeetingStepServerNotifyJoinRtc = "server_join_rtc";

const kEventJoinMeeting = "${_kComponent}_join_meeting";
const kMeetingStepMeetingInfo = "meeting_info";
const kMeetingStepAnonymousLogin = "anonymous_login";

const kEventMeetingEnd = "${_kComponent}_meeting_end";

const kEventParamUserId = 'userId';
const kEventParamType = 'type';
const kEventParamMeetingId = "meetingId";
const kEventParamMeetingNum = "meetingNum";
const kEventParamRoomArchiveId = "roomArchiveId";
const kEventParamReason = "reason";
const kEventParamMeetingDuration = "meetingDuration";
const kEventParamInputPasswordElapsed = "inputPasswordCost";
const kEventParamRequestPermissionElapsed = "requestPermissionCost";

extension ReportEventExtension<T> on Future<NEResult<T>> {
  Future<NEResult<T>> thenReport(IntervalEvent? event,
      {bool onlyFailure = false, String? userId}) {
    return then<NEResult<T>>((value) {
      if (event != null &&
          (!onlyFailure || onlyFailure && !value.isSuccess())) {
        NEMeetingKit.instance.reportEvent(event, userId: userId);
      }
      return value;
    });
  }
}
