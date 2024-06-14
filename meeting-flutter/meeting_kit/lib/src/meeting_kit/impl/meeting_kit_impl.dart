// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

mixin InitedInfo {
  String? get initedAppKey => initedConfig?.appKey ?? initedCorpInfo?.appKey;
  NEMeetingKitConfig? initedConfig;
  NEMeetingCorpInfo? initedCorpInfo;
}

class _NEMeetingKitImpl extends NEMeetingKit
    with InitedInfo, EventTrackMixin, WidgetsBindingObserver, _AloggerMixin {
  NEMeetingService meetingService = _NEMeetingServiceImpl();
  NEScreenSharingService screenSharingService = _NEScreenSharingServiceImpl();
  late final _NEAccountServiceImpl accountService = _NEAccountServiceImpl(this);
  _NESettingsServiceImpl settingsService = _NESettingsServiceImpl();
  NEPreMeetingService preMeetingService = _NEPreMeetingServiceImpl();
  NELiveMeetingService liveMeetingService = _NELiveMeetingServiceImpl();
  _NEMeetingInviteServiceImpl inviteService = _NEMeetingInviteServiceImpl();
  NEMeetingMessageChannelService messageChannelService =
      _NEMeetingMessageChannelServiceImpl();
  _NEContactsServiceImpl contactsService = _NEContactsServiceImpl();

  Map? assetServerConfig;

  NEMeetingLanguage? _userSetLanguage;
  ValueNotifier<Locale>? _localeNotifier;

  final NERoomKit _roomKit = NERoomKit.instance;

  Map<String, String>? sdkVersionsHeaders;

  _NEMeetingKitImpl() {
    ConnectivityManager();
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

  @override
  void didChangeLocales(List<Locale>? locales) {
    localeListenable.value = _determineLocale();
  }

  @override
  ValueNotifier<bool> get loginStatusChangeNotifier =>
      accountService._loginStatusChangeNotifier;

  @override
  NEMeetingKitConfig? get config => initedConfig;

  bool get isInitialized => initedAppKey != null;

  @override
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
    NEMeetingCorpInfo? corpInfo;
    if (config.appKey == null) {
      assert(config.corpCode != null || config.corpEmail != null);
      final corpInfoResult = await AuthRepository.getAppInfo(
        config.corpCode,
        config.corpEmail,
        baseUrl: config.serverUrl ??
            config.serverConfig?.meetingServerConfig?.meetingServer,
      );
      if (!corpInfoResult.isSuccess()) {
        return corpInfoResult;
      }
      corpInfo = corpInfoResult.nonNullData;
    }
    switchLanguage(config.language);
    final appKey = config.appKey ?? corpInfo!.appKey;
    await NERoomLogService().init();
    // 如果外部没有设置域名，则切换使用默认的域名
    final serverUrl = (config.serverUrl == null || config.serverUrl.isEmpty) &&
            config.serverConfig == null
        ? ServersConfig().defaultServerUrl
        : config.serverUrl;
    final initResult = await _roomKit.initialize(
      NERoomKitOptions(
        appKey: appKey,
        serverUrl: serverUrl,
        serverConfig: config.serverConfig?.roomKitServerConfig,
        extras: config.extras == null
            ? null
            : Map.fromEntries(config.extras!.entries
                .where((element) => element.value is String)).cast(),
      ),
    );
    if (initResult.isSuccess()) {
      initedConfig = config;
      initedCorpInfo = corpInfo;
      await ServiceRepository().initialize(
        appKey,
        MeetingServerConfig.parse(
            config.serverConfig?.meetingServerConfig?.meetingServer ??
                config.serverUrl ??
                config.extras?['serverUrl']),
        config.extras,
      );
      SDKConfig.current.dispose();
      SDKConfig.current = SDKConfig(appKey)..initialize();
      settingsService.sdkConfig = SDKConfig.current;
      if (sdkVersionsHeaders == null) {
        _roomKit.sdkVersions.then((value) {
          if (sdkVersionsHeaders == null) {
            sdkVersionsHeaders = {
              'imVer': value.imVersion,
              'rtcVer': value.rtcVersion,
              'wbVer': value.whiteboardVersion,
              'roomKitVer': value.roomKitVersion,
              'fltRoomKitVer': value.fltRoomKitVersion,
              'meetingVer': SDKConfig.sdkVersionName,
              'framework': 'Flutter',
            };
            HttpHeaderRegistry().addContributor(() => sdkVersionsHeaders!);
          }
        });
      }
    }
    commonLogger.i('initialize result: $initResult');
    return initResult.map(() => corpInfo);
  }

  @override
  Future<NEResult<void>> switchLanguage(NEMeetingLanguage? language) async {
    apiLogger.i('switch language: ${language?.locale}');
    final result = await NERoomKit.instance
        .switchLanguage(language?.roomLang ?? NERoomLanguage.automatic);
    if (result.isSuccess()) {
      _userSetLanguage = language;
      localeListenable.value = _determineLocale();
    }
    return result;
  }

  @override
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
  Future<NEResult<void>> loginWithToken(String accountId, String token) async {
    return accountService.loginByToken(
      accountId,
      token,
    );
  }

  @override
  Future<NEResult<void>> loginWithNEMeeting(
      String username, String password) async {
    return accountService.loginByPassword(username, password);
  }

  @override
  Future<NEResult<void>> anonymousLogin() async {
    apiLogger.i('anonymousLogin');
    return accountService.anonymousLogin();
  }

  @override
  Future<NEResult<void>> tryAutoLogin() async {
    apiLogger.i('tryAutoLogin');
    return accountService.tryAutoLogin();
  }

  @override
  NEMeetingService getMeetingService() => meetingService;

  @override
  NEMeetingInviteService getMeetingInviteService() => inviteService;

  @override
  NEMeetingMessageChannelService getMeetingMessageChannelService() =>
      messageChannelService;

  @override
  NEScreenSharingService getScreenSharingService() => screenSharingService;

  @override
  NEAccountService getAccountService() => accountService;

  @override
  NESettingsService getSettingsService() => settingsService;

  @override
  NEPreMeetingService getPreMeetingService() => preMeetingService;

  @override
  NEContactsService getContactsService() => contactsService;

  @override
  Future<NEResult<void>> logout() async {
    apiLogger.i('logout');
    return accountService.logout();
  }

  @override
  void addAuthListener(NEAuthListener listener) {
    apiLogger.i('addAuthListener $listener');
    accountService.addListener(listener);
  }

  @override
  void removeAuthListener(NEAuthListener listener) {
    apiLogger.i('removeAuthListener $listener');
    accountService.addListener(listener);
  }

  @override
  Future<NEResult<String?>> uploadLog() {
    return _roomKit.uploadLog();
  }

  @override
  Future<String> get deviceId => NERoomKit.instance.deviceId;

  @override
  Future<bool> reportEvent(Event event, {String? userId}) {
    final appKey = initedAppKey;
    if (appKey == null) return Future.value(false);
    return _roomKit.reportEvent({
      'appKey': appKey,
      'component': _kComponent,
      'version': _kVersion,
      'framework': _kFramework,
      'userId': userId ?? accountService.getAccountInfo()?.userUuid,
      'nickname': userId ?? accountService.getAccountInfo()?.nickname,
      'eventId': event.eventId,
      'priority': event.priority.index,
      'eventData': event.toMap(),
    });
  }

  @override
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

  @override
  Future<NEResult<NEMeetingAppNoticeTips>> getAppNoticeTips() {
    return MeetingRepository.getSecurityNotice(
        DateTime.now().millisecondsSinceEpoch.toString());
  }

  @override
  Future<String?> getSDKLogPath() {
    return NERoomKit.instance.logPath;
  }
}

