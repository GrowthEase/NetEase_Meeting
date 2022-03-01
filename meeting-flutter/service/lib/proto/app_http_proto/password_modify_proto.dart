// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/stringutil.dart';

import '../app_http_proto.dart';

class PasswordVerifyProto extends AppHttpProto<String> {
  /// 用户名
  final String username;

  /// 旧密码
  final String password;

  PasswordVerifyProto(this.username, this.password);

  @override
  String path() {
    return 'ne-meeting-account/changeAccountPassword';
  }

  @override
  String result(Map map) {
    return map['authCodeInternal'] as String;
  }

  @override
  Map data() {
    return {'username': username, 'password': StringUtil.pwdMD5(password)};
  }

  @override
  bool checkLoginState() {
    return false;
  }

}
