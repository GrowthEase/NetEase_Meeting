// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/config/login_type.dart';

class LoginInfo {
  final String appKey;
  final String? corpCode;
  final String accountId;
  final String accountToken;
  final LoginType loginType;
  final bool isInitialPassword;

  LoginInfo({
    required this.accountId,
    required this.accountToken,
    required this.appKey,
    this.corpCode,
    required this.loginType,
    this.isInitialPassword = false,
  });

  LoginInfo.fromJson(Map json)
      : accountId = json['userUuid'] as String,
        accountToken = json['userToken'] as String,
        appKey = (json['appKey']) as String,
        corpCode = (json['corpCode']) as String?,
        loginType = LoginTypeFromInt.fromInt(json['loginType'] as int?),
        isInitialPassword = (json['initialPassword'] ?? false) as bool;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['appKey'] = appKey;
    map['corpCode'] = corpCode;
    map['userUuid'] = accountId;
    map['userToken'] = accountToken;
    map['loginType'] = loginType.index;
    return map;
  }
}
