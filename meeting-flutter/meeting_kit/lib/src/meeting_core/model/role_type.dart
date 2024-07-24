// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class RoleType {
  static const int normal = 1;
  static const int host = 2;
  static const int manager = 3;
  static const int hide = 4;

  static bool isHide(int type) {
    return type == hide;
  }
}

enum NEMeetingRoleType {
  /// 主持人
  host,

  /// 联席主持人
  coHost,

  /// 成员
  member,

  /// 外部访客
  guest,
}
