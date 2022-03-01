// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

class NEMeetingPlugin {
  static NEMeetingPlugin? _instance;

  factory NEMeetingPlugin() {
    if (_instance == null) {
      final _channel = const MethodChannel('meeting_plugin');
      _instance = NEMeetingPlugin.private(_channel);
    }
    return _instance!;
  }

  final MethodChannel _methodChannel;

  final Map<String, _Handler> handlerMap = Map();

  NEMeetingPlugin.private(this._methodChannel) {
    _methodChannel.setMethodCallHandler(_handler);
  }

  static NENotificationService? _notificationService;

  static NEAssetService? _assetService;

  /// notification service
  NENotificationService getNotificationService() {
    return _notificationService ?? (_notificationService = NENotificationService(_methodChannel, handlerMap));
  }

  /// notification service
  NEAssetService getAssetService() {
    return _assetService ?? (_assetService = NEAssetService(_methodChannel, handlerMap));
  }

  /// native  --  dart
  Future<dynamic> _handler(MethodCall call) {
    final map = call.arguments as Map?;
    if (map != null) {
      final module = map['module']?.toString() ?? "";
      _Handler? handler = handlerMap[module];
      print("_handler method= " + call.method + " module=" + module + "handler=" + (handler?.toString() ?? 'null'));
      if (handler != null) {
        return handler._handler(call);
      }
    }
    return Future<dynamic>.value();
  }
}
