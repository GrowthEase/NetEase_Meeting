// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class WebAppRepository {
  /// 获取小应用列表
  static Future<NEResult<List<NEMeetingWebAppItem>>> getWebAppList() {
    return HttpApiHelper.getWebAppList();
  }

  /// 获取JsApi授权
  static Future<NEResult<void>> jsAPIPermission(
      JSApiPermissionRequest request) {
    return HttpApiHelper.jsAPIPermission(request);
  }

  /// 获取授权码
  static Future<NEResult<AuthCodeModel>> getAuthCode(String pluginId) {
    return HttpApiHelper.getAuthCode(pluginId);
  }
}
