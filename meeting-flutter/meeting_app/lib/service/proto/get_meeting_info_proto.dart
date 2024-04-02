// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/model/history_meeting.dart';
import 'package:nemeeting/service/proto/app_http_proto.dart';

class HistoryMeetingDetailsInfoProto extends AppHttpProto<HistoryMeeting> {
  final String appKey;
  final int meetingId;

  HistoryMeetingDetailsInfoProto(this.appKey, this.meetingId);

  @override
  String path() {
    return 'scene/meeting/$appKey/v1/meeting/history/$meetingId';
  }

  @override
  String get method => 'GET';

  @override
  HistoryMeeting? result(Map? map) {
    if (map == null || map.isEmpty) return null;
    return HistoryMeeting.fromJson(map);
  }

  @override
  Map data() {
    return {};
  }
}
