// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

abstract class ChatroomInstance with ChangeNotifier {
  NEChatroomType get chatroomType;
  bool get hasJoin;
  Future<VoidResult> join();
  Future leave();
  Future ensureJoined();
}

class FakeChatroomInstance extends ChatroomInstance {
  final NEChatroomType chatroomType;

  FakeChatroomInstance(this.chatroomType);

  @override
  bool get hasJoin => false;

  @override
  Future<VoidResult> join() async {
    return VoidResult(code: NEMeetingErrorCode.chatroomNotExists);
  }

  @override
  Future leave() async {}

  @override
  Future ensureJoined() async {}
}

class RealChatroomInstance extends ChatroomInstance with _AloggerMixin {
  static const _maxRetry = 3;

  final NERoomContext roomContext;
  final NEChatroomType chatroomType;

  var _chatroomNotExists = false;
  var _disposed = false;
  var _hasJoin = false;
  Completer<VoidResult>? _joinCompleter;
  Completer? _leaveCompleter;

  RealChatroomInstance(this.roomContext, this.chatroomType);

  bool get hasJoin => _hasJoin;

  @override
  Future ensureJoined() async {
    if (hasJoin) return;
    await _joinCompleter?.future;
  }

  Future<VoidResult> join() async {
    if (_disposed || _chatroomNotExists)
      return VoidResult(code: NEMeetingErrorCode.chatroomNotExists);
    if (_hasJoin) return VoidResult.success();
    if (_joinCompleter == null) {
      _joinCompleter = Completer<VoidResult>();
      _joinImpl();
    }
    return _joinCompleter!.future;
  }

  void _joinImpl() async {
    final joining = _joinCompleter!;
    // 等待上一次离开流程结束
    final leaving = _leaveCompleter;
    if (leaving != null) {
      _leaveCompleter = null;
      await leaving.future;
    }
    ValueGetter<bool> cancelled = () => joining != _joinCompleter;
    commonLogger.i('join chatroom: $chatroomType');
    VoidResult joinResult = VoidResult(code: -1);
    for (var index = 0; index < _maxRetry; index++) {
      joinResult = await roomContext.chatController
          .joinChatroom(chatroomType: chatroomType);
      commonLogger.i(
          'join chatroom: type=$chatroomType, index=$index, cancelled=${cancelled()}, result=$joinResult');
      if (_disposed || cancelled()) break;
      // 聊天室不存在，不再重试，并标记为不存在
      if (joinResult.code == NEMeetingErrorCode.chatroomNotExists) {
        commonLogger.i('join chatroom fail due to not exists');
        _chatroomNotExists = true;
        _joinCompleter = null;
        break;
      } else if (joinResult.isSuccess()) {
        commonLogger.i('join chatroom succeed');
        _hasJoin = true;
        _joinCompleter = null;
        notifyListeners();
        break;
      }
      // 异常Case：Android端在IM重连过程中，会导致聊天室加入失败，返回 1000 错误码
      // 需要重试，等待 IM 重连成功后在执行加入聊天室的操作
      await Future.delayed(Duration(seconds: pow(2, index).toInt()));
      if (_disposed || cancelled()) break;
    }
    joining.complete(joinResult);
  }

  Future leave() async {
    if (_disposed ||
        (!_hasJoin && _joinCompleter == null) ||
        _chatroomNotExists) return;
    if (_leaveCompleter == null) {
      _leaveCompleter = Completer();
      _leaveImpl();
    }
    return _leaveCompleter!.future;
  }

  void _leaveImpl() async {
    final leaving = _leaveCompleter!;
    // 等待上一次加入流程结束
    final joining = _joinCompleter;
    if (joining != null) {
      // this will cancel current join
      _joinCompleter = null;
      await joining.future;
    }
    commonLogger.i('leave chatroom: $chatroomType');
    await roomContext.chatController.leaveChatroom(chatroomType: chatroomType);
    _hasJoin = false;
    if (!_disposed) notifyListeners();
    leaving.complete();
    if (leaving == _leaveCompleter) {
      _leaveCompleter = null;
    }
  }

  @override
  void dispose() {
    leave();
    _disposed = true;
    super.dispose();
  }
}
