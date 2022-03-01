// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class LoginInfo {
  final String accountId;
  final String accountToken;
  String appKey;
  int appId = -1;
  String? nickname;
  String? mobile;
  int loginType = -1;

  LoginInfo({
    required this.accountId,
    required this.accountToken,
    required this.appKey,
    this.appId = -1,
    this.nickname,
    this.mobile,
    this.loginType = -1,
  });

  LoginInfo.fromJson(Map json):
    accountId = (json['accountId'] ?? json['userId']) as String,///当accountId为null，则再继续读取userId
    accountToken = json['accountToken'] as String,
    appKey = json['appKey'] as String,
    appId = json['appId'] as int,
    nickname = json['nickname'] as String?,
    mobile = json['mobile'] as String?,
    loginType = (json['loginType'] ?? -1) as int;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['accountId'] = accountId;
    map['accountToken'] = accountToken;
    map['appKey'] = appKey;
    map['appId'] = appId;
    map['nickname'] = nickname;
    map['mobile'] = mobile;
    map['loginType'] = loginType;
    return map;
  }

}