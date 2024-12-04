// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

const _kComponent = 'MeetingKit';
const _kVersion = SDKConfig.sdkVersionName;
const _kFramework = 'Flutter';

const kEventLogin = "${_kComponent}_login";
const kLoginStepAccountInfo = "account_info";
const kLoginStepRoomKitLogin = "roomkit_login";
const kLoginTypeToken = "token";
const kLoginTypePassword = "password";
const kLoginTypePhoneNumber = "phoneNumber";
const kLoginTypeSmsCode = "smsCode";
const kLoginTypeEmail = "email";
const kLoginTypeAnonymous = "anonymous";

const kEventStartMeeting = "${_kComponent}_start_meeting";
const kMeetingStepCreateRoom = "create_room";
const kMeetingStepJoinRoom = "join_room";
const kMeetingStepJoinRtc = "join_rtc";
const kMeetingStepServerNotifyJoinRtc = "server_join_rtc";

const kEventJoinMeeting = "${_kComponent}_join_meeting";
const kMeetingStepMeetingInfo = "meeting_info";
const kMeetingStepAnonymousLogin = "anonymous_login";
const kMeetingStepGuestLogin = "guest_login";

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
const kEventParamCorpCode = 'corpCode';
const kEventParamCorpEmail = 'corpEmail';

extension ReportEventExtension<T> on Future<NEResult<T>> {
  Future<NEResult<T>> thenReport(IntervalEvent? event,
      {bool onlyFailure = false, String? userId}) {
    return then<NEResult<T>>((value) {
      if (event != null &&
          (!onlyFailure || onlyFailure && !value.isSuccess())) {
        ReportRepository().reportEvent(event, userId: userId);
      }
      return value;
    });
  }
}

final class ReportRepository {
  static final ReportRepository _instance = ReportRepository._();

  ReportRepository._();

  factory ReportRepository() {
    return _instance;
  }

  Future<bool> reportEvent(Event event, {String? userId}) {
    final appKey = CoreRepository().initedAppKey;
    final channel = CoreRepository().initedConfig?.extras?['_eventChannel'];
    if (appKey == null) return Future.value(false);
    final accountInfo = AccountRepository().getAccountInfo();
    return NERoomKit.instance.reportEvent({
      'appKey': appKey,
      'component': _kComponent,
      'version': _kVersion,
      'framework': _kFramework,
      'userId': userId ?? accountInfo?.userUuid,
      if (accountInfo != null) 'nickname': accountInfo.nickname,
      'eventId': event.eventId,
      'priority': event.priority.index,
      'eventData': event.toMap(),
      if (channel != null) 'channel': channel.toString(),
    });
  }
}
