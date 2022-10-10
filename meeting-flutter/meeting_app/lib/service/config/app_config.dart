// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/manager/device_manager.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/base/util/timeutil.dart';
import 'package:device_info_plus/device_info_plus.dart';
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

  static Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId
    };
  }

  static Map<String, dynamic> readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}
