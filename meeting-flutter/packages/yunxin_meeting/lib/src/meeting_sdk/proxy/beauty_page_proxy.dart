// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

class BeautyPageProxy extends StatelessWidget {
  final GlobalKey<NavigatorState> _sdkBeautyNavigatorKey = GlobalKey();

  final dynamic arguments;
  final int beautyLevel;

  BeautyPageProxy({this.arguments, this.beautyLevel = 0});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Navigator(
        key: _sdkBeautyNavigatorKey,
        observers: [BeautyRouteObserver(context)],
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (context) => BeautySettingPage(
                    beautyLevel: beautyLevel,
                  ));
        },
      ),
      onWillPop: () async {
        await _sdkBeautyNavigatorKey.currentState!.maybePop();
        return false;
      },
    );
  }
}

/// change
class BeautyRouteObserver extends RouteObserver<PageRoute> {
  static const _tag = 'BeautyRouteObserver';
  final BuildContext context;

  BeautyRouteObserver(this.context);

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
