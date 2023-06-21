// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nemeeting/application.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/values/app_constants.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:netease_common/netease_common.dart';
import 'package:nemeeting/service/auth/auth_state.dart';
import 'package:nemeeting/service/config/login_type.dart';
import 'package:nemeeting/service/model/login_info.dart';
import 'dart:convert';
import 'package:nemeeting/service/profile/app_profile.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/service/response/result.dart';
import 'package:nemeeting/service/values/strings.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../module_name.dart' as module;

class AuthManager {
  static final String _tag = 'AuthManager';

  factory AuthManager() => _instance ??= AuthManager._internal();

  static AuthManager? _instance;
  LoginInfo? _loginInfo;
  bool _autoRegistered = false;

  final StreamController<LoginInfo?> _authInfoChanged =
      StreamController.broadcast();

  AuthManager._internal();

  final NEMeetingKit _neMeetingKit = NEMeetingKit.instance;

  Future<void> _init() async {
    var loginInfo = await GlobalPreferences().loginInfo;
    if (TextUtil.isEmpty(loginInfo)) return;
    try {
      final cachedLoginInfo =
          LoginInfo.fromJson(jsonDecode(loginInfo as String) as Map);
      _authInfoChanged.add(cachedLoginInfo);
      _loginInfo = cachedLoginInfo;
    } catch (e) {
      Alog.d(
          moduleName: module.moduleName,
          tag: 'AuthManager',
          content: 'LoginInfo.fromJson(jsonDecode(loginInfo) exception = ' +
              e.toString());
    }
  }

  String? get accountId => _loginInfo?.accountId;

  String? get nickName =>
      _loginInfo?.nickname ??
      _neMeetingKit.getAccountService().getAccountInfo()?.nickname;

  String? get mobilePhone => _loginInfo?.mobile;

  String? get accountToken => _loginInfo?.accountToken;

  String? get appKey => _loginInfo?.appKey;

  int? get loginType => _loginInfo?.loginType;

  bool? get autoRegistered => _autoRegistered;

  Future<bool> autoLogin() async {
    AuthState().updateState(state: AuthState.init);
    await _init();
    final result = await _autoLoginMeetingKit();
    return Future.value(result.code == NEMeetingErrorCode.success);
  }

  Future<Result<void>> loginMeetingKitWithToken(
      LoginType loginType, LoginInfo loginInfo) async {
    loginInfo.loginType = loginType.index;
    _loginInfo = loginInfo;
    _autoRegistered = loginInfo.autoRegistered;
    return loginProcedure(
      appKey,
      () => _neMeetingKit.loginWithToken(
          loginInfo.accountId, loginInfo.accountToken),
    );
  }

  Future<Result<void>> _autoLoginMeetingKit() async {
    final id = accountId;
    final token = accountToken;
    if (id == null || token == null || id.isEmpty || token.isEmpty) {
      return Result(code: NEMeetingErrorCode.failed);
    }
    return loginProcedure(
      appKey,
      () => _neMeetingKit.loginWithToken(id, token),
    );
  }

  Future<Result<void>> loginProcedure(
    String? appKey,
    Future<NEResult<void>> Function() loginAction,
  ) async {
    if (appKey == null || appKey.isEmpty) {
      return Result(code: NEMeetingErrorCode.failed, msg: 'appKey is empty');
    }
    await Application.ensureInitialized();
    final foregroundServiceConfig = NEForegroundServiceConfig(
      contentTitle: Strings.appName,
      contentText: Strings.foregroundContentText,
      ticker: Strings.appName,
      channelId: 'netease_meeting_channel',
      channelName: Strings.appName,
      channelDesc: Strings.appName,
    );
    await NEMeetingUIKit().switchLanguage(NEMeetingLanguage.chinese);
    final initializeResult = await NEMeetingUIKit().initialize(
      NEMeetingUIKitConfig(
        appKey: appKey,
        appName: Strings.appName,
        iosBroadcastAppGroup: iosBroadcastExtensionAppGroup,
        extras: AppConfig.isInDebugMode
            ? {
                'debugMode': 1,
                'rtcLogLevel': '4', // DETAIL_INFO
              }
            : null,
        foregroundServiceConfig: foregroundServiceConfig,
      ),
    );
    Alog.i(
      moduleName: module.moduleName,
      tag: _tag,
      content: 'MeetingSDK initialize result=$initializeResult',
    );
    if (!initializeResult.isSuccess()) {
      return Result(code: initializeResult.code, msg: initializeResult.msg);
    }
    final loginResult = await loginAction();
    Alog.i(
      moduleName: module.moduleName,
      tag: _tag,
      content: 'MeetingSDK login result=$loginResult',
    );
    if (loginResult.isSuccess()) {
      loginResultSuccess();
      assert(() {
        debugPrint('loginProcedure: loginType=$loginType');
        return true;
      }());
    }
    return Result(code: loginResult.code, msg: loginResult.msg);
  }

  void saveNick(String nick) {
    final loginInfo = _loginInfo;
    if (loginInfo != null) {
      loginInfo.nickname = nick;
      _autoRegistered = false;
      _syncAuthInfo(loginInfo);
    }
  }

  void updateAppKey(String appKey) {
    final loginInfo = _loginInfo;
    if (loginInfo != null) {
      loginInfo.appKey = appKey;
      _syncAuthInfo(loginInfo);
    }
  }

  void loginResultSuccess() {
    _syncAuthInfo(_loginInfo as LoginInfo);
  }

  void loginResultFailed() {}

  void _syncAuthInfo(LoginInfo loginInfo) {
    AppProfile.updateProfile(loginInfo);
    GlobalPreferences().setLoginInfo(jsonEncode(loginInfo));
    _authInfoChanged.add(loginInfo);
  }

  void logout() {
    _neMeetingKit.logout();
    AppProfile.clear();
    _loginInfo = null;
    GlobalPreferences().setLoginInfo('{}');
    _authInfoChanged.add(_loginInfo);
  }

  Stream<LoginInfo?> authInfoStream() {
    return _authInfoChanged.stream;
  }

  void tokenIllegal(String errorTip) {
    logout();
    AuthState().updateState(state: AuthState.tokenIllegal, errorTip: errorTip);
  }
}
