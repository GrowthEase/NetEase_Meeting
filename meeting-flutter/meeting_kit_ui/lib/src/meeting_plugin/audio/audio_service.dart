// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

typedef AudioDeviceChangedEvent = (
  NEAudioOutputDevice selectedAudioDevice,
  Set<NEAudioOutputDevice> availableAudioDevices,
  bool hasExternalMic
);

class NEAudioService extends _Service {
  NEAudioService(MethodChannel _methodChannel, Map<String, _Handler> handlerMap)
      : super(_methodChannel, handlerMap);

  static const AUDIO_MANAGER_EVENT_CHANNEL_NAME =
      "meeting_plugin.audio_service.manager";

  final _audioManagerEventChannel =
      EventChannel(AUDIO_MANAGER_EVENT_CHANNEL_NAME);

  @override
  String _getModule() => 'NEAudioService';

  AudioDeviceChangedEvent? _curEvent;
  Stream<AudioDeviceChangedEvent>? _sourceStream;

  @override
  Future<dynamic> _handlerMethod(
      String method, int code, Map arg, dynamic callback) {
    return Future<dynamic>.value();
  }

  /// 枚举所有音频设备
  Future<Set<NEAudioOutputDevice>> enumAudioDevices() async {
    final devices =
        await _methodChannel.invokeMethod('enumAudioDevices', buildArguments());
    return (devices as List)
        .map((e) => NEAudioOutputDeviceTypeExtension.fromType(e))
        .toSet();
  }

  /// 获取当前选中的音频设备
  Future<NEAudioOutputDevice> getSelectedAudioDevice() async {
    final device = await _methodChannel.invokeMethod(
        'getSelectedAudioDevice', buildArguments());
    return NEAudioOutputDeviceTypeExtension.fromType(device);
  }

  /// 选择音频设备
  Future<void> selectAudioDevice(NEAudioOutputDevice device) =>
      _methodChannel.invokeMethod(
          'selectAudioDevice', buildArguments(arg: {'device': device.index}));

  /// 设置音频配置
  Future<void> setAudioProfile(int profile, int scenario) =>
      _methodChannel.invokeMethod('setAudioProfile',
          buildArguments(arg: {'profile': profile, 'scenario': scenario}));

  /// 显示音频设备选择器，仅支持iOS
  Future<void> showAudioDevicePicker() =>
      _methodChannel.invokeMethod('showAudioDevicePicker', buildArguments());

  /// 离开房间时调用，清理音频状态
  Future<void> stop() => _methodChannel.invokeMethod('stop', buildArguments());

  Stream<AudioDeviceChangedEvent> get audioDeviceChanged {
    _ensureEnableAudioDeviceSourceStream();
    final controller = StreamController<AudioDeviceChangedEvent>();
    controller.addStream(_sourceStream!);
    controller.onCancel = () {
      controller.close();
    };
    return controller.stream;
  }

  void _ensureEnableAudioDeviceSourceStream() {
    if (_sourceStream == null) {
      _sourceStream =
          _audioManagerEventChannel.receiveBroadcastStream().map((event) {
        assert(event is Map);
        _curEvent = (
          NEAudioOutputDeviceTypeExtension.fromType(
              event['selectedAudioDevice']),
          (event['availableAudioDevices'] as List)
              .map((e) => NEAudioOutputDeviceTypeExtension.fromType(e))
              .toSet(),
          (event['hasExternalMic'] as bool?) ?? false
        );
        return _curEvent!;
      }).distinct();
      _sourceStream!.listen((event) {});
    }
  }
}
