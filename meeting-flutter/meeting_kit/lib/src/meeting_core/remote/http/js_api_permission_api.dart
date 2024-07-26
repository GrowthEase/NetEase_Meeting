// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 获取用户信息配置
class _GetJSApiPermissionApi extends HttpApi<void> {
  JSApiPermissionRequest request;

  _GetJSApiPermissionApi(this.request);

  @override
  String get method => 'POST';

  @override
  String path() => '/plugin_sdk/v1/js_api_permission';

  @override
  void result(Map map) {}

  @override
  Map data() => request.data;

  @override
  Map<String, dynamic>? header() => {
        'Content-Type': 'application/json;charset=UTF-8',
        'appVer': SDKConfig.sdkVersionCode,
        ...request.header(),
      };
}
