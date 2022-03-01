// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 窗口布局模式
enum WindowMode {
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

const gallery = 0;
const screenShare = 1;
const whiteBoard = 2;
const mix = 3;

extension WindowModeExtension on WindowMode {
  int get value {
    switch (this) {
      case WindowMode.gallery:
        return gallery;
      case WindowMode.screenShare:
        return screenShare;
      case WindowMode.whiteBoard:
        return whiteBoard;
      case WindowMode.mix:
        return mix;
      default:
        return gallery;
    }
  }

  static WindowMode get(int mode) {
    switch (mode) {
      case gallery:
        return WindowMode.gallery;
      case screenShare:
        return WindowMode.screenShare;
      case whiteBoard:
        return WindowMode.whiteBoard;
      case mix:
        return WindowMode.mix;
      default:
        return WindowMode.gallery;
    }
  }
}
