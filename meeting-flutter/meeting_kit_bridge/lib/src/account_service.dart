// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:fluttermodule/meeting_kit_bridge.dart';
import 'package:fluttermodule/src/callback.dart';
import 'package:fluttermodule/src/service.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

class AccountServiceBridge extends Service with NEAccountServiceListener {
  final MeetingKitBridge meetingKitBridge;

  AccountServiceBridge.asService(this.meetingKitBridge) {
    meetingKitBridge.accountService.addListener(this);
  }

  @override
  String get name => 'account';

  @override
  Future handleCall(String method, arguments) {
    switch (method) {
      case 'getAccountInfo':
        return _handleGetAccountInfo(arguments);
      case 'loginByToken':
        return _handleLoginByToken(arguments);
      case 'loginByPassword':
        return _handleLoginByPassword(arguments);
      case 'loginByPhoneNumber':
        return _handleLoginByPhoneNumber(arguments);
      case 'loginByEmail':
        return _handleLoginByEmail(arguments);
      case 'loginBySmsCode':
        return _handleLoginBySmsCode(arguments);
      case 'tryAutoLogin':
        return _handleTryAutoLogin(arguments);
      case 'generateSSOLoginWebURL':
        return _handleGenerateSSOLoginWebURL(arguments);
      case 'loginBySSOUri':
        return _handleLoginBySSOUri(arguments);
      case 'logout':
        return _handleLogout(arguments);
      case 'requestSmsCodeForLogin':
        return _handleRequestSmsCodeForLogin(arguments);
      case 'resetPassword':
        return _handleResetPassword(arguments);
      case 'updateAvatar':
        return _handleUpdateAvatar(arguments);
      case 'updateNickname':
        return _handleUpdateNickname(arguments);
    }
    return super.handleCall(method, arguments);
  }

  Map? convertAccountInfo(NEAccountInfo? accountInfo) {
    Map? data;
    if (accountInfo != null) {
      final val = <String, dynamic>{};
      data = val;
      void writeNotNull(String key, dynamic value) {
        if (value != null) {
          val[key] = value;
        }
      }

      writeNotNull('userUuid', accountInfo.userUuid);
      writeNotNull('userToken', accountInfo.userToken);
      writeNotNull('privateMeetingNum', accountInfo.privateMeetingNum);
      writeNotNull(
          'privateShortMeetingNum', accountInfo.privateShortMeetingNum);
      writeNotNull('nickname', accountInfo.nickname);
      writeNotNull('avatar', accountInfo.avatar);
      writeNotNull('phoneNumber', accountInfo.phoneNumber);
      writeNotNull('email', accountInfo.email);
      writeNotNull('corpName', accountInfo.corpName);
      writeNotNull('isInitialPassword', accountInfo.isInitialPassword);
      writeNotNull('isAnonymous', meetingKitBridge.accountService.isAnonymous);
      writeNotNull('serviceBundle', accountInfo.serviceBundle?.toJson());
    }
    return data;
  }

  /// 处理native获取账号信息
  Future<Map?> _handleGetAccountInfo(dynamic arguments) {
    var accountInfo = meetingKitBridge.accountService.getAccountInfo();
    Callback _callback;
    Map? data = convertAccountInfo(accountInfo);
    _callback = Callback.success('getAccountInfo', data: data);
    return _callback.result;
  }

  Future<Map?> _handleLoginByToken(dynamic arguments) {
    assert(arguments is Map);
    final userUuid = arguments['userUuid'] as String? ?? '';
    final token = arguments['token'] as String? ?? '';
    return meetingKitBridge.accountService
        .loginByToken(userUuid, token)
        .then((value) {
      Map? data = convertAccountInfo(value.data);
      return Callback.wrap('loginByToken', value.code,
              msg: value.msg, data: data)
          .result;
    });
  }

  Future<Map?> _handleLoginByPassword(dynamic arguments) {
    assert(arguments is Map);
    final userUuid = arguments['userUuid'] as String? ?? '';
    final password = arguments['password'] as String? ?? '';
    return meetingKitBridge.accountService
        .loginByPassword(userUuid, password)
        .then((value) {
      Map? data = convertAccountInfo(value.data);
      return Callback.wrap('loginByPassword', value.code,
              msg: value.msg, data: data)
          .result;
    });
  }

  Future<Map?> _handleLoginByPhoneNumber(dynamic arguments) {
    assert(arguments is Map);
    final mobile = arguments['phoneNumber'] as String? ?? '';
    final password = arguments['password'] as String? ?? '';
    return meetingKitBridge.accountService
        .loginByPhoneNumber(mobile, password)
        .then((value) {
      Map? data = convertAccountInfo(value.data);
      return Callback.wrap('loginByPhoneNumber', value.code,
              msg: value.msg, data: data)
          .result;
    });
  }

