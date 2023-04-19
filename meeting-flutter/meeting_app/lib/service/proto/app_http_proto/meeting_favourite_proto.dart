// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/proto/app_http_proto.dart';

class FavouriteMeetingProto extends AppHttpProto<int?> {
  final String appKey;
  final int roomArchiveId;
  FavouriteMeetingProto(this.appKey, this.roomArchiveId);

  @override
  Map data() {
    return {};
  }

  @override
  String get method => 'PUT';
  @override
  String path() {
    return "scene/meeting/$appKey/v1/meeting/$roomArchiveId/favorite";
  }

  @override
  int? result(Map? map) {
    if (map == null) return null;
    return map["favoriteId"] as int;
  }
}
