// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of feedback;

const _moduleName = 'feedback';

mixin _AloggerMixin {
  Alogger? _apiLogger, _commonLogger;

  Alogger get apiLogger {
    _apiLogger ??= Alogger.api(logTag, _moduleName);
    return _apiLogger!;
  }

  Alogger get commonLogger {
    _commonLogger ??= Alogger.normal(logTag, _moduleName);
    return _commonLogger!;
  }

  String get logTag {
    return runtimeType.toString();
  }
}
