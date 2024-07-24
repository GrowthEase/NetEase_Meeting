// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_meeting_kit/meeting_ui.dart';

import '../language/localizations.dart';

class MeetingStringUtil {
  /// 获取重复频率
  static String getRepeatTypeString(
      NEMeetingRecurringRuleType type, int startTime) {
    final time = DateTime.fromMillisecondsSinceEpoch(startTime);
    switch (type) {
      case NEMeetingRecurringRuleType.no:
        return getAppLocalizations().meetingNoRepeat;
      case NEMeetingRecurringRuleType.day:
        return getAppLocalizations().meetingRepeatEveryday;
      case NEMeetingRecurringRuleType.weekday:
        return getAppLocalizations().meetingRepeatEveryWeekday;
      case NEMeetingRecurringRuleType.week:
        return '${getAppLocalizations().meetingRepeatEveryWeek} (${getWeekday(time.weekday)})';
      case NEMeetingRecurringRuleType.twoWeeks:
        return '${getAppLocalizations().meetingRepeatEveryTwoWeek} (${getWeekday(time.weekday)})';
      case NEMeetingRecurringRuleType.dayOfMonth:
        return '${getAppLocalizations().meetingRepeatEveryMonth} (${getDay(time)})';
      case NEMeetingRecurringRuleType.custom:
        return getAppLocalizations().meetingRepeatCustom;
      default:
        return '';
    }
  }

  static String _excludeOne(int value) {
    return value == 1 ? '' : value.toString();
  }

  static String getCustomRepeatDesc(
      NEMeetingRecurringRule recurringRule, int startTime) {
    final customizedFrequency = recurringRule.customizedFrequency;
    if (customizedFrequency != null) {
      if (customizedFrequency.stepUnit == NEMeetingFrequencyUnitType.day) {
        return getAppLocalizations()
            .meetingRepeatDay(_excludeOne(customizedFrequency.stepSize));
      } else if (customizedFrequency.stepUnit ==
          NEMeetingFrequencyUnitType.weekday) {
        customizedFrequency.daysOfWeek!.sort((value1, value2) {
          return value1.index - value2.index;
        });
        final week = customizedFrequency.daysOfWeek!
            .map((e) => getWeekdayEx(e))
            .join(' ');
        return getAppLocalizations().meetingRepeatDayInWeek(
            week, _excludeOne(customizedFrequency.stepSize));
      } else if (customizedFrequency.stepUnit ==
          NEMeetingFrequencyUnitType.dayOfMonth) {
        customizedFrequency.daysOfMonth!.sort();
        final day = customizedFrequency.daysOfMonth!
            .map((e) => getAppLocalizations().meetingDayInMonth(e.toString()))
            .join(' ');
        return getAppLocalizations().meetingRepeatDayInMonth(
            day, _excludeOne(customizedFrequency.stepSize));
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
        return getAppLocalizations().meetingRepeatDayInWeekInMonth(
            _excludeOne(customizedFrequency.stepSize),
            currentWeekOfMonth,
            getWeekday(time.weekday));
      }
    }
    return '';
  }

  static String getWeekdayEx(NEMeetingRecurringWeekday weekday) {
    int day;
    if (weekday == NEMeetingRecurringWeekday.sunday) {
      day = 7;
    } else {
      day = weekday.index - 1;
    }
    return getWeekday(day);
  }

  static String getWeekday(int day) {
    String weekdayStr = '';
    switch (day) {
      case 1:
        weekdayStr = getAppLocalizations().globalMonday;
        break;
      case 2:
        weekdayStr = getAppLocalizations().globalTuesday;
        break;
      case 3:
        weekdayStr = getAppLocalizations().globalWednesday;
        break;
      case 4:
        weekdayStr = getAppLocalizations().globalThursday;
        break;
      case 5:
        weekdayStr = getAppLocalizations().globalFriday;
        break;
      case 6:
        weekdayStr = getAppLocalizations().globalSaturday;
        break;
      case 7:
        weekdayStr = getAppLocalizations().globalSunday;
        break;
    }
    return weekdayStr;
  }

  static String getDay(DateTime time) {
    return getAppLocalizations().meetingDayInMonth(time.day.toString());
  }

  static String getItemStatus(NEMeetingItemStatus status) {
    switch (status) {
      case NEMeetingItemStatus.init:
        return getAppLocalizations().meetingStatusInit;
      case NEMeetingItemStatus.started:
        return getAppLocalizations().meetingStatusStarted;
      case NEMeetingItemStatus.ended:
        return getAppLocalizations().meetingStatusEnded;
      case NEMeetingItemStatus.cancel:
        return getAppLocalizations().meetingStatusCancel;
      case NEMeetingItemStatus.recycled:
        return getAppLocalizations().meetingStatusRecycle;
      case NEMeetingItemStatus.invalid:
        return '';
    }
  }

  static String getMonth(int month) {
    switch (month) {
      case 1:
        return getAppLocalizations().globalMonthJan;
      case 2:
        return getAppLocalizations().globalMonthFeb;
      case 3:
        return getAppLocalizations().globalMonthMar;
      case 4:
        return getAppLocalizations().globalMonthApr;
      case 5:
        return getAppLocalizations().globalMonthMay;
      case 6:
        return getAppLocalizations().globalMonthJun;
      case 7:
        return getAppLocalizations().globalMonthJul;
      case 8:
        return getAppLocalizations().globalMonthAug;
      case 9:
        return getAppLocalizations().globalMonthSept;
      case 10:
        return getAppLocalizations().globalMonthOct;
      case 11:
        return getAppLocalizations().globalMonthNov;
      case 12:
        return getAppLocalizations().globalMonthDec;
    }
    return '';
  }
}
