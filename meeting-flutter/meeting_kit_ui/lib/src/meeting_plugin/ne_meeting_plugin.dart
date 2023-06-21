// Copyright (c) 2022 NetEase, Inc. All rights reserved.
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

  static NEImageGallerySaver? _imageGallerySaver;

  static NEBluetoothService? _bluetoothService;

  static NEPhoneStateService? _phoneStateService;

  static NEAppLifecycleDetector? _appLifecycleDetector;

  static NEIpadCheckDetector? _ipadCheckDetector;

  /// notification service
  NENotificationService getNotificationService() {
    return _notificationService ??
        (_notificationService =
            NENotificationService(_methodChannel, handlerMap));
  }

  /// notification service
  NEAssetService getAssetService() {
    return _assetService ??
        (_assetService = NEAssetService(_methodChannel, handlerMap));
  }

  NEImageGallerySaver get imageGallerySaver {
    _imageGallerySaver ??= NEImageGallerySaver(_methodChannel, handlerMap);
    return _imageGallerySaver!;
  }

  NEIpadCheckDetector get ipadCheckDetector {
    _ipadCheckDetector ??= NEIpadCheckDetector(_methodChannel, handlerMap);
    return _ipadCheckDetector!;
  }

  NEBluetoothService get bluetoothService {
    _bluetoothService ??= NEBluetoothService._();
    return _bluetoothService!;
  }

  NEPhoneStateService get phoneStateService {
    _phoneStateService ??= NEPhoneStateService._();
    return _phoneStateService!;
  }

  NEAppLifecycleDetector get appLifecycleDetector {
    _appLifecycleDetector ??= NEAppLifecycleDetector();
    return _appLifecycleDetector!;
  }

  /// native  --  dart
  Future<dynamic> _handler(MethodCall call) {
    final map = call.arguments as Map?;
    if (map != null) {
      final module = map['module']?.toString() ?? "";
      _Handler? handler = handlerMap[module];
      print("_handler method= " +
          call.method +
          " module=" +
          module +
          "handler=" +
          (handler?.toString() ?? 'null'));
      if (handler != null) {
        return handler._handler(call);
      }
    }
    return Future<dynamic>.value();
  }
}
