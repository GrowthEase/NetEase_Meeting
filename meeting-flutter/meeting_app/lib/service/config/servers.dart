// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import '../module_name.dart';
import 'app_config.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

class Servers {
  static const _serverUrl = 'https://roomkit.netease.im/';

  static const privacy =
      'https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml';

  static const userProtocol =
      'https://netease.im/meeting/clauses?serviceType=0';
  static const deleteAccountWebServiceUrl =
      'https://meeting.163.com/invite/logout';
  static const appRegistryDetailUrl =
      'https://beian.miit.gov.cn/?app_lang=zh-cn#/Integrated/index';

  final connectTimeout = 30000;
  final receiveTimeout = 15000;

  factory Servers() => _instance;

  static final Servers _instance = Servers._();

  Servers._();

  String get baseUrl {
    var env = AppConfig().env;
    Alog.d(
        moduleName: moduleName, tag: 'Servers', content: 'baseUrl env = $env');
    return _serverUrl;
  }
}

final servers = Servers();
