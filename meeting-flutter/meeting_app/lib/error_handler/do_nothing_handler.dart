// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:nemeeting/error_handler/error_handler.dart';

class DoNothingErrorHandler extends ErrorHandler {
  @override
  Future<void> recordError(exception, StackTrace? stack, {bool fatal = false}) {
    return Future.value(null);
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails,
      {bool fatal = false}) {
    return Future.value(null);
  }
}
