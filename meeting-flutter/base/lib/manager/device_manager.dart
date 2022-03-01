// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:base/util/global_preferences.dart';
import 'package:base/util/textutil.dart';
import 'package:base/util/uuid.dart';
import 'package:base/client_type.dart';

class DeviceManager {
  factory DeviceManager() {
    _instance ??= DeviceManager._internal();
    return _instance!;
  }

  static DeviceManager? _instance;
  static late String _deviceId;
  static int _clientType = 0;

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
}
