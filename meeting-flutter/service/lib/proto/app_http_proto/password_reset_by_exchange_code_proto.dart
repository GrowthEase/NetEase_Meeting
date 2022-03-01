// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/stringutil.dart';

import '../app_http_proto.dart';

class PasswordResetByCodeProto extends AppHttpProto<void> {
  /// 用户手机
  final String mobile;

  /// 新密码
  final String newPassword;

  /// 验证成功后的内部请求码
  final String verifyExchangeCode;

  PasswordResetByCodeProto(this.mobile, this.newPassword, this.verifyExchangeCode);

  @override
  String path() {
    return 'ne-meeting-account/changePasswordByMobileVerifyExchangeCode';
  }

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() {
    return {
      'mobile': mobile,
      'password': StringUtil.pwdMD5(newPassword),
      'verifyExchangeCode':verifyExchangeCode
    };
  }
}
