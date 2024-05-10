// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/service/model/security_notice_info.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/utils/security_notice_util.dart';
import 'package:nemeeting/webview/webview_page.dart';

import '../uikit/values/asset_name.dart';
import '../uikit/values/borders.dart';
import '../uikit/values/colors.dart';

class MeetingAppNotificationBar extends StatefulWidget {
  final VoidCallback? onClose;
  final AppNotification? notification;

  MeetingAppNotificationBar({
    Key? key,
    this.onClose,
    this.notification,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MeetingAppNotificationBarState();
  }
}

class MeetingAppNotificationBarState extends State<MeetingAppNotificationBar> {
  final TapGestureRecognizer _tap = TapGestureRecognizer();
  AppNotification? _notification;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    if (widget.notification != null) {
      _notification = widget.notification;
    } else {
      _subscription = AppNotificationManager().appNotification.listen((event) {
        setState(() {
          _notification = event;
        });
      });
    }
  }

  @override
  void dispose() {
    _tap.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notification = _notification;
    if (notification == null) {
      return Container();
    }

    return Column(
      children: [
        Container(
            // constraints: BoxConstraints(
            //     minHeight: 100
            // ),
            padding: EdgeInsets.only(left: 13, right: 13, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.noticeBg,
              border: Border.fromBorderSide(Borders.noticeBorder),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildIconBy(AssetName.iconWarning),
                  SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: RichText(
                      textDirection: TextDirection.ltr,
                      text: TextSpan(children: [
                        TextSpan(children: [
                          TextSpan(
                            text: notification.title,
                            style: buildTextStyle(AppColors.color_666666),
                          ),
                          TextSpan(
                              text: notification.content,
                              style: buildTextStyle(AppColors.color_666666),
                              recognizer: _tap
                                ..onTap =
                                    () => onNotificationTap(notification)),
                        ]),
                      ]),
                    ),
                  ),
                  buildIconBy(AssetName.iconClose, paddingLeft: 2)
                ])),
      ],
    );
  }

  TextStyle buildTextStyle(Color color) {
    return TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none);
  }

  Align buildIconBy(String assetName,
      {double paddingLeft = 0, double paddingRight = 0}) {
    return Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding:
              EdgeInsets.only(top: 3, right: paddingRight, left: paddingLeft),
          child: GestureDetector(
            onTap: () {
              AppNotificationManager().hideNotification();
              widget.onClose?.call();
            },
            child: Image.asset(
              assetName,
              //package: AssetName.package,
              fit: BoxFit.fill,
            ),
          ),
        ));
  }

  void onNotificationTap(AppNotification notification) {
    if (notification.type == AppNotification.kTypeUrl) {
      if (notification.url != null && notification.url!.isNotEmpty) {
        NavUtils.pushNamed(
          context,
          RouterName.webview,
          arguments: WebViewArguments(notification.url!, ''),
        );
      }
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(notification.title ?? ''),
            content: Text(notification.content ?? ''),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(notification.okBtnLabel ?? ''),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