NEResult<void> _handleMeetingResultCode(int code, [String? msg]) {
  final localizations = NEMeetingKit.instance.localizations;
  if (code == MeetingErrorCode.success) {
    return NEResult<void>(code: NEMeetingErrorCode.success, msg: msg);
  } else if (code == MeetingErrorCode.meetingAlreadyExists ||
      code == MeetingErrorCode.meetingAlreadyStarted) {
    return NEResult<void>(
        code: NEMeetingErrorCode.meetingAlreadyExist, msg: msg);
  } else if (code == MeetingErrorCode.networkError) {
    return NEResult<void>(
        code: NEMeetingErrorCode.noNetwork,
        msg: localizations.networkUnavailableCheck);
  } else if (code == MeetingErrorCode.unauthorized) {
    return NEResult<void>(
        code: NEMeetingErrorCode.noAuth,
        msg: msg ?? localizations.unauthorized);
  } else if (code == MeetingErrorCode.roomLock) {
    return NEResult<void>(
        code: NEMeetingErrorCode.meetingLocked,
        msg: localizations.meetingLocked);
  } else if (code == MeetingErrorCode.meetingNotInProgress) {
    return NEResult<void>(
        code: NEMeetingErrorCode.meetingNotInProgress,
        msg: localizations.meetingNotExist);
  } else if (code == NEMeetingErrorCode.meetingNotExist) {
    return NEResult<void>(
        code: NEMeetingErrorCode.meetingNotExist,
        msg: localizations.meetingNotExist);
  } else {
    return NEResult<void>(code: code, msg: msg);
  }
}
