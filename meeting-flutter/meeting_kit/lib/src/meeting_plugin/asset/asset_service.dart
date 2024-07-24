// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_plugin;

class NEAssetService extends _Service {
  @override
  String _getModule() {
    return "NEAssetService";
  }

  NEAssetService(MethodChannel _methodChannel, Map<String, _Handler> handlerMap)
      : super(_methodChannel, handlerMap);

  /// current key == meeting
  Future<String?> loadAssetAsString(String fileName) async {
    Map map = buildArguments(arg: {'fileName': fileName});
    return await _methodChannel.invokeMethod('loadAssetAsString', map);
  }

  @override
  Future<dynamic> _handlerMethod(
      String method, int code, Map arg, dynamic callback) {
    return Future<dynamic>.value();
  }
}
