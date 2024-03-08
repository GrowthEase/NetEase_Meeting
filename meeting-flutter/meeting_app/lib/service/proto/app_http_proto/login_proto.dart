// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/auth/password_utils.dart';
import 'package:nemeeting/service/config/login_type.dart';
import 'package:nemeeting/service/config/servers.dart';
import 'package:nemeeting/service/model/login_info.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../app_http_proto.dart';

class LoginProto extends AppHttpProto<LoginInfo> {
  /// 登录类型
  final LoginType loginType;

  // /// accountId
  // final String accountId;
  //
  // /// 第三方登录账号
  // final String account;
  //
  // /// 手机号
  // final String mobile;
  //
  // /// token
  // final String token;
  //
  // /// 验证码
  // final String verifyCode;
  //
  // /// 密码
  // final String passWord;

  LoginProto({required this.loginType});

  @override
  String path() {
    switch (loginType) {
      case LoginType.password:
        return 'ne-meeting-account/loginByUsernamePassword';
      case LoginType.verify:
        return 'ne-meeting-account/loginByMobileVerifyCode';
      default:
        return 'account/login';
    }
  }

  @override
  LoginInfo result(Map map) {
    return LoginInfo.fromJson(map);
  }

  @override
  Map data() {
    return {
      'loginType': loginType.index,
    };
  }

  @override
  bool checkLoginState() {
    return LoginType.token == loginType;
  }
}

class PasswordLoginProto extends LoginProto {
  final String appKey;

  final String username;

  final String password;

  PasswordLoginProto(this.appKey, this.username, this.password)
      : super(loginType: LoginType.password);

  @override
  String path() =>
      '${Servers().baseUrl}scene/meeting/$appKey/v1/login/$username';

  @override
  Map data() => {
        'password': PasswordUtils.hash(password),
      };

  @override
  LoginInfo result(Map map) {
    return LoginInfo.fromJson(map,
        appKey: appKey, loginType: LoginType.password.index);
  }
}

class MobileCheckCodeLoginProto extends LoginProto {
  final String appKey;

  final String mobile;

  final String verifyCode;

  MobileCheckCodeLoginProto(this.appKey, this.mobile, this.verifyCode)
      : super(loginType: LoginType.verify);

  @override
  String path() {
    return '${Servers().baseUrl}scene/meeting/$appKey/v1/mobile/$mobile/login';
  }

  @override
  Map data() => {
        // 'mobile': mobile,
        'verifyCode': verifyCode,
      };

  @override
  LoginInfo result(Map map) {
    return LoginInfo.fromJson(map,
        appKey: appKey, mobile: mobile, loginType: LoginType.verify.index);
  }
}

class ThirdPartyLoginProto extends LoginProto {
  /// accountId
  final String username;

  final String password;

  ThirdPartyLoginProto(this.username, this.password)
      : super(loginType: LoginType.third);

  @override
  Map data() => {
        ...super.data(),
        'username': username,
        'authValue': StringUtil.dartMD5(password),
      };
}
