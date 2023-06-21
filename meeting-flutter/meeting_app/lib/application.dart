// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nemeeting/constants.dart';
import 'package:nemeeting/service/config/app_config.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:netease_common/netease_common.dart';

class Application {
  static late BuildContext context;

  static Completer<bool>? _initializedCompleter;

  static Alogger _logger = Alogger.normal('Application', Constants.moduleName);

  static Future<bool> ensureInitialized() async {
    if (_initializedCompleter == null) {
      _initializedCompleter = Completer<bool>();
      _initializeInner();
    }
    return _initializedCompleter!.future;
  }

  static void _initializeInner() async {
    await NERoomLogService().init();
    final config = AppConfig();
    await config.init();
    _logger.i(
        'App initialized: env=${config.env}, vName=${config.versionName}, vCode=${config.versionCode}');
    _initializedCompleter!.complete(true);
  }
}
