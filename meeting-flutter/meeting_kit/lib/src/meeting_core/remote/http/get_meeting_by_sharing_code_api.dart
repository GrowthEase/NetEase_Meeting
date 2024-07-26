// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_core;

class _GetMeetingBySharingCodeApi extends HttpApi<MeetingInfo> {
  /// 共享码
  final sharingCode;
  final _LoginInfo? logInfo;

  _GetMeetingBySharingCodeApi(this.sharingCode, this.logInfo);

  @override
  String get method => 'POST';

  @override
  String path() => 'rooms_sdk/v1/screen_share/';

  @override
  MeetingInfo result(Map map) => MeetingInfo.fromMap(map);

  @override
  Map data() => {'code': sharingCode};

  @override
  Map<String, dynamic>? header() => {
        'Content-Type': 'application/json;charset=UTF-8',
        'AppKey': ServiceRepository().appKey,
        'user': logInfo?.userUuid,
        'token': logInfo?.userToken,
        'appVer': SDKConfig.sdkVersionCode,
      };
}
