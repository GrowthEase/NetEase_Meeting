// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class ChatRoomArguments {
  ChatRoomMessageSource messageSource;

  ChatRoomArguments(this.messageSource);

  NEChatRoomMessage? getMessage(int index) {
    if (index >= size) {
      return null;
    }
    return messageSource.messages.elementAt(index);
  }

  int get size {
    return messageSource.messages.length;
  }

  double get initialScrollOffset {
    return messageSource._initialScrollOffset;
  }
}

class ChatRoomMessageSource {
  static const int maxCacheMessageCount = 10000;

  Queue<NEChatRoomMessage> messages = ListQueue(maxCacheMessageCount);

  StreamController<dynamic> messageNotify = StreamController.broadcast();

  StreamController<int> unreadNotify = StreamController.broadcast();

  Stream get messageStream => messageNotify.stream;

  Stream get unreadStream => unreadNotify.stream;

  int _unread = 0;

  int get unread => _unread;

  set unread(int value) {
    _unread = value;
    _unreadMessageListenable!.value = value;
  }

  ValueNotifier<int>? _unreadMessageListenable;
  ValueListenable<int> get unreadMessageListenable {
    _unreadMessageListenable ??= ValueNotifier(unread);
    return _unreadMessageListenable!;
  }

  double _initialScrollOffset = 0;

  int lastTime = 0;

  static const int showTimeInterval = 5 * 60 * 1000;

  void append(NEChatRoomMessage message, {bool incUnread = true}) {
    if (TextUtils.isEmpty(message.content)) {
      return;
    }
    var curTime = message.time!;
    if (curTime - lastTime > showTimeInterval) {
      var msg = NEChatRoomTextMessage();
      // msg.msgType = MsgType.tip;
      msg.time = curTime;
      lastTime = curTime;
      messages.add(msg);
    }
    if (messages.length >= maxCacheMessageCount) {
      messages.removeFirst();
    }
    messages.addLast(message);
    if (incUnread) {
      unread++;
    } else {
      unread = 0;
    }
    unreadNotify.add(unread);
    messageNotify.add(this);
  }

  // void appendList(List<NEChatRoomMessage> list) {
  //   messages.addAll(list);
  //   unread += list.length;
  //   unreadNotify.add(unread);
  //   messageNotify.add(this);
  // }

  void resetUnread() {
    unread = 0;
    unreadNotify.add(unread);
  }

  void updateOffset(double offset) {
    _initialScrollOffset = offset;
  }

  void dispose() {
    messageNotify.close();
    unreadNotify.close();
  }
}
