// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _AddFavoriteMeetingApi extends HttpApi<int> {
  final int roomArchiveId;

  _AddFavoriteMeetingApi(this.roomArchiveId);

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/meeting/$roomArchiveId/favorite';

  @override
  String get method => 'PUT';

  @override
  int result(Map map) {
    return map["favoriteId"] as int;
  }

  @override
  Map data() {
    return {};
  }
}
