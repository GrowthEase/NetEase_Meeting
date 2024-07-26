// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

class NEBluetoothService {
  static const _STATES_EVENT_CHANNEL_NAME =
      "meeting_plugin.bluetooth_service.states";

  NEBluetoothService._();

  final _statesEventChannel = EventChannel(_STATES_EVENT_CHANNEL_NAME);

  bool? _isEnabled;
  Stream<bool>? _sourceStream;

  Future<bool> get isEnabled async {
    if (_isEnabled == null) {
      _ensureEnableStateSourceStream();
      return _sourceStream!.first;
    }
    return _isEnabled!;
  }

  Stream<bool> get enableStateChanged {
    _ensureEnableStateSourceStream();
    final controller = StreamController<bool>();
    if (_isEnabled != null) {
      controller.add(_isEnabled!);
    }
    controller.addStream(_sourceStream!);
    controller.onCancel = () {
      controller.close();
    };
    return controller.stream;
  }

  void _ensureEnableStateSourceStream() {
    if (_sourceStream == null) {
      _sourceStream = _statesEventChannel.receiveBroadcastStream().map((event) {
        assert(event is Map);
        _isEnabled = event['enabled'] as bool;
        return _isEnabled!;
      }).distinct();
      _sourceStream!.listen((event) {});
    }
  }
}
