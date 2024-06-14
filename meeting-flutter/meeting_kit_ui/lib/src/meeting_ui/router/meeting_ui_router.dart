// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingUIRouter extends StatefulWidget {
  final NERoomContext roomContext;
  final MeetingArguments arguments;

  MeetingUIRouter({
    super.key,
    required this.roomContext,
    required this.arguments,
  });

  @override
  State<MeetingUIRouter> createState() => _MeetingUIRouterState();
}

class _MeetingUIRouterState extends State<MeetingUIRouter> with _AloggerMixin {
  late final MeetingUINavigator uiNavigator;
  late final MeetingUIRouterDelegate routerDelegate;
  var disconnectingCode = NEMeetingCode.undefined;
  var hasRequestPop = false;

  String get logTag => 'MeetingUIRouter@$hashCode';

  @override
  void initState() {
    super.initState();
    commonLogger.i('initState');
    WakelockPlus.enable();
    uiNavigator = MeetingUINavigator()
      ..popHandler = pop
      ..initMeeting(widget.arguments);
    routerDelegate = MeetingUIRouterDelegate(uiNavigator);
  }

  late Route myselfRoute;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    myselfRoute = ModalRoute.of(context)!;
  }

  @override
  void dispose() {
    commonLogger.i('dispose');
    uiNavigator.dispose();
    routerDelegate.dispose();
    updateMeetingStatus();
    super.dispose();
  }

  void pop({Object? result, int? disconnectingCode}) {
    debugPrintStack(
        label:
            'Pop meeting ui router: isCurrent=${myselfRoute.isCurrent}, disconnectingCode=$disconnectingCode, frameEnabled=${WidgetsBinding.instance.framesEnabled}');
    assert(!hasRequestPop, 'Duplicated request pop meeting ui router');

    /// 如果是加入另外一个会议，不处理
    if (routerDelegate.joinAnotherMeeting) {
      routerDelegate.joinAnotherMeeting = false;
      return;
    }

    if (hasRequestPop) return;
    hasRequestPop = true;
    if (disconnectingCode != null) {
      this.disconnectingCode = disconnectingCode;
    }
    if (myselfRoute.isCurrent) {
      Navigator.of(context).pop(result);
    } else {
      Navigator.of(context).removeRoute(myselfRoute);
    }
    WakelockPlus.disable().catchError((e) {
      commonLogger.i('Wakelock error $e');
    });
    AppStyle.setSystemUIOverlayStyleDark();
    if (!WidgetsBinding.instance.framesEnabled) {
      /// 处于后台，则直接更新会议状态
      updateMeetingStatus();
    }
  }

  bool statusUpdated = false;
  void updateMeetingStatus() {
    if (statusUpdated) return;
    statusUpdated = true;
    MeetingCore().notifyStatusChange(
        NEMeetingStatus(NEMeetingEvent.disconnecting, arg: disconnectingCode));
    MeetingCore().notifyStatusChange(NEMeetingStatus(NEMeetingEvent.idle));
    EventBus().emit(NEMeetingUIEvents.flutterPageDisposed);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !(await routerDelegate.popRoute());
      },
      child: NEMeetingUIKitLocalizationsScope(
        child: Router(
          routerDelegate: routerDelegate,
        ),
      ),
    );
  }
}

