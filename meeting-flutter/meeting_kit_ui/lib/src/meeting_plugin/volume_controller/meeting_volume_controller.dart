// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

/// Provide the iOS/Androd system volume.
class NEVolumeController extends _Service {
  /// This event channel is used to communicate with iOS/Android event.
  EventChannel _eventChannel =
      EventChannel('meeting_plugin.volume_listener_event.states');

  /// Volume Listener Subscription
  StreamSubscription<double>? _volumeListener;

  NEVolumeController(super.methodChannel, super.handlerMap);

  /// This method listen to the system volume. The volume value will be generated when the volume was changed.
  StreamSubscription<double> listener(Function(double)? onData) {
    assert(_volumeListener == null, 'Listener already exists');
    _volumeListener = _eventChannel
        .receiveBroadcastStream()
        .map((d) => d as double)
        .listen(onData);
    return _volumeListener!;
  }

  /// This method for canceling volume listener
  void removeListener() {
    _volumeListener?.cancel();
    _volumeListener = null;
  }

  @override
  String _getModule() {
    return 'NEVolumeController';
  }

  @override
  Future _handlerMethod(String method, int code, Map arg, callback) {
    return Future<dynamic>.value();
  }
}
