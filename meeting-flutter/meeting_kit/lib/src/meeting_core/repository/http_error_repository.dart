// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

final class HttpError {
  final int code;
  final String? msg;
  final String? requestId;

  HttpError(
    this.code, {
    this.msg,
    this.requestId,
  });
}

class HttpErrorRepository with _AloggerMixin {
  HttpErrorRepository._();

  static final _instance = HttpErrorRepository._();

  factory HttpErrorRepository() => _instance;

  /// ignore: close_sinks
  final _errorController = StreamController<HttpError>.broadcast();

  Stream<HttpError> get onError => _errorController.stream;

  void reportResult<T>(NEResult<T> result) {
    reportError(result.code, msg: result.msg, requestId: result.requestId);
  }

  void reportError(
    int code, {
    String? msg,
    String? requestId,
  }) {
    if (code != 0) {
      commonLogger.e('on http error: $code, $msg, $requestId');
      _errorController.add(HttpError(code, msg: msg, requestId: requestId));
    }
  }
}
