// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

class MeetingPageProxy extends StatelessWidget {
  final GlobalKey<NavigatorState> _sdkNavigatorKey = GlobalKey();

  final MeetingBaseArguments arguments;

  MeetingPageProxy(this.arguments);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Navigator(
        key: _sdkNavigatorKey,
        observers: [MeetingRouteObserver(context)],
        onGenerateRoute: (RouteSettings settings) {
          final arg = settings.arguments ?? arguments;
          if (arg is MeetingArguments) {
            return LoggingMaterialPageRoute(
                builder: (context) => MeetingPage(arg));
          } else if (arg is MeetingWaitingArguments) {
            return MaterialPageRoute(
                builder: (context) => MeetingWaitingPage(arg));
          }
          return null;
        },
      ),
      onWillPop: () async {
        await _sdkNavigatorKey.currentState!.maybePop();
        return false;
      },
    );
  }
}

/// change
class MeetingRouteObserver extends RouteObserver<PageRoute> {
  static const _tag = 'MeetingRouteObserver';
  BuildContext context;

  MeetingRouteObserver(this.context);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute == null) {
      UINavUtils.pop(context, rootNavigator: true, arguments: route.popped);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content:
            'sdk didPush: pre=${previousRoute?.settings}@${previousRoute.runtimeType} cur=${route.settings}@${route.runtimeType}');
  }
}

class LoggingMaterialPageRoute extends MaterialPageRoute {
  static const _tag = 'LoggingMaterialPageRoute';
  LoggingMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  bool didPop(dynamic result) {
    assert(() {
      // print current stacktrace to figure out where it is pop
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content: 'LoggingPageRoute didPop:\n ${StackTrace.current}');
      return true;
    }());
    return super.didPop(result);
  }
}
