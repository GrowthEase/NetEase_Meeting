// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class WebAppRepository {
  /// 获取小应用列表
  static Future<NEResult<List<NEMeetingWebAppItem>>> getWebAppList(
      NEInjectedAuthorization? authorization) {
    return HttpApiHelper.getWebAppList(authorization);
  }

  /// 获取JsApi授权
  static Future<NEResult<void>> jsAPIPermission(
      JSApiPermissionRequest request) {
    return HttpApiHelper.jsAPIPermission(request);
  }

  /// 获取授权码
  static Future<NEResult<AuthCodeModel>> getAuthCode(
      NEInjectedAuthorization? authorization, String pluginId) {
    return HttpApiHelper.getAuthCode(authorization, pluginId);
  }
}

extension NEInjectedAuthorizationToHeaders on NEInjectedAuthorization {
  Map<String, dynamic> toHeaders() {
    return {
      'AppKey': this.appKey,
      'user': this.user,
      'token': this.token,
    };
  }
}
