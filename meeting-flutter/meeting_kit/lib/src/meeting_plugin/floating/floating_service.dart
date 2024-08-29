// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_plugin;

class NEFloatingService extends _Service {
  NEFloatingService(
      MethodChannel _methodChannel, Map<String, _Handler> handlerMap)
      : super(_methodChannel, handlerMap);

  final _controller = StreamController<PiPStatus>();
  final Duration _probeInterval = const Duration(milliseconds: 10);
  Timer? _timer;
  Stream<PiPStatus>? _stream;

  final alog = Alogger.normal('NEFloatingService', 'meeting_ui');
  static bool _isPIPSetupDone = false;

  @override
  String _getModule() => 'NEFloatingService';

  @override
  Future<dynamic> _handlerMethod(
      String method, int code, Map arg, dynamic callback) {
    return Future<dynamic>.value();
  }

  Future<bool> isInPipMode() async {
    if (Platform.isAndroid) return await pipStatus == PiPStatus.enabled;
    if (Platform.isIOS) return await isActive();
    return false;
  }

  /// Checks current app PiP status.
  ///
  /// When `false` the app can call [enable] method.
  /// When the app is already in PiP mode user will have an option
  /// to bring the app to it's original size via system UI.
  ///
  /// PiP may be unavailable because of system settings managed
  /// by admin or device manufacturer. Also, the device may
  /// have Android version that was released without this feature.
  Future<PiPStatus> get pipStatus async {
    if (!await isPipAvailable) {
      return PiPStatus.unavailable;
    }
    final bool? inPipAlready = await _methodChannel.invokeMethod(
        'inPipAlready', buildArguments(arg: <String, dynamic>{}));
    return inPipAlready ?? false ? PiPStatus.enabled : PiPStatus.disabled;
  }

  // Notifies about changes of the PiP mode.
  //
  // PiP state is probed, by default in the 100 milliseconds interval.
  // The probing interval can be configured in the constructor.
  //
  // This stream will call listeners only when the value changed.
  Stream<PiPStatus> get pipStatus$ {
    _timer ??= Timer.periodic(
      _probeInterval,
      (_) async => _controller.add(await pipStatus),
    );
    _stream ??= _controller.stream.asBroadcastStream();
    return _stream!.distinct();
  }

  /// Turns on PiP mode.
  ///
  /// When enabled, PiP mode can be ended by the user via system UI.
  ///
  /// PiP may be unavailable because of system settings managed
  /// by admin or device manufacturer. Also, the device may
  /// have Android version that was released without this feature.
  ///
  /// Provide [aspectRatio] to override default 16/9 aspect ratio.
  /// [aspectRatio] must fit into Android-supported values:
  /// min: 1/2.39, max: 2.39/1, otherwise [RationalNotMatchingAndroidRequirementsException]
  /// will be thrown.
  /// Note: this will not make any effect on Android SDK older than 26.
  Future<PiPStatus> enable({
    Rational aspectRatio = const Rational.landscape(),
    Rectangle<int>? sourceRectHint,
  }) async {
    if (!aspectRatio.fitsInAndroidRequirements) {
      throw RationalNotMatchingAndroidRequirementsException(aspectRatio);
    }

    final bool? enabledSuccessfully = await _methodChannel.invokeMethod(
      'enablePip',
      buildArguments(arg: <String, dynamic>{
        ...aspectRatio.toMap(),
        if (sourceRectHint != null)
          'sourceRectHintLTRB': [
            sourceRectHint.left,
            sourceRectHint.top,
            sourceRectHint.right,
            sourceRectHint.bottom,
          ],
      }),
    );
    return enabledSuccessfully ?? false
        ? PiPStatus.enabled
        : PiPStatus.unavailable;
  }

  Future<bool> exitPIPMode() async {
    final bool? exitPIP = await _methodChannel.invokeMethod(
        'exitPIPMode', buildArguments(arg: <String, dynamic>{}));
    return exitPIP ?? false;
  }

  Future<bool> disposePIP() async {
    final bool? disposePIP = await _methodChannel.invokeMethod(
        'disposePIP', buildArguments(arg: <String, dynamic>{}));
    _isPIPSetupDone = false;
    return disposePIP ?? false;
  }

  Future<void> inviteDispose() async {
    if (Platform.isIOS) {
      return _methodChannel.invokeMethod(
          'inviteDispose', buildArguments(arg: <String, dynamic>{}));
    }
  }

