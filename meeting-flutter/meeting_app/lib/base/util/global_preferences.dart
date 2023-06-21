// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import '../util/sp_util.dart';

class GlobalPreferences extends Preferences {
  static const String keyLoginInfo = "loginInfo";
  static const String keyDeviceId = "deviceId";
  static const String keyAnonyNick = "anonyNick";
  static const String keyAnonyCameraOpen = "anonyCameraOpen";
  static const String keyAnonyMicrophoneOpen = "anonyMicrophoneOpen";
  static const String keyMeetingDebug = "meetingDebug";
  static const String keyMeetingEnv = "meetingEnv";
  static const String keyNERtcLogLevel = "nertcLogLevel";
  static const String keyUserProtocolPrivacy = "userProtocolPrivacy";
  static const String keySecurityNotice = "securityNotice";
  static const String keyIsShowSecurityNotice = "isShowSecurityNotice";
  static const String keyMeetingInfo = "meetingInfo";
  static const String keyEnablePasswordLogin = 'enablePwdLogin';
  static const String keyPrivacyDialogShowed = 'privacyDialogShowed';
  static const String keyMeetingEvaluation = 'meetingEvaluation';

  GlobalPreferences._internal();

  static GlobalPreferences _singleton = GlobalPreferences._internal();

  factory GlobalPreferences() => _singleton;

  Future<void> setDeviceId(String deviceId) async {
    setSp(keyDeviceId, deviceId);
  }

  Future<String?> get deviceId async {
    return getSp(keyDeviceId);
  }

  /// save
  Future<void> setLoginInfo(String value) async {
    setSp(keyLoginInfo, value);
  }

  Future<String?> get loginInfo async {
    return getSp(keyLoginInfo);
  }

  Future<String?> get anonyNick async {
    return getSp(keyAnonyNick);
  }

  Future<void> setAnonyNick(String anonyNick) async {
    setSp(keyAnonyNick, anonyNick);
  }

  Future<bool?> get anonyCameraOpen async {
    return getBoolSp(keyAnonyCameraOpen);
  }

  Future<void> setAnonyCameraOpen(bool open) async {
    setBoolSp(keyAnonyCameraOpen, open);
  }

  Future<bool?> get anonyMicrophoneOpen async {
    return getBoolSp(keyAnonyMicrophoneOpen);
  }

  Future<void> setAnonyMicrophoneOpen(bool open) async {
    setBoolSp(keyAnonyMicrophoneOpen, open);
  }

  Future<bool?> get meetingDebug async {
    return getBoolSp(keyMeetingDebug);
  }

  Future<void> setMeetingDebug(bool meetingDebug) async {
    setBoolSp(keyMeetingDebug, meetingDebug);
  }

  final _privacyAgreeCompleter = Completer();
  Future ensurePrivacyAgree() async {
    if (!_privacyAgreeCompleter.isCompleted) {
      hasPrivacyDialogShowed.then((value) {
        if (value && !_privacyAgreeCompleter.isCompleted) {
          _privacyAgreeCompleter.complete();
        }
      });
    }
    return _privacyAgreeCompleter.future;
  }

  Future<bool> get hasPrivacyDialogShowed async {
    return await getBoolSp(keyPrivacyDialogShowed) ?? false;
  }

  Future<bool> setPrivacyDialogShowed(bool enabled) async {
    if (enabled && !_privacyAgreeCompleter.isCompleted) {
      _privacyAgreeCompleter.complete();
    }
    return setBoolSp(keyPrivacyDialogShowed, enabled);
  }

  Future<bool> get isPasswordLoginEnabled async {
    return await getBoolSp(keyEnablePasswordLogin) ?? false;
  }

  Future<bool> setPasswordLoginEnabled(bool enabled) async {
    return setBoolSp(keyEnablePasswordLogin, enabled);
  }

  Future<String?> get meetingEnv async {
    return getSp(keyMeetingEnv);
  }

  Future<bool> setMeetingEnv(String? env) async {
    if (env == null || env.isEmpty) {
      return remove(keyMeetingEnv);
    } else {
      return setSp(keyMeetingEnv, env);
    }
  }

  Future<String?> get nertcLogLevel async {
    return getSp(keyNERtcLogLevel);
  }

  Future<void> setNertcLogLevel(String level) async {
    setSp(keyNERtcLogLevel, level);
  }

  Future<bool?> get userProtocolAndPrivacy async {
    return getBoolSp(keyUserProtocolPrivacy);
  }

  Future<void> setUserProtocolAndPrivacy(bool isShow) async {
    setBoolSp(keyUserProtocolPrivacy, isShow);
  }

  Future<String?> get securityNotice async {
    return getSp(keySecurityNotice);
  }

  Future<void> setSecurityNotice(String notice) async {
    setSp(keySecurityNotice, notice);
  }

  Future<void> setMeetingInfo(String value) async {
    setSp(keyMeetingInfo, value);
  }

  Future<String?> get meetingInfo async {
    return getSp(keyMeetingInfo);
  }

  Future<void> setMeetingEvaluation(String value) async {
    setSp(keyMeetingEvaluation, value);
  }

  Future<String?> get meetingEvaluation async {
    return getSp(keyMeetingEvaluation);
  }
  // Future<bool?> get isShowSecurityNotice async {
  //   return getBoolSp(keyIsShowSecurityNotice);
  // }
  //
  // Future<void> setIsShowSecurityNotice(bool isShow) async {
  //   setBoolSp(keyIsShowSecurityNotice, isShow);
  // }
}
