// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class ChatRecallMessage {
  final String messageId;
  final String operateBy;
  final bool fileCancelDownload;
  ChatRecallMessage(this.messageId, this.operateBy,
      {this.fileCancelDownload = false});
}

class ChatRoomArguments {
  ChatRoomMessageSource messageSource;
  final NERoomContext? roomContext;
  final WaitingRoomManager? waitingRoomManager;
  final ChatRoomManager? chatRoomManager;
  final Stream? roomInfoUpdatedEventStream;
  final ValueNotifier<bool>? hideAvatar;

  ChatRoomArguments(
      {this.roomContext,
      required this.messageSource,
      this.hideAvatar,
      this.waitingRoomManager,
      this.chatRoomManager,
      this.roomInfoUpdatedEventStream});

  Object? getMessage(int index) {
    if (index < 0 || index >= msgSize) {
      return null;
    }
    return messageSource.messages.elementAt(index);
  }

  Object? get lastMessage {
    return msgSize >= 2 ? getMessage(msgSize - 2) : null;
  }

  int get msgSize {
    return messageSource.messages.length;
  }

  double get initialScrollOffset {
    return messageSource._initialScrollOffset;
  }

  bool get isFileMessageEnabled => messageSource.isFileMessageEnabled;

  bool get isImageMessageEnabled => messageSource.isImageMessageEnabled;
}

class ChatRoomMessageSource {
  static const int maxCacheMessageCount = 10000;

  Queue<Object> messages = ListQueue(maxCacheMessageCount);

  StreamController<dynamic> messageNotify = StreamController.broadcast();

  StreamController<int> unreadNotify = StreamController.broadcast();

  /// 新消息提醒文本流,用于气泡和聊天弹幕
  final newMessageNotifyTextStream = StreamController<MessageState>.broadcast();

  final SDKConfig? sdkConfig;
  final NEMeetingChatroomConfig? chatroomConfig;

  ChatRoomMessageSource({this.sdkConfig, this.chatroomConfig});
  bool isFirstFetchHistory = true;

  /// 从前面插入的消息
  bool isInsertMessage = false;

  Future Function()? inMeetingChatroomJoined;
  Future Function()? waitingRoomChatroomJoined;
  Future ensureChatroomJoined(NEChatroomType type) async {
    if (type == NEChatroomType.common && inMeetingChatroomJoined != null) {
      await inMeetingChatroomJoined!();
    } else if (type == NEChatroomType.waitingRoom &&
        waitingRoomChatroomJoined != null) {
      await waitingRoomChatroomJoined!();
    }
  }

  bool get isFileMessageEnabled {
    return (sdkConfig?.meetingChatroomConfig.enableFileMessage ?? true) &&
        (chatroomConfig?.enableFileMessage ?? true);
  }

  bool get isImageMessageEnabled {
    return (sdkConfig?.meetingChatroomConfig.enableImageMessage ?? true) &&
        (chatroomConfig?.enableImageMessage ?? true);
  }

  Stream get messageStream => messageNotify.stream;

  int _unread = 0;
  final ValueNotifier<int> _unreadMessageListenable = ValueNotifier(0);

  int get unread => _unread;

  set unread(int value) {
    _unread = value;
    _unreadMessageListenable.value = value;
  }

  ValueListenable<int> get unreadMessageListenable {
    return _unreadMessageListenable;
  }

  double _initialScrollOffset = 0;

  int lastTime = 0;
  int firstTime = 0;
  static const int showTimeInterval = 5 * 60 * 1000;

