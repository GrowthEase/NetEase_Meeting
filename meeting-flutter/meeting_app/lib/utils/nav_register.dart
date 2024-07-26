// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/about/about.dart';
import 'package:nemeeting/auth/login_corp_account.dart';
import 'package:nemeeting/auth/login_mobile.dart';
import 'package:nemeeting/auth/login_sso.dart';
import 'package:nemeeting/auth/modify_password.dart';
import 'package:nemeeting/auth/reset_initial_password.dart';
import 'package:nemeeting/auth/verify_mobile_check_code.dart';
import 'package:nemeeting/pre_meeting/transcription_history.dart';
import 'package:nemeeting/setting/app_setting.dart';
import 'package:nemeeting/meeting/history_meeting.dart';
import 'package:nemeeting/meeting/meeting_create.dart';
import 'package:nemeeting/meeting/meeting_join.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting.dart';
import 'package:nemeeting/routes/entrance.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/routes/network_not_available_page.dart';
import 'package:nemeeting/setting/account_and_safety_setting.dart';
import 'package:nemeeting/setting/avatar_setting.dart';
import 'package:nemeeting/routes/qr_scan_page.dart';
import 'package:nemeeting/setting/captions_setting.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import '../setting/language_setting.dart';
import '../uikit/utils/router_name.dart';
import 'package:nemeeting/setting/meeting_setting.dart';
import 'package:nemeeting/setting/nick_setting.dart';

import '../webview/webview_page.dart';

class RoutesRegister {
  static var _routes = {
    RouterName.mobileLogin: (context) => LoginMobileRoute(),
    RouterName.corpAccountLogin: (context) => LoginCorpAccountRoute(),
    RouterName.resetInitialPassword: (context) => ResetInitialPasswordRoute(),
    RouterName.ssoLogin: (context) => LoginSSORoute(),
    RouterName.verifyMobileCheckCode: (context) => VerifyMobileCheckCodeRoute(),
    RouterName.entrance: (context) => EntranceRoute(),
    RouterName.homePage: (context) => HomePageRoute(isPipMode: false),
    RouterName.meetCreate: (context) => MeetCreateRoute(),
    RouterName.meetJoin: (context) => MeetJoinRoute(),
    RouterName.appSetting: (context) => AppSettingRoute(),
    RouterName.historyMeet: (context) => HistoryMeetingRoute(),
    RouterName.meetingSetting: (context) => MeetingSetting(),
    RouterName.nickSetting: (context) => NickSetting(),
    RouterName.avatarSetting: (context) => AvatarSetting(),
    RouterName.about: (context) => About(),
    RouterName.scheduleMeeting: (context) => ScheduleMeetingRoute(),
    RouterName.networkNotAvailable: (context) => NetworkNotAvailableRoute(),
    RouterName.accountAndSafety: (context) => AccountAndSafetySettingRoute(),
    RouterName.modifyPassword: (context) => ModifyPasswordRoute(),
    RouterName.webview: (context) => WebViewPage(),
    RouterName.qrScan: (context) => QrScanPage(),
    RouterName.languageSetting: (context) => LanguageSetting(),
    RouterName.captionsSetting: (context) => CaptionsSetting(),
    RouterName.transcriptionTiming: (context) => TranscriptionTimingPage(),
  };

  static Map<String, Widget Function(dynamic)> get routes {
    return _routes;
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    final builder = _routes[name];
    return builder != null
        ? NEMeetingPageRoute(settings: settings, builder: builder)
        : null;
  }

  static MaterialPageRoute getPageRoute(String routeName, BuildContext context,
      {Object? arguments}) {
    var builder = routes[routeName];
    if (builder == null) {
      throw Exception('Invalid route name: $routeName');
    }
    return NEMeetingPageRoute(
        builder: (context) => builder(context),
        settings: RouteSettings(arguments: arguments));
  }
}
