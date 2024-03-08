// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/proto/app_http_proto.dart';

import '../../model/history_meeting.dart';

class FavoriteMeetingProto extends AppHttpProto<List<HistoryMeeting>> {
  final String appKey;
  final int? startId;
  final int limit;
  FavoriteMeetingProto(this.appKey, this.startId, this.limit);

  @override
  Map data() {
    return {};
  }

  @override
  String get method => 'GET';

  @override
  String path() {
    if (this.startId == null) {
      return "scene/meeting/$appKey/v1/meeting/favorite/list?limit=$limit";
    }
    return "scene/meeting/$appKey/v1/meeting/favorite/list?startId=$startId&limit=$limit";
  }

  @override
  List<HistoryMeeting>? result(Map? map) {
    if (map == null || map.isEmpty) return null;
    var links = map['favoriteList'] as List;
    var list = links
        .map<HistoryMeeting>((e) => HistoryMeeting.fromJson(e as Map))
        .toList();
    return list;
  }
}
