// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:nemeeting/language/meeting_localization/meeting_app_localizations.dart';

extension StringWeekday on int {
  String toWeekday(BuildContext context) {
    final meetingAppLocalizations = MeetingAppLocalizations.of(context)!;
    switch (this) {
      case 0:
        return meetingAppLocalizations.globalSunday;
      case 1:
        return meetingAppLocalizations.globalMonday;
      case 2:
        return meetingAppLocalizations.globalTuesday;
      case 3:
        return meetingAppLocalizations.globalWednesday;
      case 4:
        return meetingAppLocalizations.globalThursday;
      case 5:
        return meetingAppLocalizations.globalFriday;
      case 6:
        return meetingAppLocalizations.globalSaturday;
      default:
        return meetingAppLocalizations.globalSunday;
    }
  }
}
