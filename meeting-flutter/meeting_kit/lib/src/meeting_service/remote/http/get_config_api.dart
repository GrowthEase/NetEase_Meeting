// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 查询全局配置项
class _GetConfigApi extends HttpApi<_SDKGlobalConfig> {
  final String appKey;

  _GetConfigApi(this.appKey);

  @override
  String path() => 'scene/meeting/$appKey/v1/config';

  @override
  _SDKGlobalConfig? result(Map map) => _SDKGlobalConfig.fromJson(map);

  @override
  Map data() => {};

  @override
  bool checkLoginState() => false;

  @override
  String get method => 'GET';
}
