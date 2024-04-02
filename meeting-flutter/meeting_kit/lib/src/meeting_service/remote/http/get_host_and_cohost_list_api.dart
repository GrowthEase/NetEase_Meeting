// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class _GetHostAndCoHostListApi extends HttpApi<List<NERoomMember>> {
  final String roomUuid;

  _GetHostAndCoHostListApi(this.roomUuid);

  @override
  String get method => 'GET';

  @override
  String path() =>
      'scene/apps/${ServiceRepository().appKey}/v1/rooms/$roomUuid/host-cohost-list';

  @override
  List<_NEMeetingMemberImpl> parseResult(data) {
    return (data as List).map((e) => fromMap(e)).toList();
  }

  _NEMeetingMemberImpl fromMap(Map map) {
    return _NEMeetingMemberImpl(
      uuid: map['userUuid'],
      name: map['userName'],
      avatar: map['userIcon'],
      role: NERoomRole(
        name: map['role'],
        limit: 1,
        hide: false,
        params: null,
      ),
    );
  }

  @override
  Map data() => {};
}
