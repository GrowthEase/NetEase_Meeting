// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 获取预约会议
class _GetMeetingListByStatusApi extends HttpApi<List<NEMeetingItem>> {
  List<NEMeetingItemStatus> status;

  _GetMeetingListByStatusApi(this.status);

  @override
  String get method => 'GET';

  @override
  String path() {
    var query = status.map((e) => 'states=${e.index}').join('&');
    if (query.isNotEmpty) {
      query = '?$query';
    }
    return 'scene/meeting/${ServiceRepository().appKey}/v1/list/0/0$query';
  }

  @override
  List<NEMeetingItem>? result(Map? map) {
    if (map == null) return null;
    var links = map['meetingList'] as List;
    var list = links
        .map<NEMeetingItem>((e) => NEMeetingItem.fromJson(e as Map))
        .toList();
    list.removeWhere(
        (element) => element.meetingType != NEMeetingType.kReservation);
    return list;
  }

  @override
  Map data() => {};
}
