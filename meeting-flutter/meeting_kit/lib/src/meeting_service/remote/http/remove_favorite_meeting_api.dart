// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _RemoveFavoriteMeetingApi extends HttpApi<void> {
  final int? roomArchiveId;
  final int? favoriteId;

  _RemoveFavoriteMeetingApi(this.roomArchiveId, this.favoriteId);

  @override
  String path() {
    if (this.favoriteId != null) {
      return 'scene/meeting/${ServiceRepository().appKey}/v1/meeting/favorite/$favoriteId';
    } else if (this.roomArchiveId != null) {
      return 'scene/meeting/${ServiceRepository().appKey}/v1/meeting/$roomArchiveId/favorite';
    }
    return '';
  }

  @override
  String get method => 'DELETE';

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() {
    return {};
  }
}
