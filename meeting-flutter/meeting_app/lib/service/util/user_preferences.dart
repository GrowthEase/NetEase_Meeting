// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/util/sp_util.dart';
import 'package:nemeeting/service/profile/app_profile.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

class UserPreferences extends Preferences {
  static const String localSetting = 'localSetting';
  static const String serverSetting = 'serverSettings';
  static const String showShareUserVideo = 'showShareUserVideo';
  static const String transparentWB = 'transparentWB';
  static const String frontCameraMirror = 'frontCameraMirror';
  static const String audioDeviceSwitch = 'audioDeviceSwitch';

  UserPreferences._internal();

  static final UserPreferences _singleton = UserPreferences._internal();

  factory UserPreferences() => _singleton;

  Future<bool> getShowShareUserVideo() async {
    final value = await getBoolSp(_wrapperKey(showShareUserVideo));
    return value ?? true;
  }

  Future<void> setShowShareUserVideo(bool value) async {
    setBoolSp(_wrapperKey(showShareUserVideo), value);
  }

  Future<bool> isTransparentWhiteboardEnabled() async {
    final value = await getBoolSp(_wrapperKey(transparentWB));
    return value ?? false;
  }

  Future<void> setTransparentWhiteboardEnabled(bool value) async {
    setBoolSp(_wrapperKey(transparentWB), value);
  }

  void enableAudioDeviceSwitch(bool enable) {
    setBoolSp(_wrapperKey(audioDeviceSwitch), enable);
  }

  Future<bool> isAudioDeviceSwitchEnabled() async {
    return getBoolSp(_wrapperKey(audioDeviceSwitch))
        .then((value) => value ?? SDKConfig.current.isAudioDeviceSwitchEnabled);
  }

  Future<bool> isFrontCameraMirrorEnabled() async {
    final value = await getBoolSp(_wrapperKey(frontCameraMirror));
    return value ?? true;
  }

  Future<void> setFrontCameraMirrorEnabled(bool value) async {
    setBoolSp(_wrapperKey(frontCameraMirror), value);
  }

  /// save
  @override
  Future<bool> setSp(String key, String value) async {
    return super.setSp(_wrapperKey(key), value);
  }

  @override
  Future<String?> getSp(String key) async {
    return super.getSp(_wrapperKey(key));
  }

  Future<String?> get localSettings async {
    return getSp(localSetting);
  }

  Future<void> setLocalSettings(String setting) async {
    await setSp(localSetting, setting);
  }

  Future<String?> get serverSettings async {
    return getSp(serverSetting);
  }

  Future<void> setServerSettings(String setting) async {
    await setSp(serverSetting, setting);
  }

  String _wrapperKey(String key) {
    return '${AppProfile.accountId}_$key';
  }
}
