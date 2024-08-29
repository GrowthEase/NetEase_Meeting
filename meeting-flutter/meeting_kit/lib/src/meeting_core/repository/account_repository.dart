// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 账号服务监听器，可监听登录状态变更、账号信息变更相关事件。
mixin class NEAccountServiceListener {
  /// 登录状态变更为未登录，原因为当前登录账号已在其他设备上重新登录
  void onKickOut() {}

  /// 账号信息过期通知，原因为用户修改了密码，应用层随后应该重新登录
  void onAuthInfoExpired() {}

  /// 断线重连成功
  void onReconnected() {}

  /// 账号信息更新通知
  void onAccountInfoUpdated(NEAccountInfo? accountInfo) {}
}

final class AccountRepository with _AloggerMixin {
  static final AccountRepository _instance = AccountRepository._();

  factory AccountRepository() {
    return _instance;
  }

  final _authListenerSet = <NEAccountServiceListener>{};
  NEAccountInfo? _accountInfo;

  AccountRepository._() {
    HttpHeaderRegistry().addContributor(() {
      return _accountInfo.guard((value) => {
                'user': value.userUuid,
                'token': value.userToken,
              }) ??
          const {};
    });
    HttpErrorRepository()
        .onError
        .where((httpError) => httpError.code == NEMeetingErrorCode.authExpired)
        .listen((httpError) => _notifyAuthInfoExpired());
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
            _notifyAuthInfoExpired();
          }
        } catch (e) {}
      }
    }));
    NERoomKit.instance.authService.onAuthEvent.listen((event) {
      if (event == NEAuthEvent.kKickOut) {
        _authListenerSet.toList().forEach((listener) => listener.onKickOut());
      } else if ({NEAuthEvent.kTokenExpired, NEAuthEvent.kIncorrectToken}
          .contains(event)) {
        _notifyAuthInfoExpired();
      } else if (event == NEAuthEvent.kReconnected) {
        _notifyReconnected();
      }
    });
    ConnectivityManager().onReconnected.listen((_) => syncAccountInfo());
  }

  NEAccountInfo? getAccountInfo() => _accountInfo;

  bool get isLoggedIn => _accountInfo != null;

  void addListener(NEAccountServiceListener authListener) {
    apiLogger.i('addAuthListener $authListener');
    _authListenerSet.add(authListener);
  }

  void removeListener(NEAccountServiceListener authListener) {
    apiLogger.i('removeAuthListener $authListener');
    _authListenerSet.remove(authListener);
  }

  Future<NEResult<NEAccountInfo>> tryAutoLogin() async {
    apiLogger.i('tryAutoLogin');
    final loginInfo = await _LoginInfoCache.getLoginInfo();
    if (loginInfo != null &&
        loginInfo.appKey == CoreRepository().initedAppKey) {
      return loginWithAccountInfo(
          kLoginTypeToken,
          () => AuthRepository.fetchAccountInfoByToken(
              loginInfo.userUuid, loginInfo.userToken),
          userId: loginInfo.userUuid);
    }
    return NEResult(code: NEMeetingErrorCode.failed, msg: 'No login cache');
  }

  Future<NEResult<NEAccountInfo>> anonymousLogin() {
    apiLogger.i('anonymousLogin');
    return loginWithAccountInfo(
        kLoginTypeAnonymous,
        () => HttpApiHelper._anonymousLogin().map((p0) => NEAccountInfo(
              userUuid: p0.userUuid,
              userToken: p0.userToken,
              isAnonymous: true,
            )),
        anonymous: true);
  }

  Future<NEResult<NEAccountInfo>> loginWithAccountInfo(String loginType,
      Future<NEResult<NEAccountInfo>> Function() accountInfoAction,
      {bool anonymous = false, String? userId}) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    final event = IntervalEvent(kEventLogin, startTime: startTime)
      ..addParam(kEventParamType, loginType)
      ..addParam(kEventParamUserId, userId)
      ..addParam(kEventParamCorpCode, CoreRepository().initedConfig?.corpCode)
      ..addParam(kEventParamCorpEmail, CoreRepository().initedConfig?.corpEmail)
      ..beginStep(kLoginStepAccountInfo);
    Future<NEResult<NEAccountInfo>> realLogin() async {
      final accountInfoResult = await accountInfoAction();
      commonLogger.i('accountInfoResult: $accountInfoResult');
      var info = accountInfoResult.data;
      if (info != null) {
        event.endStepWithResult(accountInfoResult);
        event.beginStep(kLoginStepRoomKitLogin);
        final loginResult = await NERoomKit.instance.authService
            .login(info.userUuid, info.userToken);
        event.endStepWithResult(loginResult);
        if (loginResult.isSuccess()) {
          _setAccountInfo(info);
          if (!anonymous) {
            _LoginInfoCache.setLoginInfo(_LoginInfo(
                CoreRepository().initedAppKey!, info.userUuid, info.userToken));
            SDKConfig.global._doFetchConfig();
          }
          return loginResult.map(() => info);
        } else {
          return loginResult.onFailure((code, msg) {
            commonLogger.i('loginWithAccountInfo code:$code , msg: $msg ');
          }).cast();
        }
      } else {
        event.endStepWithResult(accountInfoResult);
        return accountInfoResult.cast();
      }
    }

    return realLogin().thenReport(event, userId: userId);
  }

  Future<VoidResult> logout() {
    apiLogger.i('logout');
    return NERoomKit.instance.authService.logout().onSuccess(() {
      _setAccountInfo(null);
      _LoginInfoCache.setLoginInfo(null);
    });
  }

  void _setAccountInfo(NEAccountInfo? accountInfo) {
    if (_accountInfo != accountInfo) {
      commonLogger.i('setAccountInfo');
      this._accountInfo = accountInfo;
      _authListenerSet
          .toList()
          .forEach((listener) => listener.onAccountInfoUpdated(accountInfo));
    }
  }

  void _notifyAuthInfoExpired() {
    logout();
    _authListenerSet
        .toList()
        .forEach((listener) => listener.onAuthInfoExpired());
  }

  /// 通知重连成功
  void _notifyReconnected() {
    _authListenerSet.toList().forEach((listener) => listener.onReconnected());
  }

  void syncAccountInfo() async {
    final accountInfo = _accountInfo;
    if (accountInfo != null && !accountInfo.isAnonymous) {
      commonLogger.i('syncAccountInfo');
      final result = await AuthRepository.fetchAccountInfoByToken(
        accountInfo.userUuid,
        accountInfo.userToken,
      );
      if (result.isSuccess() && accountInfo == _accountInfo) {
        _setAccountInfo(result.data);
      }
    }
  }
}
