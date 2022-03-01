// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yunxin_event_track/yunxin_event_track.dart';
import 'package:nemeeting/arguments/webview_arguments.dart';
import 'package:nemeeting/setting/package_setting.dart';
import 'package:nemeeting/setting/personal_setting.dart';
import 'package:service/auth/auth_state.dart';
import 'package:service/model/account_app_info.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:service/auth/auth_manager.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:service/config/app_config.dart';
import 'package:service/event/track_app_event.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';
import 'package:nemeeting/webview/webview_page.dart';
import 'package:yunxin_meeting/meeting_sdk.dart';

import 'application.dart';
import 'arguments/entrance_arguments.dart';
import 'utils/nav_register.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yunxin_base/yunxin_base.dart';
import 'package:device_info/device_info.dart';

// Toggle this for testing Crashlytics in your app loca// Toggle this for testing Crashlytics in your app locally.lly.
const _kTestingCrashlytics = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppStyle.setStatusBarTextBlackColor();
  runZonedGuarded<Future<void>>(() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      AppConfig().init().then((value) {
        NERoomLogService().init().then((value) => printDeviceInfo());
        _initEventTrack();
        AuthManager().init().then((e) {
          runApp(MeetingApp());
          if (Platform.isAndroid) {
            var systemUiOverlayStyle = SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.dark);
            SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
          }
        });
      });
    });
  }, (Object error, StackTrace stack) {
    Alog.e(
        tag: 'flutter-crash',
        content: 'crash exception: $error \ncrash stack: $stack');
  });
}

Future<void> _initEventTrack() async {
  EventTrack().init(AppInfo('', ''));
}

void printDeviceInfo() async {
  var _tag = 'fistLog';
  var _moduleName = 'mainApp';
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosInfo = await deviceInfo.iosInfo;
    Alog.d(
      tag: _tag,
      moduleName: _moduleName,
      content: json.encode(AppConfig.readIosDeviceInfo(iosInfo)),
    );
  } else if (Platform.isAndroid) {
    var androidInfo = await deviceInfo.androidInfo;
    Alog.d(tag: _tag, moduleName: _moduleName, content: json.encode(AppConfig.readAndroidBuildData(androidInfo)));
  }
}

class MeetingApp extends StatelessWidget {
  MeetingApp() {
    EventTrack().trackEvent(ActionEvent.periodic(
        TrackAppEventName.applicationInit,
        module: AppModuleName.moduleName));
    AuthState().authState().listen((event) {
      Alog.d(
          tag: 'AuthState',
          content: 'authState:$event');
      if (event.state == AuthState.tokenIllegal) {
        ToastUtils.showToast( NavUtils.navigatorKey.currentState!.context, event.errorTip);
        NavUtils.navigatorKey.currentState!.pushNamedAndRemoveUntil(
            'entrance', ModalRoute.withName('/'),
            arguments: EntranceArguments(event.state, event.errorTip));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Application.context = context;
    return MaterialApp(
        builder: BotToastInit(),
        color: Colors.white,
        theme: ThemeData(
            brightness: Brightness.light,
            primaryColorBrightness: Brightness.light,
            appBarTheme: AppBarTheme(brightness: Brightness.light)),
        themeMode: ThemeMode.light,
        navigatorKey: NavUtils.navigatorKey,
        home: WelcomePage(),
        navigatorObservers: [BotToastNavigatorObserver()],
        // 注册路由表
        routes: RoutesRegister.routes,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
              builder: (context) {
                switch (settings.name) {
                  case RouterName.webview:
                    return WebViewPage(settings.arguments as WebViewArguments);
                  case RouterName.packageVersionSetting:
                    return PackageVersionSetting(settings.arguments as Edition);
                  case RouterName.personalSetting:
                    return PersonalSetting(settings.arguments as String);
                  default:
                    return ErrorWidget('PageNotFound');
                }
              },
              settings: settings);
        },
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'), // 美国英语
          const Locale('zh', 'CN'),
        ]);
  }
}

class WelcomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WelcomePageState();
}

class _WelcomePageState extends BaseState<WelcomePage> {
  @override
  void initState() {
    super.initState();
    var config = AppConfig();
    Alog.i(
        tag: 'appInit',
        content:
            'vName=${config.versionName} vCode=${config.versionCode} time=${config.time}');
    loadLoginInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white);
  }

  void loadLoginInfo() {
    AuthManager().autoLogin().then((value) {
      if (value == true) {
        // 自动登录成功
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.homePage);
      } else {
        // 自动登录失败
        NavUtils.pushNamedAndRemoveUntil(context, RouterName.entrance);
      }
    });
  }
}
