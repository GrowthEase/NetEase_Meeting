// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/error_handler/error_handler.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/utils/virtual_background_util.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

import '../service/auth/auth_manager.dart';
import '../service/auth/auth_state.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import 'application.dart';
import 'base/util/global_preferences.dart';
import 'language/localizations.dart';
import 'language/meeting_localization/meeting_app_localizations.dart';
import 'utils/nav_register.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    debugPrint('AppStartUp: main');
    WidgetsFlutterBinding.ensureInitialized();
    NEMeetingKitUIStyle.setSystemUIOverlayStyleDark();
    ErrorHandler.instance().install();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Application.ensureInitialized();
    runApp(MeetingApp());
  }, (Object error, StackTrace stack) {
    Alog.e(
        tag: 'flutter-crash',
        content: 'crash exception: $error \ncrash stack: $stack');
    ErrorHandler.instance().recordError(error, stack);
  });
}

class MeetingApp extends StatefulWidget {
  MeetingApp();

  @override
  State<MeetingApp> createState() => _MeetingAppState();
}

class _MeetingAppState extends State<MeetingApp>
    implements NEMeetingStatusListener {
  final isInMinimizedMode = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    /// 切换至用户选中的语言
    switchLanguage().then((value) => setState(() {}));

    // 延迟首帧，待自动登录成功/失败后才展示
    WidgetsBinding.instance.deferFirstFrame();
    AuthState().authState().listen((event) {
      Alog.d(tag: 'AuthState', content: 'authState:$event');
      if (event.state == AuthState.tokenIllegal) {
        ToastUtils.showToast(context, event.errorTip);
        NavUtils.navigatorKey.currentState!.pushNamedAndRemoveUntil(
          'entrance',
          ModalRoute.withName('/'),
        );
      } else if (event.state == AuthState.authed) {
        VirtualBackgroundManager().ensureInit();
      }
    });
    NEMeetingKit.instance.getMeetingService().addMeetingStatusListener(this);
  }

  @override
  Widget build(BuildContext context) {
    final app = ValueListenableBuilder(
        valueListenable: NEMeetingUIKit.instance.localeListenable,
        builder: (context, locale, child) {
          return MaterialApp(
            builder: (context, child) {
              return BotToastInit()(
                  context,
                  ValueListenableBuilder(
                      valueListenable: isInMinimizedMode,
                      builder: (_, value, __) {
                        return value
                            ? child!
                            : InComingInvite(
                                currentContext: () =>
                                    NavUtils.navigatorKey.currentContext,
                                child: child!,
                                isInMinimizedMode: false,
                                getDefaultNickName: () =>
                                    MeetingUtil.getNickName(),
                                backgroundWidget: HomePageRoute(),
                                buildMeetingUIOptions: (videoAccept) =>
                                    buildMeetingUIOptions(
                                  noVideo: !videoAccept,
                                  noAudio: false,
                                  context: context,
                                ),
                              );
                      }));
            },
            color: Colors.white,
            debugShowCheckedModeBanner: false,
            title: getAppLocalizations().globalAppName,
            theme: ThemeData(
                fontFamily: Platform.isIOS ? 'PingFang SC' : null,
                useMaterial3: false,
                brightness: Brightness.light,
                appBarTheme: AppBarTheme(
                  systemOverlayStyle:
                      NEMeetingKitUIStyle.systemUiOverlayStyleDark,
                )),
            themeMode: ThemeMode.light,
            navigatorKey: NavUtils.navigatorKey,
            home: WelcomePage(),
            navigatorObservers: [BotToastNavigatorObserver()],
            // 注册路由表
            // routes: RoutesRegister.routes,
            onGenerateRoute: RoutesRegister.onGenerateRoute,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              ...MeetingAppLocalizations.localizationsDelegates,
              ...NEMeetingUIKitLocalizations.localizationsDelegates,
            ],
            supportedLocales: [
              const Locale('en', 'US'), // 美国英语
              const Locale('zh', 'CN'),
              const Locale('ja', 'JP'),
            ],
            locale: locale,
          );
        });
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: app,
    );
  }

  /// 根据本地缓存切换语言
  Future<void> switchLanguage() async {
    final language = await GlobalPreferences().getLanguageCode();
    if (language == null ||
        language == NEMeetingLanguage.automatic.locale.languageCode) return;
    if (language == NEMeetingLanguage.chinese.locale.languageCode) {
      await NEMeetingKit.instance.switchLanguage(NEMeetingLanguage.chinese);
    } else if (language == NEMeetingLanguage.english.locale.languageCode) {
      await NEMeetingKit.instance.switchLanguage(NEMeetingLanguage.english);
    } else if (language == NEMeetingLanguage.japanese.locale.languageCode) {
      await NEMeetingKit.instance.switchLanguage(NEMeetingLanguage.japanese);
    }
  }

  @override
  void dispose() {
    NEMeetingKit.instance.getMeetingService().removeMeetingStatusListener(this);
    super.dispose();
  }

  @override
  void onMeetingStatusChanged(NEMeetingEvent event) {
    switch (event.status) {
      case NEMeetingStatus.inMeetingMinimized:
        isInMinimizedMode.value = true;
        break;
      default:
        isInMinimizedMode.value = false;
        break;
    }
  }
}

class WelcomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WelcomePageState();
  }
}

class _WelcomePageState extends BaseState<WelcomePage> {
  StreamSubscription? _connectivitySubscription;
  bool loadLoginInfoSuccess = false;
  @override
  void initState() {
    super.initState();
    loadLoginInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.color_337eff),
          ),
        ),
      ),
    );
  }

  void loadLoginInfo() {
    debugPrint("AppStartUp: loadLoginInfo start");
    ConnectivityManager()
        .isConnected()
        .then((connected) =>
            connected ? AuthManager().autoLogin() : Future.value(false))
        .then((success) {
          NavUtils.pushNamedAndRemoveUntil(
              context, success ? RouterName.homePage : RouterName.entrance);
        })
        .timeout(Duration(seconds: 5))
        .catchError((error, stack) {
          Alog.d(tag: 'WelcomePage', content: 'auto login error: $error');
          return null;
        })
        .whenComplete(() {
          debugPrint("AppStartUp: loadLoginInfo end");
          WidgetsBinding.instance.allowFirstFrame();
        });
  }
}
