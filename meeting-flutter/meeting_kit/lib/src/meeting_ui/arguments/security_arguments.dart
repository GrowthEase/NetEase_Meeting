// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class SecurityArguments {
  final NERoomContext roomContext;
  final WaitingRoomManager waitingRoomManager;
  final ValueListenable<bool> isMySelfManagerListenable;
  final bool isGuestJoinSupported;

  SecurityArguments(this.roomContext, this.waitingRoomManager,
      this.isMySelfManagerListenable, this.isGuestJoinSupported);
}
