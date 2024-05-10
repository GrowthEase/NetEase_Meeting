// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_meeting_ui/meeting_ui.dart';

import '../language/meeting_localization/meeting_app_localizations.dart';

class MeetingStringUtil {
  /// 获取重复频率
  static String getRepeatTypeString(NEMeetingRecurringRuleType type,
      int startTime, MeetingAppLocalizations meetingAppLocalizations) {
    final time = DateTime.fromMillisecondsSinceEpoch(startTime);
    switch (type) {
      case NEMeetingRecurringRuleType.no:
        return meetingAppLocalizations.meetingNoRepeat;
      case NEMeetingRecurringRuleType.day:
        return meetingAppLocalizations.meetingRepeatEveryday;
      case NEMeetingRecurringRuleType.weekday:
        return meetingAppLocalizations.meetingRepeatEveryWeekday;
      case NEMeetingRecurringRuleType.week:
        return '${meetingAppLocalizations.meetingRepeatEveryWeek} (${getWeekday(time.weekday, meetingAppLocalizations)})';
      case NEMeetingRecurringRuleType.twoWeeks:
        return '${meetingAppLocalizations.meetingRepeatEveryTwoWeek} (${getWeekday(time.weekday, meetingAppLocalizations)})';
      case NEMeetingRecurringRuleType.dayOfMonth:
        return '${meetingAppLocalizations.meetingRepeatEveryMonth} (${getDay(time, meetingAppLocalizations)})';
      case NEMeetingRecurringRuleType.custom:
        return meetingAppLocalizations.meetingRepeatCustom;
      default:
        return '';
    }
  }

  static String getCustomRepeatDesc(NEMeetingRecurringRule recurringRule,
      int startTime, MeetingAppLocalizations meetingAppLocalizations) {
    final customizedFrequency = recurringRule.customizedFrequency;
    if (customizedFrequency != null) {
      if (customizedFrequency.stepUnit == NEMeetingFrequencyUnitType.day) {
        return meetingAppLocalizations
            .meetingRepeatDay(customizedFrequency.stepSize);
      } else if (customizedFrequency.stepUnit ==
          NEMeetingFrequencyUnitType.weekday) {
        customizedFrequency.daysOfWeek!.sort((value1, value2) {
          return value1.index - value2.index;
        });
        final week = customizedFrequency.daysOfWeek!
            .map((e) => getWeekdayEx(e, meetingAppLocalizations))
            .join(' ');
        return meetingAppLocalizations.meetingRepeatDayInWeek(
            week, customizedFrequency.stepSize);
      } else if (customizedFrequency.stepUnit ==
          NEMeetingFrequencyUnitType.dayOfMonth) {
        customizedFrequency.daysOfMonth!.sort();
        final day = customizedFrequency.daysOfMonth!
            .map((e) => meetingAppLocalizations.meetingDayInMonth(e.toString()))
            .join(' ');
        return meetingAppLocalizations.meetingRepeatDayInMonth(
            day, customizedFrequency.stepSize);
      } else if (customizedFrequency.stepUnit ==
          NEMeetingFrequencyUnitType.weekdayOfMonth) {
        final time = DateTime.fromMillisecondsSinceEpoch(startTime);
        var firstDayOfMonth = DateTime(time.year, time.month, 1);
        var dayOfWeek = firstDayOfMonth.weekday;
        var currentWeekDay = time.weekday;
        var day = time.day;
        final currentWeekOfMonth;
        if (dayOfWeek <= currentWeekDay) {
          currentWeekOfMonth = (day + dayOfWeek - 2) ~/ 7 + 1;
        } else {
          currentWeekOfMonth = (day + dayOfWeek - 2) ~/ 7;
        }
        return meetingAppLocalizations.meetingRepeatDayInWeekInMonth(
            customizedFrequency.stepSize,
            currentWeekOfMonth,
            getWeekday(time.weekday, meetingAppLocalizations));
      }
    }
    return '';
  }

  static String getWeekdayEx(NEMeetingRecurringWeekday weekday,
      MeetingAppLocalizations meetingAppLocalizations) {
    int day;
    if (weekday == NEMeetingRecurringWeekday.sunday) {
      day = 7;
    } else {
      day = weekday.index - 1;
    }
    return getWeekday(day, meetingAppLocalizations);
  }

  static String getWeekday(
      int day, MeetingAppLocalizations meetingAppLocalizations) {
    String weekdayStr = '';
    switch (day) {
      case 1:
        weekdayStr = meetingAppLocalizations.globalMonday;
        break;
      case 2:
        weekdayStr = meetingAppLocalizations.globalTuesday;
        break;
      case 3:
        weekdayStr = meetingAppLocalizations.globalWednesday;
        break;
      case 4:
        weekdayStr = meetingAppLocalizations.globalThursday;
        break;
      case 5:
        weekdayStr = meetingAppLocalizations.globalFriday;
        break;
      case 6:
        weekdayStr = meetingAppLocalizations.globalSaturday;
        break;
      case 7:
        weekdayStr = meetingAppLocalizations.globalSunday;
        break;
    }
    return weekdayStr;
  }

  static String getDay(
      DateTime time, MeetingAppLocalizations meetingAppLocalizations) {
    return meetingAppLocalizations.meetingDayInMonth(time.day.toString());
  }

  static String getItemStatus(
      NEMeetingState status, MeetingAppLocalizations meetingAppLocalizations) {
    switch (status) {
      case NEMeetingState.init:
        return meetingAppLocalizations.meetingStatusInit;
      case NEMeetingState.started:
        return meetingAppLocalizations.meetingStatusStarted;
      case NEMeetingState.ended:
        return meetingAppLocalizations.meetingStatusEnded;
      case NEMeetingState.cancel:
        return meetingAppLocalizations.meetingStatusCancel;
      case NEMeetingState.recycled:
        return meetingAppLocalizations.meetingStatusRecycle;
      case NEMeetingState.invalid:
        return '';
    }
  }
}
