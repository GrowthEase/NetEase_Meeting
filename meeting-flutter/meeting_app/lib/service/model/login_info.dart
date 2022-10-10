// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// accountId : "1159739755524187"
/// accountToken : "51b89de498a34a158cf21314eb9dbd69"
/// appKey : "092dcd94d2c2566d1ed66061891cdf15"
/// appId : 100001
/// nickname : "赵冲"
/// mobile : "15712893500"

class LoginInfo {
  final String accountId;
  final String accountToken;
  String appKey;
  int appId = -1;
  String? nickname;
  String? mobile;
  int loginType = -1;
  bool autoRegistered;
  String? privateMeetingNum;

  // String get accountId => _accountId;
  // String get accountToken => _accountToken;
  // String get appKey => _appKey;
  // int get appId => _appId;
  // String get nickname => _nickname;
  // String? get mobile => _mobile;
  // int get loginType => _loginType;

  // set appKey(String value) => _appKey = value;
  // set nickname(String value) => _nickname = value;
  // set loginType(int value) => _loginType = value;

  LoginInfo(
      {required this.accountId,
      required this.accountToken,
      required this.appKey,
      this.appId = -1,
      this.nickname,
      this.mobile,
      this.loginType = -1,
      this.autoRegistered = false,
      this.privateMeetingNum});

  LoginInfo.fromJson(Map json,
      {String? appKey,
      String? mobile,
      int? loginType,
      bool autoRegistered = false})
      : accountId = json['userUuid'] as String,

        ///当accountId为null，则再继续读取userId
        accountToken = json['userToken'] as String,
        appKey = (json['appKey'] ?? appKey) as String,
        appId = (json['appId'] ?? -1) as int,
        nickname = json['nickname'] as String?,
        mobile = mobile ?? json['mobile'] as String?,
        loginType = loginType ?? (json['loginType'] ?? -1) as int,
        autoRegistered = (json['autoRegistered'] ?? autoRegistered) as bool;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['userUuid'] = accountId;
    map['userToken'] = accountToken;
    map['appKey'] = appKey;
    map['appId'] = appId;
    map['nickname'] = nickname;
    map['mobile'] = mobile;
    map['loginType'] = loginType;
    map['autoRegistered'] = autoRegistered;
    return map;
  }
}
