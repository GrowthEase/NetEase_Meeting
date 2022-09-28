// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/response/result.dart';

abstract class BaseProto<T> {
  String get method => 'POST';

  String path();

  Map data();

  T result(Map map);

  Map<String, dynamic>? header() {
    return null;
  }

  Future<Result<T>> execute();

  bool checkLoginState() {
    return true;
  }
}
