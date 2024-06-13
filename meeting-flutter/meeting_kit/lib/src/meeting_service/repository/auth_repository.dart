// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class AuthRepository {
  static Future<NEResult<NEAccountInfo>> fetchAccountInfoByPwd(
          String username, String password) =>
      HttpApiHelper.execute(
          _LoginWithNEMeetingApi(_LoginByPwdRequest(username, password)));

  static Future<NEResult<NEAccountInfo>> fetchAccountInfoByToken(
          String accountId, String accountToken) =>
      HttpApiHelper.execute(_FetchAccountInfoApi(accountId, accountToken));

  static Future<NEResult<NEAccountInfo>> fetchAccountInfoByUsername(
          String username, String password) =>
      HttpApiHelper.execute(_FetchAccountInfoByPwdApi.username(
          username: username, password: password));

  static Future<NEResult<NEAccountInfo>> fetchAccountInfoByMobile(
          String mobile, String password) =>
      HttpApiHelper.execute(
          _FetchAccountInfoByPwdApi.mobile(mobile: mobile, password: password));

  static Future<NEResult<NEAccountInfo>> fetchAccountInfoByEmail(
          String email, String password) =>
      HttpApiHelper.execute(
          _FetchAccountInfoByPwdApi.email(email: email, password: password));

  static Future<VoidResult> updateAvatar(String url) {
    return HttpApiHelper._updateAvatar(url);
  }

  static Future<VoidResult> updateNickname(String nickname) {
    return HttpApiHelper._updateNickname(nickname);
  }

  static Future<NEResult<NELoginInfo>> resetPassword(
      String userUuid, String oldPassword, String newPassword) {
    return HttpApiHelper.execute(_ResetPasswordApi(
      userUuid: userUuid,
      oldPassword: oldPassword,
      newPassword: newPassword,
    ));
  }

  static Future<VoidResult> requestSmsCodeForLogin(String mobile) {
    return HttpApiHelper.execute(_GetMobileCheckCodeApi.forLogin(mobile));
  }

  /// 获取企业信息
  static Future<NEResult<NEMeetingCorpInfo>> getAppInfo(
      String? corpCode, String? corpEmail,
      {String? baseUrl}) {
    return HttpApiHelper.execute(_GetAppInfoApi(
        baseUrl: baseUrl, corpCode: corpCode, corpEmail: corpEmail));
  }

  static Future<NEResult<NEAccountInfo>> loginWithSmsCode(
      String mobile, String smsCode) {
    return HttpApiHelper.execute(_LoginBySmsApi(mobile, smsCode));
  }

  static Future<NEResult<NELoginInfo>> getCorpAccountInfo(
      String key, String param) {
    return HttpApiHelper.execute(_GetSSOAccountInfoProto(key, param));
  }
}
