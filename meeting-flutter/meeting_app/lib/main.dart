// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nemeeting/error_handler/error_handler.dart';
import 'package:nemeeting/uikit/values/strings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nemeeting/arguments/webview_arguments.dart';
import 'package:nemeeting/setting/package_setting.dart';
import 'package:nemeeting/setting/personal_setting.dart';
import '../service/auth/auth_state.dart';
import '../service/model/account_app_info.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../service/auth/auth_manager.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import '../service/config/app_config.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/webview/webview_page.dart';

import 'application.dart';
import 'arguments/entrance_arguments.dart';
import 'utils/nav_register.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:netease_common/netease_common.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:archive/archive_io.dart';
import 'package:nemeeting/service/config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppStyle.setStatusBarTextBlackColor();

  runZonedGuarded<Future<void>>(() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      AppConfig().init().then((value) {
        assert(() {
          print('App env: ${AppConfig().env}');
          return true;
        }());
        NERoomLogService().init().then((value) => printDeviceInfo());
        Alog.i(tag: 'main', content: 'App env: ${AppConfig().env}');
        ErrorHandler.instance().install();

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

        /// 消耗时间为2毫秒
        copyBeautyRes();
      });
    });
  }, (Object error, StackTrace stack) {
    Alog.e(
        tag: 'flutter-crash',
        content: 'crash exception: $error \ncrash stack: $stack');
    ErrorHandler.instance().recordError(error, stack);
  });
}

Future<void> copyBeautyRes() async {
  Directory? cache;
  if (Platform.isAndroid) {
    cache = await getExternalStorageDirectory();
  } else {
    cache = await getApplicationDocumentsDirectory();
  }
  // Read the Zip file from disk.
  final value =
      await rootBundle.load('assets/virtual_background_images/images.zip');
  // Decode the Zip file
  var bytes =
      value.buffer.asUint8List(value.offsetInBytes, value.lengthInBytes);
  final archive = ZipDecoder().decodeBytes(bytes);

  // Extract the contents of the Zip archive to disk.
  for (final file in archive) {
    final filename = file.name;
    if (!filename.contains('.DS_Store')) {
      if (file.isFile) {
        final data = file.content as List<int>;
        File('${cache?.path}/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        await Directory('${cache?.path}/' + filename).create(recursive: true);
      }
    }
  }
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
    Alog.d(
        tag: _tag,
        moduleName: _moduleName,
        content: json.encode(AppConfig.readAndroidBuildData(androidInfo)));
  }
}

class MeetingApp extends StatelessWidget {
  MeetingApp() {
    AuthState().authState().listen((event) {
      Alog.d(tag: 'AuthState', content: 'authState:$event');
      if (event.state == AuthState.tokenIllegal) {
        ToastUtils.showToast(
            NavUtils.navigatorKey.currentState!.context, event.errorTip);
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
        title: Strings.appName,
        theme: ThemeData(
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            )),
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
                    return Container();
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadLoginInfo();
    });
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
