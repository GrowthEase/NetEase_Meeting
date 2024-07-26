// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 'focusSwitchInterval' [int] 切换焦点视频的间隔（单位：s）
/// 'videoStreamCount' [int] 订阅视频流个数 (deviceType相关)未单独设置返回默认值
/// 'galleryPageSize' [int] 画廊单页显示数量 (clientType相关)
class SDKConfig with _AloggerMixin {
  ///android version修改对应packages/meeting_sdk_android/gradle.properties的内容
  ///iOS version修改packages/meeting_sdk_ios/NEMeetingScript/spec/NEMeetingSDK.podspec的内容
  static const String sdkVersionName = '4.7.0';
  static const int sdkVersionCode = 40700;
  static const String sdkType = 'official'; //pub

  static const int getSdkConfigRetryTime = 3; // 请求sdkConfig失败重试最大次数
  static const periodicRefreshConfigTime =
      const Duration(hours: 1); // 定时刷新sdkConfig时间

  static final SDKConfig global = SDKConfig.forever();

  String? appKey;
  Timer? _timer;
  bool _periodicRefreshTaskScheduled = false;
  bool _disposed = false;
  final bool _canDispose;
  late Completer<void> _initCompleter;

  final StreamController<bool> _configUpdated = StreamController.broadcast();

  Stream<bool> get onConfigUpdated => _configUpdated.stream;

  Future<void> onInitialized() => _initCompleter.future;

  SDKConfig([String? appKey]) : _canDispose = true {
    updateAppKey(appKey);
  }

  SDKConfig.forever([String? appKey]) : _canDispose = false {
    updateAppKey(appKey);
  }

  void updateAppKey(String? appKey) {
    if (this.appKey != appKey && !_disposed) {
      commonLogger.i('updateAppKey: $appKey');
      this.appKey = appKey;
      _initCompleter = Completer<void>();
      _cancelPeriodicRefreshConfigTask();
      _updateConfigs({});
      _doFetchConfig();
    }
  }

  void dispose() {
    if (!_canDispose) return;
    _disposed = true;
    _configUpdated.close();
    _timer?.cancel();
  }

  void _cancelPeriodicRefreshConfigTask() {
    _timer?.cancel();
    _periodicRefreshTaskScheduled = false;
  }

  void _schedulePeriodicRefreshConfigTask() {
    if (_periodicRefreshTaskScheduled) {
      return;
    }
    _periodicRefreshTaskScheduled = true;
    _timer = Timer.periodic(periodicRefreshConfigTime, (Timer timer) {
      _doFetchConfig();
    });
  }

  Future<bool> _doFetchConfig() async {
    final currentAppKey = this.appKey;
    if (currentAppKey == null || currentAppKey.isEmpty || _disposed) {
      return false;
    }
    bool isInterrupted() {
      return currentAppKey != this.appKey || _disposed;
    }

    for (var index = 0; index < getSdkConfigRetryTime; ++index) {
      await _ensureNetwork();
      if (isInterrupted()) return false;
      var sdkGlobalConfig =
          await HttpApiHelper._getSDKGlobalConfig(currentAppKey);
      if (isInterrupted()) return false;
      if (sdkGlobalConfig.code == MeetingErrorCode.success) {
        commonLogger.i('fetch sdk config success');
        var globalConfig = sdkGlobalConfig.data;
        _updateConfigs(globalConfig!.configs);
        _schedulePeriodicRefreshConfigTask();
        if (!_initCompleter.isCompleted) {
          _initCompleter.complete();
        }
        return true;
      } else {
        commonLogger.e(
            'get global config error: code=${sdkGlobalConfig.code}, index=$index');
        await Future.delayed(Duration(seconds: pow(2, index + 1).toInt()));
      }
    }
    return false;
  }

  Future _ensureNetwork() async {
    if ((await Connectivity().checkConnectivity()).any((connectivityResult) =>
        connectivityResult == ConnectivityResult.none)) {
      await Connectivity().onConnectivityChanged.firstWhere((elements) =>
          elements.every((connectivityResult) =>
              connectivityResult != ConnectivityResult.none));
    }
  }

  Map _configs = {};
  void _updateConfigs(Map configs) {
    if (_configs.isNotEmpty || configs.isNotEmpty) {
      _configs.clear();
      _configs.addAll(configs);
      _configUpdated.add(true);
    }
  }

  /// 是否支持编辑昵称
  bool get isNicknameUpdateSupported =>
      !(_config('MEETING_ACCOUNT_CONFIG')['nicknameUpdateDisabled'] ?? false);

  /// 是否禁止编辑头像
  bool get isAvatarUpdateSupported =>
      !(_config('MEETING_ACCOUNT_CONFIG')['avatarUpdateDisabled'] ?? false);

