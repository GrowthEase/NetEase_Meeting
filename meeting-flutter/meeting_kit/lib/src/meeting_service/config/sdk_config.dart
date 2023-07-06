// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 'focusSwitchInterval' [int] 切换焦点视频的间隔（单位：s）
/// 'videoStreamCount' [int] 订阅视频流个数 (deviceType相关)未单独设置返回默认值
/// 'galleryPageSize' [int] 画廊单页显示数量 (clientType相关)
/// '''
/// {"code":0,"msg":"Success","ts":1648556746014,"cost":"50ms","requestId":"a303473a820f4413af04e690dff92191",
/// "data":{"appConfig":{
/// "APP_ROOM_RESOURCE":{"whiteboard":true,"chatroom":true,"live":true,"rtc":true}}}}
/// '''
class SDKConfig {
  ///android version修改对应packages/meeting_sdk_android/gradle.properties的内容
  ///iOS version修改packages/meeting_sdk_ios/NEMeetingScript/spec/NEMeetingSDK.podspec的内容
  static const String sdkVersionName = '3.14.0';
  static const int sdkVersionCode = 31400;
  static const String sdkType = 'official'; //pub

  static const _tag = 'SDKConfig';
  static const int getSdkConfigRetryTime = 3; // 请求sdkConfig失败重试最大次数
  static const periodicRefreshConfigTime =
      const Duration(hours: 1); // 定时刷新sdkConfig时间

  final String appKey;
  Timer? _timer;
  Completer<bool>? _initialized;
  bool _periodicRefreshTaskScheduled = false;
  bool _disposed = false;

  final StreamController<bool> _configUpdated = StreamController.broadcast();

  Stream<bool> get onConfigUpdated => _configUpdated.stream;

  static late SDKConfig current = SDKConfig('');

  SDKConfig(this.appKey);

  void _schedulePeriodicRefreshConfigTask() {
    if (_periodicRefreshTaskScheduled) {
      return;
    }
    _periodicRefreshTaskScheduled = true;
    _timer = Timer.periodic(periodicRefreshConfigTime, (Timer timer) {
      _doFetchConfig();
    });
  }

  Future<bool> initialize() async {
    Alog.i(
      tag: _tag,
      moduleName: _moduleName,
      content: 'initialize: version=$sdkVersionName type=$sdkType app=$appKey',
    );
    if (_initialized == null) {
      _initialized = Completer();
      _doFetchConfig();
    }
    return _initialized!.future;
  }

  void dispose() {
    _disposed = true;
    _configUpdated.close();
    _timer?.cancel();
    if (_initialized != null && !_initialized!.isCompleted) {
      _initialized!.complete(false);
    }
  }

  Future<bool> _doFetchConfig() async {
    if (TextUtils.isEmpty(appKey) || _disposed) {
      return false;
    }
    for (var index = 0; index < getSdkConfigRetryTime; ++index) {
      await ensureNetwork();
      if (_disposed) return false;
      var sdkGlobalConfig = await HttpApiHelper._getSDKGlobalConfig(appKey);
      if (_disposed) return false;
      if (sdkGlobalConfig.code == MeetingErrorCode.success) {
        Alog.i(
            tag: _tag,
            moduleName: _moduleName,
            content: 'fetch sdk config success');
        var globalConfig = sdkGlobalConfig.data;
        configs.clear();
        configs.addAll(globalConfig!.configs);
        if (_initialized != null && !_initialized!.isCompleted) {
          _initialized!.complete(true);
        }
        _configUpdated.add(true);
        _schedulePeriodicRefreshConfigTask();
        return true;
      } else {
        Alog.e(
            tag: _tag,
            moduleName: _moduleName,
            content:
                'get global config error: code=${sdkGlobalConfig.code}, index=$index');
        await Future.delayed(Duration(seconds: pow(2, index + 1).toInt()));
      }
    }
    ensureNetwork().then((value) => _doFetchConfig());
    return false;
  }

  Future ensureNetwork() async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      await Connectivity()
          .onConnectivityChanged
          .firstWhere((element) => element != ConnectivityResult.none);
    }
  }

  Map configs = {};

  /// 切换焦点视频的间隔（单位：s）
  int get focusSwitchInterval => (configs['focusSwitchInterval'] ?? 2) as int;

  /// 订阅视频流个数 (deviceType相关
  int get videoStreamCount => (configs['videoStreamCount'] ?? 0) as int;

  /// 画廊单页显示数量 (clientType相关)
  int get galleryPageSize => (configs['galleryPageSize'] ?? 4) as int;

  /// 美颜参数配置：证书，开关状态
  // BeautyGlobalConfig get beauty =>
  //     BeautyGlobalConfig.fromJson(_functionConfig('beauty'));

  /// 直播开关状态
  // FunBaseConfig get live =>
  //     FunBaseConfig.fromJson(_functionConfig('meetingLive'));

  /// 白板版本配置
  // WhiteBoardGlobalConfig get whiteboardConfig =>
  //     WhiteBoardGlobalConfig.fromJson(_functionConfig('whiteboard'));

  /// app config
  AppRoomResConfig get _appRoomResConfig =>
      AppRoomResConfig.fromJson(_config('APP_ROOM_RESOURCE'));
  bool get isSipSupported => _appRoomResConfig.sip;
  bool get isLiveSupported => _appRoomResConfig.live;
  bool get isWhiteboardSupported => _appRoomResConfig.whiteboard;
  bool get isCloudRecordSupported => _appRoomResConfig.record;
  bool get isMeetingChatSupported => _appRoomResConfig.chatRoom;

  /// 聊天室
  MeetingChatroomServerConfig get meetingChatroomConfig =>
      MeetingChatroomServerConfig.fromJson(_config('MEETING_CHATROOM'));

  /// 美颜
  MeetingBeautyConfig get _meetingBeautyConfig =>
      MeetingBeautyConfig.fromJson(_config('MEETING_BEAUTY'));
  bool get isBeautyFaceSupported => _meetingBeautyConfig.enable;

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

  /// 静音时关闭音频流Pub通道，默认为true
  MeetingFeatureConfig get unpubAudioOnMuteConfig =>
      MeetingFeatureConfig.fromJson(_config('UNPUB_AUDIO_ON_MUTE'),
          fallback: true);

  // Map<String, dynamic> _functionConfig(String function) {
  //   var config = configs['functionConfigs'] ?? {};
  //   return (config[function] ?? <String, dynamic>{}) as Map<String, dynamic>;
  // }

  Map<String, dynamic> _config(String function) {
    var config = configs['appConfig'] ?? {};
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
  late final bool whiteboard;
  late final bool chatRoom;
  late final bool live;
  late final bool rtc;
  late final bool record;
  late final bool sip;

  ///
  AppRoomResConfig.fromJson(Map<String, dynamic>? json) {
    whiteboard = (json?['whiteboard'] ?? false) as bool;
    chatRoom = (json?['chatroom'] ?? true) as bool;
    live = (json?['live'] ?? false) as bool;
    rtc = (json?['rtc'] ?? false) as bool;
    record = (json?['record'] ?? false) as bool;
    sip = (json?['sip'] ?? false) as bool;
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
      enableFileMessage: json.getOrDefault('enableFileMessage', true),
      enableImageMessage: json.getOrDefault('enableImageMessage', true),
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

  @mustCallSuper
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
