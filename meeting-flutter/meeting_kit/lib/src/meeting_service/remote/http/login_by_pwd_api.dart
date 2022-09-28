// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class NEAccountInfo {
  late final String userUuid;

  late final String userToken;

  late final String nickname;

  late final String privateMeetingNum;

  late final String? privateShortMeetingNum;

  late final AccountSettings? settings;

  NEAccountInfo({
    required this.userUuid,
    required this.userToken,
    this.nickname = '',
    this.privateMeetingNum = '',
    this.privateShortMeetingNum,
    this.settings,
  });

  NEAccountInfo.fromMap(Map map, {String? userUuid, String? userToken}) {
    this.userUuid = userUuid ?? map['userUuid'] as String;
    this.userToken = userToken ?? map['userToken'] as String;
    nickname = map['nickname'] as String;
    privateMeetingNum = map['privateMeetingNum'] as String;
    privateShortMeetingNum = map['shortMeetingNum'] as String?;
    settings = AccountSettings.fromMap(map as Map<String, dynamic>);
  }
}

class _LoginWithNEMeetingApi extends HttpApi<NEAccountInfo> {
  _LoginByPwdRequest request;

  _LoginWithNEMeetingApi(this.request);

  @override
  Map data() => request.data;

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/login/${request.username}';

  @override
  NEAccountInfo result(Map map) => NEAccountInfo.fromMap(map);

  @override
  bool checkLoginState() => false;

  @override
  bool enableLog() => false;
}

class _FetchAccountInfoApi extends HttpApi<NEAccountInfo> {
  final String accountId;
  final String accountToken;

  _FetchAccountInfoApi(this.accountId, this.accountToken);

  @override
  Map data() => {};

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/account/info';

  @override
  NEAccountInfo result(Map map) =>
      NEAccountInfo.fromMap(map, userUuid: accountId, userToken: accountToken);

  @override
  String get method => 'GET';

  @override
  Map<String, dynamic>? header() => {
        'user': accountId,
        'token': accountToken,
      };

  @override
  bool checkLoginState() => false;

  @override
  bool enableLog() => false;
}
