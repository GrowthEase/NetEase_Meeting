// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

abstract class AVState {
  static const int open = 1;

  static const int close = 2;

  static const int hostClose = 3;

  static const int waitingOpen = 4;

  static int state(bool isOpen) {
    return isOpen ? AVState.open : AVState.close;
  }

  static bool isMute(int? avState) {
    return avState != open;
  }
}

/// video state
class VideoState extends AVState {
  static int state(bool isOpen) {
    return AVState.state(isOpen);
  }
}

/// audio state
class AudioState extends AVState {
  static int state(bool isOpen) {
    return AVState.state(isOpen);
  }
}