  bool handleReceivedMessage(NERoomChatMessage msg) {
    var valid = false;
    InMessageState? message;
    if (msg is NERoomChatTextMessage && msg.text.isNotEmpty) {
      message = InTextMessage(
        msg.messageUuid,
        msg.time,
        msg.fromNick,
        msg.fromAvatar,
        msg.text,
        msg.messageUuid,
        msg.toUserUuidList,
        msg.fromUserUuid,
        msg.chatroomType,
      );
    } else if (msg is NERoomChatImageMessage) {
      valid = isImageMessageEnabled &&
          msg.path.isNotEmpty &&
          msg.thumbPath.isNotEmpty &&
          msg.width > 0 &&
          msg.height > 0;
      if (valid) {
        message = InImageMessage(
          msg.messageUuid,
          msg.time,
          msg.fromNick,
          msg.fromAvatar,
          msg.thumbPath as String,
          msg.path as String,
          msg.extension,
          msg.size,
          msg.width,
          msg.height,
          msg.messageUuid,
          msg.url,
          msg.toUserUuidList,
          msg.fromUserUuid,
          msg.chatroomType,
        );
      }
    } else if (msg is NERoomChatFileMessage) {
      valid = isFileMessageEnabled &&
          msg.url.isNotEmpty &&
          msg.displayName != null &&
          msg.path != null;
      if (valid) {
        message = InFileMessage(
          msg.messageUuid,
          msg.time,
          msg.fromNick,
          msg.fromAvatar,
          msg.displayName as String,
          msg.path as String,
          msg.size,
          msg.extension,
          msg.messageUuid,
          msg.toUserUuidList,
          msg.fromUserUuid,
          msg.chatroomType,
        );
      }
    } else if (msg is NERoomChatNotificationMessage) {
      var recalledMessageId = msg.recalledMessageId;
      if (recalledMessageId == null) return false;
      final sourceMessage = lookupMessage(recalledMessageId);
      if (sourceMessage == null) return false;

      /// 如果是文件消息，且正在下载，则取消下载
      bool fileCancelDownload = false;
      if (sourceMessage is InFileMessage &&
          sourceMessage.isAttachmentDownloading) {
        sourceMessage.resetAttachmentDownloadProgress();
        fileCancelDownload = true;
      }
      EventBus().emit(
          RecallMessageNotify,
          ChatRecallMessage(recalledMessageId, msg.operateBy?.uuid ?? "",
              fileCancelDownload: fileCancelDownload));
      replaceToRecallMessage(msg);
    }
    if (message != null) {
      append(message, message.time);
    }
    return message != null;
  }

  void replaceToRecallMessage(NERoomChatNotificationMessage msg) {
    List<Object> messageList = messages.toList();
    for (int i = 0; i < messageList.length; i++) {
      var element = messageList[i];
      // 检查是否需要替换该元素
      if (((element is OutMessageState) &&
              (element.msgId == msg.recalledMessageId)) ||
          ((element is InMessageState) &&
              (element.uuid == msg.recalledMessageId))) {
        messageList[i] = InNotificationMessage(
          (element as MessageState).nickname,
          element.avatar,
          msg.messageUuid,
          msg.time,
          msg.eventType,
          msg.operateBy?.uuid,
          msg.recalledMessageId,
          msg.toUserUuidList,
          msg.fromUserUuid,
          msg.chatroomType,
        );
      }
    }
    // 将替换后的列表转换回队列
    messages = Queue.from(messageList);
    messageNotify.add(this);
  }

  MessageState? lookupMessage(String msgId) {
    return messages
        .whereType<MessageState>()
        .toList()
        .where((element) => element.msgId == msgId)
        .firstOrNull;
  }

  bool removeMessage(Object message) {
    return messages.remove(message);
  }

  void append(MessageState message, int time, {bool incUnread = true}) {
    if (time - lastTime > showTimeInterval) {
      messages.add(TimeMessage(time));
      lastTime = time;
    }
    if (messages.length >= maxCacheMessageCount) {
      messages.removeFirst();
    }
    if (messages.lastOrNull is AnchorMessage) {
      messages.removeLast();
    }
    messages.addLast(message);
    messages.addLast(const AnchorMessage());
    if (incUnread) {
      unread++;
    } else {
      unread = 0;
    }
    isInsertMessage = false;
    unreadNotify.add(unread);
    messageNotify.add(this);
    newMessageNotifyTextStream.add(message);
  }

  void insert(List<MessageState> inMessages, int lastTime,
      {bool isFirstInsert = false}) {
    if (inMessages.length == 0) return;
    if (isFirstInsert) {
      firstTime = lastTime;
      messages.addFirst(const HistorySegment());
      if (messages.length >= maxCacheMessageCount || inMessages.length == 0) {
        messages.removeFirst();
        return;
      }
    }

    inMessages.asMap().forEach((index, element) {
      int time = element.time;
      if (index == 0 &&
          !isFirstInsert &&
          (messages.firstOrNull is TimeMessage)) {
        messages.removeFirst();

        /// 当前消息时间
        if (firstTime - time > showTimeInterval) {
          isInsertMessage = true;
          messages.addFirst(TimeMessage(time));
          firstTime = time;
        }
      }
      messages.addFirst(const AnchorMessage());
      if (messages.length >= maxCacheMessageCount) {
        messages.removeFirst();
        return;
      }

      messages.addFirst(element);
      if (firstTime - time > showTimeInterval) {
        isInsertMessage = true;
        messages.addFirst(TimeMessage(time));
        firstTime = time;
      }
      if (messages.length >= maxCacheMessageCount) {
        if (!(messages.firstOrNull is TimeMessage)) {
          isInsertMessage = true;
          messages.addFirst(TimeMessage(time));
        }
        messageNotify.add(this);
        return;
      }

      /// 最后一个
      if (index == inMessages.length - 1 &&
          !(messages.firstOrNull is TimeMessage)) {
        isInsertMessage = true;
        messages.addFirst(TimeMessage(firstTime - showTimeInterval));
      }
    });
    messageNotify.add(this);
  }

