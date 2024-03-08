// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class NEAccountInfo {
  /// 企业名称
  late final String? corpName;

  /// 用户唯一 Id
  late final String userUuid;

  /// 用户 Token
  late final String userToken;

  /// 用户账号
  late final String? account;

  /// 用户名
  late final String nickname;

  /// 用户头像
  late final String? avatar;

  /// 电话号码
  late final String? phoneNumber;

  /// 用户邮箱
  late final String? email;

  /// 个人会议号
  late final String privateMeetingNum;

  /// 个人会议短号
  late final String? privateShortMeetingNum;

  /// 其他设置
  late final AccountSettings? settings;

  /// 会议套餐信息
  late final ServiceBundle? serviceBundle;

  NEAccountInfo({
    required this.userUuid,
    required this.userToken,
    this.corpName,
    this.nickname = '',
    this.privateMeetingNum = '',
    this.privateShortMeetingNum,
    this.account,
    this.avatar,
    this.phoneNumber,
    this.email,
    this.settings,
    this.serviceBundle,
  });

  NEAccountInfo.fromMap(Map map, {String? userUuid, String? userToken}) {
    this.userUuid = userUuid ?? map['userUuid'] as String;
    this.userToken = userToken ?? map['userToken'] as String;
    account = map['username'] as String?;
    corpName = map['corpName'] as String?;
    nickname = map['nickname'] as String;
    avatar = map['avatar'] as String?;
    phoneNumber = map['phoneNumber'] as String?;
    email = map['email'] as String?;
    privateMeetingNum = map['privateMeetingNum'] as String;
    privateShortMeetingNum = map['shortMeetingNum'] as String?;
    settings = AccountSettings.fromMap(map as Map<String, dynamic>);

    serviceBundle = switch (map['serviceBundle']) {
      {
        'name': String name,
        'meetingMaxMinutes': int? maxMinutes,
        'meetingMaxMembers': int maxMembers,
      } =>
        ServiceBundle(
          name: name,
          maxMinutes: maxMinutes,
          maxMembers: maxMembers,
        ),
      _ => null,
    };
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

/// 会议套餐信息
/// {"name":"免费版","meetingMaxMinutes":1440,"meetingMaxMembers":500}
class ServiceBundle {
  final String name;
  final int? maxMinutes;
  final int maxMembers;

  ServiceBundle({
    required this.name,
    required this.maxMinutes,
    required this.maxMembers,
  });

  bool get isUnlimited => maxMinutes == null || maxMinutes! < 0;
}
