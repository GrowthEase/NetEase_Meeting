// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NESettingsServiceImpl extends NESettingsService {
  static late SharedPreferences _sharedPreferences;

  static final _NESettingsServiceImpl _instance = _NESettingsServiceImpl._();

  factory _NESettingsServiceImpl() => _instance;
  String? _userId;
  late String _key;
  final Map _settingsCache = {};
  final Map _transientStates = {};
  StreamSubscription? subscription;

  SDKConfig? _config;

  /// SDKConfig.current 会在重新初始化后被重新赋值，会指向不同的对象，不能使用字段赋值
  SDKConfig get sdkConfig => _config ?? SDKConfig.current;

  set sdkConfig(value) {
    _config = value;
    subscription?.cancel();
    subscription = sdkConfig.onConfigUpdated.listen((event) async {
      _markChanged();
    });
  }

  _NESettingsServiceImpl._() {
    _ensureSettings();
  }

  Future<Map> _ensureSettings() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    if (_userId != getCurrentUserId()) {
      _beautyFaceValue = null;
      _userId = getCurrentUserId();
      _key = '${_userId}_localSetting';
      var settings = _sharedPreferences.getString(_key);
      _settingsCache.clear();
      _settingsCache.addAll((settings == null || settings.isEmpty
          ? {}
          : json.decode(settings)) as Map);
      _markChanged();
    }
    return _settingsCache;
  }

  @override
  void enableShowMyMeetingElapseTime(bool show) =>
      _writeSettings(Keys.isShowMyMeetingElapseTimeEnabled, show);

  @override
  Future<bool> isShowMyMeetingElapseTimeEnabled() =>
      _ensureSettings().then((settings) =>
          (settings[Keys.isShowMyMeetingElapseTimeEnabled] ?? false) as bool);

  @override
  void enableTurnOnMyAudioWhenJoinMeeting(bool enable) =>
      _writeSettings(Keys.isTurnOnMyAudioWhenJoinMeetingEnabled, enable);

  @override
  Future<bool> isTurnOnMyAudioWhenJoinMeetingEnabled() =>
      _ensureSettings().then((settings) =>
          (settings[Keys.isTurnOnMyAudioWhenJoinMeetingEnabled] ?? false)
              as bool);

  @override
  void enableTurnOnMyVideoWhenJoinMeeting(bool enable) =>
      _writeSettings(Keys.isTurnOnMyVideoWhenJoinMeetingEnabled, enable);

  @override
  Future<bool> isTurnOnMyVideoWhenJoinMeetingEnabled() =>
      _ensureSettings().then((settings) =>
          (settings[Keys.isTurnOnMyVideoWhenJoinMeetingEnabled] ?? false)
              as bool);

  @override
  Future<bool> isAudioAINSEnabled() => _ensureSettings()
      .then((settings) => (settings[Keys.isAudioAINSEnabled] ?? true) as bool);

  @override
  void enableAudioAINS(bool enable) {
    _writeSettings(Keys.isAudioAINSEnabled, enable);
  }

  void _writeSettings(String key, dynamic value, {bool commit = true}) async {
    await _ensureSettings();
    dynamic oldValue = _settingsCache[key];
    if (oldValue != value) {
      if (value == null) {
        _settingsCache.remove(key);
      } else {
        _settingsCache[key] = value;
      }
      if (commit) {
        await _sharedPreferences.setString(_key, jsonEncode(_settingsCache));
      }
      _markChanged();
    }
  }

  /// 通过[ValueNotifier]通知listeners
  void _markChanged() async {
    await updateTransientStates();
    value = Map.fromEntries([
      ..._settingsCache.entries,
      ..._transientStates.entries,
    ]);
  }

  String getCurrentUserId() {
    final accountService = NEMeetingKit.instance.getAccountService();
    final id = accountService.getAccountInfo()?.userUuid;
    final anonymous = accountService.isAnonymous;
    return id == null || id.isEmpty || anonymous ? '0' : id;
  }

  int? _beautyFaceValue;

  @override
  Future<int> getBeautyFaceValue() async {
    _beautyFaceValue ??=
        max(_settingsCache[Keys.beautyFaceValue] as int? ?? 0, 0);
    return _beautyFaceValue!;
  }

  @override
  Future<bool> isBeautyFaceSupported() =>
      Future.value(sdkConfig.isBeautyFaceSupported);

  @override
  Future<void> setBeautyFaceValue(int value) async {
    if (_beautyFaceValue != value) {
      _beautyFaceValue = value;
      if (NEMeetingKit.instance.getAccountService().isAnonymous) {
        return;
      }
      _writeSettings(Keys.beautyFaceValue, value);
    }
  }

  @override
  Future<bool> isMeetingLiveSupported() =>
      Future.value(sdkConfig.isLiveSupported);

  @override
  Future<bool> isWaitingRoomSupported() =>
      Future.value(sdkConfig.isWaitingRoomSupported);

  /// update global config
  Future updateTransientStates() async {
    _transientStates.clear();
    _transientStates[Keys.isMeetingLiveSupported] = sdkConfig.isLiveSupported;
    _transientStates[Keys.isBeautyFaceSupported] =
        sdkConfig.isBeautyFaceSupported;
    _transientStates[Keys.isMeetingWhiteboardSupported] =
        sdkConfig.isWhiteboardSupported;
    _transientStates[Keys.isMeetingCloudRecordSupported] =
        sdkConfig.isCloudRecordSupported;
    _transientStates[Keys.isVirtualBackgroundEnabled] =
        await isVirtualBackgroundEnabled();
  }

  @override
  Future<bool> isMeetingCloudRecordSupported() =>
      Future.value(sdkConfig.isCloudRecordSupported);

  @override
  Future<bool> isMeetingWhiteboardSupported() =>
      Future.value(sdkConfig.isWhiteboardSupported);

  @override
  void enableVirtualBackground(bool enable) {
    _writeSettings(Keys.isVirtualBackgroundEnabled, enable);
  }

  @override
  Future<bool> isVirtualBackgroundEnabled() async {
    await _ensureSettings();
    var isVirtualBackgroundEnabled =
        ((_settingsCache[Keys.isVirtualBackgroundEnabled] as bool?) ?? true) &&
            sdkConfig.isVirtualBackgroundSupported;
    return Future.value(isVirtualBackgroundEnabled);
  }

  @override
  void setBuiltinVirtualBackgroundList(List<String> pathList) {
    _writeSettings(Keys.builtinVirtualBackgroundList, pathList);
  }

  @override
  Future<List<String>> getBuiltinVirtualBackgroundList() async {
    await _ensureSettings();
    var builtinVirtualBackgroundJson =
        _settingsCache[Keys.builtinVirtualBackgroundList];
    var builtinVirtualBackgrounds =
        (builtinVirtualBackgroundJson as List?)?.whereType<String>().toList();
    return Future.value(builtinVirtualBackgrounds ?? []);
  }

  @override
  void setCurrentVirtualBackground(String? path) {
    _writeSettings(Keys.currentVirtualBackground, path);
  }

  @override
  Future<String?> getCurrentVirtualBackground() async {
    await _ensureSettings();
    return Future.value(
        _settingsCache[Keys.currentVirtualBackground] as String?);
  }

  @override
  void setExternalVirtualBackgroundList(List<String> virtualBackgrounds) {
    _writeSettings(Keys.externalVirtualBackgroundList, virtualBackgrounds);
  }

  @override
  Future<List<String>> getExternalVirtualBackgroundList() async {
    await _ensureSettings();
    var externalVirtualBackgrounds =
        _settingsCache[Keys.externalVirtualBackgroundList] as List?;
    return Future.value(externalVirtualBackgrounds?.cast<String>() ?? []);
  }

  @override
  void enableSpeakerSpotlight(bool enable) {
    _writeSettings(Keys.isSpeakerSpotlightEnabled, enable);
  }

  @override
  Future<bool> isSpeakerSpotlightEnabled() async {
    await _ensureSettings();
    return Future.value(_settingsCache[Keys.isSpeakerSpotlightEnabled] ?? true);
  }

  @override
  Future<bool> isFrontCameraMirrorEnabled() async {
    await _ensureSettings();
    return Future.value(
        (_settingsCache[Keys.isFrontCameraMirrorEnabled] as bool?) ?? true);
  }

  @override
  Future<void> enableFrontCameraMirror(bool enable) async {
    _writeSettings(Keys.isFrontCameraMirrorEnabled, enable);
  }

  @override
  Future<bool> isTransparentWhiteboardEnabled() async {
    await _ensureSettings();
    return Future.value(
        (_settingsCache[Keys.isTransparentWhiteboardEnabled] as bool?) ??
            false);
  }

  @override
  Future<void> enableTransparentWhiteboard(bool enable) async {
    _writeSettings(Keys.isTransparentWhiteboardEnabled, enable);
  }

  @override
  Future<bool> isVirtualBackgroundSupported() {
    return Future.value(sdkConfig.isVirtualBackgroundSupported);
  }
}

