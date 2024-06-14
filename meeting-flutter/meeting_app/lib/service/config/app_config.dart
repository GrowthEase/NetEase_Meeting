// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:nemeeting/base/manager/device_manager.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:netease_meeting_ui/meeting_plugin.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:netease_common/netease_common.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  static const String TAG = 'AppConfig';
  factory AppConfig() => _instance ??= AppConfig._internal();
  static AppConfig? _instance;

  AppConfig._internal();

  String? _corpCode;

  String? _appKey;

  String? _serverUrl;

  /// 会议解决方案如何设置企业代码链接
  String? _corpCodeIntroductionUrl;
  String? _privacyUrl;
  String? _userProtocolUrl;

  late String versionName;

  late String versionCode;

  static var _debugMode = false;

  String? get corpCode => _corpCode;
  String? get appKey => _appKey;
  String get serverUrl => _serverUrl ?? '';
  String get privacyUrl => _privacyUrl ?? '';
  String get userProtocolUrl => _userProtocolUrl ?? '';
  String get corpCodeIntroductionUrl =>
      _corpCodeIntroductionUrl ??
      'https://doc.yunxin.163.com/meeting/concept/DI1MDY1ODg?platform=console';
  String get deleteAccountWebServiceUrl => '';
  String get registryUrl => '';

  static bool get isInDebugMode {
    return _debugMode;
  }

  Future init() async {
    _debugMode = await GlobalPreferences().meetingDebug == true;
    await DeviceManager().init();
    await loadPackageInfo();

    NEAppConfig config = await loadConfig();
    print("config = ${config.toJson()}");
    _appKey = config.appKey;
    _serverUrl = config.meetingServerConfig?.meetingServer;
    _userProtocolUrl = config.meetingModuleConfig?.about?.userProtocolUrl;
    _privacyUrl = config.meetingModuleConfig?.about?.privacyUrl;
    return Future.value();
  }

  Future<void> loadPackageInfo() async {
    var info = await PackageInfo.fromPlatform();
    versionCode = info.buildNumber;
    versionName = info.version;
  }

  Future<NEAppConfig> loadConfig() async {
    NEAppConfig config = NEAppConfig();
    try {
      final serverConfigJsonString = await NEMeetingPlugin()
          .getAssetService()
          .loadAssetAsString('xkit_server.config');
      if (serverConfigJsonString?.isEmpty ?? true) {
        Alogger.normal(TAG,
            '`useAssetServerConfig` is true, but `xkit_server.config` asset file is not exists or empty');
      } else {
        final serverConfigJson =
            jsonDecode(serverConfigJsonString as String) as Map;
        config = NEAppConfig.fromJson(serverConfigJson);
      }
    } catch (e, s) {
      Alogger.normal(TAG, 'parse server config error: $e\n$s');
    }
    return config;
  }
}

class NEAppConfig {
  static const _meetingServerConfigKey = 'meeting';
  static const _meetingModuleConfigKey = 'module';
  static const _appKey = 'appkey';
  static const _buildTime = 'buildTime';
  String? appKey;
  String? corpCode;
  String? buildTime;
  late String serverUrl;
  NEAppModuleConfig? meetingModuleConfig;
  NEMeetingServerConfig? meetingServerConfig;

  NEAppConfig();

  NEAppConfig.fromJson(Map json) {
    appKey = json[_appKey] as String?;
    buildTime = json[_buildTime] as String?;
    if (json.containsKey(_meetingServerConfigKey)) {
      meetingServerConfig =
          NEMeetingServerConfig.fromJson(json[_meetingServerConfigKey]);
    }

    if (json.containsKey(_meetingModuleConfigKey)) {
      meetingModuleConfig =
          NEAppModuleConfig.fromJson(json[_meetingModuleConfigKey]);
    }
  }

  Map toJson() => {
        if (meetingServerConfig != null)
          _meetingServerConfigKey: meetingServerConfig!.toJson(),
      };
}

class NEAppModuleConfig {
  NEAppAbout? about;

  NEAppModuleConfig();

  factory NEAppModuleConfig.fromJson(Map json) {
    return NEAppModuleConfig()..about = NEAppAbout.fromJson(json['about']);
  }
}

class NEAppAbout {
  String? privacyUrl;

  String? userProtocolUrl;

  NEAppAbout();

  factory NEAppAbout.fromJson(Map json) {
    return NEAppAbout()
      ..privacyUrl = json['privacyUrl'] as String?
      ..userProtocolUrl = json['userProtocolUrl'] as String?;
  }
}
