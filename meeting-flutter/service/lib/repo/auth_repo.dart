// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:yunxin_event_track/yunxin_event_track.dart';
import 'package:yunxin_meeting/meeting_sdk.dart';
import 'package:service/auth/auth_manager.dart';
import 'package:service/auth/auth_state.dart';
import 'package:service/client/http_code.dart';
import 'package:service/config/login_type.dart';
import 'package:service/config/scene_type.dart';
import 'package:service/event/track_app_event.dart';
import 'package:service/model/login_info.dart';
import 'package:service/model/parse_sso_token.dart';
import 'package:service/proto/app_http_proto/login_proto.dart';
import 'package:service/repo/i_repo.dart';
import 'package:service/response/result.dart';

/// 登录注册,
class AuthRepo extends IRepo {
  AuthRepo._internal();

  static final AuthRepo _singleton = AuthRepo._internal();

  factory AuthRepo() => _singleton;

  /// 请求验证码
  Future<Result<void>> getAuthCode(String mobile, SceneType scene) async {
    return appService.getAuthCode(mobile, scene);
  }

  /// 验证验证码
  Future<Result<String>> verifyAuthCode(String mobile, String authCode, SceneType scene) {
    return appService.verifyAuthCode(mobile, authCode, scene);
  }

  /// 登录
  Future<Result<LoginInfo>> login(LoginProto loginProto) {
    EventTrack().trackEvent(ActionEvent.periodic(TrackAppEventName.login,
        module: AppModuleName.moduleName, extra: {'value': loginProto.loginType.index}));
    return appService
        .login(loginProto)
        .then((result) async {
      if (result.code == HttpCode.success) {
        AuthState().updateState(state: AuthState.authed);
        var sdkLoginResult = await AuthManager().loginMeetingSDKWithToken(loginProto.loginType, result.data as LoginInfo);
        return result.copy(code: sdkLoginResult.code == NEMeetingErrorCode.success ? HttpCode.success : HttpCode.meetingSDKLoginError);
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
  Future<Result<LoginInfo>> loginByPwd(String mobile, String password) {
    return login(PasswordLoginProto(mobile, password));
  }

  /// 自动登录
  Future<Result<LoginInfo>> loginByToken(String  accountId, String accountToken) async {
    return login(TokenLoginProto(accountId, accountToken));
  }

  /// 验证码登录
  Future<Result<LoginInfo>> loginByVerify(String mobile, String verifyCode) {
    return login(VerifyCodeLoginProto(mobile, verifyCode));
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
  Future<Result<void>> passwordResetByMobileCode(String mobile, String newPassWord, String exchangeCode) {
    return appService.passwordResetByMobileCode(mobile, newPassWord, exchangeCode);
  }

  /// SSO登录
  Future<Result<void>> loginBySSO(LoginInfo loginInfo, String ssoToken) async {
    AuthState().updateState(state: AuthState.unauth);
    AuthState().updateState(state: AuthState.init);
    var completer = Completer<Result<void>>();
    await AuthManager().loginMeetingSDKWithSSO(loginInfo,ssoToken).then((result) {
      if(result.code == NEMeetingErrorCode.success){
        AuthState().updateState(state: AuthState.authed);
        return completer.complete(Result(code: HttpCode.success));
      }else{
        AuthState().updateState(state: AuthState.init);
        return completer.complete(Result(code: result.code));
      }
    });

    return completer.future;
  }
}