  /// Confirms or denies PiP availability.
  ///
  /// PiP may be unavailable because of system settings managed
  /// by admin or device manufacturer. Also, the device may
  /// have Android version that was released without this feature.
  Future<bool> get isPipAvailable async {
    final bool? supportsPip = await _methodChannel.invokeMethod(
        'pipAvailable', buildArguments(arg: <String, dynamic>{}));
    return supportsPip ?? false;
  }

  Future<void> setup(
      String roomUuid, String waitingTips, String interruptedTips,
      {bool hideAvatar = false,
      bool autoEnterPIP = false,
      String? inviterRoomId,
      String? inviterName,
      String? inviterIcon}) async {
    if (_isPIPSetupDone) return;
    Map map = buildArguments();
    map['roomUuid'] = roomUuid;
    map['auto_enter_pip'] = autoEnterPIP;
    map['waitingTips'] = waitingTips;
    map['interruptedTips'] = interruptedTips;
    map['hideAvatar'] = hideAvatar;
    if (TextUtils.isNotEmpty(inviterIcon)) {
      map['inviterIcon'] = inviterIcon;
    }
    if (TextUtils.isNotEmpty(inviterRoomId)) {
      map['inviterRoomId'] = inviterRoomId;
    }
    if (TextUtils.isNotEmpty(inviterName)) {
      map['inviterName'] = inviterName;
    }
    final result = await _methodChannel.invokeMethod('setupPIP', map);
    if (result == null) {
      alog.i("PIP -> setup pip. roomUuid: $roomUuid. result: null");
      return;
    }
    alog.i(
        "PIP -> setup pip. roomUuid: $roomUuid. result: ${result['description']}");
    _isPIPSetupDone = result['code'] == 0;
  }

  Future<bool> isActive() async {
    if (_isPIPSetupDone) {
      return await _methodChannel.invokeMethod(
              'isPIPActive', buildArguments()) ??
          false;
    }
    return false;
  }

  Future<void> hideAvatar(bool hide) async {
    if (!_isPIPSetupDone) return;
    Map map = buildArguments();
    map['hideAvatar'] = hide;
    await _methodChannel.invokeMethod('hideAvatar', map);
    return;
  }

  Future<void> updateVideo(
      String roomUuid, String userUuid, String shareUuid, bool isInCall) async {
    if (!_isPIPSetupDone) return;
    Map map = buildArguments();
    map['roomUuid'] = roomUuid;
    map['userUuid'] = userUuid;
    map['shareUuid'] = shareUuid;
    map['isInCall'] = isInCall;
    final result = await _methodChannel.invokeMethod('changeVideo', map);
    if (result == null) {
      alog.i(
          "PIP -> update video. UserUuid: $userUuid. ShareUuid: $shareUuid. result: null");
      return;
    }
    alog.i(
        "PIP -> update video. UserUuid: $userUuid. ShareUuid: $shareUuid. result: ${result['description']}");
  }

  void memberVideoChange(String userUuid, bool isVideoOn) {
    if (!_isPIPSetupDone) return;
    Map map = buildArguments();
    map['userUuid'] = userUuid;
    map['isVideoOn'] = isVideoOn;
    _methodChannel.invokeMethod('memberVideoChange', map);
  }

  void memberAudioChange(String userUuid, bool isAudioOn) {
    if (!_isPIPSetupDone) return;
    Map map = buildArguments();
    map['userUuid'] = userUuid;
    map['isAudioOn'] = isAudioOn;
    _methodChannel.invokeMethod('memberAudioChange', map);
  }

  void memberInCall(String userUuid, bool isInCall) {
    if (!_isPIPSetupDone) return;
    Map map = buildArguments();
    map['userUuid'] = userUuid;
    map['isInCall'] = isInCall;
    _methodChannel.invokeMethod('memberInCall', map);
  }

  // Disposes internal components used to update the [isInPipMode$] stream.
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }

  /// Turns on PiP mode.
  Future<bool> updatePIPParams({
    Rational aspectRatio = const Rational.landscape(),
  }) async {
    final bool? enabledSuccessfully = await _methodChannel.invokeMethod(
      'updatePIPParams',
      buildArguments(arg: <String, dynamic>{
        ...aspectRatio.toMap(),
      }),
    );
    return enabledSuccessfully ?? false;
  }
}
