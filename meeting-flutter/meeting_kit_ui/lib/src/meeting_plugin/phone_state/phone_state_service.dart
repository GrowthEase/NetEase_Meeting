// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

class NEPhoneStateService {
  static const _STATES_EVENT_CHANNEL_NAME =
      "meeting_plugin.phone_state_service.states";

  NEPhoneStateService._();

  final _statesEventChannel = EventChannel(_STATES_EVENT_CHANNEL_NAME);

  bool? _isInCall;
  Stream<bool>? _sourceStream;

  Future<bool> get isInCall async {
    if (_isInCall == null) {
      _ensurePhoneStateSourceStream();
      return _sourceStream!.first;
    }
    return _isInCall!;
  }

  Stream<bool> get inCallStateChanged {
    _ensurePhoneStateSourceStream();
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
        debugPrint('phone state changed: $event');
        _isInCall = event['isInCall'] as bool;
        return _isInCall!;
      }).distinct();
      _sourceStream!.listen((event) {});
    }
  }
}
