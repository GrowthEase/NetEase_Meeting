// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

class NEPhoneStateService {
  static const _STATES_EVENT_CHANNEL_NAME =
      "meeting_plugin.phone_state_service.states";

  NEPhoneStateService._();

  final alog = Alogger.normal('NEPhoneStateService', 'meeting_ui');
  final _statesEventChannel = EventChannel(_STATES_EVENT_CHANNEL_NAME);

  bool? _isInCall;
  Stream<bool>? _sourceStream;
  bool _started = false;

  // android 需要在确保有权限的时候调用
  // ios 不需要
  void start() {
    if (!_started) {
      alog.i('start listen phone state');
      _ensurePhoneStateSourceStream();
      _started = true;
    }
  }

  Future<bool> get isInCall async {
    if (!_started) return false;
    if (_isInCall == null) {
      return _sourceStream!.first;
    }
    return _isInCall!;
  }

  Stream<bool> get inCallStateChanged {
    if (!_started) return Stream.value(false);
    final controller = StreamController<bool>();
    if (_isInCall != null) {
      controller.add(_isInCall!);
    }
    controller.addStream(_sourceStream!);
    controller.onCancel = () {
      controller.close();
    };
    return controller.stream;
  }

  void _ensurePhoneStateSourceStream() {
    if (_sourceStream == null) {
      _sourceStream = _statesEventChannel.receiveBroadcastStream().map((event) {
        assert(event is Map);
        return event['isInCall'] as bool;
      }).distinct();
      _sourceStream!.listen((event) {
        alog.i('phone state changed: $event');
        _isInCall = event;
      });
    }
  }
}
