// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEAccountServiceImpl extends NEAccountService with _AloggerMixin {
  final InitedInfo initedInfo;
  final _loginStatusChangeNotifier = ValueNotifier(false);
  final Set<NEAccountServiceListener> _authListenerSet =
      <NEAccountServiceListener>{};

  _NEAccountServiceImpl(this.initedInfo) {
    HttpHeaderRegistry().addContributor(() {
      return getAccountInfo().guard((value) => {
                'user': value.userUuid,
                'token': value.userToken,
              }) ??
          const {};
    });
    HttpErrorRepository()
        .onError
        .where((httpError) => httpError.code == NEMeetingErrorCode.authExpired)
        .listen((httpError) => notifyAuthInfoExpired());
    NERoomKit.instance.messageChannelService.addMessageChannelCallback(
        NEMessageChannelCallback(onCustomMessageReceiveCallback: (message) {
      /// 账号信息变更通知
      if (message.commandId == 211 && message.roomUuid == null) {
        try {
          final data = jsonDecode(message.data);
          final accountInfo = NEAccountInfo.fromMap(
            data['meetingAccountInfo'] as Map,
            userUuid: _accountInfo?.userUuid,
            userToken: _accountInfo?.userToken,
          );
          _setAccountInfo(accountInfo);
        } catch (e) {}
      } else if (message.commandId == 98 && message.roomUuid == null) {
        try {
          final data = jsonDecode(message.data);
          if (data['type'] == 200 && data['reason'] != null) {
            commonLogger.i('receive auth message: ${message.data}');
            notifyAuthInfoExpired();
          }
        } catch (e) {}
      }
    }));
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
  }

  NEAccountInfo? _accountInfo;

  @override
  NEAccountInfo? getAccountInfo() {
    return _accountInfo;
  }

  void _setAccountInfo(NEAccountInfo? accountInfo) {
    this._accountInfo = accountInfo;
    _authListenerSet
        .toList()
        .forEach((listener) => listener.onAccountInfoUpdated(accountInfo));
  }

  @override
  void addListener(NEAccountServiceListener authListener) {
    apiLogger.i('addAuthListener $authListener');
    _authListenerSet.add(authListener);
  }

  @override
  void removeListener(NEAccountServiceListener authListener) {
    apiLogger.i('removeAuthListener $authListener');
    _authListenerSet.remove(authListener);
  }

  @override
  Future<NEResult<NEAccountInfo>> anonymousLogin() {
    apiLogger.i('anonymousLogin');
    return _loginWithAccountInfo(
        _kLoginTypeAnonymous,
        () => MeetingRepository.anonymousLogin().map((p0) => NEAccountInfo(
              userUuid: p0.userUuid,
              userToken: p0.userToken,
              isAnonymous: true,
            )),
        anonymous: true);
  }

  @override
  Future<NEResult<NEAccountInfo>> loginByEmail(String email, String password) {
    apiLogger.i('loginByEmail');
    return _loginWithAccountInfo(_kLoginTypeEmail,
        () => AuthRepository.fetchAccountInfoByEmail(email, password),
        userId: email);
  }

  @override
  Future<NEResult<NEAccountInfo>> loginByPhoneNumber(
      String mobile, String password) {
    apiLogger.i('loginByPhoneNumber');
    return _loginWithAccountInfo(_kLoginTypePhoneNumber,
        () => AuthRepository.fetchAccountInfoByMobile(mobile, password),
        userId: mobile);
  }

  @override
  Future<NEResult<NEAccountInfo>> loginBySmsCode(
      String mobile, String smsCode) {
    apiLogger.i('loginBySmsCode: $mobile');
    return _loginWithAccountInfo(_kLoginTypeSmsCode,
        () => AuthRepository.loginWithSmsCode(mobile, smsCode));
  }

  @override
  Future<NEResult<NEAccountInfo>> loginByToken(String userUuid, String token) {
    apiLogger.i('loginByToken: $userUuid');
    return _loginWithAccountInfo(_kLoginTypeToken,
        () => AuthRepository.fetchAccountInfoByToken(userUuid, token),
        userId: userUuid);
  }

  @override
  Future<NEResult<NEAccountInfo>> loginByPassword(
      String userUuid, String password) {
    apiLogger.i('loginByPassword: $userUuid');
    return _loginWithAccountInfo(_kLoginTypePassword,
        () => AuthRepository.fetchAccountInfoByUsername(userUuid, password),
        userId: userUuid);
  }

  @override
  Future<VoidResult> logout() {
    apiLogger.i('logout');
    return NERoomKit.instance.authService.logout().onSuccess(() {
      _setAccountInfo(null);
      SDKPreferences.setLoginInfo(null);
      onLoginStatusMaybeChanged();
    });
  }

  void onLoginStatusMaybeChanged() {
    final old = _loginStatusChangeNotifier.value;
    final now = getAccountInfo() != null;
    Timer.run(() {
      _loginStatusChangeNotifier.value = now;
      if (old != now) {
        _NESettingsServiceImpl()._ensureSettings();

        /// 登录变更后，传递用户信息重新获取应用配置
        SDKConfig.current.doFetchConfig();
      }
    });
  }

  @override
  Future<VoidResult> requestSmsCodeForLogin(String mobile) {
    apiLogger.i('requestSmsCodeForLogin: $mobile');
    return AuthRepository.requestSmsCodeForLogin(mobile);
  }

  @override
  Future<NEResult<NELoginInfo>> resetPassword(
      String userUuid, String newPassword, String oldPassword) {
    apiLogger.i('resetPassword: $userUuid');
    return AuthRepository.resetPassword(userUuid, oldPassword, newPassword);
  }

  String ssoLoginReqUuid = Uuid().v4();
  @override
  Future<NEResult<String>> generateSSOLoginWebURL() async {
    apiLogger.i('generateSSOLoginWebURL');
    final corpInfo = initedInfo.initedCorpInfo;
    if (corpInfo == null) {
      commonLogger.e('Corp info not found');
      return NEResult(
          code: NEMeetingErrorCode.corpNotFound, msg: 'Corp not found');
    }
    // 获取企业信息中的认证信息
    final oauthIdp =
        corpInfo.idpList.where((element) => element.isOAuth2).firstOrNull;
    if (oauthIdp == null) {
      commonLogger.e('OAuth2 idp item not found');
      return NEResult(
          code: NEMeetingErrorCode.corpNotSupportSSO,
          msg: 'Corp not support SSO');
    }
    final uri =
        Uri.parse(ServersConfig().baseUrl + 'scene/meeting/v2/sso-authorize');
    ssoLoginReqUuid = Uuid().v4();
    final ssoLoginUrl = uri.replace(
      queryParameters: {
        // if (callback != null && callback!.isNotEmpty) 'callback': callback!,
        'appKey': corpInfo.appKey,
        'idp': oauthIdp.id.toString(),
        'key': ssoLoginReqUuid,
        'clientType': Platform.isAndroid ? 'android' : 'ios',
      },
    ).toString();
    return NEResult(code: NEErrorCode.success, data: ssoLoginUrl);
  }

  @override
  Future<NEResult<NEAccountInfo>> loginBySSOUri(String ssoUri) async {
    apiLogger.i('loginBySSOUri: $ssoUri');
    final uriData = Uri.parse(ssoUri);
    final param = uriData.queryParameters['param'];
    if (param != null && param.isNotEmpty) {
      return AuthRepository.getCorpAccountInfo(ssoLoginReqUuid, param).map(
          (loginInfo) => loginByToken(loginInfo.userUuid, loginInfo.userToken));
    }
    return NEResult(code: NEErrorCode.failure);
  }

  @override
  Future<NEResult<NEAccountInfo>> tryAutoLogin() async {
    apiLogger.i('tryAutoLogin');
    final loginInfo = await SDKPreferences.getLoginInfo();
    if (loginInfo != null &&
        loginInfo.appKey == NEMeetingKit.instance.config?.appKey) {
      return loginByToken(loginInfo.userUuid, loginInfo.userToken);
    }
    return NEResult(code: NEMeetingErrorCode.failed, msg: 'No login cache');
  }

  @override
  Future<VoidResult> updateAvatar(String imagePath) async {
    apiLogger.i('updateAvatar $imagePath');
    final ret = await NERoomKit.instance.nosService
        .uploadResource(imagePath, progress: null);
    if (!ret.isSuccess() || ret.data == null) {
      return VoidResult(code: ret.code, msg: ret.msg);
    } else {
      final updateRet = await AuthRepository.updateAvatar(ret.data!);
      return VoidResult(code: updateRet.code, msg: updateRet.msg);
    }
  }

  @override
  Future<VoidResult> updateNickname(String nickname) {
    apiLogger.i('updateNickname $nickname');
    return AuthRepository.updateNickname(nickname);
  }

  Future<NEResult<NEAccountInfo>> _loginWithAccountInfo(String loginType,
      Future<NEResult<NEAccountInfo>> Function() accountInfoAction,
      {bool anonymous = false, String? userId}) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    final event = IntervalEvent(_kEventLogin, startTime: startTime)
      ..addParam(kEventParamType, loginType)
      ..addParam(kEventParamUserId, userId)
      ..beginStep(_kLoginStepAccountInfo);
    Future<NEResult<NEAccountInfo>> realLogin() async {
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
          _setAccountInfo(info);
          if (!anonymous) {
            SDKPreferences.setLoginInfo(LoginInfo(
                initedInfo.initedAppKey!, info.userUuid, info.userToken));
          }
          onLoginStatusMaybeChanged();
          return loginResult.map(() => info);
        } else {
          return loginResult.onFailure((code, msg) {
            commonLogger.i('loginWithAccountInfo code:$code , msg: $msg ');
          }).cast();
        }
      } else {
        final convertedResult = _handleMeetingResultCode(
                accountInfoResult.code, accountInfoResult.msg)
            .onFailure((code, msg) {
          commonLogger.i('loginWithAccountInfo code:$code , msg: $msg ');
        });
        event.endStepWithResult(convertedResult);
        return convertedResult.cast();
      }
    }

    return realLogin().thenReport(event, userId: userId);
  }

  void notifyAuthInfoExpired() {
    logout();
    _authListenerSet
        .toList()
        .forEach((listener) => listener.onAuthInfoExpired());
  }

  /// 通知重连成功
  void notifyReconnected() {
    _authListenerSet.toList().forEach((listener) => listener.onReconnected());
  }
}
