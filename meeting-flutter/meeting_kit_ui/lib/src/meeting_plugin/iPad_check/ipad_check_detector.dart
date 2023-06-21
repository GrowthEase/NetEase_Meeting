// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

class NEIpadCheckDetector extends _Service {
  bool? _isIpad;
  NEIpadCheckDetector(
      MethodChannel methodChannel, Map<String, _Handler> handlerMap)
      : super(methodChannel, handlerMap);

  @override
  String _getModule() {
    return 'NEIPadCheckDetector';
  }

  @override
  Future<dynamic> _handlerMethod(
      String method, int code, Map arg, dynamic callback) {
    return Future<dynamic>.value();
  }

  Future<bool> isIpad() async {
    _isIpad ??= await _methodChannel.invokeMethod('isIPad', buildArguments());
    return _isIpad!;
  }
}
