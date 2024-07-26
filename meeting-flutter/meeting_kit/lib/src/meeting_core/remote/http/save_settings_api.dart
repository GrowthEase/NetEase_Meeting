// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 保存用户信息配置
class _SaveSettingsApi extends HttpApi<String> {
  BeautySettings request;

  _SaveSettingsApi(this.request);

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/account/settings';

  @override
  String? result(Map map) {
    // return NEMeetingItem.fromJson(map);
    return null;
  }

  @override
  Map data() => {'settings': request.toMap()};
}
