// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _GetSSOAccountInfoProto extends HttpApi<NELoginInfo> {
  final String key;
  final String param;

  _GetSSOAccountInfoProto(this.key, this.param);

  @override
  String get method => 'GET';

  @override
  String path() => 'scene/meeting/v2/sso-account-info';

  @override
  Map<String, dynamic>? header() => {'appKey': ServiceRepository().appKey};

  @override
  NELoginInfo result(Map map) =>
      NELoginInfo.fromJson(appKey: ServiceRepository().appKey, map);

  @override
  Map data() {
    return {
      'key': key,
      'param': param,
    };
  }
}
