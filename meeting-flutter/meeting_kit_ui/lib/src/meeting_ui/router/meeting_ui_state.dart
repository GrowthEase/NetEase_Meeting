// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingUIState extends ChangeNotifier
    with NEWaitingRoomListener, WidgetsBindingObserver, _AloggerMixin {
  MeetingUIState(NERoomContext roomContext, this._arguments)
      : assert(roomContext == _arguments.roomContext),
        _isInWaitingRoom = roomContext.isInWaitingRoom(),
        _isInMeeting = !roomContext.isInWaitingRoom() {
    _currentRoomContext = roomContext;
    updateRoomContext(roomContext);
    WidgetsBinding.instance.addObserver(this);
  }

  late final _roomEventCallback = NERoomEventCallback(
    roomEnd: (NERoomEndReason reason) {
      debugPrint('roomEnd: $reason');
      _roomEndReason = reason;
      _roomEndStreamController.add(reason);
    },
  );

  NERoomEndReason? _roomEndReason;
  final _roomEndStreamController =
      StreamController<NERoomEndReason>.broadcast();
  Stream<NERoomEndReason> get roomEndStream {
    if (_roomEndReason != null) {
      return Stream.value(_roomEndReason!);
    } else {
      return Stream.fromFuture(_roomEndStreamController.stream.first);
    }
  }

  late NERoomContext _currentRoomContext;
  NERoomContext get roomContext => _currentRoomContext;
  void updateRoomContext(NERoomContext roomContext) {
    debugPrint('updateRoomContext');
    _currentRoomContext.removeEventCallback(_roomEventCallback);
    _currentRoomContext.waitingRoomController.removeListener(this);
    roomContext.addEventCallback(_roomEventCallback);
    roomContext.waitingRoomController.addListener(this);
    _roomEndReason = null;
    _currentRoomContext = roomContext;
  }

  bool _isInWaitingRoom = false;

  bool get isInWaitingRoom => _isInWaitingRoom;

  bool _isInMeeting = false;

  bool get isInMeeting => _isInMeeting;

  MeetingArguments _arguments;

  MeetingArguments get meetingArguments => _arguments;

  void navigateToInMeetingFromWaitingRoom(
      {required MeetingArguments arguments}) {
    debugPrint('navigateToInMeetingFromWaitingRoom');
    _isInWaitingRoom = false;
    _isInMeeting = true;
    _arguments = arguments;
    notifyListeners();
  }

  void navigateToWaitingRoomFromInMeeting(
      {required MeetingArguments arguments}) {
    debugPrint('navigateToWaitingRoomFromInMeeting');
    _isInWaitingRoom = true;
    _isInMeeting = false;
    _arguments = arguments;
    notifyListeners();
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
      return Stream.fromFuture(_waitingRoomStatusStreamController.stream
          .firstWhere(
              (status) => NEWaitingRoomConstants.STATUS_ADMITTED == status));
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
      return Stream.fromFuture(_waitingRoomStatusStreamController.stream
          .firstWhere(
              (status) => NEWaitingRoomConstants.STATUS_WAITING == status));
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

  /// 当前会议是否处于最小化状态，可能是通过点击最小化按钮或通过会议组件提供的最小化接口
  bool isMinimized = false;

  @override
  void dispose() {
    _currentRoomContext.removeEventCallback(_roomEventCallback);
    _currentRoomContext.waitingRoomController.removeListener(this);
    _roomEndStreamController.close();
    _waitingRoomStatusStreamController.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  String toString() {
    return 'MeetingUIState{isInWaitingRoom: $_isInWaitingRoom, isInMeeting: $_isInMeeting}';
  }
}
