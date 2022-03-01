// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class JoinControlType{
  static const int allowJoin = 1;
  static const int forbidden = 2;

  static bool isLock(int type) {
    return type == forbidden;
  }
}