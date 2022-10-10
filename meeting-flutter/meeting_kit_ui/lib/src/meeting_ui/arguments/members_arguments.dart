// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MembersArguments {
  final Stream roomInfoUpdatedEventStream;
  final NEMeetingUIOptions options;
  final Map<String, StreamController<int>> audioVolumeStreams;
  final NERoomContext roomContext;
  final String meetingTitle;

  MembersArguments(
      {required this.options,
      required this.roomInfoUpdatedEventStream,
      required this.audioVolumeStreams,
      required this.roomContext,
      required this.meetingTitle});
}
