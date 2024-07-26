// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/uikit/utils/nav_utils.dart';
import 'package:nemeeting/uikit/utils/router_name.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/utils/security_notice_util.dart';
import 'package:nemeeting/webview/webview_page.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

import '../uikit/values/asset_name.dart';
import '../uikit/values/colors.dart';
import '../utils/integration_test.dart';

class MeetingAppNotificationBar extends StatefulWidget {
  final VoidCallback? onClose;
  final NEMeetingAppNoticeTip? notification;

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

class MeetingAppNotificationBarState
    extends PlatformAwareLifecycleBaseState<MeetingAppNotificationBar> {
  final TapGestureRecognizer _tap = TapGestureRecognizer();
  NEMeetingAppNoticeTip? _notification;
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
  Widget buildWithPlatform(BuildContext context) {
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
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildWarning(),
                  SizedBox(
                    width: 6,
                  ),
                  Expanded(
                    child: RichText(
                      textDirection: TextDirection.ltr,
                      text: TextSpan(children: [
                        TextSpan(children: [
                          TextSpan(
                            text: notification.title,
                            style: buildTextStyle(AppColors.color_f29900),
                          ),
                          TextSpan(
                              text: notification.content,
                              style: buildTextStyle(AppColors.color_f29900),
                              recognizer: _tap
                                ..onTap =
                                    () => onNotificationTap(notification)),
                        ]),
                      ]),
                    ),
                  ),
                  SizedBox(width: 6),
                  buildClose(),
                ])),
      ],
    );
  }

  TextStyle buildTextStyle(Color color) {
    return TextStyle(
        color: color,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none);
  }

  Align buildWarning() {
    return Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 14.w,
          width: 14.w,
          child: NEGestureDetector(
              onTap: () {
                AppNotificationManager().hideNotification();
                widget.onClose?.call();
              },
              child: Image.asset(
                AssetName.iconWarning,
                fit: BoxFit.fill,
              )),
        ));
  }

  Align buildClose() {
    return Align(
        alignment: Alignment.topCenter,
        child: Container(
          key: MeetingValueKey.tipClose,
          height: 12.w,
          width: 12.w,
          child: NEGestureDetector(
            onTap: () {
              AppNotificationManager().hideNotification();
              widget.onClose?.call();
            },
            child: Icon(
              IconFont.icon_close,
              size: 10,
              color: AppColors.color_f29900,
            ),
          ),
        ));
  }

  void onNotificationTap(NEMeetingAppNoticeTip notification) {
    if (notification.type == NEMeetingAppNoticeTipType.kUrl) {
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
