// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import '../module_name.dart';
import 'app_config.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

class Servers {
  final connectTimeout = 30000;
  final receiveTimeout = 15000;

  factory Servers() => _instance;

  static final Servers _instance = Servers._();

  Servers._() {
    Alog.d(
        moduleName: moduleName, tag: 'Servers', content: 'baseUrl = $baseUrl');
  }

  String get baseUrl {
    return AppConfig().serverUrl;
  }

  String? get privacy {
    return AppConfig().privacyUrl;
  }

  String? get userProtocol {
    return AppConfig().userProtocolUrl;
  }
}

final servers = Servers();
