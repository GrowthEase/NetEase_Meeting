// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

class NEPipController extends _Service {
  NEPipController(MethodChannel methodChannel, Map<String, _Handler> handlerMap)
      : super(methodChannel, handlerMap);

  @override
  String _getModule() {
    return 'NEPipController';
  }

  static bool _isPIPSetupDone = false;
  @override
  Future<dynamic> _handlerMethod(
      String method, int code, Map arg, dynamic callback) {
    return Future<dynamic>.value();
  }

  Future<void> setup(String roomUuid, {bool autoEnterPIP = false}) async {
    Map map = buildArguments();
    map['roomUuid'] = roomUuid;
    map['auto_enter_pip'] = autoEnterPIP;
    print("roomUuid: $roomUuid autoEnterPIP: $autoEnterPIP");
    final result = await _methodChannel.invokeMethod('setup_pip', map);
    print("${result['description']}");
    _isPIPSetupDone = result['code'] == 0;
  }

  Future<bool> isActive() async {
    if (_isPIPSetupDone) {
      return await _methodChannel.invokeMethod(
          'is_pip_active', buildArguments());
    }
    return false;
  }

  Future<void> updateVideo(
      String roomUuid, String userUuid, String shareUuid) async {
    if (!_isPIPSetupDone) return;
    Map map = buildArguments();
    map['roomUuid'] = roomUuid;
    map['userUuid'] = userUuid;
    map['shareUuid'] = shareUuid;
    final result = await _methodChannel.invokeMethod('change_video', map);
    print("update video: ${result['description']}");
  }

  Future<void> memberVideoChange(String userUuid, bool isVideoOn) async {
    Map map = buildArguments();
    map['userUuid'] = userUuid;
    map['isVideoOn'] = isVideoOn;
    final result =
        await _methodChannel.invokeMethod('member_video_change', map);
    print("member video change: ${result['description']}");
  }

  Future<bool> disposePIP() async {
    print("执行dispose");
    final result =
        await _methodChannel.invokeMethod('dispose_pip', buildArguments());
    final code = result['code'];
    if (code == 0) {
      _isPIPSetupDone = false;
    }
    return code == 0;
  }
}
