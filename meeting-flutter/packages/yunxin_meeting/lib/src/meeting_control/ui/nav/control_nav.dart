// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class _PageName {
  static const String homePage = 'homePage';

  static const String controlPair = 'controlpair';
  static const String controlHome = 'controlhome';
  static const String controlMeet = 'controlmeet';
  static const String controlMeetCreate = 'controlmeetcreate';
  static const String controlMeetJoin = 'controlmeetjoin';
  static const String controlMeetWaiting = 'controlmeetwaiting';
}

class _NavUtils {
  static Future<T?> push<T extends Object>(BuildContext context, String pageName, StatefulWidget page) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => page, settings: RouteSettings(name: pageName)));
  }

  static Future<T?> toControlMeetCreatePage<T extends Object>(BuildContext context, ControlArguments controlArguments) {
    return _NavUtils.push(context, _PageName.controlMeetCreate, ControlMeetCreatePage(controlArguments));
  }

  static Future<T?> toControlMeetJoinPage<T extends Object>(BuildContext context, ControlArguments controlArguments) {
    return _NavUtils.push(context, _PageName.controlMeetJoin, ControlMeetJoinPage(controlArguments));
  }

  static Future<T?> toControlMeetingPage<T extends Object>(BuildContext context,
      ControlMeetingArguments controlMeetingArguments) {
    return _NavUtils.push(
        context,
        _PageName.controlMeet,
        ControlMeetingPage(controlMeetingArguments));
  }

  static Future<T?> toControlMeetingWaitingPage<T extends Object>(BuildContext context,
      ControlMeetingWaitingArguments controlMeetingWaitingArguments) {
    return _NavUtils.push(
        context,
        _PageName.controlMeetWaiting,
        ControlMeetingWaitingPage(controlMeetingWaitingArguments));
  }

  static Future<T?> toControlNickSettingPage<T extends Object>(BuildContext context, ControlArguments controlArguments) {
    return _NavUtils.push(
        context,
        _PageName.controlMeet,
        ControlNickSettingPage(controlArguments));
  }

  static void pop(BuildContext context, {Object? arguments}) {
    Navigator.of(context).pop(arguments);
  }
}