  void updateMessageAttachmentProgress(
      String uuid, int transferred, int total) {
    messages
        .whereType<MessageState>()
        .where((msg) => msg.uuid == uuid)
        .forEach((msg) {
      msg.updateProgress(transferred, total);
    });
  }

  void resetUnread() {
    unread = 0;
    unreadNotify.add(unread);
  }

  void dispose() {
    messageNotify.close();
    unreadNotify.close();
    newMessageNotifyTextStream.close();
  }
}

class TimeMessage {
  final int time;

  TimeMessage(this.time);
}

mixin MessageState {
  String get uuid;
  String? get msgId;
  int get time;

  String get nickname;

  String? get avatar;

  bool get isSend;

  NEChatroomType get chatroomType;
  List<String>? get toUserUuidList;

  ValueNotifier<bool> failStatusListenable = ValueNotifier(false);
  bool get isFailed => failStatusListenable.value;

  bool get isHistory;

  bool get isPrivateMessage =>
      toUserUuidList != null && toUserUuidList!.isNotEmpty;

  void updateProgress(int transferred, int total) {
    // do nothing
  }
}

mixin OutMessageState on MessageState {
  final String uuid = Uuid().v4().replaceAll(RegExp(r'-'), '');
  bool isHistory = false;
  int time = DateTime.now().millisecondsSinceEpoch;
  String? msgId;
  final bool isSend = true;
  List<String>? toUserNicknameList;

  ValueNotifier<double> attachmentUploadProgressListenable = ValueNotifier(0.0);

  void startSend(Future<NEResult<NERoomChatMessage>>? job) {
    if (job != null) {
      failStatusListenable.value = false;
      attachmentUploadProgressListenable.value = 0.0;
      job.then((value) {
        if (value.isSuccess()) {
          attachmentUploadProgressListenable.value = 1.0;
          failStatusListenable.value = false;
          msgId = value.data!.messageUuid;
          time = value.data!.time;
        } else {
          attachmentUploadProgressListenable.value = 0.0;
          failStatusListenable.value = true;
        }
      });
    }
  }

  void updateProgress(int transferred, int total) {
    attachmentUploadProgressListenable.value = max(
        transferred.toDouble() / total,
        attachmentUploadProgressListenable.value);
  }

  double get attachmentUploadProgress =>
      attachmentUploadProgressListenable.value;

  OutMessageState copy();
}

mixin InMessageState on MessageState {
  bool isSend = false;

  bool get isSuccess => true;

  String? get attachmentPath;
  bool isHistory = false;
  String? get fromUserUuid;

  ValueNotifier<double> attachmentDownloadProgress = ValueNotifier(0.0);

  void updateProgress(int transferred, int total) async {
    if (transferred < total) {
      attachmentDownloadProgress.value =
          max(transferred.toDouble() / total, attachmentDownloadProgress.value);
    }
    assert(() {
      print(
          'updateProgress: attachmentDownloadProgress=${attachmentDownloadProgress.value}');
      return true;
    }());
    if (attachmentPath != null && await File(attachmentPath!).exists()) {
      attachmentDownloadProgress.value = 1.0;
    }
  }

  void startDownloadAttachment(Future<VoidResult>? job) {
    if (job != null && !isAttachmentDownloaded) {
      failStatusListenable.value = false;
      attachmentDownloadProgress.value = 0.01; // update ui

      job.then((value) {
        Alog.i(
          tag: 'MeetingChatMessage',
          moduleName: _moduleName,
          content: "download attachment result: $uuid $value",
        );
        if (value.isSuccess()) {
          attachmentDownloadProgress.value = 1.0;
        } else {
          attachmentDownloadProgress.value = 0.0;
          failStatusListenable.value = true;
        }
      });
    }
  }

  bool get isAttachmentDownloaded {
    if (attachmentPath == null) return true;
    return attachmentDownloadProgress.value == 1.0 ||
        File(attachmentPath!).existsSync();
  }

  bool get isAttachmentDownloading {
    if (attachmentPath == null) return false;
    return attachmentDownloadProgress.value > 0.0 &&
        attachmentDownloadProgress.value < 1.0;
  }

  void resetAttachmentDownloadProgress() {
    attachmentDownloadProgress.value = 0.0;
  }
}

