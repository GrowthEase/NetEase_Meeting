// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:base/util/textutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uikit/utils/router_name.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yunxin_base/yunxin_base.dart';

class NavUtils {
  static final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  static Future<bool> launchURL(String url, {bool? forceWebView}) async {

    if(Platform.isIOS){
      return await launch(url, forceSafariVC: false);
    }else {
      if (await canLaunch(url)) {
        return await launch(url, forceSafariVC: false);
      } else {
        Alog.d(tag: 'NavUtils', content: 'Could not launch $url');
      }
    }
    return Future.value(false);
  }

  static void exitApp() {
    if (Platform.isAndroid) {
      exitAndroid();
    } else {
      exit(0);
    }
  }

  static Future<void> exitAndroid() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  static Future<void> pushNamedAndRemoveUntil(
    BuildContext context,
    String routeName, {
    String? utilRouteName,
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      TextUtil.isEmpty(utilRouteName)
          ? (Route<dynamic> route) => false
          : withName(utilRouteName!),
    );
  }

  static RoutePredicate withName(String name) {
    return (Route<dynamic> route) {
      return !route.willHandlePopInternally && route is ModalRoute && route.settings.name == name;
    };
  }

  static void popAndPushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.of(context).popAndPushNamed(routeName, arguments: arguments);
  }

  static void pop(BuildContext context, {Object? arguments}) {
    Navigator.of(context).pop(arguments);
  }

  static void popUntil(BuildContext context, String pageRoute) {
    Navigator.of(context).popUntil(ModalRoute.withName(pageRoute));
  }

  static void closeCurrentState([dynamic result]) {
    navigatorKey.currentState?.pop(result);
  }

  static const int clickTimes = 5;
  static const int duration = 2 * 1000;
  static var mHits = List<int>.filled(clickTimes, 0);

  static void toDeveloper(BuildContext context) {
    List.copyRange(mHits, 0, mHits, 1, mHits.length);
    mHits[mHits.length - 1] = DateTime.now().millisecondsSinceEpoch;
    if (mHits[0] >= (DateTime.now().millisecondsSinceEpoch - duration)) {
      mHits = List<int>.filled(clickTimes, 0);
      NavUtils.pushNamed(context, RouterName.backdoor);
    }
  }
}
