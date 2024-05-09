// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEMeetingKitImpl extends NEMeetingKit
    with EventTrackMixin, WidgetsBindingObserver, _AloggerMixin {
  NEMeetingKitConfig? _lastConfig;
  NEMeetingService meetingService = _NEMeetingServiceImpl();
  NEScreenSharingService screenSharingService = _NEScreenSharingServiceImpl();
  _NEMeetingAccountServiceImpl accountService = _NEMeetingAccountServiceImpl();
  _NESettingsServiceImpl settingsService = _NESettingsServiceImpl();
  NEPreMeetingService preMeetingService = _NEPreMeetingServiceImpl();
  NELiveMeetingService liveMeetingService = _NELiveMeetingServiceImpl();
  NEMeetingNosService nosService = _NEMeetingNosServiceImpl();
  _NEMeetingInviteServiceImpl inviteService = _NEMeetingInviteServiceImpl();

  Map? assetServerConfig;

  NEMeetingLanguage? _userSetLanguage;
  ValueNotifier<Locale>? _localeNotifier;

  final _loginStatusChangeNotifier = ValueNotifier(false);

  final NERoomKit _roomKit = NERoomKit.instance;

  Map<String, String>? sdkVersionsHeaders;

  final Set<NEMeetingAuthListener> _authListenerSet = <NEMeetingAuthListener>{};
  final Set<NEMeetingMessageSessionListener> _sessionListenerSet =
      <NEMeetingMessageSessionListener>{};

  /// 缓存会议内的会话消息列表
  Map<int, Set<NEMeetingCustomSessionMessage>?> _sessionMessageMapCache = {};

  _NEMeetingKitImpl() {
    ConnectivityManager();
    HttpHeaderRegistry().addContributor(() {
      final appKey = config?.appKey;
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
    NERoomKit.instance.authService.onAuthEvent.listen((event) {
      if (event == NEAuthEvent.kKickOut) {
        _authListenerSet.toList().forEach((listener) => listener.onKickOut());
      } else if ({NEAuthEvent.kTokenExpired, NEAuthEvent.kIncorrectToken}
          .contains(event)) {
        notifyAuthInfoExpired();
      } else if (event == NEAuthEvent.kReconnected) {
        notifyReconnected();
      }
    });
    HttpErrorRepository()
        .onError
        .where((httpError) => httpError.code == NEMeetingErrorCode.authExpired)
        .listen((httpError) => notifyAuthInfoExpired());

    NERoomKit.instance.messageChannelService.addMessageChannelCallback(
        NEMessageChannelCallback(onReceiveCustomMessage: (message) {
      if (message.commandId == 98 && message.roomUuid == null) {
        try {
          final data = jsonDecode(message.data);
          if (data['type'] == 200 && data['reason'] != null) {
            commonLogger.i('receive auth message: ${message.data}');
            notifyAuthInfoExpired();
          }
        } catch (e) {}
      }
    }));

    NERoomKit.instance.messageChannelService
        .addReceiveSessionMessageCallback(NERoomMessageSessionCallback(
      onReceiveMessageSessionCallback: (message) {
        if (message.data != null) {
          try {
            final data = NotifyCardData.fromMap(jsonDecode(message.data!));
            commonLogger.i(
                'receive session message: ${message.data},_sessionListenerSet: ${_sessionListenerSet.length}');
            final customSessionMessage = NEMeetingCustomSessionMessage(
              sessionId: message.sessionId,
              sessionType: NEMeetingSessionTypeEnumExtension.toType(
                  message.sessionType?.index),
              messageId: message.messageId,
              data: data,
              time: message.time,
            );

            /// 处理App邀请消息
            /// timestamp 距离当前60内, 且当前无会议
            if (data.data?.type == NENotifyCenterCardType.meetingInvite &&
                data.data?.timestamp != null &&
                DateTime.now().millisecondsSinceEpoch - data.data!.timestamp! <
                    60 * 1000) {
              InviteQueueUtil.instance.pushInvite(data.data);
              var inviteInfoObj = NEMeetingInviteInfo.fromMap(
                  data.data?.inviteInfo?.toMap()); // 会议邀请信息
              inviteInfoObj.meetingNum = data.data?.meetingNum ?? '';

              /// 处理会议邀请消息,转移到邀请服务处理
              inviteService.listeners.forEach((element) {
                element.onMeetingInviteStatusChanged(
                    NEMeetingInviteStatus.calling,
                    data.data?.meetingId.toString(),
                    inviteInfoObj);
              });
              return;
            }

            /// 缓存会议内的插件消息
            if (data.data?.pluginId != null &&
                data.data?.meetingId != null &&
                data.data?.meetingId != 0) {
              _sessionMessageMapCache[data.data!.meetingId!] ??= {};
              _sessionMessageMapCache[data.data!.meetingId!]
                  ?.add(customSessionMessage);
            }
            for (var listener in _sessionListenerSet) {
              listener.onReceiveSessionMessage(customSessionMessage);
            }
          } catch (e) {}
        }
      },
      onRecentSessionChangeCallback:
          (List<NERoomRecentSession> recentSessionChangeMessageList) {
        commonLogger.i(
            'receive recent session message: $recentSessionChangeMessageList');
        for (var listener in _sessionListenerSet) {
          listener.onChangeRecentSession(recentSessionChangeMessageList
              .map((e) => NEMeetingRecentSession(
                    e.sessionId,
                    e.fromAccount,
                    e.fromNick,
                    NEMeetingSessionTypeEnumExtension.toType(
                        e.sessionType?.index),
                    e.recentMessageId,
                    e.unreadCount,
                    e.content,
                    e.time,
                  ))
              .toList());
        }
      },
    ));

    WidgetsBinding.instance.addObserver(this);
  }

  void notifyAuthInfoExpired() {
    _authListenerSet
        .toList()
        .forEach((listener) => listener.onAuthInfoExpired());
    logout();
  }

  /// 通知重连成功
  void notifyReconnected() {
    _authListenerSet.toList().forEach((listener) => listener.onReconnected());
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
    apiLogger.i('initialize: $config');
    if (config == _lastConfig) {
      return NEResult.success();
    }
    await NERoomLogService().init(loggerConfig: config.aLoggerConfig);
    // 如果外部没有设置域名，则切换使用默认的域名
    final serverUrl = (config.serverUrl == null || config.serverUrl.isEmpty) &&
            config.serverConfig == null
        ? ServersConfig().defaultServerUrl
        : config.serverUrl;
    final initResult = await _roomKit.initialize(
      NERoomKitOptions(
        appKey: config.appKey,
        serverUrl: serverUrl,
        serverConfig: config.serverConfig?.roomKitServerConfig,
        extras: config.extras == null
            ? null
            : Map.fromEntries(config.extras!.entries
                .where((element) => element.value is String)).cast(),
      ),
    );
    if (initResult.isSuccess()) {
      _lastConfig = config;
      // MeetingCore().foregroundConfig = config.config;
      await ServiceRepository().initialize(
        config.appKey,
        MeetingServerConfig.parse(
            config.serverConfig?.meetingServerConfig?.meetingServer ??
                config.serverUrl ??
                config.extras?['serverUrl']),
        config.extras,
      );
      SDKConfig.current.dispose();
      SDKConfig.current = SDKConfig(config.appKey)..initialize();
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
    return initResult;
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
  Future<NEResult<void>> loginWithToken(String accountId, String token,
      {int? startTime}) async {
    apiLogger.i('loginWithToken: $accountId');
    return _loginWithAccountInfo(_kLoginTypeToken,
        () => AuthRepository.fetchAccountInfoByToken(accountId, token),
        startTime: startTime, userId: accountId);
  }

  @override
  Future<NEResult<void>> loginWithNEMeeting(String username, String password,
      {int? startTime}) async {
    apiLogger.i('loginWithNEMeeting');
    return _loginWithAccountInfo(_kLoginTypePassword,
        () => AuthRepository.fetchAccountInfoByPwd(username, password),
        startTime: startTime, userId: username);
  }

  @override
  Future<NEResult<void>> anonymousLogin() async {
    apiLogger.i('anonymousLogin');
    // if (config?.reuseIM ?? false) {
    //   return NEResult(
    //     code: NEMeetingErrorCode.reuseIMNotSupportAnonymousLogin,
    //     msg: localizations.reuseIMNotSupportAnonymousLogin,
    //   );
    // }
    return _loginWithAccountInfo(
        _kLoginTypeAnonymous,
        () => MeetingRepository.anonymousLogin().map((p0) => NEAccountInfo(
              userUuid: p0.userUuid,
              userToken: p0.userToken,
            )),
        anonymous: true);
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
    apiLogger.i('tryAutoLogin');
    final loginInfo = await SDKPreferences.getLoginInfo();
    if (loginInfo != null && loginInfo.appKey == config?.appKey) {
      return loginWithToken(loginInfo.userUuid, loginInfo.userToken);
    }
    return NEResult(code: NEMeetingErrorCode.failed, msg: 'No login cache');
  }

  Future<VoidResult> _loginWithAccountInfo(String loginType,
      Future<NEResult<NEAccountInfo>> Function() accountInfoAction,
      {bool anonymous = false, int? startTime, String? userId}) async {
    final event = IntervalEvent(_kEventLogin, startTime: startTime)
      ..addParam(kEventParamType, loginType)
      ..addParam(kEventParamUserId, userId)
      ..beginStep(_kLoginStepAccountInfo);
    Future<VoidResult> realLogin() async {
      final accountInfoResult = await accountInfoAction();
      print('accountInfoResult: ${accountInfoResult.requestId}');
      var info = accountInfoResult.data;
      if (info != null) {
        event.endStepWithResult(accountInfoResult);
        event.beginStep(_kLoginStepRoomKitLogin);
        final loginResult = await NERoomKit.instance.authService
            .login(info.userUuid, info.userToken);
        event.endStepWithResult(loginResult);
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
            commonLogger.i('loginWithAccountInfo code:$code , msg: $msg ');
          });
        }
      } else {
        final convertedResult = _handleMeetingResultCode(
                accountInfoResult.code, accountInfoResult.msg)
            .onFailure((code, msg) {
          commonLogger.i('loginWithAccountInfo code:$code , msg: $msg ');
        });
        event.endStepWithResult(convertedResult);
        return convertedResult;
      }
    }

    return realLogin().thenReport(event, userId: userId);
  }

  @override
  NEMeetingService getMeetingService() => meetingService;

  @override
  NEMeetingInviteService getMeetingInviteService() => inviteService;

  @override
  NEScreenSharingService getScreenSharingService() => screenSharingService;

  @override
  NEMeetingAccountService getAccountService() => accountService;

  @override
  NESettingsService getSettingsService() => settingsService;

  @override
  NEPreMeetingService getPreMeetingService() => preMeetingService;

  @override
  NELiveMeetingService getLiveMeetingService() => liveMeetingService;

  @override
  NEMeetingNosService getNosService() => nosService;

  @override
  Future<NEResult<void>> logout() async {
    apiLogger.i('logout');
    return NERoomKit.instance.authService.logout().onSuccess(() {
      accountService._setAccountInfo(null);
      SDKPreferences.setLoginInfo(null);
      onLoginStatusMaybeChanged();
    });
  }

  @override
  void addAuthListener(NEMeetingAuthListener listener) {
    apiLogger.i('addAuthListener $listener');
    _authListenerSet.add(listener);
  }

  @override
  void removeAuthListener(NEMeetingAuthListener listener) {
    apiLogger.i('removeAuthListener $listener');
    _authListenerSet.remove(listener);
  }

  void onLoginStatusMaybeChanged() {
    final old = _loginStatusChangeNotifier.value;
    final now = accountService.getAccountInfo() != null;
    Timer.run(() {
      _loginStatusChangeNotifier.value = now;
      if (old != now) {
        settingsService._ensureSettings();

        /// 登录变更后，传递用户信息重新获取应用配置
        SDKConfig.current.doFetchConfig();
      }
    });
  }

  @override
  Future<NEResult<String?>> uploadLog() {
    return _roomKit.uploadLog();
  }

  @override
  Future<String> get deviceId => NERoomKit.instance.deviceId;

  @override
  Future<bool> reportEvent(Event event, {String? userId}) {
    if (config?.appKey == null) return Future.value(false);
    return _roomKit.reportEvent({
      'appKey': config?.appKey,
      'component': _kComponent,
      'version': _kVersion,
      'framework': _kFramework,
      'userId': userId ?? accountService.getAccountInfo()?.userUuid,
      'eventId': event.eventId,
      'priority': event.priority.index,
      'eventData': event.toMap(),
    });
  }

  @override
  void addReceiveSessionMessageListener(
      NEMeetingMessageSessionListener listener) {
    apiLogger.i(
        'receive session message addReceiveSessionMessageListener $listener');
    _sessionListenerSet.add(listener);

    /// 会议内的缓存会话消息列表
    if (_sessionMessageMapCache.isNotEmpty) {
      _sessionMessageMapCache.forEach((key, value) {
        value?.forEach((element) {
          listener.onReceiveSessionMessage(element);
        });
      });
      _sessionMessageMapCache.clear(); // 使用 clear 方法一次性移除所有映射项
    }
  }

  @override
  void removeReceiveSessionMessageListener(
      NEMeetingMessageSessionListener listener) {
    apiLogger.i('removeReceiveSessionMessageListener $listener');
    _sessionListenerSet.remove(listener);
    _sessionMessageMapCache.clear();
  }

  @override
  Future<NEResult<List<NEMeetingCustomSessionMessage>>> queryUnreadMessageList(
      String sessionId,
      {NEMeetingSessionTypeEnum sessionType = NEMeetingSessionTypeEnum.P2P}) {
    return _roomKit.messageChannelService
        .queryUnreadMessageList(sessionId,
            sessionType:
                NERoomSessionTypeEnumExtension.toType(sessionType.index))
        .then(
          (value) => NEResult(
            code: value.code,
            msg: value.msg,
            data: value.data
                ?.map(
                  (e) => NEMeetingCustomSessionMessage(
                    sessionId: e.sessionId,
                    sessionType: NEMeetingSessionTypeEnumExtension.toType(
                        e.sessionType?.index),
                    messageId: e.messageId,
                    time: e.time,
                    data: NotifyCardData.fromMap(jsonDecode(e.data!)),
                  ),
                )
                .toList(),
          ),
        );
  }

  @override
  Future<NEResult<List<NEMeetingCustomSessionMessage>>>
      getSessionMessagesHistory(NEMeetingGetMessagesHistoryParam param) {
    return _roomKit.messageChannelService
        .getSessionMessagesHistory(
          NERoomGetMessagesHistoryParam(
            sessionId: param.sessionId,
            sessionType: NERoomSessionTypeEnum.P2P,
            limit: param.limit ?? 100,
            fromTime: param.fromTime,
            toTime: param.toTime,
            order: NEMessageSearchOrderExtension.toType(param.order?.index),
          ),
        )
        .then(
          (value) => NEResult(
            code: value.code,
            msg: value.msg,
            data: value.data
                ?.map(
                  (e) => NEMeetingCustomSessionMessage(
                    sessionId: e.sessionId,
                    sessionType: NEMeetingSessionTypeEnumExtension.toType(
                        e.sessionType?.index),
                    messageId: e.messageId,
                    time: e.time,
                    data: NotifyCardData.fromMap(jsonDecode(e.data!)),
                  ),
                )
                .toList(),
          ),
        );
  }

  @override
  Future<VoidResult> clearUnreadCount(String sessionId,
      {NEMeetingSessionTypeEnum sessionType = NEMeetingSessionTypeEnum.P2P}) {
    return _roomKit.messageChannelService.clearUnreadCount(sessionId,
        sessionType: NERoomSessionTypeEnumExtension.toType(sessionType.index));
  }

  @override
  Future<VoidResult> deleteAllSessionMessage(String sessionId,
      {NEMeetingSessionTypeEnum sessionType = NEMeetingSessionTypeEnum.P2P}) {
    return _roomKit.messageChannelService.deleteAllSessionMessage(
      sessionId,
      sessionType: NERoomSessionTypeEnumExtension.toType(sessionType.index),
    );
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
