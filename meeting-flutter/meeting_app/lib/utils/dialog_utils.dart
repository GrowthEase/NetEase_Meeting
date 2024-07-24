// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/uikit/values/colors.dart';

import '../language/localizations.dart';

bool _isEmpty(String? text) {
  return text == null || text.length == 0;
}

class AppDialogUtils {
  static Future showCommonDialog(BuildContext context, String title,
      String content, VoidCallback cancelCallback, VoidCallback acceptCallback,
      {String? cancelText,
      String? acceptText,
      bool canBack = true,
      bool isContentCenter = true}) {
    cancelText ??= getAppLocalizations().globalCancel;
    acceptText ??= getAppLocalizations().globalSure;
    return showDialog(
        context: context,
        useRootNavigator: false,
        barrierDismissible: canBack,
        builder: (BuildContext context) {
          return PopScope(
            canPop: canBack,
            child: CupertinoAlertDialog(
              title: _isEmpty(title) ? null : Text(title),
              content: Text(content,
                  textAlign:
                      isContentCenter ? TextAlign.center : TextAlign.left),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(cancelText!),
                  onPressed: cancelCallback,
                  textStyle: TextStyle(color: AppColors.color_666666),
                ),
                CupertinoDialogAction(
                  child: Text(acceptText!),
                  onPressed: acceptCallback,
                  textStyle: TextStyle(color: AppColors.color_337eff),
                ),
              ],
            ),
          );
        });
  }

  static Future showOneButtonCommonDialog(
      BuildContext context, String title, String content, VoidCallback callback,
      {String? acceptText, bool canBack = true, bool isContentCenter = true}) {
    acceptText ??= getAppLocalizations().globalIKnow;
    return showDialog(
        context: context,
        useRootNavigator: false,
        barrierDismissible: canBack,
        builder: (BuildContext context) {
          return PopScope(
            canPop: canBack,
            child: CupertinoAlertDialog(
              title: _isEmpty(title) ? null : Text(title),
              content: Text(content,
                  textAlign:
                      isContentCenter ? TextAlign.center : TextAlign.left),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(acceptText!),
                  onPressed: callback,
                ),
              ],
            ),
          );
        });
  }
}
