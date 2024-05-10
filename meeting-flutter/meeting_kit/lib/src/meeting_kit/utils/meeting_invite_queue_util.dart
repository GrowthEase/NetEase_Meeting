// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 邀请加入事件类型
/// [InviteJoinActionType] 邀请加入事件类型
typedef InviteAction = void Function(InviteJoinActionType type);

/// 邀请加入事件类型
/// [InviteJoinEvent] 邀请加入事件
/// [videoMute] 是否关闭视频
typedef HandleInviteEvent = Future<void> Function(
    CardData? inviteData, bool videoMute);

/// App邀请邀请消息队列工具类
class InviteQueueUtil {
  InviteQueueUtil._() {
    /// 退出登录时，邀请队列清空
    NERoomKit.instance.authService.onAuthEvent.listen((event) {
      if (event != NEAuthEvent.kLoggedIn && event != NEAuthEvent.kReconnected) {
        disposeAllInvite();
      }
    });
  }

  static InviteQueueUtil get instance => _getInstance();
  static InviteQueueUtil? _instance;

  static InviteQueueUtil _getInstance() {
    _instance ??= InviteQueueUtil._();
    return _instance!;
  }

  final _inviteTimerMap = <CardData, Timer>{};
  final _inviteQueue = Queue<CardData>();

  get inviteQueue => _inviteQueue;

  ValueNotifier<CardData?> _currentInviteData = ValueNotifier(null);

  ValueListenable<CardData?> get currentInviteData => _currentInviteData;

  /// 接收到邀请
  void pushInvite(CardData? cardData) {
    if (cardData == null) return;
    _inviteQueue.add(cardData);
    Timer _inviteTimer =
        Timer(Duration(seconds: cardData.popupDuration ?? 60), () {
      disposeInvite(cardData);
    });
    _inviteTimerMap.putIfAbsent(cardData, () => _inviteTimer);
    _loopInviteQueue();
  }

  /// 邀请队列loop
  void _loopInviteQueue() {
    if (_currentInviteData.value == null && _inviteQueue.isNotEmpty) {
      final invite = _inviteQueue.removeFirst();
      if (invite.inviteInfo == null) {
        _loopInviteQueue();
        return;
      }
      _currentInviteData.value = invite;
    }
  }

  /// 通过meetingId获取当前邀请数据
  /// [meetingNum] 会议meetingNum
  ///
  CardData? getInviteDataByMeetingNum(String meetingNum) {
    if (_currentInviteData.value != null &&
        _currentInviteData.value?.meetingNum == meetingNum) {
      return _currentInviteData.value;
    }
    return _inviteQueue
        .toList()
        .where((element) => element.meetingNum == meetingNum)
        .firstOrNull;
  }

  /// 销毁邀请
  void disposeInvite(CardData? inviteData) {
    if (inviteData == null) return;
    _inviteQueue.remove(inviteData);
    _inviteTimerMap.remove(inviteData)?.cancel();
    if (_currentInviteData.value == inviteData) {
      _currentInviteData.value = null;
      _loopInviteQueue();
    }
  }

  /// 销毁全部邀请
  void disposeAllInvite() {
    _inviteQueue.clear();
    _inviteTimerMap.forEach((key, value) {
      value.cancel();
    });
    _inviteTimerMap.clear();
    _currentInviteData.value = null;
  }
}

/// 邀请加入操作类型
class InviteJoinActionEvent {
  InviteJoinActionType type;
  CardData? cardData;

  InviteJoinActionEvent(this.type, this.cardData);
}

/// 邀请加入操作类型
enum InviteJoinActionType {
  /// 音频接受
  audioAccept,

  /// 视频接受
  videoAccept,

  /// 拒绝
  reject,
}
