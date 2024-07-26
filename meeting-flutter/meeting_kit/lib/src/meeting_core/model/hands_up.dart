// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class HandsUp {
  /// 举手类型， 1：全体静音举手发言
  /// see [HandsUpType]
  final int handsUpType;

  /// 举手状态， 0： 无， 1：举手， 2：举手通过
  /// see [NEHandsUpStatus]
  final int status;

  /// 举手时间， -1: 放下
  final int handsUpTime;

  HandsUp({
    required this.handsUpType,
    required this.status,
    required this.handsUpTime,
  });

  static HandsUp? fromMap(Map? map) {
    if (map != null) {
      try {
        return HandsUp(
          handsUpType: map['handsUpType'] as int,
          status: map['status'] as int,
          handsUpTime: (map['handsUpTime'] ?? -1) as int,
        );
      } catch (e) {
        Alog.e(
            tag: _tag,
            moduleName: _moduleName,
            content: 'parse HandsUp error: exception=$e, data=$map');
      }
    }
    return null;
  }

  // bool get isOnline => status == HandsUpStatus.agree;

  static List<HandsUp>? fromArrays(List? handsUp) {
    if (handsUp == null || handsUp.isEmpty) {
      return null;
    }
    return handsUp
        .map((item) {
          return HandsUp.fromMap(item as Map);
        })
        .whereType<HandsUp>()
        .toList();
  }
}

// 举手类型
class HandsUpType {
  /// 全局静音举手
  static const int muteAll = 1;
}

/// 举手状态
class NEHandsUpStatus {
  /// 放下
  static const int down = 0;

  /// 举手
  static const int up = 1;

  /// 举手通过
  static const int agree = 2;

  /// 主持人拒绝
  static const int downByHost = 3;
}
