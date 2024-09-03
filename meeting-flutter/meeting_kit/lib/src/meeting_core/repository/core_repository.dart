// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

///
/// 提供会议SDK初始化时必要的参数和配置信息
///
class NEMeetingKitConfig {
  ///
  /// 会议AppKey
  ///
  final String? appKey;

  /// 企业码，如果填写则会使用企业码进行初始化
  ///
  final String? corpCode;

  ///
  /// 企业邮箱，如果填写则会使用企业邮箱进行初始化
  ///
  final String? corpEmail;

  ///
  /// 应用名称，显示在会议页面的标题栏中
  ///
  final String? appName;

  ///
  /// Broadcast Upload Extension的App Group名称，iOS屏幕共享时使用
  ///
  final String? iosBroadcastAppGroup;

  ///
  /// 是否检查并使用asset资源目录下的私有化服务器配置文件，默认为false。
  ///
  final bool useAssetServerConfig;

  ///
  /// 前台服务配置
  ///
  final NEForegroundServiceConfig? foregroundServiceConfig;

  ///
  /// 默认语言
  ///
  final NEMeetingLanguage? language;

  ///
  /// 私有化地址
  ///
  final String? serverUrl;

  ///
  /// 额外字段
  ///
  final Map<String, dynamic>? extras;

  ///
  /// APNS推送证书名称（仅iOS有效）
  ///
  final String? apnsCerName;

  ///
  /// 通知推送配置
  ///
  final NEMeetingMixPushConfig? mixPushConfig;

  NEMeetingKitConfig({
    this.appName,
    this.appKey,
    this.corpCode,
    this.corpEmail,
    this.serverUrl,
    this.iosBroadcastAppGroup,
    this.foregroundServiceConfig,
    this.useAssetServerConfig = false,
    this.extras,
    this.language,
    this.apnsCerName,
    this.mixPushConfig,
  });

  @override
  bool operator ==(other) {
    if (other is! NEMeetingKitConfig) {
      return false;
    }
    return appKey == other.appKey &&
        corpCode == other.corpCode &&
        corpEmail == other.corpEmail &&
        serverUrl == other.serverUrl &&
        language == other.language &&
        appName == other.appName &&
        iosBroadcastAppGroup == other.iosBroadcastAppGroup &&
        useAssetServerConfig == other.useAssetServerConfig &&
        foregroundServiceConfig == other.foregroundServiceConfig &&
        mapEquals(extras, other.extras) &&
        apnsCerName == other.apnsCerName &&
        mixPushConfig == other.mixPushConfig;
  }

  @override
  int get hashCode => Object.hash(
        appKey,
        corpCode,
        corpEmail,
        appName,
        iosBroadcastAppGroup,
        useAssetServerConfig,
        foregroundServiceConfig,
        serverUrl,
        language,
        extras,
        apnsCerName,
        mixPushConfig,
      );

  String? get _initializeKey => appKey ?? corpCode ?? corpEmail;

  @override
  String toString() {
    return 'NEMeetingKitConfig{$_initializeKey, $serverUrl}';
  }
}

///
/// 提供会议通知推送配置
///
class NEMeetingMixPushConfig {
  /// 小米推送 appId
  final String? xmAppId;

  /// 小米推送 appKey
  final String? xmAppKey;

  /// 小米推送证书，请在云信管理后台申请
  final String? xmCertificateName;

  /// 华为推送 hwAppId
  final String? hwAppId;

  /// 华为推送证书，请在云信管理后台申请
  final String? hwCertificateName;

  /// 魅族推送 appId
  final String? mzAppId;

  /// 魅族推送 appKey
  final String? mzAppKey;

  /// 魅族推送证书，请在云信管理后台申请
  final String? mzCertificateName;

  /// FCM 推送证书，请在云信管理后台申请 海外客户使用
  final String? fcmCertificateName;

  /// VIVO推送 appId apiKey请在 AndroidManifest. xml 文件中配置 VIVO推送证书，请在云信管理后台申请
  final String? vivoCertificateName;

  /// oppo 推送appId
  final String? oppoAppId;

  /// oppo 推送appKey
  final String? oppoAppKey;

  /// oppo 推送AppSecret
  final String? oppoAppSecret;

  /// OPPO推送证书，请在云信管理后台申请
  final String? oppoCertificateName;

  /// 荣耀推送 appId，请在 AndroidManifest. xml 文件中配置 荣耀推送证书，请在云信管理后台申请
  final String? honorCertificateName;

  /// 是否根据token自动选择推送类型
  final bool autoSelectPushType;

