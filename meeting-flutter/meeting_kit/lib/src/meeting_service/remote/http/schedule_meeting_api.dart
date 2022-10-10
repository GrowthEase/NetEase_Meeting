// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 预约会议
class _ScheduleMeetingApi extends HttpApi<NEMeetingItem> {
  NEMeetingItem item;

  _ScheduleMeetingApi(this.item);

  @override
  String get method => 'PUT';

  @override
  String path() => 'scene/meeting/${ServiceRepository().appKey}/v1/create/3';

  @override
  NEMeetingItem result(Map map) {
    return NEMeetingItem.fromJson(map);
  }

  @override
  Map data() => item.request();
}
