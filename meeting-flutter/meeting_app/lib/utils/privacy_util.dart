// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:nemeeting/service/config/servers.dart';
import 'package:nemeeting/webview/webview_page.dart';
import '../language/meeting_localization/meeting_app_localizations.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/widget/meeting_protocols.dart';

class PrivacyUtil {
  static ValueNotifier<bool> checked = ValueNotifier<bool>(false);

  static set privateAgreementChecked(bool value) => checked.value = value;

  static bool get privateAgreementChecked => checked.value;

  static final TapGestureRecognizer _tapPrivacy = TapGestureRecognizer();

  static final TapGestureRecognizer _tapUserProtocol = TapGestureRecognizer();

  static TextStyle buildTextStyle(Color color) {
    return TextStyle(
        color: color,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none);
  }

  static void dispose() {
    _tapPrivacy.dispose();
    _tapUserProtocol.dispose();
  }

  static Widget protocolTips() {
    return ValueListenableBuilder(
      builder: (BuildContext context, bool value, Widget? child) {
        final meetingAppLocalizations = MeetingAppLocalizations.of(context)!;
        return MeetingProtocols(
          value: value,
          onChanged: (bool value) {
            checked.value = value;
          },
          tapUserProtocol: () {
            NavUtils.pushNamed(context, RouterName.webview,
                arguments: WebViewArguments(Servers.userProtocol,
                    meetingAppLocalizations.authServiceAgreement));
          },
          tapPrivacy: () {
            NavUtils.pushNamed(context, RouterName.webview,
                arguments: WebViewArguments(
                    Servers.privacy, meetingAppLocalizations.authPrivacy));
          },
        );
      },
      valueListenable: checked,
    );
  }
}
