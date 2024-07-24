// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 更新昵称
class _UpdateNicknameApi extends HttpApi<void> {
  /// 昵称
  final String nickname;

  _UpdateNicknameApi(this.nickname);

  @override
  String path() {
    return 'scene/meeting/${ServiceRepository().appKey}/v1/account/nickname';
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
      'nickname': nickname,
    };
  }
}
