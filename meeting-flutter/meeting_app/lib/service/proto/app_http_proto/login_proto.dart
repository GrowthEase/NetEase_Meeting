// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/util/stringutil.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/config/login_type.dart';
import 'package:nemeeting/service/config/servers.dart';
import 'package:nemeeting/service/model/login_info.dart';

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
    // switch(loginType){
    //   case LoginType.token:
    //     return {'accountId': accountId, 'loginType': loginType.index, 'accountToken': getAuthValue(loginType)};
    //   case LoginType.third:
    //     return {'username': account, 'loginType': loginType.index, 'authValue': getAuthValue(loginType)};
    //   case LoginType.password:
    //     return {'username': mobile, 'loginType': loginType.index, 'password': getAuthValue(loginType)};
    //   case LoginType.verify:
    //     return {'mobile': mobile, 'verifyCode': verifyCode};
    //   default:
    //     return {'mobilePhone': mobile, 'loginType': loginType.index, 'authValue': getAuthValue(loginType)};
    // }
  }

  // String getAuthValue(LoginType loginType) {
  //   switch (loginType) {
  //     case LoginType.token:
  //       return token;
  //     case LoginType.verify:
  //       return verifyCode;
  //     case LoginType.password:
  //       return StringUtil.pwdMD5(passWord);
  //     case LoginType.third:
  //       return StringUtil.dartMD5(passWord);
  //     default:
  //       return '';
  //   }
  // }

  @override
  bool checkLoginState() {
    return LoginType.token == loginType;
  }
}

class TokenLoginProto extends LoginProto {
  /// accountId
  final String accountId;

  final String accountToken;

  TokenLoginProto(this.accountId, this.accountToken)
      : super(loginType: LoginType.token);

  @override
  Map data() => {
        ...super.data(),
        'accountId': accountId,
        'accountToken': accountToken,
      };
}

class PasswordLoginProto extends LoginProto {
  final String appKey = AppConfig().appKey;

  final String username;

  final String password;

  PasswordLoginProto(this.username, this.password)
      : super(loginType: LoginType.password);

  @override
  String path() =>
      '${Servers().baseUrl}scene/meeting/$appKey/v1/login/$username';

  @override
  Map data() => {
        'password': StringUtil.dartMD5('$password@yiyong.im'),
      };

  @override
  LoginInfo result(Map map) {
    return LoginInfo.fromJson(map,
        appKey: appKey, loginType: LoginType.password.index);
  }
}

class VerifyCodeLoginProto extends LoginProto {
  final String appKey = AppConfig().appKey;

  final String mobile;

  final String verifyCode;

  VerifyCodeLoginProto(this.mobile, this.verifyCode)
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
