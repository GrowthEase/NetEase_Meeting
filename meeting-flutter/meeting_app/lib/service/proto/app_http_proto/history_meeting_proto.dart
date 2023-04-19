// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/model/history_meeting.dart';
import 'package:nemeeting/service/proto/app_http_proto.dart';

class HistoryAllMeetingProto extends AppHttpProto<List<HistoryMeeting>> {
  final String appKey;
  final int? startId;
  final int limit;
  HistoryAllMeetingProto(this.appKey, this.startId, this.limit);

  @override
  String path() {
    if (this.startId == null) {
      return 'scene/meeting/$appKey/v1/meeting/history/list?limit=$limit';
    }
    return 'scene/meeting/$appKey/v1/meeting/history/list?startId=$startId&limit=$limit';
  }

  @override
  String get method => 'GET';

  @override
  List<HistoryMeeting>? result(Map? map) {
    if (map == null || map.isEmpty) return null;
    var links = map['meetingList'] as List;
    var list = links
        .map<HistoryMeeting>((e) => HistoryMeeting.fromJson(e as Map))
        .toList();

    return list;
  }

  @override
  Map data() {
    return {};
  }
}
