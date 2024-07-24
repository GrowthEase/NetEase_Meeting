// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class SettingsRepository extends ValueNotifier<Map> {
  static final _instance = SettingsRepository._();

  factory SettingsRepository() => _instance;

  late SharedPreferences _sharedPreferences;

  SettingsRepository._() : super({}) {
    sdkConfig.onConfigUpdated.listen((event) async {
      _markChanged();
    });
    ensureSettings();
  }

  String? _userId;
  late String _key;
  final Map _settingsCache = {};
  final Map _transientStates = {};
  int? _beautyFaceValue;

  final sdkConfig = SDKConfig.global;

  Future<Map> ensureSettings() async {
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

  String getCurrentUserId() {
    final id = AccountRepository().getAccountInfo()?.userUuid;
    final anonymous =
        AccountRepository().getAccountInfo()?.isAnonymous ?? false;
    return id == null || id.isEmpty || anonymous ? '0' : id;
  }

  void _writeSettings(String key, dynamic value, {bool commit = true}) async {
    await ensureSettings();
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
    _transientStates[Keys.isWaitingRoomSupported] =
        sdkConfig.isWaitingRoomSupported;
    _transientStates[Keys.isVirtualBackgroundSupported] =
        sdkConfig.isVirtualBackgroundSupported;
    _transientStates[Keys.interpretationConfig] =
        sdkConfig.interpretationConfig.toJson();
    _transientStates[Keys.scheduledMemberConfig] =
        sdkConfig.scheduledMemberConfig.toJson();
    _transientStates[Keys.isAvatarUpdateSupported] =
        sdkConfig.isAvatarUpdateSupported;
    _transientStates[Keys.isNicknameUpdateSupported] =
        sdkConfig.isNicknameUpdateSupported;
    _transientStates[Keys.appNotifySessionId] = sdkConfig.appNotifySessionId;
    _transientStates[Keys.isCaptionsSupported] = isCaptionsSupported();
    _transientStates[Keys.isTranscriptionSupported] =
        isTranscriptionSupported();
    _transientStates[Keys.isGuestJoinSupported] = isGuestJoinSupported();
  }

  ///保存用户信息配置
  Future<NEResult<void>> saveSettingsApi(BeautySettings status) async {
    return await HttpApiHelper._saveSettingsApi(status);
  }

  ///获取用户信息配置
  Future<NEResult<AccountSettings>> getSettingsApi() async {
    return HttpApiHelper._getSettingsApi();
  }

  /// 设置是否显示会议时长
  ///
  /// [enable] true-开启，false-关闭
  void enableShowMyMeetingElapseTime(bool show) =>
      _writeSettings(Keys.isShowMyMeetingElapseTimeEnabled, show);

  /// 查询是否显示会议时长
  Future<bool> isShowMyMeetingElapseTimeEnabled() =>
      ensureSettings().then((settings) =>
          (settings[Keys.isShowMyMeetingElapseTimeEnabled] ?? false) as bool);

  /// 设置入会时是否打开本地视频
  ///
  /// [enable] true-入会时打开视频，false-入会时关闭视频
  void enableTurnOnMyVideoWhenJoinMeeting(bool enable) =>
      _writeSettings(Keys.isTurnOnMyVideoWhenJoinMeetingEnabled, enable);

  /// 查询入会时是否打开本地视频
  Future<bool> isTurnOnMyVideoWhenJoinMeetingEnabled() =>
      ensureSettings().then((settings) =>
          (settings[Keys.isTurnOnMyVideoWhenJoinMeetingEnabled] ?? false)
              as bool);

  /// 设置入会时是否打开本地音频
  ///
  /// [enable] true-入会时打开音频，false-入会时关闭音频
  void enableTurnOnMyAudioWhenJoinMeeting(bool enable) =>
      _writeSettings(Keys.isTurnOnMyAudioWhenJoinMeetingEnabled, enable);

  /// 查询入会时是否打开本地音频
  Future<bool> isTurnOnMyAudioWhenJoinMeetingEnabled() =>
      ensureSettings().then((settings) =>
          (settings[Keys.isTurnOnMyAudioWhenJoinMeetingEnabled] ?? false)
              as bool);

  /// 查询应用是否支持会议直播
  bool isMeetingLiveSupported() => sdkConfig.isLiveSupported;

  /// 查询应用是否支持白板共享
  bool isMeetingWhiteboardSupported() => sdkConfig.isWhiteboardSupported;

  /// 查询应用是否支持云端录制服务
  bool isMeetingCloudRecordSupported() => sdkConfig.isCloudRecordSupported;

  /// 设置是否打开音频智能降噪
  ///
  /// [enable] true-开启，false-关闭
  void enableAudioAINS(bool enable) {
    _writeSettings(Keys.isAudioAINSEnabled, enable);
  }

  /// 查询音频智能降噪是否打开
  Future<bool> isAudioAINSEnabled() => ensureSettings()
      .then((settings) => (settings[Keys.isAudioAINSEnabled] ?? true) as bool);

  /// 设置是否显示虚拟背景
  ///
  /// [enable] true 显示 false不显示
  void enableVirtualBackground(bool enable) {
    _writeSettings(Keys.isVirtualBackgroundEnabled, enable);
  }

  /// 查询虚拟背景是否显示
  Future<bool> isVirtualBackgroundEnabled() async {
    await ensureSettings();
    var isVirtualBackgroundEnabled =
        ((_settingsCache[Keys.isVirtualBackgroundEnabled] as bool?) ?? true) &&
            sdkConfig.isVirtualBackgroundSupported;
    return Future.value(isVirtualBackgroundEnabled);
  }

  /// 设置内置虚拟背景图片路径列表
  ///
  /// [pathList] 虚拟背景图片路径列表
  void setBuiltinVirtualBackgroundList(List<String> pathList) {
    _writeSettings(Keys.builtinVirtualBackgroundList, pathList);
  }

  /// 获取内置虚拟背景图片路径列表
  Future<List<String>> getBuiltinVirtualBackgroundList() async {
    await ensureSettings();
    var builtinVirtualBackgroundJson =
        _settingsCache[Keys.builtinVirtualBackgroundList];
    var builtinVirtualBackgrounds =
        (builtinVirtualBackgroundJson as List?)?.whereType<String>().toList();
    return Future.value((builtinVirtualBackgrounds ?? []).copy().toList());
  }

  /// 设置外部虚拟背景图片路径列表
  ///
  /// [pathList] 虚拟背景图片路径列表
  void setExternalVirtualBackgroundList(List<String> virtualBackgrounds) {
    _writeSettings(Keys.externalVirtualBackgroundList, virtualBackgrounds);
  }

  /// 获取外部虚拟背景图片路径列表
  Future<List<String>> getExternalVirtualBackgroundList() async {
    await ensureSettings();
    var externalVirtualBackgrounds =
        _settingsCache[Keys.externalVirtualBackgroundList] as List?;
    return Future.value(
        (externalVirtualBackgrounds?.cast<String>() ?? []).copy().toList());
  }

  /// 设置最近选择的虚拟背景图片路径
  ///
  /// [path] 虚拟背景图片路径,为空代表不设置虚拟背景
  void setCurrentVirtualBackground(String? path) {
    _writeSettings(Keys.currentVirtualBackground, path);
  }

  /// 获取最近选择的虚拟背景图片路径
  Future<String?> getCurrentVirtualBackground() async {
    await ensureSettings();
    return Future.value(
        _settingsCache[Keys.currentVirtualBackground] as String?);
  }

  /// 设置是否开启语音激励
  ///
  /// [enable] true-开启，false-关闭
  void enableSpeakerSpotlight(bool enable) {
    _writeSettings(Keys.isSpeakerSpotlightEnabled, enable);
  }

  /// 查询是否打开语音激励
  Future<bool> isSpeakerSpotlightEnabled() async {
    await ensureSettings();
    return Future.value(_settingsCache[Keys.isSpeakerSpotlightEnabled] ?? true);
  }

  /// 设置是否打开前置摄像头镜像
  ///
  /// [enable] true-打开，false-关闭
  Future<void> enableFrontCameraMirror(bool enable) async {
    _writeSettings(Keys.isFrontCameraMirrorEnabled, enable);
  }

  /// 查询前置摄像头镜像是否打开
  Future<bool> isFrontCameraMirrorEnabled() async {
    await ensureSettings();
    return Future.value(
        (_settingsCache[Keys.isFrontCameraMirrorEnabled] as bool?) ?? true);
  }

  /// 设置是否打开白板透明
  ///
  /// [enable] true-打开，false-关闭
  Future<void> enableTransparentWhiteboard(bool enable) async {
    _writeSettings(Keys.isTransparentWhiteboardEnabled, enable);
  }

  /// 查询白板透明是否打开
  Future<bool> isTransparentWhiteboardEnabled() async {
    await ensureSettings();
    return Future.value(
        (_settingsCache[Keys.isTransparentWhiteboardEnabled] as bool?) ??
            false);
  }

  /// 查询应用是否支持美颜
  bool isBeautyFaceSupported() => sdkConfig.isBeautyFaceSupported;

  /// 获取当前美颜参数，关闭返回0
  Future<int> getBeautyFaceValue() async {
    _beautyFaceValue ??=
        max(_settingsCache[Keys.beautyFaceValue] as int? ?? 0, 0);
    return _beautyFaceValue!;
  }

  /// 设置美颜参数
  ///
  /// [value] 传入美颜等级，参数规则为[0,10]整数
  Future<void> setBeautyFaceValue(int value) async {
    if (_beautyFaceValue != value) {
      _beautyFaceValue = value;

      if (AccountRepository().getAccountInfo()?.isAnonymous == true) {
        return;
      }
      _writeSettings(Keys.beautyFaceValue, value);

      /// 两秒后，如果未继续发生变更保存美颜设置
      Future.delayed(Duration(seconds: 2)).then((value) {
        if (_beautyFaceValue == value) {
          saveSettingsApi(BeautySettings(beauty: Beauty(level: value)));
        }
      });
    }
  }

  /// 查询应用是否支持等候室
  bool isWaitingRoomSupported() => sdkConfig.isWaitingRoomSupported;

  /// 查询应用是否支持虚拟背景
  bool isVirtualBackgroundSupported() => sdkConfig.isVirtualBackgroundSupported;

  /// 是否支持同声传译
  NEInterpretationConfig getInterpretationConfig() =>
      sdkConfig.interpretationConfig;

  /// 是否支持预约会议指定成员
  NEScheduledMemberConfig getScheduledMemberConfig() =>
      sdkConfig.scheduledMemberConfig;

  /// 是否支持编辑昵称
  bool isNicknameUpdateSupported() => sdkConfig.isNicknameUpdateSupported;

  /// 是否支持编辑头像
  bool isAvatarUpdateSupported() => sdkConfig.isAvatarUpdateSupported;

  bool isCaptionsSupported() => sdkConfig.isCaptionsSupported;

  bool isTranscriptionSupported() => sdkConfig.isTranscriptionSupported;

  bool isGuestJoinSupported() => sdkConfig.isGuestJoinSupported;

  /// 查询应用session会议Id
  String getAppNotifySessionId() => sdkConfig.appNotifySessionId;

  /// 查询云录制配置
  Future<NECloudRecordConfig> getCloudRecordConfig() async {
    await ensureSettings();
    if (_settingsCache[Keys.cloudRecordConfig] == null) {
      return Future.value(NECloudRecordConfig(enable: false));
    }
    return Future.value(
        NECloudRecordConfig.fromJson(_settingsCache[Keys.cloudRecordConfig]));
  }

  /// 设置云录制配置
  Future<void> setCloudRecordConfig(NECloudRecordConfig config) {
    _writeSettings(Keys.cloudRecordConfig, config.toJson());
    return Future.value();
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
  static const String interpretationConfig = "interpretationConfig";
  static const String scheduledMemberConfig = "scheduledMemberConfig";
  static const String isAvatarUpdateSupported = "isAvatarUpdateSupported";
  static const String isNicknameUpdateSupported = "isNicknameUpdateSupported";
  static const String appNotifySessionId = "appNotifySessionId";
  static const String cloudRecordConfig = "cloudRecordConfig";
  static const String isCaptionsSupported = "isCaptionsSupported";
  static const String isTranscriptionSupported = "isTranscriptionSupported";
  static const String isGuestJoinSupported = "isGuestJoinSupported";
}
