// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 屏幕共享服务接口，用于创建和管理屏幕共享、添加共享状态监听等。可通过 [NEMeetingUIKit.instance.get] 获取对应的服务实例
abstract class NEMeetingUIKitScreenSharingService {
  static final NEMeetingUIKitScreenSharingService _instance =
      _NEMeetingUIKitScreenSharingServiceImpl();

  /// 获取会议NEMeetingUIKitScreenSharingService SDK实例
  static NEMeetingUIKitScreenSharingService get instance => _instance;

  /// 开启一个开启屏幕共享，只有完成SDK的登录鉴权操作才允许开启屏幕共享。
  ///
  /// * [param] 屏幕共享参数对象，不能为空
  /// * [opts]  屏幕共享选项对象，可空；当未指定时，会使用默认的选项
  ///
  Future<NEResult<String>> startScreenShare(
    NEScreenSharingParams param,
    NEScreenSharingOptions opts,
  );

  ///
  /// 停止屏幕共享
  /// 回调接口。该回调不会返回额外的结果数据
  ///
  Future<NEResult<void>> stopScreenShare();

  ///
  /// 添加共享屏幕状态监听实例，用于接收共享屏幕状态变更通知
  ///
  /// [listener] 要添加的监听实例
  ///
  void addScreenSharingStatusListener(NEScreenSharingStatusListener listener);

  ///
  /// 移除对应的会议共享屏幕状态的监听实例
  ///
  /// [listener] 要移除的监听实例
  ///
  void removeScreenSharingStatusListener(
      NEScreenSharingStatusListener listener);
}

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

class _NEMeetingUIKitScreenSharingServiceImpl
    extends NEMeetingUIKitScreenSharingService
    with _AloggerMixin, WidgetsBindingObserver {
  /// 状态监听器集合
  final Set<NEScreenSharingStatusListener> _screenSharingListenerSet =
      <NEScreenSharingStatusListener>{};

  _NEMeetingUIKitScreenSharingServiceImpl() {
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

  final _roomService = NERoomKit.instance.roomService;
  late NERoomContext _roomContext;
  late NERoomEventCallback roomEventCallback;
  late bool _enableAudioShare;

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
        _stopScreenShareInterner(
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
        _stopScreenShareInterner(reason: NERoomEndReason.kKickOut);
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
              .startScreenShare(
                  iosAppGroup:
                      NEMeetingUIKit.instance.uiConfig?.iosBroadcastAppGroup)
              .then((value) {
            if (!value.isSuccess()) {
              apiLogger.i('startScreenShare fail  value: ${value.code}');
              _stopScreenShareInterner(reason: NERoomEndReason.kUnknown);
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
  void addScreenSharingStatusListener(NEScreenSharingStatusListener listener) {
    _screenSharingListenerSet.add(listener);
  }

  @override
  void removeScreenSharingStatusListener(
      NEScreenSharingStatusListener listener) {
    _screenSharingListenerSet.remove(listener);
  }

  Future<NEResult<String>> startScreenShare(
    NEScreenSharingParams param,
    NEScreenSharingOptions opts,
  ) async {
    apiLogger.i('startScreenShare');
    if (Platform.isAndroid) {
      /// Android 显示前台服务通知
      final foregroundConfig = await MeetingCore().getForegroundConfig();
      if (foregroundConfig != null) {
        await NEMeetingPlugin().getNotificationService().startForegroundService(
            foregroundConfig, NENotificationService.serviceTypeMediaProjection);
      }
    }

    final checkParamsResult = checkParameters(param);
    if (checkParamsResult != null) {
      return checkParamsResult.cast();
    }
    if (!await ConnectivityManager().isConnected()) {
      return handleMeetingResultCode(MeetingErrorCode.networkError).cast();
    }

    final meetingInfoResult = await MeetingRepository()
        .getMeetingInfoBySharingCode(param.sharingCode);
    if (!meetingInfoResult.isSuccess()) {
      return handleMeetingResultCode(
              meetingInfoResult.code, meetingInfoResult.msg)
          .cast();
    }

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
    if (joinRoomResult.code == MeetingErrorCode.success &&
        joinRoomResult.data != null) {
      _roomContext = joinRoomResult.nonNullData;
      _roomContext.setupMeetingEnv(meetingInfo);
      _enableAudioShare = opts.enableAudioShare;
      _roomContext.addEventCallback(roomEventCallback);
      _roomContext.rtcController.joinRtcChannel();
      return NEResult<String>(
          code: NEMeetingErrorCode.success, data: _roomContext.roomUuid);
    } else {
      if (Platform.isAndroid) {
        final ForegroundConfigResult =
            await MeetingCore().getForegroundConfig();
        if (ForegroundConfigResult != null) {
          await NEMeetingPlugin()
              .getNotificationService()
              .stopForegroundService();
        }
      }
      return handleMeetingResultCode(joinRoomResult.code, joinRoomResult.msg)
          .cast();
    }
  }

  @override
  Future<NEResult<void>> stopScreenShare() {
    return _stopScreenShareInterner(reason: NERoomEndReason.kLeaveBySelf);
  }

  ///
  /// 停止屏幕共享, 会自动离开房间,内部接口
  ///
  Future<NEResult<void>> _stopScreenShareInterner(
      {required NERoomEndReason reason}) async {
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
      return handleMeetingResultCode(leaveRoomResult.code, leaveRoomResult.msg)
          .cast();
    }
  }
}