class MeetingUIRouterDelegate extends RouterDelegate<Object>
    with
        PopNavigatorRouterDelegateMixin<Object>,
        ChangeNotifier,
        _AloggerMixin {
  @override
  GlobalKey<NavigatorState> get navigatorKey =>
      GlobalObjectKey(uiNavigator.roomContext);

  final MeetingUINavigator uiNavigator;

  /// 会议邀请事件回调
  EventCallback? callback;

  MeetingUIRouterDelegate(this.uiNavigator) {
    uiNavigator.addListener(notifyListeners);
    callback ??= (arg) {
      var meetingContext = NEMeetingUIKit.instance.getCurrentRoomContext();
      final CardData? cardData = arg.cardData;
      if (meetingContext != null && arg.type != InviteJoinActionType.reject) {
        handleEvent(cardData, arg.type == InviteJoinActionType.audioAccept);
      }
    };
    EventBus().subscribe(NEMeetingUIEvents.flutterInvitedChanged, callback!);
  }

  @override
  void dispose() {
    uiNavigator.removeListener(notifyListeners);
    EventBus().unsubscribe(NEMeetingUIEvents.flutterInvitedChanged, callback);
    super.dispose();
  }

  @override
  Future<void> setNewRoutePath(Object configuration) {
    return SynchronousFuture(null);
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator(
      key: navigatorKey,
      initialRoute: null,
      observers: [
        _LoggingNavigatorObserver(),
      ],
      onPopPage: _handlePopPagedRoute,
      pages: [
        if (!uiNavigator.isActive)
          MaterialPage(
            name: Navigator.defaultRouteName,
            key: ValueKey(Navigator.defaultRouteName),
            child: Builder(
              builder: (context) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    tileMode: TileMode.clamp,
                    colors: [_UIColors.grey_292933, _UIColors.grey_1E1E25],
                  ),
                ),
              ),
            ),
          ),
        if (uiNavigator.isInWaitingRoom)
          MaterialPage(
            name: _RouterName.waitingRoom,
            key: ValueKey((_RouterName.waitingRoom, uiNavigator.roomContext)),
            child: Builder(
              builder: (context) =>
                  MeetingWaitingRoomPage(uiNavigator.meetingArguments),
            ),
          ),
        if (uiNavigator.isInMeeting)
          MaterialPage(
            name: _RouterName.inMeeting,
            key: ValueKey((_RouterName.inMeeting, uiNavigator.roomContext)),
            child: Builder(builder: (context) {
              final key = GlobalObjectKey<MeetingNotificationManagerState>(
                  uiNavigator.roomContext);
              MeetingNotificationManager.globalKey = key;
              return MeetingNotificationManager(
                  key: key,
                  enable: !uiNavigator.meetingLifecycleState.isMinimized,
                  child: MeetingPage(uiNavigator.meetingArguments));
            }),
          ),
      ],
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: uiNavigator,
        ),
        ChangeNotifierProvider.value(
          value: uiNavigator.meetingLifecycleState,
        ),
        ChangeNotifierProvider.value(
          value: uiNavigator.meetingUIState,
        ),
      ],
      child: NEMeetingKitFeatureConfig(
        config: uiNavigator.meetingUIState.sdkConfig,
        child: NEWatermarkConfigurationManager(
          roomContext: uiNavigator.roomContext,
          watermarkConfig: uiNavigator.meetingArguments.watermarkConfig,
          child: navigator,
        ),
      ),
    );
  }

  bool _handlePopPagedRoute(Route<dynamic> route, dynamic result) {
    final page = route.settings as Page;
    if ([_RouterName.waitingRoom, _RouterName.inMeeting].contains(page.name)) {
      commonLogger.w(
          'Unexpected pop route request: ${page.name} $result\n${StackTrace.current}');
      return false;
    }
    commonLogger.i('_handlePopPagedRoute: ${page.name} $result');
    return route.didPop(result);
  }

  /// 离开当前会议并加入另外一个会议
  bool joinAnotherMeeting = false;

  /// 处理邀请点击事件
  Future<void> handleEvent(CardData? inviteData, bool videoMute) async {
    /// 设置字段拦截不退出
    joinAnotherMeeting = true;

    /// 如果当前在会议中，先离开会议
    if (uiNavigator.isInMeeting) {
      await uiNavigator.roomContext.leaveRoom();
    }

    /// 如果当前在等候室中，则确保销毁rtc
    else {
      await uiNavigator.roomContext.rtcController.leaveRtcChannel();
    }

    final newRoomResult =
        await NEMeetingKit.instance.getMeetingInviteService().acceptInvite(
              NEJoinMeetingParams(
                meetingNum: inviteData!.meetingNum!,
                displayName: uiNavigator.roomContext.localMember.name,
              ),
              NEJoinMeetingOptions(
                enableMyAudioDeviceOnJoinRtc:
                    uiNavigator.meetingArguments.options.detectMutedMic,
              ),
            );
    if (newRoomResult.isSuccess()) {
      uiNavigator.initMeeting(MeetingArguments(
        roomContext: newRoomResult.data!,
        meetingInfo: newRoomResult.data!.meetingInfo,
        options: uiNavigator.meetingArguments.options.copyWith(
          noAudio: false,
          noVideo: videoMute,
        ),
        backgroundWidget: uiNavigator.meetingArguments.backgroundWidget,
        watermarkConfig: uiNavigator.meetingArguments.watermarkConfig,
      ));
      return;
    }

    /// 离开了当前会议，但是加入新会议失败了，返回首页
    else {
      uiNavigator.pop();
    }
    ToastUtils.showBotToast('${newRoomResult.msg}');
  }
}

class _RouterName {
  static const waitingRoom = 'waitingRoom';
  static const inMeeting = 'inMeeting';
}

class _LoggingNavigatorObserver extends NavigatorObserver with _AloggerMixin {
  final logTag = 'MeetingUIRouter';

  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    commonLogger.i(
        'didPush: route=${routeInfo(route)} pre=${routeInfo(previousRoute)}');
  }

  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    commonLogger
        .i('didPop: route=${routeInfo(route)} pre=${routeInfo(previousRoute)}');
  }

  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    commonLogger.i(
        'didRemove: route=${routeInfo(route)} pre=${routeInfo(previousRoute)}');
  }

  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    commonLogger.i(
        'didReplace: route=${routeInfo(newRoute)} pre=${routeInfo(oldRoute)}');
  }

  String routeInfo(Route? route) {
    return route == null
        ? 'NULL'
        : '${route.runtimeType}-${route.settings.name}-${route.hashCode}';
  }
}
