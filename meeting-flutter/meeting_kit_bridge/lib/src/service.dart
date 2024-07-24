// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:fluttermodule/src/callback.dart';

abstract class Service {
  String get name;

  Future<dynamic> handleCall(String method, dynamic arguments) {
    return Callback.wrap(method, -1, msg: '$method not implemented').result;
  }
}
