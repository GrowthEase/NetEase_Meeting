// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class MeetingInviteRepository with _AloggerMixin {
  static final MeetingInviteRepository _instance = MeetingInviteRepository._();

  MeetingInviteRepository._() {
    NERoomKit.instance.messageChannelService.addMessageChannelCallback(
        NEMessageChannelCallback(
            onSessionMessageReceivedCallback: onSessionMessageReceive,
            onCustomMessageReceiveCallback: onCustomMessageReceive));
  }

  factory MeetingInviteRepository() => _instance;

  static const kTypeMeetingInviteStatusChanged = 82;

  static const kTypeMeetingSelfJoinRoom = 30;
  static const kTypeMeetingSelfLeaveByRoomClosed = 33;
  static const kTypeMeetingByRoomClosed = 51;

  ValueListenable<CardData?> get currentInviteData =>
      _InviteQueueUtil.instance.currentInviteData;

  /// 处理自定义消息
  void onCustomMessageReceive(NECustomMessage message) {
    commonLogger.i(
        'onCustomMessageReceive ${message.data} ${message.commandId} ${message.roomUuid}');
    try {
      var data = json.decode(message.data);
      final String? _userUuId = AccountRepository().getAccountInfo()?.userUuid;

      /// 判断被操作人是不是自己
      bool isSelf = false;
      switch (message.commandId) {
        case kTypeMeetingSelfJoinRoom:
        case kTypeMeetingSelfLeaveByRoomClosed:
          isSelf = _userUuId == data?['members']?[0]?['userUuid'];
          break;
        case kTypeMeetingByRoomClosed:
          isSelf = true;
          break;
        case kTypeMeetingInviteStatusChanged:
          isSelf = _userUuId == data['member']['userUuid'];
          break;
      }
      if (isSelf) {
        NEMeetingInviteStatus inviteStatus = NEMeetingInviteStatus.unknown;
        if (message.commandId == kTypeMeetingInviteStatusChanged ||
            message.commandId == kTypeMeetingByRoomClosed) {
          inviteStatus = NEMeetingInviteStatus.canceled;
        }
        if (message.commandId == kTypeMeetingSelfLeaveByRoomClosed ||
            message.commandId == kTypeMeetingSelfJoinRoom) {
          inviteStatus = NEMeetingInviteStatus.removed;
        }

        /// 如果当前会议室和邀请的会议室一致，则直接移除邀请
        /// roomUuid与meetingNum是一致的
        final currentInvite = _InviteQueueUtil.instance
            .getInviteDataByMeetingNum(message.roomUuid ?? '');
        if (currentInvite != null) {
          _InviteQueueUtil.instance.disposeInvite(currentInvite, inviteStatus);
        }
      }
    } catch (e) {
      debugPrint('parse message channel service message error: $e');
    }
  }

  /// 处理会议邀请消息
  void onSessionMessageReceive(NECustomSessionMessage message) async {
    commonLogger.i('receive session message: ${message.data} ');
    final data = NotifyCardData.fromMap(jsonDecode(message.data!));

    /// 处理App邀请消息
    /// timestamp 距离当前60内, 且当前无会议
    if (data.data?.type == NENotifyCenterCardType.meetingInvite &&
        data.data?.timestamp != null &&
        DateTime.now().millisecondsSinceEpoch - data.data!.timestamp! <
            60 * 1000) {
      if (_InviteQueueUtil.instance
              .getInviteDataByMeetingNum(data.data?.meetingNum ?? '') !=
          null) {
        /// 同一会议内的邀请只处理一次，用于处理离线时反复邀请+取消的场景
        commonLogger.i(
            'onSessionMessageReceive, have same invite: ${data.data?.meetingNum}');
        return;
      }
      if (DateTime.now().millisecondsSinceEpoch - data.data!.timestamp! >
          5 * 1000) {
        /// 如果邀请的时间距离现在大于5秒，则很可能是个离线邀请，先查询下会议是否还有效
        final valid = await checkInviteState(data.data?.meetingId ?? 0);
        if (valid.data != true) {
          commonLogger.i(
              'onSessionMessageReceive, invalid meeting state: ${data.data?.meetingNum}');
          final currentInvite = _InviteQueueUtil.instance
              .getInviteDataByMeetingNum(data.data?.meetingNum ?? '');
          if (currentInvite != null) {
            _InviteQueueUtil.instance
                .disposeInvite(currentInvite, NEMeetingInviteStatus.canceled);
          }
          return;
        }
      }
      commonLogger
          .i('onSessionMessageReceive, push invite: ${data.data?.meetingNum}');
      _InviteQueueUtil.instance.pushInvite(data.data);
    }
  }

  /// 清空邀请队列
  void disposeAllInvite(NEMeetingInviteStatus status) {
    _InviteQueueUtil.instance.disposeAllInvite(status);
  }

  Future<NEResult<VoidResult>> rejectInvite(int meetingId) {
    final currentInviteData = _InviteQueueUtil.instance.currentInviteData.value;
    if (currentInviteData?.meetingId != null &&
        currentInviteData?.meetingId == meetingId &&
        currentInviteData?.roomUuid != null) {
      /// 拒绝邀请时，销毁当前邀请
      _InviteQueueUtil.instance
          .disposeInvite(currentInviteData, NEMeetingInviteStatus.rejected);
      return NERoomKit.instance.roomService
          .rejectInvite(currentInviteData!.roomUuid!);
    }
    return Future.value(
        NEResult(code: -1, msg: 'rejectInvite error meetingId not exist'));
  }

  void addMeetingInviteStatusListener(NEMeetingInviteStatusListener listener) {
    _InviteQueueUtil.instance.addMeetingInviteStatusListener(listener);
  }

  void removeMeetingInviteStatusListener(
      NEMeetingInviteStatusListener listener) {
    _InviteQueueUtil.instance.removeMeetingInviteStatusListener(listener);
  }

  Future<NEResult<bool>> checkInviteState(int meetingId) {
    return HttpApiHelper.execute(_CheckInviteStateApi(meetingId));
  }

  Future<NEResult<NERoomSIPCallInfo?>> callOutRoomSystem(
      NERoomSystemDevice device) async {
    final roomContext = MeetingRepository().currentRoomContext;
    if (roomContext == null) {
      return NEResult(
          code: -1, msg: 'callOutRoomSystem error roomContext not exist');
    }
    return roomContext.sipController.callOutRoomSystem(device);
  }
}

///
/// 会议邀请状态监听器，用于监听邀请状态变更事件
///
mixin class NEMeetingInviteStatusListener {
  ///
  /// 会议邀请状态变更通知
  /// [status] 邀请状态
  /// [meetingId] 会议ID
  /// [inviteInfo] 邀请对象信息
  ///
  void onMeetingInviteStatusChanged(NEMeetingInviteStatus status,
      String? meetingId, NEMeetingInviteInfo inviteInfo) {}
}
