// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _AnonymousLoginApi extends HttpApi<AnonymousLoginInfo> {
  @override
  String path() =>
      'scene/apps/${ServiceRepository().appKey}/v1/anonymous/login';

  @override
  String get method => 'POST';

  @override
  AnonymousLoginInfo? result(Map map) => AnonymousLoginInfo.fromMap(map);

  @override
  Map data() => {
        'appKey': ServiceRepository().appKey,
      };
}
