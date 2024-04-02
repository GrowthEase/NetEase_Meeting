// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 获取等候室房间配置
class _GetWaitingRoomPropertiesApi extends HttpApi<Map<String, dynamic>> {
  final String roomUuid;

  _GetWaitingRoomPropertiesApi(this.roomUuid);

  @override
  String get method => 'GET';

  @override
  String path() =>
      'scene/apps/${ServiceRepository().appKey}/v1/rooms/$roomUuid/waiting-room-config';

  @override
  Map result(Map map) => map;

  @override
  Map data() => {};
}
