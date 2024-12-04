// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 全部手放下
class _HandsUpDownAllApi extends HttpApi<Map<String, dynamic>> {
  final String roomUuid;

  _HandsUpDownAllApi(this.roomUuid);

  @override
  String get method => 'POST';

  @override
  String path() => '/scene/apps/v1/rooms/${roomUuid}/members/hands-down';

  @override
  void result(Map map) => null;

  @override
  Map data() => {};
}
