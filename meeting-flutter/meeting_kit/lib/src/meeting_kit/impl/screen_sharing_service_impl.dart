// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEScreenSharingCore {
  static _NEScreenSharingCore? _instance;
  static const _tag = '_NEScreenSharingCore';
  factory _NEScreenSharingCore() {
    return _instance ??= _NEScreenSharingCore._internal();
  }
  _NEScreenSharingCore._internal();
  static int? _currentScreenSharingStatus;
  final StreamController<NEScreenSharingEvent> _screenSharingEventController =
      StreamController.broadcast();
  Stream<NEScreenSharingEvent> get screenSharingEventStream =>
      _screenSharingEventController.stream;

  void notifyEventChange(NEScreenSharingEvent event) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'screen share notifyStatusChange, status: ${event.event}');
    if (_currentScreenSharingStatus == event.event) {
      return;
    }
    _currentScreenSharingStatus = event.event;
    _screenSharingEventController.add(event);
  }
}

class _NEScreenSharingServiceImpl extends NEScreenSharingService
    with _AloggerMixin, EventTrackMixin, _MeetingKitLocalizationsMixin {
  static final _NEScreenSharingServiceImpl _instance =
      _NEScreenSharingServiceImpl._();

  factory _NEScreenSharingServiceImpl() => _instance;

  final _roomService = NERoomKit.instance.roomService;
  late NERoomContext _roomContext;
  late NERoomEventCallback roomEventCallback;
  late String? _iOSAppGroup;
  late bool _enableAudioShare;

  /// 状态监听器集合
  final Set<NEScreenSharingStatusListener> _screenSharingListenerSet =
      <NEScreenSharingStatusListener>{};

  _NEScreenSharingServiceImpl._() {
    roomEventCallback = NERoomEventCallback(
      memberJoinRtcChannel: memberJoinRtcChannel,
      roomEnd: onRoomDisconnected,
      memberLeaveRoom: memberLeaveRoom,
      memberScreenShareStateChanged: memberScreenShareStateChanged,
    );
    _NEScreenSharingCore().screenSharingEventStream.listen((event) {
      _screenSharingListenerSet.toList().forEach((element) {
        element(event);
      });
    });
  }

  void memberLeaveRoom(List<NERoomMember> userList) {
    for (var user in userList) {
      if (user.uuid == _roomContext.localMember.uuid) {
        _NEScreenSharingCore().notifyEventChange(
            NEScreenSharingEvent(NEScreenSharingStatus.idle.index));
      }
    }
  }

  void memberScreenShareStateChanged(
      NERoomMember member, bool isSharing, NERoomMember? operator) {
    if (member.uuid == _roomContext.localMember.uuid) {
      if (!isSharing) {
        stopScreenShare(
            reason: operator?.uuid == member.uuid
                ? NERoomEndReason.kLeaveBySelf
                : NERoomEndReason.kKickOut);
      } else {
        _NEScreenSharingCore().notifyEventChange(
            NEScreenSharingEvent(NEScreenSharingStatus.started.index));
      }
    } else {
      apiLogger.i(
          'Screen share changed: member: ${member.uuid}, isSharing: $isSharing');
      if (isSharing) {
        stopScreenShare(reason: NERoomEndReason.kKickOut);
      }
    }
  }

  void memberJoinRtcChannel(List<NERoomMember> members) {
    for (var user in members) {
      if (user.uuid == _roomContext.localMember.uuid) {
        _roomContext.rtcController.muteMyAudio();
        // 加入rtc 通知waiting
        _NEScreenSharingCore().notifyEventChange(
            NEScreenSharingEvent(NEScreenSharingStatus.waiting.index));
        if (Platform.isIOS) {
          _roomContext.rtcController
              .startScreenShare(iosAppGroup: _iOSAppGroup)
              .then((value) {
            if (!value.isSuccess()) {
              apiLogger.i('startScreenShare fail  value: ${value.code}');
              stopScreenShare(reason: NERoomEndReason.kUnknown);
            } else {
              if (_enableAudioShare) {
                _roomContext.rtcController.enableLoopbackRecording(true);
              }
            }
          });
        }
      }
    }
  }

  void onRoomDisconnected(NERoomEndReason reason) {
    var userUuid = _roomContext.rtcController.getScreenSharingUserUuid();
    if (userUuid != null && userUuid == _roomContext.localMember.uuid) {
      _roomContext.rtcController.stopScreenShare();
      _NEScreenSharingCore().notifyEventChange(NEScreenSharingEvent(
          NEScreenSharingStatus.ended.index,
          arg: reason.index));
    }
    _NEScreenSharingCore().notifyEventChange(
        NEScreenSharingEvent(NEScreenSharingStatus.idle.index));
  }

  @override
  Future<NEResult<String>> startScreenShare(
    NEScreenSharingParams param,
    NEScreenSharingOptions opts,
  ) async {
    apiLogger.i('startScreenShare');
    final trackingEvent = param.trackingEvent;

    final checkParamsResult = checkParameters(param);
    if (checkParamsResult != null) {
      return checkParamsResult.cast();
    }
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      return _handleMeetingResultCode(MeetingErrorCode.networkError).cast();
    }

    trackingEvent?.beginStep(kMeetingStepMeetingInfo);
    final meetingInfoResult =
        await MeetingRepository.getMeetingInfoBySharingCode(param.sharingCode);
    trackingEvent?.endStepWithResult(meetingInfoResult);
    if (!meetingInfoResult.isSuccess()) {
      return _handleMeetingResultCode(
              meetingInfoResult.code, meetingInfoResult.msg)
          .cast();
    }

    trackingEvent?.beginStep(kMeetingStepJoinRoom);
    final meetingInfo = meetingInfoResult.nonNullData;
    final authorization = meetingInfo.authorization;
    var joinRoomResult = await _roomService.joinRoom(
      NEJoinRoomParams(
        roomUuid: meetingInfo.roomUuid,
        userName: param.displayName,
        role: MeetingRoles.kScreenSharer,
        injectedAuthorization: authorization != null
            ? NEInjectedAuthorization(
                appKey: authorization.appKey,
                user: authorization.user,
                token: authorization.token)
            : null,
      ),
      NEJoinRoomOptions(
        enableMyAudioDeviceOnJoinRtc: true,
        autoSubscribeAudio: false,
      ),
    );
    trackingEvent?.endStepWithResult(joinRoomResult);
    if (joinRoomResult.code == MeetingErrorCode.success &&
        joinRoomResult.data != null) {
      _roomContext = joinRoomResult.nonNullData;
      _roomContext.setupMeetingEnv(meetingInfo);
      _iOSAppGroup = param.iosAppGroup;
      _enableAudioShare = opts.enableAudioShare;
      _roomContext.addEventCallback(roomEventCallback);
      _roomContext.rtcController.joinRtcChannel();
      return NEResult<String>(
          code: NEMeetingErrorCode.success, data: _roomContext.roomUuid);
    } else {
      return _handleMeetingResultCode(joinRoomResult.code, joinRoomResult.msg)
          .cast();
    }
  }

  /// 统一参数校验
  NEResult<void>? checkParameters(Object param) {
    if (param is NEScreenSharingParams &&
        (param.displayName.isEmpty || param.sharingCode.isEmpty)) {
      return NEResult<void>(
          code: NEMeetingErrorCode.paramError,
          msg: 'displayName or sharingCode should not be empty');
    }
    return null;
  }

  @override
  Future<NEResult<void>> stopScreenShare(
      {NERoomEndReason reason = NERoomEndReason.kLeaveBySelf}) async {
    apiLogger.i('stopScreenShare');
    await _roomContext.rtcController.stopScreenShare();
    _roomContext.removeEventCallback(roomEventCallback);
    _NEScreenSharingCore().notifyEventChange(NEScreenSharingEvent(
        NEScreenSharingStatus.ended.index,
        arg: reason.index));
    final leaveRoomResult = await _roomContext.leaveRoom();
    _NEScreenSharingCore().notifyEventChange(
        NEScreenSharingEvent(NEScreenSharingStatus.idle.index));
    if (leaveRoomResult.isSuccess()) {
      return NEResult(code: NEMeetingErrorCode.success);
    } else {
      return _handleMeetingResultCode(leaveRoomResult.code, leaveRoomResult.msg)
          .cast();
    }
  }

  @override
  void addListener(NEScreenSharingStatusListener listener) {
    _screenSharingListenerSet.add(listener);
  }

  @override
  void removeListener(NEScreenSharingStatusListener listener) {
    _screenSharingListenerSet.remove(listener);
  }
}
