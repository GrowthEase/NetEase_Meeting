// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

const _tag = 'MeetingPage';

class MeetingPage extends StatefulWidget {
  final MeetingArguments arguments;

  MeetingPage(this.arguments);

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
        InMeetingDataServiceCallback {
  MeetingBusinessUiState(this.arguments);

  final galleryItemSize = MeetingConfig().pageSize;

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

  static const double appBarHeight = 64, bottomBarHeight = 54, space = 1;

  late AnimationController appBarAnimController;

  late Animation<Offset> bottomAnim, topBarAnim, meetingEndTipAnim;

  late Animation<double> localAudioVolumeIndicatorAnim;

  late int meetingBeginTime;

  bool _isAlreadyCancel = false,
      _isMinimized = false,
      _hasRequestEngineToDetach = false,
      _isPortrait = true,
      _frontCamera = true;

  double? _restoreToPageIndex;

  OverlayEntry? _overlayEntry;

  NEAudioOutputDevice _audioDeviceSelected = NEAudioOutputDevice.kSpeakerPhone;

  int beautyLevel = 0;

  int meetingEndTipMin = 0;
  bool showMeetingEndTip = false;
  int _remainingSeconds = 0;
  Stopwatch _remainingSecondsAdjustment = Stopwatch();
  StreamSubscription? meetingEndTipEventSubscription;

  final StreamController<Object> roomInfoUpdatedEventStream =
      StreamController.broadcast();
  late final NERoomWhiteboardController whiteboardController;
  late final NERoomChatController chatController;
  late final NERoomRtcController rtcController;
  late final NEMessageChannelCallback messageCallback;
  late final NERoomEventCallback roomEventCallback;

  ValueNotifier<bool> whiteBoardInteractionStatusNotifier =
      ValueNotifier<bool>(false);
  ValueNotifier<bool> whiteBoardEditingState = ValueNotifier<bool>(false);

  NEHistoryMeetingItem? historyMeetingItem;

  static const kSmallVideoViewSize = const Size(72.0, 128.0);
  final smallVideoViewPaddings = ValueNotifier(EdgeInsets.zero);
  var smallVideoViewAlignment = Alignment.topRight;

  static const int minSpeakingVolume = 20;
  static const int minMinutesToRemind = 5;
  static const int minSpeakingTimesToRemind = 10;
  // 本地用户是否正在讲话
  var localUserSpeakingContinuousTimes = -1;

  // 入会后delay一段时间后才开始静音检测，防止误报
  static const muteDetectDelay = Duration(seconds: 8);
  var muteDetectStarted = false;

  /// 上次提醒时间
  var lastRemindTimestamp = DateTime.utc(2020);

  /// 上次焦点视频切换时间
  var lastFocusSwitchTimestamp = DateTime.utc(2020);
  var openMicphoneTipDialogShowing = false;
  final audioVolumeStreams = <String, StreamController<int>>{};
  late NERoomContext roomContext;
  bool isFrontCamera = true;
  NERtcVideoRenderer? localRenderer;
  bool isVirtualBackgroundEnabled = false;
  bool isPreviewVirtualBackground = false;
  bool isAnonymous = false;

  final pageViewCurrentIndex = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    assert(() {
      // debugPrintScheduleBuildForStacks = true;
      debugPrintRebuildDirtyWidgets = false;
      return true;
    }());
    roomContext = arguments.roomContext;
    whiteboardController = roomContext.whiteboardController;
    chatController = roomContext.chatController;
    rtcController = roomContext.rtcController;
    _meetingMemberCount = ValueNotifier(userCount);
    _messageSource = ChatRoomMessageSource(
        arguments.options.chatroomConfig ?? NEMeetingChatroomConfig());
    SystemChrome.setPreferredOrientations([]);
    meetingBeginTime = DateTime.now().millisecondsSinceEpoch;
    Wakelock.enable();
    _galleryModePageController = PageController(initialPage: 0);
    _initAnimationController();
    trackPeriodicEvent(TrackEventName.pageMeeting);
    isAnonymous = NEMeetingKit.instance.getAccountService().isAnonymous;
    _initBeauty();
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
      rtcAudioVolumeIndication: onRtcAudioVolumeIndication,
      rtcAudioOutputDeviceChanged: onRtcAudioOutputDeviceChanged,
      rtcVirtualBackgroundSourceEnabled: onRtcVirtualBackgroundSourceEnabled,
    );
    roomContext.addEventCallback(roomEventCallback);

    messageCallback = NEMessageChannelCallback(
      onReceiveCustomMessage: handlePassThroughMessage,
    );
    NERoomKit.instance.messageChannelService
        .addMessageChannelCallback(messageCallback);

    MeetingCore()
        .notifyStatusChange(NEMeetingStatus(NEMeetingEvent.connecting));
    var userSetAudioProfile = arguments.options.audioProfile;
    if (userSetAudioProfile == null && Platform.isIOS) {
      userSetAudioProfile = NERoomAudioProfile(
        profile: NERtcAudioProfile.profileMiddleQuality.index,
        scenario: NERtcAudioScenario.scenarioSpeech.index,
        enableAINS: false,
      );
    }
    if (userSetAudioProfile != null) {
      roomContext.rtcController.setAudioProfile(
          userSetAudioProfile.profile, userSetAudioProfile.scenario);
    }
    roomContext.rtcController.joinRtcChannel();
    setupMeetingEndTip();
    _joining();
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

  @override
  void didChangeMetrics() {
    assert(() {
      print(
          '$tag didChangeMetrics: ${WidgetsBinding.instance.window.physicalSize}');
      return true;
    }());
    if (!_isMinimized &&
        _restoreToPageIndex != null &&
        !WidgetsBinding.instance.window.physicalSize.isEmpty) {
      assert(() {
        print('$tag time to restore pageView index');
        return true;
      }());
      setState(() {
        context.findRenderObject()?.markNeedsLayout();
      });
    }
  }