  /// 切换焦点视频的间隔（单位：s）
  int get focusSwitchInterval => (_configs['focusSwitchInterval'] ?? 2) as int;

  /// 订阅视频流个数 (deviceType相关
  int get videoStreamCount => (_configs['videoStreamCount'] ?? 0) as int;

  /// 画廊单页显示数量 (clientType相关)
  int get galleryPageSize => (_configs['galleryPageSize'] ?? 4) as int;

  /// app config
  AppRoomResConfig get _appRoomResConfig =>
      AppRoomResConfig.fromJson(_config('APP_ROOM_RESOURCE'));
  bool get isSipSupported => _appRoomResConfig.sip;
  bool get isLiveSupported => _appRoomResConfig.live;
  bool get isWhiteboardSupported => _appRoomResConfig.whiteboard;
  bool get isCloudRecordSupported => _appRoomResConfig.record;
  bool get isMeetingChatSupported => _appRoomResConfig.chatRoom;
  bool get isWaitingRoomSupported => _appRoomResConfig.waitingRoom;
  bool get isSipInviteSupported => _appRoomResConfig.sipInvite;
  bool get isCaptionsSupported => _appRoomResConfig.caption;
  bool get isTranscriptionSupported => _appRoomResConfig.transcription;

  /// 是否支持访客入会，默认打开
  bool get isGuestJoinSupported => _appRoomResConfig.guest;

  /// 是否支持同声传译
  NEInterpretationConfig get interpretationConfig =>
      _appRoomResConfig.interpretation;

  /// 屏幕共享配置
  NEScreenShareConfig get screenShareConfig => _appRoomResConfig.screenShare;

  /// 预约会议指定成员配置
  NEScheduledMemberConfig get scheduledMemberConfig =>
      NEScheduledMemberConfig.fromJson(
          _config('MEETING_SCHEDULED_MEMBER_CONFIG'));

  /// 获取拨号入会的呼入号码
  String? get inboundPhoneNumber {
    final appConfigs = _configs['appConfig'] as Map?;
    return appConfigs?['inboundPhoneNumber'] as String?;
  }

  /// SIP外呼显示号码
  String? get outboundPhoneNumber {
    final appConfigs = _configs['appConfig'] as Map?;
    return appConfigs?['outboundPhoneNumber'] as String?;
  }

  /// 会话Id
  String get appNotifySessionId => switch (_configs['appConfig']) {
        {'notifySenderAccid': String notifySessionId} => notifySessionId,
        _ => '',
      };

  /// 聊天室
  MeetingChatroomServerConfig get meetingChatroomConfig =>
      MeetingChatroomServerConfig.fromJson(_config('MEETING_CHATROOM'));

  /// 美颜
  MeetingBeautyConfig get _meetingBeautyConfig =>
      MeetingBeautyConfig.fromJson(_config('MEETING_BEAUTY'));
  bool get isBeautyFaceSupported => _meetingBeautyConfig.enable;

  /// 视频跟随
  MeetingViewOrderConfig get _meetingViewOrderConfig =>
      MeetingViewOrderConfig.fromJson(_config('ROOM_VIEW_ORDER'));
  bool get isViewOrderSupported => _meetingViewOrderConfig.enable;

  /// 虚拟背景
  MeetingFeatureConfig get _meetingVirtualBackgroundConfig =>
      MeetingFeatureConfig.fromJson(_config('MEETING_VIRTUAL_BACKGROUND'));
  bool get isVirtualBackgroundSupported =>
      _meetingVirtualBackgroundConfig.enable;

  /// 最大时长快到时间时进行提示
  MeetingFeatureConfig get _meetingEndTimeTipConfig =>
      MeetingFeatureConfig.fromJson(_config('ROOM_END_TIME_TIP'),
          fallback: true);
  bool get isMeetingEndTimeTipSupported => _meetingEndTimeTipConfig.enable;

  /// 会议设置，是否支持音频设备切换，默认开启
  bool get isAudioDeviceSwitchEnabled =>
      getConfig('meetingSettingsConfig')?['enableAudioDeviceSwitch'] ?? true;

  /// 静音时关闭音频流Pub通道，默认为true
  MeetingFeatureConfig get unpubAudioOnMuteConfig =>
      MeetingFeatureConfig.fromJson(_config('UNPUB_AUDIO_ON_MUTE'),
          fallback: true);

  dynamic getConfig(String configName) {
    final extrasConfig = _config('MEETING_CLIENT_CONFIG');
    return extrasConfig[configName];
  }

  Map<String, dynamic> _config(String function) {
    var config = _configs['appConfig'] ?? {};
    return (config[function] ?? <String, dynamic>{}) as Map<String, dynamic>;
  }
}

