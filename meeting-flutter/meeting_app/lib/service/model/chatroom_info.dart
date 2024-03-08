// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// 聊天室信息
class ChatroomInfo {
  /// 聊天室id
  final int? chatroomId;

  ///导出状态，1.可导出，2.没权限，3.已过期
  final int exportAccess;

  ChatroomInfo(this.chatroomId, this.exportAccess);

  ChatroomInfo.fromJson(Map json)
      : chatroomId = json["chatroomId"] as int?,
        exportAccess = json["exportAccess"] as int;

  Map<String, dynamic> toJson() => {
        'chatroomId': chatroomId,
        'exportAccess': exportAccess,
      };
}
