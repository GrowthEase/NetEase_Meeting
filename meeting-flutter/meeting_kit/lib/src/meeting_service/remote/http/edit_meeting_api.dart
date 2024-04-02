// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 编译预约会议
class _EditMeetingApi extends HttpApi<NEMeetingItem> {
  NEMeetingItem item;

  _EditMeetingApi(this.item);

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/edit/${item.meetingId}';

  @override
  NEMeetingItem result(Map map) {
    return NEMeetingItem.fromJson(map);
  }

  @override
  Map data() => item.request();
}

class _EditRecurringMeetingApi extends _EditMeetingApi {
  _EditRecurringMeetingApi(super.item);

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/recurring-meeting/${item.meetingId}';

  @override
  String get method => 'PATCH';
}
