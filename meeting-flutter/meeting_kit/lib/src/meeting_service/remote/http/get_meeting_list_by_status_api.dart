// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 删除预约会议
class _GetMeetingListByStatusApi extends HttpApi<List<NEMeetingItem>> {
  List<NEMeetingState> status;

  _GetMeetingListByStatusApi(this.status);

  @override
  String get method => 'GET';

  @override
  String path() {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < status.length; i++) {
      if (i != status.length - 1) {
        buffer.write('states=${status[i].index}' + '&');
      } else {
        buffer.write('states=${status[i].index}');
      }
    }
    return 'scene/meeting/${ServiceRepository().appKey}/v1/list/0/0?${buffer.toString()}';
  }

  @override
  List<NEMeetingItem>? result(Map? map) {
    if (map == null) return null;
    var links = map['meetingList'] as List;
    var list = links
        .map<NEMeetingItem>((e) => NEMeetingItem.fromJson(e as Map))
        .toList();
    list.removeWhere(
        (element) => element.meetingType != NEMeetingType.kReservation.type);
    return list;
  }

  @override
  Map data() => {};
}
