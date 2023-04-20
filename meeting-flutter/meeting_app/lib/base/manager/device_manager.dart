// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import '../util/global_preferences.dart';
import '../util/text_util.dart';
import '../util/uuid.dart';
import '../client_type.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceManager {
  factory DeviceManager() {
    _instance ??= DeviceManager._internal();
    return _instance!;
  }

  static DeviceManager? _instance;
  static late String _deviceId;
  static int _clientType = 0;
  static late String _platform;
  static late String _manufacturer;
  static late String _model;
  static late String _osVer;

  DeviceManager._internal();

  Future<void> init() async {
    var plat = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      _platform = 'Android';
      var androidInfo = await plat.androidInfo;
      _manufacturer = androidInfo.manufacturer;
      _model = androidInfo.model;
      _osVer = androidInfo.version.release;
    } else if (Platform.isIOS) {
      _platform = 'iOS';
      var iosDeviceInfo = await plat.iosInfo;
      _manufacturer = 'Apple';
      _model = iosDeviceInfo.name ?? 'unknown';
      _osVer = iosDeviceInfo.systemVersion ?? 'unknown';
    }
    String? deviceId = await GlobalPreferences().deviceId;
    if (TextUtil.isEmpty(deviceId)) {
      _deviceId = UUID().genUUID();
      GlobalPreferences().setDeviceId(_deviceId);
    } else {
      _deviceId = deviceId!;
    }

    if (Platform.isAndroid) {
      _clientType = ClientType.aos;
    } else if (Platform.isIOS) {
      _clientType = ClientType.ios;
    } else if (Platform.isWindows || Platform.isMacOS) {
      _clientType = ClientType.pc;
    }
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
    return _manufacturer;
  }

  String get model {
    return _model;
  }

  String get osVer {
    return _osVer;
  }
}
