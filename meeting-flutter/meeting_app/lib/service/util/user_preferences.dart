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
  static const String audioDeviceSwitch = 'audioDeviceSwitch';
  static const String _keyMeetingInfo = "meetingInfo";

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

  void enableAudioDeviceSwitch(bool enable) {
    setBoolSp(_wrapperKey(audioDeviceSwitch), enable);
  }

  Future<bool> isAudioDeviceSwitchEnabled() async {
    return getBoolSp(_wrapperKey(audioDeviceSwitch))
        .then((value) => value ?? SDKConfig.current.isAudioDeviceSwitchEnabled);
  }

  Future<void> setMeetingInfo(String value) async {
    setSp(_keyMeetingInfo, value);
  }

  Future<String?> get meetingInfo async {
    return getSp(_keyMeetingInfo);
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