mixin TextMessageState on MessageState {
  String get text;

  String toString() {
    return 'Txt($text)';
  }
}

class OutTextMessage with MessageState, TextMessageState, OutMessageState {
  final String nickname;
  final String? avatar;
  final String text;
  final List<String>? toUserUuidList;
  final NEChatroomType chatroomType;
  final List<String>? toUserNicknameList;

  OutTextMessage(
    this.nickname,
    this.avatar,
    this.text,
    this.toUserUuidList,
    this.toUserNicknameList,
    this.chatroomType,
  );

  OutTextMessage copy() {
    return OutTextMessage(
      nickname,
      avatar,
      text,
      toUserUuidList,
      toUserNicknameList,
      chatroomType,
    );
  }
}

class InTextMessage with MessageState, TextMessageState, InMessageState {
  final String uuid;
  final int time;
  final String nickname;
  final String? avatar;
  final String text;
  final String msgId;
  final List<String>? toUserUuidList;
  final String? fromUserUuid;
  final NEChatroomType chatroomType;

  InTextMessage(this.uuid, this.time, this.nickname, this.avatar, this.text,
      this.msgId, this.toUserUuidList, this.fromUserUuid, this.chatroomType);

  @override
  String? get attachmentPath => null;
}

mixin ImageMessageState on MessageState {
  String get thumbPath;

  @protected
  ValueNotifier<double> thumbDownloadProgress = ValueNotifier(0.0);
  ValueNotifier<double> originDownloadProgress = ValueNotifier(0.0);

  String get originPath;

  String? extension;

  int get size;

  int? width, height;
  String? url;

  Completer<_ImageInfo>? _thumbImageInfo;
  Completer<_ImageInfo>? _originImageInfo;

  Future<_ImageInfo> get originImageInfo {
    if (_originImageInfo == null) {
      _originImageInfo = Completer();
      final path = originPath;
      final existsSync = File(path).existsSync();
      assert(() {
        print('thumbImageInfo: $uuid, $path, $existsSync');
        return true;
      }());
      if (existsSync) {
        _getSizeAsync(path, isThumb: false);
      } else {
        originDownloadProgress.addListener(() {
          final existsSync = File(path).existsSync();
          assert(() {
            print('thumbImageInfo2: $uuid, $path, $existsSync');
            return true;
          }());
          if (existsSync) {
            _getSizeAsync(path, isThumb: false);
          }
        });
      }
    }
    return _originImageInfo!.future;
  }

  Future<_ImageInfo> get thumbImageInfo {
    if (_thumbImageInfo == null) {
      _thumbImageInfo = Completer();
      final path = thumbPath;
      final existsSync = File(path).existsSync();
      assert(() {
        print('thumbImageInfo: $uuid, $path, $existsSync');
        return true;
      }());
      if (existsSync) {
        _getSizeAsync(path);
      } else {
        thumbDownloadProgress.addListener(() {
          final existsSync = File(path).existsSync();
          assert(() {
            print('thumbImageInfo2: $uuid, $path, $existsSync');
            return true;
          }());
          if (existsSync) {
            _getSizeAsync(path);
          }
        });
      }
    }
    return _thumbImageInfo!.future;
  }

  void _getSizeAsync(String path, {bool isThumb = true}) async {
    if (width == null || height == null) {
      final size = await ImageSizeGetter.getSizeAsync(path);
      width = size[0];
      height = size[1];
      assert(() {
        print('thumbImageInfo3: $uuid, $path, $size');
        return true;
      }());
    }
    if (isThumb) {
      _thumbImageInfo!.complete(_ImageInfo(path, width!, height!));
    } else {
      _originImageInfo!.complete(_ImageInfo(path, width!, height!));
    }
  }
}

class OutImageMessage with MessageState, ImageMessageState, OutMessageState {
  final String nickname;
  final String? avatar;
  final String thumbPath;
  final String originPath;
  final String path;
  final int size;
  final List<String>? toUserUuidList;
  final NEChatroomType chatroomType;
  final List<String>? toUserNicknameList;

  OutImageMessage(this.nickname, this.avatar, this.path, this.size,
      this.toUserUuidList, this.toUserNicknameList, this.chatroomType,
      [int? width, int? height])
      : thumbPath = path,
        originPath = path {
    this.width = width;
    this.height = height;
  }

