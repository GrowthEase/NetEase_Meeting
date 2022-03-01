// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:base/util/global_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/arguments/webview_arguments.dart';
import 'package:service/config/servers.dart';
import 'package:uikit/utils/nav_utils.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/strings.dart';
import 'package:uikit/widget/meeting_checkbox.dart';

class PrivacyUtil {
  static ValueNotifier<bool> checked = ValueNotifier<bool>(false);

  static set privateAgreementChecked(bool value) => checked.value = value;

  static bool get privateAgreementChecked => checked.value;

  static final TapGestureRecognizer _tapPrivacy = TapGestureRecognizer();

  static final TapGestureRecognizer _tapUserProtocol = TapGestureRecognizer();

  static void handlePrivacyDialog(BuildContext context, VoidCallback callback) {
    GlobalPreferences().userProtocolAndPrivacy.then((value) {
      if (value == null || value == false) {
        showPrivacyDialog(context, callback);
      } else {
        callback();
      }
    });
  }

  static void showPrivacyDialog(BuildContext context, VoidCallback callback) {
    showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(Strings.userProtocolAndPrivacy),
            content: buildPrivacyText(context),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(Strings.notAgree),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              CupertinoDialogAction(
                child: Text(Strings.agree),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        }).then((value) {
      if (value != null && value) {
        GlobalPreferences().setUserProtocolAndPrivacy(true);
        Future.delayed(Duration(milliseconds: 320)).then((value) {
          callback();
        });
      } else {
        exit(0);
      }
    });
  }

  static Text buildPrivacyText(BuildContext context) {
    return Text.rich(
      TextSpan(children: [
        TextSpan(
            text: Strings.privacyDialogTipsPrefix,
            style: buildTextStyle(AppColors.color_333333)),
        TextSpan(
            text: Strings.privacyDialogPrivacyTips,
            style: buildTextStyle(AppColors.blue_337eff),
            recognizer: _tapPrivacy
              ..onTap = () {
                NavUtils.pushNamed(context, RouterName.webview,
                    arguments:
                        WebViewArguments(servers.privacy, Strings.privacy));
              }),
        TextSpan(
            text: Strings.joinAppAnd,
            style: buildTextStyle(AppColors.color_333333)),
        TextSpan(
            text: Strings.privacyDialogProtocolTips,
            style: buildTextStyle(AppColors.blue_337eff),
            recognizer: _tapUserProtocol
              ..onTap = () {
                NavUtils.pushNamed(context, RouterName.webview,
                    arguments: WebViewArguments(
                        servers.userProtocol, Strings.user_protocol));
              }),
        TextSpan(
            text: Strings.privacyDialogTipsSuffix,
            style: buildTextStyle(AppColors.color_333333)),
      ]),
      textAlign: TextAlign.left,
    );
  }

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

  static Widget protocolTips(
    BuildContext context,
  ) {
    return ValueListenableBuilder(
      builder: (BuildContext context, bool value, Widget? child) {
        return buildProtocol(context, value);
      },
      valueListenable: checked,
      child: buildProtocol(context, PrivacyUtil.checked.value),
    );
  }

  static Widget buildProtocol(BuildContext context, bool value) {
    return Padding(
      padding: EdgeInsets.only(right: 4, bottom: 12),
      // margin: const EdgeInsets.only(bottom: 41),
      child: MeetingCheckBox(
        height: 80,
        value: value,
        onChanged: (bool value) {
          checked.value = value;
        },
        tapUserProtocol: () {
          NavUtils.pushNamed(context, RouterName.webview,
              arguments: WebViewArguments(
                  servers.userProtocol, Strings.user_protocol));
        },
        tapPrivacy: () {
          NavUtils.pushNamed(context, RouterName.webview,
              arguments: WebViewArguments(servers.privacy, Strings.privacy));
        },
      ),
    );
  }
}
