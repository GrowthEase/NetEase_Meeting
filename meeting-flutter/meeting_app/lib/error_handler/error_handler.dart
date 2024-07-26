// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:nemeeting/error_handler/do_nothing_handler.dart';

abstract class ErrorHandler {
  static ErrorHandler? _handler;

  ErrorHandler();

  factory ErrorHandler.instance() {
    _handler ??= DoNothingErrorHandler();
    return _handler!;
  }

  @mustCallSuper
  Future<void> install() async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) async {
      await recordFlutterError(details);
      originalOnError?.call(details);
    };
    var originalOnError2 = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack);
      return originalOnError2?.call(error, stack) ?? true;
    };
  }

  Future<void> recordError(dynamic exception, StackTrace? stack,
      {bool fatal = false});

  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails,
      {bool fatal = false});
}
