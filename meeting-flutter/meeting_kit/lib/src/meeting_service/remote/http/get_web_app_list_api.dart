// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 获取用户信息配置
class _GetWebAppListApi extends HttpApi<NEMeetingWebAppList> {
  @override
  String get method => 'GET';

  @override
  String path() => 'plugin_sdk/v1/list';

  @override
  NEMeetingWebAppList result(Map map) {
    return NEMeetingWebAppList.fromMap(map as Map<String, dynamic>);
  }

  @override
  Map data() => {};

  @override
  Map<String, dynamic>? header() => {
        'Content-Type': 'application/json;charset=UTF-8',
        'appVer': SDKConfig.sdkVersionCode,
      };
}
