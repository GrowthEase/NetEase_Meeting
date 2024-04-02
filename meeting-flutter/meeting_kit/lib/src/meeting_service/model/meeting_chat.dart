// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 聊天室权限类型
enum NEChatPermission {
  /// 允许自由聊天
  freeChat,

  /// 仅允许公开聊天
  publicChatOnly,

  /// 仅允许私聊主持人
  privateChatHostOnly,

  /// 全体成员禁言
  noChat,
}

extension NEChatPermissionValue on NEChatPermission {
  int get value {
    switch (this) {
      case NEChatPermission.freeChat:
        return 1;
      case NEChatPermission.publicChatOnly:
        return 2;
      case NEChatPermission.privateChatHostOnly:
        return 3;
      case NEChatPermission.noChat:
        return 4;
    }
  }

  static NEChatPermission fromValue(int? value) {
    switch (value) {
      case 1:
        return NEChatPermission.freeChat;
      case 2:
        return NEChatPermission.publicChatOnly;
      case 3:
        return NEChatPermission.privateChatHostOnly;
      case 4:
        return NEChatPermission.noChat;
      default:
        return NEChatPermission.freeChat;
    }
  }
}

/// 等候室聊天室权限类型
enum NEWaitingRoomChatPermission {
  /// 全体成员禁言
  noChat,

  /// 仅允许私聊主持人
  privateChatHostOnly,
}

extension NEWaitingRoomChatPermissionValue on NEWaitingRoomChatPermission {
  int get value {
    switch (this) {
      case NEWaitingRoomChatPermission.noChat:
        return 0;
      case NEWaitingRoomChatPermission.privateChatHostOnly:
        return 1;
    }
  }

  static NEWaitingRoomChatPermission fromValue(int? value) {
    switch (value) {
      case 0:
        return NEWaitingRoomChatPermission.noChat;
      case 1:
        return NEWaitingRoomChatPermission.privateChatHostOnly;
      default:
        return NEWaitingRoomChatPermission.privateChatHostOnly;
    }
  }
}

///
/// 聊天室权限房间属性Key
///
class NEChatPermissionProperty {
  static const key = 'crPerm';
}

///
/// 等候室聊天室权限房间属性Key
///
class NEWaitingRoomChatPermissionProperty {
  static const key = 'wtPrChat';
}

///
/// 房间消息拓展类
///
extension NEMeetingChatMessage on NERoomChatMessage {
  ///
  /// 存在toUserUuidList字段，则该消息为私聊消息类型
  /// 反之不存在toUserUuidList字段，则消息为公聊消息类型
  ///
  bool get isPrivateMessage => toUserUuidList?.isNotEmpty == true;
}
