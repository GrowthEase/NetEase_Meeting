// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

class _NEMeetingSDKImpl extends NEMeetingSDK with EventTrackMixin {
  static const _tag = '_NEMeetingSDKImpl';
  NEMeetingSDKConfig? _lastConfig;
  NEMeetingService meetingService = _NEMeetingServiceImpl();
  NEMeetingAccountService accountService = _NEMeetingAccountServiceImpl();
  _NESettingsServiceImpl settingsService = _NESettingsServiceImpl();
  NEControlService controlService = _NEControlServiceImpl();
  NEPreMeetingService preMeetingService = _NEPreMeetingServiceImpl();
  NELiveMeetingService liveMeetingService = _NELiveMeetingServiceImpl();

  Map? assetServerConfig;

  final _loginStatusChangeNotifier = ValueNotifier(false);

  final NERoomKit _roomKit = NERoomKit.instance;

  _NEMeetingSDKImpl();

  @override
  ValueNotifier<bool> get loginStatusChangeNotifier => _loginStatusChangeNotifier;

  @override
  NEMeetingSDKConfig? get config => _lastConfig;

  @override
  void initialize(NEMeetingSDKConfig config, result) async {
    _lastConfig = config;
    MeetingCore().foregroundConfig = config.config;
    String? customServerConfig;
    if (config.useAssetServerConfig) {
      customServerConfig = await NEMeetingPlugin().getAssetService().loadCustomServer();
      if (customServerConfig?.isEmpty ?? true) {
        Alog.i(
            tag: _tag,
            moduleName: _moduleName,
            content: 'useAssetServerConfig is true, '
                ' but asset server config file is not exists or empty');
      }
    }
    var initRes = await _roomKit.initialize(NERoomKitConfig(
      appKey: config.appKey,
      serverConfig: customServerConfig,
      reuseNIM: config.reuseNIM,
      extras: config.extras,
      aLoggerConfig: config.aLoggerConfig,
    ));
    result(errorCode: initRes.code);
  }

  @override
  Future<void> loginWithToken(
      String accountId, String token, NECompleteListener listener) async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'loginWithToken accountId $accountId');
    var loginResult = await _roomKit.getAuthService().loginWithToken(accountId, token);
    onLoginStatusMaybeChanged();
    listener(errorCode: loginResult.code, errorMessage: loginResult.msg);
  }

  @override
  Future<void> loginWithNEMeeting(
      String username, String password, NECompleteListener listener) async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'loginWithNEMeeting');
    var loginResult = await _roomKit.getAuthService().loginWithAccount(username, password);
    onLoginStatusMaybeChanged();
    listener(errorCode: loginResult.code, errorMessage: loginResult.msg);
  }

  @override
  Future<void> loginWithSSOToken(String ssoToken, NECompleteListener listener) async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'loginWithSSOToken');
    var loginResult = await _roomKit.getAuthService().loginWithSSOToken(ssoToken);
    onLoginStatusMaybeChanged();
    listener(errorCode: loginResult.code, errorMessage: loginResult.msg);
  }

  @override
  Future<void> tryAutoLogin(NECompleteListener listener) async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'tryAutoLogin');
    var loginResult = await _roomKit.getAuthService().tryAutoLogin();
    onLoginStatusMaybeChanged();
    listener(errorCode: loginResult.code, errorMessage: loginResult.msg);
  }

  @override
  NEMeetingService getMeetingService() => meetingService;

  @override
  NEMeetingAccountService getAccountService() => accountService;

  @override
  NESettingsService getSettingsService() => settingsService;

  @override
  NEControlService getControlService() => controlService;

  @override
  NEPreMeetingService getPreMeetingService() => preMeetingService;

  @override
  NELiveMeetingService getLiveMeetingService() => liveMeetingService;

  @override
  Future<void> logout(NECompleteListener listener) async {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'logout');
    var result = await _roomKit.getAuthService().logout();
    onLoginStatusMaybeChanged();
    listener(errorCode: result.code, errorMessage: result.msg);
  }

  @override
  void addAuthListener(NERoomAuthListener listener) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'addAuthListener');
    _roomKit.getAuthService().addAuthListener(listener);
  }

  @override
  void removeAuthListener(NERoomAuthListener listener) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        type: AlogType.api,
        content: 'removeAuthListener');
    _roomKit.getAuthService().removeAuthListener(listener);
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
