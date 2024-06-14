// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_common/netease_common.dart';

class Constants {
  static const moduleName = 'meeting_app';
}

class AppLoggerFactory {
  static Alogger get(String tag) {
    return Alogger.normal(tag, Constants.moduleName);
  }
}

mixin class AppLogger {
  Alogger? _logger;

  Alogger get logger {
    _logger ??= Alogger.normal(loggerTag, Constants.moduleName);
    return _logger!;
  }

  String get loggerTag => runtimeType.toString();
}
