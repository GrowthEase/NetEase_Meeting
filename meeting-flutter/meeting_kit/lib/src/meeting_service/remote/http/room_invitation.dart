// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 邀请成员加入房间
class _RoomInvitationApi extends HttpApi<void> {
  final String roomId;
  final NERoomInvitation invitation;

  _RoomInvitationApi(this.roomId, this.invitation);

  @override
  Map data() => {'sipNum': invitation.sipNum, 'sipHost': invitation.sipHost};

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/sip/$roomId/invite';

  @override
  void result(Map map) => null;
}

/// 获取邀请列表
class _RoomGetInviteListApi extends HttpApi<List<NERoomInvitation>> {
  final String roomId;

  _RoomGetInviteListApi(this.roomId);

  @override
  String get method => 'GET';

  @override
  Map data() => {
        'meetingId': roomId,
      };

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/sip/$roomId/list';

  @override
  List<NERoomInvitation> parseResult(dynamic data) {
    List list = data['list'];
    if (list.isNotEmpty) {
      return list.map((e) {
        assert(e is Map);
        final item = e as Map;
        return NERoomInvitation(
          sipNum: item.remove('sipNum') as String,
          sipHost: item.remove('sipHost') as String,
        );
      }).toList();
    }
    return [];
  }
}
