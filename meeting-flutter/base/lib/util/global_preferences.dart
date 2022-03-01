// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/sp_util.dart';

class GlobalPreferences extends Preferences {
  static const String keyLoginInfo = "loginInfo";
  static const String keyDeviceId = "deviceId";
  static const String keyAnonyNick = "anonyNick";
  static const String keyAnonyCameraOpen = "anonyCameraOpen";
  static const String keyAnonyMicrophoneOpen = "anonyMicrophoneOpen";
  static const String keyMeetingDebug = "meetingDebug";
  static const String keyNERtcLogLevel = "nertcLogLevel";
  static const String keyUserProtocolPrivacy = "userProtocolPrivacy";
  static const String keySecurityNotice = "securityNotice";
  static const String keyIsShowSecurityNotice = "isShowSecurityNotice";

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

  Future<void> setAnonyNick(String anonyNick) async{
    setSp(keyAnonyNick, anonyNick);
  }

  Future<bool?> get anonyCameraOpen async {
    return getBoolSp(keyAnonyCameraOpen);
  }

  Future<void> setAnonyCameraOpen(bool open) async{
    setBoolSp(keyAnonyCameraOpen, open);
  }

  Future<bool?> get anonyMicrophoneOpen async {
    return getBoolSp(keyAnonyMicrophoneOpen);
  }

  Future<void> setAnonyMicrophoneOpen(bool open) async{
    setBoolSp(keyAnonyMicrophoneOpen, open);
  }

  Future<bool?> get meetingDebug async {
    return getBoolSp(keyMeetingDebug);
  }

  Future<void> setMeetingDebug(bool meetingDebug) async{
    setBoolSp(keyMeetingDebug, meetingDebug);
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

  Future<void> setUserProtocolAndPrivacy(bool isShow) async{
    setBoolSp(keyUserProtocolPrivacy, isShow);
  }


  Future<String?> get securityNotice async {
    return getSp(keySecurityNotice);
  }

  Future<void> setSecurityNotice(String notice) async {
    setSp(keySecurityNotice, notice);
  }

  // Future<bool?> get isShowSecurityNotice async {
  //   return getBoolSp(keyIsShowSecurityNotice);
  // }
  //
  // Future<void> setIsShowSecurityNotice(bool isShow) async {
  //   setBoolSp(keyIsShowSecurityNotice, isShow);
  // }
}
