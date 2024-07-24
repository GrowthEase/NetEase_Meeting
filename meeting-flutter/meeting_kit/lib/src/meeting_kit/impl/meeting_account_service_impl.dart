// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEAccountServiceImpl extends NEAccountService with _AloggerMixin {
  _NEAccountServiceImpl();

  @override
  NEAccountInfo? getAccountInfo() {
    return AccountRepository().getAccountInfo();
  }

  @override
  void addListener(NEAccountServiceListener authListener) {
    AccountRepository().addListener(authListener);
  }

  @override
  void removeListener(NEAccountServiceListener authListener) {
    AccountRepository().removeListener(authListener);
  }

  @override
  Future<NEResult<NEAccountInfo>> loginByEmail(String email, String password) {
    apiLogger.i('loginByEmail');
    return AccountRepository().loginWithAccountInfo(kLoginTypeEmail,
        () => AuthRepository.fetchAccountInfoByEmail(email, password),
        userId: email);
  }

  @override
  Future<NEResult<NEAccountInfo>> loginByPhoneNumber(
      String mobile, String password) {
    apiLogger.i('loginByPhoneNumber');
    return AccountRepository().loginWithAccountInfo(kLoginTypePhoneNumber,
        () => AuthRepository.fetchAccountInfoByMobile(mobile, password),
        userId: mobile);
  }

  @override
  Future<NEResult<NEAccountInfo>> loginBySmsCode(
      String mobile, String smsCode) {
    apiLogger.i('loginBySmsCode: $mobile');
    return AccountRepository().loginWithAccountInfo(kLoginTypeSmsCode,
        () => AuthRepository.loginWithSmsCode(mobile, smsCode));
  }

  @override
  Future<NEResult<NEAccountInfo>> loginByToken(String userUuid, String token) {
    apiLogger.i('loginByToken: $userUuid');
    return AccountRepository().loginWithAccountInfo(kLoginTypeToken,
        () => AuthRepository.fetchAccountInfoByToken(userUuid, token),
        userId: userUuid);
  }

  @override
  Future<NEResult<NEAccountInfo>> loginByPassword(
      String userUuid, String password) {
    apiLogger.i('loginByPassword: $userUuid');
    return AccountRepository().loginWithAccountInfo(kLoginTypePassword,
        () => AuthRepository.fetchAccountInfoByUsername(userUuid, password),
        userId: userUuid);
  }

  @override
  Future<VoidResult> logout() {
    return AccountRepository().logout();
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
    final corpInfo = CoreRepository().initedCorpInfo;
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
    return AccountRepository().tryAutoLogin();
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
}
