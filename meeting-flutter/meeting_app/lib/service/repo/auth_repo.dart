// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:netease_meeting_core/meeting_kit.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/auth/auth_state.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/config/login_type.dart';
import 'package:nemeeting/service/model/login_info.dart';
import 'package:nemeeting/service/model/parse_sso_token.dart';
import 'package:nemeeting/service/proto/app_http_proto/login_proto.dart';
import 'package:nemeeting/service/repo/i_repo.dart';
import 'package:nemeeting/service/response/result.dart';

/// 登录注册,
class AuthRepo extends IRepo {
  AuthRepo._internal();

  static final AuthRepo _singleton = AuthRepo._internal();

  factory AuthRepo() => _singleton;

  /// 请求验证码
  Future<Result<void>> getMobileCheckCode(String appKey, String mobile) async {
    return appService.getMobileCheckCode(appKey, mobile);
  }

  /// 登录
  Future<Result<LoginInfo>> login(LoginProto loginProto) {
    return appService.login(loginProto).then((result) async {
      if (result.code == HttpCode.success) {
        AuthState().updateState(state: AuthState.authed);
        var sdkLoginResult = await AuthManager().loginMeetingKitWithToken(
            loginProto.loginType, result.data as LoginInfo);
        return result.copy(
          code: sdkLoginResult.code == NEMeetingErrorCode.success
              ? HttpCode.success
              : HttpCode.meetingSDKLoginError,
          msg: sdkLoginResult.msg,
        );
      } else if (result.code == HttpCode.verifyError ||
          result.code == HttpCode.tokenError ||
          result.code == HttpCode.passwordError ||
          result.code == HttpCode.accountNotExist ||
          result.code == HttpCode.loginPasswordError) {
        AuthState().updateState(state: AuthState.init);

        /// reset
        AuthManager().logout();
      }
      return result;
    });
  }

  /// 密码登录
  Future<Result<LoginInfo>> loginByPwd(
      String appKey, String username, String password) {
    return login(PasswordLoginProto(appKey, username, password));
  }

  /// 自动登录
  Future<Result<void>> loginByToken(LoginType loginType, String accountId,
      String accountToken, String appKey) {
    var loginInfo = LoginInfo(
        accountId: accountId, accountToken: accountToken, appKey: appKey);
    return AuthManager()
        .loginMeetingKitWithToken(loginType, loginInfo)
        .then((sdkLoginResult) {
      if (sdkLoginResult.code == HttpCode.success) {
        AuthState().updateState(state: AuthState.authed);
      } else {
        AuthState().updateState(state: AuthState.init);
        AuthManager().logout();
      }
      return Result(code: sdkLoginResult.code, msg: sdkLoginResult.msg);
    });
  }

  /// 验证码登录
  Future<Result<LoginInfo>> loginByMobileCheckCode(
      String appKey, String mobile, String checkCode) {
    return login(MobileCheckCodeLoginProto(appKey, mobile, checkCode));
  }

  /// 验证码登录
  Future<Result<LoginInfo>> loginByThird(String account, String password) {
    return login(ThirdPartyLoginProto(account, password));
  }

  /// 解析ssoToken
  Future<Result<ParseSSOToken>> parseSSOToken(String ssoToken) {
    return appService.parseSSOToken(ssoToken);
  }

  /// 密码验证
  /// TODO:
  Future<Result<String>> passwordVerify(String userId, String oldPassword) {
    return appService.passwordVerify(userId, oldPassword);
  }

  /// 登录后密码重置
  Future<Result<void>> passwordResetAfterLogin(String newPassWord) {
    return appService.passwordReset(newPassWord);
  }

  /// 登录前密码重置
  Future<Result<void>> passwordResetByMobileCode(
      String mobile, String newPassWord, String exchangeCode) {
    return appService.passwordResetByMobileCode(
        mobile, newPassWord, exchangeCode);
  }
}
