// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class VirtualBackgroundPageProxy extends StatelessWidget {
  final GlobalKey<NavigatorState> _sdkVirtualNavigatorKey = GlobalObjectKey(1);

  final dynamic arguments;

  VirtualBackgroundPageProxy({this.arguments});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: NEMeetingUIKitLocalizationsScope(
        child: Navigator(
          key: _sdkVirtualNavigatorKey,
          observers: [VirtualBackgroundRouteObserver(context)],
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute(
              builder: (context) => PreVirtualBackgroundPage(),
            );
          },
        ),
      ),
      onWillPop: () async {
        await _sdkVirtualNavigatorKey.currentState!.maybePop();
        return false;
      },
    );
  }
}

/// change
class VirtualBackgroundRouteObserver extends RouteObserver<PageRoute> {
  static const _tag = 'VirtualBackgroundRouteObserver';
  final BuildContext context;

  VirtualBackgroundRouteObserver(this.context);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute == null) {
      UINavUtils.pop(context, rootNavigator: true);
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
