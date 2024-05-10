// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingWaitingRoomPage extends StatefulWidget {
  static const routeName = 'meeting_waiting_room';

  final MeetingArguments arguments;

  MeetingWaitingRoomPage(this.arguments);

  @override
  State<StatefulWidget> createState() =>
      _MeetingWaitingRoomPageState(arguments);
}

class _MeetingWaitingRoomPageState extends BaseState<MeetingWaitingRoomPage>
    with
        _AloggerMixin,
        NEWaitingRoomListener,
        MeetingKitLocalizationsMixin,
        MeetingStateScope,
        MeetingNavigatorScope,
        FirstBuildScope {
  late final NERoomContext roomContext;
  late final MeetingInfo meetingInfo;
  late NEMeetingState meetingState;
  late bool showChatroomEntrance = false;
  late bool audioMute, videoMute;
  MeetingArguments arguments;

  late final NERoomEventCallback roomCallback;
  late ChatRoomMessageSource _messageSource;
  SDKConfig? crossAppSDKConfig;

  _MeetingWaitingRoomPageState(this.arguments);
  NEHistoryMeetingItem? historyMeetingItem;
  final streamSubscriptions = <StreamSubscription>[];

  /// 画中画判断
  final floating = NEMeetingPlugin().getFloatingService();
  ValueNotifier<bool> _isInPIPView = ValueNotifier(false);

  int? disconnectingCode;

  StreamSubscription? _roomEndStreamSubscription;
  StreamSubscription? _waitingRoomStatusSubscription;

  @override
  void initState() {
    super.initState();
    MeetingCore()
        .notifyStatusChange(NEMeetingStatus(NEMeetingEvent.inWaitingRoom));
    roomContext = widget.arguments.roomContext;
    meetingInfo = widget.arguments.meetingInfo;
    meetingState = meetingInfo.state;
    audioMute = widget.arguments.initialAudioMute;
    videoMute = widget.arguments.initialVideoMute;
    roomContext.addEventCallback(roomCallback = NERoomEventCallback(
      chatroomMessagesReceived: chatroomMessagesReceived,
    ));
    roomContext.waitingRoomController.addListener(this);
    NEMeetingKit.instance
        .getPreMeetingService()
        .registerScheduleMeetingStatusChange(onMeetingStatusChange);
    handleToggleVideoPreview();

    _messageSource = ChatRoomMessageSource(
        sdkConfig: sdkConfig,
        chatroomConfig:
            arguments.options.chatroomConfig ?? NEMeetingChatroomConfig());
    createHistoryMeetingItem();
    handleAppLifecycleChangeEvent();
    _isInPIPView = ValueNotifier(widget.arguments.initialIsInPIPView);
  }

  void handleAppLifecycleChangeEvent() {
    var subscription = NEAppLifecycleDetector()
        .onBackgroundChange
        .listen((isInBackground) async {
      if (!mounted) return;
      commonLogger.i(
        'Handle WaitingRoom lifecycle: background=$isInBackground',
      );
      if (isInBackground && videoPreviewStarted) {
        await roomContext.rtcController.stopPreview();
        commonLogger.i(
            'Handle WaitingRoom lifecycle: in background and close video: $videoMute $isInBackground');
      }
      if (!isInBackground && videoPreviewStarted) {
        final permissionGranted = await ensureCameraPermission();
        if (mounted && permissionGranted) {
          final result = await roomContext.rtcController.startPreview();
          commonLogger
              .i('Handle App lifecycle: open video automatically $result');
        }
      }
      // if (!isInBackground && disconnectingCode != null) {
      //   commonLogger
      //       .i('Handle App lifecycle: room end and close automatically');
      //   MeetingUIRouter.pop(context, disconnectingCode: disconnectingCode);
      // }
    });
    streamSubscriptions.add(subscription);
  }

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

  bool get isChatSupport =>
      !arguments.noChat &&
      roomContext.chatController.isSupported &&
      meetingState == NEMeetingState.started;

  @override
  void onFirstBuild() {
    setupChatRoom();
  }

  void setupChatRoom() async {
    if (!showChatroomEntrance && isChatSupport) {
      meetingUIState.waitingRoomChatroom.join().then((value) {
        if (!mounted) return;
        commonLogger.i('waitingRoom join chatroom success: $value');
        if (value.isSuccess()) {
          setState(() {
            showChatroomEntrance = true;
          });
          chatRoomManager.hasJoinWaitingRoomChatroom = () => true;
        } else if (value.code != NEMeetingErrorCode.chatroomNotExists) {
          showToast(NEMeetingUIKitLocalizations.of(context)!.chatJoinFail);
        }
      });
    }
  }

  void chatroomMessagesReceived(List<NERoomChatMessage> message) {
    message.forEach((msg) {
      if (!_messageSource.handleReceivedMessage(msg)) {
        commonLogger.i(
            'waitingRoom chatroomMessagesReceived: unsupported message type of ${msg.runtimeType}');
      }
    });
  }

  bool hasCleanup = false;
  void cleanup() {
    if (hasCleanup) return;
    hasCleanup = true;
    roomContext
      ..removeEventCallback(roomCallback)
      ..waitingRoomController.removeListener(this);
    if (videoPreviewStarted) {
      roomContext.rtcController.stopPreview();
    }
    NEMeetingKit.instance
        .getPreMeetingService()
        .unRegisterScheduleMeetingStatusChange(onMeetingStatusChange);
    crossAppSDKConfig?.dispose();
    InMeetingService()._updateHistoryMeetingItem(historyMeetingItem);
  }

  @override
  void dispose() {
    streamSubscriptions.forEach((subscription) {
      subscription.cancel();
    });
    _roomEndStreamSubscription?.cancel();
    _waitingRoomStatusSubscription?.cancel();
    _chatRoomManager?.dispose();
    cleanup();
    super.dispose();
  }

  void onAdmittedToMeeting(int status) {
    _rejoinAfterAdmittedToRoom().then((value) {
      if (!mounted) return;
      if (!value) {
        meetingNavigator.pop();
      }
      cleanup();
    });
  }

  Future<bool> _rejoinAfterAdmittedToRoom() async {
    final meetingInfoResult =
        await MeetingRepository.getMeetingInfo(roomContext.meetingNum);
    if (!meetingInfoResult.isSuccess() || meetingInfoResult.data == null)
      return false;
    final result = await roomContext.rejoinAfterAdmittedToRoom();
    if (!mounted) return false;
    commonLogger.i('rejoinAfterAdmittedToRoom: $result');
    if (videoPreviewStarted) {
      roomContext.rtcController.stopPreview();
    }
    final success = result.isSuccess();
    if (!_isInPIPView.value) {
      meetingUIState.isMinimized = false;
    }
    if (success) {
      meetingNavigator.navigateToInMeetingFromWaitingRoom(
          arguments: widget.arguments.copyWith(
        initialAudioMute: audioMute,
        initialVideoMute: videoMute,
        meetingInfo: meetingInfoResult.data!,
      ));
    } else {
      showToast(result.msg ?? meetingUiLocalizations.meetingJoinFail);
    }
    return success;
  }

  @override
  void onMemberNameChanged(String member, String name) {
    if (member == roomContext.myUuid) {
      historyMeetingItem?.nickname = name;
      InMeetingService()._updateHistoryMeetingItem(historyMeetingItem);
      setState(() {});
    }
  }

  void onMeetingStatusChange(List<NEMeetingItem> items, _) {
    for (var item in items) {
      if (item.meetingId == meetingInfo.meetingId) {
        setState(() {
          meetingState = item.state;
          setupChatRoom();
        });
        return;
      }
    }
  }

  void handleRoomEnd(NERoomEndReason reason) {
    if (disconnectingCode != null) return;
    disconnectingCode = NEMeetingCode.undefined;
    switch (reason) {
      case NERoomEndReason.kKickBySelf:
        disconnectingCode = NEMeetingCode.loginOnOtherDevice;
        break;
      case NERoomEndReason.kKickOut:
        disconnectingCode = NEMeetingCode.removedByHost;
        if (!_isInPIPView.value) {
          showEndDialog(
            meetingUiLocalizations.meetingBeKickedOut,
            meetingUiLocalizations.meetingBeKickedOutByHost,
            meetingUiLocalizations.globalClose,
            NEMeetingCode.removedByHost,
          );
        } else {
          setState(() {});
        }
        return;
      case NERoomEndReason.kCloseByMember:
      case NERoomEndReason.kCloseByBackend:
      case NERoomEndReason.kAllMemberOut:
        disconnectingCode = NEMeetingCode.closeByHost;
        break;
      case NERoomEndReason.kLeaveBySelf:
        disconnectingCode = NEMeetingCode.self;
        break;
      case NERoomEndReason.kLoginStateError:
        disconnectingCode = NEMeetingCode.authInfoExpired;
        break;
      case NERoomEndReason.kSyncDataError:
        disconnectingCode = NEMeetingCode.syncDataError;
        break;
      case NERoomEndReason.kEndOfLife:
        disconnectingCode = NEMeetingCode.endOfLife;
        break;
      case NERoomEndReason.kUnknown:
      case NERoomEndReason.kEndOfRtc:
        // do nothing
        break;
    }
    if (!_isInPIPView.value) {
      meetingNavigator.pop(disconnectingCode: disconnectingCode);
    } else {
      setState(() {});
    }
  }

  /// 会议结束弹窗
  void showEndDialog(
      String title, String message, String okText, int disconnectingCode) {
    DialogUtils.showOneButtonCommonDialog(
      context,
      title,
      message,
      () {
        meetingNavigator.pop(disconnectingCode: disconnectingCode);
      },
      acceptText: okText,
      canBack: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = PopScope(
      child: ValueListenableBuilder(
        valueListenable: _isInPIPView,
        builder: (_, bool isInPIPView, __) {
          return isInPIPView
              ? Container(
                  color: _UIColors.grey_292933,
                  child: Stack(fit: StackFit.expand, children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          disconnectingCode != null
                              ? meetingUiLocalizations.meetingWasInterrupted
                              : meetingUiLocalizations.movedToWaitingRoom,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    buildNameView(roomContext.myUuid),
                  ]),
                )
              : _buildBody();
        },
      ),
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _finishPage();
      },
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppStyle.systemUiOverlayStyleLight,
      child: child,
    );
  }

  @override
  void onAppLifecycleState(AppLifecycleState state) {
    if (!Platform.isIOS) {
      floating.pipStatus.then((value) {
        _isInPIPView.value = value == PiPStatus.enabled;
      });
    }
    if (state == AppLifecycleState.resumed) {
      meetingUIState.isMinimized = false;
      _isInPIPView.value = false;
      if (Platform.isIOS) {
        floating.disposePIP();
      }
    }

    /// 非小窗模式会议关闭状态
    if (_isInPIPView.value != true && disconnectingCode != null) {
      meetingNavigator.pop(disconnectingCode: disconnectingCode);
    }
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
      child: Row(
        children: [
          Expanded(child: SizedBox()),
          Text(
            widget.arguments.meetingTitle,
            style: TextStyle(
              color: _UIColors.white,
              fontSize: 17,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildLeave(), SizedBox(width: 16)],
          )),
        ],
      ),
    );
  }

  Widget buildNameView(String userId, {String? prefix, String? suffix}) {
    final user = roomContext.getMember(userId);
    String content =
        '${prefix ?? ''}${StringUtil.truncate(user?.name ?? '')}${suffix ?? ''}';
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        height: 21,
        margin: EdgeInsets.only(left: 12, bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
            color: Colors.black54,
            border: Border.all(color: Colors.transparent, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(2))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if ((user?.name ?? '').isNotEmpty)
              Flexible(
                  child: Container(
                      child: Text(content,
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w400)))),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // 会议组件在首次启动时，可能还没有size信息
    final size = MediaQuery.maybeSizeOf(context);
    final backgroundImageUrl = roomContext.waitingRoomController
        .getWaitingRoomInfo()
        .backgroundImageUrl;
    final hasBackground = backgroundImageUrl != null &&
        size != null &&
        size.width > 0 &&
        size.height > 0;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!hasBackground)
          Image(
            image: NEMeetingImages.assetImageProvider(
                NEMeetingImages.waitingRoomBackground),
            fit: BoxFit.cover,
          ),
        if (hasBackground)
          FadeInImage(
            placeholder: NEMeetingImages.assetImageProvider(
                NEMeetingImages.waitingRoomBackground),
            image: ResizeImage(
              NetworkImage(backgroundImageUrl),
              width: size.width.toInt(),
              height: size.height.toInt(),
              policy: ResizeImagePolicy.fit,
            ),
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 200),
            fadeOutDuration: const Duration(milliseconds: 10),
          ),
        SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(),
              SizedBox(height: 13),
              _buildNetworkNotice(),
              SizedBox(height: 10),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMeetingInfo(),
                      SizedBox(height: 40),
                      _buildSplit(),
                      SizedBox(height: 40),
                      _buildMeetingOptions(),
                    ],
                  ))
            ],
          ),
        ),
        if (showChatroomEntrance)
          Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: onChat,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    height: 42,
                    margin: EdgeInsets.only(bottom: 50),
                    decoration: BoxDecoration(
                        color: _UIColors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _circularNumberTipBuilder(
                                _messageSource.unreadMessageListenable)
                            .call(
                                context,
                                Icon(
                                  NEMeetingIconFont.icon_chat,
                                  size: 24,
                                  color: _UIColors.white,
                                )),
                        Text(
                          meetingUiLocalizations.chatMessage,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none),
                        )
                      ],
                    )),
              )),
        if (videoPreviewStarted) buildVideoPreview(),
      ],
    );
  }

  ChatRoomManager? _chatRoomManager;
  ChatRoomManager get chatRoomManager {
    _chatRoomManager ??= ChatRoomManager(roomContext);
    return _chatRoomManager!;
  }

  void onChat() {
    showMeetingPopupPageRoute(
        context: context,
        routeSettings: RouteSettings(name: MeetingChatRoomPage.routeName),
        builder: (context) {
          return MeetingChatRoomPage(
            arguments: ChatRoomArguments(
              roomContext: roomContext,
              messageSource: _messageSource,
              chatRoomManager: chatRoomManager,
            ),
          );
        });
  }

  Widget _buildSplit() {
    return Opacity(
        opacity: 0.2,
        child: Container(
          color: _UIColors.colorF2F3F5,
          height: 1,
        ));
  }

  Widget _buildMeetingInfo() {
    final localizations = NEMeetingUIKitLocalizations.of(context)!;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meetingState == NEMeetingState.started
                ? localizations.waitingRoomWaitHostToInviteJoinMeeting
                : localizations.waitingRoomWaitMeetingToStart,
            style: TextStyle(
                color: _UIColors.white,
                fontSize: 20,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 32),
          _buildMeetingInfoItem(NEMeetingIconFont.icon_meeting_info_title,
              '${localizations.meetingSubject}: ', meetingInfo.subject),
          SizedBox(height: 16),
          _buildMeetingInfoItem(
              NEMeetingIconFont.icon_meeting_info_time,
              '${localizations.meetingTime}: ',
              meetingInfo.startTime.formatToTimeString('yyyy.MM.dd HH:mm')),
          SizedBox(height: 16),
          _buildMeetingInfoItem(
              NEMeetingIconFont.icon_nickname,
              '${localizations.meetingNickname}: ',
              historyMeetingItem?.nickname ?? ''),
        ],
      ),
    );
  }

  Widget _buildMeetingInfoItem(IconData? icon, String title, String content) {
    const strutStyle = StrutStyle(
      fontSize: 16,
      height: 1.3,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            icon,
            size: 16,
            color: _UIColors.white.withOpacity(0.8),
          ),
          SizedBox(width: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _UIColors.white.withOpacity(0.8),
              fontSize: 16,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w400,
            ),
            strutStyle: strutStyle,
          ),
        ]),
        Expanded(
          child: Text(
            content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _UIColors.white,
              fontSize: 16,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w500,
            ),
            strutStyle: strutStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildLeave() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          width: 50,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: _UIColors.colorD93D35,
              borderRadius: BorderRadius.all(Radius.circular(13))),
          child: Text(NEMeetingUIKitLocalizations.of(context)!.meetingLeave,
              style: TextStyle(
                  color: _UIColors.white,
                  fontSize: 13,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400))),
      onTap: _finishPage,
    );
  }

  void _finishPage() {
    final localizations = NEMeetingUIKitLocalizations.of(context)!;
    DialogUtils.showChildNavigatorPopup<int>(
        context,
        (context) => CupertinoActionSheet(
              actions: <Widget>[
                Container(
                  height: 45,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    localizations.meetingLeaveConfirm,
                    style: TextStyle(
                        color: _UIColors.grey_8F8F8F,
                        fontSize: 13,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                _buildActionSheetItem(context, false,
                    localizations.meetingLeave, InternalMenuIDs.leaveMeeting),
              ],
              cancelButton: _buildActionSheetItem(context, true,
                  localizations.globalCancel, InternalMenuIDs.cancel),
            )).then<void>((int? itemId) async {
      if (mounted && itemId == InternalMenuIDs.leaveMeeting) {
        roomContext.leaveRoom();
        handleRoomEnd(NERoomEndReason.kLeaveBySelf);
      }
    });
  }

  Widget _buildActionSheetItem(
      BuildContext context, bool defaultAction, String title, int itemId,
      {Color textColor = _UIColors.color_007AFF}) {
    return CupertinoActionSheetAction(
        isDefaultAction: defaultAction,
        child: Text(title, style: TextStyle(color: textColor)),
        onPressed: () => Navigator.pop(context, itemId));
  }

  Widget _buildMeetingOptions() {
    final localizations = NEMeetingUIKitLocalizations.of(context)!;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
              opacity: 0.6,
              child: Text(
                localizations.waitingRoomJoinMeetingOption,
                style: TextStyle(
                    color: _UIColors.white,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400),
              )),
          SizedBox(height: 24),
          _buildOptionSwitch(
            localizations.waitingRoomTurnOnMicrophone,
            !audioMute,
            (value) {
              setState(() {
                audioMute = !value;
              });
            },
            key: MeetingUIValueKeys.switchMyMicrophone,
          ),
          SizedBox(height: 24),
          _buildOptionSwitch(
            localizations.waitingRoomTurnOnVideo,
            !videoMute,
            (value) {
              setState(() {
                videoMute = !value;
                handleToggleVideoPreview();
              });
            },
            key: MeetingUIValueKeys.switchMyCamera,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionSwitch(
      String title, bool value, ValueChanged<bool>? onChanged,
      {Key? key}) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: _UIColors.white,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        CupertinoSwitch(
          key: key,
          value: value,
          onChanged: (newValue) {
            onChanged?.call(newValue);
          },
          activeColor: _UIColors.blue_337eff,
          trackColor: _UIColors.colorD2D7DB,
        )
      ],
    );
  }

  MenuItemTipBuilder _circularNumberTipBuilder(
      ValueListenable<int> valueListenable,
      {int max = 99}) {
    return (context, anchor) => SafeValueListenableBuilder(
        valueListenable: valueListenable,
        builder: (_, int value, __) => Container(
              height: 32,
              width: 32,
              child: Stack(alignment: Alignment.centerLeft, children: <Widget>[
                anchor,
                if (value > 0)
                  Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 16,
                        width: 16,
                        decoration: ShapeDecoration(
                          color: _UIColors.colorFE3B30,
                          shape: CircleBorder(),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          child: Text(
                            value > max ? '$max+' : '$value',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ))
              ]),
            ));
  }

  final videoPreviewPaddings = ValueNotifier(EdgeInsets.zero);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vp = MediaQuery.of(context).viewPadding;
    videoPreviewPaddings.value = EdgeInsets.only(
      left: max(vp.left, 12),
      right: max(vp.right, 12),
      top: max(vp.top, 12),
      bottom: max(vp.bottom, 12),
    );
    _roomEndStreamSubscription ??=
        meetingLifecycleState.roomEndStream.listen(handleRoomEnd);
    _waitingRoomStatusSubscription ??=
        meetingLifecycleState.onAdmittedToMeeting.listen(onAdmittedToMeeting);
  }

  var videoPreviewAlignment = Alignment.bottomRight;
  bool videoPreviewStarted = false;
  void handleToggleVideoPreview() async {
    if (videoMute && videoPreviewStarted) {
      roomContext.rtcController.stopPreview();
      setState(() {
        videoPreviewStarted = false;
      });
    } else if (!videoMute) {
      final permissionGranted = await ensureCameraPermission();
      if (mounted && permissionGranted) {
        final startPreviewResult =
            await roomContext.rtcController.startPreview();
        if (mounted && startPreviewResult.isSuccess()) {
          setState(() {
            videoPreviewStarted = true;
          });
        }
      }
    }
  }

  Future<bool> ensureCameraPermission() async {
    return await Permission.camera.status == PermissionStatus.granted ||
        await PermissionHelper.requestPermissionSingle(
            context,
            Permission.camera,
            '',
            NEMeetingUIKitLocalizations.of(context)!.meetingCamera);
  }

  Widget buildVideoPreview() {
    return DraggablePositioned(
      // size: const Size(138.0, 243.0),
      size: const Size(92.0, 162.0),
      initialAlignment: videoPreviewAlignment,
      paddings: videoPreviewPaddings,
      pinAnimationDuration: const Duration(milliseconds: 500),
      pinAnimationCurve: Curves.easeOut,
      builder: (context) {
        return NERoomContextProvider(
          roomContext: roomContext,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(children: [
              NERoomUserVideoView(
                roomContext.myUuid,
                mirror: true,
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  // height: 13,
                  margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(2))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        audioMute
                            ? NEMeetingIconFont.icon_yx_tv_voice_offx
                            : NEMeetingIconFont.icon_yx_tv_voice_onx,
                        color: audioMute ? _UIColors.colorFE3B30 : Colors.white,
                        size: 12,
                      ),
                      Flexible(
                        child: Text(
                          roomContext.localMember.name,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        );
      },
      onPinStart: (alignment) {
        videoPreviewAlignment = alignment;
      },
    );
  }

  Widget _buildNetworkNotice() {
    return ConnectivityChangedBuilder(
        builder: (_, connected, __) => connected
            ? SizedBox.shrink()
            : Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                color: _UIColors.colorFFD8D6,
                child: Row(
                  children: [
                    Icon(
                      NEMeetingIconFont.icon_fail,
                      color: _UIColors.colorFB594F,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        NEMeetingUIKitLocalizations.of(context)!
                            .networkAbnormalityPleaseCheckYourNetwork,
                        style: TextStyle(
                          fontSize: 12,
                          color: _UIColors.colorED2E24,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
