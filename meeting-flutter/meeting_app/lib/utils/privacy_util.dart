// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/service/config/servers.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/webview/webview_page.dart';
import '../language/localizations.dart';
import '../uikit/utils/nav_utils.dart';
import '../uikit/utils/router_name.dart';
import '../uikit/widget/meeting_protocols.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

class PrivacyUtil {
  static const String TAG = "PrivacyUtil";
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

  static Future<bool> ensurePrivacyAgree(BuildContext context) async {
    if (!PrivacyUtil.privateAgreementChecked) {
      return PrivacyUtil.showPrivacyDialog(context, exitIfNotOk: false);
    }
    return true;
  }

  static Widget protocolTips() {
    return ValueListenableBuilder(
      builder: (BuildContext context, bool value, Widget? child) {
        return MeetingProtocols(
          value: value,
          onChanged: (bool value) {
            checked.value = value;
          },
          tapUserProtocol: () {
            if (Servers().userProtocol?.isNotEmpty ?? false) {
              NavUtils.pushNamed(context, RouterName.webview,
                  arguments: WebViewArguments(Servers().userProtocol!,
                      getAppLocalizations().authServiceAgreement));
            } else {
              Alog.e(tag: TAG, content: "privacy is empty");
            }
          },
          tapPrivacy: () {
            if (Servers().privacy?.isNotEmpty ?? false) {
              NavUtils.pushNamed(context, RouterName.webview,
                  arguments: WebViewArguments(
                      Servers().privacy!, getAppLocalizations().authPrivacy));
            } else {
              Alog.e(tag: TAG, content: "privacy is empty");
            }
          },
        );
      },
      valueListenable: checked,
    );
  }

  static Future<bool> showPrivacyDialog(BuildContext context,
      {bool exitIfNotOk = true}) async {
    TextSpan buildTextSpan(String text, WebViewArguments? arguments) {
      return TextSpan(
        text: text,
        style: buildTextStyle(
          arguments != null ? AppColors.blue_337eff : AppColors.color_999999,
        ),
        recognizer: arguments == null
            ? null
            : (TapGestureRecognizer()
              ..onTap = () {
                NavUtils.pushNamed(context, RouterName.webview,
                    arguments: arguments);
              }),
      );
    }

    final userArguments = WebViewArguments(
        Servers().userProtocol, getAppLocalizations().authServiceAgreement);
    final privacyArguments =
        WebViewArguments(Servers().privacy, getAppLocalizations().authPrivacy);
    final message = getAppLocalizations().authPrivacyDialogMessage(
        '##neteasePrivacy##', '##neteaseUserProtocol##');
    final messageList = message.split('##');
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(getAppLocalizations().authPrivacyDialogTitle),
            content: Text.rich(
              TextSpan(
                children: [
                  for (var item in messageList)
                    item == 'neteasePrivacy'
                        ? buildTextSpan(
                            getAppLocalizations().authNeteasePrivacy,
                            privacyArguments)
                        : item == 'neteaseUserProtocol'
                            ? buildTextSpan(
                                getAppLocalizations()
                                    .authNetEaseServiceAgreement,
                                userArguments)
                            : buildTextSpan(item, null),
                ],
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(exitIfNotOk
                    ? getAppLocalizations().globalQuit
                    : getAppLocalizations().globalCancel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              CupertinoDialogAction(
                child: Text(getAppLocalizations().globalAgree),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        }).then((value) {
      if (value != true && exitIfNotOk) {
        exit(0);
      }
      if (value == true) {
        GlobalPreferences().setPrivacyDialogShowed(true);
        PrivacyUtil.privateAgreementChecked = true;
      }
      return value ?? false;
    });
  }
}
