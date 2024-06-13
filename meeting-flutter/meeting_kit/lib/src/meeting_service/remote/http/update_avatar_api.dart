// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 更新头像
class _UpdateAvatarApi extends HttpApi<void> {
  /// 头像URL
  final String url;

  _UpdateAvatarApi(this.url);

  @override
  String path() {
    return 'scene/meeting/${ServiceRepository().appKey}/v1/account/avatar';
  }

  @override
  String get method => 'POST';

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() {
    return {
      'avatar': url,
    };
  }
}
