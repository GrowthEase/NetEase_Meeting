// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:service/values/app_constants.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:base/util/textutil.dart';
import 'package:yunxin_event_track/yunxin_event_track.dart';
import 'package:yunxin_meeting/meeting_sdk.dart';
import 'package:service/auth/auth_state.dart';
import 'package:service/config/login_type.dart';
import 'package:service/event/track_app_event.dart';
import 'package:service/model/login_info.dart';
import 'dart:convert';
import 'package:service/profile/app_profile.dart';
import 'package:base/util/global_preferences.dart';
import 'package:service/response/result.dart';
import 'package:service/values/strings.dart';
import 'package:yunxin_meeting/meeting_plugin.dart';

import '../module_name.dart' as module;

class AuthManager {
  static final String _tag = 'AuthManager';

  factory AuthManager() => _instance ??= AuthManager._internal();

  static AuthManager? _instance;
  LoginInfo? _loginInfo;

  final StreamController<LoginInfo?> _authInfoChanged =
      StreamController.broadcast();

  AuthManager._internal();

  final NEMeetingSDK _neMeetingSDK = NEMeetingSDK.instance;

  Future<void> init() async {
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

  String? get nickName => _loginInfo?.nickname;

  String? get mobilePhone => _loginInfo?.mobile;

  String? get accountToken => _loginInfo?.accountToken;

  String? get appKey => _loginInfo?.appKey;

  int? get loginType => _loginInfo?.loginType;

  Future<bool> autoLogin() async {
    AuthState().updateState(state: AuthState.init);
    var result = await autoLoginMeetingSDK();
    return Future.value(result.code == NEMeetingErrorCode.success);
  }

  Future<Result<void>> loginMeetingSDKWithSSO(
      LoginInfo loginInfo, String ssoToken) async {
    _loginInfo = loginInfo;
    var completer = Completer<Result<void>>();
    var config = NEForegroundServiceConfig();
    config
      ..contentTitle = Strings.appName
      ..contentText = Strings.foregroundContentText
      ..channelName = Strings.appName
      ..channelDesc = Strings.appName;
    _neMeetingSDK.initialize(
        NEMeetingSDKConfig(
            appKey: loginInfo.appKey,
            appName: Strings.appName,
            iosBroadcastAppGroup: iosBroadcastExtensionAppGroup,
            config: config), ({required errorCode, errorMessage, result}) {
      if (errorCode == NEMeetingErrorCode.success) {
        Alog.d(
            moduleName:module.moduleName,
            tag: _tag ,
            content: 'loginMeetingSDKWithSSO MeetingSDK initialize success');
        _neMeetingSDK.loginWithSSOToken(ssoToken, (
            {required errorCode, errorMessage, result}) {
          if (errorCode == NEMeetingErrorCode.success) {
            loginResultSuccess();
            Alog.d(
                moduleName:module.moduleName,
                tag: _tag ,
                content:
                    'loginMeetingSDKWithSSO MeetingSDK loginWithSSOToken success');
          } else {
            Alog.d(
                moduleName:module.moduleName,
                tag: _tag ,
                content:
                    'loginMeetingSDKWithSSO MeetingSDK loginWithSSOToken failed errorCode = $errorCode');
          }
          return completer.complete(Result(code: errorCode, msg: errorMessage));
        });
      } else {
        Alog.d(
            moduleName:module.moduleName,
            tag: _tag ,
            content:
                'loginMeetingSDKWithSSO MeetingSDK initialize failed errorCode = $errorCode');
        return completer.complete(Result(code: errorCode, msg: errorMessage));
      }
    });
    return completer.future;
  }

  Future<Result<void>> loginMeetingSDKWithToken(
      LoginType loginType, LoginInfo loginInfo) async {
    loginInfo.loginType = loginType.index;
    _loginInfo = loginInfo;
    var completer = Completer<Result<void>>();
    var config = NEForegroundServiceConfig();
    config
      ..contentTitle = Strings.appName
      ..contentText = Strings.foregroundContentText
      ..channelName = Strings.appName
      ..channelDesc = Strings.appName;
    _neMeetingSDK.initialize(
        NEMeetingSDKConfig(
            appKey: loginInfo.appKey,
            appName: Strings.appName,
            iosBroadcastAppGroup: iosBroadcastExtensionAppGroup,
            config: config), ({required errorCode, errorMessage, result}) {
      if (errorCode == NEMeetingErrorCode.success) {
        Alog.d(
            moduleName:module.moduleName,
            tag: _tag ,
            content: 'loginMeetingSDKWithToken MeetingSDK initialize success');
        _neMeetingSDK
            .loginWithToken(loginInfo.accountId, loginInfo.accountToken, (
                {required errorCode, errorMessage, result}) {
          if (errorCode == NEMeetingErrorCode.success) {
            loginResultSuccess();
            Alog.d(
                moduleName:module.moduleName,
                tag: _tag ,
                content:
                    'loginMeetingSDKWithToken MeetingSDK loginWithToken success');
          } else {
            Alog.d(
                moduleName:module.moduleName,
                tag: _tag ,
                content:
                    'loginMeetingSDKWithToken MeetingSDK loginWithToken failed errorCode = $errorCode,errorMessage :$errorMessage');
          }
          return completer.complete(Result(code: errorCode, msg: errorMessage));
        });
      } else {
        Alog.d(
            moduleName:module.moduleName,
            tag: _tag ,
            content:
                'loginMeetingSDKWithToken MeetingSDK initialize failed errorCode = $errorCode');
        return completer.complete(Result(code: errorCode, msg: errorMessage));
      }
    });
    return completer.future;
  }

  Future<Result<void>> autoLoginMeetingSDK() async {
    final _appKey = appKey;
    if (TextUtil.isEmpty(_appKey)) {
      return Result(code: NEMeetingErrorCode.failed);
    }

    var completer = Completer<Result<void>>();
    var config = NEForegroundServiceConfig();
    config
      ..contentTitle = Strings.appName
      ..contentText = Strings.foregroundContentText
      ..channelName = Strings.appName
      ..channelDesc = Strings.appName;
    _neMeetingSDK.initialize(
        NEMeetingSDKConfig(
            appKey: _appKey!,
            appName: Strings.appName,
            iosBroadcastAppGroup: iosBroadcastExtensionAppGroup,
            config: config), ({required errorCode, errorMessage, result}) {
      if (errorCode == NEMeetingErrorCode.success) {
        Alog.d(
            moduleName:module.moduleName,
            tag: _tag ,
            content: 'autoLoginMeetingSDK MeetingSDK initialize success');
        _neMeetingSDK
            .tryAutoLogin(({required errorCode, errorMessage, result}) {
          if (errorCode == NEMeetingErrorCode.success) {
            loginResultSuccess();
            Alog.d(
                moduleName:module.moduleName,
                tag: _tag ,
                content: 'autoLoginMeetingSDK MeetingSDK tryAutoLogin success');
          } else {
            Alog.d(
                moduleName:module.moduleName,
                tag: _tag ,
                content:
                    'autoLoginMeetingSDK MeetingSDK tryAutoLogin failed errorCode = $errorCode');
          }
          return completer.complete(Result(code: errorCode, msg: errorMessage));
        });
      } else {
        Alog.d(
            moduleName:module.moduleName,
            tag: _tag ,
            content:
                'autoLoginMeetingSDK MeetingSDK initialize failed errorCode = $errorCode');
        return completer.complete(Result(code: errorCode, msg: errorMessage));
      }
    });
    return completer.future;
  }

  void saveNick(String nick) {
    final loginInfo = _loginInfo;
    if (loginInfo != null) {
      loginInfo.nickname = nick;
      _syncAuthInfo(loginInfo);
    }
  }

  /// TODO
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
    EventTrack().trackEvent(ActionEvent.periodic(TrackAppEventName.logout,
        module: AppModuleName.moduleName));
    _neMeetingSDK.logout(({required errorCode, errorMessage, result}) {});
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
