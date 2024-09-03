// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 获取用户信息配置
class _GetSettingsApi extends HttpApi<AccountSettings> {
  @override
  String path() => 'scene/meeting/v1/sdk/account/settings/get';

  @override
  AccountSettings result(Map map) {
    return AccountSettings.fromMap(map['settings'] as Map? ?? {});
  }

  @override
  Map data() => {};
}
