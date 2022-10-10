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
  static const String sdkVersionName = '3.5.0';
  static const int sdkVersionCode = 30500;
  static const String sdkType = 'official'; //pub

  static const _tag = 'SDKConfig';
  static const int getSdkConfigRetryTime = 3; // 请求sdkConfig失败重试最大次数
  static const periodicRefreshConfigTime =
      const Duration(hours: 1); // 定时刷新sdkConfig时间

  static String? _appKey;
  static bool _initialized = false;
  static bool _periodicRefreshTaskScheduled = false;

  static final StreamController<bool> _initNotify =
      StreamController.broadcast();

  static Stream<bool> get initNotifyStream => _initNotify.stream;

  static SDKConfig instance = SDKConfig._();

  SDKConfig._() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (!_initialized &&
          result != ConnectivityResult.none &&
          _appKey != null) {
        _doFetchConfig(_appKey!);
      }
    });
  }

  static void _schedulePeriodicRefreshConfigTask() {
    if (_periodicRefreshTaskScheduled) {
      return;
    }
    _periodicRefreshTaskScheduled = true;
    Timer.periodic(periodicRefreshConfigTime, (Timer timer) {
      if (_appKey != null) {
        _doFetchConfig(_appKey!, forceRefresh: true);
      }
    });
  }

  static Future<bool> initialize(String appKey) async {
    return _doFetchConfig(appKey);
  }

  static Future<bool> _doFetchConfig(String appKey,
      {bool forceRefresh = false}) async {
    if (TextUtils.isEmpty(appKey)) {
      return false;
    }
    if (_appKey == appKey && _initialized && !forceRefresh) {
      return true;
    }
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'initialize: version=$sdkVersionName type=$sdkType');
    _appKey = appKey;
    for (var index = 0; index < getSdkConfigRetryTime; ++index) {
      var sdkGlobalConfig = await HttpApiHelper._getSDKGlobalConfig(appKey);
      if (_appKey != appKey) return false;
      if (sdkGlobalConfig.code == MeetingErrorCode.success) {
        Alog.i(
            tag: _tag,
            moduleName: _moduleName,
            content: 'SDKConfig initialize success');
        var globalConfig = sdkGlobalConfig.data;
        instance.configs.clear();
        instance.configs.addAll(globalConfig!.configs);
        _initialized = true;
        _initNotify.add(true);
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
    return false;
  }

  Map configs = {};

  /// 切换焦点视频的间隔（单位：s）
  static int get focusSwitchInterval =>
      (instance.configs['focusSwitchInterval'] ?? 5) as int;

  /// 订阅视频流个数 (deviceType相关
  static int get videoStreamCount =>
      (instance.configs['videoStreamCount'] ?? 0) as int;

  /// 画廊单页显示数量 (clientType相关)
  static int get galleryPageSize =>
      (instance.configs['galleryPageSize'] ?? 4) as int;

  /// 会议音频录制开启，true：开启，false：关闭，true由服务器抄送给应用的回调接口
  static bool get meetingRecordAudioEnable =>
      (instance.configs['meetingRecordAudioEnable'] ?? false) as bool;

  /// 会议视频录制开启，true：开启，false：关闭，true由服务器抄送给应用的回调接口
  static bool get meetingRecordVideoEnable =>
      (instance.configs['meetingRecordVideoEnable'] ?? false) as bool;

  /// 会议录制模式，0：混合与单人，1：混合，2：单人，但只在有值的时候，才会由服务器抄送给应用的回调接口
  static int get meetingRecordMode =>
      (instance.configs['meetingRecordMode'] ?? 0) as int;

  /// 美颜参数配置：证书，开关状态
  static BeautyGlobalConfig get beauty =>
      BeautyGlobalConfig.fromJson(_functionConfig('beauty'));

  /// 直播开关状态
  static FunBaseConfig get live =>
      FunBaseConfig.fromJson(_functionConfig('meetingLive'));

  /// 白板版本配置
  static WhiteBoardGlobalConfig get whiteboardConfig =>
      WhiteBoardGlobalConfig.fromJson(_functionConfig('whiteboard'));

  /// app config
  static AppRoomResConfig get appRoomResConfig =>
      AppRoomResConfig.fromJson(_config('APP_ROOM_RESOURCE'));

  /// 聊天室
  static MeetingChatroomServerConfig get meetingChatroomConfig =>
      MeetingChatroomServerConfig.fromJson(_config('MEETING_CHATROOM'));

  /// 美颜
  static MeetingBeautyConfig get meetingBeautyConfig =>
      MeetingBeautyConfig.fromJson(_config('MEETING_BEAUTY'));

  /// 虚拟背景
  static MeetingFeatureConfig get meetingVirtualBackgroundConfig =>
      MeetingFeatureConfig.fromJson(_config('MEETING_VIRTUAL_BACKGROUND'));

  /// 最大时长快到时间时进行提示
  static MeetingFeatureConfig get meetingEndTimeTipConfig =>
      MeetingFeatureConfig.fromJson(_config('ROOM_END_TIME_TIP'),
          fallback: true);

  /// 会议录制开关状态
  static FunBaseConfig get meetingRecord =>
      FunBaseConfig.fromJson(_functionConfig('meetingRecord'));

  /// 会议聊天室开关状态
  static FunBaseConfig get meetingChat =>
      FunBaseConfig.fromJson(_functionConfig('chatroom'));

  static FunBaseConfig get sip =>
      FunBaseConfig.fromJson(_functionConfig('sip'));

  static Map<String, dynamic> _functionConfig(String function) {
    var config = instance.configs['functionConfigs'] ?? {};
    return (config[function] ?? <String, dynamic>{}) as Map<String, dynamic>;
  }

  static Map<String, dynamic> _config(String function) {
    var config = instance.configs['appConfig'] ?? {};
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

// class MeetingLiveConfig extends FunBaseConfig {
//   MeetingLiveConfig.fromJson(Map<String, dynamic> json) : super.fromJson(json);

//   @override
//   BaseConfig fromJson(Map<String, dynamic>? config) {
//     return BaseConfig.fromJson(config);
//   }
// }

// class MeetingWhiteBoardConfig extends FunBaseConfig {
//   MeetingWhiteBoardConfig.fromJson(Map<String, dynamic> json)
//       : super.fromJson(json);

//   @override
//   BaseConfig fromJson(Map<String, dynamic>? config) {
//     return BaseConfig.fromJson(config);
//   }
// }

// class MeetingRecordConfig extends FunBaseConfig {
//   MeetingRecordConfig.fromJson(Map<String, dynamic> json)
//       : super.fromJson(json);

//   @override
//   BaseConfig fromJson(Map<String, dynamic>? config) {
//     return BaseConfig.fromJson(config);
//   }
// }

// class MeetingChatConfig extends FunBaseConfig {
//   MeetingChatConfig.fromJson(Map<String, dynamic> json)
//       : super.fromJson(json);

//   @override
//   BaseConfig fromJson(Map<String, dynamic>? config) {
//     return BaseConfig.fromJson(config);
//   }
// }
