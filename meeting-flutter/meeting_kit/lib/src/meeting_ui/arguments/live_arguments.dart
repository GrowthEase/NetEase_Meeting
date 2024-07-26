// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

///
/// meeting live & meeting live setting use same arguments, so need dispose with meeting live
class LiveArguments {
  final NERoomLiveInfo liveInfo;

  final Stream<Object> roomInfoUpdatedEventStream;

  final NERoomContext roomContext;

  final String? liveAddress;

  LiveArguments(this.roomContext, this.liveInfo,
      this.roomInfoUpdatedEventStream, this.liveAddress);

  /// not nullable
  NERoomLiveInfo get live => liveInfo;
}
