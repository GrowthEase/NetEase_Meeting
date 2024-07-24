// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:fluttermodule/src/module_name.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_kit/meeting_kit.dart';

typedef Interceptor = bool Function(int code, String? msg, dynamic data);

class Callback {
  static const _tag = 'Callback';

  final String key;
  Interceptor? interceptor;

  int? _code;
  String? _msg;
  dynamic _data;

  Callback(this.key, [this.interceptor]);

  Callback.success(String key, {String? msg, dynamic data})
      : this.wrap(key, 0, msg: msg, data: data);

  Callback.wrap(this.key, int code, {String? msg, dynamic data}) {
    _code = convertCode(code);
    _msg = msg ?? (_code == 0 ? 'SUCCESS' : 'FAIL');
    _data = data;
  }

  final Completer<Map> _completer = Completer();

  Future<Map> get result {
    if (_code != null) {
      Alog.i(
          tag: _tag,
          moduleName: moduleName,
          content: '$key callback with: $_code $_msg');
      return Future.value(
          {'key': key, 'code': _code, 'msg': _msg, 'data': _data});
    }
    return _completer.future;
  }

  static int convertCode(int code) =>
      code == NEMeetingErrorCode.success || code == 200 ? 0 : code;
}