  NEMeetingMixPushConfig({
    this.xmAppId,
    this.xmAppKey,
    this.xmCertificateName,
    this.hwAppId,
    this.hwCertificateName,
    this.mzAppId,
    this.mzAppKey,
    this.mzCertificateName,
    this.fcmCertificateName,
    this.vivoCertificateName,
    this.oppoAppId,
    this.oppoAppKey,
    this.oppoAppSecret,
    this.oppoCertificateName,
    this.honorCertificateName,
    this.autoSelectPushType = false,
  });

  factory NEMeetingMixPushConfig.fromJson(Map map) {
    return NEMeetingMixPushConfig(
      xmAppId: map['xmAppId'] as String?,
      xmAppKey: map['xmAppKey'] as String?,
      xmCertificateName: map['xmCertificateName'] as String?,
      hwAppId: map['hwAppId'] as String?,
      hwCertificateName: map['hwCertificateName'] as String?,
      mzAppId: map['mzAppId'] as String?,
      mzAppKey: map['mzAppKey'] as String?,
      mzCertificateName: map['mzCertificateName'] as String?,
      fcmCertificateName: map['fcmCertificateName'] as String?,
      vivoCertificateName: map['vivoCertificateName'] as String?,
      oppoAppId: map['oppoAppId'] as String?,
      oppoAppKey: map['oppoAppKey'] as String?,
      oppoAppSecret: map['oppoAppSecret'] as String?,
      oppoCertificateName: map['oppoCertificateName'] as String?,
      honorCertificateName: map['honorCertificateName'] as String?,
      autoSelectPushType: map['autoSelectPushType'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xmAppId': xmAppId,
      'xmAppKey': xmAppKey,
      'xmCertificateName': xmCertificateName,
      'hwAppId': hwAppId,
      'hwCertificateName': hwCertificateName,
      'mzAppId': mzAppId,
      'mzAppKey': mzAppKey,
      'mzCertificateName': mzCertificateName,
      'fcmCertificateName': fcmCertificateName,
      'vivoCertificateName': vivoCertificateName,
      'oppoAppId': oppoAppId,
      'oppoAppKey': oppoAppKey,
      'oppoAppSecret': oppoAppSecret,
      'oppoCertificateName': oppoCertificateName,
      'honorCertificateName': honorCertificateName,
      'autoSelectPushType': autoSelectPushType,
    };
  }
}

///
/// 组件支持的语言类型
///
class NEMeetingLanguage {
  static const automatic =
      NEMeetingLanguage._(Locale('*'), NERoomLanguage.automatic);
  static const chinese =
      NEMeetingLanguage._(Locale('zh', 'CN'), NERoomLanguage.chinese);
  static const english =
      NEMeetingLanguage._(Locale('en', 'US'), NERoomLanguage.english);
  static const japanese =
      NEMeetingLanguage._(Locale('ja', 'JP'), NERoomLanguage.japanese);

  final Locale locale;
  final NERoomLanguage roomLang;

  const NEMeetingLanguage._(this.locale, this.roomLang);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NEMeetingLanguage &&
          runtimeType == other.runtimeType &&
          locale == other.locale;

  @override
  int get hashCode => locale.hashCode;
}

/// SDK通用错误码
class NEMeetingErrorCode {
  /// 取消操作
  static const int cancelled = -9;

  /// SDK没有登录
  static const int noAuth = -7;

  /// 创建或加入会议失败，原因为当前已经处于一个会议中
  static const int alreadyInMeeting = -6;

  /// 接口调用失败，原因为参数错误
  static const int paramError = -5;

  /// 创建会议失败，原因为当前已经存在一个使用相同会议ID的会议。调用方此时可以加入该会议或者等待该会议结束后重新创建
  static const int meetingAlreadyExist = -4;

  /// 接口调用失败，原因为无网络连接
  static const int noNetwork = -3;

  /// 对应接口调用失败
  static const int failed = -1;

  /// 对应接口调用成功
  static const int success = MeetingErrorCode.success;

  ///
  /// 网络异常
  ///
  static const networkUnavailable = NEErrorCode.networkUnavailable;

  /// 开启了IM复用，请先登录IM
  static const int reuseIMNotLogin = NEErrorCode.reuseIMNotLogin;

  /// 开启了IM复用，IM账号不匹配
  static const int reuseIMAccountNotMatch = NEErrorCode.reuseIMAccountNotMatch;

  /// 企业不存在
  static const int corpNotFound = 1834;

  /// 账号需要重置密码才能允许登录
  static const int accountPasswordNeedReset = 3426;

  /// 企业不支持 SSO 登录
  static const int corpNotSupportSSO = 112002;

