// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nemeeting/application.dart';
import 'package:nemeeting/constants.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:nemeeting/service/values/app_constants.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:netease_common/netease_common.dart';
import 'package:nemeeting/service/auth/auth_state.dart';
import 'package:nemeeting/service/config/login_type.dart';
import 'package:nemeeting/service/model/login_info.dart';
import 'dart:convert';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:netease_meeting_kit/meeting_kit.dart';

import '../../language/localizations.dart';
import '../../utils/meeting_util.dart';
import '../config/servers.dart';
import '../util/user_preferences.dart';

class AuthManager with AppLogger {
  static AuthManager? _instance;
  factory AuthManager() => _instance ??= AuthManager._internal();

  LoginInfo? _loginInfo;

  AuthManager._internal();

  final NEMeetingKit _neMeetingKit = NEMeetingKit.instance;

  Future<LoginInfo?> _loadLoginInfoCache() async {
    final loginInfo = await GlobalPreferences().loginInfo;
    if (TextUtil.isEmpty(loginInfo)) return null;
    try {
      return LoginInfo.fromJson(jsonDecode(loginInfo as String) as Map);
    } catch (e) {
      logger.d('LoginInfo.fromJson(jsonDecode(loginInfo) exception = ' +
          e.toString());
    }
    return null;
  }

  String? get accountId => accountInfo?.userUuid;

  String? get nickName => accountInfo?.nickname;

  String? get phoneNumber => accountInfo?.phoneNumber;

  String? get email => accountInfo?.email;

  String? get accountToken => accountInfo?.userToken;

  String? get appKey => _loginInfo?.appKey;

  LoginType? get loginType => _loginInfo?.loginType;

  NEAccountInfo? get accountInfo =>
      _neMeetingKit.getAccountService().getAccountInfo();

  bool get isLoggedIn => accountInfo != null;

  Future<bool> autoLogin() async {
    AuthState().updateState(state: AuthState.init);
    final result = await _autoLoginMeetingKit();
    if (result.isSuccess()) {
      AuthState().updateState(state: AuthState.authed);
    }
    return Future.value(result.code == NEMeetingErrorCode.success);
  }

  Future<NEResult<void>> _autoLoginMeetingKit() async {
    final loginInfo = await _loadLoginInfoCache();
    if (loginInfo == null) {
      return NEResult(code: NEMeetingErrorCode.failed);
    }
    logger.i('_autoLoginMeetingKit loginType = ${loginInfo.loginType}');
    final id = loginInfo.accountId;
    final token = loginInfo.accountToken;
    return loginProcedure(
      loginInfo.loginType,
      () => _neMeetingKit.getAccountService().loginByToken(id, token),
      appKey: loginInfo.appKey,
      corpCode: loginInfo.corpCode,
    );
  }

  Future<NEResult<NEMeetingCorpInfo?>> initialize({
    String? appKey,
    String? corpCode,
    String? corpEmail,
  }) async {
    assert(appKey != null || corpCode != null || corpEmail != null);
    await Application.ensureInitialized();
    final foregroundServiceConfig = NEForegroundServiceConfig(
      contentTitle: getAppLocalizations().globalAppName,
      contentText: getAppLocalizations().meetingForegroundContentText,
      ticker: getAppLocalizations().globalAppName,
      channelId: 'netease_meeting_channel',
      channelName: getAppLocalizations().globalAppName,
      channelDesc: getAppLocalizations().globalAppName,
    );
    return NEMeetingKit.instance.initialize(
      NEMeetingKitConfig(
        appKey: appKey,
        corpCode: corpCode,
        corpEmail: corpEmail,
        appName: getAppLocalizations().globalAppName,

        /// 使用asset资源目录下的服务器配置文件
        useAssetServerConfig: true,
        iosBroadcastAppGroup: iosBroadcastExtensionAppGroup,
        iosBroadcastScheme: iosBroadcastScheme,
        serverUrl: Servers().baseUrl,
        extras: AppConfig.isInDebugMode
            ? {
                'debugMode': 1,
                'rtcLogLevel': '4', // DETAIL_INFO
              }
            : null,
        foregroundServiceConfig: foregroundServiceConfig,
        apnsCerName: AppConfig().apnsCerName,
        mixPushConfig: AppConfig().mixPushConfig,
      ),
    );
  }

  Future<NEResult<LoginInfo>> loginProcedure(
    LoginType loginType,
    Future<NEResult<NEAccountInfo>> Function() loginAction, {
    String? appKey,
    String? corpCode,
    String? corpEmail,
  }) async {
    final initializeResult = await initialize(
        appKey: appKey, corpCode: corpCode, corpEmail: corpEmail);
    logger.i('MeetingSDK initialize result=$initializeResult');
    if (!initializeResult.isSuccess()) {
      return initializeResult.cast();
    }
    appKey ??= initializeResult.data?.appKey;
    final loginResult = await loginAction().map<LoginInfo>((accountInfo) {
      return LoginInfo(
        appKey: appKey!,
        corpCode: corpCode,
        accountId: accountInfo.userUuid,
        accountToken: accountInfo.userToken,
        isInitialPassword: accountInfo.isInitialPassword,
        loginType: loginType,
      );
    });
    logger.i('MeetingSDK login result=$loginResult');
    if (loginResult.isSuccess()) {
      final loginInfo = loginResult.nonNullData;
      loginResultSuccess(loginInfo);
      assert(() {
        debugPrint('loginProcedure: loginType=${loginInfo.loginType}');
        return true;
      }());
    }
    return loginResult;
  }

  void loginResultSuccess(LoginInfo loginInfo) {
    _setLoginInfo(loginInfo);

    /// 登录成功后重新加载用户本地会议记录
    LocalHistoryMeetingManager().ensureInit();
  }

  void _setLoginInfo(LoginInfo? loginInfo) {
    _loginInfo = loginInfo;
    GlobalPreferences()
        .setLoginInfo(loginInfo == null ? '{}' : jsonEncode(loginInfo));
  }

  void logout() {
    _neMeetingKit.getAccountService().logout();
    _setLoginInfo(null);
    UserPreferences().setMeetingInfo('');
    MeetingUtil.setUnreadNotifyMessageListenable(0);
  }

  void tokenIllegal(String errorTip) {
    logout();
    AuthState().updateState(state: AuthState.tokenIllegal, errorTip: errorTip);
  }
}
