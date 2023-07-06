// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_ui;

const _tag = 'MeetingPage';

class MeetingPage extends StatefulWidget {
  final MeetingArguments arguments;

  MeetingPage(this.arguments) {
    assert(() {
      print('debug create');
      return true;
    }());
  }

  @override
  State<StatefulWidget> createState() {
    return MeetingBusinessUiState(arguments);
  }
}

class MeetingBusinessUiState extends LifecycleBaseState<MeetingPage>
    with
        TickerProviderStateMixin,
        EventTrackMixin,
        NERoomUserVideoViewListener,
        AudioManager,
        MinimizeMeetingManager,
        _AloggerMixin,
        InMeetingDataServiceCallback {
  MeetingBusinessUiState(this.arguments);

  @override
  String get logTag => _tag;

  var galleryItemSize = 4;

  final MeetingArguments arguments;

  int _currentExitCode = 0;

  bool _isEverConnected = false;
  MeetingState _meetingState = MeetingState.init;

  /// 显示逻辑，有焦点显示焦点， 否则显示活跃， 否则显示host，否则显示自己, speakingUid与activeUid相同，当没有人说话时，activeUid不变，speakingUid置空
  String? focusUid, activeUid, bigUid, smallUid, speakingUid;

  Timer? joinTimeOut, _inComingTipsTimer;

  late ValueNotifier<int> _meetingMemberCount;

  ValueListenable<int> get meetingMemberCountListenable => _meetingMemberCount;

  late final ChatRoomMessageSource _messageSource;

  late ValueNotifier<_NetworkStatus> _networkStats;

  ValueListenable<_NetworkStatus> get meetingNetworkStatsListenable =>
      _networkStats;

  late ValueNotifier<NetWorkRttInfo> _networkInfo;

  ValueListenable<NetWorkRttInfo> get meetingNetworkInfoListenable =>
      _networkInfo;

  late ValueNotifier<bool> _isGalleryLayout;
  ValueListenable<bool> get isGalleryLayout => _isGalleryLayout;

  bool _isShowOpenMicroDialog = false,
      _isShowOpenVideoDialog = false,
      switchBigAndSmall = false,
      interceptEvent = false,
      // _isEditStatus = false,
      autoSubscribeAudio = true;

  bool _invitingToOpenAudio = false, _invitingToOpenVideo = false;

  PointerEvent? downPointEvent;

  PageController? _galleryModePageController;

  double? aspectRatio = 9 / 16,
      vPaddingTop,
      vPaddingLR,
      hPaddingTop,
      hPaddingLR;

  WindowMode _windowMode = WindowMode.gallery;

  static const double appBarHeight = 64, bottomBarHeight = 54, space = 0;

  late AnimationController appBarAnimController;

  late Animation<Offset> bottomAnim, topBarAnim, meetingEndTipAnim;

  late Animation<double> localAudioVolumeIndicatorAnim;

  late int meetingBeginTime;

  bool _isAlreadyCancel = false,
      _isMinimized = false,
      _hasRequestEngineToDetach = false,
      _isPortrait = true;

  bool _isIpad = false;
  final localMirrorState = ValueNotifier(true);
  final alwaysUnMirrorState = ValueNotifier(false);

  OverlayEntry? _overlayEntry;

  final _audioDeviceSelected = ValueNotifier(NEAudioOutputDevice.kSpeakerPhone);

  int beautyLevel = 0;

  int meetingEndTipMin = 0;
  bool showMeetingEndTip = false;
  int _remainingSeconds = 0;
  Stopwatch _remainingSecondsAdjustment = Stopwatch();
  final streamSubscriptions = <StreamSubscription>[];

  final StreamController<Object> roomInfoUpdatedEventStream =
      StreamController.broadcast();
  late final NERoomWhiteboardController whiteboardController;
  late final NERoomChatController chatController;
  late final NERoomRtcController rtcController;
  late final NEMessageChannelCallback messageCallback;
  late final NERoomEventCallback roomEventCallback;
  late final NERoomRtcStatsCallback roomStatsCallback;

  ValueNotifier<bool> whiteBoardInteractionStatusNotifier =
      ValueNotifier<bool>(false);
  ValueNotifier<bool> whiteBoardEditingState = ValueNotifier<bool>(false);

  NEHistoryMeetingItem? historyMeetingItem;

  static const kSmallVideoViewSize = const Size(92.0, 162.0);
  static const kIPadSmallVideoViewSize = const Size(138.0, 243.0);
  final smallVideoViewPaddings = ValueNotifier(EdgeInsets.zero);
  var smallVideoViewAlignment = Alignment.topRight;

  static const int minSpeakingVolume = 20;
  static const int minMinutesToRemind = 5;
  static const int minSpeakingTimesToRemind = 10;

  // 本地用户是否正在讲话
  var localUserSpeakingContinuousTimes = -1;

  // 入会后delay一段时间后才开始静音检测，防止误报
  static const muteDetectDelay = Duration(seconds: 5);

  //用户主动关闭麦克风后延迟3s开始静音检测
  static const muteMyAudioDelay = Duration(seconds: 3);
  bool? muteDetectStarted;
  Timer? muteDetectStartedTimer;
  var volumeInfo = <int>[];
  var vadInfo = <bool>[];
  var showNetInfo = false;

  /// 上次提醒时间
  var lastRemindTimestamp = DateTime.utc(2020);

  var focusSwitchInterval = Duration(seconds: 2);

  /// 上次焦点视频切换时间
  var lastFocusSwitchTimestamp = DateTime.utc(2020);
  var openMicphoneTipDialogShowing = false;
  final audioVolumeStreams = <String, StreamController<int>>{};
  late NERoomContext roomContext;
  late NERoomUserVideoStreamSubscriber userVideoStreamSubscriber;
  bool isPreviewVirtualBackground = false;
  bool isAnonymous = false;

  final audioSharingListenable = ValueNotifier(false);
  final pageViewCurrentIndex = ValueNotifier(0);

  final networkTaskExecutor = NetworkTaskExecutor();

  SDKConfig? crossAppSDKConfig;

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  void initState() {
    super.initState();
    assert(() {
      // debugPrintScheduleBuildForStacks = true;
      debugPrintRebuildDirtyWidgets = false;
      // debugRepaintTextRainbowEnabled = debugRepaintRainbowEnabled = true;
      return true;
    }());
    // _isIpad = await NEMeetingPlugin().ipadCheckDetector.isIpad();
    roomContext = arguments.roomContext;
    whiteboardController = roomContext.whiteboardController;
    chatController = roomContext.chatController;
    rtcController = roomContext.rtcController;
    userVideoStreamSubscriber = NERoomUserVideoStreamSubscriber(roomContext);
    _meetingMemberCount = ValueNotifier(userCount);
    _networkStats = ValueNotifier(_NetworkStatus.good);
    _isGalleryLayout = ValueNotifier(false);
    _networkInfo = ValueNotifier(NetWorkRttInfo(0, 0, 0));
    _messageSource = ChatRoomMessageSource(sdkConfig,
        arguments.options.chatroomConfig ?? NEMeetingChatroomConfig());
    SystemChrome.setPreferredOrientations([]);
    meetingBeginTime = DateTime.now().millisecondsSinceEpoch;
    Wakelock.enable();
    _galleryModePageController = PageController(initialPage: 0);
    _galleryModePageController?.addListener(_handleGalleryModePageChange);
    _initAnimationController();
    trackPeriodicEvent(TrackEventName.pageMeeting);
    isAnonymous = NEMeetingKit.instance.getAccountService().isAnonymous;
    roomEventCallback = NERoomEventCallback(
      chatroomMessagesReceived: chatroomMessagesReceived,
      chatroomMessageAttachmentProgress:
          _messageSource.updateMessageAttachmentProgress,
      memberNameChanged: memberNameChanged,
      memberRoleChanged: memberRoleChanged,
      memberJoinRtcChannel: memberJoinRtcChannel,
      memberLeaveRtcChannel: memberLeaveRtcChannel,
      memberJoinRoom: memberJoinRoom,
      memberLeaveRoom: memberLeaveRoom,
      memberVideoMuteChanged: memberVideoMuteChanged,
      memberAudioMuteChanged: memberAudioMuteChanged,
      memberWhiteboardShareStateChanged: memberWhiteboardShareStateChanged,
      memberScreenShareStateChanged: memberScreenShareStateChanged,
      roomPropertiesChanged: (map) => handleRoomPropertiesEvent(map, false),
      roomPropertiesDeleted: (map) => handleRoomPropertiesEvent(map, true),
      memberPropertiesChanged: handleMemberPropertiesEvent,
      memberPropertiesDeleted: handleMemberPropertiesEvent,
      liveStateChanged: liveStateChanged,
      roomEnd: onRoomDisconnected,
      rtcChannelError: onRtcChannelError,
      rtcRemoteAudioVolumeIndication: onRtcAudioVolumeIndication,
      rtcLocalAudioVolumeIndication: onLocalAudioVolumeIndicationWithVad,
      rtcAudioOutputDeviceChanged: onRtcAudioOutputDeviceChanged,
      rtcVirtualBackgroundSourceEnabled: onRtcVirtualBackgroundSourceEnabled,
    );
    roomContext.addEventCallback(roomEventCallback);

    roomStatsCallback = NERoomRtcStatsCallback(
      rtcStats: handleRoomRtcStats,
      networkQuality: handleRoomNetworkQuality,
    );
    roomContext.addRtcStatsCallback(roomStatsCallback);

    messageCallback = NEMessageChannelCallback(
      onReceiveCustomMessage: handlePassThroughMessage,
    );
    NERoomKit.instance.messageChannelService
        .addMessageChannelCallback(messageCallback);

    MeetingCore()
        .notifyStatusChange(NEMeetingStatus(NEMeetingEvent.connecting));
    setupAudioProfile();
    setupMeetingEndTip();
    permissionCheckBeforeJoin().then((value) {
      roomContext.rtcController.joinRtcChannel().then((value) {
        if (mounted && !value.isSuccess()) {
          commonLogger.i('join channel error: ${value.code} ${value.msg}');
          roomContext.leaveRoom();
          _onCancel(exitCode: NEMeetingCode.joinChannelError);
        }
      });
      _joining();
    });
    localMirrorState.value = arguments.options.enableFrontCameraMirror;
  }

  Future<bool> requestPhoneStatePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 31
          ? await PermissionHelper.requestPermissionSingle(
              context,
              Permission.phone,
              arguments.meetingTitle,
              NEMeetingUIKit().ofLocalizations().phoneStatePermission,
              useDialog: true,
            )
          : true;
    }
    return Platform.isIOS;
  }

  Future<dynamic> permissionCheckBeforeJoin() async {
    requestPhoneStatePermission().then((hasPermission) {
      commonLogger.i(
        'request phone state permission: $hasPermission',
      );
      if (hasPermission) {
        handlePhoneStateChangeEvent();
      }
    });
    if (Platform.isAndroid) {
      // Target Android S or Higher 需要提前申请蓝牙权限
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 31) {
        bool bluetoothEnabled =
            await NEMeetingPlugin().bluetoothService.isEnabled;
        if (!mounted) return null;
        commonLogger.i(
          'bluetooth enabled=$bluetoothEnabled',
        );
        // 会议过程中，蓝牙开关变更时请求权限，只做一次
        // 目前，RTC SDK 在加入房间后再申请蓝牙权限，也不会切换到蓝牙设备，需要重新入会
        // var subscription = NEMeetingPlugin()
        //     .bluetoothService
        //     .enableStateChanged
        //     .skip(1)
        //     .where((enabled) => enabled)
        //     .take(1)
        //     .listen((event) => requestAndroidBluetoothPermission());
        // streamSubscriptions.add(subscription);
        if (bluetoothEnabled) {
          return requestAndroidBluetoothPermission();
        }
      }
    }
    return null;
  }

  Future awaitNetworkAvailable() async {
    final current = await Connectivity().checkConnectivity();
    if (current != ConnectivityResult.none) return;
    return Connectivity()
        .onConnectivityChanged
        .firstWhere((element) => element != ConnectivityResult.none);
  }

  bool _isAppInBackground = false;
  bool _needAutoRestartVideo = false;

  void handleAppLifecycleChangeEvent() {
    var subscription = NEAppLifecycleDetector()
        .onBackgroundChange
        .listen((isInBackground) async {
      if (!mounted || _isAlreadyCancel) return;
      commonLogger.i(
        'Handle App lifecycle: background=$isInBackground',
      );
      _isAppInBackground = isInBackground;
      if (isInBackground) {
        // ios 从左上角下滑，会快速连续发送三次事件：background -> foreground -> background
        if (Platform.isIOS) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (!_isAppInBackground) return;
        }
        await awaitNetworkAvailable();
        if (!_isAppInBackground) {
          commonLogger.i(
            'Handle App lifecycle: no network when background',
          );
          return;
        }
        if (roomContext.localMember.isVideoOn) {
          final result = await rtcController.muteMyVideo();
          _needAutoRestartVideo = result.isSuccess();
          commonLogger.i(
              'Handle App lifecycle: in background and close video: $_needAutoRestartVideo $_isAppInBackground');
        }
      }
      // 异常case：关闭摄像头操作还未
      // 在完成异步关闭摄像头后，立刻检查是否需要重新打开摄像头。
      if (!_isAppInBackground && _needAutoRestartVideo) {
        _needAutoRestartVideo = false;
        final _canUnmute = roomContext.canUnmuteMyVideo();
        commonLogger.i(
            'Handle App lifecycle: in foreground and open video automatically: canUnmute=$_canUnmute, inviting=$_invitingToOpenVideo');
        if (_canUnmute || _invitingToOpenVideo) {
          _invitingToOpenVideo = false;
          final result = await rtcController.unmuteMyVideo();
          commonLogger
              .i('Handle App lifecycle: open video automatically $result');
        } else {
          commonLogger
              .i('Handle App lifecycle: in foreground but cannot open anymore');
        }
      }
    });
    streamSubscriptions.add(subscription);
  }

  static const _updateMyPhoneState = 'UpdateMyPhoneState';
  void handlePhoneStateChangeEvent() {
    NEMeetingPlugin().phoneStateService.start();
    var subscription = NEMeetingPlugin()
        .phoneStateService
        .inCallStateChanged
        .asyncMap((event) => Future.delayed(const Duration(seconds: 1),
            () => event)) // 延迟1S排队执行，避免连续两次更新可能导致的属性错乱
        .listen((isInCall) {
      roomContext.localMember.updateMyPhoneStateLocal(isInCall);
      networkTaskExecutor
          .execute(
        () => roomContext.updateMyPhoneState(isInCall),
        type: _updateMyPhoneState,
        debugName: '$_updateMyPhoneState($isInCall)',
        cancelOthers: true,
      )
          .catchError((err) {
        debugPrint('$_updateMyPhoneState($isInCall) $err');
      });
      if (isInCall) {
        if (isSelfScreenSharing()) rtcController.stopScreenShare();
        if (audioSharingListenable.value) enableAudioShare(false);
        rtcController
          ..adjustRecordingSignalVolume(0)
          ..pauseLocalVideoCapture()
          ..adjustPlaybackSignalVolume(0);
      } else {
        if (roomContext.localMember.isAudioOn) {
          rtcController.adjustRecordingSignalVolume(100);
        }
        rtcController
          ..resumeLocalVideoCapture()
          ..adjustPlaybackSignalVolume(100);
      }
    });
    streamSubscriptions.add(subscription);
  }

  Future<bool> requestAndroidBluetoothPermission() {
    return PermissionHelper.requestPermissionSingle(
      context,
      Permission.bluetoothConnect,
      arguments.meetingTitle,
      NEMeetingUIKitLocalizations.of(context)!.bluetoothPermission,
      message:
          '${NEMeetingUIKitLocalizations.of(context)!.permissionRationalePrefix}${NEMeetingUIKitLocalizations.of(context)!.bluetoothPermission}${NEMeetingUIKitLocalizations.of(context)!.permissionRationaleSuffixAudio}',
      useDialog: true,
    ).then((value) {
      commonLogger.i(
        'request bluetooth connect permission granted=$value',
      );
      return value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshSmallVideoViewPaddings();
  }

  void refreshSmallVideoViewPaddings() {
    final safeArea = MediaQuery.of(context).viewPadding;
    var paddings = EdgeInsets.fromLTRB(max(safeArea.left, 12.0),
        safeArea.top + 20, max(safeArea.right, 12.0), safeArea.bottom + 20);
    if (isToolbarShowing) {
      paddings +=
          const EdgeInsets.fromLTRB(0, appBarHeight, 0, bottomBarHeight);
    }
    smallVideoViewPaddings.value = paddings;
  }

  @override
  void onAppLifecycleState(AppLifecycleState state) {
    _checkResumeFromMinimized(state);
  }

  void _checkResumeFromMinimized(AppLifecycleState state) {
    if (!_isAlreadyCancel &&
        state == AppLifecycleState.resumed &&
        _isMinimized == true) {
      _isMinimized = false;
      MeetingCore()
          .notifyStatusChange(NEMeetingStatus(NEMeetingEvent.inMeeting));
      commonLogger.i('resume from minimized');
    }
  }

  void _initAnimationController() {
    appBarAnimController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    bottomAnim = Tween(begin: Offset(0, 0), end: Offset(0, 1)).animate(
        CurvedAnimation(parent: appBarAnimController, curve: Curves.easeOut));
    topBarAnim = Tween(begin: Offset(0, 0), end: Offset(0, -1)).animate(
        CurvedAnimation(parent: appBarAnimController, curve: Curves.easeOut));
    localAudioVolumeIndicatorAnim =
        Tween(begin: -50.0, end: bottomBarHeight + 71.0).animate(
            CurvedAnimation(
                parent: appBarAnimController, curve: Curves.easeOut));
    meetingEndTipAnim = Tween(begin: Offset(0, 0), end: Offset(0, 0)).animate(
        CurvedAnimation(parent: appBarAnimController, curve: Curves.easeOut));
    appBarAnimController.addStatusListener((status) {
      refreshSmallVideoViewPaddings();
    });
  }

  void _joining() {
    if (_meetingState == MeetingState.init) {
      _meetingState = MeetingState.joining;
      joinTimeOut = Timer(Duration(milliseconds: arguments.joinTimeout), () {
        if (_meetingState.index <= MeetingState.joining.index) {
          commonLogger.i(
            'join meeting timeout',
          );
          _meetingState = MeetingState.closing;
          roomContext.leaveRoom();
          _onCancel(
              exitCode: NEMeetingCode.joinTimeout,
              reason: NEMeetingUIKitLocalizations.of(context)!.joinTimeout);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light, child: buildChild());
  }

  Widget buildChild() {
    if (_meetingState.index < MeetingState.joined.index || !_isEverConnected) {
      return buildJoiningUI();
    }
    final data = MediaQuery.of(context);
    final height = appBarHeight + data.viewPadding.top;
    return WillPopScope(
      child: OrientationBuilder(builder: (_, orientation) {
        _isPortrait = orientation == Orientation.portrait;
        return Stack(
          children: <Widget>[
            GestureDetector(
              key: MeetingUIValueKeys.meetingFullScreen,
              onTap: changeToolBarStatus,
              child: buildCenter(),
            ),
            // MeetingCoreValueKey.addTextWidgetTest(valueKey:MeetingCoreValueKey.meetingFullScreen,value: handlMeetingFullScreen),
            Align(
              alignment: Alignment.bottomCenter,
              child: RepaintBoundary(
                child: SlideTransition(
                  child: buildBottomAppBar(),
                  position: bottomAnim,
                ),
              ),
            ),
            if (isMeetingEndTimeTiSupported() &&
                showMeetingEndTip &&
                meetingEndTipMin != 0)
              buildMeetingEndTip(height),
            RepaintBoundary(
              child: SlideTransition(
                position: topBarAnim,
                child: buildAppBar(data, height),
              ),
            ),
          ],
        );
      }),
      onWillPop: () {
        if (!_hideMorePopupMenu()) finishPage();
        return Future.value(false);
      },
    );
    // }
  }

  Widget buildCenter() {
    return Stack(
      children: <Widget>[
        NERoomUserVideoStreamSubscriberProvider(
          subscriber: userVideoStreamSubscriber,
          child: ValueListenableBuilder<bool>(
            valueListenable: whiteBoardEditingState,
            builder: (context, value, child) => buildGalleyUI(),
          ),
        ),
        // if(arguments.joinmeetingInfo.attendeeRecordOn && SettingsRepository.isMeetingCloudRecordEnabled())
        // _buildRecord(),
      ],
    );
  }

  bool isHeadset() {
    return _audioDeviceSelected.value ==
            NEAudioOutputDevice.kBluetoothHeadset ||
        _audioDeviceSelected.value == NEAudioOutputDevice.kWiredHeadset;
  }

  bool isEarpiece() {
    return _audioDeviceSelected.value == NEAudioOutputDevice.kEarpiece;
  }

  Widget buildAppBar(data, height) {
    return Container(
      height: height,
      padding:
          EdgeInsets.only(left: 8.0, right: 8.0, top: data.viewPadding.top),
      child: Stack(
        children: [
          buildMeetingInfo(),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildAudioMode(),
                buildCameraMode(),
                buildNetwork(),
                buildSwitchMode()
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildMinimize(),
                buildLeave(),
              ],
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [_UIColors.color_292933, _UIColors.color_212129],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )),
    );
  }

  Widget buildNetwork() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onNetworkInfo,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: _meetingNetworkIconBuilder(context),
      ),
    );
  }

  void _handleGalleryModePageChange() {
    if (_galleryModePageController != null) {
      _isGalleryLayout.value = _galleryModePageController!.page! >= 1.0;
    }
  }

  Widget buildSwitchMode() {
    return FutureBuilder<bool>(
        future: checkIpad(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data! && userCount > 1) {
            return buildSwitchLayoutBtn();
          }
          return Container();
        });
  }

  Future<bool> checkIpad() async {
    if (Platform.isIOS) {
      return await NEMeetingPlugin().ipadCheckDetector.isIpad();
    }
    return false;
  }

  String getGalleryLayoutDes(bool isGallery) {
    return isGallery
        ? NEMeetingUIKitLocalizations.of(context)!.switchFcusView
        : NEMeetingUIKitLocalizations.of(context)!.switchGalleryView;
  }

  Widget buildSwitchLayoutBtn() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _galleryModePageController
              ?.jumpToPage(!isGalleryLayout.value ? 1 : 0);
        },
        child: SafeValueListenableBuilder(
          valueListenable: isGalleryLayout,
          builder: (BuildContext context, bool value, _) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              width: 160,
              height: 38,
              decoration: BoxDecoration(
                  color: _UIColors.color_337eff,
                  borderRadius: BorderRadius.circular(19)),
              child: Align(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      value
                          ? NEMeetingIconFont.icon_yx_tv_layout_ax
                          : NEMeetingIconFont.icon_yx_tv_layout_bx,
                      size: 21,
                      color: _UIColors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      getGalleryLayoutDes(value),
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget _meetingNetworkIconBuilder(BuildContext context) {
    return SafeValueListenableBuilder(
        valueListenable: meetingNetworkStatsListenable,
        builder: (BuildContext context, _NetworkStatus value, _) {
          return getNetWorkIcon(value);
        });
  }

  Widget getNetWorkIcon(_NetworkStatus status) {
    if (status == _NetworkStatus.good || status == _NetworkStatus.unknown) {
      return Icon(NEMeetingIconFont.icon_net_state,
          key: MeetingUIValueKeys.minimize, size: 21, color: Colors.green);
    } else if (status == _NetworkStatus.normal) {
      return Icon(NEMeetingIconFont.icon_net_state,
          key: MeetingUIValueKeys.minimize, size: 21, color: Colors.yellow);
    } else {
      return Icon(NEMeetingIconFont.icon_net_state,
          key: MeetingUIValueKeys.minimize, size: 21, color: Colors.red);
    }
  }

  Widget buildLeave() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          width: 50,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: _UIColors.colorD93D35,
              borderRadius: BorderRadius.all(Radius.circular(13))),
          child: Text(
              isSelfHostOrCoHost()
                  ? NEMeetingUIKitLocalizations.of(context)!.finish
                  : NEMeetingUIKitLocalizations.of(context)!.leave,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _UIColors.white,
                  fontSize: 13,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400))),
      onTap: finishPage,
    );
  }

  Widget buildMeetingInfo() {
    final appbarItemSize = 21 + 16;
    final marginLeft = [
      !arguments.noSwitchAudioMode,
      !arguments.noSwitchCamera && !arguments.videoMute,
      true /*network always shown*/
    ].fold<double>(
        0,
        (previousValue, show) =>
            show ? appbarItemSize + previousValue : previousValue);

    var marginRight = 50.0 + 16.0;
    if (!arguments.noMinimize) {
      marginRight += appbarItemSize;
    }
    return SizedBox.expand(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: max(marginLeft, marginRight)),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onMeetingInfo,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      ' ${arguments.meetingTitle} ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 15,
                  ),
                ],
              ),
              if (arguments.showMeetingTime)
                MeetingDuration(
                  DateTime.now().millisecondsSinceEpoch -
                      roomContext.rtcStartTime,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMeetingInfo() {
    trackPeriodicEvent(TrackEventName.meetingInfoClick,
        extra: {'meeting_num': arguments.meetingNum});
    DialogUtils.showChildNavigatorPopup(
      context,
      (context) => MeetingInfoPage(
        roomContext,
        arguments.meetingInfo,
        arguments.options,
        roomInfoUpdatedEventStream.stream,
      ),
    );
  }

  Widget buildMinimize() {
    if (!arguments.noMinimize) {
      return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: minimizeCurrentMeeting,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: const Icon(NEMeetingIconFont.icon_narrow_line,
                key: MeetingUIValueKeys.minimize,
                size: 21,
                color: _UIColors.white),
          ));
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildCameraMode() {
    if (arguments.videoMute == true || arguments.noSwitchCamera) {
      return SizedBox.shrink();
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: const Icon(
          NEMeetingIconFont.icon_yx_tv_filpx,
          key: MeetingUIValueKeys.switchCamera,
          size: 21,
          color: _UIColors.white,
        ),
      ),
      onTap: _onSwitchCamera,
    );
  }

  Widget buildAudioMode() {
    if (arguments.noSwitchAudioMode) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _audioModeSwitch,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: ValueListenableBuilder<NEAudioOutputDevice>(
          valueListenable: _audioDeviceSelected,
          builder: (context, value, child) {
            return Icon(
              isHeadset()
                  ? NEMeetingIconFont.icon_headset1x
                  : (isEarpiece()
                      ? NEMeetingIconFont.icon_earpiece1x
                      : NEMeetingIconFont.icon_amplify),
              key: MeetingUIValueKeys.switchLoudspeaker,
              size: 21,
              color: _UIColors.white,
            );
          },
        ),
      ),
    );
  }

  void _audioModeSwitch() {
    checkIpad().then((value) => {
          if (value)
            {
              ToastUtils.showToast(context,
                  NEMeetingUIKitLocalizations.of(context)!.noSupportSwitch)
            }
        });
    if (isHeadset()) {
      ToastUtils.showToast(
          context, NEMeetingUIKitLocalizations.of(context)!.headsetState);
    } else {
      _onSwitchLoudspeaker();
    }
  }

  bool _willToolbarMenuShow() {
    return arguments.injectedToolbarMenuItems
            .where(shouldShowMenu)
            .isNotEmpty ||
        _willMoreMenuShow();
  }

  Container buildBottomAppBar() {
    if (!_willToolbarMenuShow()) {
      return Container(height: bottomBarHeight);
    }
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.transparent,
          _UIColors.color_212129,
          _UIColors.color_212129
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
            top: false,
            child: Container(
                height: 106,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      color: Colors.transparent,
                      height: 46,
                      margin: EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          ...arguments.injectedToolbarMenuItems
                              .where(shouldShowMenu)
                              .map((menu) {
                            if (menu.itemId == NEMenuIDs.participants &&
                                roomContext.localMember.isRaisingHand) {
                              return Expanded(
                                child: buildHandsUp(
                                  NEMeetingUIKitLocalizations.of(context)!
                                      .inHandsUp,
                                  () => _lowerMyHand(),
                                ),
                              );
                            }
                            if (menu.itemId == NEMenuIDs.managerParticipants &&
                                hasHandsUp() &&
                                isSelfHostOrCoHost()) {
                              return Expanded(
                                child: buildHandsUp(
                                    handsUpCount().toString(), _onMember),
                              );
                            }
                            return Spacer();
                          }).toList(growable: false),
                          if (_willMoreMenuShow()) Spacer()
                        ],
                      ),
                    ),
                    Container(
                      height: bottomBarHeight,
                      child: Row(
                        children: <Widget>[
                          ...arguments.injectedToolbarMenuItems
                              .where(shouldShowMenu)
                              .map(menuItem2Widget)
                              .whereType<Widget>()
                              .map((widget) => Expanded(child: widget))
                              .toList(growable: false),
                          if (_willMoreMenuShow())
                            Expanded(
                              child: SingleStateMenuItem(
                                  menuItem: InternalMenuItems.more,
                                  callback: handleMenuItemClick,
                                  tipBuilder: getMenuItemTipBuilder(
                                      InternalMenuIDs.more)),
                            ),
                        ],
                      ),
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: _UIColors.color_33FFFFFF, width: 0.5)),
                          gradient: LinearGradient(
                              colors: [
                                _UIColors.color_292933,
                                _UIColors.color_212129
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                    )
                  ],
                ))));
  }

  bool shouldShowMenu(NEMeetingMenuItem item) {
    if (!roomContext.localMember.isVisible) return false;
    final id = item.itemId;
    if (!item.isValid) return false;
    if (id == NEMenuIDs.screenShare && !_isScreenShareSupported()) return false;
    if (id == NEMenuIDs.chatroom && (arguments.noChat || !isChatroomEnabled()))
      return false;
    if (id == NEMenuIDs.invitation && arguments.noInvite) return false;
    if (id == InternalMenuIDs.beauty && !isBeautyFuncSupported) {
      return false;
    }
    if (id == InternalMenuIDs.virtualBackground &&
        !isVirtualBackgroundEnabled) {
      return false;
    }
    if (id == InternalMenuIDs.live &&
        (arguments.noLive || !roomContext.liveController.isSupported)) {
      return false;
    }

    if (id == InternalMenuIDs.sip && (arguments.noSip || !isSipSupported())) {
      return false;
    }
    if (id == NEMenuIDs.whiteBoard &&
        (arguments.noWhiteBoard || !whiteboardController.isSupported)) {
      return false;
    }
    switch (item.visibility) {
      case NEMenuVisibility.visibleToHostOnly:
        return isSelfHostOrCoHost();
      case NEMenuVisibility.visibleExcludeHost:
        return !isSelfHostOrCoHost();
      case NEMenuVisibility.visibleAlways:
        return true;
    }
  }

  /// 新增聊天室是否可用，对应原chatController内的isChatroomEnabled() 方法
  bool isChatroomEnabled() {
    return chatController.isSupported;
  }

  bool isSipSupported() =>
      sdkConfig.isSipSupported && !TextUtils.isEmpty(roomContext.sipCid);

  final Map<int, NEMeetingMenuItem> menuId2Item = {};
  final Map<int, CyclicStateListController> menuId2Controller = {};

  Widget? menuItem2Widget(NEMeetingMenuItem item) {
    menuId2Item.putIfAbsent(item.itemId, () => item);
    final tipBuilder = getMenuItemTipBuilder(item.itemId);
    final iconBuilder = getMenuItemIconBuilder(item.itemId);
    if (item is NESingleStateMenuItem) {
      return SingleStateMenuItem(
        menuItem: item,
        callback: handleMenuItemClick,
        tipBuilder: tipBuilder,
        iconBuilder: iconBuilder,
      );
    } else if (item is NECheckableMenuItem) {
      final controller = menuId2Controller.putIfAbsent(
          item.itemId, () => getMenuItemStateController(item.itemId));
      return CheckableMenuItem(
        menuItem: item,
        controller: controller,
        callback: handleMenuItemClick,
        tipBuilder: tipBuilder,
        iconBuilder: iconBuilder,
      );
    }
    return null;
  }

  MenuItemTipBuilder? getMenuItemTipBuilder(int menuId) {
    switch (menuId) {
      case NEMenuIDs.participants:
      case NEMenuIDs.managerParticipants:
        return _meetingMemberCountBuilder;
      case NEMenuIDs.chatroom:
        return _circularNumberTipBuilder(
            _messageSource.unreadMessageListenable);
      case InternalMenuIDs.more:

        /// Only show unread tip when chat menu is in 'more' menu
        if (arguments.injectedMoreMenuItems
            .where(shouldShowMenu)
            .any((element) => element.itemId == NEMenuIDs.chatroom)) {
          return _circularNumberTipBuilder(moreMenuItemTipListenable);
        }
    }
    return null;
  }

  MenuItemIconBuilder? getMenuItemIconBuilder(int menuId) {
    if (menuId == NEMenuIDs.microphone) {
      return (context, state) {
        return buildRoomUserVolumeIndicator(roomContext.localMember.uuid);
      };
    }
    return null;
  }

  CyclicStateListController getMenuItemStateController(int menuId) {
    var initialState = NEMenuItemState.uncheck;
    ValueListenable? listenTo;
    switch (menuId) {
      case NEMenuIDs.microphone:
        listenTo = arguments.audioMuteListenable;
        initialState = arguments.audioMute
            ? NEMenuItemState.checked
            : NEMenuItemState.uncheck;
        break;
      case NEMenuIDs.camera:
        listenTo = arguments.videoMuteListenable;
        initialState = arguments.videoMute
            ? NEMenuItemState.checked
            : NEMenuItemState.uncheck;
        break;
      case NEMenuIDs.screenShare:
        listenTo = screenShareListenable;
        initialState = isSelfScreenSharing()
            ? NEMenuItemState.checked
            : NEMenuItemState.uncheck;
        break;
      case NEMenuIDs.whiteBoard:
        listenTo = whiteBoardShareListenable;
        initialState = isSelfWhiteBoardSharing()
            ? NEMenuItemState.checked
            : NEMenuItemState.uncheck;
        break;
    }
    return CyclicStateListController(
      stateList: [NEMenuItemState.uncheck, NEMenuItemState.checked],
      initialState: initialState,
      listenTo: listenTo,
    );
  }

  Widget _meetingMemberCountBuilder(BuildContext context, Widget anchor) {
    return SafeValueListenableBuilder(
      valueListenable: meetingMemberCountListenable,
      builder: (BuildContext context, int value, _) {
        return Container(
          height: 24,
          padding: const EdgeInsets.only(left: 5),
          child: Stack(
            children: <Widget>[
              Center(
                child: anchor,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(left: 36),
                  child: Text(
                    '$value',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  MenuItemTipBuilder? _circularNumberTipBuilder(
      ValueListenable<int>? valueListenable,
      {int max = 99}) {
    return valueListenable != null
        ? (context, anchor) => SafeValueListenableBuilder(
              valueListenable: valueListenable,
              builder: (_, int value, __) => value > 0
                  ? Container(
                      height: 24,
                      width: 36,
                      child:
                          Stack(alignment: Alignment.center, children: <Widget>[
                        anchor,
                        Align(
                            alignment: Alignment.topRight,
                            child: ClipOval(
                                child: Container(
                                    height: 16,
                                    width: 16,
                                    decoration: ShapeDecoration(
                                        color: _UIColors.colorFE3B30,
                                        shape: Border()),
                                    alignment: Alignment.center,
                                    child: Text(
                                      value > max ? '$max+' : '$value',
                                      style: const TextStyle(
                                          fontSize: 8,
                                          color: Colors.white,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.w400),
                                    ))))
                      ]))
                  : anchor,
            )
        : null;
  }

  /// 按钮事件回调
  void handleMenuItemClick(NEMenuClickInfo clickInfo) {
    final itemId = clickInfo.itemId;
    commonLogger.i('handleMenuItemClick $itemId');
    if (_fullMoreMenuItemList.any((element) => element.itemId == itemId)) {
      _hideMorePopupMenu();
    }
    switch (itemId) {
      case NEMenuIDs.microphone:
        _muteMyAudio(!arguments.audioMute);
        return;
      case NEMenuIDs.camera:
        _muteMyVideo(!arguments.videoMute);
        return;
      case NEMenuIDs.screenShare:
        _onScreenShare();
        return;
      case NEMenuIDs.managerParticipants:
      case NEMenuIDs.participants:
        _onMember();
        return;
      case NEMenuIDs.chatroom:
        onChat();
        return;
      case NEMenuIDs.invitation:
        _onInvite();
        return;
      case InternalMenuIDs.sip:
        Navigator.of(context).push(MaterialMeetingPageRoute(builder: (context) {
          return MeetingInvitePage(roomUuid: roomContext.roomUuid);
        }));
        return;
      case InternalMenuIDs.more:
        commonLogger.i('handleMenuItemClick InternalMenuIDs.more before');
        if (arguments.options.extras['useCompatibleMoreMenuStyle'] == true) {
          _showCompatibleMoreMenu();
          commonLogger.i(
              'handleMenuItemClick InternalMenuIDs.more  _showCompatibleMoreMenu');
        } else {
          _showMorePopupMenu();
          commonLogger.i(
              'handleMenuItemClick InternalMenuIDs.more  _showMorePopupMenu');
        }
        return;
      case InternalMenuIDs.beauty:
        _onBeauty();
        return;
      case InternalMenuIDs.live:
        _onLive();
        return;
      case NEMenuIDs.whiteBoard:
        _onWhiteBoard();
        return;
      case InternalMenuIDs.virtualBackground:
        _onVirtualBackground();
        return;
    }
    if (itemId >= firstInjectableMenuId) {
      final transitionFuture =
          NEMeetingUIKit()._notifyOnInjectedMenuItemClick(context, clickInfo);
      menuId2Controller[itemId]?.didStateTransition(transitionFuture);
    }
  }

  bool hasHandsUp() {
    return userList.any((user) => user.isRaisingHand);
  }

  int handsUpCount() {
    return userList.where((user) => user.isRaisingHand).length;
  }

  Widget buildHandsUp(String desc, VoidCallback callback) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: callback,
        child: Container(
          height: 46,
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 36,
                    height: 40,
                    decoration: BoxDecoration(
                        color: _UIColors.color_337eff,
                        border: Border.all(color: Colors.transparent, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(2))),
                  )),
              Align(
                alignment: Alignment.bottomCenter,
                child: Icon(NEMeetingIconFont.icon_triangle_down,
                    size: 7, color: _UIColors.color_337eff),
              ),
              Align(
                alignment: Alignment(0.0, -0.8),
                child: Icon(NEMeetingIconFont.icon_raisehands,
                    key: MeetingUIValueKeys.raiseHands,
                    size: 20,
                    color: Colors.white),
              ),
              Align(
                  alignment: Alignment(0.0, 0.5),
                  child: Text(desc,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w400)))
            ],
          ),
        ));
  }

  bool _isMenuItemShowing(int itemId) => _fullMenuItemList
      .any((element) => element.itemId == itemId && shouldShowMenu(element));

  Iterable<NEMeetingMenuItem> get _fullMenuItemList =>
      arguments.injectedToolbarMenuItems.followedBy(_fullMoreMenuItemList);

  Iterable<NEMeetingMenuItem> get _fullMoreMenuItemList =>
      InternalMenuItems.dynamicFeatureMenuItemList
          .followedBy(arguments.injectedMoreMenuItems);

  bool _willMoreMenuShow() => _fullMoreMenuItemList.any(shouldShowMenu);

  AnimationController? _morePopupMenuAnimation;
  late AnimationStatusListener _morePopupMenuAnimationListener;
  Animation<Offset>? _morePopupMenuOffset;
  OverlayEntry? _morePopupMenuEntry;
  ValueNotifierAdapter<int, int>? _moreMenuItemUnreadCountNotifier;

  ValueListenable<int>? get moreMenuItemTipListenable {
    _moreMenuItemUnreadCountNotifier ??= ValueNotifierAdapter<int, int>(
      source: _messageSource.unreadMessageListenable,
      mapper: (value) =>
          _morePopupMenuAnimation?.status == AnimationStatus.completed
              ? 0
              : value,
    );
    return _moreMenuItemUnreadCountNotifier;
  }

  void _setupMorePopupMenuAnimation() {
    //timeDilation = 1;
    _morePopupMenuAnimation ??= AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _morePopupMenuAnimationListener = (status) {
      commonLogger.i('_morePopupMenuAnimationListener status:$status');
      if (status == AnimationStatus.dismissed) {
        _morePopupMenuEntry?.remove();
        _morePopupMenuEntry = null;
        commonLogger.i('_morePopupMenuEntry remove');
      }
      _moreMenuItemUnreadCountNotifier?.refresh();
    };
    _morePopupMenuAnimation!.addStatusListener(_morePopupMenuAnimationListener);
    _morePopupMenuOffset ??= _morePopupMenuAnimation!.drive(
      Tween(
        begin: const Offset(0, 1),
        end: const Offset(0, 0),
      ).chain(
        CurveTween(
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  void _showMorePopupMenu() {
    commonLogger.i('_showMorePopupMenu ${_morePopupMenuEntry != null}');
    if (_morePopupMenuEntry != null) {
      _hideMorePopupMenu();
      return;
    }
    _setupMorePopupMenuAnimation();
    _morePopupMenuEntry = OverlayEntry(builder: (context) {
      return SafeArea(
        child: Stack(
          children: [
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) {
                commonLogger.i(
                    'Listener onPointerDown ${_morePopupMenuAnimation!.status == AnimationStatus.completed}');
                if (_morePopupMenuAnimation!.status ==
                    AnimationStatus.completed) {
                  _hideMorePopupMenu();
                }
              },
            ),
            Container(
              margin: EdgeInsets.only(
                bottom: bottomBarHeight + 4,
                right: 4,
              ),
              alignment: Alignment.bottomRight,
              child: SlideTransition(
                position: _morePopupMenuOffset!,
                child: FadeTransition(
                  opacity: _morePopupMenuAnimation!,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 188.0),
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          _UIColors.color_33333f,
                          _UIColors.grey_292933,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    padding: EdgeInsets.all(4),
                    child: StreamBuilder(
                      stream: sdkConfig.onConfigUpdated,
                      builder: (context, value) {
                        return Wrap(
                          children: [
                            ..._fullMoreMenuItemList
                                .where(shouldShowMenu)
                                .map(menuItem2Widget)
                                .whereType<Widget>()
                                .map((widget) => Container(
                                      width: 60,
                                      height: 68,
                                      alignment: Alignment.center,
                                      child: widget,
                                    ))
                                .toList(growable: false),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
    Overlay.of(context)!.insert(_morePopupMenuEntry!);
    _morePopupMenuAnimation!.forward();
  }

  bool _hideMorePopupMenu() {
    commonLogger.i('_hideMorePopupMenu before');
    if (_morePopupMenuEntry != null) {
      _morePopupMenuAnimation!.reverse();
      commonLogger.i('_hideMorePopupMenu in if');
      return true;
    }
    commonLogger.i('_hideMorePopupMenu after');
    return false;
  }

  void onChat() {
    cancelInComingTips();
    Navigator.of(context).push(MaterialMeetingPageRoute(builder: (context) {
      return MeetingChatRoomPage(
        ChatRoomArguments(
          arguments.roomContext,
          _messageSource,
        ),
      );
    }));
  }

  void _showCompatibleMoreMenu() {
    showCupertinoModalPopup<int>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text(NEMeetingUIKitLocalizations.of(context)!.more,
                  style: TextStyle(color: _UIColors.grey_8F8F8F, fontSize: 13)),
              actions: _fullMoreMenuItemList
                  .where(shouldShowMenu)
                  .map((element) {
                    String? title;
                    if (element is NESingleStateMenuItem) {
                      title = element.singleStateItem.text;
                    } else if (element is NECheckableMenuItem) {
                      title = element.uncheckStateItem.text;
                    }
                    if (element.itemId == NEMenuIDs.chatroom) {
                      title =
                          "${NEMeetingUIKitLocalizations.of(context)!.chat}${_messageSource.unread > 0 ? '(${_messageSource.unread})' : ''}";
                    }
                    return title != null
                        ? buildActionSheetItem(
                            context, false, title, element.itemId)
                        : null;
                  })
                  .whereType<Widget>()
                  .toList(growable: false),
              cancelButton: buildActionSheetItem(
                  context,
                  true,
                  NEMeetingUIKitLocalizations.of(context)!.cancel,
                  InternalMenuIDs.cancel),
            )).then((itemId) {
      if (itemId != null) {
        handleMenuItemClick(NEMenuClickInfo(itemId));
      }
    });
  }

  Future<void> _onLive() async {
    final result = await roomContext.liveController.getLiveInfo();
    var liveInfo = result.data;
    if (liveInfo == null) return;
    Navigator.of(context).push(MaterialMeetingPageRoute(builder: (context) {
      return MeetingLivePage(LiveArguments(
          roomContext,
          liveInfo,
          roomInfoUpdatedEventStream.stream,
          arguments.meetingInfo.settings?.liveConfig?.liveAddress));
    }));
  }

  /// 加入中状态
  Widget buildJoiningUI() {
    return Container(
        decoration: BoxDecoration(
            gradient:
                buildGradient([_UIColors.grey_292933, _UIColors.grey_1E1E25])),
        child: Column(
          children: <Widget>[
            Spacer(),
            Image.asset(NEMeetingImages.meetingJoin,
                package: NEMeetingImages.package),
            SizedBox(height: 16),
            Text(NEMeetingUIKitLocalizations.of(context)!.joiningTips,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400)),
            Spacer(),
          ],
        ));
  }

  void finishPage() {
    // buildEvaluationView();
    // return;
    commonLogger.i(
      'finishPage isHost:${isHost()}, isCoHost:${isSelfCoHost()} tap leave.',
    );
    DialogUtils.showChildNavigatorPopup<int>(
        context,
        (context) => CupertinoActionSheet(
              actions: <Widget>[
                buildActionSheetItem(
                    context,
                    false,
                    NEMeetingUIKitLocalizations.of(context)!.leaveMeeting,
                    InternalMenuIDs.leaveMeeting),
                if (isSelfHostOrCoHost())
                  buildActionSheetItem(
                      context,
                      false,
                      NEMeetingUIKitLocalizations.of(context)!.quitMeeting,
                      InternalMenuIDs.closeMeeting,
                      textColor: _UIColors.colorFE3B30),
              ],
              cancelButton: buildActionSheetItem(
                  context,
                  true,
                  NEMeetingUIKitLocalizations.of(context)!.cancel,
                  InternalMenuIDs.cancel),
            )).then<void>((int? itemId) async {
      if (itemId != null && itemId != InternalMenuIDs.cancel) {
        _meetingState = MeetingState.closing;
        final requestClose = itemId == InternalMenuIDs.closeMeeting;
        final result;
        if (requestClose) {
          result = await roomContext.endRoom();
          debugPrintAlog('End room result: $result');
        } else {
          roomContext.leaveRoom();
          result = VoidResult.success();
        }
        if (mounted && requestClose && !result.isSuccess()) {
          roomContext.leaveRoom();
          showToast(NEMeetingUIKitLocalizations.of(context)!
              .networkUnavailableCloseFail);
        }
        switch (itemId) {
          case InternalMenuIDs.leaveMeeting:
            trackPeriodicEvent(TrackEventName.selfLeaveMeeting,
                extra: {'meeting_num': arguments.meetingNum});
            _onCancel(
                reason:
                    NEMeetingUIKitLocalizations.of(context)!.leaveMeetingBySelf,
                exitCode: NEMeetingCode.self);
            break;
          case InternalMenuIDs.closeMeeting:
            trackPeriodicEvent(TrackEventName.selfFinishMeeting,
                extra: {'meeting_num': arguments.meetingNum});
            //退出会议的时候，调了MeetingRepository.closeMeeting，ios上会先调用onDisconnect接口
            //_meetingState = MeetingState.manuallyClosed;
            _onCancel(
                reason: NEMeetingUIKitLocalizations.of(context)!.meetingClosed,
                exitCode: NEMeetingCode.closeBySelfAsHost);
            break;
          default:
            break;
        }
      }
    });
  }

  Widget buildActionSheetItem(
      BuildContext context, bool defaultAction, String title, int itemId,
      {Color textColor = _UIColors.color_007AFF}) {
    return CupertinoActionSheetAction(
        isDefaultAction: defaultAction,
        child: Text(title, style: TextStyle(color: textColor)),
        onPressed: () {
          Navigator.pop(context, itemId);
        });
  }

  bool isSelf(String? userId) {
    return userId != null && roomContext.isMySelf(userId);
  }

  bool isSelfScreenSharing() {
    return roomContext.localMember.isSharingScreen;
  }

  bool isOtherScreenSharing() {
    final member =
        roomContext.getMember(rtcController.getScreenSharingUserUuid());
    return member != null &&
        !roomContext.isMySelf(member.uuid) &&
        member.isInRtcChannel;
  }

  bool isWhiteboardTransparentModeEnabled() {
    return whiteboardController.isTransparentModeEnabled();
  }

  bool isSelfWhiteBoardSharing() {
    return whiteboardController.isSharingWhiteboard();
  }

  bool isWhiteBoardSharing() {
    return whiteboardController.getWhiteboardSharingUserUuid() != null;
  }

  bool isOtherWhiteBoardSharing() {
    final uuid = whiteboardController.getWhiteboardSharingUserUuid();
    return uuid != null && !roomContext.isMySelf(uuid);
  }

  bool isWhiteBoardSharingAndIsHost() {
    return isSelfWhiteBoardSharing() ||
        (isWhiteBoardSharing() && isSelfHostOrCoHost());
  }

  /// 主讲人视觉，
  Widget buildHostUI() {
    final bigViewUser = bigUid != null ? roomContext.getMember(bigUid!) : null;
    return Stack(
      children: <Widget>[
        buildBigVideoView(bigViewUser),
        if (bigViewUser?.canRenderVideo ?? false)
          buildNameView(bigUid!, Alignment.topLeft),
        if (smallUid != null)
          buildDraggableSmallVideoView(buildSmallView(smallUid!)),
        // if (_sessionInfo.debug) buildDebugView(),
      ],
    );
  }

  Widget buildDraggableSmallVideoView(Widget child) {
    return FutureBuilder<bool>(
        future: checkIpad(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return DraggablePositioned(
              size: (snapshot.hasData && snapshot.data!)
                  ? kIPadSmallVideoViewSize
                  : kSmallVideoViewSize,
              initialAlignment: smallVideoViewAlignment,
              paddings: smallVideoViewPaddings,
              pinAnimationDuration: const Duration(milliseconds: 500),
              pinAnimationCurve: Curves.easeOut,
              builder: (context) => child,
              onPinStart: (alignment) {
                smallVideoViewAlignment = alignment;
              });
        });
  }

  bool get shouldShowWhiteboardShareUserVideo {
    final member = roomContext
        .getMember(whiteboardController.getWhiteboardSharingUserUuid());
    if (member != null && member.isVideoOn) {
      return isSelfWhiteBoardSharing() ||
          arguments.options.showWhiteboardShareUserVideo;
    }
    return false;
  }

  void lockWhiteboardCameraContent(String uid, int width, int height) {
    if (!mounted || uid != bigUid) return;
    whiteboardController.lockCameraWithContent(width, height);
  }

  ///白板共享
  Widget buildWhiteBoardShareUI() {
    debugPrint('buildWhiteBoardShareUI');
    // _isEditStatus = whiteboardController.isDrawWhiteboardEnabled();
    final whiteboardPage = _isMinimized && Platform.isAndroid
        ? Container()
        : WhiteBoardWebPage(
            key: ValueKey(whiteboardController.getWhiteboardSharingUserUuid()),
            roomContext: arguments.roomContext,
            whiteBoardPageStatusCallback: (isEditStatus) {
              whiteBoardEditingState.value = isEditStatus;
            },
            valueNotifier: whiteBoardInteractionStatusNotifier,
            backgroundColor:
                whiteboardController.isSupported ? Colors.transparent : null);
    final bigViewUser = bigUid != null ? roomContext.getMember(bigUid!) : null;
    return Stack(
      children: <Widget>[
        if (isWhiteboardTransparentModeEnabled())
          buildBigVideoView(bigViewUser,
              videoViewListener:
                  _LockCameraVideoViewListener(lockWhiteboardCameraContent)),
        whiteboardPage,
        if (shouldShowWhiteboardShareUserVideo &&
            !isWhiteboardTransparentModeEnabled())
          ValueListenableBuilder(
            valueListenable: whiteBoardEditingState,
            builder: (BuildContext context, bool isEditing, Widget? child) {
              if (isEditing) return Container();
              return buildDraggableSmallVideoView(buildSmallView(
                  whiteboardController.getWhiteboardSharingUserUuid()));
            },
          ),
      ],
    );
  }

  ///屏幕共享
  Widget buildScreenShareUI() {
    final mySelf = roomContext.localMember;
    return Stack(
      children: [
        Container(
          color: _UIColors.color_181820,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                NEMeetingIconFont.icon_yx_tv_sharescreen,
                size: 40,
                color: _UIColors.colorD8D8D8.withOpacity(0.1),
              ),
              SizedBox(height: 12),
              Text(
                '${roomContext.localMember.name}${NEMeetingUIKitLocalizations.of(context)!.screenShareLocalTips}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_isAudioShareSupported()) ...[
                SizedBox(height: 24),
                ValueListenableBuilder<bool>(
                  valueListenable: audioSharingListenable,
                  builder: (context, audioSharing, child) {
                    return TextButton.icon(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.white.withOpacity(0.2),
                        ),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 24.0),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(38 / 2),
                          ),
                        ),
                        fixedSize: MaterialStateProperty.all(
                            const Size.fromHeight(38)),
                      ),
                      onPressed: () => enableAudioShare(!audioSharing),
                      icon: Icon(
                        NEMeetingIconFont.icon_device_audio,
                        size: 16,
                        color:
                            audioSharing ? Colors.white : _UIColors.colorD93D35,
                      ),
                      label: Text(
                        audioSharing
                            ? NEMeetingUIKitLocalizations.of(context)!
                                .stopAudioShare
                            : NEMeetingUIKitLocalizations.of(context)!
                                .startAudioShare,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        if (mySelf.canRenderVideo)
          buildDraggableSmallVideoView(buildSmallView(mySelf.uuid)),
        // if (shouldShowFloatingMicrophone())
        //   buildSelfVolumeIndicator(),
      ],
    );
  }

  bool shouldShowFloatingMicrophone() {
    return !isWhiteBoardSharing() &&
        !isSelfScreenSharing() &&
        !isOtherScreenSharing() &&
        roomContext.localMember.isVisible &&
        arguments.options.showFloatingMicrophone;
  }

  String? getScreenShareUserId() {
    return rtcController.getScreenSharingUserUuid();
  }

  bool shouldShowScreenShareUserVideo(String? shareUser) {
    if (!arguments.options.showScreenShareUserVideo) {
      return false;
    }
    final member = roomContext.getMember(shareUser);
    if (member != null && !member.isVideoOn) {
      return false;
    }
    return true;
  }

  Widget buildRemoteScreenShare() {
    _showScreenShareInteractionTip();
    var roomUid = getScreenShareUserId();
    return Stack(
      children: <Widget>[
        if (roomUid == null)
          Container(color: _UIColors.color_181820)
        else ...[
          Align(
            child: InteractiveViewer(
              maxScale: 4.0,
              minScale: 1.0,
              transformationController: _getScreenShareController(),
              child: NERoomUserVideoView.subStream(
                roomUid,
                keepAlive: true,
                debugName: roomContext.getMember(roomUid)?.name,
                listener: this,
              ),
            ),
            alignment: Alignment.center,
          ),
          if (shouldShowScreenShareUserVideo(roomUid) && smallUid != null)
            buildDraggableSmallVideoView(buildSmallView(smallUid!)),
          buildNameView(roomUid, Alignment.topLeft,
              suffix:
                  NEMeetingUIKitLocalizations.of(context)!.screenShareSuffix),
        ],
        if (speakingUid != null)
          buildNameView(speakingUid!, Alignment.topRight,
              prefix: NEMeetingUIKitLocalizations.of(context)!.speakingPrefix),
      ],
    );
  }

  /// 画廊模式
  Widget buildGalleyUI() {
    return FutureBuilder<bool>(
        future: checkIpad(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            _isIpad = snapshot.data!;
          }
          determineBigSmallUser();
          var pageSize = calculatePageSize();
          var curPage = _galleryModePageController!.hasClients
              ? _galleryModePageController!.page!.round()
              : 0;
          if (curPage >= pageSize) {
            curPage = pageSize - 1;
            _galleryModePageController!.animateToPage(curPage,
                duration: Duration(milliseconds: 50), curve: Curves.easeInOut);
          }
          return Stack(
            children: <Widget>[
              PageView.builder(
                itemBuilder: (BuildContext context, int index) {
                  if (index > 0) {
                    return buildGrid(index);
                  }
                  if (isSelfScreenSharing()) {
                    return buildScreenShareUI();
                  }
                  if (isOtherScreenSharing()) {
                    return buildRemoteScreenShare();
                  }
                  if (isWhiteBoardSharing()) {
                    return buildWhiteBoardShareUI();
                  }
                  return buildHostUI();
                },
                physics: PageScrollPhysics(),
                controller: _galleryModePageController,
                allowImplicitScrolling: false,
                itemCount: pageSize,
                onPageChanged: (index) {
                  pageViewCurrentIndex.value = index;
                },
              ),
              if (pageSize > 1)
                Padding(
                  padding: EdgeInsets.only(bottom: bottomBarHeight + 8),
                  child: PointerEventAware(
                    key: ValueKey(pageSize),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: DotsIndicator(
                        itemCount: pageSize,
                        selectedIndex: pageViewCurrentIndex,
                      ),
                    ),
                  ),
                ),
              if (shouldShowFloatingMicrophone()) buildSelfVolumeIndicator(),
            ],
          );
        });
  }

  LinearGradient buildGradient(List<Color> colors) {
    return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        tileMode: TileMode.clamp,
        colors: colors);
  }

  /// 2*2
  void calAspectRatio() {
    final data = MediaQuery.of(context);
    var count = MeetingConfig.defaultGridSide;
    var spaceSize = (space * (count - 1));
    if (_isPortrait) {
      if (vPaddingLR == null) {
        var _itemW = (data.size.width - spaceSize) / count;
        var _itemH = _itemW / aspectRatio!;

        /// 修正竖屏高度比较小的情况
        var revise = data.size.height -
            data.viewPadding.top -
            spaceSize -
            _itemH * count;
        if (revise < 0) {
          _itemH =
              (data.size.height - spaceSize - data.viewPadding.top) / count;
          _itemW = _itemH * aspectRatio!;
          vPaddingTop = 0;
          vPaddingLR = (data.size.width - spaceSize - _itemW * count) / 2;
        } else {
          vPaddingTop = revise / 2;
          vPaddingLR = 0;
        }

        Alog.d(
            tag: _tag,
            moduleName: _moduleName,
            content: '$tag, _portrait  _itemH = $_itemH , _itemW= $_itemW');
      }
    } else {
      if (hPaddingLR == null) {
        var _itemH =
            (data.size.height - spaceSize - data.viewPadding.top) / count;
        var _itemW = _itemH / aspectRatio!;

        /// 修正横屏高度比较小的情况
        var revise = data.size.width - _itemW * count - spaceSize;
        if (revise < 0) {
          _itemW = (data.size.width - spaceSize) / count;
          _itemH = _itemW * aspectRatio!;
          hPaddingLR = 0;
          hPaddingTop = (data.size.height -
                  _itemH * count -
                  spaceSize -
                  data.viewPadding.top) /
              2;
        } else {
          hPaddingLR = revise / 2;
          hPaddingTop = 0;
        }

        Alog.d(
            tag: _tag,
            moduleName: _moduleName,
            content: '$tag, _landScape  _itemH = $_itemH , _itemW= $_itemW');
      }
    }
  }

  /// build
  Widget buildGrid(int page) {
    calAspectRatio();
    return Container(
        padding: EdgeInsets.only(
            top: _isPortrait ? vPaddingTop! : hPaddingTop!,
            left: _isPortrait ? vPaddingLR! : hPaddingLR!,
            right: _isPortrait ? vPaddingLR! : hPaddingLR!),
        color: Colors.black,
        child: Center(
            child: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: space,
          crossAxisSpacing: space,
          childAspectRatio: _isPortrait ? aspectRatio! : 1 / aspectRatio!,
          crossAxisCount: MeetingConfig.defaultGridSide,
          children: buildGridItems(page),
        )));
  }

  List<Widget> buildGridItems(int page) {
    var list = <Widget>[];
    getUidListByPage(page).forEach((roomUid) {
      final user = roomContext.getMember(roomUid);
      final child = user == null
          ? Container()
          : ValueListenableBuilder<bool>(
              valueListenable: user.isInCallListenable,
              builder: (context, isInCall, child) {
                if (isInCall)
                  return buildIsInSystemCall(
                    background: _UIColors.color_292933,
                    fontSize: 14.0,
                  );
                return buildUserVideoView(
                  user,
                  // 如果是大画面，需要订阅大流，否则画廊模式会订阅小流，大流会被覆盖，导致大画面变糊；
                  streamType: bigUid == roomUid
                      ? NEVideoStreamType.kHigh
                      : NEVideoStreamType.kLow,
                  ifVideoOff: buildSmallNameView(user.name),
                );
              },
            );
      list.add(
          buildGridItem(child, roomUid, user?.name, user?.isAudioOn ?? false));
    });
    return list;
  }

  Widget buildIsInSystemCall({
    Color background = Colors.transparent,
    double? containerSize = 52.0,
    double? iconSize,
    double fontSize = 17.0,
    double gap = 20.0,
    bool showText = true,
  }) {
    return Container(
      alignment: Alignment.center,
      color: background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: ShapeDecoration(
              shape: const CircleBorder(
                side: const BorderSide(
                  color: Colors.white,
                ),
              ),
            ),
            child: Icon(
              Icons.phone,
              size: iconSize,
              color: Colors.white,
            ),
          ),
          if (showText) SizedBox(height: gap),
          if (showText)
            Text(
              NEMeetingUIKitLocalizations.of(context)!.isInCall,
              maxLines: 1,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildGridItem(
      Widget view, String roomUid, String? name, bool muteAudio) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isHighLight(roomUid) ? _UIColors.color_59F20C : Colors.black,
              width: 2,
            ),
          ),
          child: view,
        ),
        buildGalleyNameView(roomUid, name, muteAudio),
      ],
    );
  }

  Widget buildGalleyNameView(String userId, String? name, bool muteAudio) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        height: 21,
        margin: EdgeInsets.only(left: 4, bottom: 4),
        padding: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
            color: Colors.black54,
            border: Border.all(color: Colors.transparent, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(2))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildRoomUserVolumeIndicator(userId, size: 12),
            Text(
              name ?? '',
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  // 是否需要高亮
  bool isHighLight(String? roomUid) {
    if (roomUid == null) return false;
    if (focusUid != null) return roomUid == focusUid;
    return activeUid == roomUid && !isSelf(roomUid);
    //return roomUid == (switchBigAndSmall ? smallUid : bigUid);
  }

  Align buildBottomLeftName(NERoomMember user) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        height: 13,
        margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.all(Radius.circular(2))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildRoomUserVolumeIndicator(
              user.uuid,
              size: 12,
            ),
            Text(
              truncate(user.name),
              softWrap: false,
              maxLines: 1,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Align buildAudioIcon(bool muteAudio) {
    return Align(
        alignment: Alignment.topLeft,
        child: Container(
          padding: EdgeInsets.all(2),
          child: muteAudio
              ? SizedBox(
                  height: 12,
                  width: 12,
                  child: Icon(NEMeetingIconFont.icon_yx_tv_voice_offx,
                      size: 9, color: _UIColors.colorFE3B30))
              : Container(),
        ));
  }

  Iterable<NERoomMember> get userList => roomContext.getAllUsers();

  int get userCount => userList.length;

  /// add 1 focus ui
  int calculatePageSize() {
    final memberSize = userCount;
    if (arguments.noGallery || memberSize < 2) {
      return 1;
    }

    final whiteboardSharing = isWhiteBoardSharing();
    // 白板编辑模式下，不支持右滑动，因为与PageView的滑动手势有冲突
    if (whiteboardSharing && whiteBoardEditingState.value) {
      return 1;
    }

    final screenSharing = isSelfScreenSharing() || isOtherScreenSharing();
    // 虽然只有两个人，但小画面是被共享者占用了，所以本端自己的小画面只能放到第二页去显示
    if (!screenSharing &&
        !whiteboardSharing &&
        (_isIpad ? memberSize <= 1 : memberSize <= 2)) {
      return 1;
    }
    // 如果是其他人在屏幕共享，需要调整memberSize
    // 如果共享者已经在第一页小画面中显示，其他页需要过滤掉 共享者；如果第一页没有显示，则需要显示。
    // if (otherMemberScreenSharing && shouldShowScreenShareUserVideo(rtcController.getScreenSharingUserUuid())) {
    //   memberSize = memberSize - 1;
    // }
    return (memberSize / galleryItemSize).ceil() + 1;
  }

  Widget buildBigVideoView(NERoomMember? bigViewUser,
      {NERoomUserVideoViewListener? videoViewListener}) {
    if (bigViewUser == null) return Container();
    return ValueListenableBuilder<bool>(
      valueListenable: bigViewUser.isInCallListenable,
      builder: (context, isInCall, child) {
        if (isInCall) {
          return Stack(
            children: [
              buildBigNameView(bigViewUser),
              buildIsInSystemCall(
                background: _UIColors.color_181820.withAlpha(76),
                showText: false,
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  // icon_container_size + gap_size * 2 + line_height * 2
                  height: 52.0 + 20.0 * 2 + 17.0 * 2,
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    NEMeetingUIKitLocalizations.of(context)!.isInCall,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return buildUserVideoView(
          bigViewUser,
          streamType: NEVideoStreamType.kHigh,
          ifVideoOff: buildBigNameView(bigViewUser),
          videoViewListener: videoViewListener,
        );
      },
    );
  }

  Widget buildUserVideoView(
    NERoomMember user, {
    NEVideoStreamType streamType = NEVideoStreamType.kLow,
    Widget? ifVideoOff,
    Color? backgroundColor,
    NERoomUserVideoViewListener? videoViewListener,
  }) {
    return user.canRenderVideo
        ? ValueListenableBuilder<bool>(
            valueListenable:
                isSelf(user.uuid) ? localMirrorState : alwaysUnMirrorState,
            builder: (context, mirror, child) {
              return NERoomUserVideoView(
                user.uuid,
                debugName: user.name,
                backgroundColor: backgroundColor,
                streamType: streamType,
                mirror: mirror,
                listener: videoViewListener ?? this,
              );
            },
          )
        : (ifVideoOff ?? Container());
  }

  Widget buildSmallVideoView(NERoomMember user) {
    return buildUserVideoView(user, ifVideoOff: buildSmallNameView(user.name));
  }

  Widget buildNameView(String userId, AlignmentGeometry alignment,
      {String? prefix, String? suffix}) {
    final user = roomContext.getMember(userId);
    return Align(
      alignment: alignment,
      child: Container(
        height: 21,
        margin: EdgeInsets.only(
            left: 4, right: 4, top: 4 + MediaQuery.of(context).viewPadding.top),
        padding: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
            color: Colors.black54,
            border: Border.all(color: Colors.transparent, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(2))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (user != null)
              buildRoomUserVolumeIndicator(
                user.uuid,
                size: 12,
              ),
            if ((user?.name ?? '').isNotEmpty)
              Container(
                  child: Text(
                      '${prefix ?? ''}${truncate(user?.name ?? '')}${suffix ?? ''}',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      key: MeetingUIValueKeys.nickName,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w400))),
          ],
        ),
      ),
    );
  }

  Widget buildItemTab(VoidCallback callback, bool state, IconData enableIcon,
      IconData disableIcon, String enableStr, String disableStr,
      {Color? enableColor, Color? disableColor}) {
    return Expanded(
        child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: callback,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(state ? enableIcon : disableIcon,
              color: state
                  ? (enableColor ?? _UIColors.colorFE3B30)
                  : (disableColor ?? _UIColors.colorECEDEF)),
          Padding(padding: EdgeInsets.only(top: 2)),
          Text(
            state ? enableStr : disableStr,
            style: TextStyle(
                color: _UIColors.colorECEDEF,
                fontSize: 10,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w400),
          )
        ],
      ),
    ));
  }

  Widget buildSmallView(String? userId) {
    final user = roomContext.getMember(userId);
    if (user == null) return Container();
    Widget child = Container(
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.white,
        width: 1.0,
      )),
      child: ValueListenableBuilder<bool>(
        valueListenable: user.isInCallListenable,
        builder: (context, isInCall, child) {
          return Stack(
            children: <Widget>[
              if (!isInCall) buildSmallVideoView(user),
              if (isInCall)
                buildIsInSystemCall(
                  background: const Color(0xFF292933),
                  containerSize: 32.0,
                  fontSize: 8,
                  gap: 10,
                ),
              buildBottomLeftName(user),
            ],
          );
        },
      ),
    );
    if (_isSwitchBigSmallViewsEnable()) {
      child = GestureDetector(
        onTap: () {
          switchBigAndSmall = !switchBigAndSmall;
          setState(swapBigSmallUid);
        },
        child: child,
      );
    }
    return child;
  }

  Future<void> _lowerMyHand() async {
    if (roomContext.localMember.isRaisingHand) {
      final cancel = await DialogUtils.showCommonDialog(
          context,
          NEMeetingUIKitLocalizations.of(context)!.cancelHandsUp,
          NEMeetingUIKitLocalizations.of(context)!.cancelHandsUpTips, () {
        Navigator.of(context).pop();
      }, () {
        Navigator.of(context).pop(true);
      });
      if (!mounted || _isAlreadyCancel) return;
      if (cancel != true) return;
      trackPeriodicEvent(TrackEventName.handsUp,
          extra: {'value': 0, 'meeting_num': arguments.meetingNum});
      final result = await roomContext.lowerMyHand();
      if (!result.isSuccess()) {
        showToast(result.msg ??
            NEMeetingUIKitLocalizations.of(context)!.cancelHandsUpFail);
      }
    }
  }

  bool get enableMediaPubOnAudioMute {
    final shouldUnpub = arguments.options.unpubAudioOnMute &&
        NEMeetingKit.instance.getSettingsService().shouldUnpubOnAudioMute();
    return !shouldUnpub;
  }

  Object? audioActionToken;
  Future<void> _muteMyAudio(bool mute) async {
    if (mute || roomContext.canUnmuteMyAudio() || _invitingToOpenAudio) {
      _invitingToOpenAudio = false;
      trackPeriodicEvent(TrackEventName.switchAudio,
          extra: {'value': mute ? 0 : 1, 'meeting_num': arguments.meetingNum});
      muteDetectStartedTimer?.cancel();
      final token = Object();
      audioActionToken = token;
      if (mute) {
        rtcController.muteMyAudioAndAdjustVolume().onSuccess(() {
          muteDetectStartedTimer = Timer(muteMyAudioDelay, () {
            muteDetectStarted = true;
          });
        }).onFailure((code, msg) {
          if (!mounted || audioActionToken != token) return;
          showToast(
              msg ?? NEMeetingUIKitLocalizations.of(context)!.muteAudioFail);
        });
      } else {
        rtcController
            .unmuteMyAudioWithCheckPermission(context, arguments.meetingTitle)
            .onFailure((code, msg) {
          if (!mounted || audioActionToken != token) return;
          showToast(
              msg ?? NEMeetingUIKitLocalizations.of(context)!.unMuteAudioFail);
        });
      }
    } else {
      if (roomContext.localMember.isRaisingHand) {
        ToastUtils.showToast(context,
            NEMeetingUIKitLocalizations.of(context)!.alreadyHandsUpTips);
        return;
      }
      final willRaise = await DialogUtils.showCommonDialog(
          context,
          NEMeetingUIKitLocalizations.of(context)!.muteAudioAll,
          NEMeetingUIKitLocalizations.of(context)!.muteAllHandsUpTips, () {
        Navigator.of(context).pop();
      }, () {
        Navigator.of(context).pop(true);
      }, acceptText: NEMeetingUIKitLocalizations.of(context)!.handsUpApply);
      if (!mounted || _isAlreadyCancel) return;
      if (willRaise != true || !arguments.audioMute) return;
      // check again
      if (roomContext.canUnmuteMyAudio()) {
        return;
      }
      trackPeriodicEvent(TrackEventName.handsUp, extra: {
        'value': 1,
        'meeting_num': arguments.meetingNum,
        'type': 'audio'
      });
      final result = await roomContext.raiseMyHand();
      showToast(result.isSuccess()
          ? NEMeetingUIKitLocalizations.of(context)!.handsUpSuccess
          : (result.msg ??
              NEMeetingUIKitLocalizations.of(context)!.handsUpFail));
    }
  }

  bool modifyingAudioShareState = false;
  void enableAudioShare(bool enable) async {
    // 需要先申请权限
    if (enable) {
      final isInCall = await NEMeetingPlugin().phoneStateService.isInCall;
      if (isInCall) {
        showToast(NEMeetingUIKitLocalizations.of(context)!
            .funcNotAvailableWhenInCallState);
        return;
      }

      final hasPermission =
          await PermissionHelper.enableLocalAudioAndCheckPermission(
              context, true, arguments.meetingTitle);
      if (!hasPermission) {
        commonLogger.i(
            'enableLoopbackRecording($enable) cancelled due to no permission');
        return;
      }
    }
    if (modifyingAudioShareState) return;
    modifyingAudioShareState = true;
    rtcController.enableLoopbackRecording(enable).then((value) {
      commonLogger.i('enableLoopbackRecording($enable) $value');
      modifyingAudioShareState = false;
      if (value.isSuccess()) {
        if (!roomContext.localMember.isAudioOn) {
          rtcController.adjustRecordingSignalVolume(0);
        }
        audioSharingListenable.value = enable;
      }
    });
  }

  void _onScreenShare() async {
    final isSharing = isSelfScreenSharing();
    commonLogger.i('_onScreenShare isShare=$isSharing');

    /// 如果不为空且不等于自己，已经有人共享了
    if (isSharing) {
      trackPeriodicEvent(TrackEventName.screenShare,
          extra: {'value': 0, 'meeting_num': arguments.meetingNum});
      final result = await rtcController.stopScreenShare();
      if (!result.isSuccess()) {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.screenShareStopFail);
      } else if (audioSharingListenable.value) {
        enableAudioShare(false);
      }
    } else if (await ifScreenShareAvailable()) {
      confirmStartScreenShare();
    }
  }

  Future<bool> ifScreenShareAvailable() async {
    if (isWhiteBoardSharing()) {
      showToast(NEMeetingUIKitLocalizations.of(context)!.hasWhiteBoardShare);
      return false;
    }
    if (isOtherScreenSharing()) {
      showToast(NEMeetingUIKitLocalizations.of(context)!.shareOverLimit);
      return false;
    }
    // if (await NEMeetingPlugin().phoneStateService.isInCall) {
    //   showToast(NEMeetingUIKitLocalizations.of(context)!.shareOverLimit);
    //   return false;
    // }
    return true;
  }

  void confirmStartScreenShare() {
    if (_meetingState.index >= MeetingState.closing.index) {
      return;
    }

    var tips = arguments.getOptionExtraValue('shareScreenTips');
    if (tips == null || tips.isEmpty) {
      tips = NEMeetingUIKitLocalizations.of(context)!.screenShareTips;
    }

    DialogUtils.showShareScreenDialog(
        context, NEMeetingUIKitLocalizations.of(context)!.screenShare, tips,
        () async {
      Navigator.of(context).pop();
      //wait until dialog dismiss
      await Future.delayed(Duration(milliseconds: 250), () {});

      if (!(await ifScreenShareAvailable())) {
        return;
      }

      trackPeriodicEvent(TrackEventName.screenShare,
          extra: {'value': 1, 'meeting_num': arguments.meetingNum});

      final result = await rtcController.startScreenShare(
          iosAppGroup: arguments.iosBroadcastAppGroup);
      if (!mounted) return;
      if (!result.isSuccess()) {
        commonLogger
            .i('engine startScreenCapture error: ${result.code} ${result.msg}');
        if (result.code == NEErrorCode.screenSharingLimitError) {
          showToast(NEMeetingUIKitLocalizations.of(context)!.shareOverLimit);
          return;
        } else if (result.code == NEErrorCode.noScreenSharingPermission) {
          showToast(
              NEMeetingUIKitLocalizations.of(context)!.noShareScreenPermission);
          return;
        }
        showToast(result.msg ??
            NEMeetingUIKitLocalizations.of(context)!.screenShareStartFail);
      } else if (arguments.options.enableAudioShare &&
          _isAudioShareSupported()) {
        enableAudioShare(true);
      }
    });
  }

  ///白板分享模式处理
  Future<void> _onWhiteBoard() async {
    commonLogger.e('onWhiteBoard windowMode=$_windowMode');

    /// 屏幕共享时暂不支持白板共享
    if (rtcController.getScreenSharingUserUuid() != null) {
      ToastUtils.showToast(context,
          NEMeetingUIKitLocalizations.of(context)!.hasScreenShareShare);
      return;
    }

    if (isOtherWhiteBoardSharing()) {
      ToastUtils.showToast(
          context, NEMeetingUIKitLocalizations.of(context)!.shareOverLimit);
      return;
    }

    if (whiteboardController.isSharingWhiteboard()) {
      var result = await whiteboardController.stopWhiteboardShare();
      if (result.code != MeetingErrorCode.success) {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!
                    .whiteBoardShareStopFail);
      }
    } else {
      await whiteboardController.updateWhiteboardConfig(
          isTransparent: arguments.isWhiteboardTransparent);
      if (!mounted) return;
      var result = await whiteboardController.startWhiteboardShare();
      if (result.code != MeetingErrorCode.success && mounted) {
        if (result.code == MeetingErrorCode.meetingWBExists) {
          ToastUtils.showToast(
              context, NEMeetingUIKitLocalizations.of(context)!.shareOverLimit);
          return;
        }
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!
                    .whiteBoardShareStartFail);
      }
    }
  }

  void _trackMuteVideoEvent(bool mute) {
    trackPeriodicEvent(TrackEventName.switchCamera,
        extra: {'value': mute ? 0 : 1, 'meeting_num': arguments.meetingNum});
  }

  Object? videoActionToken;
  void _muteMyVideo(bool mute) async {
    if (mute || roomContext.canUnmuteMyVideo() || _invitingToOpenVideo) {
      _trackMuteVideoEvent(mute);
      _invitingToOpenVideo = false;
      // var enable = await  PermissionHelper.enableLocalVideoAndCheckPermission(context,!mute,arguments.meetingTitle);
      // if(!enable) return;
      final token = Object();
      videoActionToken = token;
      if (mute) {
        rtcController.muteMyVideo().onFailure((code, msg) {
          if (!mounted || videoActionToken != token) return;
          showToast(
              msg ?? NEMeetingUIKitLocalizations.of(context)!.muteVideoFail);
        });
      } else {
        rtcController
            .unmuteMyVideoWithCheckPermission(context, arguments.meetingTitle)
            .onFailure((code, msg) {
          if (!mounted || videoActionToken != token) return;
          showToast(
              msg ?? NEMeetingUIKitLocalizations.of(context)!.unMuteVideoFail);
        });
      }
    } else {
      if (roomContext.localMember.isRaisingHand) {
        ToastUtils.showToast(context,
            NEMeetingUIKitLocalizations.of(context)!.alreadyHandsUpTips);
        return;
      }
      final willRaise = await DialogUtils.showCommonDialog(
          context,
          NEMeetingUIKitLocalizations.of(context)!.muteAllVideo,
          NEMeetingUIKitLocalizations.of(context)!.muteAllVideoHandsUpTips, () {
        Navigator.of(context).pop();
      }, () {
        Navigator.of(context).pop(true);
      }, acceptText: NEMeetingUIKitLocalizations.of(context)!.handsUpApply);
      if (!mounted || _isAlreadyCancel) return;
      if (willRaise != true || !arguments.videoMute) return;
      // check again
      if (roomContext.canUnmuteMyVideo()) {
        return;
      }
      trackPeriodicEvent(TrackEventName.handsUp, extra: {
        'value': 1,
        'meeting_num': arguments.meetingNum,
        'type': 'video'
      });
      final result = await roomContext.raiseMyHand();
      showToast(result.isSuccess()
          ? NEMeetingUIKitLocalizations.of(context)!.handsUpSuccess
          : (result.msg ??
              NEMeetingUIKitLocalizations.of(context)!.handsUpFail));
    }
  }

  /// 从下往上显示
  void _onMember() {
    trackPeriodicEvent(TrackEventName.manageMember,
        extra: {'meeting_num': arguments.meetingNum});
    DialogUtils.showChildNavigatorPopup(
      context,
      (context) => MeetMemberPage(
        MembersArguments(
            options: arguments.options,
            roomInfoUpdatedEventStream: roomInfoUpdatedEventStream.stream,
            audioVolumeStreams: audioVolumeStreams,
            roomContext: roomContext,
            meetingTitle: arguments.meetingTitle),
      ),
    );
  }

  SDKConfig get sdkConfig {
    if (roomContext.isCrossAppJoining) {
      if (crossAppSDKConfig == null) {
        crossAppSDKConfig =
            SDKConfig(roomContext.crossAppAuthorization!.appKey);
        crossAppSDKConfig!.initialize();
      }
      return crossAppSDKConfig!;
    }
    return SDKConfig.current;
  }

  Future<dynamic> _initWithSDKConfig() async {
    void action(dynamic) {
      if (!mounted || _isAlreadyCancel) return;
      _initBeauty();
      _initVirtualBackground();
      focusSwitchInterval = Duration(seconds: sdkConfig.focusSwitchInterval);
      final galleryPageSize = sdkConfig.galleryPageSize;
      if (galleryPageSize != galleryItemSize) {
        setState(() {
          galleryItemSize = galleryPageSize;
        });
      }
    }

    streamSubscriptions.add(sdkConfig.onConfigUpdated.listen(action));
    sdkConfig.initialize().then((value) => action(null));
  }

  bool get isBeautyFuncSupported {
    return sdkConfig.isBeautyFaceSupported;
  }

  bool isBeautyEnabled = false;
  Future<dynamic> _initBeauty() async {
    if (!isBeautyFuncSupported) return;
    var result = await roomContext.rtcController.startBeauty();
    if (result.isSuccess()) {
      isBeautyEnabled = true;
      beautyLevel =
          await NEMeetingKit.instance.getSettingsService().getBeautyFaceValue();
      await setBeautyEffect(beautyLevel);
    } else {
      commonLogger.i('start beauty fail: ${result.msg}');
    }
  }

  bool get isVirtualBackgroundEnabled {
    return sdkConfig.isVirtualBackgroundSupported;
  }

  Future<dynamic> _initVirtualBackground() async {
    if (!isVirtualBackgroundEnabled) return;
    var sharedPreferences = await SharedPreferences.getInstance();
    var currentSelected =
        sharedPreferences.getInt(currentVirtualSelectedKey) ?? 0;
    if (currentSelected != 0) {
      var setting = NEMeetingKit.instance.getSettingsService();
      Directory? cache;
      if (Platform.isAndroid) {
        cache = await getExternalStorageDirectory();
      } else {
        cache = await getApplicationDocumentsDirectory();
      }
      var virtualList =
          sharedPreferences.getStringList(addExternalVirtualListKey) ?? [];
      var list = await setting.getBuiltinVirtualBackgrounds();
      bool builtinVirtualBackgroundListAllDelete =
          sharedPreferences.getBool(builtinVirtualBackgroundListAllDelKey) ??
              false;
      String source = '';
      //组件传入
      if (list.isNotEmpty || builtinVirtualBackgroundListAllDelete) {
        virtualList.forEach((element) {
          list.add(NEMeetingVirtualBackground(element));
        });
        source =
            replaceBundleIdByStr(list[currentSelected - 1].path, cache!.path);
      } else {
        if (currentSelected > virtualListMax) {
          source = replaceBundleIdByStr(
              virtualList[currentSelected - virtualListMax - 1], cache!.path);
        } else {
          source = '${cache?.path}/virtual/$currentSelected.png';
          File file = File(source);
          var exist = await file.exists();
          if (!exist) {
            source = virtualList[currentSelected - 1];
          }
        }
      }
      commonLogger.e('enableVirtualBackground source:$source ');
      if (source != '') {
        rtcController.enableVirtualBackground(
            true,
            NERoomVirtualBackgroundSource(
                backgroundSourceType:
                    NERoomVirtualBackgroundType.kBackgroundImg,
                source: source,
                color: 0,
                blurDegree: NERoomVirtualBackgroundType.kBlurDegreeHigh));
      } else {
        commonLogger.e(
          'enableVirtualBackground virtualList=$virtualList ,currentSelected=$currentSelected',
        );
      }
    }
  }

  void _onBeauty() {
    trackPeriodicEvent(TrackEventName.beauty,
        extra: {'meeting_num': arguments.meetingNum});
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => SliderWidget(
              onChange: (value) async {
                beautyLevel = value;
                await Future.delayed(Duration(milliseconds: 200));
                if (beautyLevel == value) {
                  NEMeetingKit.instance
                      .getSettingsService()
                      .setBeautyFaceValue(value);
                  setBeautyEffect(value);
                }
              },
              level: beautyLevel,
            ));
  }

  void _onInvite() {
    trackPeriodicEvent(TrackEventName.invite,
        extra: {'meeting_num': arguments.meetingNum});
    DialogUtils.showInviteDialog(
        context, (context) => _buildInviteInfo(context));
  }

  String _buildInviteInfo(BuildContext context) {
    var info = '${NEMeetingUIKitLocalizations.of(context)!.inviteTitle}';

    final meetingInfo = arguments.meetingInfo;
    info +=
        '${NEMeetingUIKitLocalizations.of(context)!.meetingSubject}${meetingInfo.subject}\n';
    if (meetingInfo.type == NEMeetingType.kReservation) {
      info +=
          '${NEMeetingUIKitLocalizations.of(context)!.meetingTime}${meetingInfo.startTime.formatToTimeString('yyyy/MM/dd HH:mm')} - ${meetingInfo.endTime.formatToTimeString('yyyy/MM/dd HH:mm')}\n';
    }

    info += '\n';
    if (!arguments.options.isShortMeetingIdEnabled ||
        TextUtils.isEmpty(meetingInfo.shortMeetingNum)) {
      info +=
          '${NEMeetingUIKitLocalizations.of(context)!.meetingNum}${meetingInfo.meetingNum.toMeetingNumFormat()}\n';
    } else if (!arguments.options.isLongMeetingIdEnabled) {
      info +=
          '${NEMeetingUIKitLocalizations.of(context)!.meetingNum}${meetingInfo.shortMeetingNum}\n';
    } else {
      info +=
          '${NEMeetingUIKitLocalizations.of(context)!.shortMeetingNum}${meetingInfo.shortMeetingNum}(${NEMeetingUIKitLocalizations.of(context)!.internalSpecial})\n';
      info +=
          '${NEMeetingUIKitLocalizations.of(context)!.meetingNum}${meetingInfo.meetingNum.toMeetingNumFormat()}\n';
    }
    if (!TextUtils.isEmpty(roomContext.password)) {
      info +=
          '${NEMeetingUIKitLocalizations.of(context)!.meetingPwd}${roomContext.password}\n';
    }
    if (!TextUtils.isEmpty(roomContext.sipCid)) {
      info += '\n';
      info +=
          '${NEMeetingUIKitLocalizations.of(context)!.sipNumber}: ${roomContext.sipCid}\n';
    }
    if (!TextUtils.isEmpty(meetingInfo.inviteUrl)) {
      info += '\n';
      info +=
          '${NEMeetingUIKitLocalizations.of(context)!.invitationUrl}${meetingInfo.inviteUrl}\n';
    }
    return info;
  }

  Widget buildBigNameView(NERoomMember user) {
    return Container(
      color: _UIColors.grey_292933,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isSelf(user.uuid))
              buildRoomUserVolumeIndicator(user.uuid, size: 20),
            Flexible(
              child: Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSmallNameView(String? name) {
    return Container(
        color: _UIColors.color_292933,
        alignment: Alignment.center,
        child: Text(
          name ?? '',
          style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w500),
        ));
  }

  List<String> getUidListByPage(int page) {
    // 这里需要过滤掉共享者的画面
    assert(page > 0);
    var temp = userList.map((user) => user.uuid).toList()
      ..remove(roomContext.localMember.uuid)
      ..insert(0, roomContext.localMember.uuid);

    // final screenShareUser = getScreenShareUserId();
    // if (shouldShowScreenShareUserVideo(screenShareUser)) {
    //   temp.remove(screenShareUser);
    // }

    var start = galleryItemSize * (page - 1);
    if (start >= temp.length) {
      return [];
    }
    return temp.sublist(start, min(start + galleryItemSize, temp.length));
  }

  bool isHost() {
    return roomContext.isMySelfHost();
  }

  /// 自己是否是主持人或者联席主持人
  bool isSelfHostOrCoHost() {
    return isHost() || isSelfCoHost();
  }

  /// 自己是否是联席主持人
  bool isSelfCoHost() {
    return roomContext.isMySelfCoHost();
  }

  /// 是否是联席主持人
  bool isCoHost(String? uuid) {
    return roomContext.isCoHost(uuid);
  }

  /// [uuid] 是否是主持人或者联席主持人
  bool isHostOrCoHost(String? uuid) {
    return roomContext.isHostOrCoHost(uuid);
  }

  /// 从哪儿来回哪儿去
  void _onCancel({int exitCode = 0, String? reason = ''}) {
    if (!_isAlreadyCancel) {
      commonLogger.i(
        '_onCancel exitCode=$exitCode ,reason=$reason',
      );
      if (_meetingState.index < MeetingState.joined.index) {
        ToastUtils.showToast(
            context, NEMeetingUIKitLocalizations.of(context)!.joinMeetingFail);
      }
      _currentExitCode = exitCode;
      _meetingState = MeetingState.closed;
      _dispose();
      _isAlreadyCancel = true;
      Navigator.of(context).popUntil((route) => false);
    }
  }

  void _dispose() {
    if (_isAlreadyCancel) {
      return;
    }
    networkTaskExecutor.dispose();
    NERoomKit.instance.messageChannelService
        .removeMessageChannelCallback(messageCallback);
    roomContext.removeEventCallback(roomEventCallback);
    roomContext.removeRtcStatsCallback(roomStatsCallback);
    _galleryModePageController?.removeListener(_handleGalleryModePageChange);
    _galleryModePageController?.dispose();
    userVideoStreamSubscriber.dispose();
    roomInfoUpdatedEventStream.close();
    restorePreferredOrientations();
    InMeetingService()
      ..clearRoomContext()
      .._updateHistoryMeetingItem(historyMeetingItem)
      .._serviceCallback = null
      .._minimizeDelegate = null
      .._audioDelegate = null;
    joinTimeOut?.cancel();
    muteDetectStartedTimer?.cancel();
    streamSubscriptions.forEach((subscription) {
      subscription.cancel();
    });
    cancelInComingTips();
    Wakelock.disable().catchError((e) {
      commonLogger.i('Wakelock error $e');
    });
    if (Platform.isAndroid) {
      NEMeetingPlugin().getNotificationService().stopForegroundService();
    }
    // 在后台的时候由于各种原因从会议中退出，需要对应的销毁Activity
    // 且下次不能再次发送销毁的消息
    if (SchedulerBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      EventBus().emit(NEMeetingUIEvents.flutterPageDisposed);
      _hasRequestEngineToDetach = true;
      commonLogger.i('MeetingPage request detach from engine');
    }
    appBarAnimController.dispose();
    _morePopupMenuAnimation?.dispose();
    MeetingCore().notifyStatusChange(
        NEMeetingStatus(NEMeetingEvent.disconnecting, arg: _currentExitCode));
    MeetingCore().notifyStatusChange(NEMeetingStatus(NEMeetingEvent.idle));
    trackPeriodicEvent(TrackEventName.meetingFinish, extra: {
      'meeting_time': DateTime.now().millisecondsSinceEpoch - meetingBeginTime
    });
    audioVolumeStreams.forEach((key, value) {
      value.close();
    });
    crossAppSDKConfig?.dispose();
  }

  void restorePreferredOrientations() {
    if (arguments.restorePreferredOrientations != null) {
      SystemChrome.setPreferredOrientations(
          [...arguments.restorePreferredOrientations!]);
    }
  }

  TransformationController? _screenShareController;
  bool _screenShareInteractionTipShown = false;
  int _screenShareWidth = 0, _screenShareHeight = 0;
  Orientation? _screenOrientation;

  void _showScreenShareInteractionTip() {
    if (!_screenShareInteractionTipShown) {
      _screenShareInteractionTipShown = true;
      showToast(
          NEMeetingUIKitLocalizations.of(context)!.screenShareInteractionTip);
    }
  }

  TransformationController? _getScreenShareController() {
    final orientation = MediaQuery.of(context).orientation;
    if (_screenOrientation != null &&
        _screenOrientation != orientation &&
        _screenShareController != null) {
      _screenShareController!.value = Matrix4.identity();
    }
    _screenOrientation = orientation;
    return _screenShareController;
  }

  ValueNotifier<bool>? _screenShareListenable;

  ValueNotifier<bool> get screenShareListenable {
    _screenShareListenable ??= ValueNotifier(isSelfScreenSharing());
    return _screenShareListenable!;
  }

  ValueNotifier<bool>? _whiteBoardShareListenable;

  ValueNotifier<bool> get whiteBoardShareListenable {
    _whiteBoardShareListenable ??= ValueNotifier(isSelfWhiteBoardSharing());
    return _whiteBoardShareListenable!;
  }

  void memberNameChanged(NERoomMember member, String name) {
    if (isSelf(member.uuid)) {
      historyMeetingItem?.nickname = name;
    }
    _onRoomInfoChanged();
  }

  /// 此处只处理了txt 样式的消息
  void chatroomMessagesReceived(List<NERoomChatMessage> message) {
    message.forEach((msg) {
      if (_messageSource.handleReceivedMessage(msg)) {
        if (ModalRoute.of(context)!.isCurrent) {
          showInComingMessage(msg);
        }
      } else {
        commonLogger.i(
            'chatroomMessagesReceived: unsupported message type of ${msg.runtimeType}');
      }
    });
  }

  void memberAudioMuteChanged(
      NERoomMember member, bool mute, NERoomMember? operator) {
    if (isSelf(member.uuid)) {
      arguments.audioMute = mute;
      if (mute && !isSelf(operator?.uuid) && isHostOrCoHost(operator?.uuid)) {
        showToast(
            NEMeetingUIKitLocalizations.of(context)!.meetingHostMuteAudio);
      }
      if (!mute && member.isRaisingHand && roomContext.isAllAudioMuted) {
        /// roomContext.isAllAudioMuted 增加这个判断是为了 如果视频开启全体关闭 用户举手，而此时用户自行打开音频的时候，手会放下的异常
        roomContext.lowerMyHand();
        showToast(
            NEMeetingUIKitLocalizations.of(context)!.muteAudioHandsUpOnTips);
      }
    }
    if (speakingUid == member.uuid && mute) {
      speakingUid = null;
    }
    _onRoomInfoChanged();
  }

  void showOpenMicDialog() async {
    if (!_isShowOpenMicroDialog) {
      _isShowOpenMicroDialog = true;
      final agree = await DialogUtils.showOpenAudioDialog(
          context,
          NEMeetingUIKitLocalizations.of(context)!.openMicro,
          NEMeetingUIKitLocalizations.of(context)!.hostOpenMicroTips, () {
        Navigator.of(context).pop();
      }, () {
        Navigator.of(context).pop(true);
      });
      if (!mounted || _isAlreadyCancel) return;
      _isShowOpenMicroDialog = false;
      if (agree == true && arguments.audioMute) {
        _muteMyAudio(false);
      }
    }
  }

  void showOpenVideoDialog() async {
    if (!_isShowOpenVideoDialog) {
      _isShowOpenVideoDialog = true;
      final agree = await DialogUtils.showOpenVideoDialog(
          context,
          NEMeetingUIKitLocalizations.of(context)!.openCamera,
          NEMeetingUIKitLocalizations.of(context)!.hostOpenCameraTips, () {
        Navigator.of(context).pop(false);
      }, () {
        Navigator.of(context).pop(true);
      });
      if (!mounted || _isAlreadyCancel) return;
      _isShowOpenVideoDialog = false;
      if (agree == true && arguments.videoMute) {
        _muteMyVideo(false);
      }
    }
  }

  void memberVideoMuteChanged(
      NERoomMember member, bool mute, NERoomMember? operator) async {
    trackPeriodicEvent(
      !mute ? TrackEventName.memberVideoStart : TrackEventName.memberVideoStop,
      extra: {'member_uid': member.uuid, 'meeting_num': arguments.meetingNum},
    );

    if (roomContext.isMySelf(member.uuid)) {
      if (mute && !isSelf(operator?.uuid) && isHostOrCoHost(operator?.uuid)) {
        ToastUtils.showToast(context,
            NEMeetingUIKitLocalizations.of(context)!.meetingHostMuteVideo);
      }
      if (!mute && member.isRaisingHand && roomContext.isAllVideoMuted) {
        ///  roomContext.isAllVideoMuted 增加这个判断是为了 如果音频开启全体静音 用户举手，而此时用户自行打开视频的时候，手会放下的异常
        roomContext.lowerMyHand();
      }
      arguments.videoMute = mute;
    }
    _onRoomInfoChanged();
  }

  void memberRoleChanged(
      NERoomMember member, NERoomRole before, NERoomRole after) {
    if (isSelf(member.uuid)) {
      /// 角色变更的用户是自己
      if (isHost()) {
        /// 被设置为主持人
        if (member.isRaisingHand) {
          roomContext.lowerMyHand();
        }
        ToastUtils.showToast(
            context, NEMeetingUIKitLocalizations.of(context)!.yourChangeHost);
      } else if (isSelfCoHost()) {
        /// 被设置为联席主持人
        if (member.isRaisingHand) {
          roomContext.lowerMyHand();
        }
        ToastUtils.showToast(
            context, NEMeetingUIKitLocalizations.of(context)!.yourChangeCoHost);
      } else if (before.name == MeetingRoles.kCohost &&
          after.name == MeetingRoles.kMember) {
        /// 被取消联席主持人
        ToastUtils.showToast(context,
            NEMeetingUIKitLocalizations.of(context)!.yourChangeCancelCoHost);
      }
    }
    _onRoomInfoChanged();
  }

  @override
  void dispose() {
    assert(() {
      // debugPrintScheduleBuildForStacks = false;
      debugPrintRebuildDirtyWidgets = false;
      debugRepaintTextRainbowEnabled = debugRepaintRainbowEnabled = false;
      return true;
    }());
    _dispose();
    if (!_isMinimized && !_hasRequestEngineToDetach) {
      EventBus().emit(NEMeetingUIEvents.flutterPageDisposed);
    }
    AppStyle.setStatusBarTextBlackColor();
    PaintingBinding.instance.imageCache.clear();
    //FilePicker.platform.clearTemporaryFiles();
    super.dispose();
  }

  /// 被踢出, 没有操作3秒自动退出
  void onKicked() {
    var countDown = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      _onCancel(
          reason: NEMeetingUIKitLocalizations.of(context)!.removedByHost,
          exitCode: NEMeetingCode.removedByHost);
    });
    DialogUtils.showChildNavigatorDialog(
        context,
        (context) => CupertinoAlertDialog(
              title: Text(NEMeetingUIKitLocalizations.of(context)!.notify),
              content:
                  Text(NEMeetingUIKitLocalizations.of(context)!.hostKickedYou),
              actions: <Widget>[
                CupertinoDialogAction(
                    child: Text(
                      NEMeetingUIKitLocalizations.of(context)!.sure,
                      key: MeetingUIValueKeys.closeMeetingNotification,
                    ),
                    onPressed: () {
                      countDown.cancel();
                      _onCancel(
                          reason: NEMeetingUIKitLocalizations.of(context)!
                              .removedByHost,
                          exitCode: NEMeetingCode.removedByHost);
                    })
              ],
            ));
  }

  void setupChatRoom() async {
    if (_isMenuItemShowing(NEMenuIDs.chatroom)) {
      var result = await chatController.joinChatroom();
      if (!result.isSuccess()) {
        /// 聊天室进入失败
        ToastUtils.showToast(context,
            NEMeetingUIKitLocalizations.of(context)!.enterChatRoomFail);
      }
    }
  }

  /// 提示聊天室接受消息
  void showInComingMessage(NERoomChatMessage chatRoomMessage) {
    // 聊天菜单不显示时，不出现聊天气泡
    if (!_isMenuItemShowing(NEMenuIDs.chatroom)) {
      return;
    }

    String? content;
    if (chatRoomMessage is NERoomChatTextMessage) {
      content = chatRoomMessage.text;
    } else if (chatRoomMessage is NERoomChatImageMessage) {
      content = NEMeetingUIKitLocalizations.of(context)!.imageMessageTip;
    } else if (chatRoomMessage is NERoomChatFileMessage) {
      content = NEMeetingUIKitLocalizations.of(context)!.fileMessageTip;
    }
    if (content == null) {
      return;
    }

    cancelInComingTips();
    _overlayEntry = OverlayEntry(builder: (context) {
      return SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
              margin: EdgeInsets.only(bottom: bottomBarHeight + 12, right: 12),
              padding: EdgeInsets.all(12),
              decoration: ShapeDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        _UIColors.grey_292933,
                        _UIColors.color_212129
                      ]),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              width: 240,
              height: 60,
              child: GestureDetector(
                  onTap: () {
                    _hideMorePopupMenu();
                    onChat();
                  },
                  child: Row(children: <Widget>[
                    buildHead(chatRoomMessage.fromNick),
                    SizedBox(width: 8),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                          buildName(chatRoomMessage.fromNick),
                          buildContent(content)
                        ]))
                  ]))),
        ),
      );
    });
    Overlay.of(context)!.insert(_overlayEntry!);
    _inComingTipsTimer = Timer(const Duration(seconds: 5), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void cancelInComingTips() {
    _inComingTipsTimer?.cancel();
    _inComingTipsTimer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget buildHead(String? nick) {
    return ClipOval(
        child: Container(
      height: 36,
      width: 36,
      decoration: ShapeDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[_UIColors.blue_5996FF, _UIColors.blue_2575FF]),
          shape: Border()),
      alignment: Alignment.center,
      child: Text(
        /// 修改当nick为空串的时候，截取越界问题
        (nick?.isNotEmpty ?? false) ? (nick?.substring(0, 1) ?? '') : '',
        style: TextStyle(
            fontSize: 21, color: Colors.white, decoration: TextDecoration.none),
      ),
    ));
  }

  Widget buildName(String nick) {
    return Text(
      nick,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: _UIColors.greyCCCCCC,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.none),
    );
  }

  Widget buildContent(String? content) {
    return Text(
      content ?? '',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: _UIColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.none),
    );
  }

  void _onSwitchLoudspeaker() {
    final curDevice = _audioDeviceSelected.value;
    final targetDevice = isEarpiece()
        ? NEAudioOutputDevice.kSpeakerPhone
        : NEAudioOutputDevice.kEarpiece;
    rtcController
        .setSpeakerphoneOn(targetDevice == NEAudioOutputDevice.kSpeakerPhone)
        .then((result) {
      if (mounted && result.isSuccess()) {
        if (_audioDeviceSelected.value == curDevice) {
          _audioDeviceSelected.value = targetDevice;
        }
      }
    });
  }

  void _onSwitchCamera() async {
    final result = await rtcController.switchCamera();
    if (result.isSuccess()) {
      if (!arguments.options.enableFrontCameraMirror) return;
      bool current = localMirrorState.value;
      localMirrorState.value = !current;
    }
  }

  Widget _onNetworkView(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          margin: EdgeInsets.only(top: appBarHeight - 12),
          child: SafeArea(
            child: getNetworkInfoBuilder(context),
          ),
        ),
      ),
    );
  }

  void _onNetworkInfo() {
    Navigator.of(context).push(
      DialogRoute(
        context: context,
        builder: (context) {
          return _onNetworkView(context);
        },
        barrierColor: Colors.transparent,
      ),
    );
  }

  Widget getNetworkInfoBuilder(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: meetingNetworkInfoListenable,
      builder: (BuildContext context, NetWorkRttInfo value, Widget? child) {
        return showNetworkInfo(context, value);
      },
    );
  }

  Widget showNetworkInfo(BuildContext context, NetWorkRttInfo value) {
    double position = 50;
    if (roomContext.localMember.isVideoOn) {
      position = 85;
    }
    return Container(
        margin: EdgeInsets.only(left: 12),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                    margin: EdgeInsets.only(left: position),
                    child: Image.asset(NEMeetingImages.arrow,
                        package: NEMeetingImages.package)),
              ),
              Container(
                  padding: EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.white),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(getNetworkStatusDesc(_networkStats.value),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold,
                                color: _UIColors.black)),
                      ]),
                      SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              NEMeetingUIKitLocalizations.of(context)!
                                      .localLatency +
                                  ":",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 14,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w400,
                                  color: _UIColors.black)),
                          SizedBox(width: 58),
                          Text(value.networkDownRtt.toString() + "ms",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 14,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w400,
                                  color: _UIColors.black))
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                NEMeetingUIKitLocalizations.of(context)!
                                        .packetLossRate +
                                    ":",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.w400,
                                    color: _UIColors.black)),
                            SizedBox(width: 36),
                            Container(
                              padding: EdgeInsets.only(top: 2),
                              child: Column(
                                children: <Widget>[
                                  Row(children: [
                                    Icon(Icons.arrow_upward,
                                        color: Colors.green, size: 16.0),
                                    Text(value.upLossRate.toString() + '%',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: 14,
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.w400,
                                            color: _UIColors.black))
                                  ]),
                                  SizedBox(height: 8),
                                  Row(children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      color: Colors.blue,
                                      size: 16.0,
                                    ),
                                    Text(value.downLossRate.toString() + '%',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: 14,
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.w400,
                                            color: _UIColors.black)),
                                  ])
                                ],
                              ),
                            )
                          ]),
                    ],
                  ))
            ]));
  }

  //成员进入房间 跟[onRoomUserJoin]逻辑保持一致
  void memberJoinRoom(List<NERoomMember> userList) {
    for (var user in userList) {
      if (isSelfHostOrCoHost() && user.isVisible) {
        ToastUtils.showToast(context,
            '${(user.name)}${NEMeetingUIKitLocalizations.of(context)!.onUserJoinMeeting}');
      }
      // if (isVisible && autoSubscribeAudio) {
      //   inRoomService.getInRoomAudioController().subscribeRemoteAudioStream(user.userId);
      // }
      audioVolumeStreams.putIfAbsent(
          user.uuid, () => StreamController<int>.broadcast());
    }
    onMemberInOrOut();
  }

  String truncate(String str) {
    return '${str.substring(0, min(str.length, 10))}${((str.length) > 10 ? "..." : "")}';
  }

  // 成员离开房间 与[onRoomUserLeave] 一致
  void memberLeaveRoom(List<NERoomMember> userList) {
    userList.forEach((user) {
      trackPeriodicEvent(TrackEventName.memberLeaveMeeting, extra: {
        'member_uid': user.uuid,
        'meeting_num': arguments.meetingNum
      });
      commonLogger.i('onUserLeave ${user.name}');
      if (isSelfHostOrCoHost() && user.isVisible) {
        ToastUtils.showToast(context,
            '${user.name}${NEMeetingUIKitLocalizations.of(context)!.onUserLeaveMeeting}');
      }
      volumeList?.removeWhere((element) => element.userUuid == user.uuid);
      if (activeUid == user.uuid) {
        activeUid = null;
      }
      audioVolumeStreams.remove(user.uuid)?.close();
    });
    onMemberInOrOut();
    if (!roomContext.localMember.isVisible && userCount == 0) {
      commonLogger.i('No other members in meeting, leave meeting');
      roomContext.leaveRoom();
      return;
    }
  }

  void _determineActiveUser([bool forceUpdate = false]) {
    final now = DateTime.now();
    if (!forceUpdate &&
        now.difference(lastFocusSwitchTimestamp) < focusSwitchInterval) {
      return;
    }
    lastFocusSwitchTimestamp = now;

    var oldSpeakingUid = speakingUid;
    speakingUid = null;
    var oldActiveUserId = activeUid;
    activeUid = null;
    var maxVolume = -1;
    String? maxVolumeUserId;
    (volumeList ?? []).where((item) {
      final member = roomContext.getMember(item.userUuid);
      return member != null && member.isAudioOn;
    }).forEach((item) {
      final curVolume = item.volume;
      audioVolumeStreams[item.userUuid]?.add(curVolume);
      if (curVolume > MeetingConfig.volumeLowThreshold &&
          curVolume > maxVolume) {
        maxVolume = curVolume;
        maxVolumeUserId = item.userUuid;
      }
    });
    if (maxVolumeUserId != null) {
      activeUid = maxVolumeUserId;
      speakingUid = maxVolumeUserId;
    }
    if (oldActiveUserId != activeUid || oldSpeakingUid != speakingUid) {
      setState(() {});
    }
  }

  void _onRoomInfoChanged() {
    _meetingMemberCount.value = userCount;
    if (!roomInfoUpdatedEventStream.isClosed) {
      roomInfoUpdatedEventStream.add(const Object());
    }
    setState(() {});
  }

  void swapBigSmallUid() {
    commonLogger.i('swapBigSmallUid switchBigAndSmall= $switchBigAndSmall');
    if (bigUid != null && smallUid != null) {
      var temp = bigUid;
      bigUid = smallUid;
      smallUid = temp;
    } else {
      /// 只有一个大画面了, 退回切换
      switchBigAndSmall = false;
    }
  }

  bool _isSwitchBigSmallViewsEnable() {
    // 共享情况下，小画面不允许切换
    if (isOtherScreenSharing() ||
        isSelfScreenSharing() ||
        isWhiteBoardSharing()) return false;
    return true;
  }

  void determineBigSmallUser() {
    final oldFocus = focusUid;
    final oldActive = activeUid;
    final oldBig = bigUid;
    final oldSmall = smallUid;

    final users = userList.toList();
    if (users.length == 1) {
      // 特殊处理 房间只有我
      bigUid = users.first.uuid;
      smallUid = null;
    } else if (users.length >= 2) {
      final screenSharingUid = getScreenShareUserId();
      final selfUid = roomContext.localMember.uuid;
      // 别人在共享屏幕，则大屏是共享内容画面，小屏是共享者画面
      if (screenSharingUid != null && selfUid != screenSharingUid) {
        bigUid = null;
        smallUid = screenSharingUid;
        switchBigAndSmall = false;
      } else if (focusUid != null) {
        // 房间有其他人
        // 有focus big可以确定, 如果焦点是自己因此大画面是自己， 小画面选择一个， 否则小画面是自己
        bigUid = focusUid;
        smallUid = bigUid == selfUid ? _pickRoomUid(users) : selfUid;
      } else {
        // 开始计算big，无focus，右下角肯定是自己，small可以确定是自己
        bigUid = _pickRoomUid(users);
        smallUid = selfUid;
      }
    }
    if (switchBigAndSmall) {
      swapBigSmallUid();
    }

    if (oldFocus != focusUid ||
        oldActive != activeUid ||
        oldBig != bigUid ||
        oldSmall != smallUid) {
      commonLogger.i(
          'BigSmall: focus=$focusUid active=$activeUid big=$bigUid small=$smallUid');
    }
  }

  String _pickRoomUid(Iterable<NERoomMember> users) {
    // active > host > joined
    if (activeUid != null) {
      return activeUid!;
    }
    final hostUid = roomContext.getHostUuid();
    if (!roomContext.isMySelfHost() && roomContext.getMember(hostUid) != null) {
      // 主持人在这个会议中
      return hostUid!;
    }
    String? userId;
    for (var user in users) {
      if (!isSelf(user.uuid)) {
        userId ??= user.uuid;
        if (user.canRenderVideo) {
          return user.uuid;
        }
      }
    }
    return userId!;
  }

  void onRtcAudioOutputDeviceChanged(NEAudioOutputDevice selected) {
    commonLogger.i('onAudioDeviceChanged selected=$selected');
    _audioDeviceSelected.value = selected;
  }

  void onRtcVirtualBackgroundSourceEnabled(bool enabled, int reason) {
    commonLogger.i(
        'onRtcVirtualBackgroundSourceEnabled enabled=$enabled,reason:$reason');

    /// 预览虚拟背景不进行提示
    if (!isPreviewVirtualBackground) return;
    switch (reason) {
      case NERoomVirtualBackgroundSourceStateReason.kImageNotExist:
        ToastUtils.showToast(
            context,
            NEMeetingUIKitLocalizations.of(context)!
                .virtualBackgroundImageNotExist);
        break;
      case NERoomVirtualBackgroundSourceStateReason.kImageFormatNotSupported:
        ToastUtils.showToast(
            context,
            NEMeetingUIKitLocalizations.of(context)!
                .virtualBackgroundImageFormatNotSupported);
        break;
      case NERoomVirtualBackgroundSourceStateReason.kDeviceNotSupported:
        ToastUtils.showToast(
            context,
            NEMeetingUIKitLocalizations.of(context)!
                .virtualBackgroundImageDeviceNotSupported);
        break;
    }
  }

  void handleRoomRtcStats(NERoomRtcStats stats) {
    final screenShareUuid =
        roomContext.rtcController.getScreenSharingUserUuid();
    bool isLocalVideoOn = roomContext.localMember.isVideoOn;
    bool isLocalScreenShareOn = screenShareUuid == roomContext.localMember.uuid;

    int upLossRate = (isLocalVideoOn || isLocalScreenShareOn)
        ? stats.txVideoPacketLossRate
        : stats.txAudioPacketLossRate;

    bool isRemoteVideoOn =
        roomContext.remoteMembers.any((member) => member.isVideoOn);
    bool isRemoteScreenShareOn = roomContext.remoteMembers
        .any((member) => member.uuid == screenShareUuid);

    int downLossRate = (isRemoteVideoOn || isRemoteScreenShareOn)
        ? stats.rxVideoPacketLossRate
        : stats.rxAudioPacketLossRate;

    _networkInfo.value =
        NetWorkRttInfo(stats.downRtt, downLossRate, upLossRate);

    // assert(() {
    //   debugPrint(
    //       'downRtt: ${stats.downRtt}, upLossRate: $upLossRate, downLossRate: $downLossRate');
    //   return true;
    // }());
  }

  void handleRoomNetworkQuality(List<NERoomRtcNetworkQualityInfo> statsArray) {
    var stats = statsArray
        .takeWhile((stats) => stats.userId == roomContext.localMember.uuid)
        .firstOrNull;
    if (stats != null) {
      _networkStats.value = getNetworkStatus(stats.upStatus, stats.downStatus);
      // assert(() {
      //   debugPrint(
      //       'userId: ${stats.userId},upStatus: ${stats.upStatus}, downStatus: ${stats.downStatus}');
      //   return true;
      // }());
    }
  }

  _NetworkStatus getNetworkStatus(NERoomRtcNetworkStatusType upStatus,
      NERoomRtcNetworkStatusType downStatus) {
    if ((upStatus == NERoomRtcNetworkStatusType.kStatusGood ||
            upStatus == NERoomRtcNetworkStatusType.kStatusExcellent) &&
        (downStatus == NERoomRtcNetworkStatusType.kStatusGood ||
            downStatus == NERoomRtcNetworkStatusType.kStatusExcellent)) {
      return _NetworkStatus.good;
    } else if ((upStatus == NERoomRtcNetworkStatusType.kStatusVeryBad ||
            upStatus == NERoomRtcNetworkStatusType.kStatusDown) ||
        (downStatus == NERoomRtcNetworkStatusType.kStatusVeryBad ||
            downStatus == NERoomRtcNetworkStatusType.kStatusDown)) {
      return _NetworkStatus.poor;
    } else if (upStatus == NERoomRtcNetworkStatusType.kStatusUnknown ||
        downStatus == NERoomRtcNetworkStatusType.kStatusUnknown) {
      return _NetworkStatus.unknown;
    } else {
      return _NetworkStatus.normal;
    }
  }

  String getNetworkStatusDesc(_NetworkStatus status) {
    switch (status) {
      case _NetworkStatus.good:
      case _NetworkStatus.unknown:
        return NEMeetingUIKitLocalizations.of(context)!.networkConnectionGood;
      case _NetworkStatus.normal:
        return NEMeetingUIKitLocalizations.of(context)!
            .networkConnectionGeneral;
      default:
        return NEMeetingUIKitLocalizations.of(context)!.networkConnectionPoor;
    }
  }

  @override
  void onFirstFrameRendered(String uid) {
    commonLogger.i('onFirstFrameRendered uid=$uid');
  }

  @override
  void onFrameResolutionChanged(
      String uid, int width, int height, int rotation) {
    commonLogger.i(
      'onFrameResolutionChanged uid=$uid width=$width height=$height rotation=$rotation',
    );
    if (uid == getScreenShareUserId() &&
        _screenShareController != null &&
        (_screenShareWidth != width || _screenShareHeight != height)) {
      _screenShareWidth = width;
      _screenShareHeight = height;
      _screenShareController!.value = Matrix4.identity();
    }
  }

  Future<NEResult<void>> minimizeCurrentMeeting() {
    if (_isMinimized != true) {
      _isMinimized = true;
      void minimizeImpl() {
        EventBus().emit(NEMeetingUIEvents.flutterPageDisposed, 'minimize');
        MeetingCore().notifyStatusChange(
            NEMeetingStatus(NEMeetingEvent.inMeetingMinimized));
      }

      // FIX: http://jira.netease.com/browse/YYTX-15556
      // 临时方案，后续升级 Flutter Engine 即可修复该问题
      if (Platform.isAndroid && isWhiteBoardSharing()) {
        postOnFrame(minimizeImpl);
        setState(() {});
      } else {
        minimizeImpl();
      }
    }
    commonLogger.i('minimized');
    return Future.value(NEResult(code: NEErrorCode.success));
  }

  @override
  Future<NEResult<void>> subscribeAllRemoteAudioStreams(bool subscribe) {
    return Future.value(
        NEResult(code: NEErrorCode.failure, msg: 'NotSupported'));
  }

  @override
  Future<NEResult<void>> startAudioDump() {
    final result = rtcController.startAudioDump(NEAudioDumpType.kPCM);
    commonLogger.i('startAudioDump: $result');
    return result;
  }

  @override
  Future<NEResult<void>> stopAudioDump() {
    final result = rtcController.stopAudioDump();
    commonLogger.i(
      'stopAudioDump: $result',
    );
    return result;
  }

  @override
  Future<NEResult<List<String>>> subscribeRemoteAudioStreams(
      List<String> userList, bool subscribe) {
    return Future.value(
        NEResult(code: NEErrorCode.failure, msg: 'NotSupported'));
  }

  @override
  Future<NEResult<void>> subscribeRemoteAudioStream(
      String userId, bool subscribe) {
    return Future.value(
        NEResult(code: NEErrorCode.failure, msg: 'NotSupported'));
  }

  void changeToolBarStatus() {
    // print("changeToolBarStatus :$_isEditStatus");
    if (appBarAnimController.status == AnimationStatus.completed) {
      appBarAnimController.reverse();
    } else if (appBarAnimController.status == AnimationStatus.dismissed) {
      appBarAnimController.forward();
    }
  }

  bool get isToolbarShowing =>
      appBarAnimController.status == AnimationStatus.dismissed ||
      appBarAnimController.status == AnimationStatus.reverse;

  void createHistoryMeetingItem() {
    if (historyMeetingItem == null) {
      final meetingInfo = arguments.meetingInfo;
      final self = roomContext.localMember;
      historyMeetingItem = NEHistoryMeetingItem(
        meetingId: meetingInfo.meetingId,
        meetingNum: meetingInfo.meetingNum,
        shortMeetingNum: meetingInfo.shortMeetingNum,
        subject: meetingInfo.subject,
        password: roomContext.password,
        nickname: self.name,
        sipId: roomContext.sipCid,
      );
    }
  }

  @override
  NEMeetingInfo? getCurrentMeetingInfo() {
    final meetingInfo = arguments.meetingInfo;
    return NEMeetingInfo(
      meetingId: meetingInfo.meetingId,
      meetingNum: meetingInfo.meetingNum,
      shortMeetingNum: meetingInfo.shortMeetingNum,
      sipCid: roomContext.sipCid,
      type: meetingInfo.type.type,
      subject: meetingInfo.subject,
      password: roomContext.password,
      inviteCode: meetingInfo.inviteCode,
      inviteUrl: meetingInfo.inviteUrl,
      startTime: roomContext.rtcStartTime,
      duration:
          DateTime.now().millisecondsSinceEpoch - roomContext.rtcStartTime,
      scheduleStartTime: meetingInfo.startTime,
      scheduleEndTime: meetingInfo.endTime,
      isHost: isHost(),
      isLocked: roomContext.isRoomLocked,
      hostUserId: roomContext.getHostUuid() ?? '',
      extraData: roomContext.extraData,
      userList: userList
          .map((e) => NEInMeetingUserInfo(
              e.uuid, e.name, e.tag, e.role.name, isSelf(e.uuid)))
          .toList(growable: false),
    );
  }

  void memberJoinRtcChannel(List<NERoomMember> members) {
    for (var user in members) {
      audioVolumeStreams.putIfAbsent(
          user.uuid, () => StreamController<int>.broadcast());
      if (user.uuid == roomContext.localMember.uuid) {
        onConnected();
      } else {
        onMemberInOrOut();
      }
    }
  }

  void onConnected() {
    commonLogger.i(
      'onConnected elapsed=${DateTime.now().millisecondsSinceEpoch - meetingBeginTime}ms, state=$_meetingState',
    );
    if (_meetingState != MeetingState.joining) return;
    _isEverConnected = true;
    _meetingState = MeetingState.joined;
    joinTimeOut?.cancel();
    InMeetingService()
      .._serviceCallback = this
      .._audioDelegate = this
      .._minimizeDelegate = this
      ..rememberRoomContext(roomContext);
    createHistoryMeetingItem();
    MeetingCore().notifyStatusChange(NEMeetingStatus(NEMeetingEvent.inMeeting));
    handleAppLifecycleChangeEvent();
    setupAudioAndVideo();
    _initWithSDKConfig();

    // rtcController.enableAudioVolumeIndication(true, 200);
    rtcController.enableAudioVolumeIndication(true, 500, true);
    audioVolumeStreams[roomContext.localMember.uuid] =
        StreamController<int>.broadcast();

    /// Android 显示前台服务通知
    if (Platform.isAndroid) {
      MeetingCore().getForegroundConfig().then((foregroundConfig) {
        if (foregroundConfig != null) {
          NEMeetingPlugin()
              .getNotificationService()
              .startForegroundService(foregroundConfig);
        }
      });
    }

    setupChatRoom();
    if (arguments.defaultWindowMode == WindowMode.whiteBoard.value &&
        _isMenuItemShowing(NEMenuIDs.whiteBoard) &&
        !whiteboardController.isSharingWhiteboard()) {
      unawaited(_onWhiteBoard());
    }
    whiteBoardEditingState.addListener(() {
      debugPrint('whiteboard editing state=${whiteBoardEditingState.value}');
      if (whiteBoardEditingState.value) {
        appBarAnimController.forward();
      } else {
        appBarAnimController.reverse();
      }
    });
    if (mounted) {
      setState(() {});
    }
    if (roomContext.isMySelfCoHost()) {
      ToastUtils.showToast(
          context, NEMeetingUIKitLocalizations.of(context)!.yourChangeCoHost);
    }
    Timer(muteDetectDelay, () {
      if (muteDetectStarted == null) {
        muteDetectStarted = true;
      }
    });
    scheduleMeetingEndTipTask();
  }

  void memberLeaveRtcChannel(List<NERoomMember> members) {
    onMemberInOrOut();
  }

  void onMemberInOrOut() {
    focusUid = roomContext.getFocusUuid();
    _determineActiveUser(true);
    _onRoomInfoChanged();
  }

  void onRtcChannelError(int code) {
    commonLogger.i('onRtcChannelError: code=$code');
  }

  void onRoomDisconnected(NERoomEndReason reason) {
    if (_meetingState.index >= MeetingState.closing.index) {
      return;
    }
    commonLogger.i('onDisconnect reason=$reason');
    switch (reason) {
      case NERoomEndReason.kCloseByBackend:
        _onCancel(
            exitCode: NEMeetingCode.closeByHost,
            reason: NEMeetingUIKitLocalizations.of(context)!.closeByHost);
        break;
      case NERoomEndReason.kCloseByMember:
        _onCancel(
            exitCode: isSelfHostOrCoHost()
                ? NEMeetingCode.closeBySelfAsHost
                : NEMeetingCode.closeByHost,
            reason: NEMeetingUIKitLocalizations.of(context)!.meetingClosed);
        break;
      case NERoomEndReason.kKickOut:
        onKicked();
        break;
      case NERoomEndReason.kKickBySelf:
        _onCancel(
            exitCode: NEMeetingCode.loginOnOtherDevice,
            reason:
                NEMeetingUIKitLocalizations.of(context)!.loginOnOtherDevice);
        break;
      case NERoomEndReason.kLoginStateError:
        _onCancel(
            exitCode: NEMeetingCode.authInfoExpired,
            reason: NEMeetingUIKitLocalizations.of(context)!.authInfoExpired);
        break;
      case NERoomEndReason.kLeaveBySelf:
        _onCancel(
            exitCode: NEMeetingCode.self,
            reason:
                NEMeetingUIKitLocalizations.of(context)!.leaveMeetingBySelf);
        break;
      case NERoomEndReason.kSyncDataError:
        showToast(NEMeetingUIKitLocalizations.of(context)!.networkNotStable);
        _onCancel(
            exitCode: NEMeetingCode.syncDataError,
            reason: NEMeetingUIKitLocalizations.of(context)!.syncDataError);
        break;
      case NERoomEndReason.kEndOfLife:
        _onCancel(
            exitCode: NEMeetingCode.endOfLife,
            reason: NEMeetingUIKitLocalizations.of(context)!.endOfLife);
        break;
      case NERoomEndReason.kEndOfRtc:
        showToast(NEMeetingUIKitLocalizations.of(context)!.networkNotStable);
        _onCancel(
            exitCode: NEMeetingCode.self,
            reason: NEMeetingUIKitLocalizations.of(context)!.connectFail);
        break;
      default:
        showToast(NEMeetingUIKitLocalizations.of(context)!.networkNotStable);
        _onCancel();
        break;
    }
  }

  /// ****************** InRoomServiceListener ******************

  // status 对应缺少主持人操作相关
  // 此处通过 对比 被操作人member，和操作人operateMember的id，来区分是自己操作，还是管理者操作
  void memberScreenShareStateChanged(
      NERoomMember member, bool isSharing, NERoomMember? operator) {
    trackPeriodicEvent(
        isSharing
            ? TrackEventName.memberScreenShareStart
            : TrackEventName.memberScreenShareStop,
        extra: {
          'member_uid': member.uuid,
          'meeting_num': arguments.meetingNum
        });

    if (isSharing) {
      _isGalleryLayout.value = false;
      _galleryModePageController?.jumpTo(1);
      appBarAnimController.forward();
    }

    if (isSelf(member.uuid)) {
      if (!isSharing &&
          !isSelf(operator?.uuid) &&
          isHostOrCoHost(operator?.uuid)) {
        ToastUtils.showToast(
            context, NEMeetingUIKitLocalizations.of(context)!.hostStopShare);
      }
      // 被停止共享，音频共享也要停止
      if (!isSharing && audioSharingListenable.value) {
        enableAudioShare(false);
      }

      bool isSelfSharing = isSelfScreenSharing();
      screenShareListenable.value = isSelfSharing;
      if (isSelfSharing && member.isRaisingHand) {
        roomContext.lowerMyHand();
      }
    } else {
      if (isSharing) {
        _screenShareController ??= TransformationController();
      } else {
        _screenShareController = null;
      }
    }
    _onRoomInfoChanged();
  }

  // 白板分享状态变更回调
  void memberWhiteboardShareStateChanged(
      NERoomMember member, bool isSharing, NERoomMember? operator) {
    if (isSharing) {
      _isGalleryLayout.value = false;
      _galleryModePageController?.jumpTo(1);
      appBarAnimController.forward();
    }
    if (!isSharing &&
        isSelf(member.uuid) &&
        !isSelf(operator?.uuid) &&
        isHostOrCoHost(operator?.uuid)) {
      // 被操作的是自己，操作人是非自己，isSharing false 时认为是被主持人或者管理者停止了共享
      ToastUtils.showToast(
          context, NEMeetingUIKitLocalizations.of(context)!.hostStopWhiteboard);
    }
    whiteBoardShareListenable.value = isSelfWhiteBoardSharing();
    if (!isSharing) {
      appBarAnimController.reverse();
      if (isSelf(member.uuid)) {
        whiteboardController.deleteWhiteboardConfig();
      }
    }
    _onRoomInfoChanged();
    if (whiteboardController.isDrawWhiteboardEnabled() && !isSharing) {
      whiteboardController.revokePermission(roomContext.myUuid);
    }
  }

  void handleRoomPropertiesEvent(
      Map<String, String> properties, bool isDelete) {
    var updated = updateFocus();
    updated = updateAllMuteState(properties, isDelete) || updated;
    if (updated) {
      _onRoomInfoChanged();
    }
  }

  bool updateFocus() {
    final oldFocus = focusUid;
    final newFocus = roomContext.getFocusUuid();
    if (oldFocus != newFocus) {
      commonLogger.i(
        'focus user changed: old=$oldFocus, new=$newFocus',
      );
      if (isSelf(oldFocus)) {
        showToast(NEMeetingUIKitLocalizations.of(context)!
            .localUserUnAssignedActiveSpeaker);
      }
      if (isSelf(newFocus)) {
        // 联席主持人，主持人都有可被其他人设置为焦点视频，去掉 非主持人才提示的判断
        showToast(NEMeetingUIKitLocalizations.of(context)!
            .localUserAssignedActiveSpeaker);
      }
      focusUid = newFocus;
      return true;
    }
    return false;
  }

  bool updateAllMuteState(Map<String, String> properties, bool isDelete) {
    _invitingToOpenAudio = false;
    _invitingToOpenVideo = false;
    var updated = false;
    if (properties.containsKey(AudioControlProperty.key)) {
      if (!isSelfHostOrCoHost() &&
          roomContext.isAllAudioMuted &&
          roomContext.localMember.isAudioOn) {
        showToast(
            NEMeetingUIKitLocalizations.of(context)!.meetingHostMuteAllAudio);
        rtcController.muteMyAudioAndAdjustVolume();
      }
      if (!isSelfHostOrCoHost() &&
          !roomContext.isAllAudioMuted &&
          !roomContext.localMember.isAudioOn) {
        /// 解除全体静音时，如果当前用户处于举手状态不需要弹出dialog，直接打开音频
        /// 如果没有举手 就弹出dialog
        if (roomContext.localMember.isRaisingHand) {
          _muteMyAudio(false);
        } else {
          showOpenMicDialog();
        }
      }
      updated = true;
      if (roomContext.localMember.isRaisingHand &&
          roomContext.canUnmuteMyAudio()) {
        roomContext.lowerMyHand();
      }
    }
    if (properties.containsKey(VideoControlProperty.key)) {
      if (!isSelfHostOrCoHost() &&
          roomContext.isAllVideoMuted &&
          roomContext.localMember.isVideoOn) {
        showToast(
            NEMeetingUIKitLocalizations.of(context)!.meetingHostMuteAllVideo);
        rtcController.muteMyVideo();
      }
      if (!isSelfHostOrCoHost() &&
          !roomContext.isAllVideoMuted &&
          !roomContext.localMember.isVideoOn) {
        showOpenVideoDialog();
      }
      updated = true;
      if (roomContext.localMember.isRaisingHand &&
          roomContext.canUnmuteMyVideo()) {
        roomContext.lowerMyHand();
      }
    }
    return updated;
  }

  void handleMemberPropertiesEvent(
      NERoomMember member, Map<String, String> properties) {
    var updated = updateSelfWhiteboardDrawableState(member.uuid, properties);
    updated = updateSelfHandsUpState(member.uuid, properties) || updated;
    if (updated) {
      _onRoomInfoChanged();
    }
  }

  // 白板权限变更回调 与onRoomUserWhiteBoardInteractionStatusChanged 逻辑一致
  bool updateSelfWhiteboardDrawableState(
      String userId, Map<String, String> properties) {
    if (!isSelf(userId) ||
        !properties.containsKey(WhiteboardDrawableProperty.key)) return false;
    final isDrawEnabled = whiteboardController.isDrawWhiteboardEnabled();
    whiteBoardInteractionStatusNotifier.value = isDrawEnabled;
    whiteBoardEditingState.value = isDrawEnabled;
    whiteboardController.showWhiteboardTools(isDrawEnabled);
    if (isWhiteBoardSharing() && !isSelfWhiteBoardSharing()) {
      showToast(isDrawEnabled
          ? NEMeetingUIKitLocalizations.of(context)!.whiteBoardInteractionTip
          : NEMeetingUIKitLocalizations.of(context)!
              .undoWhiteBoardInteractionTip);
    }
    return true;
  }

  bool updateSelfHandsUpState(String userId, Map<String, String> properties) {
    if (!properties.containsKey(HandsUpProperty.key)) return false;
    if (isSelf(userId) && roomContext.localMember.isHandDownByHost) {
      showToast(NEMeetingUIKitLocalizations.of(context)!
          .hostRejectAudioHandsUp); // Strings.hostAgreeAudioHandsUp
    }
    return isSelfHostOrCoHost() || isSelf(userId);
  }

  void liveStateChanged(NERoomLiveState state) {
    commonLogger.i(
      'liveStateChanged:state ${state.name}',
    );
  }

  void handlePassThroughMessage(NECustomMessage message) {
    if (message.roomUuid != roomContext.roomUuid) {
      return;
    }
    commonLogger.i(
      'handlePassThroughMessage: ${message.data}',
    );
    final controlAction = MeetingControlMessenger.parseMessage(message.data);
    if (controlAction == MeetingControlMessenger.inviteToOpenAudio ||
        controlAction == MeetingControlMessenger.inviteToOpenAudioVideo) {
      if (roomContext.localMember.isRaisingHand) {
        if (!roomContext.localMember.isAudioOn) {
          rtcController.unmuteMyAudioWithCheckPermission(
              context, arguments.meetingTitle);
        }
      } else if (!roomContext.localMember.isAudioOn) {
        _invitingToOpenAudio = true;
        showOpenMicDialog();
      }
    }
    if (controlAction == MeetingControlMessenger.inviteToOpenVideo ||
        controlAction == MeetingControlMessenger.inviteToOpenAudioVideo) {
      // 邀请打开视频，总是需要弹窗确认
      if (!roomContext.localMember.isVideoOn) {
        _invitingToOpenVideo = true;
        if (roomContext.localMember.isRaisingHand) {
          roomContext.lowerMyHand();
        }
        showOpenVideoDialog();
      }
    }
  }

  List<NEMemberVolumeInfo>? volumeList;

  void onRtcAudioVolumeIndication(
      List<NEMemberVolumeInfo> volumeList, int totalVolume) {
    if (_isAlreadyCancel) return;
    // final isLocalVolumeChanged = volumeList.length == 1 &&
    //     volumeList.single.userUuid == roomContext.myUuid;
    // if (isLocalVolumeChanged) {
    //   onLocalAudioVolumeIndication(totalVolume, false);
    // } else {
    this.volumeList = volumeList;
    volumeList.forEach((item) {
      audioVolumeStreams[item.userUuid]?.add(item.volume);
    });
    _determineActiveUser();
    // }
  }

  void onLocalAudioVolumeIndicationWithVad(int volume, bool enableVad) {
    // assert((){
    //   debugPrint('onLocalAudioVolumeIndicationWithVad: volume=$volume, enableVad=$enableVad');
    //   return true;
    // }());
    audioVolumeStreams[roomContext.localMember.uuid]?.add(volume);
    if (!arguments.options.detectMutedMic) {
      return;
    }
    if (!arguments.audioMute) {
      muteDetectStarted = false;
      resetMuteDetectInfo();
      return;
    }
    var res = false;
    if (muteDetectStarted == true) {
      res = detectContinueSpeak(volume, enableVad);
      if (res) {
        showTurnOnMicphoneTipDialog();
        muteDetectStarted = false;
        return;
      }
    }
  }

  void resetMuteDetectInfo() {
    volumeInfo.clear();
    vadInfo.clear();
  }

  bool detectContinueSpeak(int volume, bool enableVad) {
    int count = 0;
    bool res = false;
    volumeInfo.add(volume);
    vadInfo.add(enableVad);
    if (volumeInfo.length == 7) {
      for (int i = 0; i < 7; i++) {
        if ((volumeInfo[i] > 40) && vadInfo[i]) {
          count++;
        }
      }
      if (count >= 4) {
        res = true;
      }
      resetMuteDetectInfo();
    }
    return res;
  }

  /// “打开扬声器”提醒弹窗
  void showTurnOnMicphoneTipDialog() {
    lastRemindTimestamp = DateTime.now();
    commonLogger.i(
      'showTurnOnMicphoneTipDialog',
    );
    DialogUtils.showOneButtonCommonDialog(
      context,
      NEMeetingUIKitLocalizations.of(context)!.micphoneNotWorksDialogTitle,
      NEMeetingUIKitLocalizations.of(context)!.micphoneNotWorksDialogMessage,
      () {
        openMicphoneTipDialogShowing = false;
        commonLogger.i(
          'dismissTurnOnMicphoneTipDialog',
        );
        Navigator.of(context).pop();
      },
      canBack: false,
    );
    openMicphoneTipDialogShowing = true;
    Timer(Duration(seconds: 3), () {
      if (openMicphoneTipDialogShowing && mounted) {
        commonLogger.i(
          'dismissTurnOnMicphoneTipDialog',
        );
        Navigator.of(context).pop();
      }
    });
  }

  void setupAudioProfile() async {
    var userSetAudioProfile = arguments.options.audioProfile;
    final settingsAudioAINs =
        await NEMeetingKit.instance.getSettingsService().isAudioAINSEnabled();
    if (userSetAudioProfile != null) {
      if (userSetAudioProfile.profile >= 0 &&
          userSetAudioProfile.scenario >= 0) {
        roomContext.rtcController.setAudioProfile(
            userSetAudioProfile.profile, userSetAudioProfile.scenario);
      }
    }
    final enableAudioAINs =
        userSetAudioProfile?.enableAINS ?? settingsAudioAINs;
    roomContext.rtcController.enableAudioAINS(enableAudioAINs);
  }

  Future<void> setupAudioAndVideo() async {
    final bool isInCall = await NEMeetingPlugin().phoneStateService.isInCall;

    var willOpenAudio = false, willOpenVideo = false;
    if (!arguments.initialAudioMute) {
      if (roomContext.isAllAudioMuted && !isSelfHostOrCoHost()) {
        /// 设置了全体静音，并且自己不是主持人时 提示主持人设置全体静音
        showToast(
            NEMeetingUIKitLocalizations.of(context)!.meetingHostMuteAllAudio);
      } else if (!isInCall) {
        willOpenAudio = true;
      }
    }

    if (!arguments.initialVideoMute) {
      if (roomContext.isAllVideoMuted && !isSelfHostOrCoHost()) {
        /// 设置了全体关闭视频，并且自己不是主持人时 提示主持人设置全体关闭视频
        showToast(
            NEMeetingUIKitLocalizations.of(context)!.meetingHostMuteAllVideo);
      } else if (!isInCall) {
        willOpenVideo = true;
      }
    }

    commonLogger.i(
      'setup audio and video: $willOpenAudio $willOpenVideo',
    );

    if (willOpenAudio) {
      await rtcController.unmuteMyAudioWithCheckPermission(
          context, arguments.meetingTitle,
          needAwaitResult: false);
    }

    if (willOpenVideo) {
      await rtcController.unmuteMyVideoWithCheckPermission(
          context, arguments.meetingTitle,
          needAwaitResult: false);
    }
  }

  Widget buildSelfVolumeIndicator() {
    return AnimatedBuilder(
      animation: localAudioVolumeIndicatorAnim,
      builder: (context, child) => Positioned(
          bottom: localAudioVolumeIndicatorAnim.value,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: Colors.black.withAlpha(77),
                shape: CircleBorder(),
              ),
              child: GestureDetector(
                onTap: () => _muteMyAudio(!arguments.audioMute),
                child: buildRoomUserVolumeIndicator(
                  roomContext.localMember.uuid,
                  opacity: 0.8,
                  size: 30,
                ),
              ),
            ),
          )),
    );
  }

  Widget buildRoomUserVolumeIndicator(String userId,
      {double? size, double? opacity}) {
    final user = roomContext.getMember(userId);
    if (user == null) {
      return Container();
    }
    if (!user.isAudioOn) {
      return Icon(
        NEMeetingIconFont.icon_yx_tv_voice_offx,
        color: _UIColors.colorFE3B30,
        size: size,
      );
    } else {
      audioVolumeStreams.putIfAbsent(
          userId, () => StreamController<int>.broadcast());
      Widget child = AnimatedMicphoneVolume.light(
          opacity: opacity, volume: audioVolumeStreams[userId]!.stream);
      if (size != null) {
        child = SizedBox(
          width: size,
          height: size,
          child: child,
        );
      }
      return child;
    }
  }

