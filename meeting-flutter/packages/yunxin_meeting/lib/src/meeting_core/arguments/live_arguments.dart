// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;
///
/// meeting live & meeting live setting use same arguments, so need dispose with meeting live
class LiveArguments {
  final NEInRoomLiveInfo liveInfo;

  final Stream<Object> roomInfoUpdatedEventStream;

  LiveArguments(this.liveInfo, this.roomInfoUpdatedEventStream);

  /// not nullable
  NEInRoomLiveInfo get live => liveInfo;
}
