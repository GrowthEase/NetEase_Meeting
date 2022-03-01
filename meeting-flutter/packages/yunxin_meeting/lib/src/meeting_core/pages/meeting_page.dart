// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

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
        NERtcDeviceEventCallback,
        TickerProviderStateMixin,
        EventTrackMixin,
        NERoomLifeCycleObserver,
        NERoomUserVideoViewListener,
        AudioManager,
        NEInRoomServiceListener, 
        InMeetingDataServiceCallback {
  MeetingBusinessUiState(this.arguments);

  final MeetingArguments arguments;

  int _currentExitCode = 0;

  MeetingState _meetingState = MeetingState.init;

  /// 显示逻辑，有焦点显示焦点， 否则显示活跃， 否则显示host，否则显示自己, speakingUid与activeUid相同，当没有人说话时，activeUid不变，speakingUid置空
  String? focusUid, hostUid, activeUid, bigUid, smallUid, speakingUid;

  Timer? joinTimeOut, _inComingTipsTimer;

  final ValueNotifier<int> _meetingMemberCount = ValueNotifier(1);

  ValueListenable<int> get meetingMemberCountListenable => _meetingMemberCount;

  final ChatRoomMessageSource _messageSource = ChatRoomMessageSource();

  bool _isShowOpenMicroDialog = false,
      _isShowOpenVideoDialog = false,
      switchBigAndSmall = false,
      interceptEvent = false,
      _isEditStatus = false,
      autoSubscribeAudio = true;

  PointerEvent? downPointEvent;

  PageController? _galleryModePageController;

  double? aspectRatio = 9 / 16,
      vPaddingTop,
      vPaddingLR,
      hPaddingTop,
      hPaddingLR;

  WindowMode _windowMode = WindowMode.gallery;

  final double appBarHeight = 64, bottomBarHeight = 54, space = 1;

  late AnimationController appBarAnimController;

  late Animation<Offset> bottomAnim, topBarAnim;

  late int meetingBeginTime;

  bool _isAlreadyCancel = false,
      _isMinimized = false,
      _hasRequestEngineToDetach = false,
      _isPortrait = true,
      _frontCamera = true;

  double? _restoreToPageIndex;

  OverlayEntry? _overlayEntry;

  int _audioDeviceSelected = NERtcAudioDevice.speakerPhone;

  int beautyLevel = 0;

  late final NEInRoomService inRoomService;
  final StreamController<Object> roomInfoUpdatedEventStream = StreamController.broadcast();
  late final NEInRoomScreenShareController screenShareController;
  late final NEInRoomWhiteboardController whiteboardController;

  ValueNotifier<bool> whiteBoardInteractionStatusNotifier =  ValueNotifier<bool>(false);

  NEHistoryMeetingItem? historyMeetingItem;

  bool localVideoPermissionGranted = false, localAudioPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    inRoomService = NERoomKit.instance.getInRoomService()!;
    screenShareController = inRoomService.getInRoomScreenShareController();
    whiteboardController = inRoomService.getInRoomWhiteboardController();
    inRoomService
      ..addListener(this)
      ..addRtcDeviceEventListener(this)
      ..addRoomLifeCycleObserver(this)
      ..startConnect();

    InMeetingService()._audioDelegate = this;
    SystemChrome.setPreferredOrientations([]);
    meetingBeginTime = DateTime.now().millisecondsSinceEpoch;
    Wakelock.enable();
    _galleryModePageController = PageController(initialPage: 0);
    _initAnimationController();
    _joining();
    trackPeriodicEvent(TrackEventName.pageMeeting);
  }

  @override
  void onAppLifecycleState(AppLifecycleState state) {
    _checkResumeFromMinimized(state);
  }

  @override
  void didChangeMetrics() {
    assert(() {
      print(
          '$tag didChangeMetrics: ${WidgetsBinding.instance!.window.physicalSize}');
      return true;
    }());
    if (!_isMinimized &&
        _restoreToPageIndex != null &&
        !WidgetsBinding.instance!.window.physicalSize.isEmpty) {
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
      EventBus().emit(UIEventName.flutterEngineCanRecycle, 'minimize');
      MeetingCore().notifyStatusChange(
          NEMeetingStatus(NEMeetingEvent.inMeetingMinimized));
      Alog.i(tag: _tag, moduleName: _moduleName, content: '$tag, minimized');
    }
  }

  void _showToast(String message, [ValueGetter<bool>? predictor]) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if ((predictor == null || predictor()) && mounted) {
        ToastUtils.showToast(context, message);
      }
    });
  }

  void _initAnimationController() {
    appBarAnimController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    bottomAnim = Tween(begin: Offset(0, 0), end: Offset(0, 1)).animate(
        CurvedAnimation(parent: appBarAnimController, curve: Curves.easeOut));
    topBarAnim = Tween(begin: Offset(0, 0), end: Offset(0, -1)).animate(
        CurvedAnimation(parent: appBarAnimController, curve: Curves.easeOut));
  }

  void _joining() {
    if (_meetingState == MeetingState.init) {
      _meetingState = MeetingState.joining;
      joinTimeOut =
          Timer(Duration(milliseconds: arguments.joinTimeout), () {
            if (_meetingState.index <= MeetingState.joining.index) {
              _meetingState = MeetingState.closing;
              inRoomService.leaveCurrentRoom(false);
              _onCancel(exitCode: NEMeetingCode.joinTimeout, reason: 'join timeout');
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
    if (_meetingState.index < MeetingState.joined.index) {
      return buildJoiningUI();
    } else {
      return WillPopScope(
        child: OrientationBuilder(builder: (_, orientation) {
          _isPortrait = orientation == Orientation.portrait;
          return Stack(
            children: <Widget>[
              Listener(
                key: MeetingCoreValueKey.meetingFullScreen,
                behavior: HitTestBehavior.deferToChild,
                onPointerDown: (event) {
                  assert(() {
                    print(
                        'Listener onPointerDown: ${event.device} @ ${event.position} ${event.timeStamp}');
                    return true;
                  }());
                  downPointEvent = event;
                  interceptEvent = false;
                },
                onPointerUp: (event) {
                  assert(() {
                    print(
                        'Listener onPointerUp: ${event.device}, trackingId=${event.device} ${event.timeStamp}');
                    return true;
                  }());

                  /// 适配当白板模式在非编辑状态下，进行缩放，点击区域(∞，100)区域不消费事件。
                  if (_windowMode == WindowMode.whiteBoard &&
                      !_isEditStatus &&
                      event.position.dy <= 100) {
                    return;
                  }
                  //we only respond to the tracking pointer id
                  if (downPointEvent?.device != event.device) {
                    return;
                  }
                  //this is a move or long press, ignore
                  if ((event.position - downPointEvent!.position).distance >=
                      kTouchSlop ||
                      event.timeStamp - downPointEvent!.timeStamp >=
                          kLongPressTimeout) {
                    return;
                  }
                  if (interceptEvent) {
                    interceptEvent = false;
                    return;
                  }

                  if (!_isEditStatus) {
                    changeToolBarStatus();
                  }
                },
                child: buildCenter(),
              ),
              // MeetingCoreValueKey.addTextWidgetTest(valueKey:MeetingCoreValueKey.meetingFullScreen,value: handlMeetingFullScreen),
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                    child: buildBottomAppBar(), position: bottomAnim),
              ),
              SlideTransition(position: topBarAnim, child: buildAppBar()),
            ],
          );
        }),
        onWillPop: () {
          if (!_hideMorePopupMenu()) finishPage();
          return Future.value(false);
        },
      );
    }
  }

  Widget buildCenter(){
    return Stack(
      children: <Widget>[
        NERoomUserVideoControllerProvider(
          videoController: inRoomService.getInRoomVideoController(),
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
    return _audioDeviceSelected == NERtcAudioDevice.bluetoothHeadset ||
        _audioDeviceSelected == NERtcAudioDevice.wiredHeadset;
  }

  bool isEarpiece() {
    return _audioDeviceSelected == NERtcAudioDevice.earpiece;
  }

  Widget buildAppBar() {
    final data = MediaQuery.of(context);
    return Container(
      height: appBarHeight + data.viewPadding.top,
      child: Row(
        children: <Widget>[
          buildAudioMode(data),
          buildCameraMode(data),
          buildMeetingInfo(data),
          buildMinimize(data),
          buildLeave(data),
        ],
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [UIColors.color_292933, UIColors.color_212129],
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
              color: UIColors.colorD93D35,
              borderRadius: BorderRadius.all(Radius.circular(13))),
          child: Text(isHost() ? Strings.finish : Strings.leave,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: UIColors.white,
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
                          text:
                          ' ${TextUtils.isEmpty(arguments.meetingTitle) ? Strings.appName : arguments.meetingTitle} ',
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
                    MeetingDuration(arguments.joinmeetingInfo.duration * 1000 +
                        (DateTime.now().millisecondsSinceEpoch -
                            arguments.requestTimeStamp)),
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
    DialogUtils.showChildNavigatorPopup(context,
        MeetingInfoPage(arguments.options!));
  }

  Widget buildMinimize(MediaQueryData data) {
    if (!arguments.noMinimize) {
      return Container(
          padding:
          EdgeInsets.only(left: 10, top: data.viewPadding.top, right: 8),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: const Icon(NEMeetingIconFont.icon_narrow_line,
                key: MeetingCoreValueKey.minimize,
                size: 21,
                color: UIColors.white),
            onTap: _minimizeMeeting,
          ));
    } else {
      return Container(width: 39);
    }
  }

  Widget buildCameraMode(MediaQueryData data) {
    if (arguments.videoMute == true || arguments.noSwitchCamera
        || !inRoomService.getInRoomVideoController().canSwitchCamera()) {
      return Container(width: 39);
    }
    return Container(
        padding: EdgeInsets.only(left: 8, top: data.viewPadding.top, right: 10),
        //
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: const Icon(NEMeetingIconFont.icon_yx_tv_filpx,
              key: MeetingCoreValueKey.switchCamera,
              size: 21,
              color: UIColors.white),
          onTap: _onSwitchCamera,
        ));
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
              key: MeetingCoreValueKey.switchLoudspeaker,
              size: 21,
              color: UIColors.white),
          onTap: _audioModeSwitch,
        ));
  }

  void _audioModeSwitch() {
    if (isHeadset()) {
      ToastUtils.showToast(context, Strings.headsetState);
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
              UIColors.color_212129,
              UIColors.color_212129
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
                            if (menu.itemId == NEMenuIDs.microphone &&
                                inRoomService.getMyUserInfo()?.raiseHandDetail.isRaisingHand == true) {
                              return Expanded(
                                child: buildHandsUp(
                                    Strings.inHandsUp, () => _muteMyAudio(!arguments.audioMute)),
                              );
                            }
                            if (menu.itemId == NEMenuIDs.managerParticipants &&
                                hasHandsUp() &&
                                isHost()) {
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
                                  color: UIColors.color_33FFFFFF, width: 0.5)),
                          gradient: LinearGradient(
                              colors: [
                                UIColors.color_292933,
                                UIColors.color_212129
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                    )
                  ],
                ))));
  }

  bool shouldShowMenu(NEMeetingMenuItem item) {
    final settingsService = NERoomKit.instance.getSettingsService();
    final id = item.itemId;
    if (!item.isValid) return false;
    if (id == NEMenuIDs.screenShare && !settingsService.isScreenShareSupported()) return false;
    if (id == NEMenuIDs.chatroom &&
        (arguments.noChat || !inRoomService.getInRoomChatController().isChatroomEnabled())) return false;
    if (id == NEMenuIDs.invitation && arguments.noInvite) return false;
    if (id == InternalMenuIDs.beauty && !settingsService.isBeautySupported()) {
      return false;
    }
    if (id == InternalMenuIDs.live && !inRoomService.getInRoomLiveStreamController().isLiveStreamEnabled()) {
      return false;
    }
    if (id == NEMenuIDs.whiteBoard &&
        (arguments.noWhiteBoard || !settingsService.isWhiteboardSupported())) {
      return false;
    }
    switch (item.visibility) {
      case NEMenuVisibility.visibleToHostOnly:
        return isHost();
      case NEMenuVisibility.visibleExcludeHost:
        return !isHost();
      case NEMenuVisibility.visibleAlways:
        return true;
    }
  }

  final Map<int, NEMeetingMenuItem> menuId2Item = {};
  final Map<int, CyclicStateListController> menuId2Controller = {};

  Widget? menuItem2Widget(NEMeetingMenuItem item) {
    menuId2Item.putIfAbsent(item.itemId, () => item);
    final tipBuilder = getMenuItemTipBuilder(item.itemId);
    if (item is NESingleStateMenuItem) {
      return SingleStateMenuItem(
        menuItem: item,
        callback: handleMenuItemClick,
        tipBuilder: tipBuilder,
      );
    } else if (item is NECheckableMenuItem) {
      final controller = menuId2Controller.putIfAbsent(
          item.itemId, () => getMenuItemStateController(item.itemId));
      return CheckableMenuItem(
        menuItem: item,
        controller: controller,
        callback: handleMenuItemClick,
        tipBuilder: tipBuilder,
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
          width: 34,
          padding: const EdgeInsets.only(left: 5),
          child: Stack(
            children: <Widget>[
              anchor,
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  '$value',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w400),
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
                            color: UIColors.colorFE3B30,
                            shape: Border()),
                        alignment: Alignment.center,
                        child: Text(
                          '${min(max, value)}',
                          style: const TextStyle(
                              fontSize: 11,
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
      case InternalMenuIDs.more:
        if (arguments.options!.extras!['useCompatibleMoreMenuStyle'] == true) {
          _showCompatibleMoreMenu();
        } else {
          _showMorePopupMenu();
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
    }
    if (itemId >= firstInjectableMenuId) {
      final transitionFuture =
      MeetingUIService().injectedMenuItemClickHandler?.call(context,clickInfo);
      menuId2Controller[itemId]?.didStateTransition(transitionFuture);
    }
  }

  bool hasHandsUp() {
    return userList.any((user) => user.raiseHandDetail.isRaisingHand);
  }

  int handsUpCount() {
    return userList.where((user) => user.raiseHandDetail.isRaisingHand).length;
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
                        color: UIColors.color_337eff,
                        border: Border.all(color: Colors.transparent, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(2))),
                  )),
              Align(
                alignment: Alignment.bottomCenter,
                child: Icon(NEMeetingIconFont.icon_triangle_down,
                    size: 7, color: UIColors.color_337eff),
              ),
              Align(
                alignment: Alignment(0.0, -0.8),
                child: Icon(NEMeetingIconFont.icon_raisehands,
                    size: 20, color: Colors.white),
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
      if (status == AnimationStatus.dismissed) {
        _morePopupMenuEntry?.remove();
        _morePopupMenuEntry = null;
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
                          UIColors.color_33333f,
                          UIColors.grey_292933,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    padding: EdgeInsets.all(4),
                    child: Wrap(
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
    if (_morePopupMenuEntry != null) {
      _morePopupMenuAnimation!.reverse();
      return true;
    }
    return false;
  }

  void onChat() {
    cancelInComingTips();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return MeetingChatRoomPage(
        ChatRoomArguments(
          _messageSource,
        ),
      );
    }));
  }

  void _showCompatibleMoreMenu() {
    showCupertinoModalPopup<int>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(Strings.more,
              style: TextStyle(color: UIColors.grey_8F8F8F, fontSize: 13)),
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
              "${Strings.chat}${_messageSource.unread > 0 ? '(${_messageSource.unread})' : ''}";
            }
            return title != null
                ? buildActionSheetItem(
                context, false, title, element.itemId)
                : null;
          })
              .whereType<Widget>()
              .toList(growable: false),
          cancelButton: buildActionSheetItem(
              context, true, Strings.cancel, InternalMenuIDs.cancel),
        )).then((itemId) {
      if (itemId != null) {
        handleMenuItemClick(NEMenuClickInfo(itemId));
      }
    });
  }

  void _onLive() {
    final liveInfo = inRoomService.getInRoomLiveStreamController().getLiveStreamInfo();
    if (liveInfo == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return MeetingLivePage(
          LiveArguments(liveInfo, roomInfoUpdatedEventStream.stream));
    }));
  }

  /// 加入中状态
  Widget buildJoiningUI() {
    return Container(
        decoration: BoxDecoration(
            gradient:
            buildGradient([UIColors.grey_292933, UIColors.grey_1E1E25])),
        child: Column(
          children: <Widget>[
            Spacer(),
            Image.asset(NEMeetingImages.meetingJoin,
                package: NEMeetingImages.package),
            SizedBox(height: 16),
            Text(Strings.joiningTips,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400)),
            Spacer(),
          ],
        ));
  }

  @override
  void finishPage() {
    DialogUtils.showChildNavigatorPopup<int>(
        context,
        CupertinoActionSheet(
          actions: <Widget>[
            buildActionSheetItem(context, false, Strings.leaveMeeting,
                InternalMenuIDs.leaveMeeting),
            if (isHost())
              buildActionSheetItem(context, false, Strings.quitMeeting,
                  InternalMenuIDs.closeMeeting,
                  textColor: UIColors.colorFE3B30),
          ],
          cancelButton: buildActionSheetItem(
              context, true, Strings.cancel, InternalMenuIDs.cancel),
        )).then<void>((int? itemId) async {
      if (itemId != null && itemId != InternalMenuIDs.cancel) {
        _meetingState = MeetingState.closing;
        final requestClose = itemId == InternalMenuIDs.closeMeeting;
        final result = await inRoomService.leaveCurrentRoom(requestClose);
        if (mounted && requestClose && !result.isSuccess()) {
          ToastUtils.showToast(context, result.msg ?? Strings.networkUnavailableCloseFail);
        }
        switch (itemId) {
          case InternalMenuIDs.leaveMeeting:
            trackPeriodicEvent(TrackEventName.selfLeaveMeeting,
                extra: {'meeting_id': arguments.meetingId});
            _onCancel(reason: 'leaveMeeting', exitCode: NEMeetingCode.self);
            break;
          case InternalMenuIDs.closeMeeting:
            trackPeriodicEvent(TrackEventName.selfFinishMeeting,
                extra: {'meeting_id': arguments.meetingId});
            //退出会议的时候，调了MeetingRepository.closeMeeting，ios上会先调用onDisconnect接口
            //_meetingState = MeetingState.manuallyClosed;
            _onCancel(
                reason: 'quitMeeting', exitCode: NEMeetingCode.closeBySelfAsHost);
            break;
          default:
            break;
        }
      }
    });
  }

  Widget buildActionSheetItem(
      BuildContext context, bool defaultAction, String title, int itemId,
      {Color textColor = UIColors.color_007AFF}) {
    return CupertinoActionSheetAction(
        isDefaultAction: defaultAction,
        child: Text(title, style: TextStyle(color: textColor)),
        onPressed: () {
          Navigator.pop(context, itemId);
        });
  }

  bool isSelf(String? userId) {
    return userId != null && inRoomService.isMyself(userId);
  }

  bool isSelfScreenSharing() {
    return inRoomService.getInRoomScreenShareController().isSharingScreen();
  }

  bool isOtherScreenSharing() {
    return inRoomService.getInRoomScreenShareController().isOtherSharing();
  }

  bool isSelfWhiteBoardSharing() {
    return whiteboardController.isSharingWhiteboard();
  }

  bool isWhiteBoardSharing() {
    return whiteboardController.getWhiteboardSharingUserId() != null;
  }

  bool isOtherWhiteBoardSharing() {
    return whiteboardController.isOtherSharing();
  }

  bool isWhiteBoardSharingAndIsHost() {
    return isSelfWhiteBoardSharing() || (isWhiteBoardSharing() && isHost());
  }

  /// 主讲人视觉，
  Widget buildHostUI() {
    return Stack(
      children: <Widget>[
        buildBigVideoView(),
        if (bigUid != null) buildNameView(bigUid!, Alignment.topLeft),
        if (smallUid != null) buildSmallView(smallUid!), // 大图不是自己才显示小窗口
        // if (_sessionInfo.debug) buildDebugView(),
      ],
    );
  }

  ///白板共享
  Widget buildWhiteBoardShareUI() {
    _isEditStatus = whiteboardController.hasInteractPrivilege();
    Widget modeUI = WhiteBoardWebPage(
      whiteBoardPageStatusCallback: (isEditStatus) {
        if (isEditStatus) {
          appBarAnimController.forward();
        } else {
          appBarAnimController.reverse();
        }
        _isEditStatus = isEditStatus;
        setState(() {});
      },
      valueNotifier: whiteBoardInteractionStatusNotifier,
    );

    return modeUI;
  }

  ///屏幕共享
  Widget buildScreenShareUI() {

    return Container(
      color: UIColors.color_181820,
      alignment: Alignment.center,
      child: Text(
        '${inRoomService.getMyUserInfo()!.displayName}${Strings.screenShareLocalTips}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String? getScreenShareUserId() {
    return inRoomService.getInRoomScreenShareController().getScreenSharingUserId();
  }

  Widget buildRemoteScreenShare() {
    var roomUid = getScreenShareUserId();
    return Stack(
      children: <Widget>[
        if (roomUid == null)
          Container(color: UIColors.color_181820)
        else ...[
          Align(
            child: InteractiveViewer(
              maxScale: 4.0,
              minScale: 1.0,
              transformationController: _getScreenShareController(),
              child: NERoomUserVideoView.subStream(
                roomUid,
                listener: this,
              ),
            ),
            alignment: Alignment.center,
          ),
          buildSmallView(roomUid),
          buildNameView(roomUid, Alignment.topLeft, suffix: Strings.screenShareSuffix),
        ],
        if (speakingUid != null)
          buildNameView(speakingUid!, Alignment.topRight, prefix: Strings.speakingPrefix),
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
        !WidgetsBinding.instance!.window.physicalSize.isEmpty) {
      assert(() {
        print(
            '$tag, schedule restore pageview index: $_restoreToPageIndex ${_galleryModePageController!.position.viewportDimension}');
        return true;
      }());
      final toPage = _restoreToPageIndex;
      _restoreToPageIndex = null;
      SchedulerBinding.instance!.addPostFrameCallback((_) {
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
            return isOtherScreenSharing()
                ? buildRemoteScreenShare()
                : buildHostUI();
          },
          physics: PageScrollPhysics(),
          controller: _galleryModePageController,
          allowImplicitScrolling: false,
          itemCount: pageSize,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
                gradient: buildGradient(
                    [Colors.transparent, UIColors.black_50_000000])),
            height: 39,
            child: pageSize <= 1
                ? Center()
                : DotsIndicator(
                controller: _galleryModePageController!,
                itemCount: pageSize),
          ),
        )
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
      final user = inRoomService.getUserInfoById(roomUid);
      if (user?.videoStatus == NERoomVideoStatus.on ) {
        innerView = NERoomUserVideoView(
          roomUid,
          mirror: isSelf(roomUid) ? _frontCamera : false,
        );
      } else {
        innerView = buildSmallNameView(user?.displayName);
      }
      list.add(buildGridItem(innerView, roomUid,
          user?.displayName, user?.audioStatus != NERoomAudioStatus.on));
    });
    return list;
  }

  Widget buildGridItem(
      Widget view, String roomUid, String? name, bool muteAudio) {
    return Stack(
      children: <Widget>[
        view,
        buildGalleyNameView(name, muteAudio),
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: isHighLight(roomUid)
                      ? UIColors.color_59F20C
                      : UIColors.black,
                  width: 2)),
        )
      ],
    );
  }

  Widget buildGalleyNameView(String? name, bool muteAudio) {
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
            if (muteAudio)
              Icon(NEMeetingIconFont.icon_yx_tv_voice_offx,
                  size: 12, color: UIColors.colorFE3B30),
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

  Align buildBottomLeftName(String name) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        height: 13,
        margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.all(Radius.circular(2))),
        child: Text(
          truncate(name),
          softWrap: false,
          maxLines: 1,
          style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w400),
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
                  size: 9, color: UIColors.colorFE3B30))
              : Container(),
        ));
  }

  Iterable<NEInRoomUserInfo> get userList =>
      inRoomService.getAllUsers().where((user) => user.roleType != RoleType.hide);

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
    // 共享者已经在第一页小画面中显示，其他页需要过滤掉 共享者
    if (otherMemberScreenSharing) {
      memberSize = memberSize - 1;
    }
    return (memberSize / MeetingConfig().pageSize).ceil() + 1;
  }

  Widget buildBigVideoView() {
    final bigViewUser = bigUid != null ? inRoomService.getUserInfoById(bigUid!) : null;
    if (bigViewUser == null) return Container();
    if (bigViewUser.videoStatus == NERoomVideoStatus.on) {
      return NERoomUserVideoView(
        bigUid!,
        mirror: isSelf(bigUid) ? _frontCamera : false,
        streamType: NERtcRemoteVideoStreamType.high,
      );
    } else {
      return buildBigNameView(bigViewUser.displayName);
    }
  }

  Widget buildSmallVideoView(NEInRoomUserInfo user) {
    if (user.videoStatus == NERoomVideoStatus.on) {
      return NERoomUserVideoView(
        user.userId,
        mirror: isSelf(user.userId) ? _frontCamera : false,
      );
    } else {
      return buildSmallNameView(user.displayName);
    }
  }

  Widget buildNameView(String userId, AlignmentGeometry alignment,
      {String? prefix, String? suffix}) {
    final user = inRoomService.getUserInfoById(userId);
    return Align(
      alignment: alignment,
      child: Container(
        height: 21,
        margin: EdgeInsets.only(
            left: 4, top: 4 + MediaQuery.of(context).viewPadding.top),
        padding: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
            color: Colors.black54,
            border: Border.all(color: Colors.transparent, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(2))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (user != null && user.audioStatus != NERoomAudioStatus.on)
              Icon(NEMeetingIconFont.icon_yx_tv_voice_offx,
                  size: 12, color: UIColors.colorFE3B30),
            if ((user?.displayName ?? '').isNotEmpty)
              Container(
                  child: Text(
                      '${prefix ?? ''} ${truncate(user?.displayName ?? '')}${suffix ?? ''}',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      key: MeetingCoreValueKey.nickName,
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
                      ? (enableColor ?? UIColors.colorFE3B30)
                      : (disableColor ?? UIColors.colorECEDEF)),
              Padding(padding: EdgeInsets.only(top: 2)),
              Text(
                state ? enableStr : disableStr,
                style: TextStyle(
                    color: UIColors.colorECEDEF,
                    fontSize: 10,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400),
              )
            ],
          ),
        ));
  }

  Widget buildSmallView(String userId) {
    final user = inRoomService.getUserInfoById(userId);
    if (user == null) return Container();
    var muteAudio = user.audioStatus != NERoomAudioStatus.on;
    return SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(
                right: 12,
                top: appBarHeight + MediaQuery.of(context).viewPadding.top + 20),
            height: 128,
            width: 72,
            padding: EdgeInsets.all(1),
            child: Stack(
              children: <Widget>[
                buildSmallVideoView(user),
                buildAudioIcon(muteAudio),
                buildBottomLeftName(user.displayName),
                if (_isSwitchBigSmallViewsEnable())
                  Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerUp: (event) {
                        interceptEvent = true;
                        switchBigAndSmall = !switchBigAndSmall;
                        setState(swapBigSmallUid);
                      }),
              ],
            ),
          ),
        ));
  }

  Future<void> _muteMyAudio(bool mute) async {
    final inRoomAudioController = inRoomService.getInRoomAudioController();
    if (inRoomService.getMyUserInfo()?.raiseHandDetail.isRaisingHand == true) {
      final cancel = await DialogUtils.showCommonDialog(
          context, Strings.cancelHandsUp, Strings.cancelHandsUpTips, () {
        Navigator.of(context).pop();
      }, () {
        Navigator.of(context).pop(true);
      });
      if (cancel != true) return;
      trackPeriodicEvent(TrackEventName.handsUp,
          extra: {'value': 0, 'meeting_id': arguments.meetingId});
      final result = await inRoomAudioController.lowerMyHand();
      if (mounted && !result.isSuccess()) {
        ToastUtils.showToast(context, result.msg ?? Strings.cancelHandsUpFail);
      }
    } else if (mute || inRoomAudioController.canUnmuteMyAudio()) {
      trackPeriodicEvent(TrackEventName.switchAudio,
          extra: {'value': mute ? 0 : 1, 'meeting_id': arguments.meetingId});
      var enable = await  _enableLocalAudioAndCheckPermission(!mute);
      if(!enable) return;
      final result = await inRoomService.getInRoomAudioController().muteMyAudio(
          mute);
      if (mounted && !result.isSuccess()) {
        ToastUtils.showToast(
            context,
            result.msg ??
                (mute ? Strings.muteAudioFail : Strings.unMuteAudioFail));
      }
    } else {
      final willRaise = await DialogUtils.showCommonDialog(
          context, Strings.muteAudioAll, Strings.muteAllHandsUpTips, () {
        Navigator.of(context).pop();
      }, () {
        Navigator.of(context).pop(true);
      }, acceptText: Strings.handsUpApply);
      if (willRaise != true) return;
      trackPeriodicEvent(TrackEventName.handsUp,
          extra: {'value': 1, 'meeting_id': arguments.meetingId});
      final result = await inRoomAudioController.raiseMyHand();
      if (mounted) {
        ToastUtils.showToast(
            context,
            result.isSuccess()
                ? Strings.handsUpSuccess
                : (result.msg ?? Strings.handsUpFail));
      }
    }
  }

  Future<bool> _enableLocalVideoAndCheckPermission(bool on) async {
    var result = true;
    if (on && !localVideoPermissionGranted) {
      localVideoPermissionGranted =
      await PermissionHelper.requestPermissionSingle(
          context, Permission.camera,arguments.meetingTitle,Strings.cameraPermission);
      result = localVideoPermissionGranted;
    }
    return result;
  }

  Future<bool> _enableLocalAudioAndCheckPermission(bool on) async {
    var result = true;
    if (on && !localAudioPermissionGranted) {
      localAudioPermissionGranted =
      await PermissionHelper.requestPermissionSingle(
          context, Permission.microphone,arguments.meetingTitle,Strings.microphonePermission);
      result = localAudioPermissionGranted;
    }
    return result;
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
      final result = await inRoomService.getInRoomScreenShareController().stopScreenShare();
      if (!result.isSuccess()) {
        ToastUtils.showToast(context, result.msg ?? Strings.screenShareStopFail);
      }
    } else {
      /// 共享白板时暂不支持屏幕共享
      if (isWhiteBoardSharing()) {
        ToastUtils.showToast(context, Strings.hasWhiteBoardShare);
      } else if (isOtherScreenSharing()) {
        ToastUtils.showToast(context, Strings.shareOverLimit);
      } else {
        confirmStartScreenShare();
      }
    }
  }

  void confirmStartScreenShare() {
    if (_meetingState.index >= MeetingState.closing.index) {
      return;
    }

    DialogUtils.showShareScreenDialog(context, Strings.screenShare,
        '${TextUtils.isEmpty(arguments.meetingTitle) ? Strings.appName : arguments.meetingTitle}${Strings.screenShareTips}',
            () async {
          Navigator.of(context).pop();
          //wait until dialog dismiss
          await Future.delayed(Duration(milliseconds: 250), () {});

          if (isWhiteBoardSharing()) {
            ToastUtils.showToast(context, Strings.hasWhiteBoardShare);
            return;
          }
          if (isOtherScreenSharing()) {
            ToastUtils.showToast(context, Strings.shareOverLimit);
            return;
          }

          trackPeriodicEvent(TrackEventName.screenShare,
              extra: {'value': 1, 'meeting_id': arguments.meetingId});

          final screenConfig = NERtcScreenConfig();
          if (Platform.isIOS) {
            screenConfig.videoProfile = NERtcVideoProfile.hd720p;
            screenConfig.frameRate = NERtcVideoFrameRate.fps_10;
          } else {
            screenConfig.videoProfile = NERtcVideoProfile.hd1080p;
          }
          final result = await inRoomService.getInRoomScreenShareController().startScreenShare(screenConfig,
              arguments.options?.iosBroadcastAppGroup);
          if (!result.isSuccess()) {
            Alog.i(
                tag: _tag,
                moduleName: _moduleName,
                content: 'engine startScreenCapture error: ${result.code}');
            ToastUtils.showToast(context, result.msg ?? Strings.screenShareStartFail);
          }
        });
  }

  ///白板分享模式处理
  Future<void> _onWhiteBoard() async {
    Alog.e(
        tag: _tag,
        moduleName: _moduleName,
        content: '_onWhiteBoard _windowMode = ${_windowMode},');

    /// 屏幕共享时暂不支持白板共享
    if (screenShareController.getScreenSharingUserId() != null) {
      ToastUtils.showToast(context, Strings.hasScreenShareShare);
      return;
    }

    if (whiteboardController.isOtherSharing()) {
      ToastUtils.showToast(context, Strings.shareOverLimit);
      return;
    }

    if (whiteboardController.isSharingWhiteboard()) {
      var result = await whiteboardController.stopWhiteboardShare();
      if (result.code != RoomErrorCode.success) {
        ToastUtils.showToast(
            context, result.msg ?? Strings.whiteBoardShareStopFail);
      }
    } else {
      var result = await whiteboardController.startWhiteboardShare();
      if (result.code != RoomErrorCode.success) {
        ToastUtils.showToast(
            context, result.msg ?? Strings.whiteBoardShareStartFail);
      }
    }
  }

  void _muteMyVideo(bool mute) async {
    trackPeriodicEvent(TrackEventName.switchCamera,
        extra: {'value': mute ? 0 : 1, 'meeting_id': arguments.meetingId});
    var enable = await  _enableLocalVideoAndCheckPermission(!mute);
    if(!enable) return;
    final result =
    await inRoomService.getInRoomVideoController().muteMyVideo(mute);
    if (result.isSuccess() && Platform.isIOS && !mute && !_frontCamera) {
      await _onSyncSwitchCamera();
    }
    if (mounted && !result.isSuccess()) {
      ToastUtils.showToast(
          context,
          result.msg ??
              (mute ? Strings.muteVideoFail : Strings.unMuteVideoFail));
    }
  }

  /// 从下往上显示
  void _onMember() {
    trackPeriodicEvent(TrackEventName.manageMember,
        extra: {'meeting_id': arguments.meetingId});
    DialogUtils.showChildNavigatorPopup(
      context,
      MeetMemberPage(
        MembersArguments(
          options: arguments.options!,
          roomInfoUpdatedEventStream: roomInfoUpdatedEventStream.stream,
        ),
      ),
    );
  }

  Future<dynamic> _initBeauty() async {
    var result =
    await inRoomService.getInRoomBeautyController().enableBeauty(true);
    if (result.isSuccess()) {
      var level =
      await inRoomService.getInRoomBeautyController().getBeautyFaceValue();
      beautyLevel = level.data!;
      await inRoomService.getInRoomBeautyController().setBeautyFaceValue(beautyLevel);
    }
  }

  void _onBeauty() {
    trackPeriodicEvent(TrackEventName.beauty,
        extra: {'meeting_id': arguments.meetingId});
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => SliderWidget(
          onChange: (value) async {
            await inRoomService
                .getInRoomBeautyController()
                .setBeautyFaceValue(value);
            beautyLevel = value;
          },
          level: beautyLevel,
        ));
  }

  void _onInvite() {
    trackPeriodicEvent(TrackEventName.invite,
        extra: {'meeting_id': arguments.meetingId});
    DialogUtils.showInviteDialog(context, _buildInviteInfo());
  }

  String _buildInviteInfo() {
    var info = '${UIStrings.inviteTitle}';

    final roomInfo = inRoomService.getCurrentRoomInfo()!;
    info += '${UIStrings.meetingSubject}${roomInfo.subject}\n';
    if (roomInfo.type == NERoomType.schedule) {
      info +=
      '${UIStrings.meetingTime}${roomInfo.scheduleStartTime.formatToTimeString('yyyy/MM/dd HH:mm')} - ${roomInfo.scheduleEndTime.formatToTimeString('yyyy/MM/dd HH:mm')}\n';
    }

    info += '\n';
    if (!arguments.options!.isShortMeetingIdEnabled ||
        TextUtils.isEmpty(roomInfo.shortRoomId)) {
      info +=
      '${UIStrings.meetingID}${roomInfo.roomId.toMeetingIdFormat()}\n';
    } else if (!arguments.options!.isLongMeetingIdEnabled) {
      info += '${UIStrings.meetingID}${roomInfo.shortRoomId}\n';
    } else {
      info +=
      '${UIStrings.shortMeetingID}${roomInfo.shortRoomId}(${UIStrings.internalSpecial})\n';
      info +=
      '${UIStrings.meetingID}${roomInfo.roomId.toMeetingIdFormat()}\n';
    }
    if (!TextUtils.isEmpty(roomInfo.password)) {
      info += '${UIStrings.meetingPwd}${roomInfo.password}\n';
    }
    if (!TextUtils.isEmpty(roomInfo.sipCid)) {
      info += '\n';
      info += '${UIStrings.sipID}${roomInfo.sipCid}\n';
    }
    return info;
  }

  Widget buildBigNameView(String? name) {
    return Container(
      color: UIColors.grey_292933,
      child: Center(
        child: Text(
          name ?? '',
          style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget buildSmallNameView(String? name) {
    return Container(
        color: UIColors.color_292933,
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
    var temp = userList.map((user) => user.userId).toList()
      ..remove(inRoomService.getMyUserId())
      ..insert(0, inRoomService.getMyUserId())
      ..remove(getScreenShareUserId());
    var start = (MeetingConfig().pageSize) * (page - 1);
    if (start >= temp.length) {
      return [];
    }
    return temp.sublist(
        start, min(start + MeetingConfig().pageSize, temp.length));
  }

  bool isHost() {
    return inRoomService.isMySelfHost();
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
        ToastUtils.showToast(context, Strings.joinMeetingFail);
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
    inRoomService
      ..removeListener(this)
      ..removeRoomLifeCycleObserver(this)
      ..removeRtcDeviceEventListener(this);
    roomInfoUpdatedEventStream.close();
    restorePreferredOrientations();
    InMeetingService()._updateHistoryMeetingItem(historyMeetingItem);
    InMeetingService()._serviceCallback = null;
    InMeetingService()._audioDelegate = null;
    joinTimeOut?.cancel();
    cancelInComingTips();
    Wakelock.disable().catchError((e) {
      Alog.d(tag: _tag, moduleName: _moduleName, content: 'Wakelock error $e');
    });
    if (Platform.isAndroid) {
      NEMeetingPlugin().getNotificationService().stopForegroundService();
    }
    // 在后台的时候由于各种原因从会议中退出，需要对应的销毁Activity
    // 且下次不能再次发送销毁的消息
    if (SchedulerBinding.instance!.lifecycleState !=
        AppLifecycleState.resumed) {
      EventBus().emit(UIEventName.flutterEngineCanRecycle);
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
  }

  void restorePreferredOrientations() {
    if (arguments.restorePreferredOrientations != null) {
      SystemChrome.setPreferredOrientations(
          [...arguments.restorePreferredOrientations!]);
    }
  }

  @override
  void onRoomLockStatusChanged(bool isLock) {}

  TransformationController? _screenShareController;
  bool _screenShareInteractionTipShown = false;
  int _screenShareWidth = 0, _screenShareHeight = 0;
  Orientation? _screenOrientation;

  void _setupScreenShareInteraction() {
    if (!_screenShareInteractionTipShown) {
      _screenShareInteractionTipShown = true;
      _showToast(Strings.screenShareInteractionTip);
    }
    _screenShareController ??= TransformationController();
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

  void _onScreenShareWillEnd() {
    _screenShareController = null;
  }

  ValueNotifier<bool>? _screenShareListenable;

  ValueNotifier<bool> get screenShareListenable {
    _screenShareListenable ??= ValueNotifier(isSelfScreenSharing());
    return _screenShareListenable!;
  }

  ValueNotifier<bool>? _whiteBoardShareListenable;

  ValueNotifier<bool> get whiteBoardShareListenable {
    _whiteBoardShareListenable ??=
        ValueNotifier(isWhiteBoardSharingAndIsHost());
    return _whiteBoardShareListenable!;
  }
  /// update nick
  @override
  void onRoomUserNameChanged(String userId, String userName) {
    if (isSelf(userId)) {
      historyMeetingItem?.nickname = userName;
    }
    _onRoomInfoChanged();
  }

  @override
  void onRoomSilentModeChanged(bool inSilentMode) {
    final before = arguments.audioMute;
    var selfAudioStatus = inRoomService.getMyUserInfo()!.audioStatus;
    final now = arguments.audioMute = selfAudioStatus != NERoomAudioStatus.on;
    if (inSilentMode && !before && now) {
      ToastUtils.showToast(context, Strings.meetingHostMuteAllAudio);
    } else if (selfAudioStatus == NERoomAudioStatus.waitingOpen) {
      showOpenMicDialog();
    }
    _onRoomInfoChanged();
  }

  @override
  void onRoomChatMessageReceived(List<NEChatRoomMessage> message) {
    message.forEach((element) {
      _messageSource.append(element);
      if (ModalRoute.of(context)!.isCurrent &&
          !TextUtils.isEmpty(element.content)) {
        showInComingMessage(element);
      }
    });
  }

  @override
  void onRoomUserAudioStatusChanged(String userId, NERoomAudioStatus status) async {
    if (inRoomService.isMyself(userId)) {
      final beforeIsMute = arguments.audioMute;
      arguments.audioMute = status != NERoomAudioStatus.on;
      if (!beforeIsMute && status == NERoomAudioStatus.mutedByHost) {
        ToastUtils.showToast(context, Strings.meetingHostMuteAudio);
      } else if (status == NERoomAudioStatus.waitingOpen) {
        showOpenMicDialog();
      }
    }
    _onRoomInfoChanged();
  }

  void showOpenMicDialog() async {
    if (!_isShowOpenMicroDialog) {
      _isShowOpenMicroDialog = true;
      await DialogUtils.showOpenAudioDialog(
          context, Strings.openMicro, Strings.hostOpenMicroTips, () {
        Navigator.of(context).pop();
      }, () {
        Navigator.of(context).pop();
        _muteMyAudio(false);
      });
      _isShowOpenMicroDialog = false;
    }
  }

  @override
  void onRoomUserVideoStatusChanged(
      String userId, NERoomVideoStatus status) async {
    trackPeriodicEvent(
      status == NERoomVideoStatus.on
          ? TrackEventName.memberVideoStart
          : TrackEventName.memberVideoStop,
      extra: {'member_uid': userId, 'meeting_id': arguments.meetingId},
    );

    if (inRoomService.isMyself(userId)) {
      if (status == NERoomVideoStatus.mutedByHost) {
        ToastUtils.showToast(context, Strings.meetingHostMuteVideo);
      } else if (status == NERoomVideoStatus.waitingOpen &&
          !_isShowOpenVideoDialog) {
        _isShowOpenVideoDialog = true;
        final agree = await DialogUtils.showOpenVideoDialog(
            context, Strings.openCamera, Strings.hostOpenCameraTips, () {
          Navigator.of(context).pop(false);
        }, () {
          Navigator.of(context).pop(true);
        });
        _isShowOpenVideoDialog = false;
        _muteMyVideo(agree != true);
      }

      arguments.videoMute = status != NERoomVideoStatus.on;
    }
    _onRoomInfoChanged();
  }

  /// control focus
  @override
  void onRoomUserVideoPinStatusChanged(String userId, bool isPinned) {
    if (isPinned) {
      focusUid = userId;
    } else if (userId == focusUid) {
      focusUid = null;
    }
    if (isPinned && isSelf(focusUid)) {
      ToastUtils.showToast(context, Strings.yourChangeFocus);
    }
    _onRoomInfoChanged();
  }

  @override
  void onRoomHostChanged(String userId) {
    hostUid = userId;
    if (isSelf(hostUid)) {
      ToastUtils.showToast(context, Strings.yourChangeHost);
    }
    _onRoomInfoChanged();
  }

  @override
  void dispose() {
    _dispose();
    if (!_isMinimized && !_hasRequestEngineToDetach) {
      EventBus().emit(UIEventName.flutterEngineCanRecycle);
    }
    AppStyle.setStatusBarTextBlackColor();
    super.dispose();
  }

  /// 被踢出, 没有操作3秒自动退出
  void onKicked() {
    var countDown = Timer(const Duration(seconds: 3), () {
      _onCancel(reason: 'onKicked ', exitCode: NEMeetingCode.removedByHost);
    });
    DialogUtils.showChildNavigatorDialog(
        context,
        CupertinoAlertDialog(
          title: Text(Strings.notify),
          content: Text(Strings.hostKickedYou),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text(Strings.sure),
                onPressed: () {
                  countDown.cancel();
                  _onCancel(
                      reason: 'onKicked ', exitCode: NEMeetingCode.removedByHost);
                })
          ],
        ));
  }

  void setupChatRoom() async {
    if (_isMenuItemShowing(NEMenuIDs.chatroom)) {
      var result = await inRoomService.getInRoomChatController()
          .enterChatRoom();
      if (!result.isSuccess()) {
        /// 聊天室进入失败
        ToastUtils.showToast(context, Strings.enterChatRoomFail);
      } else {
        lifecycleListen(_messageSource.unreadStream, (dynamic event) {
          setState(() {});
        });
      }
    }
  }

  /// 提示聊天室接受消息
  void showInComingMessage(NEChatRoomMessage chatRoomMessage) {
    // 聊天菜单不显示时，不出现聊天气泡
    if (!_isMenuItemShowing(NEMenuIDs.chatroom)) {
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
                        UIColors.grey_292933,
                        UIColors.color_212129
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
                    buildHead(chatRoomMessage.chatRoomUserInfo.nick),
                    SizedBox(width: 8),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              buildName(chatRoomMessage.chatRoomUserInfo.nick),
                              buildContent(chatRoomMessage.content)
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
                  colors: <Color>[UIColors.blue_5996FF, UIColors.blue_2575FF]),
              shape: Border()),
          alignment: Alignment.center,
          child: Text(
            nick?.substring(0, 1) ?? '',
            style: TextStyle(
                fontSize: 21, color: Colors.white, decoration: TextDecoration.none),
          ),
        ));
  }

  Widget buildName(String? nick) {
    return Text(
      '${nick ?? ''}说',
      style: TextStyle(
          color: UIColors.greyCCCCCC,
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
          color: UIColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.none),
    );
  }

  void _onSwitchLoudspeaker() {
    Alog.i(tag: _tag, moduleName: _moduleName, content: '_onSwitchLoudspeaker');
    setState(() {
      inRoomService.getInRoomAudioController().setMyLoudSpeakerOn(isEarpiece() ? true : false);
    });
  }

  void _onSwitchCamera() async {
    final result = await _onSyncSwitchCamera();
    if (result) {
      setState(() {
        _frontCamera = !_frontCamera;
      });
    }
  }

  Future<bool> _onSyncSwitchCamera() {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: '_onSwitchCamera _frontCamera: $_frontCamera');
    return inRoomService.getInRoomVideoController().switchCamera();
  }

  @override
  void onRoomUserJoin(List<NEInRoomUserInfo> userList) {
    for (var user in userList) {
      final isVisible = !RoleType.isHide(user.roleType);
      if (isHost() && isVisible) {
        ToastUtils.showToast(context, '${(user.displayName)}加入会议');
      }
      if (isVisible && autoSubscribeAudio) {
        inRoomService.getInRoomAudioController().subscribeRemoteAudioStream(user.userId);
      }
    }
    _onRoomInfoChanged();
  }

  String truncate(String str) {
    return '${str.substring(0, min(str.length, 10))}${((str.length) > 10 ? "..." : "")}';
  }

  @override
  void onRoomUserLeave(List<NEInRoomUserInfo> userList) {
    userList.forEach((user) {
      trackPeriodicEvent(TrackEventName.memberLeaveMeeting,
          extra: {'member_uid': user.userId, 'meeting_id': arguments.meetingId});
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content: 'onUserLeave ${user.displayName}');
      if (isHost() && !RoleType.isHide(user.roleType)) {
        ToastUtils.showToast(context, '${user.displayName}离开会议');
      }
      if (activeUid == user.userId) {
        activeUid = null;
        _determineActiveUser();
      }
    });
    _onRoomInfoChanged();
  }

  void notifyRoomInfoUpdatedEvent() {
    roomInfoUpdatedEventStream.add(const Object());
  }

  void _determineActiveUser() {
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
      if (curVolume > MeetingConfig.volumeLowThreshold &&
          curVolume > maxVolume) {
        maxVolume = curVolume;
        maxVolumeUserId = item.userId;
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
    roomInfoUpdatedEventStream.add(const Object());
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
      bigUid = users.first.userId;
      smallUid = null;
    } else if (users.length >= 2) {
      final screenSharingUid = getScreenShareUserId();
      final selfUid = inRoomService.getMyUserId();
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

    if (oldFocus != focusUid || oldActive != activeUid
        || oldBig != bigUid || oldSmall != smallUid) {
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content:
          'BigSmall: focus=$focusUid active=$activeUid host=$hostUid big=$bigUid small=$smallUid');
    }
  }

  String _pickRoomUid(Iterable<NEInRoomUserInfo> users) {
    // active > host > joined
    if (activeUid != null) {
      return activeUid!;
    }
    final hostUid = inRoomService.getHostUserId()!;
    if (!inRoomService.isMySelfHost()
        && inRoomService.getUserInfoById(hostUid) != null) {
        // 主持人在这个会议中
        return hostUid;
    }
    String? userId;
    for (var user in users) {
      if (!isSelf(user.userId)) {
        userId ??= user.userId;
        if (user.videoStatus == NERoomVideoStatus.on) {
          return user.userId;
        }
      }
    }
    return userId!;
  }

  @override
  void onAudioDeviceChanged(int selected) {
    Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content: 'onAudioDeviceChanged selected=$selected');
    setState(() {
      _audioDeviceSelected = selected;
    });
  }

  @override
  void onAudioDeviceStateChange(int deviceType, int deviceState) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content:
        'onAudioDeviceStateChange deviceType=$deviceType deviceState=$deviceState');
    if (deviceState == NERtcAudioDeviceState.initializationError ||
        deviceState == NERtcAudioDeviceState.startError ||
        deviceState == NERtcAudioDeviceState.unknownError) {
      ToastUtils.showToast(context, Strings.audioStateError);
    }
  }

  @override
  void onVideoDeviceStageChange(int deviceState) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'onVideoDeviceStageChange deviceState=$deviceState');
  }

  @override
  void onFirstFrameRendered(String uid) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'onFirstFrameRendered uid=$uid');
  }

  @override
  void onFrameResolutionChanged(String uid, int width, int height, int rotation) {
    Alog.i(
      tag: _tag,
      moduleName: _moduleName,
      content:
      'onFrameResolutionChanged uid=$uid width=$width height=$height rotation=$rotation',);
    if (uid == getScreenShareUserId()
        && _screenShareController != null
        && (_screenShareWidth != width || _screenShareHeight != height)) {
      _screenShareWidth = width;
      _screenShareHeight = height;
      _screenShareController!.value = Matrix4.identity();
    }
  }

  @override
  Future<NEResult<void>> subscribeAllRemoteAudioStreams(bool subscribe) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'subscribeAllRemoteAudioStreams subscribe=$subscribe');
    autoSubscribeAudio = subscribe == true;
    userList.forEach((user) {
      if (subscribe) {
        inRoomService.getInRoomAudioController().subscribeRemoteAudioStream(user.userId);
      } else {
        inRoomService.getInRoomAudioController().unsubscribeRemoteAudioStream(user.userId);
      }
    });
    return Future.value(NEResult(code: RoomErrorCode.success));
  }

  @override
  Future<NEResult<void>> startAudioDump() {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'startAudioDump ');
    inRoomService.getInRoomAudioController().startAudioDump();
    return Future.value(NEResult(code: RoomErrorCode.success));
  }

  @override
  Future<NEResult<void>> stopAudioDump() {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'stopAudioDump ');
    inRoomService.getInRoomAudioController().stopAudioDump();
    return Future.value(NEResult(code: RoomErrorCode.success));
  }

  @override
  Future<NEResult<List<String>>> subscribeRemoteAudioStreams(
      List<String> userList, bool subscribe) {
    Alog.i(
      tag: _tag,
      moduleName: _moduleName,
      content:
      'subscribeRemoteAudioStreams accountIds=${userList.toString()} subscribe=$subscribe',);
    if (userList.contains(inRoomService.getMyUserId())) {
      return Future.value(
        NEResult(
          code: RoomErrorCode.paramsError,
          msg: Strings.cannotSubscribeSelfAudio,
        ),
      );
    }
    final unknownUserList = userList
        .where((userId) => inRoomService.getUserInfoById(userId) == null)
        .toList();
    if (unknownUserList.isNotEmpty) {
      return Future.value(
        NEResult(
            code: RoomErrorCode.memberNotInRoom,
            msg: Strings.partMemberNotInMeeting,
            data: unknownUserList),
      );
    } else {
      userList.forEach((uid) {
        inRoomService.getInRoomAudioController().subscribeRemoteAudioStream(uid);
      });
      return Future.value(NEResult(code: RoomErrorCode.success));
    }
  }

  @override
  Future<NEResult<void>> subscribeRemoteAudioStream(String userId, bool subscribe) {
    var audioController = inRoomService.getInRoomAudioController();
    return subscribe
        ? audioController.subscribeRemoteAudioStream(userId)
        : audioController.unsubscribeRemoteAudioStream(userId);
  }

  void changeToolBarStatus() {
    if (appBarAnimController.status == AnimationStatus.completed) {
      appBarAnimController.reverse();
    } else if (appBarAnimController.status == AnimationStatus.dismissed) {
      appBarAnimController.forward();
    }
  }

  void createHistoryMeetingItem() {
    if (historyMeetingItem == null) {
      final roomInfo = inRoomService.getCurrentRoomInfo()!;
      final self = inRoomService.getMyUserInfo()!;
      historyMeetingItem = NEHistoryMeetingItem(
        meetingUniqueId: roomInfo.uniqueId,
        meetingId: roomInfo.roomId,
        shortMeetingId: roomInfo.shortRoomId,
        subject: roomInfo.subject,
        password: roomInfo.password,
        nickname: self.displayName,
        sipId: roomInfo.sipCid,
      );
    }
  }

  @override
  NEMeetingInfo? getCurrentMeetingInfo() {
    final roomInfo = inRoomService.getCurrentRoomInfo();
    if (roomInfo != null) {
      return NEMeetingInfo(
        meetingUniqueId: roomInfo.uniqueId,
        meetingId: roomInfo.roomId,
        shortMeetingId: roomInfo.shortRoomId,
        sipCid: roomInfo.sipCid,
        type: roomInfo.type,
        subject: roomInfo.subject,
        password: roomInfo.password,
        startTime: arguments.createTime * 1000,
        duration: arguments.joinmeetingInfo.duration * 1000
            + DateTime.now().millisecondsSinceEpoch - arguments.requestTimeStamp,
        scheduleStartTime: roomInfo.scheduleStartTime,
        scheduleEndTime: roomInfo.scheduleEndTime,
        isHost: inRoomService.isMySelfHost(),
        isLocked: inRoomService.isRoomLocked(),
        hostUserId: roomInfo.hostUserId,
        userList: userList
            .map((e) => NEInMeetingUserInfo(e.userId, e.displayName, e.tag))
            .toList(growable: false),
      );
    }
    return null;
  }

  @override
  void onConnected() {
    Alog.i(
      tag: _tag,
      moduleName: _moduleName,
      content: 'onConnected elapsed=${DateTime.now().millisecondsSinceEpoch - meetingBeginTime}ms',
    );
    _meetingState = MeetingState.joined;
    InMeetingService()._serviceCallback = this;
    InMeetingService()._audioDelegate = this;
    createHistoryMeetingItem();
    MeetingCore().notifyStatusChange(NEMeetingStatus(NEMeetingEvent.inMeeting));
    correctionAudioAndVideo();

    joinTimeOut?.cancel();

    inRoomService
        .getInRoomAudioController()
        .enableAudioVolumeIndication(true, 2000);

    /// Android 显示前台服务通知
    if (Platform.isAndroid) {
      NEMeetingPlugin()
          .getNotificationService()
          .startForegroundService(MeetingCore().foregroundConfig);
    }

    setupChatRoom();
    if (arguments.defaultWindowMode == WindowMode.whiteBoard.value) {
      unawaited(_onWhiteBoard());
    }
    _initBeauty();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void onConnecting() {
    MeetingCore().notifyStatusChange(NEMeetingStatus(NEMeetingEvent.connecting));
  }

  @override
  void onConnectFail(int reason) {
    if (_isAlreadyCancel) return;
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'onConnectFail reason=$reason');
    switch (reason) {
      case NERoomConnectFailReason.roomNotExist:
        _onCancel(exitCode: NEMeetingCode.roomNotExist, reason: 'roomNotExist');
        break;
      case NERoomConnectFailReason.syncDataError:
        _onCancel(exitCode: NEMeetingCode.syncDataError, reason: 'syncDataError');
        break;
      case NERoomConnectFailReason.rtcInitError:
        _onCancel(exitCode: NEMeetingCode.rtcInitError, reason: 'rtcInitError');
        break;
      case NERoomConnectFailReason.joinChannelError:
        _onCancel(exitCode: NEMeetingCode.joinChannelError, reason: 'joinChannelError');
        break;
    }
  }

  @override
  void onDisconnected(int reason) {
    if (_meetingState.index >= MeetingState.closing.index) {
      return;
    }
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'onDisconnect reason=$reason');
    switch (reason) {
      case NERoomDisconnectReason.closeByHost:
        _onCancel(exitCode: NEMeetingCode.closeByHost, reason: 'closeByHost');
        break;
      case NERoomDisconnectReason.closeBySelf:
        _onCancel(exitCode: NEMeetingCode.closeBySelfAsHost, reason: 'closeBySelfAsHost');
        break;
      case NERoomDisconnectReason.removedByHost:
        onKicked();
        break;
      case NERoomDisconnectReason.loginOnOtherDevice:
        _onCancel(exitCode: NEMeetingCode.loginOnOtherDevice, reason: 'loginOnOtherDevice');
        break;
      case NERoomDisconnectReason.authInfoExpired:
        _onCancel(exitCode: NEMeetingCode.authInfoExpired, reason: 'authInfoExpired');
        break;
      case NERoomDisconnectReason.leaveBySelf:
        _onCancel(exitCode: NEMeetingCode.self, reason: 'bySelf');
        break;
      default:
        ToastUtils.showToast(context, Strings.networkNotStable);
        _onCancel();
        break;
    }
  }

  @override
  void onDisconnecting() {
    // TODO: implement onDisconnecting
  }

  @override
  void onIdle() {
    // TODO: implement onIdle
  }

  /// ****************** InRoomServiceListener ******************

  @override
  void onRoomUserScreenShareStatusChanged(
      String userId, NERoomScreenShareStatus status) {
    trackPeriodicEvent(
        status == NERoomScreenShareStatus.start
            ? TrackEventName.memberScreenShareStart
            : TrackEventName.memberScreenShareStop,
        extra: {'member_uid': userId, 'meeting_id': arguments.meetingId});

    if (inRoomService.isMyself(userId)) {
      if (status == NERoomScreenShareStatus.stopByHost) {
        ToastUtils.showToast(context, Strings.hostStopShare);
      }
      screenShareListenable.value = isSelfScreenSharing();
    } else {
      if (status == NERoomScreenShareStatus.start) {
        _setupScreenShareInteraction();
      } else if (status == NERoomScreenShareStatus.end) {
        _onScreenShareWillEnd();
      }
    }
    _onRoomInfoChanged();
  }

  /// 房间成员白板共享状态变更回调
  @override
  void onRoomUserWhiteBoardShareStatusChanged(
      String userId, NERoomWhiteBoardShareStatus status) {
    if (isSelf(userId) && status == NERoomWhiteBoardShareStatus.stopByHost) {
      ToastUtils.showToast(context, Strings.hostStopShare);
    }
    setState(() {
      whiteBoardShareListenable.value = isSelfWhiteBoardSharing();
    });
    _onRoomInfoChanged();
  }

  @override
  void onRoomUserWhiteBoardInteractionStatusChanged(
      String userId, bool enable) {
    ///本地只关心local 是否有权限
    if (!isSelf(userId)) return;
    whiteBoardInteractionStatusNotifier.value = enable;
    if (isWhiteBoardSharing() && !isSelfWhiteBoardSharing()) {
      _showToast(enable
          ? Strings.whiteBoardInteractionTip
          : Strings.undoWhiteBoardInteractionTip);
    }
    if (enable) {
      appBarAnimController.forward();
    } else {
      appBarAnimController.reverse();
    }
    _onRoomInfoChanged();
  }

  @override
  void onRoomRaiseHandStatusChanged(String userId, NERaiseHandDetail raiseHandDetail) {
    if (isSelf(userId)) {
      switch (raiseHandDetail.status) {
        case NEHandsUpStatus.downByHost:
          ToastUtils.showToast(context, Strings.hostRejectAudioHandsUp);break;
        case NEHandsUpStatus.agree:
          ToastUtils.showToast(context, Strings.hostAgreeAudioHandsUp);break;
      }
    }
    _onRoomInfoChanged();
  }

  List<NERoomUserAudioVolumeInfo>? volumeList;
  @override
  void onRoomRemoteAudioVolumeIndication(List<NERoomUserAudioVolumeInfo> volumeList, int totalVolume) {
    this.volumeList = volumeList;
    _determineActiveUser();
  }

  Future<void> correctionAudioAndVideo() async {
    if (inRoomService.getMyUserInfo()!.audioStatus == NERoomAudioStatus.on) {
      var permissionGranted = await _enableLocalAudioAndCheckPermission(true);
      if (!permissionGranted) {
        await inRoomService.getInRoomAudioController().muteMyAudio(true);
      }
      await inRoomService.getInRoomAudioController().syncLocalAudioStatus();
    }

    if (inRoomService.getMyUserInfo()!.videoStatus == NERoomVideoStatus.on) {
      var permissionGranted = await _enableLocalVideoAndCheckPermission(true);
      if (!permissionGranted) {
        await inRoomService.getInRoomVideoController().muteMyVideo(true);
      }
      await inRoomService.getInRoomVideoController().syncLocalVideoStatus();
    }
  }
}
