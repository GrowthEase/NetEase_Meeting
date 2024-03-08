// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

abstract class MinimizeMeetingManager {
  Future<NEResult<void>> minimizeCurrentMeeting();
  Future<NEResult<void>> fullCurrentMeeting();
}

abstract class MeetingMenuItemManager {
  Future<NEResult<void>> updateInjectedMenuItem(NEMeetingMenuItem item);
}

abstract class AudioManager {
  /// 订阅会议内某一音频流
  ///
  /// * [accountId] 订阅或者取消订阅的id
  /// * [subscribe] true：订阅， false：取消订阅
  Future<NEResult<void>> subscribeRemoteAudioStream(
      String accountId, bool subscribe);

  /// 批量订阅会议内音频流
  ///
  /// * [accountIds] 订阅或者取消订阅的id列表
  /// * [subscribe] true：订阅， false：取消订阅
  Future<NEResult<List<String>>> subscribeRemoteAudioStreams(
      List<String> accountIds, bool subscribe);

  /// 订阅会议内全部音频流
  ///
  /// * [subscribe] true：订阅， false：取消订阅
  Future<NEResult<void>> subscribeAllRemoteAudioStreams(bool subscribe);

  /// 开启音频dump
  Future<NEResult<void>> startAudioDump();

  /// 关闭音频dump
  Future<NEResult<void>> stopAudioDump();
}

class InMeetingService with _AloggerMixin {
  static final InMeetingService _instance = InMeetingService._();

  factory InMeetingService() => _instance;

  InMeetingService._();

  final StreamController<NEHistoryMeetingItem> _historyMeetingItemStream =
      StreamController.broadcast();

  AudioManager? _audioDelegate;

  AudioManager? get audioManager => _audioDelegate;

  MeetingUIState? _currentMeetingUIState;

  MinimizeMeetingManager? _minimizeDelegate;
  MinimizeMeetingManager? get minimizeDelegate => _minimizeDelegate;

  MeetingMenuItemManager? _menuItemDelegate;
  MeetingMenuItemManager? get menuItemDelegate => _menuItemDelegate;

  void _updateHistoryMeetingItem(NEHistoryMeetingItem? item) {
    if (item != null) {
      _historyMeetingItemStream.add(item);
    }
  }

  Stream<NEHistoryMeetingItem> get historyMeetingItemStream =>
      _historyMeetingItemStream.stream;

  void rememberMeetingUIState(MeetingUIState state) {
    assert(_currentMeetingUIState == null || state == _currentMeetingUIState,
        'Current meeting ui state is not null');
    _currentMeetingUIState = state;
  }

  void clearMeetingUIState() {
    _currentMeetingUIState = null;
  }

  NEMeetingInfo? currentMeetingInfo() {
    final context = _currentMeetingUIState?.roomContext;
    if (context == null) return null;
    final meetingInfo = context.meetingInfo;
    return NEMeetingInfo(
      meetingId: meetingInfo.meetingId,
      meetingNum: meetingInfo.meetingNum,
      shortMeetingNum: meetingInfo.shortMeetingNum,
      sipCid: context.sipCid,
      type: meetingInfo.type.type,
      subject: meetingInfo.subject,
      password: context.password,
      inviteCode: meetingInfo.inviteCode,
      inviteUrl: meetingInfo.inviteUrl,
      startTime: context.rtcStartTime,
      duration: context.rtcStartTime == 0
          ? 0
          : DateTime.now().millisecondsSinceEpoch - context.rtcStartTime,
      scheduleStartTime: meetingInfo.startTime,
      scheduleEndTime: meetingInfo.endTime,
      isHost: context.isMySelfHost(),
      isLocked: context.isRoomLocked,
      isInWaitingRoom: context.isInWaitingRoom(),
      hostUserId: context.getHostUuid() ?? '',
      extraData: context.extraData,
      userList: (context.isInWaitingRoom()
              ? [context.localMember]
              : context.getAllUsers())
          .map((e) => NEInMeetingUserInfo(
              e.uuid, e.name, e.tag, e.role.name, context.isMySelf(e.uuid)))
          .toList(growable: false),
    );
  }

  Future<NEResult<void>> leaveCurrentMeeting(bool closeIfHost) async {
    final context = _currentMeetingUIState?.roomContext;
    if (context != null) {
      final willClose = closeIfHost && context.isMySelfHost();
      return willClose ? context.endRoom() : context.leaveRoom();
    }
    return Future.value(const NEResult(
        code: NEMeetingErrorCode.failed, msg: 'meeting not exists'));
  }
}
