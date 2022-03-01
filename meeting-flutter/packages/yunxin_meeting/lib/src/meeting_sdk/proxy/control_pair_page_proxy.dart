// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

bool back2MainRoute = true;

class ControlPairPageProxy extends StatefulWidget {
  final ControlArguments arguments;

  ControlPairPageProxy(this.arguments);

  @override
  _ControlPairPageProxyState createState() => _ControlPairPageProxyState();
}

class _ControlPairPageProxyState extends State<ControlPairPageProxy> implements NEMeetingAuthListener  {

  @override
  void initState() {
    super.initState();
    NEMeetingSDK.instance.addAuthListener(this);
  }

  /// 被踢出
  @override
  void onKickOut() => quit();

  @override
  void onAuthInfoExpired() => quit();

  void quit() {
    MeetingControl().isAlreadyOpenControl = false;
    UINavUtils.pop(context, rootNavigator: true);
  }

  @override
  void dispose() {
    NEMeetingSDK.instance.removeAuthListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Store.init(
        context: context,
        child: WillPopScope(
          child: Navigator(
            key: MeetingControl.controlNavigatorKey,
            observers: [ControlRouteObserver(context)],
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(builder: (context) => ControlPairPage(widget.arguments));
            },
          ),
          onWillPop: () async {
            if (back2MainRoute) {
              MeetingControl().isAlreadyOpenControl = false;
              UINavUtils.pop(context, rootNavigator: true);
            } else {
              await MeetingControl.controlNavigatorKey.currentState!.maybePop();
            }
            return false;
          },
        ));
  }
}

/// change
class ControlRouteObserver extends RouteObserver<PageRoute> {
  BuildContext context;

  ControlRouteObserver(this.context);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute == null) {
      back2MainRoute = true;
      MeetingControl().isAlreadyOpenControl = false;
      UINavUtils.pop(context, rootNavigator: true);
    } else {
      back2MainRoute = false;
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (previousRoute == null) {
      MeetingControl().isAlreadyOpenControl = true;
      back2MainRoute = true;
    } else {
      back2MainRoute = false;
    }
  }
}
