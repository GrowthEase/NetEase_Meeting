// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:netease_meeting_kit/meeting_kit.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/auth/auth_state.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/config/login_type.dart';
import 'package:nemeeting/service/model/login_info.dart';
import 'package:nemeeting/service/repo/i_repo.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

/// 登录注册,
class AuthRepo extends IRepo {
  AuthRepo._internal();

  static final AuthRepo _singleton = AuthRepo._internal();

  factory AuthRepo() => _singleton;

  /// 请求验证码
  Future<VoidResult> getMobileCheckCode(String appKey, String mobile) async {
    /// 请求验证码前要先初始化
    await AuthManager().initialize(appKey: appKey);
    return NEMeetingKit.instance
        .getAccountService()
        .requestSmsCodeForLogin(mobile);
  }

  Future<NEResult<LoginInfo>> loginByPwd(
    String appKey,
    Future<NEResult<NEAccountInfo>> action(), {
    String? corpCode,
    String? corpEmail,
  }) async {
    return AuthManager()
        .loginProcedure(
      LoginType.password,
      action,
      appKey: appKey,
      corpCode: corpCode,
      corpEmail: corpEmail,
    )
        .then((sdkLoginResult) {
      if (sdkLoginResult.code == HttpCode.success) {
        AuthState().updateState(state: AuthState.authed);
      } else {
        AuthManager().logout();
        AuthState().updateState(state: AuthState.init);
      }
      return sdkLoginResult;
    });
  }

  /// 验证码登录
  Future<NEResult<LoginInfo>> loginByMobileCheckCode(
      String appKey, String mobile, String checkCode) {
    return AuthManager().loginProcedure(LoginType.verify, appKey: appKey,
        () async {
      return NEMeetingKit.instance
          .getAccountService()
          .loginBySmsCode(mobile, checkCode);
    }).then((sdkLoginResult) {
      if (sdkLoginResult.code == HttpCode.success) {
        AuthState().updateState(state: AuthState.authed);
      } else {
        AuthManager().logout();
        AuthState().updateState(state: AuthState.init);
      }
      return sdkLoginResult;
    });
  }

  Future<NEResult<LoginInfo>> loginBySSOUri(
    String uri, {
    String? appKey,
    String? corpCode,
    String? corpEmail,
  }) {
    return AuthManager().loginProcedure(
      LoginType.sso,
      () async {
        return NEMeetingKit.instance.getAccountService().loginBySSOUri(uri);
      },
      appKey: appKey,
      corpCode: corpCode,
      corpEmail: corpEmail,
    ).then((sdkLoginResult) {
      if (sdkLoginResult.code == HttpCode.success) {
        AuthState().updateState(state: AuthState.authed);
      } else {
        AuthManager().logout();
        AuthState().updateState(state: AuthState.init);
      }
      return sdkLoginResult;
    });
  }
}
