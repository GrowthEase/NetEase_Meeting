// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/proto/app_http_proto.dart';

class CancelFavoriteByRoomArchiveIdProto extends AppHttpProto<void> {
  final String appKey;
  final int roomArchiveId;
  CancelFavoriteByRoomArchiveIdProto(this.appKey, this.roomArchiveId);

  @override
  Map data() {
    return {};
  }

  @override
  String get method => 'DELETE';
  @override
  String path() {
    return 'scene/meeting/$appKey/v1/meeting/$roomArchiveId/favorite';
  }

  @override
  void result(Map? map) {
    return null;
  }
}

class CancelFavoriteByFavoriteIdProto extends AppHttpProto<void> {
  final String appKey;
  final int favoriteId;
  CancelFavoriteByFavoriteIdProto(this.appKey, this.favoriteId);

  @override
  Map data() {
    return {};
  }

  @override
  String get method => 'DELETE';

  @override
  String path() {
    return 'scene/meeting/$appKey/v1/meeting/favorite/$favoriteId';
  }

  @override
  void result(Map map) {
    return null;
  }
}