class Keys {
  static const String isShowMyMeetingElapseTimeEnabled =
      "isShowMyMeetingElapseTimeEnabled";
  static const String isTurnOnMyVideoWhenJoinMeetingEnabled =
      "isTurnOnMyVideoWhenJoinMeetingEnabled";
  static const String isTurnOnMyAudioWhenJoinMeetingEnabled =
      "isTurnOnMyAudioWhenJoinMeetingEnabled";
  static const String isMeetingLiveSupported = "isMeetingLiveSupported";
  static const String isMeetingWhiteboardSupported =
      "isMeetingWhiteboardSupported";
  static const String isMeetingCloudRecordSupported =
      "isMeetingCloudRecordSupported";
  static const String isAudioAINSEnabled = "isAudioAINSEnabled";
  static const String isVirtualBackgroundEnabled = "isVirtualBackgroundEnabled";
  static const String builtinVirtualBackgroundList =
      "builtinVirtualBackgroundList";
  static const String externalVirtualBackgroundList =
      "externalVirtualBackgroundList";
  static const String currentVirtualBackground = "currentVirtualBackground";
  static const String isSpeakerSpotlightEnabled = "isSpeakerSpotlightEnabled";
  static const String isFrontCameraMirrorEnabled = "isFrontCameraMirrorEnabled";
  static const String isTransparentWhiteboardEnabled =
      "isTransparentWhiteboardEnabled";
  static const String isBeautyFaceSupported = "isBeautyFaceSupported";
  static const String beautyFaceValue = "beautyFaceValue";
  static const String isWaitingRoomSupported = "isWaitingRoomSupported";
  static const String isVirtualBackgroundSupported =
      "isVirtualBackgroundSupported";
}