  void _checkResumeFromMinimized(AppLifecycleState state) {
    if (!_isAlreadyCancel &&
        state == AppLifecycleState.resumed &&
        _isMinimized == true) {
      _isMinimized = false;
      MeetingCore()
          .notifyStatusChange(NEMeetingStatus(NEMeetingEvent.inMeeting));
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content: '$tag, resume from minimized');
    }
  }

  void _minimizeMeeting() {
    if (!arguments.noMinimize && _isMinimized != true) {
      //save current pageview index
      if (_galleryModePageController != null &&
          _galleryModePageController!.hasClients &&
          _galleryModePageController!.position.viewportDimension > 0) {
        _restoreToPageIndex = _galleryModePageController!.page;
        Alog.i(
            tag: _tag,
            moduleName: _moduleName,
            content: '$tag, save pageview index: $_restoreToPageIndex');
      }

      _isMinimized = true;
      EventBus().emit(NEMeetingUIEvents.flutterPageDisposed, 'minimize');
      MeetingCore().notifyStatusChange(
          NEMeetingStatus(NEMeetingEvent.inMeetingMinimized));
      Alog.i(tag: _tag, moduleName: _moduleName, content: '$tag, minimized');
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
          Alog.i(
            tag: _tag,
            moduleName: _moduleName,
            content: 'join meeting timeout',
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
            // Listener(
            //   key: MeetingUIValueKeys.meetingFullScreen,
            //   behavior: HitTestBehavior.deferToChild,
            //   onPointerDown: (event) {
            //     assert(() {
            //       print(
            //           'Listener onPointerDown: ${event.device} @ ${event.position} ${event.timeStamp}');
            //       return true;
            //     }());
            //     downPointEvent = event;
            //     interceptEvent = false;
            //   },
            //   onPointerUp: (event) {
            //     assert(() {
            //       print(
            //           'Listener onPointerUp: ${event.device}, trackingId=${event.device} ${event.timeStamp}');
            //       return true;
            //     }());
            //
            //     /// 适配当白板模式在非编辑状态下，进行缩放，点击区域(∞，100)区域不消费事件。
            //     if (_windowMode == WindowMode.whiteBoard &&
            //         !_isEditStatus &&
            //         event.position.dy <= 100) {
            //       return;
            //     }
            //     //we only respond to the tracking pointer id
            //     if (downPointEvent?.device != event.device) {
            //       return;
            //     }
            //     //this is a move or long press, ignore
            //     if ((event.position - downPointEvent!.position).distance >=
            //             kTouchSlop ||
            //         event.timeStamp - downPointEvent!.timeStamp >=
            //             kLongPressTimeout) {
            //       return;
            //     }
            //     if (interceptEvent) {
            //       interceptEvent = false;
            //       return;
            //     }
            //
            //     if (!_isEditStatus) {
            //       changeToolBarStatus();
            //     }
            //   },
            //   child: buildCenter(),
            // ),
            GestureDetector(
              key: MeetingUIValueKeys.meetingFullScreen,
              onTap: changeToolBarStatus,
              child: buildCenter(),
            ),
            // MeetingCoreValueKey.addTextWidgetTest(valueKey:MeetingCoreValueKey.meetingFullScreen,value: handlMeetingFullScreen),
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                  child: buildBottomAppBar(), position: bottomAnim),
            ),
            if (isMeetingEndTimeTiSupported() &&
                showMeetingEndTip &&
                meetingEndTipMin != 0)
              buildMeetingEndTip(height),
            SlideTransition(
                position: topBarAnim, child: buildAppBar(data, height)),
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
        NERoomContextProvider(
          roomContext: roomContext,
          child: buildModeUI(),
        ),
        // if(arguments.joinmeetingInfo.attendeeRecordOn && SettingsRepository.isMeetingCloudRecordEnabled())
        // _buildRecord(),
      ],
    );
  }

  Widget buildModeUI() {
    Widget modeUI;
    var mode = gallery;
    if (isSelfScreenSharing()) {
      mode = screenShare;
    } else if (isWhiteBoardSharing()) {
      mode = whiteBoard;
    }
    _windowMode = WindowModeExtension.get(mode);
    switch (_windowMode) {
      case WindowMode.screenShare:
        modeUI = buildScreenShareUI();
        break;
      case WindowMode.whiteBoard:
        modeUI = buildWhiteBoardShareUI();
        break;
      default:
        modeUI = buildGalleyUI();
    }
    return modeUI;
  }

  bool isHeadset() {
    return _audioDeviceSelected == NEAudioOutputDevice.kBluetoothHeadset ||
        _audioDeviceSelected == NEAudioOutputDevice.kWiredHeadset;
  }

  bool isEarpiece() {
    return _audioDeviceSelected == NEAudioOutputDevice.kEarpiece;
  }

  Widget buildAppBar(data, height) {
    return Container(
      height: height,
      child: Row(
        children: <Widget>[
          buildAudioMode(data),
          buildCameraMode(data, height),
          buildMeetingInfo(data),
          buildMinimize(data),
          buildLeave(data),
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

  Widget buildLeave(MediaQueryData data) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
          margin:
              EdgeInsets.only(top: data.viewPadding.top, right: 16, left: 8),
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

  Widget buildMeetingInfo(MediaQueryData data) {
    return Expanded(
      child: Container(
          padding: EdgeInsets.only(top: 22 + data.viewPadding.top),
          margin: EdgeInsets.only(left: 29),
          child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _onMeetingInfo();
              },
              child: Column(
                children: <Widget>[
                  Text.rich(TextSpan(
                    children: [
                      TextSpan(
                          text: ' ${arguments.meetingTitle} ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w400)),
                      WidgetSpan(
                          child: Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 15),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w400),
                          alignment: PlaceholderAlignment.middle),
                    ],
                  )),
                  if (arguments.showMeetingTime)
                    MeetingDuration(DateTime.now().millisecondsSinceEpoch -
                        roomContext.rtcStartTime),
                  if (!arguments.showMeetingTime)
                    Text('',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w400)),
                ],
              ))),
    );
  }

  void _onMeetingInfo() {
    trackPeriodicEvent(TrackEventName.meetingInfoClick,
        extra: {'meeting_id': arguments.meetingId});
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

  Widget buildMinimize(MediaQueryData data) {
    if (!arguments.noMinimize) {
      return Container(
          padding:
              EdgeInsets.only(left: 10, top: data.viewPadding.top, right: 8),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: const Icon(NEMeetingIconFont.icon_narrow_line,
                key: MeetingUIValueKeys.minimize,
                size: 21,
                color: _UIColors.white),
            onTap: _minimizeMeeting,
          ));
    } else {
      return Container(width: 39);
    }
  }

  Widget buildCameraMode(MediaQueryData data, double height) {
    if (arguments.videoMute == true || arguments.noSwitchCamera) {
      return Container(width: 39);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        padding: EdgeInsets.only(left: 8, top: data.viewPadding.top, right: 10),
        child: const Icon(NEMeetingIconFont.icon_yx_tv_filpx,
            key: MeetingUIValueKeys.switchCamera,
            size: 21,
            color: _UIColors.white),
      ),
      onTap: _onSwitchCamera,
    );
  }

  Widget buildAudioMode(MediaQueryData data) {
    if (arguments.noSwitchAudioMode) {
      return Container(width: 45);
    }
    return Container(
        padding: EdgeInsets.only(left: 16, top: data.viewPadding.top, right: 8),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Icon(
              isHeadset()
                  ? NEMeetingIconFont.icon_headset1x
                  : (isEarpiece()
                      ? NEMeetingIconFont.icon_earpiece1x
                      : NEMeetingIconFont.icon_amplify),
              key: MeetingUIValueKeys.switchLoudspeaker,
              size: 21,
              color: _UIColors.white),
          onTap: _audioModeSwitch,
        ));
  }

  void _audioModeSwitch() {
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
    final id = item.itemId;
    if (!item.isValid) return false;
    if (id == NEMenuIDs.screenShare && !_isScreenShareSupported()) return false;
    if (id == NEMenuIDs.chatroom && (arguments.noChat || !isChatroomEnabled()))
      return false;
    if (id == NEMenuIDs.invitation && arguments.noInvite) return false;
    if (id == InternalMenuIDs.beauty &&
        !SettingsRepository.isBeautyFaceSupported()) {
      return false;
    }
    if (id == InternalMenuIDs.virtualBackground &&
        !isVirtualBackgroundEnabled) {
      return false;
    }
    if (id == InternalMenuIDs.live && !roomContext.liveController.isSupported) {
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
      SettingsRepository.isSipSupported() &&
      !TextUtils.isEmpty(roomContext.sipCid);

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
    Alog.i(tag: _tag, content: 'handleMenuItemClick $itemId');
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
        Alog.i(
            tag: _tag,
            content: 'handleMenuItemClick InternalMenuIDs.more before');
        if (arguments.options.extras['useCompatibleMoreMenuStyle'] == true) {
          _showCompatibleMoreMenu();
          Alog.i(
              tag: _tag,
              content:
                  'handleMenuItemClick InternalMenuIDs.more  _showCompatibleMoreMenu');
        } else {
          _showMorePopupMenu();
          Alog.i(
              tag: _tag,
              content:
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
      Alog.i(
          tag: _tag, content: '_morePopupMenuAnimationListener status:$status');
      if (status == AnimationStatus.dismissed) {
        _morePopupMenuEntry?.remove();
        _morePopupMenuEntry = null;
        Alog.i(tag: _tag, content: '_morePopupMenuEntry remove');
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
    Alog.i(
        tag: _tag,
        content: '_showMorePopupMenu ${_morePopupMenuEntry != null}');
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
                Alog.i(
                    tag: _tag,
                    content:
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
                      stream: SDKConfig.initNotifyStream,
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
    Alog.i(tag: _tag, content: '_hideMorePopupMenu before');
    if (_morePopupMenuEntry != null) {
      _morePopupMenuAnimation!.reverse();
      Alog.i(tag: _tag, content: '_hideMorePopupMenu in if');
      return true;
    }
    Alog.i(tag: _tag, content: '_hideMorePopupMenu after');
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
    Alog.i(
      tag: _tag,
      moduleName: _moduleName,
      content:
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
        } else {
          roomContext.leaveRoom();
          result = VoidResult.success();
        }
        if (mounted && requestClose && !result.isSuccess()) {
          ToastUtils.showToast(
              context,
              result.msg ??
                  NEMeetingUIKitLocalizations.of(context)!
                      .networkUnavailableCloseFail);
        }
        switch (itemId) {
          case InternalMenuIDs.leaveMeeting:
            trackPeriodicEvent(TrackEventName.selfLeaveMeeting,
                extra: {'meeting_id': arguments.meetingId});
            _onCancel(
                reason:
                    NEMeetingUIKitLocalizations.of(context)!.leaveMeetingBySelf,
                exitCode: NEMeetingCode.self);
            break;
          case InternalMenuIDs.closeMeeting:
            trackPeriodicEvent(TrackEventName.selfFinishMeeting,
                extra: {'meeting_id': arguments.meetingId});
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
    return DraggablePositioned(
      size: kSmallVideoViewSize,
      initialAlignment: smallVideoViewAlignment,
      paddings: smallVideoViewPaddings,
      pinAnimationDuration: const Duration(milliseconds: 500),
      pinAnimationCurve: Curves.easeOut,
      builder: (context) => child,
      onPinStart: (alignment) {
        smallVideoViewAlignment = alignment;
      },
    );
  }

  bool get shouldShowWhiteboardShareUserVideo {
    if (!arguments.options.showWhiteboardShareUserVideo) {
      return false;
    }
    final member = roomContext
        .getMember(whiteboardController.getWhiteboardSharingUserUuid());
    if (member != null && member.isVideoOn) {
      return true;
    }
    return false;
  }

  ///白板共享
  Widget buildWhiteBoardShareUI() {
    // _isEditStatus = whiteboardController.isDrawWhiteboardEnabled();
    final whiteboardPage = WhiteBoardWebPage(
      key: ValueKey(whiteboardController.getWhiteboardSharingUserUuid()),
      roomContext: arguments.roomContext,
      whiteBoardPageStatusCallback: (isEditStatus) {
        whiteBoardEditingState.value = isEditStatus;
      },
      valueNotifier: whiteBoardInteractionStatusNotifier,
    );
    return Stack(
      children: <Widget>[
        whiteboardPage,
        if (shouldShowWhiteboardShareUserVideo && isOtherWhiteBoardSharing())
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
    return Stack(
      children: [
        Container(
          color: _UIColors.color_181820,
          alignment: Alignment.center,
          child: Text(
            '${roomContext.localMember.name}${NEMeetingUIKitLocalizations.of(context)!.screenShareLocalTips}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (arguments.options.showFloatingMicrophone)
          buildSelfVolumeIndicator(),
      ],
    );
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
                debugName: roomContext.getMember(roomUid)?.name,
                listener: this,
              ),
            ),
            alignment: Alignment.center,
          ),
          if (shouldShowScreenShareUserVideo(roomUid))
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
    determineBigSmallUser();
    var pageSize = calculatePageSize();
    var curPage = _galleryModePageController!.hasClients
        ? _galleryModePageController!.page!.round()
        : 0;
    if (!_isMinimized &&
        _restoreToPageIndex != null &&
        _galleryModePageController!.hasClients &&
        curPage != _restoreToPageIndex &&
        !WidgetsBinding.instance.window.physicalSize.isEmpty) {
      assert(() {
        print(
            '$tag, schedule restore pageview index: $_restoreToPageIndex ${_galleryModePageController!.position.viewportDimension}');
        return true;
      }());
      final toPage = _restoreToPageIndex;
      _restoreToPageIndex = null;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Timer.run(() {
          setState(() => _galleryModePageController!
              .jumpToPage(min(toPage!.toInt(), pageSize - 1)));
        });
      });
    }
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
            if (isOtherScreenSharing()) {
              return buildRemoteScreenShare();
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
          Positioned(
            bottom: bottomBarHeight + 8,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: DotsIndicator(
                  itemCount: pageSize,
                  selectedIndex: pageViewCurrentIndex,
                ),
              ),
            ),
          ),
        if (arguments.options.showFloatingMicrophone)
          buildSelfVolumeIndicator(),
      ],
    );
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
    Widget innerView;
    getUidListByPage(page).forEach((roomUid) {
      final user = roomContext.getMember(roomUid);
      if (user?.canRenderVideo ?? false) {
        innerView = NERoomUserVideoView(
          roomUid,
          builder: (ctx) => buildSmallNameView(user?.name),
          debugName: user?.name,
          listener: this,
          mirror: isSelf(roomUid) ? _frontCamera : false,
        );
      } else {
        innerView = buildSmallNameView(user?.name);
      }
      list.add(buildGridItem(
          innerView, roomUid, user?.name, user?.isAudioOn ?? false));
    });
    return list;
  }

  Widget buildGridItem(
      Widget view, String roomUid, String? name, bool muteAudio) {
    return Stack(
      children: <Widget>[
        view,
        buildGalleyNameView(roomUid, name, muteAudio),
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: isHighLight(roomUid)
                      ? _UIColors.color_59F20C
                      : _UIColors.black,
                  width: 2)),
        )
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
          children: [
            buildRoomUserVolumeIndicator(
              user.uuid,
              size: 12,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  truncate(user.name),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w400),
                ),
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
    if (arguments.noGallery) {
      return 1;
    }
    var memberSize = userCount;
    final otherMemberScreenSharing = isOtherScreenSharing();
    // 虽然只有两个人，但小画面是被共享者占用了，所以本端自己的小画面只能放到第二页去显示
    if (!otherMemberScreenSharing && memberSize <= 2) {
      return 1;
    }
    // 如果是其他人在屏幕共享，需要调整memberSize
    // 如果共享者已经在第一页小画面中显示，其他页需要过滤掉 共享者；如果第一页没有显示，则需要显示。
    // if (otherMemberScreenSharing && shouldShowScreenShareUserVideo(rtcController.getScreenSharingUserUuid())) {
    //   memberSize = memberSize - 1;
    // }
    return (memberSize / galleryItemSize).ceil() + 1;
  }

  Widget buildBigVideoView(NERoomMember? bigViewUser) {
    if (bigViewUser == null) return Container();
    if (bigViewUser.canRenderVideo) {
      return NERoomUserVideoView(
        bigUid!,
        debugName: bigViewUser.name,
        mirror: isSelf(bigUid) ? _frontCamera : false,
        streamType: NEVideoStreamType.kHigh,
        listener: this,
      );
    } else {
      return buildBigNameView(bigViewUser);
    }
  }

  Widget buildSmallVideoView(NERoomMember user) {
    if (user.canRenderVideo) {
      return NERoomUserVideoView(
        user.uuid,
        debugName: user.name,
        mirror: isSelf(user.uuid) ? _frontCamera : false,
        listener: this,
      );
    } else {
      return buildSmallNameView(user.name);
    }
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
      child: Stack(
        children: <Widget>[
          buildSmallVideoView(user),
          buildBottomLeftName(user),
        ],
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

  // Widget buildSmallView(String userId) {
  //   final user = roomContext.getMember(userId);
  //   if (user == null) return Container();
  //   // var muteAudio = user.audioStatus != NERoomAudioStatus.on;
  //   return SafeArea(
  //       child: Align(
  //     alignment: Alignment.topRight,
  //     child: Container(
  //       color: Colors.white,
  //       margin: EdgeInsets.only(
  //           right: 12,
  //           top: appBarHeight + MediaQuery.of(context).viewPadding.top + 20),
  //       height: 128,
  //       width: 72,
  //       padding: EdgeInsets.all(1),
  //       child: Stack(
  //         children: <Widget>[
  //           buildSmallVideoView(user),
  //           // buildAudioIcon(muteAudio),
  //           buildBottomLeftName(user),
  //           if (_isSwitchBigSmallViewsEnable())
  //             Listener(
  //                 behavior: HitTestBehavior.opaque,
  //                 onPointerUp: (event) {
  //                   Alog.i(
  //                       tag: _tag,
  //                       moduleName: _moduleName,
  //                       content: 'switch big and small video views');
  //                   interceptEvent = true;
  //                   switchBigAndSmall = !switchBigAndSmall;
  //                   setState(swapBigSmallUid);
  //                 }),
  //         ],
  //       ),
  //     ),
  //   ));
  // }

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
      if (cancel != true) return;
      trackPeriodicEvent(TrackEventName.handsUp,
          extra: {'value': 0, 'meeting_id': arguments.meetingId});
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

  Future<void> _muteMyAudio(bool mute) async {
    if (mute || roomContext.canUnmuteMyAudio() || _invitingToOpenAudio) {
      _invitingToOpenAudio = false;
      trackPeriodicEvent(TrackEventName.switchAudio,
          extra: {'value': mute ? 0 : 1, 'meeting_id': arguments.meetingId});
      if (mute) {
        rtcController
            .muteMyAudio(enableMediaPubOnAudioMute)
            .onFailure((code, msg) {
          showToast(
              msg ?? NEMeetingUIKitLocalizations.of(context)!.muteAudioFail);
        });
      } else {
        rtcController
            .unmuteMyAudioWithCheckPermission(context, arguments.meetingTitle)
            .onFailure((code, msg) {
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
      if (willRaise != true || !arguments.audioMute) return;
      // check again
      if (roomContext.canUnmuteMyAudio()) {
        return;
      }
      trackPeriodicEvent(TrackEventName.handsUp, extra: {
        'value': 1,
        'meeting_id': arguments.meetingId,
        'type': 'audio'
      });
      final result = await roomContext.raiseMyHand();
      showToast(result.isSuccess()
          ? NEMeetingUIKitLocalizations.of(context)!.handsUpSuccess
          : (result.msg ??
              NEMeetingUIKitLocalizations.of(context)!.handsUpFail));
    }
  }

  void _onScreenShare() async {
    final isSharing = isSelfScreenSharing();
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: '_onScreenShare isShare=$isSharing');

    /// 如果不为空且不等于自己，已经有人共享了
    if (isSharing) {
      trackPeriodicEvent(TrackEventName.screenShare,
          extra: {'value': 0, 'meeting_id': arguments.meetingId});
      final result = await rtcController.stopScreenShare();
      if (!result.isSuccess()) {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.screenShareStopFail);
      }
    } else {
      /// 共享白板时暂不支持屏幕共享
      if (isWhiteBoardSharing()) {
        showToast(NEMeetingUIKitLocalizations.of(context)!.hasWhiteBoardShare);
      } else if (isOtherScreenSharing()) {
        showToast(NEMeetingUIKitLocalizations.of(context)!.shareOverLimit);
      } else {
        confirmStartScreenShare();
      }
    }
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

      if (isWhiteBoardSharing()) {
        showToast(NEMeetingUIKitLocalizations.of(context)!.hasWhiteBoardShare);
        return;
      }
      if (isOtherScreenSharing()) {
        showToast(NEMeetingUIKitLocalizations.of(context)!.shareOverLimit);
        return;
      }

      trackPeriodicEvent(TrackEventName.screenShare,
          extra: {'value': 1, 'meeting_id': arguments.meetingId});

      final result = await rtcController.startScreenShare(
          iosAppGroup: arguments.iosBroadcastAppGroup);
      if (!result.isSuccess()) {
        Alog.i(
            tag: _tag,
            moduleName: _moduleName,
            content:
                'engine startScreenCapture error: ${result.code} ${result.msg}');
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
      }
    });
  }

  ///白板分享模式处理
  Future<void> _onWhiteBoard() async {
    Alog.e(
        tag: _tag,
        moduleName: _moduleName,
        content: 'onWhiteBoard windowMode=$_windowMode');

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
      var result = await whiteboardController.startWhiteboardShare();
      if (result.code != MeetingErrorCode.success) {
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
        extra: {'value': mute ? 0 : 1, 'meeting_id': arguments.meetingId});
  }

  void _muteMyVideo(bool mute) async {
    if (mute || roomContext.canUnmuteMyVideo() || _invitingToOpenVideo) {
      _trackMuteVideoEvent(mute);
      _invitingToOpenVideo = false;
      // var enable = await  PermissionHelper.enableLocalVideoAndCheckPermission(context,!mute,arguments.meetingTitle);
      // if(!enable) return;
      if (mute) {
        rtcController.muteMyVideo().onFailure((code, msg) {
          showToast(
              msg ?? NEMeetingUIKitLocalizations.of(context)!.muteVideoFail);
        });
      } else {
        rtcController
            .unmuteMyVideoWithCheckPermission(context, arguments.meetingTitle)
            .onFailure((code, msg) {
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
      if (willRaise != true || !arguments.videoMute) return;
      // check again
      if (roomContext.canUnmuteMyVideo()) {
        return;
      }
      trackPeriodicEvent(TrackEventName.handsUp, extra: {
        'value': 1,
        'meeting_id': arguments.meetingId,
        'type': 'video'
      });
      final result = await roomContext.raiseMyHand();
      showToast(result.isSuccess()
          ? NEMeetingUIKitLocalizations.of(context)!.handsUpSuccess
          : (result.msg ??
              NEMeetingUIKitLocalizations.of(context)!.handsUpFail));
    }

    // if (result.isSuccess() && Platform.isIOS && !mute && !_frontCamera) {
    //   await rtcController.switchCamera();
    // }
  }

  /// 从下往上显示
  void _onMember() {
    trackPeriodicEvent(TrackEventName.manageMember,
        extra: {'meeting_id': arguments.meetingId});
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

  ///同步美颜漫游
  Future<dynamic> _initBeauty() async {
    NEMeetingKit.instance
        .getSettingsService()
        .isVirtualBackgroundEnabled()
        .then((value) {
      setState(() {
        isVirtualBackgroundEnabled = value;
      });
    });
    var result = await roomContext.rtcController.startBeauty();
    result = await roomContext.rtcController.enableBeauty(true);
    if (result.isSuccess()) {
      beautyLevel =
          await NEMeetingKit.instance.getSettingsService().getBeautyFaceValue();
      await setBeautyEffect(beautyLevel);
    }
    var sharedPreferences = await SharedPreferences.getInstance();

    var currentSelected =
        sharedPreferences.getInt(currentVirtualSelectedKey) ?? 0;
    var setting = NEMeetingKit.instance.getSettingsService();
    if (currentSelected != 0 && await setting.isVirtualBackgroundEnabled()) {
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
      Alog.e(
        tag: _tag,
        moduleName: _moduleName,
        content: 'enableVirtualBackground source:$source ',
      );
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
        Alog.e(
          tag: _tag,
          moduleName: _moduleName,
          content:
              'enableVirtualBackground virtualList=$virtualList ,currentSelected=$currentSelected',
        );
      }
    }
  }

  void _onBeauty() {
    trackPeriodicEvent(TrackEventName.beauty,
        extra: {'meeting_id': arguments.meetingId});
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
        extra: {'meeting_id': arguments.meetingId});
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
          '${NEMeetingUIKitLocalizations.of(context)!.meetingID}${meetingInfo.meetingNum.toMeetingIdFormat()}\n';
    } else if (!arguments.options.isLongMeetingIdEnabled) {
      info +=
          '${NEMeetingUIKitLocalizations.of(context)!.meetingID}${meetingInfo.shortMeetingNum}\n';
    } else {
      info +=
          '${NEMeetingUIKitLocalizations.of(context)!.shortMeetingID}${meetingInfo.shortMeetingNum}(${NEMeetingUIKitLocalizations.of(context)!.internalSpecial})\n';
      info +=
          '${NEMeetingUIKitLocalizations.of(context)!.meetingID}${meetingInfo.meetingNum.toMeetingIdFormat()}\n';
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
            Text(
              user.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w500,
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
      Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: '_onCancel exitCode=$exitCode ,reason=$reason',
      );
      if (_meetingState.index < MeetingState.joined.index) {
        ToastUtils.showToast(
            context, NEMeetingUIKitLocalizations.of(context)!.joinMeetingFail);
      }
      _currentExitCode = exitCode;
      _meetingState = MeetingState.closed;
      _dispose();
      Navigator.of(context).popUntil((route) => false);
      _isAlreadyCancel = true;
    }
  }

  void _dispose() {
    if (_isAlreadyCancel) {
      return;
    }
    NERoomKit.instance.messageChannelService
        .removeMessageChannelCallback(messageCallback);
    roomContext.removeEventCallback(roomEventCallback);
    roomInfoUpdatedEventStream.close();
    restorePreferredOrientations();
    InMeetingService()
      ..clearRoomContext()
      .._updateHistoryMeetingItem(historyMeetingItem)
      .._serviceCallback = null
      .._audioDelegate = null;
    joinTimeOut?.cancel();
    meetingEndTipEventSubscription?.cancel();
    cancelInComingTips();
    Wakelock.disable().catchError((e) {
      Alog.d(tag: _tag, moduleName: _moduleName, content: 'Wakelock error $e');
    });
    if (Platform.isAndroid) {
      NEMeetingPlugin().getNotificationService().stopForegroundService();
    }
    // 在后台的时候由于各种原因从会议中退出，需要对应的销毁Activity
    // 且下次不能再次发送销毁的消息
    if (SchedulerBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      EventBus().emit(NEMeetingUIEvents.flutterPageDisposed);
      _hasRequestEngineToDetach = true;
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content: 'MeetingPage request detach from engine');
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
        Alog.i(
            tag: _tag,
            moduleName: _moduleName,
            content:
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
      _isShowOpenMicroDialog = false;
      _muteMyAudio(agree != true);
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
      _isShowOpenVideoDialog = false;
      _muteMyVideo(agree != true);
    }
  }

  void memberVideoMuteChanged(
      NERoomMember member, bool mute, NERoomMember? operator) async {
    trackPeriodicEvent(
      !mute ? TrackEventName.memberVideoStart : TrackEventName.memberVideoStop,
      extra: {'member_uid': member.uuid, 'meeting_id': arguments.meetingId},
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
      } else {
        lifecycleListen(_messageSource.unreadStream, (dynamic event) {
          setState(() {});
        });
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
    final curDevice = _audioDeviceSelected;
    final targetDevice = isEarpiece()
        ? NEAudioOutputDevice.kSpeakerPhone
        : NEAudioOutputDevice.kEarpiece;
    rtcController
        .setSpeakerphoneOn(targetDevice == NEAudioOutputDevice.kSpeakerPhone)
        .then((result) {
      if (mounted && result.isSuccess()) {
        if (_audioDeviceSelected == curDevice) {
          setState(() {
            _audioDeviceSelected = targetDevice;
          });
        }
      }
    });
  }

  void _onSwitchCamera() async {
    await rtcController.switchCamera();
    setState(() {
      _frontCamera = !_frontCamera;
    });
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
      trackPeriodicEvent(TrackEventName.memberLeaveMeeting,
          extra: {'member_uid': user.uuid, 'meeting_id': arguments.meetingId});
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content: 'onUserLeave ${user.name}');
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
  }

  void _determineActiveUser([bool forceUpdate = false]) {
    final now = DateTime.now();
    if (!forceUpdate &&
        now.difference(lastFocusSwitchTimestamp) < const Duration(seconds: 2)) {
      return;
    }
    lastFocusSwitchTimestamp = now;

    var oldSpeakingUid = speakingUid;
    speakingUid = null;
    if (volumeList == null) {
      ///正在讲话的状态变更
      setState(() {});
      return;
    }
    var oldActiveUserId = activeUid;
    var maxVolume = -1;
    String? maxVolumeUserId;
    volumeList!.forEach((item) {
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
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'swapBigSmallUid switchBigAndSmall= $switchBigAndSmall');
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
    if (isOtherScreenSharing()) return false;
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
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content:
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
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'onAudioDeviceChanged selected=$selected');
    setState(() {
      _audioDeviceSelected = selected;
    });
  }

  void onRtcVirtualBackgroundSourceEnabled(bool enabled, int reason) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content:
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

  @override
  void onRendererAvailable(String userId, NERtcVideoRenderer renderer) {
    if (isSelf(userId)) {
      localRenderer = renderer;
    }
  }

  @override
  void onFirstFrameRendered(String uid) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'onFirstFrameRendered uid=$uid');
  }

  @override
  void onFrameResolutionChanged(
      String uid, int width, int height, int rotation) {
    Alog.i(
      tag: _tag,
      moduleName: _moduleName,
      content:
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

  @override
  Future<NEResult<void>> subscribeAllRemoteAudioStreams(bool subscribe) {
    // Alog.i(
    //     tag: _tag,
    //     moduleName: _moduleName,
    //     content: 'subscribeAllRemoteAudioStreams subscribe=$subscribe');
    // autoSubscribeAudio = subscribe == true;
    // userList.forEach((user) {
    //   if (subscribe) {
    //     inRoomService.getInRoomAudioController().subscribeRemoteAudioStream(user.userId);
    //   } else {
    //     inRoomService.getInRoomAudioController().unsubscribeRemoteAudioStream(user.userId);
    //   }
    // });
    // return Future.value(NEResult(code: MeetingErrorCode.success));
    return Future.value(
        NEResult(code: NEErrorCode.failure, msg: 'NotSupported'));
  }

  @override
  Future<NEResult<void>> startAudioDump() {
    final result = rtcController.startAudioDump(NEAudioDumpType.kPCM);
    Alog.i(
        tag: _tag, moduleName: _moduleName, content: 'startAudioDump: $result');
    return result;
  }

  @override
  Future<NEResult<void>> stopAudioDump() {
    final result = rtcController.stopAudioDump();
    Alog.i(
      tag: _tag,
      moduleName: _moduleName,
      content: 'stopAudioDump: $result',
    );
    return result;
  }

  @override
  Future<NEResult<List<String>>> subscribeRemoteAudioStreams(
      List<String> userList, bool subscribe) {
    return Future.value(
        NEResult(code: NEErrorCode.failure, msg: 'NotSupported'));
    // Alog.i(
    //   tag: _tag,
    //   moduleName: _moduleName,
    //   content:
    //   'subscribeRemoteAudioStreams accountIds=${userList.toString()} subscribe=$subscribe',);
    // if (userList.contains(roomContext.localMember.uuid)) {
    //   return Future.value(
    //     NEResult(
    //       code: MeetingErrorCode.paramsError,
    //       msg: Strings.cannotSubscribeSelfAudio,
    //     ),
    //   );
    // }
    // final unknownUserList = userList
    //     .where((userId) => roomContext.ofMember(userId) == null)
    //     .toList();
    // if (unknownUserList.isNotEmpty) {
    //   return Future.value(
    //     NEResult(
    //         code: MeetingErrorCode.memberNotInRoom,
    //         msg: Strings.partMemberNotInMeeting,
    //         data: unknownUserList),
    //   );
    // } else {
    //   userList.forEach((uid) {
    //     // inRoomService.getInRoomAudioController().subscribeRemoteAudioStream(uid);
    //   });
    //   return Future.value(NEResult(code: MeetingErrorCode.success));
    // }
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
        meetingUniqueId: meetingInfo.meetingId,
        meetingId: meetingInfo.meetingNum,
        shortMeetingId: meetingInfo.shortMeetingNum,
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
      meetingUniqueId: meetingInfo.meetingId,
      meetingId: meetingInfo.meetingNum,
      shortMeetingId: meetingInfo.shortMeetingNum,
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
    Alog.i(
      tag: _tag,
      moduleName: _moduleName,
      content:
          'onConnected elapsed=${DateTime.now().millisecondsSinceEpoch - meetingBeginTime}ms, state=$_meetingState',
    );
    if (_meetingState != MeetingState.joining) return;
    _isEverConnected = true;
    _meetingState = MeetingState.joined;
    joinTimeOut?.cancel();
    InMeetingService()
      .._serviceCallback = this
      .._audioDelegate = this
      ..rememberRoomContext(roomContext);
    createHistoryMeetingItem();
    MeetingCore().notifyStatusChange(NEMeetingStatus(NEMeetingEvent.inMeeting));
    setupAudioAndVideo();

    rtcController.enableAudioVolumeIndication(true, 200);
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
      if (whiteBoardEditingState.value) {
        appBarAnimController.forward();
      }
      // else {
      //   appBarAnimController.reverse();
      // }
    });
    if (mounted) {
      setState(() {});
    }
    if (roomContext.isMySelfCoHost()) {
      ToastUtils.showToast(
          context, NEMeetingUIKitLocalizations.of(context)!.yourChangeCoHost);
    }
    Timer(muteDetectDelay, () {
      muteDetectStarted = true;
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
    switch (code) {
      case 30015: // 连接失败
        _onCancel(
            exitCode: NEMeetingCode.self,
            reason: NEMeetingUIKitLocalizations.of(context)!.connectFail);
        roomContext.leaveRoom();
        break;
    }
  }

  void onRoomDisconnected(NERoomEndReason reason) {
    if (_meetingState.index >= MeetingState.closing.index) {
      return;
    }
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'onDisconnect reason=$reason');
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
        _onCancel(
            exitCode: NEMeetingCode.syncDataError,
            reason: NEMeetingUIKitLocalizations.of(context)!.syncDataError);
        break;
      case NERoomEndReason.kEndOfLife:
        _onCancel(
            exitCode: NEMeetingCode.endOfLife,
            reason: NEMeetingUIKitLocalizations.of(context)!.endOfLife);
        break;
      default:
        ToastUtils.showToast(
            context, NEMeetingUIKitLocalizations.of(context)!.networkNotStable);
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
        extra: {'member_uid': member.uuid, 'meeting_id': arguments.meetingId});

    if (isSelf(member.uuid)) {
      if (!isSharing &&
          !isSelf(operator?.uuid) &&
          isHostOrCoHost(operator?.uuid)) {
        ToastUtils.showToast(
            context, NEMeetingUIKitLocalizations.of(context)!.hostStopShare);
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
    // if (!isSharing) {
    //   _isEditStatus = false;
    // }
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
      Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'focus user changed: old=$oldFocus, new=$newFocus',
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
        rtcController.muteMyAudio();
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
    Alog.i(
      tag: _tag,
      moduleName: _moduleName,
      content: 'liveStateChanged:state ${state.name}',
    );
  }

  void handlePassThroughMessage(NECustomMessage message) {
    if (message.roomUuid != roomContext.roomUuid) {
      return;
    }
    Alog.i(
      tag: _tag,
      moduleName: _moduleName,
      content: 'handlePassThroughMessage: ${message.data}',
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
    final isLocalVolumeChanged = volumeList.length == 1 &&
        volumeList.single.userUuid == roomContext.myUuid;
    if (isLocalVolumeChanged) {
      onLocalAudioVolumeIndication(totalVolume);
    } else {
      this.volumeList = volumeList;
      volumeList.forEach((item) {
        audioVolumeStreams[item.userUuid]?.add(item.volume);
      });
      _determineActiveUser();
    }
  }

  void onLocalAudioVolumeIndication(int volume) {
    audioVolumeStreams[roomContext.localMember.uuid]?.add(volume);
    if (!arguments.options.detectMutedMic || !muteDetectStarted) {
      return;
    }
    if (!arguments.audioMute) {
      localUserSpeakingContinuousTimes = -1;
      return;
    }
    final isLocalUserSpeaking = volume >= minSpeakingVolume;
    if (!isLocalUserSpeaking) {
      localUserSpeakingContinuousTimes = -1;
    } else if (localUserSpeakingContinuousTimes < 0) {
      localUserSpeakingContinuousTimes = 0;
    } else {
      localUserSpeakingContinuousTimes++;
    }
    if (ModalRoute.of(context)!.isCurrent &&
        localUserSpeakingContinuousTimes >= minSpeakingTimesToRemind &&
        DateTime.now().difference(lastRemindTimestamp) >=
            const Duration(minutes: minMinutesToRemind)) {
      showTurnOnMicphoneTipDialog();
    }
  }

  /// “打开扬声器”提醒弹窗
  void showTurnOnMicphoneTipDialog() {
    lastRemindTimestamp = DateTime.now();
    Alog.i(
      tag: _tag,
      moduleName: _moduleName,
      content: 'showTurnOnMicphoneTipDialog',
    );
    DialogUtils.showOneButtonCommonDialog(
      context,
      NEMeetingUIKitLocalizations.of(context)!.micphoneNotWorksDialogTitle,
      NEMeetingUIKitLocalizations.of(context)!.micphoneNotWorksDialogMessage,
      () {
        openMicphoneTipDialogShowing = false;
        Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content: 'dismissTurnOnMicphoneTipDialog',
        );
        Navigator.of(context).pop();
      },
      canBack: false,
    );
    openMicphoneTipDialogShowing = true;
    Timer(Duration(seconds: 3), () {
      if (openMicphoneTipDialogShowing && mounted) {
        Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content: 'dismissTurnOnMicphoneTipDialog',
        );
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> setupAudioAndVideo() async {
    var willOpenAudio = false, willOpenVideo = false;
    if (!arguments.initialAudioMute) {
      if (roomContext.isAllAudioMuted && !isSelfHostOrCoHost()) {
        /// 设置了全体静音，并且自己不是主持人时 提示主持人设置全体静音
        showToast(
            NEMeetingUIKitLocalizations.of(context)!.meetingHostMuteAllAudio);
      } else {
        willOpenAudio = true;
      }
    }

    if (!arguments.initialVideoMute) {
      if (roomContext.isAllVideoMuted && !isSelfHostOrCoHost()) {
        /// 设置了全体关闭视频，并且自己不是主持人时 提示主持人设置全体关闭视频
        showToast(
            NEMeetingUIKitLocalizations.of(context)!.meetingHostMuteAllVideo);
      } else {
        willOpenVideo = true;
      }
    }

    Alog.i(
      tag: _tag,
      moduleName: _moduleName,
      content: 'setup audio and video: $willOpenAudio $willOpenVideo',
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
    var level = beautyLevel.toDouble() / 10;
    roomContext.rtcController
        .setBeautyEffect(NERoomBeautyEffectType.kWhiten, level);
    roomContext.rtcController
        .setBeautyEffect(NERoomBeautyEffectType.kSmooth, level);
    roomContext.rtcController
        .setBeautyEffect(NERoomBeautyEffectType.kFaceRuddy, level);
    await roomContext.rtcController
        .setBeautyEffect(NERoomBeautyEffectType.kFaceSharpen, level);
  }

  void _onVirtualBackground() {
    isPreviewVirtualBackground = true;
    Navigator.of(context).push(MaterialMeetingPageRoute(
        builder: (context) => VirtualBackgroundPage(
            roomContext: roomContext,
            renderer: localRenderer,
            muteVideo: arguments.videoMute,
            callback: () => isPreviewVirtualBackground = false)));
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
      SettingsRepository.isMeetingEndTimeTiSupported() &&
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
      Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: message,
      );
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
    meetingEndTipEventSubscription ??=
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

bool _isScreenShareSupported() {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final osVer = '${DeviceInfo.osVer}.0';
    return (double.tryParse(osVer.substring(0, osVer.indexOf(r'.'))) ?? 0) >=
        12;
  }
  return defaultTargetPlatform == TargetPlatform.android;
}
