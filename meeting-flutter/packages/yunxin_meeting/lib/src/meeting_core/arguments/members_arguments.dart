// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class MembersArguments {

  final Stream roomInfoUpdatedEventStream;
  final MeetingOptions options;

  MembersArguments({
    required this.options,
    required this.roomInfoUpdatedEventStream,
  });

}
