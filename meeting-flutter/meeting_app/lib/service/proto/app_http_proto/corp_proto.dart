// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/auth/password_utils.dart';
import 'package:nemeeting/service/model/login_info.dart';

import '../../repo/corp_repo.dart';
import '../app_http_proto.dart';

class GetCorpInfoProto extends AppHttpProto<NECorpInfo> {
  final String? corpCode;
  final String? corpEmail;

  GetCorpInfoProto({this.corpCode, this.corpEmail});

  @override
  String get method => 'GET';

  @override
  String path() => 'scene/meeting/v2/app-info';

  @override
  NECorpInfo result(Map map) => NECorpInfo.fromJson(map, corpCode: corpCode);

  @override
  Map data() {
    return {
      if (corpCode != null) 'code': corpCode,
      if (corpEmail != null) 'email': corpEmail,
    };
  }
}

class GetCorpAccountInfoProto extends AppHttpProto<LoginInfo> {
  final String appKey;
  final String key;
  final String param;

  GetCorpAccountInfoProto(this.appKey, this.key, this.param);

  @override
  String get method => 'GET';

  @override
  String path() => 'scene/meeting/v2/sso-account-info';

  @override
  Map<String, dynamic>? header() => {
        'appKey': appKey,
      };

  @override
  LoginInfo result(Map map) => LoginInfo.fromJson(appKey: appKey, map);

  @override
  Map data() {
    return {
      'key': key,
      'param': param,
    };
  }
}

class ResetPasswordProto extends AppHttpProto<LoginInfo> {
  final String appKey;
  final String oldPassword;
  final String newPassword;
  final String? accountId;
  final String? account;

  ResetPasswordProto(
    this.appKey,
    this.oldPassword,
    this.newPassword, {
    this.accountId,
    this.account,
  }) : assert(accountId != null || account != null);

  @override
  String get method => 'POST';

  @override
  String path() => 'scene/meeting/v2/password';

  @override
  LoginInfo result(Map map) => LoginInfo.fromJson(appKey: appKey, map);

  @override
  Map<String, dynamic>? header() {
    return {
      'appKey': appKey,
    };
  }

  @override
  Map data() {
    return {
      if (account != null) 'username': account,
      if (accountId != null) 'userUuid': accountId,
      'password': PasswordUtils.hash(oldPassword),
      'newPassword': PasswordUtils.hash(newPassword),
    };
  }
}
