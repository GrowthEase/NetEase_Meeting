// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

class NEAppLifecycleDetector {
  static final _singleton = NEAppLifecycleDetector._();
  NEAppLifecycleDetector._();
  factory NEAppLifecycleDetector() {
    _lifeCycleListener();
    return _singleton;
  }
  static final _streamController = StreamController<bool>.broadcast();

  static const _STATES_EVENT_CHANNEL_NAME =
      "meeting_plugin.app_lifecycle_service.states";

  static const _eventChannel = EventChannel(_STATES_EVENT_CHANNEL_NAME);

  static final alog = Alogger.normal('NEAppLifecycleDetector', 'meeting_ui');

  static void _lifeCycleListener() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      assert(event is Map);
      alog.i('app lifecycle changed: $event');
      _streamController.sink.add(event['isInBackground'] as bool);
    });
  }

  Stream<bool> get onBackgroundChange => _streamController.stream;

  void cancel() {
    _streamController.close();
  }
}
