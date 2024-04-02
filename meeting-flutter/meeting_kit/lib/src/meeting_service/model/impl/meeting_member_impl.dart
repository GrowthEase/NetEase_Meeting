// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 等候室普通成员调用，通过接口获取主持人的信息
class _NEMeetingMemberImpl extends NERoomMember {
  @override
  final String uuid;

  @override
  String name;

  @override
  String? avatar;

  @override
  NERoomRole role;

  @override
  bool isAudioOn = false;

  @override
  bool isVideoOn = false;

  @override
  bool isInRtcChannel = true;

  @override
  bool isInChatroom = true;

  @override
  bool isSharingScreen = false;

  @override
  bool isAudioConnected = true;

  Map<String, String> props = {};

  @override
  Map<String, String> get properties => Map.from(props);

  @override
  bool isSharingWhiteboard = false;

  @override
  NEClientType clientType = NEClientType.unknown;

  _NEMeetingMemberImpl({
    required this.uuid,
    required this.name,
    required this.avatar,
    required this.role,
  });

  @override
  String toString() {
    return '_NEMeetingMemberImpl{uuid: $uuid, name: $name, avatar: $avatar, role: $role}';
  }
}
