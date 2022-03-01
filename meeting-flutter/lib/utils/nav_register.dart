// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/about/about.dart';
import 'package:nemeeting/meeting/meeting_create.dart';
import 'package:nemeeting/meeting/meeting_join.dart';
import 'package:nemeeting/meeting/anony_meet_join.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting.dart';
import 'package:nemeeting/routes/auth/check_mobile.dart';
import 'package:nemeeting/routes/auth/get_mobile_check_code.dart';
import 'package:nemeeting/routes/auth/login_sso.dart';
import 'package:nemeeting/routes/auth/password_verify.dart';
import 'package:nemeeting/routes/backdoor.dart';
import 'package:nemeeting/routes/entrance.dart';
import 'package:nemeeting/routes/home_page.dart';
import 'package:nemeeting/routes/auth/login.dart';
import 'package:nemeeting/setting/company_setting.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:nemeeting/routes/third/auth/mail_login.dart';
import 'package:nemeeting/setting/meeting_setting.dart';
import 'package:nemeeting/setting/nick_setting.dart';

class RoutesRegister {
  static var routes = {
    RouterName.login: (context) => LoginRoute(),
    RouterName.ssoLogin: (context) => LoginSSORoute(),
    RouterName.getMobileCheckCode: (context) => GetMobileCheckCodeRoute(),
    RouterName.checkMobile: (context) => CheckMobileRoute(),
    RouterName.passwordVerify: (context) => PasswordVerifyRoute(),
    //RouterName.oldPasswordVerify: (context) => OldPasswordVerifyRoute(),
    RouterName.anonyMeetJoin: (context) => AnonyMeetJoinRoute(),
    RouterName.entrance: (context) => EntranceRoute(),
    RouterName.homePage: (context) => HomePageRoute(),
    RouterName.meetCreate: (context) => MeetCreateRoute(),
    RouterName.meetJoin: (context) => MeetJoinRoute(),
    RouterName.meetingSetting: (context) => MeetingSetting(),
    // RouterName.personalSetting: (context) => PersonalSetting(),
    RouterName.companySetting: (context) => CompanySetting(),
    RouterName.nickSetting: (context) => NickSetting(),
    RouterName.backdoor: (context) => BackdoorRoute(),
    RouterName.about: (context) => About(),
    RouterName.mailLogin: (context) => MailLoginRoute(),
    RouterName.scheduleMeeting: (context) => ScheduleMeetingRoute(),
  };
}
