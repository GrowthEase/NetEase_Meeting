// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_uikit;

class PageName {
  static const String meetingPage = "meetingPage";
}

class UINavUtils {
  static const _tag = 'ReporterClient';
  static Future<bool> launchURL(String url) async {
    if (Platform.isIOS) {
      return await launch(url, forceSafariVC: false);
    } else {
      if (await canLaunch(url)) {
        return await launch(url, forceSafariVC: false);
      } else {
        Alog.d(tag: _tag, content: 'UINavUtils Could not launch $url');
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

  static Future<void> pushNamed(
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
        routeName, TextUtils.isEmpty(utilRouteName!) ? (Route<dynamic> route) => false : withName(utilRouteName));
  }

  static RoutePredicate withName(String? name) {
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

  static void pop(BuildContext context, {Object? arguments, bool rootNavigator = false}) {
    Navigator.of(context, rootNavigator: rootNavigator).pop(arguments);
  }

  static void popUntil(BuildContext context, String pageRoute) {
    Navigator.of(context).popUntil(ModalRoute.withName(pageRoute));
  }
}
