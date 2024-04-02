// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 获取用户信息配置
class _GetAuthCodeApi extends HttpApi<AuthCodeModel> {
  String pluginId;

  _GetAuthCodeApi(this.pluginId);

  @override
  String get method => 'POST';

  @override
  String path() => 'plugin_sdk/v1/auth_code';

  @override
  AuthCodeModel result(Map map) {
    return AuthCodeModel.fromMap(map);
  }

  @override
  Map data() => {'pluginId': pluginId};

  @override
  Map<String, dynamic>? header() => {
        'Content-Type': 'application/json;charset=UTF-8',
        'appVer': SDKConfig.sdkVersionCode,
      };
}
