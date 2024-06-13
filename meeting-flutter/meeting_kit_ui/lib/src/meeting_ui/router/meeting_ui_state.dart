// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

typedef PopHandler({Object? result, int? disconnectingCode});

class MeetingUINavigator extends ChangeNotifier with _AloggerMixin {
  PopHandler? popHandler;
  void pop({Object? result, int? disconnectingCode}) {
    commonLogger.i('pop');
    popHandler?.call(result: result, disconnectingCode: disconnectingCode);
    if (_isActive) {
      _isActive = false;
      notifyListeners();
    }
  }

  bool _isActive = true;
  bool get isActive => _isActive;

  void initMeeting(MeetingArguments arguments) {
    commonLogger.i('initMeeting');
    final roomContext = arguments.roomContext;
    if (roomContext.isInWaitingRoom()) {
      navigateToWaitingRoomFromInMeeting(arguments: arguments);
    } else {
      navigateToInMeetingFromWaitingRoom(arguments: arguments);
    }
  }

  bool _isInWaitingRoom = false;
  bool get isInWaitingRoom => _isInWaitingRoom && _isActive;
  void navigateToWaitingRoomFromInMeeting(
      {required MeetingArguments arguments}) {
    commonLogger.i('navigateToWaitingRoomFromInMeeting');
    _isInWaitingRoom = true;
    _isInMeeting = false;
    _ensureMeetingStates(arguments);
    notifyListeners();
  }

  bool _isInMeeting = false;
  bool get isInMeeting => _isInMeeting && _isActive;
  void navigateToInMeetingFromWaitingRoom(
      {required MeetingArguments arguments}) {
    commonLogger.i('navigateToInMeetingFromWaitingRoom');
    _isInWaitingRoom = false;
    _isInMeeting = true;
    _ensureMeetingStates(arguments);
    notifyListeners();
  }

  void _ensureMeetingStates(MeetingArguments arguments) {
    /// roomContext 发生变化，如异常断开后重新入会
    if (_meetingUIState._roomContext != arguments.roomContext) {
      _meetingLifecycleState.dispose();
      _meetingLifecycleState = MeetingLifecycleState(arguments.roomContext);
    }

    InMeetingService().clearMeetingUIState(_meetingUIState);

    /// 每次都创建新的状态对象
    _meetingUIState.dispose();
    _meetingUIState = MeetingUIState(arguments, _meetingLifecycleState);
    InMeetingService().rememberMeetingUIState(_meetingUIState);
  }

  var _meetingLifecycleState = MeetingLifecycleState();
  MeetingLifecycleState get meetingLifecycleState => _meetingLifecycleState;

  var _meetingUIState = MeetingUIState();
  MeetingUIState get meetingUIState => _meetingUIState;

  MeetingArguments get meetingArguments => _meetingUIState.meetingArguments;

  NERoomContext get roomContext => _meetingUIState.roomContext;

  @override
  void dispose() {
    _meetingLifecycleState.dispose();
    _meetingUIState.dispose();
    InMeetingService().clearMeetingUIState(_meetingUIState);
    super.dispose();
  }
}

/// 会议生命周期状态管理
class MeetingLifecycleState extends ChangeNotifier
    with NEWaitingRoomListener, WidgetsBindingObserver, _AloggerMixin {
  final NERoomContext? roomContext;

  MeetingLifecycleState([this.roomContext]) {
    if (roomContext != null) {
      roomContext!.addEventCallback(_roomEventCallback);
      roomContext!.waitingRoomController.addListener(this);
      WidgetsBinding.instance.addObserver(this);
    }
  }

  /// 当前会议是否处于最小化状态，可能是通过点击最小化按钮或通过会议组件提供的最小化接口
  bool isMinimized = false;

  late final _roomEventCallback = NERoomEventCallback(
    roomEnd: (NERoomEndReason reason) {
      commonLogger.i('roomEnd: $reason');
      _roomEndReason = reason;
      _roomEndStreamController.add(reason);
    },
  );

  bool get roomEnded => _roomEndReason != null;

  NERoomEndReason? _roomEndReason;
  final _roomEndStreamController =
      StreamController<NERoomEndReason>.broadcast();
  Stream<NERoomEndReason> get roomEndStream {
    if (_roomEndReason != null) {
      return Stream.value(_roomEndReason!);
    } else {
      final controller = StreamController<NERoomEndReason>(sync: true);
      _roomEndStreamController.stream.first.then((value) {
        controller.add(value);
        controller.close();
      }, onError: (error, stackTrace) {
        controller.close();
      });
      return controller.stream;
    }
  }

  int? _waitingRoomStatus, _pendingWaitingRoomStatus;
  final _waitingRoomStatusStreamController = StreamController<int>.broadcast();
  @override
  void onMyWaitingRoomStatusChanged(int status, int reason) {
    if (_roomEndReason != null &&
        _roomEndReason != NERoomEndReason.kSyncDataError &&
        _roomEndReason != NERoomEndReason.kEndOfRtc) return;
    commonLogger.i(
      'onMyWaitingRoomStatusChanged: status=$status, reason=$reason, foreground=$_isInForeground',
    );
    _waitingRoomStatus = status;
    if (_isInForeground || status == NEWaitingRoomConstants.STATUS_WAITING) {
      _pendingWaitingRoomStatus = null;
      _waitingRoomStatusStreamController.add(status);
    } else {
      _pendingWaitingRoomStatus = status;
    }
  }

  Stream<int> get onAdmittedToMeeting {
    if (_roomEndReason != null) {
      return Stream.empty();
    }
    final status = _waitingRoomStatus;
    if (status == NEWaitingRoomConstants.STATUS_ADMITTED) {
      return Stream.value(status!);
    } else {
      return _waitingRoomStatusStreamController.stream
          .where((status) => NEWaitingRoomConstants.STATUS_ADMITTED == status)
          .take(1);
    }
  }

  Stream<int> get onPuttedInWaitingRoom {
    if (_roomEndReason != null) {
      return Stream.empty();
    }
    final status = _waitingRoomStatus;
    if (status == NEWaitingRoomConstants.STATUS_WAITING) {
      return Stream.value(status!);
    } else {
      return _waitingRoomStatusStreamController.stream
          .where(
            (status) => NEWaitingRoomConstants.STATUS_WAITING == status,
          )
          .take(1);
    }
  }

  bool _isInForeground = true;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isInForeground = state == AppLifecycleState.inactive ||
        state == AppLifecycleState.resumed;
    if (_isInForeground != isInForeground) {
      isInForeground ? _onEnterForeground() : _onEnterBackground();
      _isInForeground = isInForeground;
    }
  }

  void _onEnterForeground() {
    if (_pendingWaitingRoomStatus != null && _roomEndReason == null) {
      commonLogger
          .i('Handle pending waiting room status: $_pendingWaitingRoomStatus');
      _waitingRoomStatusStreamController.add(_pendingWaitingRoomStatus!);
      _pendingWaitingRoomStatus = null;
    }
  }

  void _onEnterBackground() {}

  @override
  void dispose() {
    if (roomContext != null) {
      roomContext!.removeEventCallback(_roomEventCallback);
      roomContext!.waitingRoomController.removeListener(this);
      WidgetsBinding.instance.removeObserver(this);
    }
    _roomEndStreamController.close();
    _waitingRoomStatusStreamController.close();
    super.dispose();
  }

  @override
  String toString() {
    return 'MeetingLifecycleState{'
        'roomEndReason: $_roomEndReason, '
        'waitingRoomStatus: $_waitingRoomStatus, '
        'pendingWaitingRoomStatus: $_pendingWaitingRoomStatus, '
        'isInForeground: $_isInForeground'
        '}';
  }
}

