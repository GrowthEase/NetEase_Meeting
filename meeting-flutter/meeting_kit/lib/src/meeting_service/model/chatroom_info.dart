// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 聊天室导出状态
enum NEChatroomExportAccess {
  /// 未知
  kUnknown,

  /// 可导出
  kAvailable,

  /// 无权限导出
  kNoPermission,

  /// 已过期
  kOutOfDate,
}

/// 聊天室信息
class NEChatroomInfo {
  /// 聊天室id
  final int? chatroomId;

  /// 导出状态
  final NEChatroomExportAccess exportAccess;

  NEChatroomInfo(this.chatroomId, this.exportAccess);

  NEChatroomInfo.fromJson(Map json)
      : chatroomId = json["chatroomId"] as int?,
        exportAccess =
            NEChatroomExportAccess.values[json["exportAccess"] as int];

  Map<String, dynamic> toJson() => {
        'chatroomId': chatroomId,
        'exportAccess': exportAccess.index,
      };
}
