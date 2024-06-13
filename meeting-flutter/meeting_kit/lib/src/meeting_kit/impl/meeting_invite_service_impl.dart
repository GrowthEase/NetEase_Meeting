// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEMeetingInviteServiceImpl extends NEMeetingInviteService
    with _AloggerMixin, EventTrackMixin, _MeetingKitLocalizationsMixin {
  static final _NEMeetingInviteServiceImpl _instance =
      _NEMeetingInviteServiceImpl._();

  factory _NEMeetingInviteServiceImpl() => _instance;

  final List<NEMeetingInviteStatusListener> _listeners =
      <NEMeetingInviteStatusListener>[];

  List<NEMeetingInviteStatusListener> get listeners => _listeners;

  static const kTypeMeetingInviteStatusChanged = 82;

  static const kTypeMeetingSelfJoinRoom = 30;
  static const kTypeMeetingSelfLeaveByRoomClosed = 33;
  static const kTypeMeetingByRoomClosed = 51;

  NEMeetingInviteStatus _inviteStatus = NEMeetingInviteStatus.unknown;

  _NEMeetingInviteServiceImpl._() {
    NERoomKit.instance.messageChannelService.addMessageChannelCallback(
        NEMessageChannelCallback(
            onCustomMessageReceiveCallback: (message) async {
      try {
        commonLogger.i('invite ,message ${message.data}');

        var data = json.decode(message.data);
        final String? _userUuId = NEMeetingKit.instance
            .getAccountService()
            .getAccountInfo()
            ?.userUuid;

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
          _listeners.forEach((element) {
            /// 如果当前会议室和邀请的会议室一致，则直接移除邀请页面
            final currentInviteData =
                InviteQueueUtil.instance.currentInviteData.value;
            if (currentInviteData?.roomUuid == message.roomUuid) {
              InviteQueueUtil.instance.disposeInvite(currentInviteData);
            }

            /// 如果当前会议室和邀请的会议室一致，则直接移除邀请
            InviteQueueUtil.instance.inviteQueue.forEach((element) {
              if (element.roomUuid == message.roomUuid) {
                InviteQueueUtil.instance.disposeInvite(element);
              }
            });

            final inviteInfoObj = NEMeetingInviteInfo.fromMap(
                currentInviteData?.inviteInfo?.toMap());
            inviteInfoObj.meetingNum = currentInviteData?.meetingNum ?? '';
            final meetingId = currentInviteData?.meetingId ?? '';

            if (message.commandId == kTypeMeetingInviteStatusChanged ||
                message.commandId == kTypeMeetingByRoomClosed) {
              _inviteStatus = NEMeetingInviteStatus.canceled;
            }
            if (message.commandId == kTypeMeetingSelfLeaveByRoomClosed ||
                message.commandId == kTypeMeetingSelfJoinRoom) {
              _inviteStatus = NEMeetingInviteStatus.removed;
            }
            element.onMeetingInviteStatusChanged(
                _inviteStatus, meetingId.toString(), inviteInfoObj);
          });
        }
      } catch (e) {
        debugPrint('parse message channel service message error: $e');
      }
    }));
  }

  @override
  Future<NEResult<NERoomContext>> acceptInvite(
      NEJoinMeetingParams param, NEJoinMeetingOptions opts) async {
    apiLogger.i('acceptInvite param: $param, opts: $opts');
    return MeetingServiceUtil.joinMeetingInternal(
      param,
      opts,
      localizations: localizations,
      isInvite: true,
    );
  }

  @override
  Future<NEResult<VoidResult>> rejectInvite(int meetingId) {
    apiLogger.i('rejectInvite meetingId: $meetingId');
    final currentInviteData = InviteQueueUtil.instance.currentInviteData.value;
    if (currentInviteData?.meetingId != null &&
        currentInviteData?.meetingId == meetingId &&
        currentInviteData?.roomUuid != null) {
      return NERoomKit.instance.roomService
          .rejectInvite(currentInviteData!.roomUuid!);
    }
    return Future.value(
        NEResult(code: -1, msg: 'rejectInvite error meetingId not exist'));
  }

  @override
  void addMeetingInviteStatusListener(NEMeetingInviteStatusListener listener) {
    apiLogger.i('addMeetingInviteStatusListener, listener: $listener');
    if (_listeners.contains(listener)) {
      return;
    }
    _listeners.add(listener);
  }

  @override
  void removeMeetingInviteStatusListener(
      NEMeetingInviteStatusListener listener) {
    apiLogger.i('removeMeetingInviteStatusListener, listener: $listener');
    if (_listeners.contains(listener)) {
      _listeners.remove(listener);
    }
  }
}
