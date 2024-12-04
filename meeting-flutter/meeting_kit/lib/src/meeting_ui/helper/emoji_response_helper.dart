// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 表情回应帮助类，跟随meeting_page生命周期
class EmojiResponseHelper {
  NERoomContext? roomContext;

  Map<String, NEMeetingUserEmoji> _userEmojiMap = Map();

  /// 一秒一次，检查是否有需要显示隐藏的表情回应图标
  Timer? _userEmojiTimer;

  NEMessageChannelCallback? messageCallback;
  NERoomEventCallback? roomEventCallback;

  final isEmojiResponseEnabled = ValueNotifier<bool>(true);

  bool get isMySelfHostOrCoHost => roomContext?.isMySelfHostOrCoHost() ?? false;

  String handsUpTag = "handsUpTag";

  void init(NERoomContext roomContext) {
    this.roomContext = roomContext;
    messageCallback = NEMessageChannelCallback(
      onCustomMessageReceiveCallback: handlePassThroughMessage,
    );
    roomEventCallback = NERoomEventCallback(
      chatroomMessagesReceived: chatroomMessagesReceived,
      roomPropertiesChanged: _onRoomPropertiesChanged,
      memberPropertiesChanged: handleMemberPropertiesEvent,
      memberPropertiesDeleted: handleMemberPropertiesEvent,
      memberLeaveRoom: memberLeaveRoom,
    );
    isEmojiResponseEnabled.value = roomContext.isEmojiResponseEnabled;
    NERoomKit.instance.messageChannelService
        .addMessageChannelCallback(messageCallback!);
    roomContext.addEventCallback(roomEventCallback!);
  }

  void handlePassThroughMessage(NECustomMessage message) {
    if (message.roomUuid != roomContext?.roomUuid) {
      return;
    }

    /// 表情回应消息
    if (message.commandId == MeetingEmojiMessenger.commandId) {
      final emojiId = MeetingEmojiMessenger.parseEmojiTag(message.data);
      handleEmojiMessage(emojiId, message.senderUuid);
      return;
    }
  }

  void handleMemberPropertiesEvent(
      NERoomMember member, Map<String, String> properties) {
    if (!properties.containsKey(HandsUpProperty.key)) return;
    if (member.isRaisingHand) {
      _userEmojiMap[member.uuid]
          ?.currentEmojiTagStreamController
          .add(handsUpTag);
    } else {
      _userEmojiMap[member.uuid]
          ?.currentEmojiTagStreamController
          .add(_userEmojiMap[member.uuid]?.currentEmojiTag);
    }
  }

  void memberLeaveRoom(List<NERoomMember> userList) {
    userList.forEach((user) {
      final remove = _userEmojiMap.remove(user.uuid);
      if (remove?.currentEmojiTagStreamController.isClosed != true) {
        remove?.currentEmojiTagStreamController.close();
      }
    });
  }

  void _onRoomPropertiesChanged(Map<String, String> properties) {
    if (properties.containsKey(MeetingSecurityCtrlKey.securityCtrlKey)) {
      isEmojiResponseEnabled.value =
          roomContext?.isEmojiResponseEnabled ?? true;
    }
  }

  void chatroomMessagesReceived(List<NERoomChatMessage> message) {
    /// 普通观众过滤等候室消息
    if (roomContext?.isMySelfHostOrCoHost() != true) {
      message = message.where((element) {
        return element.chatroomType != NEChatroomType.waitingRoom;
      }).toList();
    }
    message.forEach((msg) {
      if (msg is NERoomChatCustomMessage) {
        final commandId = MeetingEmojiMessenger.parseCommandId(msg.attachStr);
        if (commandId == MeetingEmojiMessenger.commandId) {
          final emojiTag = MeetingEmojiMessenger.parseEmojiTag(msg.attachStr);
          handleEmojiMessage(emojiTag, msg.fromUserUuid);
        }
      }
    });
  }

  NEMeetingUserEmoji getUserEmoji(String uuid) {
    if (!_userEmojiMap.containsKey(uuid)) {
      _userEmojiMap[uuid] = NEMeetingUserEmoji(uuid);
    }
    return _userEmojiMap[uuid]!;
  }

  void startUserEmojiTimer() {
    _userEmojiTimer?.cancel();
    _userEmojiTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      int timestamp = now.millisecondsSinceEpoch;
      bool emojiActive = false;
      _userEmojiMap.values.forEach((value) {
        if (value.currentEmojiTime != null) {
          if (timestamp - value.currentEmojiTime! >= 10000) {
            value.currentEmojiTag = null;
            value.currentEmojiTagStreamController.add(null);
          } else {
            emojiActive = true;
          }
        }
      });
      if (!emojiActive) {
        stopUserEmojiTimer();
      }
    });
  }

  void stopUserEmojiTimer() {
    _userEmojiTimer?.cancel();
    _userEmojiTimer = null;
  }

  void handleEmojiMessage(String? emojiTag, String? uuid) {
    if (emojiTag != null && uuid != null) {
      DateTime now = DateTime.now();
      int timestamp = now.millisecondsSinceEpoch;
      final emoji = _userEmojiMap[uuid];
      if (emoji != null) {
        emoji.currentEmojiTime = timestamp;
        emoji.currentEmojiTag = emojiTag;
        emoji.currentEmojiTagStreamController.add(emojiTag);
      }
      startUserEmojiTimer();
    }
  }

  void sendEmojiMessage(String emojiTag, bool isChatroomEnabled) {
    roomContext?.sendEmojiMessage(emojiTag, isChatroomEnabled);
    handleEmojiMessage(emojiTag, roomContext?.myUuid);
  }

  void dispose() {
    _userEmojiMap.forEach((key, value) {
      if (value.currentEmojiTagStreamController.isClosed != true) {
        value.currentEmojiTagStreamController.close();
      }
    });
    _userEmojiMap.clear();
    stopUserEmojiTimer();
    if (roomEventCallback != null) {
      roomContext?.removeEventCallback(roomEventCallback!);
    }
    if (messageCallback != null) {
      NERoomKit.instance.messageChannelService
          .removeMessageChannelCallback(messageCallback!);
    }
  }
}
