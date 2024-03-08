// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

class NEPadCheckDetector extends _Service {
  bool? _isPad;
  NEPadCheckDetector(
      MethodChannel methodChannel, Map<String, _Handler> handlerMap)
      : super(methodChannel, handlerMap);

  @override
  String _getModule() {
    return 'NEPadCheckDetector';
  }

  @override
  Future<dynamic> _handlerMethod(
      String method, int code, Map arg, dynamic callback) {
    return Future<dynamic>.value();
  }

  Future<bool> isPad() async {
    _isPad ??= await _methodChannel.invokeMethod('isPad', buildArguments());
    return _isPad!;
  }
}