  /// IM复用不支持匿名加入会议
  static const int reuseIMNotSupportAnonymousLogin = 112001;

  /// ==================== ERROR CODE FROM SERVER ====================
  /// 会议被锁定
  static const int meetingLocked = NEErrorCode.roomLocked;

  /// 会议密码错误
  static const int badPassword = NEErrorCode.badPassword;

  /// 会议已回收
  static const int meetingRecycled = MeetingErrorCode.meetingRecycled;

  /// 会议不存在
  static const int meetingNotExist = MeetingErrorCode.meetingNotExists;

  /// room 不存在
  static const int meetingNotInProgress = NEErrorCode.roomNotExist;

  /// 鉴权过期，如密码重置
  static const int authExpired = NEErrorCode.authExpired;

  /// 聊天室不存在
  static const int chatroomNotExists = 110001;
}

final class CoreRepository with WidgetsBindingObserver, _AloggerMixin {
  static final CoreRepository _instance = CoreRepository._();

  factory CoreRepository() {
    return _instance;
  }

  final NERoomKit _roomKit = NERoomKit.instance;
  NEMeetingKitConfig? _initedConfig;
  NEMeetingCorpInfo? _initedCorpInfo;
  NEMeetingLanguage? _userSetLanguage;
  ValueNotifier<Locale>? _localeNotifier;
  Map<String, String>? _sdkVersionsHeaders;
  String? _feedbackServer;

  CoreRepository._() {
    HttpHeaderRegistry().addContributor(() {
      final appKey = initedAppKey;
      final languageTag = localeListenable.value.toLanguageTag();
      return {
        if (appKey != null) 'AppKey': appKey,
        if (languageTag != 'und') 'Accept-Language': languageTag,
      };
    });
    NERoomKit.instance.deviceId.then((value) {
      HttpHeaderRegistry().addContributor(() => {
            'deviceId': value,
          });
    });
    WidgetsBinding.instance.addObserver(this);
  }

  String get feedbackServer =>
      _feedbackServer ??
      "https://statistic.live.126.net/statics/report/common/form";

  Future<NEResult<NEMeetingCorpInfo?>> initialize(
      NEMeetingKitConfig config) async {
    apiLogger.i('initialize: $config');
    if (config == initedConfig) {
      return NEResult.successWith(initedCorpInfo);
    }
    if (config.appKey == null &&
        config.corpCode == null &&
        config.corpEmail == null) {
      return NEResult(
          code: NEMeetingErrorCode.paramError,
          msg: 'AppKey or corpCode or corpEmail is required');
    }

    _MeetingKitServerConfig? serverConfig;
    if (config.useAssetServerConfig) {
      try {
        final serverConfigJsonString = await NEMeetingPlugin()
            .getAssetService()
            .loadAssetAsString('xkit_server.config');
        if (serverConfigJsonString?.isEmpty ?? true) {
          commonLogger.e(
              '`useAssetServerConfig` is true, but `xkit_server.config` asset file is not exists or empty');
        } else {
          serverConfig = _MeetingKitServerConfig.fromJson(
              jsonDecode(serverConfigJsonString as String) as Map);
          _feedbackServer = serverConfig.meetingServerConfig?.feedbackServer;
        }
      } catch (e, s) {
        commonLogger.e('parse server config error: $e\n$s');
      }
    }

    NEMeetingCorpInfo? corpInfo;
    if (config.appKey == null) {
      assert(config.corpCode != null || config.corpEmail != null);
      final corpInfoResult = await AuthRepository.getAppInfo(
        config.corpCode,
        config.corpEmail,
        baseUrl: config.serverUrl ??
            serverConfig?.meetingServerConfig?.meetingServer,
      );
      if (!corpInfoResult.isSuccess()) {
        return corpInfoResult;
      }
      corpInfo = corpInfoResult.nonNullData;
    }
    if (config.language != null) {
      switchLanguage(config.language);
    }
    final appKey = config.appKey ?? corpInfo!.appKey;
    await _LogService().init();
    // 如果外部没有设置域名，则切换使用默认的域名
    final serverUrl = (config.serverUrl == null || config.serverUrl.isEmpty) &&
            serverConfig == null
        ? ServersConfig().defaultServerUrl
        : config.serverUrl;
    final initResult = await _roomKit.initialize(
      NERoomKitOptions(
        appKey: appKey,
        serverUrl: serverUrl,
        serverConfig: serverConfig?.roomKitServerConfig,
        extras: config.extras == null
            ? null
            : Map.fromEntries(config.extras!.entries
                .where((element) => element.value is String)).cast(),
        apnsCerName: config.apnsCerName,
        mixPushConfig: config.mixPushConfig != null
            ? NEMixPushConfig.fromJson(config.mixPushConfig!.toJson())
            : null,
      ),
    );
    if (initResult.isSuccess()) {
      _initedConfig = config;
      _initedCorpInfo = corpInfo;
      await ServiceRepository().initialize(
        appKey,
        MeetingServerConfig.parse(config.serverUrl ??
            serverConfig?.meetingServerConfig?.meetingServer ??
            config.extras?['serverUrl']),
        config.extras,
      );
      SDKConfig.global.updateAppKey(appKey);
      if (_sdkVersionsHeaders == null) {
        _roomKit.sdkVersions.then((value) {
          if (_sdkVersionsHeaders == null) {
            _sdkVersionsHeaders = {
              'imVer': value.imVersion,
              'rtcVer': value.rtcVersion,
              'wbVer': value.whiteboardVersion,
              'roomKitVer': value.roomKitVersion,
              'fltRoomKitVer': value.fltRoomKitVersion,
              'meetingVer': SDKConfig.sdkVersionName,
              'framework': 'Flutter',
            };
            HttpHeaderRegistry().addContributor(() => _sdkVersionsHeaders!);
          }
        });
      }
    }
    commonLogger.i('initialize result: $initResult');
    return initResult.map(() => corpInfo);
  }