  Future<Map?> _handleLoginByEmail(dynamic arguments) {
    assert(arguments is Map);
    final email = arguments['email'] as String? ?? '';
    final password = arguments['password'] as String? ?? '';
    return meetingKitBridge.accountService
        .loginByEmail(email, password)
        .then((value) {
      Map? data = convertAccountInfo(value.data);
      return Callback.wrap('loginByEmail', value.code,
              msg: value.msg, data: data)
          .result;
    });
  }

  Future<Map?> _handleLoginBySmsCode(dynamic arguments) {
    assert(arguments is Map);
    final mobile = arguments['phoneNumber'] as String? ?? '';
    final code = arguments['smsCode'] as String? ?? '';
    return meetingKitBridge.accountService
        .loginBySmsCode(mobile, code)
        .then((value) {
      Map? data = convertAccountInfo(value.data);
      return Callback.wrap('loginBySmsCode', value.code,
              msg: value.msg, data: data)
          .result;
    });
  }

  Future<Map?> _handleTryAutoLogin(dynamic arguments) {
    return meetingKitBridge.accountService.tryAutoLogin().then((value) {
      Map? data = convertAccountInfo(value.data);
      return Callback.wrap('tryAutoLogin', value.code,
              msg: value.msg, data: data)
          .result;
    });
  }

  Future<Map?> _handleGenerateSSOLoginWebURL(dynamic arguments) {
    return meetingKitBridge.accountService
        .generateSSOLoginWebURL()
        .then((value) {
      return Callback.wrap('generateSSOLoginWebURL', value.code,
              msg: value.msg, data: value.data)
          .result;
    });
  }

  Future<Map?> _handleLoginBySSOUri(dynamic arguments) {
    final ssoUri = arguments['ssoUri'] as String? ?? '';
    return meetingKitBridge.accountService.loginBySSOUri(ssoUri).then((value) {
      Map? data = convertAccountInfo(value.data);
      return Callback.wrap('loginBySSOUri', value.code,
              msg: value.msg, data: data)
          .result;
    });
  }

  Future<Map?> _handleLogout(dynamic arguments) {
    return meetingKitBridge.accountService.logout().then((value) {
      return Callback.wrap('logout', value.code, msg: value.msg, data: null)
          .result;
    });
  }

  Future<Map?> _handleRequestSmsCodeForLogin(dynamic arguments) {
    assert(arguments is Map);
    final phoneNumber = arguments['phoneNumber'] as String? ?? '';
    return meetingKitBridge.accountService
        .requestSmsCodeForLogin(phoneNumber)
        .then((value) {
      return Callback.wrap('requestSmsCodeForLogin', value.code,
              msg: value.msg, data: null)
          .result;
    });
  }

  Future<Map?> _handleResetPassword(dynamic arguments) {
    assert(arguments is Map);
    final userUuid = arguments['userUuid'] as String? ?? '';
    final newPassword = arguments['newPassword'] as String? ?? '';
    final oldPassword = arguments['oldPassword'] as String? ?? '';
    return meetingKitBridge.accountService
        .resetPassword(userUuid, newPassword, oldPassword)
        .then((value) {
      return Callback.wrap('resetPassword', value.code,
              msg: value.msg, data: null)
          .result;
    });
  }

  Future<Map?> _handleUpdateAvatar(dynamic arguments) {
    return meetingKitBridge.accountService
        .updateAvatar(arguments as String? ?? '')
        .then((value) {
      return Callback.wrap('updateAvatar', value.code,
              msg: value.msg, data: null)
          .result;
    });
  }

  Future<Map?> _handleUpdateNickname(dynamic arguments) {
    return meetingKitBridge.accountService
        .updateNickname(arguments as String? ?? '')
        .then((value) {
      return Callback.wrap('updateNickname', value.code,
              msg: value.msg, data: null)
          .result;
    });
  }

  @override
  void onKickOut() {
    meetingKitBridge.channel.invokeMethod('$name.onKickOut');
  }

  @override
  void onAuthInfoExpired() {
    meetingKitBridge.channel.invokeMethod('$name.onAuthInfoExpired');
  }

  @override
  void onReconnected() {
    meetingKitBridge.channel.invokeMethod('$name.onReconnected');
  }

  @override
  void onAccountInfoUpdated(NEAccountInfo? accountInfo) {
    meetingKitBridge.channel.invokeMethod(
        '$name.onAccountInfoUpdated', convertAccountInfo(accountInfo));
  }
}