/// 会议 UI 状态管理
class MeetingUIState extends ChangeNotifier with _AloggerMixin {
  MeetingUIState([this._arguments, this._lifecycleState])
      : _roomContext = _arguments?.roomContext {
    if (_roomContext != null) {
      _inMeetingChatroom =
          RealChatroomInstance(_roomContext!, NEChatroomType.common)
            ..addListener(notifyListeners);
      _waitingRoomChatroom =
          RealChatroomInstance(_roomContext!, NEChatroomType.waitingRoom)
            ..addListener(notifyListeners);
    }
  }

  final MeetingArguments? _arguments;
  final MeetingLifecycleState? _lifecycleState;
  final NERoomContext? _roomContext;

  ChatroomInstance _inMeetingChatroom =
      FakeChatroomInstance(NEChatroomType.common);
  ChatroomInstance get inMeetingChatroom => _inMeetingChatroom;

  ChatroomInstance _waitingRoomChatroom =
      FakeChatroomInstance(NEChatroomType.waitingRoom);
  ChatroomInstance get waitingRoomChatroom => _waitingRoomChatroom;

  MeetingArguments get meetingArguments => _arguments!;
  NERoomContext get roomContext => _roomContext!;

  bool get isMinimized => _lifecycleState?.isMinimized ?? false;
  set isMinimized(bool value) => _lifecycleState?.isMinimized = value;

  /// 本地锁定视频的用户，优先级低于“焦点视频”
  String? _lockedUser;
  String? get lockedUser => _lockedUser;
  void lockUserVideo(String? userId) {
    if (userId != _lockedUser) {
      commonLogger.i('lockUserVideo: $_lockedUser -> $userId');
      _lockedUser = userId;
      notifyListeners();
    }
  }

  /// 同声传译控制器
  NEInterpretationController? _interpretationController;
  NEInterpretationController get interpretationController {
    _interpretationController ??= NEInterpretationController(
      roomContext,
      sdkConfig.interpretationConfig,
    );
    return _interpretationController!;
  }

  SDKConfig? _crossAppSDKConfig;
  SDKConfig get sdkConfig {
    if (roomContext.isCrossAppJoining) {
      if (_crossAppSDKConfig == null) {
        _crossAppSDKConfig =
            SDKConfig(roomContext.crossAppAuthorization!.appKey);
        _crossAppSDKConfig!.initialize();
      }
      return _crossAppSDKConfig!;
    }
    return SDKConfig.current;
  }

  @override
  void dispose() {
    inMeetingChatroom.dispose();
    waitingRoomChatroom.dispose();
    _interpretationController?.dispose();
    _crossAppSDKConfig?.dispose();
    super.dispose();
  }
}

mixin MeetingNavigatorScope<T extends StatefulWidget> on State<T> {
  late MeetingUINavigator meetingNavigator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    meetingNavigator = Provider.of<MeetingUINavigator>(context);
  }
}

mixin MeetingStateScope<T extends StatefulWidget> on State<T> {
  late MeetingLifecycleState meetingLifecycleState;
  late MeetingUIState meetingUIState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    meetingLifecycleState =
        Provider.of<MeetingLifecycleState?>(context) ?? MeetingLifecycleState();
    meetingUIState = Provider.of<MeetingUIState?>(context) ?? MeetingUIState();
  }

  NERoomContext getRoomContext() => meetingUIState.roomContext;
}
