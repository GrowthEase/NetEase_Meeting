// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class LoginInfo {
  final String accountId;
  final String accountToken;
  String appKey;
  final int appId;
  String? nickname;
  String? account;
  final String? mobile;
  final String? email;
  int loginType = -1;
  final bool autoRegistered;
  final String? privateMeetingNum;
  final bool isInitialPassword;

  LoginInfo({
    required this.accountId,
    required this.accountToken,
    required this.appKey,
    this.appId = -1,
    this.nickname,
    this.account,
    this.mobile,
    this.email,
    this.loginType = -1,
    this.autoRegistered = false,
    this.isInitialPassword = false,
    this.privateMeetingNum,
  });

  LoginInfo.fromJson(
    Map json, {
    String? appKey,
    String? mobile,
    String? email,
    int? loginType,
    bool autoRegistered = false,
  })  : accountId = json['userUuid'] as String,
        accountToken = json['userToken'] as String,
        appKey = (json['appKey'] ?? appKey) as String,
        appId = (json['appId'] ?? -1) as int,
        privateMeetingNum = json['privateMeetingNum'] as String?,
        nickname = json['nickname'] as String?,
        account = json['username'] as String?,
        mobile = mobile ?? json['mobile'] as String?,
        email = email ?? json['email'] as String?,
        loginType = loginType ?? (json['loginType'] ?? -1) as int,
        isInitialPassword = (json['initialPassword'] ?? false) as bool,
        autoRegistered = (json['autoRegistered'] ?? autoRegistered) as bool;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['userUuid'] = accountId;
    map['userToken'] = accountToken;
    map['appKey'] = appKey;
    map['appId'] = appId;
    map['nickname'] = nickname;
    map['username'] = account;
    map['mobile'] = mobile;
    map['email'] = email;
    map['loginType'] = loginType;
    map['autoRegistered'] = autoRegistered;
    return map;
  }
}
