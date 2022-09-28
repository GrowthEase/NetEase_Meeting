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
}
