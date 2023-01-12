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

  _NESettingsServiceImpl._() {
    _ensureSettings();
    sdkConfigChangeStream.listen((event) {
      updateGlobalConfig();
      _markChanged();
    });
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
      updateGlobalConfig();
      _markChanged();
    }
    return _settingsCache;
  }

  @override
  void enableShowMyMeetingElapseTime(bool show) =>
      _writeSettings(Keys.keyShowMeetTimeOpen, show);

  @override
  Future<bool> isShowMyMeetingElapseTimeEnabled() => _ensureSettings().then(
      (settings) => (settings[Keys.keyShowMeetTimeOpen] ?? false) as bool);

  @override
  void setTurnOnMyAudioWhenJoinMeeting(bool enabled) =>
      _writeSettings(Keys.keyMicroOpen, enabled);

  @override
  Future<bool> isTurnOnMyAudioWhenJoinMeetingEnabled() => _ensureSettings()
      .then((settings) => (settings[Keys.keyMicroOpen] ?? false) as bool);

  @override
  void setTurnOnMyVideoWhenJoinMeeting(bool enabled) =>
      _writeSettings(Keys.keyCameraOpen, enabled);

  @override
  Future<bool> isTurnOnMyVideoWhenJoinMeetingEnabled() => _ensureSettings()
      .then((settings) => (settings[Keys.keyCameraOpen] ?? false) as bool);

  @override
  Future<bool> isAudioAINSEnabled() => _ensureSettings().then(
      (settings) => (settings[Keys.keyAudioAINSEnabled] ?? false) as bool);

  @override
  void enableAudioAINS(bool enable) {
    _writeSettings(Keys.keyAudioAINSEnabled, enable);
  }

  void _writeSettings(String key, dynamic value) async {
    await _ensureSettings();
    dynamic oldValue = _settingsCache[key];
    if (oldValue != value) {
      if (value == null) {
        _settingsCache.remove(key);
      } else {
        _settingsCache[key] = value;
      }
      await _sharedPreferences.setString(_key, jsonEncode(_settingsCache));
      _markChanged();
    }
  }

  /// 通过[ValueNotifier]通知listeners
  void _markChanged() {
    value = Map.unmodifiable(_settingsCache);
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
    _beautyFaceValue ??= NEMeetingKit.instance
            .getAccountService()
            .getAccountInfo()
            ?.settings
            ?.beauty
            ?.beauty
            .level ??
        0;
    return _beautyFaceValue!;
  }

  @override
  Future<bool> isBeautyFaceEnabled() =>
      Future.value(SettingsRepository.isBeautyFaceSupported());

  @override
  Future<void> setBeautyFaceValue(int value) async {
    if (_beautyFaceValue != value) {
      if (NEMeetingKit.instance.getAccountService().isAnonymous) {
        _beautyFaceValue = value;
        return;
      }
      final result = await SettingsRepository.saveBeautyFaceValue(value);
      if (result.isSuccess()) {
        _beautyFaceValue = value;
        _writeSettings(Keys.keySetBeautyFaceValue, value);
      }
    }
  }

  /// 查询会议是否拥有直播权限
  ///
  @override
  Future<bool> isMeetingLiveEnabled() => _ensureSettings().then(
      (settings) async => Future.value((settings[Keys.keyMeetingLiveEnabled] ??
          SettingsRepository.isMeetingLiveSupported()) as bool));

  /// update global config
  void updateGlobalConfig() async {
    final meetingLiveEnabled = SettingsRepository.isMeetingLiveSupported();
    var isBeautyFaceEnabled = SettingsRepository.isBeautyFaceSupported();
    final isMeetingWhiteboardEnabled =
        SettingsRepository.isMeetingWhiteboardSupported();
    var isMeetingRecordEnabled =
        SettingsRepository.isMeetingCloudRecordSupported();
    _writeSettings(Keys.keyMeetingLiveEnabled, meetingLiveEnabled);
    _writeSettings(Keys.keyBeautyFaceEnabled, isBeautyFaceEnabled);
    _writeSettings(Keys.keyWhiteboardEnabled, isMeetingWhiteboardEnabled);
    _writeSettings(Keys.keyMeetingRecordEnabled, isMeetingRecordEnabled);
    _markChanged();
  }

  @override
  Future<List<NEHistoryMeetingItem>?> getHistoryMeetingItem() async {
    var settings = await _ensureSettings();
    final item = NEHistoryMeetingItem.fromJson(
        settings[Keys.keyHistoryMeetingItem] as Map?);
    if (item != null) {
      return [item];
    }
    return null;
  }

  @override
  void updateHistoryMeetingItem(NEHistoryMeetingItem? item) async {
    _writeSettings(Keys.keyHistoryMeetingItem, item?.toJson());
  }

  @override
  Future<bool> isMeetingCloudRecordEnabled() {
    return Future.value(SettingsRepository.isMeetingCloudRecordSupported());
  }

  @override
  Future<bool> isMeetingWhiteboardEnabled() {
    return Future.value(SDKConfig.appRoomResConfig.whiteboard);
  }

  @override
  Stream<bool> get sdkConfigChangeStream => SDKConfig.initNotifyStream;

  @override
  void enableVirtualBackground(bool enable) {
    _writeSettings(Keys.enableVirtualBackground, enable);
  }

  @override
  Future<bool> isVirtualBackgroundEnabled() {
    var isVirtualBackgroundEnabled =
        ((_settingsCache[Keys.enableVirtualBackground] as bool?) ?? true) &&
            SettingsRepository.isVirtualBackgroundFaceSupported();
    return Future.value(isVirtualBackgroundEnabled);
  }

  @override
  bool shouldUnpubOnAudioMute() {
    return SDKConfig.unpubAudioOnMuteConfig.enable;
  }

  @override
  void setBuiltinVirtualBackgrounds(
      List<NEMeetingVirtualBackground> virtualBackgrounds) {
    var str = virtualBackgrounds.map((e) => e.toJson()).toList();
    _writeSettings(Keys.builtinVirtualBackgrounds, str);
  }

  @override
  Future<List<NEMeetingVirtualBackground>> getBuiltinVirtualBackgrounds() {
    var builtinVirtualBackgroundJson =
        _settingsCache[Keys.builtinVirtualBackgrounds];
    var builtinVirtualBackgrounds = (builtinVirtualBackgroundJson as List?)
        ?.map((e) => NEMeetingVirtualBackground.fromMap(e))
        .toList();
    return Future.value(builtinVirtualBackgrounds ?? []);
  }
}

