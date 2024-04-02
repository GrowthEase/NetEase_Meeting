// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_repeat_custom.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/fonts.dart';

class ScheduleMeetingRepeatRoute extends StatefulWidget {
  final NEMeetingRecurringRule recurringRule;
  final int startTime;
  final bool isEdit;

  ScheduleMeetingRepeatRoute(this.recurringRule, this.startTime, this.isEdit);

  @override
  State<ScheduleMeetingRepeatRoute> createState() =>
      _ScheduleMeetingRepeatRouteState();
}

class _ScheduleMeetingRepeatRouteState
    extends MeetingBaseState<ScheduleMeetingRepeatRoute>
    with MeetingAppLocalizationsMixin {
  @override
  String getTitle() {
    return meetingAppLocalizations.meetingFrequency;
  }

  @override
  Widget buildBody() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: viewportConstraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buildTypeItems(),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> buildTypeItems() {
    final ruleTypes = NEMeetingRecurringRuleType.values;
    final widgets = <Widget>[];
    widgets.add(buildSpace());
    ruleTypes.forEach((element) {
      if (element != NEMeetingRecurringRuleType.custom &&
          element != NEMeetingRecurringRuleType.undefine) {
        widgets.add(buildSplit());
        widgets.add(buildCheckableItem(element));
      }
    });
    widgets.add(buildSpace());
    widgets.add(buildArrowItem(meetingAppLocalizations.meetingRepeatCustom));
    if (widget.recurringRule.type == NEMeetingRecurringRuleType.custom) {
      widgets.add(buildSplit());
      widgets.add(buildCustomDetail());
    }
    return widgets;
  }

  Widget buildCheckableItem(NEMeetingRecurringRuleType type) {
    final time = DateTime.fromMillisecondsSinceEpoch(widget.startTime);
    final title;
    String? subTitle;
    switch (type) {
      case NEMeetingRecurringRuleType.no:
        title = meetingAppLocalizations.meetingNoRepeat;
        break;
      case NEMeetingRecurringRuleType.day:
        title = meetingAppLocalizations.meetingRepeatEveryday;
        break;
      case NEMeetingRecurringRuleType.weekday:
        title = meetingAppLocalizations.meetingRepeatEveryWeekday;
        break;
      case NEMeetingRecurringRuleType.week:
        title = meetingAppLocalizations.meetingRepeatEveryWeek;
        subTitle = ' (${getWeekday(time.weekday)})';
        break;
      case NEMeetingRecurringRuleType.twoWeeks:
        title = meetingAppLocalizations.meetingRepeatEveryTwoWeek;
        subTitle = ' (${getWeekday(time.weekday)})';
        break;
      case NEMeetingRecurringRuleType.dayOfMonth:
        title = meetingAppLocalizations.meetingRepeatEveryMonth;
        subTitle = ' (${getDay(time)})';
        break;
      default:
        title = '';
        break;
    }
    return GestureDetector(
      child: Container(
          height: 56,
          color: Colors.white,
          alignment: Alignment.center,
          child: ListTile(
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style:
                        TextStyle(fontSize: 16, color: AppColors.black_222222),
                  ),
                  if (subTitle != null)
                    TextSpan(
                      text: subTitle,
                      style: TextStyle(
                          fontSize: 16, color: AppColors.color_999999),
                    ),
                ],
              ),
            ),
            trailing: type == widget.recurringRule.type
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.blue_337eff,
                  )
                : null,
          )),
      onTap: () {
        setState(() {
          widget.recurringRule.type = type;
        });
      },
    );
  }

  Widget buildArrowItem(String title) {
    final checked =
        widget.recurringRule.type == NEMeetingRecurringRuleType.custom;
    return GestureDetector(
      child: Container(
          height: 56,
          color: Colors.white,
          alignment: Alignment.center,
          child: ListTile(
            title: Text(title,
                style: TextStyle(fontSize: 16, color: AppColors.black_222222)),
            trailing: checked
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.blue_337eff,
                  )
                : Icon(IconFont.iconyx_allowx,
                    size: 14, color: AppColors.greyCCCCCC),
          )),
      onTap: () {
        /// 选中状态下要点具体显示项进行跳转
        if (checked) {
          return;
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return MeetingAppLocalizationsScope(
              child: ScheduleMeetingRepeatCustomRoute(
                  widget.recurringRule, widget.startTime, widget.isEdit));
        })).then((value) => setState(() {}));
      },
    );
  }

  Widget buildCustomDetail() {
    return GestureDetector(
      child: Container(
          padding: EdgeInsets.only(left: 16, top: 6, bottom: 6),
          constraints: BoxConstraints(minHeight: 56),
          color: Colors.white,
          alignment: Alignment.center,
          child: ListTile(
              title: Text(
                getCustomRepeatDesc(),
                style: TextStyle(fontSize: 16, color: AppColors.color_999999),
                softWrap: true,
              ),
              trailing: Icon(
                IconFont.iconyx_allowx,
                size: 14,
                color: AppColors.greyCCCCCC,
              ))),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return MeetingAppLocalizationsScope(
              child: ScheduleMeetingRepeatCustomRoute(
                  widget.recurringRule, widget.startTime, widget.isEdit));
        })).then((value) => setState(() {}));
      },
    );
  }

  String getCustomRepeatDesc() {
    final customizedFrequency = widget.recurringRule.customizedFrequency;
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
            .map((e) => getWeekdayEx(e))
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
        final time = DateTime.fromMillisecondsSinceEpoch(widget.startTime);
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
            getWeekday(time.weekday));
      }
    }
    return '';
  }

  Widget buildSpace({double height = 20}) {
    return Container(
      color: AppColors.globalBg,
      height: height,
    );
  }

  Widget buildSplit() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20),
      child: Container(
        height: 0.5,
        color: AppColors.colorE8E9EB,
      ),
    );
  }

  String getWeekdayEx(NEMeetingRecurringWeekday weekday) {
    int day;
    if (weekday == NEMeetingRecurringWeekday.sunday) {
      day = 7;
    } else {
      day = weekday.index - 1;
    }
    return getWeekday(day);
  }

  String getWeekday(int day) {
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

  String getDay(DateTime time) {
    return meetingAppLocalizations.meetingDayInMonth(time.day.toString());
  }
}
