// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class NEAccountInfo {
  /// 企业名称
  late final String? corpName;

  /// 用户唯一 Id
  late final String userUuid;

  /// 用户 Token
  late final String userToken;

  /// 用户昵称
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

  /// 是否为初始密码
  late final bool isInitialPassword;

  /// 会议套餐信息
  late final NEServiceBundle? serviceBundle;

  /// 是否是匿名账号
  late final bool isAnonymous;

  NEAccountInfo({
    required this.userUuid,
    required this.userToken,
    this.corpName,
    this.nickname = '',
    this.privateMeetingNum = '',
    this.privateShortMeetingNum,
    this.avatar,
    this.phoneNumber,
    this.email,
    this.isInitialPassword = false,
    this.serviceBundle,
    this.isAnonymous = false,
  });

  NEAccountInfo.fromMap(Map map,
      {String? userUuid, String? userToken, bool? isAnonymous}) {
    this.userUuid = userUuid ?? map['userUuid'] as String;
    this.userToken = userToken ?? map['userToken'] as String;
    corpName = map['corpName'] as String?;
    nickname = map['nickname'] as String;
    avatar = map['avatar'] as String?;
    phoneNumber = map['phoneNumber'] as String?;
    email = map['email'] as String?;
    privateMeetingNum = map['privateMeetingNum'] as String;
    privateShortMeetingNum = map['shortMeetingNum'] as String?;
    isInitialPassword = map['initialPassword'] as bool? ?? false;

    serviceBundle = switch (map['serviceBundle']) {
      {
        'name': String name,
        'meetingMaxMinutes': int? maxMinutes,
        'meetingMaxMembers': int maxMembers,
        'expireTimeStamp': int expireTimestamp,
        'expireTip': String expireTip,
      } =>
        NEServiceBundle(
          name: name,
          maxMinutes: maxMinutes,
          maxMembers: maxMembers,
          expireTimestamp: expireTimestamp,
          expireTip: expireTip,
        ),
      _ => null,
    };

    this.isAnonymous = isAnonymous ?? false;
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

class _FetchAccountInfoByPwdApi extends HttpApi<NEAccountInfo> {
  final String? username;
  final String? mobile;
  final String? email;
  final String password;

  _FetchAccountInfoByPwdApi.username({
    required this.username,
    required this.password,
  })  : mobile = null,
        email = null;

  _FetchAccountInfoByPwdApi.mobile({
    required this.mobile,
    required this.password,
  })  : username = null,
        email = null;

  _FetchAccountInfoByPwdApi.email({
    required this.email,
    required this.password,
  })  : username = null,
        mobile = null;

  @override
  Map data() => {
        if (username != null) 'username': username,
        if (mobile != null) 'phone': mobile,
        if (email != null) 'email': email,
        'password': '$password@yiyong.im'.md5,
      };

  @override
  String path() {
    String type;
    if (email != null) {
      type = 'email';
    } else if (mobile != null) {
      type = 'phone';
    } else {
      type = 'username';
    }
    return 'scene/meeting/v1/login-$type';
  }

  @override
  NEAccountInfo result(Map map) => NEAccountInfo.fromMap(map);

  @override
  String get method => 'POST';

  @override
  bool checkLoginState() => false;

  @override
  bool enableLog() => false;
}

/// 会议套餐信息
class NEServiceBundle {
  ///
  /// 套餐名称
  ///
  final String name;

  ///
  /// 套餐支持的单会议最大时长，以分钟为单位，小于0或为空表示不限时长
  ///
  final int? maxMinutes;

  ///
  /// 套餐支持的单会议最大成员数
  ///
  final int maxMembers;

  ///
  /// 套餐过期时间戳，-1表示永不过期
  ///
  final int expireTimestamp;

  ///
  /// 套餐过期提示
  ///
  final String expireTip;

  NEServiceBundle({
    required this.name,
    required this.maxMinutes,
    required this.maxMembers,
    required this.expireTimestamp,
    this.expireTip = '',
  });

  toJson() {
    return {
      'name': name,
      'maxMinutes': maxMinutes,
      'maxMembers': maxMembers,
      'expireTimestamp': expireTimestamp,
      'expireTip': expireTip,
    };
  }

  /// 是否不限时长
  bool get isUnlimited => maxMinutes == null || maxMinutes! < 0;

  /// 是否永不过期
  bool get isNeverExpired => expireTimestamp == -1;

  /// 是否已过期
  bool get isExpired =>
      !isNeverExpired &&
      expireTimestamp < DateTime.now().millisecondsSinceEpoch;
}
