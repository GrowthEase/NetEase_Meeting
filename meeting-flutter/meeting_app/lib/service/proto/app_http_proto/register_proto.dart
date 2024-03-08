// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/model/login_info.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../app_http_proto.dart';

class RegisterProto extends AppHttpProto<LoginInfo> {
  /// 手机号
  final String mobile;

  /// 验证码
  final String verifyExchangeCode;

  /// 昵称
  final String nickname;

  /// 密码
  final String password;

  RegisterProto(
      this.mobile, this.verifyExchangeCode, this.nickname, this.password);

  @override
  String path() {
    return 'ne-meeting-account/registerByMobileVerifyExchangeCode';
  }

  @override
  LoginInfo result(Map map) {
    return LoginInfo.fromJson(map);
  }

  @override
  Map data() {
    return {
      'mobile': mobile,
      'verifyExchangeCode': verifyExchangeCode,
      'nickname': nickname,
      'password': StringUtil.pwdMD5(password)
    };
  }

  @override
  bool checkLoginState() {
    return false;
  }
}
