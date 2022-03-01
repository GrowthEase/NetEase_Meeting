// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_plugin;

class NENotificationService extends _Service {
  @override
  String _getModule() {
    return "NENotificationService";
  }

  NENotificationService(MethodChannel _methodChannel, Map<String, _Handler> handlerMap)
      : super(_methodChannel, handlerMap);

  ///start foreground service
  Future<void> startForegroundService(NEForegroundServiceConfig? config) async {
    Map map = buildArguments();
    map['config'] = config?._toMap();
    return await _methodChannel.invokeMethod('startForegroundService', map);
  }

  Future<void> stopForegroundService() async {
    return await _methodChannel.invokeMethod('stopForegroundService', buildArguments());
  }

  @override
  Future<dynamic> _handlerMethod(String method, int code, Map arg, dynamic callback) {
    return Future<dynamic>.value();
  }
}
