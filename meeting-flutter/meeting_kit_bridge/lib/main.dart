// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttermodule/meeting_kit_bridge.dart';
import 'package:fluttermodule/src/module_name.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

late final MeetingKitBridge bridge;
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runZonedGuarded<void>(() {
    WidgetsFlutterBinding.ensureInitialized();
    _wrapFlutterErrorHandler();
    bridge = MeetingKitBridge();
    runApp(MyApp());
  }, onError);
}

void _wrapFlutterErrorHandler() {
  var handler = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    onError(details.exceptionAsString(), details.stack);
    handler?.call(details);
  };
  var handler2 = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(exception: error, stack: stack));
    onError(error, stack);
    return handler2?.call(error, stack) ?? true;
  };
}

void onError(Object exception, StackTrace? stacktrace) {
  Alog.e(
      tag: 'MeetingBridge',
      moduleName: moduleName,
      content: '''unexpected error: $exception
$stacktrace
    ''');
  assert(() {
    showFlutterErrorDialogIfDebug(exception, stacktrace);
    return true;
  }());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bridge.appNameNotifier,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: bridge.appNameNotifier.value ?? '',
          home: RedirectPage(),
          theme: ThemeData.light(
            useMaterial3: false,
          ),
          themeMode: ThemeMode.light,
          navigatorObservers: [routeObserver, _LoggingNavigatorObserver()],
        );
      },
    );
  }
}

class RedirectPage extends StatefulWidget {
  @override
  _RedirectPageState createState() => _RedirectPageState();
}

class _RedirectPageState extends State<RedirectPage>
    with RouteAware, WidgetsBindingObserver {
  static const _tag = 'RedirectPage';
  late final EventCallback _eventCallback;
  late final EventCallback _frameChangeCallback;
  @override
  void initState() {
    super.initState();
    bridge.buildContext = context;
    _eventCallback = (arg) {
      Alog.i(tag: _tag, moduleName: moduleName, content: 'onEvent: $arg');
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        try {
          bridge.channel.invokeMethod(
              'SystemNavigator.pop${arg == 'minimize' ? '.minimize' : ''}',
              false /* animated */);
          Alog.i(
              tag: _tag,
              moduleName: moduleName,
              content: 'request finish view controller');
        } catch (e) {
          Alog.i(
              tag: _tag,
              moduleName: moduleName,
              content: 'SystemNavigator.pop error: $e');
        }
      } else if (arg == 'minimize') {
        //bridge.channel.invokeMethod('meeting.minimize', false /* animated */);
        // SystemNavigator.pop();
        Alog.i(tag: _tag, moduleName: moduleName, content: 'request minimize');
      } else {
        SystemNavigator.pop();
        Alog.i(
            tag: _tag,
            moduleName: moduleName,
            content: 'request finish activity');
      }
    };
    EventBus().subscribe(NEMeetingUIEvents.flutterPageDisposed, _eventCallback);
    _frameChangeCallback = (arg) {
      if (arg is! Map) return;
      int? width = arg["width"];
      int? height = arg["height"];
      if (width == null || height == null) return;
      bridge.channel.invokeMethod('minimize.frame.change',
          {'width': width.toDouble(), 'height': height.toDouble()});
    };
    EventBus()
        .subscribe(NEMeetingUIEvents.flutterFrameChanged, _frameChangeCallback);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    EventBus().unsubscribe(NEMeetingUIEvents.flutterPageDisposed);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff292933),
      body: Center(
          // child: Text(
          //   '正在$_label会议...',
          //   style: TextStyle(
          //       color: Colors.white,
          //       fontSize: 20,
          //       decoration: TextDecoration.none,
          //       fontWeight: FontWeight.w500),
          // ),
          ),
    );
  }

  @override
  void didPush() {
    Alog.i(tag: _tag, moduleName: moduleName, content: 'RedirectPage did push');
  }

  @override
  void didPushNext() {
    Alog.i(
        tag: _tag,
        moduleName: moduleName,
        content: 'RedirectPage did push next');
  }

  @override
  void didPop() {
    Alog.i(tag: _tag, moduleName: moduleName, content: 'RedirectPage did pop');
  }

  @override
  void didPopNext() {
    Alog.i(
        tag: _tag,
        moduleName: moduleName,
        content: 'RedirectPage did pop next');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Alog.i(
          tag: _tag,
          moduleName: moduleName,
          content: 'RedirectPage app resumed');
    }
  }

  @override
  void didChangeMetrics() {
    print('_RedirectPageState.didChangeMetrics');
  }
}

/// Generally, Flutter errors are always caught and then dump to console , so developers may not be aware of them.
/// Showing an error dialog explicitly to avoid errors eaten by console or somehow silently.
void showFlutterErrorDialogIfDebug(Object exception, StackTrace? stacktrace) {
  Timer.run(() {
    showDialog<void>(
      context: bridge.buildContext,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xF0900000),
          titleTextStyle: TextStyle(
            color: const Color(0xFFFFFF66),
            fontFamily: 'sans-serif',
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
            color: const Color(0xFFFFFF66),
            fontFamily: 'monospace',
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
          title: Center(child: Text('Error Detected!!')),
          content: SingleChildScrollView(
            child: Text('exception: \n$exception'
                '\n'
                'stacktrace: \n$stacktrace'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true)
                    .pop(); // Dismiss alert dialog
              },
            ),
          ],
        );
      },
    );
  });
}

class _LoggingNavigatorObserver extends NavigatorObserver {
  void log(String content) {
    Alog.i(
      tag: 'MeetingKitBridgeMainRouter',
      moduleName: moduleName,
      content: content,
    );
  }

  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log('didPush: route=${routeInfo(route)} pre=${routeInfo(previousRoute)}');
  }

  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log('didPop: route=${routeInfo(route)} pre=${routeInfo(previousRoute)}');
  }

  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log('didRemove: route=${routeInfo(route)} pre=${routeInfo(previousRoute)}');
  }

  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    log('didReplace: route=${routeInfo(newRoute)} pre=${routeInfo(oldRoute)}');
  }

  String routeInfo(Route? route) {
    return route == null
        ? 'NULL'
        : '${route.runtimeType}-${route.settings.name}';
  }
}
