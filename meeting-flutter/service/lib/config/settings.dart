// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'package:base/util/textutil.dart';
import 'package:service/util/user_preferences.dart';

/// 应用设置
class Settings {
  static final Settings _singleton = Settings._internal();

  factory Settings() => _singleton;

  // late LocalSettings _localSettings;

  late ServerSettings _serverSettings;

  Settings._internal();

  Future<void> init() async {
    // _localSettings = await LocalSettings.load();
    _serverSettings = await ServerSettings.load();
  }

  // Future<LocalSettings> get localSettings async {
  //   await init();
  //   return _localSettings;
  // }

  Future<ServerSettings> get serviceSettings async {
    await init();
    return _serverSettings;
  }

  // void updateValue(String key, dynamic value) {
  //   switch (key) {
  //     case LocalSettings.keyUseMeetId:
  //       _localSettings.useMeetId = value as bool;
  //       break;
  //     case LocalSettings.keyCameraOpen:
  //       _localSettings.cameraOpen = value as bool;
  //       break;
  //     case LocalSettings.keyMicroOpen:
  //       _localSettings.microphoneOpen = value as bool;
  //       break;
  //     case LocalSettings.keyShowMeetTimeOpen:
  //       _localSettings.showMeetingTime = value as bool;
  //       break;
  //   }
  //   UserPreferences().setLocalSettings(jsonEncode(_localSettings));
  // }
}

/// 本地设置
// class LocalSettings {
//   static const String keyUseMeetId = 'useMeetId';
//   static const String keyCameraOpen = 'cameraOpen';
//   static const String keyMicroOpen = 'microphoneOpen';
//   static const String keyShowMeetTimeOpen = 'showMeetingTime';
//
//   /// 是否使用个人会议Id
//   bool useMeetId = false;
//
//   /// 默认摄像头状态
//   bool cameraOpen = true;
//
//   /// 默认麦克风状态
//   bool microphoneOpen = true;
//
//   /// 显示会议持续时间
//   bool showMeetingTime = false;
//
//   Map toJson() => {
//         keyUseMeetId: useMeetId,
//         keyCameraOpen: cameraOpen,
//         keyMicroOpen: microphoneOpen,
//         keyShowMeetTimeOpen: showMeetingTime,
//       };
//
//   /// load from sp
//   static Future<LocalSettings> load() async {
//     var localSettings = await UserPreferences().localSettings;
//     return fromJson(localSettings);
//   }
//
//   static LocalSettings fromJson(String? localSettings) {
//     if (TextUtil.isEmpty(localSettings)) {
//       return LocalSettings(); // default value
//     }
//     return fromMap(json.decode(localSettings!) as Map);
//   }
//
//   static LocalSettings fromMap(Map map) {
//     var settings = LocalSettings();
//     settings.useMeetId = (map[keyUseMeetId] ?? false) as bool;
//     settings.cameraOpen = (map[keyCameraOpen] ?? true) as bool;
//     settings.microphoneOpen = (map[keyMicroOpen] ?? true) as bool;
//     settings.showMeetingTime = (map[keyShowMeetTimeOpen] ?? true) as bool;
//     return settings;
//   }
// }

/// 服务器设置
class ServerSettings {
  /// load from sp
  static Future<ServerSettings> load() async {
    var serverSettings = await UserPreferences().serverSettings;
    return fromJson(serverSettings);
  }

  static ServerSettings fromJson(String? serverSettings) {
    if (TextUtil.isEmpty(serverSettings)) {
      return ServerSettings(); // default value
    }
    return fromMap(json.decode(serverSettings!) as Map);
  }

  static ServerSettings fromMap(Map map) {
    var settings = ServerSettings();
    return settings;
  }
}
