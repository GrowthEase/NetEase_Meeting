// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

/// 窗口布局模式
enum _WindowMode {
  /// 画廊模式, 等分界面，滑动布局
  gallery,

  /// 屏幕共享模式
  screenShare,

  /// 白板共享模式
  whiteBoard,

  /// 混合模式
  mix,
}

/// gallery.未开启共享，screenShare.屏幕，whiteBoard.白板，mix.混合

const _gallery = 0;
const _screenShare = 1;
const _whiteBoard = 2;
const _mix = 3;

extension _WindowModeExtension on _WindowMode {
  int get value {
    switch (this) {
      case _WindowMode.gallery:
        return _gallery;
      case _WindowMode.screenShare:
        return _screenShare;
      case _WindowMode.whiteBoard:
        return _whiteBoard;
      case _WindowMode.mix:
        return _mix;
      default:
        return _gallery;
    }
  }

  static _WindowMode get(int mode) {
    switch (mode) {
      case _gallery:
        return _WindowMode.gallery;
      case _screenShare:
        return _WindowMode.screenShare;
      case _whiteBoard:
        return _WindowMode.whiteBoard;
      case _mix:
        return _WindowMode.mix;
      default:
        return _WindowMode.gallery;
    }
  }
}
