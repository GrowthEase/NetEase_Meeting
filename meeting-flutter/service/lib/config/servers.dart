// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import '../module_name.dart';
import 'app_config.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

class Servers {

  static const onlineUrl = 'https://meeting-api.netease.im/';

  static const oldOnlineUrl = 'https://meeting.netease.im/';

  final privacy = 'https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml';

  final userProtocol = 'https://netease.im/meeting/clauses?serviceType=0';

  final connectTimeout = 30000;
  final receiveTimeout = 15000;

  String get baseUrl {
    var env = AppConfig().env;
    Alog.d(moduleName: moduleName, tag: 'Servers', content: 'env = $env');
    return onlineUrl;
  }

  /// 临时维护服务器双host兼容逻辑
  String get oldBaseUrl {
    var env = AppConfig().env;
    Alog.d(moduleName: moduleName, tag: 'Servers', content: 'env = $env');
    return oldOnlineUrl;
  }

  String get universalLink {
    return onlineUrl;
  }
}

var servers = Servers();
