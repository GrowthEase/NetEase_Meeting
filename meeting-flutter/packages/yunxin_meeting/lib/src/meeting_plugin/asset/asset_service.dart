// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_plugin;

class NEAssetService extends _Service {
  @override
  String _getModule() {
    return "NEAssetService";
  }

  NEAssetService(MethodChannel _methodChannel, Map<String, _Handler> handlerMap) : super(_methodChannel, handlerMap);

  /// current key == meeting
  Future<String?> loadCustomServer() async {
    Map map = buildArguments();
    return await _methodChannel.invokeMethod('loadCustomServer', map);
  }

  @override
  Future<dynamic> _handlerMethod(String method, int code, Map arg, dynamic callback) {
    return Future<dynamic>.value();
  }
}