  bool get isInitialized => _initedConfig != null;

  NEMeetingKitConfig? get initedConfig => _initedConfig;
  NEMeetingCorpInfo? get initedCorpInfo => _initedCorpInfo;

  String? get initedAppKey => _initedConfig?.appKey ?? _initedCorpInfo?.appKey;

  Future<NEResult<void>> switchLanguage(NEMeetingLanguage? language) async {
    apiLogger.i('switch language: ${language?.locale}');
    final result = await _roomKit
        .switchLanguage(language?.roomLang ?? NERoomLanguage.automatic);
    if (result.isSuccess()) {
      _userSetLanguage = language;
      localeListenable.value = _determineLocale();
    }
    return result;
  }

  NEMeetingLanguage get currentLanguage {
    final locale = _userSetLanguage == null ||
            _userSetLanguage == NEMeetingLanguage.automatic
        ? WidgetsBinding.instance.platformDispatcher.locale
        : _userSetLanguage!.locale;
    if (locale.languageCode == 'zh') {
      return NEMeetingLanguage.chinese;
    }
    if (locale.languageCode == 'ja') {
      return NEMeetingLanguage.japanese;
    }
    return NEMeetingLanguage.english;
  }

  ValueNotifier<Locale> get localeListenable {
    _localeNotifier ??= ValueNotifier(_determineLocale());
    return _localeNotifier!;
  }

  Locale _determineLocale() {
    final locale = _userSetLanguage == null ||
            _userSetLanguage == NEMeetingLanguage.automatic
        ? WidgetsBinding.instance.platformDispatcher.locale
        : _userSetLanguage!.locale;
    if (locale.languageCode == 'zh') {
      return NEMeetingLanguage.chinese.locale;
    }
    if (locale.languageCode == 'ja') {
      return NEMeetingLanguage.japanese.locale;
    }
    return NEMeetingLanguage.english.locale;
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    localeListenable.value = _determineLocale();
  }
}

class _MeetingServerConfig {
  static const _serverUrlKey = 'serverUrl';
  static const _feedbackServerUrlKey = 'feedbackUploadUrl';

  String? meetingServer;

  String? feedbackServer;

  _MeetingServerConfig();

  factory _MeetingServerConfig.fromJson(Map json) {
    return _MeetingServerConfig()
      ..meetingServer = json[_serverUrlKey] as String?
      ..feedbackServer = json[_feedbackServerUrlKey] as String?;
  }

  Map toJson() => {
        if (meetingServer != null) _serverUrlKey: meetingServer,
        if (feedbackServer != null) _feedbackServerUrlKey: feedbackServer,
      };
}

class _MeetingKitServerConfig {
  static const _meetingServerConfigKey = 'meeting';

  _MeetingServerConfig? meetingServerConfig;
  NEServerConfig? roomKitServerConfig;

  _MeetingKitServerConfig();

  _MeetingKitServerConfig.fromJson(Map json) {
    meetingServerConfig =
        _MeetingServerConfig.fromJson(json[_meetingServerConfigKey]);
    roomKitServerConfig = NEServerConfig.fromJson(json);
  }

  Map toJson() => {
        if (roomKitServerConfig != null) ...(roomKitServerConfig!.toJson()),
        if (meetingServerConfig != null)
          _meetingServerConfigKey: meetingServerConfig!.toJson(),
      };
}
