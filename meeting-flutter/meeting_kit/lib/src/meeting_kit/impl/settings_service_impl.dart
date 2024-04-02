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
  Future<bool> isAudioAINSEnabled() => _ensureSettings()
      .then((settings) => (settings[Keys.keyAudioAINSEnabled] ?? true) as bool);

  @override
  void enableAudioAINS(bool enable) {
    _writeSettings(Keys.keyAudioAINSEnabled, enable);
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
    _beautyFaceValue ??= max(
        NEMeetingKit.instance
                .getAccountService()
                .getAccountInfo()
                ?.settings
                ?.beauty
                ?.beauty
                .level ??
            0,
        0);
    return _beautyFaceValue!;
  }

  @override
  Future<bool> isBeautyFaceEnabled() =>
      Future.value(sdkConfig.isBeautyFaceSupported);

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
  Future<bool> isMeetingLiveEnabled() =>
      Future.value(sdkConfig.isLiveSupported);

  @override
  Future<bool> isWaitingRoomEnabled() =>
      Future.value(sdkConfig.isWaitingRoomSupported);

  /// update global config
  Future updateTransientStates() async {
    _transientStates.clear();
    _transientStates[Keys.keyMeetingLiveEnabled] = sdkConfig.isLiveSupported;
    _transientStates[Keys.keyBeautyFaceEnabled] =
        sdkConfig.isBeautyFaceSupported;
    _transientStates[Keys.keyWhiteboardEnabled] =
        sdkConfig.isWhiteboardSupported;
    _transientStates[Keys.keyMeetingRecordEnabled] =
        sdkConfig.isCloudRecordSupported;
    _transientStates[Keys.enableVirtualBackground] =
        await isVirtualBackgroundEnabled();
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
  Future<bool> isMeetingCloudRecordEnabled() =>
      Future.value(sdkConfig.isCloudRecordSupported);

  @override
  Future<bool> isMeetingWhiteboardEnabled() =>
      Future.value(sdkConfig.isWhiteboardSupported);

  @override
  Stream<bool> get sdkConfigChangeStream => sdkConfig.onConfigUpdated;

  @override
  void enableVirtualBackground(bool enable) {
    _writeSettings(Keys.enableVirtualBackground, enable);
  }

  @override
  Future<bool> isVirtualBackgroundEnabled() async {
    await _ensureSettings();
    var isVirtualBackgroundEnabled =
        ((_settingsCache[Keys.enableVirtualBackground] as bool?) ?? true) &&
            sdkConfig.isVirtualBackgroundSupported;
    return Future.value(isVirtualBackgroundEnabled);
  }

  @override
  bool shouldUnpubOnAudioMute() {
    return sdkConfig.unpubAudioOnMuteConfig.enable;
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

  @override
  void setCurrentVirtualBackgroundSelected(int index) {
    _writeSettings(Keys.currentVirtualSelected, index);
  }

  @override
  Future<int> getCurrentVirtualBackgroundSelected() {
    return Future.value(
        (_settingsCache[Keys.currentVirtualSelected] as int?) ?? 0);
  }

  @override
  void setExternalVirtualBackgrounds(List<String> virtualBackgrounds) {
    _writeSettings(Keys.addExternalVirtualList, virtualBackgrounds);
  }

  @override
  Future<List<String>> getExternalVirtualBackgrounds() {
    var externalVirtualBackgrounds =
        _settingsCache[Keys.addExternalVirtualList] as List?;
    return Future.value(externalVirtualBackgrounds?.cast<String>() ?? []);
  }

  @override
  void enableAudioDeviceSwitch(bool enable) {
    _writeSettings(Keys.enableAudioDeviceSwitch, enable);
  }

  @override
  Future<bool> isAudioDeviceSwitchEnabled() {
    return Future.value(_settingsCache[Keys.enableAudioDeviceSwitch] as bool? ??
        SDKConfig.current.isAudioDeviceSwitchEnabled);
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

  /// 最近选择的虚拟背景
  static const String currentVirtualSelected = 'currentVirtualSelected';

  /// 添加外部虚拟背景列表
  static const String addExternalVirtualList = 'addExternalVirtualList';

  /// 是否允许切换音频设备
  static const String enableAudioDeviceSwitch = 'enableAudioDeviceSwitch';
}
