// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 聊天弹幕帮助类，记住消息顺序和透明度，跟随meeting_page生命周期
class MeetingBarrageHelper {
  List<MessageState> _messages = [];
  Map<MessageState, ValueNotifier<double>> _messageOpacityMap = {};
  Timer? timer;
  StreamSubscription<MessageState>? _messageSubscription;
  final _messageStream = StreamController<List<MessageState>>.broadcast();
  Stream<List<MessageState>> get stream =>
      _messageStream.stream.addInitial(_messages);

  void init(Stream<MessageState> messageStream) {
    _messageSubscription?.cancel();
    _messageSubscription = messageStream.listen((event) {
      if (_messages.length > 10) {
        _messageOpacityMap.remove(_messages.removeLast());
      }
      _messages.insert(0, event);
      _messageOpacityMap[event] = ValueNotifier(2.0);
      _startTimer();
      _messageStream.add(_messages);
    });
  }

  ValueNotifier<double> getMessageOpacity(MessageState message) =>
      _messageOpacityMap[message] ?? ValueNotifier(0.0);

  /// 总时长显示8秒，最后4秒渐隐
  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      List<MessageState> messagesToRemove = [];
      _messageOpacityMap.forEach((message, opacity) {
        opacity.value -= 0.0075;
        if (opacity.value <= 0) {
          messagesToRemove.add(message);
        }
      });

      messagesToRemove.forEach((message) {
        _messages.remove(message);
        _messageOpacityMap.remove(message);
      });

      if (_messages.isEmpty) {
        _stopTimer();
      }
      _messageStream.add(_messages);
    });
  }

  void _stopTimer() {
    timer?.cancel();
    timer = null;
  }

  void dispose() {
    _stopTimer();
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }
}
