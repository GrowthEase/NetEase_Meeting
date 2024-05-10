// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

abstract class BaseApi<T> {
  String path();

  Object? data();

  T parseResult(dynamic data) {
    return result(data as Map);
  }

  T result(Map map) {
    throw UnimplementedError();
  }

  Map<String, dynamic>? header() => null;

  Future<NEResult<T>> execute();

  bool checkLoginState() => true;

  bool enableLog() => true;
}