/// 全局配置
/// 'deviceConfig'[Object] 返回与客户端类型与设备型号相匹配的参数配置，若clientType未匹配则不返回
class _SDKGlobalConfig {
  Map configs = {};

  static _SDKGlobalConfig? fromJson(Map? map) {
    if (map == null) {
      return null;
    }
    var info = _SDKGlobalConfig();
    var deviceConfig = (map.remove('deviceConfig') ?? {}) as Map;
    info.configs.addAll(map);
    info.configs.addAll(deviceConfig);
    return info;
  }
}

/// 对应服务端config接口返回的APP_ROOM_RESOURCE
/// https://office.netease.com/doc/?identity=67f6ea157eae470c9c2f9a7ebd09ee38
/// GET https://{domain}/scene/meeting/{appId}/v1/config HTTP/1.1
class AppRoomResConfig {
  /// 白板功能开关
  late final bool whiteboard;

  /// 聊天室功能开关
  late final bool chatRoom;

  /// 直播功能开关
  late final bool live;
  late final bool rtc;

  /// 云录制功能开关
  late final bool record;

  /// sip 功能开关
  late final bool sip;

  /// 等候室功能开关
  late final bool waitingRoom;

  /// sip 邀请功能开关
  late final bool sipInvite;

  /// 访客入会功能开关
  late final bool guest;

  /// 字幕功能开关
  late final bool caption;

  /// 转写功能开关
  late final bool transcription;

  /// 同声传译功能开关
  late final NEInterpretationConfig interpretation;

  /// 屏幕共享配置
  late final NEScreenShareConfig screenShare;

  /// 应用开关配置
  AppRoomResConfig.fromJson(Map<String, dynamic>? json) {
    whiteboard = (json?['whiteboard'] ?? false) as bool;
    chatRoom = (json?['chatroom'] ?? true) as bool;
    live = (json?['live'] ?? false) as bool;
    rtc = (json?['rtc'] ?? false) as bool;
    record = (json?['record'] ?? false) as bool;
    sip = (json?['sip'] ?? false) as bool;
    waitingRoom = (json?['waitingRoom'] ?? false) as bool;
    sipInvite = (json?['sipInvite'] ?? false) as bool;
    guest = (json?['guest'] ?? true) as bool;
    caption = (json?['caption'] ?? false) as bool;
    transcription = (json?['transcript'] ?? false) as bool;
    interpretation = switch (json?['interpretation']) {
      Map interpretation => NEInterpretationConfig.fromJson(interpretation),
      _ => const NEInterpretationConfig(),
    };
    screenShare = switch (json?['screenShare']) {
      Map screenShare => NEScreenShareConfig.fromJson(screenShare),
      _ => const NEScreenShareConfig(enable: true),
    };
  }
}

/// 通用功能相关配置
class MeetingFeatureConfig {
  bool enable = false;

  MeetingFeatureConfig.fromJson(Map<String, dynamic>? json,
      {bool fallback = false}) {
    enable = json?['enable'] ?? fallback;
  }
}

/// 跟随主持人视图模式相关配置
class MeetingViewOrderConfig {
  late bool enable;

  MeetingViewOrderConfig.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      enable = json['enable'] ?? false;
    }
  }
}

/// 美颜相关配置
class MeetingBeautyConfig {
  late bool enable;

  MeetingBeautyConfig.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      enable = json['enable'] ?? false;
    }
  }
}

/// 美颜等级对应config levels
class BeautyLevel {
  late int level;
  late double originFilter;
  late double color;
  late double red;
  late double blur;
  late double eye;
  BeautyLevel.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      level = json['level'];
      originFilter = json['originFilter'];
      color = json['color'];
      red = json['red'];
      blur = json['blur'];
      eye = json['eye'];
    }
  }
}

class MeetingChatroomServerConfig {
  ///
  /// 是否允许发送/接收文件消息，默认打开。
  ///
  final bool enableFileMessage;

  ///
  /// 是否允许发送/接收图片消息，默认打开。
  ///
  final bool enableImageMessage;

  MeetingChatroomServerConfig({
    this.enableFileMessage = true,
    this.enableImageMessage = true,
  });

  factory MeetingChatroomServerConfig.fromJson(Map? json) {
    return MeetingChatroomServerConfig(
      enableFileMessage: json.getOrDefault('enableFileMessage', true) ?? true,
      enableImageMessage: json.getOrDefault('enableImageMessage', true) ?? true,
    );
  }
}

class BaseConfig {
  late bool enable;

  BaseConfig.fromJson(Map<String, dynamic>? json) {
    enable = json != null ? json['enable'] == true : false;
  }

  Map<String, dynamic> toJson() => {'enable': enable};
}

class FunBaseConfig {
  int? _status;
  int? expireAt;

  BaseConfig? config;

