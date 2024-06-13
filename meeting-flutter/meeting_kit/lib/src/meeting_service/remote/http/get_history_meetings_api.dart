// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _GetHistoryMeetingsApi extends HttpApi<List<NERemoteHistoryMeeting>> {
  final int? startId;
  final int limit;

  _GetHistoryMeetingsApi(this.startId, this.limit);

  @override
  String path() {
    if (this.startId == null || this.startId! <= 0) {
      return 'scene/meeting/${ServiceRepository().appKey}/v1/meeting/history/list?limit=$limit';
    }
    return 'scene/meeting/${ServiceRepository().appKey}/v1/meeting/history/list?startId=$startId&limit=$limit';
  }

  @override
  String get method => 'GET';

  @override
  List<NERemoteHistoryMeeting>? result(Map? map) {
    if (map == null || map.isEmpty) return null;
    var links = map['meetingList'] as List;
    var list = links
        .map<NERemoteHistoryMeeting>(
            (e) => NERemoteHistoryMeeting.fromJson(e as Map))
        .toList();

    return list;
  }

  @override
  Map data() {
    return {};
  }
}
