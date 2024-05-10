// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/error_handler/error_handler.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:path_provider/path_provider.dart';
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
    AppStyle.setSystemUIOverlayStyleDark();
    ErrorHandler.instance().install();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Application.ensureInitialized();
    runApp(MeetingAppLocalizationsScope(child: MeetingApp()));
    copyBeautyRes();
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

class MeetingApp extends StatefulWidget {
  MeetingApp();

  @override
  State<MeetingApp> createState() => _MeetingAppState();
}

class _MeetingAppState extends State<MeetingApp> {
  late NEMeetingStatusListener _meetingStatusListener;

  final isInMinimizedMode = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    /// 切换至用户选中的语言
    switchLanguage();

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
      }
    });

    _meetingStatusListener = (status) {
      switch (status.event) {
        case NEMeetingEvent.inMeetingMinimized:
          isInMinimizedMode.value = true;
          break;
        case NEMeetingEvent.inMeeting:
          isInMinimizedMode.value = false;
          break;
        default:
          break;
      }
    };
    NEMeetingUIKit().addListener(_meetingStatusListener);
  }

  @override
  Widget build(BuildContext context) {
    Application.context = context;
    final meetingAppLocalizations = MeetingAppLocalizations.of(context)!;
    final app = MaterialApp(
      builder: (context, child) {
        return BotToastInit()(
            context,
            ValueListenableBuilder(
                valueListenable: isInMinimizedMode,
                builder: (_, value, __) {
                  return value
                      ? child!
                      : InComingInvite(
                          child: child!,
                          isInMinimizedMode: false,
                        );
                }));
      },
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      title: meetingAppLocalizations.globalAppName,
      theme: ThemeData(
          useMaterial3: false,
          brightness: Brightness.light,
          appBarTheme: AppBarTheme(
            systemOverlayStyle: AppStyle.systemUiOverlayStyleDark,
          )),
      themeMode: ThemeMode.light,
      navigatorKey: NavUtils.navigatorKey,
      home: MeetingAppLocalizationsScope(
        child: WelcomePage(),
      ),
      navigatorObservers: [BotToastNavigatorObserver()],
      // 注册路由表
      routes: RoutesRegister.routes,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...MeetingAppLocalizations.localizationsDelegates,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // 美国英语
        const Locale('zh', 'CN'),
        const Locale('ja', 'JP'),
      ],
      locale: NEMeetingUIKit().localeListenable.value,
    );
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
      await NEMeetingUIKit().switchLanguage(NEMeetingLanguage.chinese);
    } else if (language == NEMeetingLanguage.english.locale.languageCode) {
      await NEMeetingUIKit().switchLanguage(NEMeetingLanguage.english);
    } else if (language == NEMeetingLanguage.japanese.locale.languageCode) {
      await NEMeetingUIKit().switchLanguage(NEMeetingLanguage.japanese);
    }
  }

  @override
  void dispose() {
    NEMeetingUIKit().removeListener(_meetingStatusListener);
    super.dispose();
  }
}

class WelcomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WelcomePageState();
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
