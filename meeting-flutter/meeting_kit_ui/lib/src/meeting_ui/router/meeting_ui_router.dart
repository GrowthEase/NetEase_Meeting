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

  static void pop(
    BuildContext context, {
    Object? result,
    int? disconnectingCode,
  }) {
    return _MeetingUIRouterScope.of(context)!
        .state
        .pop(result: result, disconnectingCode: disconnectingCode);
  }
}

class _MeetingUIRouterState extends State<MeetingUIRouter> with _AloggerMixin {
  late final MeetingUIState state;
  late final MeetingUIRouterDelegate routerDelegate;
  var disconnectingCode = NEMeetingCode.undefined;
  var hasRequestPop = false;

  String get logTag => 'MeetingUIRouter@$hashCode';

  @override
  void initState() {
    super.initState();
    commonLogger.i('initState');
    Wakelock.enable();
    state = MeetingUIState(widget.roomContext, widget.arguments);
    routerDelegate = MeetingUIRouterDelegate(state);
    InMeetingService().rememberMeetingUIState(state);
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
    Wakelock.disable().catchError((e) {
      commonLogger.i('Wakelock error $e');
    });
    InMeetingService().clearMeetingUIState();
    MeetingCore().notifyStatusChange(
        NEMeetingStatus(NEMeetingEvent.disconnecting, arg: disconnectingCode));
    MeetingCore().notifyStatusChange(NEMeetingStatus(NEMeetingEvent.idle));
    EventBus().emit(NEMeetingUIEvents.flutterPageDisposed);
    AppStyle.setSystemUIOverlayStyleDark();
    state.dispose();
    super.dispose();
  }

  void pop({Object? result, int? disconnectingCode}) {
    debugPrintStack(
        label:
            'Pop meeting ui router: isCurrent=${myselfRoute.isCurrent}, disconnectingCode=$disconnectingCode');
    assert(!hasRequestPop, 'Duplicated request pop meeting ui router');
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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !(await routerDelegate.popRoute());
      },
      child: NEMeetingUIKitLocalizationsScope(
        child: _MeetingUIRouterScope(
          state: this,
          child: Router(
            routerDelegate: routerDelegate,
          ),
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
  static final key = GlobalKey<NavigatorState>();

  @override
  GlobalKey<NavigatorState> navigatorKey = key;

  final MeetingUIState state;

  MeetingUIRouterDelegate(this.state) {
    state.addListener(notifyListeners);
  }

  @override
  void dispose() {
    state.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  Future<void> setNewRoutePath(Object configuration) {
    return SynchronousFuture(null);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: null,
      observers: [
        _LoggingNavigatorObserver(),
      ],
      onPopPage: _handlePopPagedRoute,
      pages: [
        if (state.isInWaitingRoom)
          MaterialPage(
            name: _RouterName.waitingRoom,
            key: const ValueKey<String>(_RouterName.waitingRoom),
            child: Builder(
              builder: (context) =>
                  MeetingWaitingRoomPage(state.meetingArguments),
            ),
          ),
        if (state.isInMeeting)
          MaterialPage(
            name: _RouterName.inMeeting,
            key: const ValueKey<String>(_RouterName.inMeeting),
            child: Builder(
              builder: (context) => MeetingPage(state.meetingArguments),
            ),
          ),
      ],
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
}

class _RouterName {
  static const waitingRoom = 'waitingRoom';
  static const inMeeting = 'inMeeting';
}

mixin MeetingUIStateScope<T extends StatefulWidget> on State<T> {
  MeetingUIState? _meetingUIState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _meetingUIState =
        _MeetingUIRouterScope.of(context, nullOk: true)?.state.state;
  }

  MeetingUIState? get currentMeetingUIState => _meetingUIState;

  MeetingArguments? get currentMeetingArguments =>
      currentMeetingUIState?.meetingArguments;
}

class _MeetingUIRouterScope extends InheritedWidget {
  final _MeetingUIRouterState state;

  const _MeetingUIRouterScope({
    required this.state,
    required Widget child,
  }) : super(child: child);

  static _MeetingUIRouterScope? of(BuildContext context,
      {bool nullOk = false}) {
    final _MeetingUIRouterScope? result =
        context.dependOnInheritedWidgetOfExactType<_MeetingUIRouterScope>();
    assert(
        result != null || nullOk, 'No _MeetingUIRouterScope found in context');
    return result;
  }

  @override
  bool updateShouldNotify(_MeetingUIRouterScope old) {
    return old.state != state;
  }
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