//线性参数
  Future<void> setBeautyEffect(int beautyLevel) async {
    if (!isBeautyEnabled) {
      return;
    }
    final shouldEnable = beautyLevel > 0;
    rtcController.enableBeauty(shouldEnable);
    if (!shouldEnable) {
      return;
    }
    final level = beautyLevel.toDouble() / 10;
    rtcController
      ..setBeautyEffect(NERoomBeautyEffectType.kWhiten, level)
      ..setBeautyEffect(NERoomBeautyEffectType.kSmooth, level)
      ..setBeautyEffect(NERoomBeautyEffectType.kFaceRuddy, level)
      ..setBeautyEffect(NERoomBeautyEffectType.kFaceSharpen, level);
  }

  void _onVirtualBackground() {
    isPreviewVirtualBackground = true;
    Navigator.of(context)
        .push(
      MaterialMeetingPageRoute(
        builder: (context) => VirtualBackgroundPage(
          roomContext: roomContext,
          mirrorListenable: localMirrorState,
          videoStreamSubscriber: userVideoStreamSubscriber,
        ),
      ),
    )
        .whenComplete(() {
      isPreviewVirtualBackground = false;
    });
  }

  Widget buildMeetingEndTip(height) {
    return Row(
      // mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: height + 10),
          padding: EdgeInsets.only(left: 13),
          height: 45,
          decoration: BoxDecoration(
            color: _UIColors.tipStartBg,
            border: Border.fromBorderSide(BorderSide(
              color: _UIColors.tipEndBg,
              width: 1,
              style: BorderStyle.solid,
            )),
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          child: Row(
            children: [
              Container(
                  alignment: Alignment.center,
                  child: Text(
                      '${NEMeetingUIKitLocalizations.of(context)!.endMeetingTip}$meetingEndTipMin${NEMeetingUIKitLocalizations.of(context)!.min}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _UIColors.black,
                          fontSize: 15,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w400))),
              Container(
                padding: EdgeInsets.only(top: 2),
                child: RawMaterialButton(
                  constraints:
                      const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
                  child: Icon(
                    NEMeetingIconFont.icon_yx_tv_duankaix,
                    color: _UIColors.color_666666,
                    size: 15,
                    key: MeetingUIValueKeys.close,
                  ),
                  onPressed: () {
                    setState(() {
                      showMeetingEndTip = false;
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  bool isMeetingEndTimeTiSupported() =>
      sdkConfig.isMeetingEndTimeTipSupported &&
      arguments.showMeetingRemainingTip;

  void setupMeetingEndTip() {
    if (!isMeetingEndTimeTiSupported()) {
      return;
    }
    _remainingSeconds = (roomContext.remainingSeconds ?? 0).toInt();
    if (_remainingSeconds > 0) {
      _remainingSecondsAdjustment.start();
    }
  }

  void debugPrintAlog(String message) {
    assert(() {
      commonLogger.i(message);
      return true;
    }());
  }

  Stream<int> meetingEndTipEventStream() async* {
    assert(() {
      debugPrintAlog('meeting end tip stream started');
      return true;
    }());
    _remainingSecondsAdjustment.stop();
    var remain = Duration(seconds: _remainingSeconds) -
        _remainingSecondsAdjustment.elapsed;
    if (!remain.isNegative) {
      // 10分钟、5分钟、1分钟各提醒一次；提醒时间为 1 分钟
      final checkPoints = const [10, 5, 1];
      for (var index = 0; index < checkPoints.length; ++index) {
        final value = checkPoints[index];
        final next = Duration(minutes: value);
        var durationToRemind = remain - next;
        if (!durationToRemind.isNegative || index == checkPoints.length - 1) {
          if (!durationToRemind.isNegative) {
            await Future.delayed(durationToRemind);
          }
          assert(() {
            debugPrintAlog('meeting end tip $value minutes remain');
            return true;
          }());
          yield value;
          remain = next;
        }
      }
    }
  }

  void scheduleMeetingEndTipTask() {
    final meetingEndTipEventSubscription =
        meetingEndTipEventStream().listen((minutes) async {
      if (mounted) {
        setState(() {
          meetingEndTipMin = minutes;
          showMeetingEndTip = true;
        });
        if (minutes > 1) {
          await Future.delayed(const Duration(minutes: 1));
          if (mounted) {
            setState(() {
              showMeetingEndTip = false;
            });
          }
        }
      }
    });
    streamSubscriptions.add(meetingEndTipEventSubscription);
  }
}

extension ToastExtension on State {
  void showToast(String message) {
    if (mounted) {
      ToastUtils.showToast(context, message);
    }
  }
}

class NERoomUserAudioVolumeInfo {
  /// 用户 ID
  final String userId;

  /// 音量[0-100]
  final int volume;

  NERoomUserAudioVolumeInfo(this.userId, this.volume);
}

class NetWorkRttInfo {
  int networkDownRtt;
  int upLossRate;
  int downLossRate;

  NetWorkRttInfo(this.networkDownRtt, this.upLossRate, this.downLossRate);
}

enum _NetworkStatus {
  good,
  normal,
  poor,
  unknown,
}

bool _isScreenShareSupported() {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final osVer = '${DeviceInfo.osVer}.0';
    return (double.tryParse(osVer.substring(0, osVer.indexOf(r'.'))) ?? 0) >=
        12;
  }
  return defaultTargetPlatform == TargetPlatform.android;
}

bool _isAudioShareSupported() {
  if (Platform.isAndroid) {
    return DeviceInfo.sdkInt >= 29;
  }
  return _isScreenShareSupported();
}

class _LockCameraVideoViewListener extends NERoomUserVideoViewListener {
  final void Function(String uid, int width, int height) action;

  _LockCameraVideoViewListener(this.action);

  void onFrameResolutionChanged(
      String userId, int width, int height, int rotation) {
    action(userId, width, height);
  }
}