class Keys {
  static const String keyCameraOpen = 'cameraOpen';

  static const String keyMicroOpen = 'microphoneOpen';

  static const String keyShowMeetTimeOpen = 'showMeetingTime';

  /// 音频智能降噪
  static const String keyAudioAINSEnabled = 'audioAINSEnabled';

  static const String keyMeetingLiveEnabled = 'meetingLiveEnabled';

  /// 开关组件美颜UI界面预览
  static const String keyOpenBeautyUI = 'openBeautyUI';

  /// 查询美颜服务是否可用接口
  static const String keyBeautyFaceEnabled = 'isBeautyFaceEnabled';

  /// 漫游美颜等级，美颜等级配置（0-10）
  static const String keySetBeautyFaceValue = 'setBeautyFaceValue';

  /// 获取美颜当前配置接口
  static const String keyGetBeautyFaceValue = 'getBeautyFaceValue';

  static const String keyHistoryMeetingItem = 'historyMeetingItem';

  /// 查询白板服务是否可用接口
  static const String keyWhiteboardEnabled = 'isMeetingWhiteboardEnabled';

  /// 查询录制服务是否可用接口
  static const String keyMeetingRecordEnabled = 'isMeetingRecordEnabled';

  /// 虚拟背景 是否开启
  static const String enableVirtualBackground = "enableVirtualBackground";

  /// 设置虚拟背景
  static const String builtinVirtualBackgrounds = "builtinVirtualBackgrounds";
}
