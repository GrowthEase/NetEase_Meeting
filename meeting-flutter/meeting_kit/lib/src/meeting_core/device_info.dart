// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class DeviceInfo {
  static late String _model;
  static late String _osVer;
  static int sdkInt = 0;
  static late String _platform;
  static late String _manufacturer;
  static int _clientType = 0;
  static late String _deviceId;
  static bool _initialized = false;

  DeviceInfo._();

  static Future<void> initialize() async {
    if (!_initialized) {
      var plat = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        _platform = 'Android';
        var androidInfo = await plat.androidInfo;
        _manufacturer = androidInfo.manufacturer;
        _clientType = ClientType.android;
        _model = androidInfo.model;
        _osVer = androidInfo.version.release;
        sdkInt = androidInfo.version.sdkInt;
      } else if (Platform.isIOS) {
        _platform = 'iOS';
        var iosDeviceInfo = await plat.iosInfo;
        _manufacturer = 'Apple';
        _clientType = ClientType.iOS;
        _model = iosDeviceInfo.name;
        _osVer = iosDeviceInfo.systemVersion;
      } else if (Platform.isWindows) {
        _clientType = ClientType.windows;
      } else if (Platform.isMacOS) {
        _clientType = ClientType.macOS;
      }
      _deviceId = await NERoomKit.instance.deviceId;
      _initialized = true;
    }
  }

  static int get clientType => _clientType;

  static String get platform => _platform;

  static String get model => _model;

  static String get osVer => _osVer;

  static String get manufacturer => _manufacturer;

  static String get deviceId => _deviceId;
}
