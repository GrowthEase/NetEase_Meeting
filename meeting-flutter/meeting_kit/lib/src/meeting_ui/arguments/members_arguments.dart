// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MembersArguments {
  final Stream roomInfoUpdatedEventStream;
  final NEMeetingOptions options;
  final Map<String, StreamController<int>> audioVolumeStreams;
  final NERoomContext roomContext;
  final String meetingTitle;
  final WaitingRoomManager waitingRoomManager;
  final ValueListenable<bool> isMySelfManagerListenable;
  final ValueListenable<bool> hideAvatar;
  final HandsUpHelper handsUpHelper;
  final EmojiResponseHelper emojiResponseHelper;
  final List<NEMeetingMenuItem> memberActionMenuItems;

  MembersArguments({
    required this.options,
    required this.roomInfoUpdatedEventStream,
    required this.audioVolumeStreams,
    required this.roomContext,
    required this.meetingTitle,
    required this.waitingRoomManager,
    required this.isMySelfManagerListenable,
    required this.hideAvatar,
    required this.handsUpHelper,
    required this.emojiResponseHelper,
    required this.memberActionMenuItems,
  });
}
