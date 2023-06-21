// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class ChatRoomArguments {
  ChatRoomMessageSource messageSource;
  final NERoomContext roomContext;

  ChatRoomArguments(this.roomContext, this.messageSource);

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

  final SDKConfig sdkConfig;
  final NEMeetingChatroomConfig _chatroomConfig;

  ChatRoomMessageSource(this.sdkConfig, this._chatroomConfig);

  bool get isFileMessageEnabled {
    return sdkConfig.meetingChatroomConfig.enableFileMessage &&
        _chatroomConfig.enableFileMessage;
  }

  bool get isImageMessageEnabled {
    return sdkConfig.meetingChatroomConfig.enableImageMessage &&
        _chatroomConfig.enableImageMessage;
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

  static const int showTimeInterval = 5 * 60 * 1000;

  bool handleReceivedMessage(NERoomChatMessage msg) {
    var valid = false;
    InMessageState? message;
    if (msg is NERoomChatTextMessage && msg.text.isNotEmpty) {
      message =
          InTextMessage(msg.messageUuid, msg.time, msg.fromNick, msg.text);
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
          msg.thumbPath as String,
          msg.path as String,
          msg.extension,
          msg.size,
          msg.width,
          msg.height,
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
          msg.displayName as String,
          msg.path as String,
          msg.size,
          msg.extension,
        );
      }
    }
    if (message != null) {
      append(message, message.time);
    }
    return message != null;
  }

  bool removeMessage(Object message) {
    return messages.remove(message);
  }

  void append(Object message, int time, {bool incUnread = true}) {
    if (Platform.isIOS) {
      time *= 1000;
    }
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
    unreadNotify.add(unread);
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
  }
}

class TimeMessage {
  final int time;

  TimeMessage(this.time);
}

mixin MessageState {
  String get uuid;

  int get time;

  String get nickname;

  bool get isSend;

  ValueNotifier<bool> failStatusListenable = ValueNotifier(false);
  bool get isFailed => failStatusListenable.value;

  void updateProgress(int transferred, int total) {
    // do nothing
  }
}

mixin OutMessageState on MessageState {
  final String uuid = Uuid().v4().replaceAll(RegExp(r'-'), '');

  final int time = Platform.isIOS
      ? (DateTime.now().millisecondsSinceEpoch / 1000).floor()
      : DateTime.now().millisecondsSinceEpoch;

  final bool isSend = true;

  ValueNotifier<double> attachmentUploadProgressListenable = ValueNotifier(0.0);

  void startSend(Future<VoidResult>? job) {
    if (job != null) {
      failStatusListenable.value = false;
      attachmentUploadProgressListenable.value = 0.0;
      job.then((value) {
        if (value.isSuccess()) {
          attachmentUploadProgressListenable.value = 1.0;
          failStatusListenable.value = false;
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
  final bool isSend = false;

  bool get isSuccess => true;

  String? get attachmentPath;

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
  final String text;

  OutTextMessage(this.nickname, this.text);

  OutTextMessage copy() {
    return OutTextMessage(nickname, text);
  }
}

class InTextMessage with MessageState, TextMessageState, InMessageState {
  final String uuid;
  final int time;
  final String nickname;
  final String text;

  InTextMessage(this.uuid, this.time, this.nickname, this.text);

  @override
  String? get attachmentPath => null;
}

mixin ImageMessageState on MessageState {
  String get thumbPath;

  @protected
  ValueNotifier<double> thumbDownloadProgress = ValueNotifier(0.0);

  String get originPath;

  String? extension;

  int get size;

  int? width, height;

  Completer<_ImageInfo>? _thumbImageInfo;

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

  void _getSizeAsync(String path) async {
    if (width == null || height == null) {
      final size = await ImageSizeGetter.getSizeAsync(path);
      width = size[0];
      height = size[1];
      assert(() {
        print('thumbImageInfo3: $uuid, $path, $size');
        return true;
      }());
    }
    _thumbImageInfo!.complete(_ImageInfo(path, width!, height!));
  }
}

class OutImageMessage with MessageState, ImageMessageState, OutMessageState {
  final String nickname;
  final String thumbPath;
  final String originPath;
  final String path;
  final int size;

  OutImageMessage(this.nickname, this.path, this.size,
      [int? width, int? height])
      : thumbPath = path,
        originPath = path {
    this.width = width;
    this.height = height;
  }

  OutImageMessage copy() {
    return OutImageMessage(nickname, path, size, width, height);
  }
}

class InImageMessage with MessageState, ImageMessageState, InMessageState {
  final String uuid;
  final int time;
  final String nickname;
  final String thumbPath;
  final String originPath;
  final int size;
  final int? width, height;
  final String? extension;

  InImageMessage(
    this.uuid,
    this.time,
    this.nickname,
    this.thumbPath,
    this.originPath,
    this.extension,
    this.size,
    this.width,
    this.height,
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

class OutFileMessage with MessageState, FileMessageState, OutMessageState {
  final String nickname;
  final String name;
  final String path;
  final int size;
  final String? extension;

  OutFileMessage(
      this.nickname, this.name, this.path, this.size, this.extension);

  OutFileMessage copy() {
    return OutFileMessage(nickname, name, path, size, extension);
  }
}

class InFileMessage with MessageState, FileMessageState, InMessageState {
  final String uuid;
  final int time;
  final String nickname;
  final String name;
  final String path;
  final int size;
  final String? extension;

  InFileMessage(this.uuid, this.time, this.nickname, this.name, this.path,
      this.size, this.extension);

  @override
  String? get attachmentPath => path;
}

class AnchorMessage {
  const AnchorMessage();
}
