// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/manager/device_manager.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/base/util/timeutil.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

class AppConfig {
  factory AppConfig() => _instance ??= AppConfig._internal();

  static AppConfig? _instance;

  AppConfig._internal();

  static const String online = 'ONLINE';
  late String _env;

  late String _appKey;

  late String versionName;
  late String versionCode;

  /// build time
  late String time;

  static var _debugMode = false;

  String get appKey {
    return _appKey;
  }

  String get env {
    return _env;
  }

  Future changeEnv(String? value) {
    return GlobalPreferences().setMeetingEnv(value);
  }

  bool get isPublicFlavor {
    return true;
  }

  static bool get isInDebugMode {
    return _debugMode;
  }

  Future init() async {
    var properties = <String, String>{};
    _debugMode = await GlobalPreferences().meetingDebug == true;
    var value = await rootBundle.loadString('assets/config.properties');
    var list = value.split('\n');
    list.forEach((element) {
      if (element.contains('=')) {
        var key = element.substring(0, element.indexOf('='));
        var value = element.substring(element.indexOf('=') + 1);
        properties[key] = value;
      }
    });
    parserProperties(properties);

    final overrideEnv = await GlobalPreferences().meetingEnv;
    if (overrideEnv != null) {
      _env = overrideEnv;
    }

    await DeviceManager().init();
    await loadPackageInfo();
    return Future.value();
  }

  void parserProperties(Map<String, String> properties) {
    _env = properties['ENV'] ?? online;
    _appKey = properties['appKey'] ?? '';
    time = properties['time'] ?? TimeUtil.getTimeFormatMillisecond();
  }

  Future<void> loadPackageInfo() async {
    var info = await PackageInfo.fromPlatform();
    versionCode = info.buildNumber;
    versionName = info.version;
  }
}