  FunBaseConfig.fromJson(Map<String, dynamic> json) {
    _status = json['status'] as int?;
    expireAt = json['expireAt'] as int?;
    config = fromJson(json['config'] as Map<String, dynamic>?);
  }

  int get status => _status ?? 0;

  BaseConfig fromJson(Map<String, dynamic>? config) {
    return BaseConfig.fromJson(config);
  }

  Map<String, dynamic> toJson() => {
        'status': _status,
        'expireAt': expireAt,
        if (config != null) 'config': config!.toJson()
      };
}

class BeautyGlobalConfig extends FunBaseConfig {
  BeautyGlobalConfig.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  @override
  BaseConfig fromJson(Map<String, dynamic>? config) {
    return BeautyConfig.fromJson(config);
  }
}

class BeautyConfig extends BaseConfig {
  String? licenseUrl;
  String? md5;

  BeautyConfig.fromJson(Map<String, dynamic>? json) : super.fromJson(json) {
    if (json != null) {
      licenseUrl = json['licenseUrl'] as String;
      md5 = json['md5'] as String;
    }
  }

  @override
  Map<String, dynamic> toJson() =>
      {'licenseUrl': licenseUrl, 'md5': md5, ...super.toJson()};
}

/// 白板相关信息配置
class WhiteBoardGlobalConfig extends FunBaseConfig {
  WhiteBoardGlobalConfig.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);

  @override
  BaseConfig fromJson(Map<String, dynamic>? config) {
    return WhiteBoardConfig.fromJson(config);
  }
}

/// 白板版本配置信息
class WhiteBoardConfig extends BaseConfig {
  String? version;
  WhiteBoardConfig.fromJson(Map<String, dynamic>? json) : super.fromJson(json) {
    if (json != null && json['version'] != null) {
      version = json['version'] as String;
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'version': version,
      };
}

class NEScreenShareConfig {
  final bool enable;
  final String? message;

  NEScreenShareConfig.fromJson(Map json)
      : enable = json['enable'] == true,
        message = json['message'] as String?;

  const NEScreenShareConfig({this.enable = true, this.message});
}

/// 同声传译应用配置
class NEInterpretationConfig {
  /// 应用是否支持同声传译
  final bool isSupported;

  /// 同传译员最大数量
  final int maxInterpreters;

  /// 是否启用自定义语言
  final bool enableCustomLang;

  /// 自定义语言名称最大长度
  final int maxCustomLangNameLen;

  /// 默认主音频音量
  final int defMajorAudioVolume;

  const NEInterpretationConfig({
    bool? isSupported,
    int? maxInterpreters,
    bool? enableCustomLang,
    int? maxCustomLangNameLen,
    int? defMajorAudioVolume,
  })  : isSupported = isSupported ?? false,
        maxInterpreters = maxInterpreters ?? 10,
        maxCustomLangNameLen = maxCustomLangNameLen ?? 20,
        defMajorAudioVolume = defMajorAudioVolume ?? 20,
        enableCustomLang = enableCustomLang ?? false;

  factory NEInterpretationConfig.fromJson(Map map) {
    return NEInterpretationConfig(
      isSupported: map['enable'] ?? false,
      maxInterpreters: map['maxInterpreters'],
      enableCustomLang: map['enableCustomLang'],
      defMajorAudioVolume: map['defMajorAudioVolume'],
      maxCustomLangNameLen: map['maxCustomLanguageLength'],
    );
  }

  Map<String, dynamic> toJson() => {
        'isSupported': isSupported,
        'maxInterpreters': maxInterpreters,
        'enableCustomLang': enableCustomLang,
        'maxCustomLangNameLen': maxCustomLangNameLen,
        'defMajorAudioVolume': defMajorAudioVolume,
      };
}

/// 预约会议指定成员配置
class NEScheduledMemberConfig {
  /// 应用是否支持预约会议指定成员
  final bool isSupported;

  /// 预约会议指定成员最大数量
  final int scheduleMemberMax;

  /// 预约会议指定联席主持人最大数量
  final int coHostLimit;

  const NEScheduledMemberConfig({
    bool? isSupported,
    int? scheduleMemberMax,
    int? coHostLimit,
  })  : isSupported = isSupported ?? false,
        scheduleMemberMax = scheduleMemberMax ?? 300,
        coHostLimit = coHostLimit ?? 4;

  factory NEScheduledMemberConfig.fromJson(Map map) {
    return NEScheduledMemberConfig(
      isSupported: map['enable'] ?? false,
      scheduleMemberMax: map['max'],
      coHostLimit: map['coHostLimit'],
    );
  }

  Map<String, dynamic> toJson() => {
        'isSupported': isSupported,
        'scheduleMemberMax': scheduleMemberMax,
        'coHostLimit': coHostLimit,
      };
}
