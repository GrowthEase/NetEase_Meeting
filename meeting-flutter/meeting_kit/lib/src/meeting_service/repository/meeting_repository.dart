// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class MeetingRepository {
  /// 创建会议
  static Future<NEResult<MeetingInfo>> createMeeting({
    required NEMeetingType type,
    String? subject,
    String? password,
    required int roomConfigId,
    Map? roomProperties,
    Map? roleBinds,
    NEMeetingFeatureConfig featureConfig = const NEMeetingFeatureConfig(),
  }) {
    return HttpApiHelper.execute(
      _CreateMeetingApi(
        type,
        _CreateMeetingRequest(
          subject: subject,
          password: password,
          roomConfigId: roomConfigId,
          roomProperties:
              roomProperties?.map((k, v) => MapEntry(k, {'value': v})),
          roleBinds: roleBinds,
          featureConfig: featureConfig,
        ),
      ),
    );
  }

  static Future<NEResult<MeetingInfo>> getMeetingInfo(String meetingId) {
    return HttpApiHelper.execute(_GetMeetingInfoApi(meetingId));
  }

  /// 匿名登陆
  static Future<NEResult<AnonymousLoginInfo>> anonymousLogin() {
    return HttpApiHelper._anonymousLogin();
  }
}
