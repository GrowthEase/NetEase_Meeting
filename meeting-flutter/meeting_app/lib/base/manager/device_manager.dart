// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:nemeeting/constants.dart';

import '../util/global_preferences.dart';
import '../util/text_util.dart';
import '../util/uuid.dart';
import '../client_type.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:netease_common/netease_common.dart';

class DeviceManager {
  factory DeviceManager() {
    _instance ??= DeviceManager._internal();
    return _instance!;
  }

  static const _unknown = 'unknown';

  static DeviceManager? _instance;
  static late String _deviceId;
  static int _clientType = 0;
  static late String _platform;

  static String? _manufacturer;
  static String? _model;
  static String? _osVer;

  DeviceManager._internal();

  Future<void> init() async {
    String? deviceId = await GlobalPreferences().deviceId;
    if (TextUtil.isEmpty(deviceId)) {
      _deviceId = UUID().genUUID();
      GlobalPreferences().setDeviceId(_deviceId);
    } else {
      _deviceId = deviceId!;
    }

    if (Platform.isAndroid) {
      _platform = 'Android';
      _clientType = ClientType.aos;
    } else if (Platform.isIOS) {
      _platform = 'iOS';
      _clientType = ClientType.ios;
    } else if (Platform.isWindows || Platform.isMacOS) {
      _platform = 'PC';
      _clientType = ClientType.pc;
    }

    _initDeviceInfo();
  }

  String get deviceId {
    return _deviceId;
  }

  int get clientType {
    return _clientType;
  }

  String get platform {
    return _platform;
  }

  String get manufacturer {
    return _manufacturer ?? _unknown;
  }

  String get model {
    return _model ?? _unknown;
  }

  String get osVer {
    return _osVer ?? _unknown;
  }

  static Future<void> _initDeviceInfo() async {
    await GlobalPreferences().ensurePrivacyAgree();
    final plat = DeviceInfoPlugin();
    Map? deviceInfoData;
    if (Platform.isAndroid) {
      var androidInfo = await plat.androidInfo;
      _manufacturer = androidInfo.manufacturer;
      _model = androidInfo.model;
      _osVer = androidInfo.version.release;
      deviceInfoData = _readAndroidBuildData(androidInfo);
    } else if (Platform.isIOS) {
      var iosDeviceInfo = await plat.iosInfo;
      _manufacturer = 'Apple';
      _model = iosDeviceInfo.name;
      _osVer = iosDeviceInfo.systemVersion;
      deviceInfoData = _readIosDeviceInfo(iosDeviceInfo);
    }
    if (deviceInfoData != null) {
      Alog.i(
        tag: 'DeviceManager',
        moduleName: Constants.moduleName,
        content: 'deviceInfoData: $deviceInfoData',
      );
    }
  }

  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
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
    };
  }

  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
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
