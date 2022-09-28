// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _ApiHelper {
  static Future<NEResult<T>> _execute<T>(BaseApi api) {
    return api.execute().then((result) {
      // if (api.checkLoginState() &&
      //     (result.code == MeetingErrorCode.verifyError ||
      //         result.code == MeetingErrorCode.tokenError)) {
      //   _AuthManager().tokenIllegal(MeetingErrorCode.getMsg(result.msg, 'Token失效'));
      // }
      return NEResult(
          code: result.code, msg: result.msg, data: result.data as T?);
    });
  }
}
