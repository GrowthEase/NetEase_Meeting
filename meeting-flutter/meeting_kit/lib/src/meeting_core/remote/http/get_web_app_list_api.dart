// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 获取用户信息配置
class _GetWebAppListApi extends HttpApi<List<NEMeetingWebAppItem>> {
  final NEInjectedAuthorization? authorization;

  _GetWebAppListApi(this.authorization);

  @override
  String get method => 'GET';

  @override
  String path() => 'plugin_sdk/v1/list';

  @override
  List<NEMeetingWebAppItem> result(Map map) {
    final pluginInfos =
        (map['pluginInfos'] as List).cast<Map<String, dynamic>>();
    return pluginInfos.map((ret) => NEMeetingWebAppItem.fromMap(ret)).toList();
  }

  @override
  Map data() => {};

  @override
  Map<String, dynamic>? header() => {
        if (authorization != null) ...authorization!.toHeaders(),
        'Content-Type': 'application/json;charset=UTF-8',
        'appVer': SDKConfig.sdkVersionCode,
      };
}
