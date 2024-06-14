// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _GetHistoryMeetingDetailApi
    extends HttpApi<NERemoteHistoryMeetingDetail> {
  final int roomArchiveId;

  _GetHistoryMeetingDetailApi(this.roomArchiveId);

  @override
  String path() {
    return 'scene/meeting/${ServiceRepository().appKey}/v1/meeting-history-detail?roomArchiveId=$roomArchiveId';
  }

  @override
  String get method => 'GET';

  @override
  NERemoteHistoryMeetingDetail? result(Map? map) {
    if (map == null || map.isEmpty) return null;
    return NERemoteHistoryMeetingDetail.fromJson(map);
  }

  @override
  Map data() {
    return {};
  }
}
