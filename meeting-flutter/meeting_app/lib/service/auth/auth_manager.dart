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
import 'package:nemeeting/service/profile/app_profile.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/service/response/result.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../../language/localizations.dart';
import '../../utils/meeting_util.dart';
import '../config/servers.dart';
import '../util/user_preferences.dart';

class AuthManager with AppLogger {
  factory AuthManager() => _instance ??= AuthManager._internal();

  static AuthManager? _instance;
  LoginInfo? _loginInfo;

  final StreamController<LoginInfo?> _authInfoChanged =
      StreamController.broadcast();

  AuthManager._internal();

  final NEMeetingKit _neMeetingKit = NEMeetingKit.instance;

  Future<LoginInfo?> _loadLoginInfoCache() async {
    final loginInfo = await GlobalPreferences().loginInfo;
    if (TextUtil.isEmpty(loginInfo)) return null;
    try {
      final cachedLoginInfo =
          LoginInfo.fromJson(jsonDecode(loginInfo as String) as Map);
      cachedLoginInfo.nickname = null;
      return cachedLoginInfo;
    } catch (e) {
      logger.d('LoginInfo.fromJson(jsonDecode(loginInfo) exception = ' +
          e.toString());
    }
    return null;
  }

  String? get accountId => _loginInfo?.accountId;

  String? get nickName => _loginInfo?.nickname ?? accountInfo?.nickname;

  String? get mobilePhone => accountInfo?.phoneNumber;

  String? get email => accountInfo?.email;

  String? get accountToken => _loginInfo?.accountToken;

  String? get appKey => _loginInfo?.appKey;

  int? get loginType => _loginInfo?.loginType;

  NEAccountInfo? get accountInfo =>
      _neMeetingKit.getAccountService().getAccountInfo();

  Future<bool> autoLogin() async {
    AuthState().updateState(state: AuthState.init);
    final result = await _autoLoginMeetingKit();
    if (result.isSuccess()) {
      AuthState().updateState(state: AuthState.authed);
    }
    return Future.value(result.code == NEMeetingErrorCode.success);
  }

  Future<Result<void>> _autoLoginMeetingKit() async {
    final loginInfo = await _loadLoginInfoCache();
    if (loginInfo == null) {
      return Result(code: NEMeetingErrorCode.failed);
    }
    logger.i('_autoLoginMeetingKit loginType = ${loginInfo.loginType}');
    final id = loginInfo.accountId;
    final token = loginInfo.accountToken;
    return loginProcedure(
      LoginType.token,
      () => _neMeetingKit.getAccountService().loginByToken(id, token),
      appKey: loginInfo.appKey,
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
    return NEMeetingUIKit.instance.initialize(
      NEMeetingUIKitConfig(
        appKey: appKey,
        corpCode: corpCode,
        corpEmail: corpEmail,
        appName: getAppLocalizations().globalAppName,

        /// 使用asset资源目录下的服务器配置文件
        useAssetServerConfig: true,
        iosBroadcastAppGroup: iosBroadcastExtensionAppGroup,
        serverUrl: Servers().baseUrl,
        extras: AppConfig.isInDebugMode
            ? {
                'debugMode': 1,
                'rtcLogLevel': '4', // DETAIL_INFO
              }
            : null,
        foregroundServiceConfig: foregroundServiceConfig,
      ),
    );
  }

  Future<Result<LoginInfo>> loginProcedure(
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
      return Result(code: initializeResult.code, msg: initializeResult.msg);
    }
    appKey ??= initializeResult.data?.appKey;
    final loginResult = await loginAction().map((accountInfo) {
      return LoginInfo(
        appKey: appKey!,
        accountId: accountInfo.userUuid,
        accountToken: accountInfo.userToken,
        isInitialPassword: accountInfo.isInitialPassword,
        loginType: loginType.index,
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
    return Result(
        code: loginResult.code, msg: loginResult.msg, data: loginResult.data);
  }

  void saveNick(String nick) {
    final loginInfo = _loginInfo;
    if (loginInfo != null) {
      loginInfo.nickname = nick;
      _syncAuthInfo(loginInfo);
    }
  }

  void loginResultSuccess(LoginInfo loginInfo) {
    _loginInfo = loginInfo;
    _syncAuthInfo(loginInfo);

    /// 登录成功后重新加载用户本地会议记录
    LocalHistoryMeetingManager().ensureInit();
  }

  void loginResultFailed() {}

  void _syncAuthInfo(LoginInfo loginInfo) {
    AppProfile.updateProfile(loginInfo);
    GlobalPreferences().setLoginInfo(jsonEncode(loginInfo));
    _authInfoChanged.add(loginInfo);
  }

  void logout() {
    _neMeetingKit.getAccountService().logout();
    AppProfile.clear();
    _loginInfo = null;
    GlobalPreferences().setLoginInfo('{}');
    UserPreferences().setMeetingInfo('');
    MeetingUtil.setUnreadNotifyMessageListenable(0);
    _authInfoChanged.add(null);
  }

  Stream<LoginInfo?> authInfoStream() {
    return _authInfoChanged.stream;
  }

  void tokenIllegal(String errorTip) {
    logout();
    AuthState().updateState(state: AuthState.tokenIllegal, errorTip: errorTip);
  }
}
