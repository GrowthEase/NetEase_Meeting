// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/model/chatroom_info.dart';
import 'package:nemeeting/service/proto/app_http_proto.dart';

/// 获取历史会议详情
class HistoryMeetingDetailsProto extends AppHttpProto<ChatroomInfo> {
  final String appKey;
  final int roomArchiveId;
  HistoryMeetingDetailsProto(this.appKey, this.roomArchiveId);

  @override
  String path() {
    return 'scene/meeting/$appKey/v1/meeting-history-detail?roomArchiveId=$roomArchiveId';
  }

  @override
  String get method => 'GET';

  @override
  Map data() {
    return {};
  }

  @override
  ChatroomInfo? result(Map map) {
    if (map.isEmpty) return null;
    var chatroom = map['chatroom'];
    return ChatroomInfo.fromJson(chatroom);
  }
}
