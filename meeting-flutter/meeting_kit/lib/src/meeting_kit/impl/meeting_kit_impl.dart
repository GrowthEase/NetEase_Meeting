// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEMeetingKitImpl extends NEMeetingKit
    with EventTrackMixin, WidgetsBindingObserver {
  static const _tag = '_NEMeetingKitImpl';
  static const _serverUrlExtraKey = 'serverUrl';

  NEMeetingKitConfig? _lastConfig;
  NEMeetingService meetingService = _NEMeetingServiceImpl();
  _NEMeetingAccountServiceImpl accountService = _NEMeetingAccountServiceImpl();
  _NESettingsServiceImpl settingsService = _NESettingsServiceImpl();
  NEPreMeetingService preMeetingService = _NEPreMeetingServiceImpl();
  NELiveMeetingService liveMeetingService = _NELiveMeetingServiceImpl();

  Map? assetServerConfig;

  NEMeetingLanguage? _userSetLanguage;
  ValueNotifier<Locale>? _localeNotifier;

  final _loginStatusChangeNotifier = ValueNotifier(false);

  final NERoomKit _roomKit = NERoomKit.instance;

  Map<String, String>? sdkVersionsHeaders;

  final Set<NEMeetingAuthListener> _authListenerSet = <NEMeetingAuthListener>{};

  _NEMeetingKitImpl() {
    HttpHeaderRegistry().addContributor(() {
      final appKey = config?.appKey;
      final languageTag = localeListenable.value.toLanguageTag();
      return {
        if (appKey != null) 'AppKey': appKey,
        if (languageTag != 'und') 'Accept-Language': languageTag,
      };
    });
    NERoomKit.instance.authService.onAuthEvent.listen((event) {
      if (event == NEAuthEvent.kKickOut) {
        _authListenerSet.toList().forEach((listener) => listener.onKickOut());
      } else if (event == NEAuthEvent.kTokenExpired) {
        _authListenerSet
            .toList()
            .forEach((listener) => listener.onAuthInfoExpired());
      }
    });
    NERoomKit.instance.messageChannelService.addMessageChannelCallback(
        NEMessageChannelCallback(onReceiveCustomMessage: (message) {
      if (message.commandId == 98 && message.roomUuid == null) {
        try {
          final data = jsonDecode(message.data);
          if (data['type'] == 200 && data['reason'] != null) {
            Alog.i(
                tag: _tag,
                moduleName: _moduleName,
                content: 'receive auth message: ${message.data}');
            _authListenerSet
                .toList()
                .forEach((listener) => listener.onAuthInfoExpired());
          }
        } catch (e) {}
      }
    }));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    localeListenable.value = _determineLocale();
  }

  @override
  ValueNotifier<bool> get loginStatusChangeNotifier =>
      _loginStatusChangeNotifier;

  @override
  NEMeetingKitConfig? get config => _lastConfig;

  @override
  Future<NEResult<void>> initialize(NEMeetingKitConfig config) async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content:
            'appKey:${config.appKey},_lastConfig appKey:"${_lastConfig?.appKey ?? '空'}');
    if (config.appKey == _lastConfig?.appKey) {
      return NEResult.success();
    }
    await NERoomLogService().init(loggerConfig: config.aLoggerConfig);
    // final serverUrlInExtras = config.extras?[_serverUrlExtraKey] as String?;
    final initResult = await _roomKit.initialize(
      NERoomKitOptions(
        appKey: config.appKey,
        serverUrl: config.serverUrl,
        serverConfig: config.serverConfig?.roomKitServerConfig,
        // extras: serverUrlInExtras.isNotEmpty
        //     ? {
        //         _serverUrlExtraKey: serverUrlInExtras as String,
        //       }
        //     : null,
        reuseIM: config.reuseIM,
      ),
    );
    if (initResult.isSuccess()) {
      _lastConfig = config;
      // MeetingCore().foregroundConfig = config.config;
      await ServiceRepository().initialize(
        config.appKey,
        MeetingServerConfig.parse(
            config.serverConfig?.meetingServerConfig?.meetingServer ??
                config.serverUrl),
        config.extras,
      );
      SDKConfig.initialize(config.appKey);
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
            };
            HttpHeaderRegistry().addContributor(() => sdkVersionsHeaders!);
          }
        });
      }
    }
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'initialize result: $initResult');
    return initResult;
  }

  @override
  Future<NEResult<void>> switchLanguage(NEMeetingLanguage? language) async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'switch language: ${language?.locale}');
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
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'loginWithToken accountId $accountId');
    return _loginWithAccountInfo(
        await AuthRepository.fetchAccountInfoByToken(accountId, token));
  }

  @override
  Future<NEResult<void>> loginWithNEMeeting(
      String username, String password) async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'loginWithNEMeeting');
    return _loginWithAccountInfo(
        await AuthRepository.fetchAccountInfoByPwd(username, password));
  }

  @override
  Future<NEResult<void>> anonymousLogin() async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'anonymousLogin');
    if (config?.reuseIM ?? false) {
      return NEResult(
        code: NEMeetingErrorCode.reuseIMNotSupportAnonymousLogin,
        msg: localizations.reuseIMNotSupportAnonymousLogin,
      );
    }
    return _loginWithAccountInfo(
        await MeetingRepository.anonymousLogin().map((p0) => NEAccountInfo(
              userUuid: p0.userUuid,
              userToken: p0.userToken,
            )),
        true);
  }

  NEResult<void> trackLoginResultEvent(NEResult<void> result) {
    if (result.code == MeetingErrorCode.success) {
      trackPeriodicEvent(TrackEventName.loginSdkSuccess);
    } else {
      trackPeriodicEvent(TrackEventName.loginSdkFailed,
          extra: {'value': result.code});
    }
    return result;
  }

  @override
  Future<NEResult<void>> tryAutoLogin() async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'tryAutoLogin');
    final loginInfo = await SDKPreferences.getLoginInfo();
    if (loginInfo != null && loginInfo.appKey == config?.appKey) {
      return loginWithToken(loginInfo.userUuid, loginInfo.userToken);
    }
    return NEResult(code: NEMeetingErrorCode.failed, msg: 'No login cache');
  }

  Future<VoidResult> _loginWithAccountInfo(
      NEResult<NEAccountInfo> accountInfoResult,
      [bool anonymous = false]) async {
    var info = accountInfoResult.data;
    if (info != null) {
      final loginResult = await NERoomKit.instance.authService
          .login(info.userUuid, info.userToken);
      if (loginResult.isSuccess()) {
        return loginResult.onSuccess(() {
          accountService._setAccountInfo(info, anonymous);
          if (!anonymous) {
            SDKPreferences.setLoginInfo(
                LoginInfo(config!.appKey, info.userUuid, info.userToken));
          }
          onLoginStatusMaybeChanged();
        });
      } else {
        return loginResult.onFailure((code, msg) {
          Alog.i(
              tag: _tag,
              moduleName: _moduleName,
              type: AlogType.api,
              content: '_loginWithAccountInfo code:$code , msg: $msg ');
        });
      }
    } else {
      return NEResult<void>(
          code: accountInfoResult.code, msg: accountInfoResult.msg);
    }
  }

  @override
  NEMeetingService getMeetingService() => meetingService;

  @override
  NEMeetingAccountService getAccountService() => accountService;

  @override
  NESettingsService getSettingsService() => settingsService;

  @override
  NEPreMeetingService getPreMeetingService() => preMeetingService;

  @override
  NELiveMeetingService getLiveMeetingService() => liveMeetingService;

  @override
  Future<NEResult<void>> logout() async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'logout');
    return NERoomKit.instance.authService.logout().onSuccess(() {
      accountService._setAccountInfo(null);
      SDKPreferences.setLoginInfo(null);
      onLoginStatusMaybeChanged();
    });
  }

  @override
  void addAuthListener(NEMeetingAuthListener listener) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'addAuthListener $listener');
    _authListenerSet.add(listener);
  }

  @override
  void removeAuthListener(NEMeetingAuthListener listener) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'removeAuthListener $listener');
    _authListenerSet.remove(listener);
  }

  void onLoginStatusMaybeChanged() {
    final old = _loginStatusChangeNotifier.value;
    final now = accountService.getAccountInfo() != null;
    Timer.run(() {
      _loginStatusChangeNotifier.value = now;
      if (old != now) {
        settingsService._ensureSettings();
      }
    });
  }
}