  OutImageMessage copy() {
    return OutImageMessage(nickname, avatar, path, size, toUserUuidList,
        toUserNicknameList, chatroomType, width, height);
  }
}

class InImageMessage with MessageState, ImageMessageState, InMessageState {
  final String uuid;
  final int time;
  final String nickname;
  final String? avatar;
  final String thumbPath;
  final String originPath;
  final int size;
  final int? width, height;
  final String? url;
  final String? extension;
  final String msgId;
  final List<String>? toUserUuidList;
  final String? fromUserUuid;
  final NEChatroomType chatroomType;

  InImageMessage(
    this.uuid,
    this.time,
    this.nickname,
    this.avatar,
    this.thumbPath,
    this.originPath,
    this.extension,
    this.size,
    this.width,
    this.height,
    this.msgId,
    this.url,
    this.toUserUuidList,
    this.fromUserUuid,
    this.chatroomType,
  );

  @override
  String? get attachmentPath => originPath;

  ValueNotifier<double> thumbImageDownloadProgress = ValueNotifier(0.0);

  void updateProgress(int transferred, int total) async {
    if (size == total) {
      super.updateProgress(transferred, total);
    } else {
      thumbImageDownloadProgress.value =
          max(transferred.toDouble() / total, thumbImageDownloadProgress.value);
    }
    await Future.delayed(Duration(milliseconds: 20));
    if (await File(originPath).exists()) {
      attachmentDownloadProgress.value = 1.0;
      originDownloadProgress.value = 1.0;
    }
    if (await File(thumbPath).exists()) {
      thumbDownloadProgress.value = 1.0;
    }
  }
}

class _ImageInfo {
  final String path;
  final int width;
  final int height;

  _ImageInfo(this.path, this.width, this.height);
}

mixin FileMessageState on MessageState {
  String get path;
  String get name;
  int get size;
  String? get extension;

  String get basename {
    return name.split('.').first;
  }

  String get sizeInfo {
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1048576) {
      return '${(size.toDouble() / 1024).toStringAsFixed(2)}KB';
    } else {
      return '${(size.toDouble() / 1048576).toStringAsFixed(2)}MB';
    }
  }
}

mixin NotificationMessageState on MessageState {
  int get eventType;
  String? get operator;
  String? get recalledMessageId;
}

class InNotificationMessage
    with MessageState, NotificationMessageState, InMessageState {
  final String uuid;
  final int time;
  final int eventType;
  final String? operator;
  final String? recalledMessageId;
  final List<String>? toUserUuidList;
  final String? fromUserUuid;
  final NEChatroomType chatroomType;
  final String nickname;
  final String? avatar;

  InNotificationMessage(
      this.nickname,
      this.avatar,
      this.uuid,
      this.time,
      this.eventType,
      this.operator,
      this.recalledMessageId,
      this.toUserUuidList,
      this.fromUserUuid,
      this.chatroomType);

  @override
  String? get attachmentPath => null;

  @override
  String? get msgId => null;
}

class OutFileMessage with MessageState, FileMessageState, OutMessageState {
  final String nickname;
  final String? avatar;
  final String name;
  final String path;
  final int size;
  final String? extension;
  final List<String>? toUserUuidList;
  final NEChatroomType chatroomType;
  final List<String>? toUserNicknameList;

  OutFileMessage(
      this.nickname,
      this.avatar,
      this.name,
      this.path,
      this.size,
      this.extension,
      this.toUserUuidList,
      this.toUserNicknameList,
      this.chatroomType);

  OutFileMessage copy() {
    return OutFileMessage(nickname, avatar, name, path, size, extension,
        toUserUuidList, toUserNicknameList, chatroomType);
  }
}

class InFileMessage with MessageState, FileMessageState, InMessageState {
  final String uuid;
  final int time;
  final String nickname;
  final String? avatar;
  final String name;
  final String path;
  final int size;
  final String? extension;
  final String msgId;
  final List<String>? toUserUuidList;
  final String? fromUserUuid;
  final NEChatroomType chatroomType;

  InFileMessage(
      this.uuid,
      this.time,
      this.nickname,
      this.avatar,
      this.name,
      this.path,
      this.size,
      this.extension,
      this.msgId,
      this.toUserUuidList,
      this.fromUserUuid,
      this.chatroomType);

  @override
  String? get attachmentPath => path;
}

class AnchorMessage {
  const AnchorMessage();
}

class HistorySegment {
  const HistorySegment();
}
