// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/colors.dart';
import '../utils/meeting_string_util.dart';

class ScheduleMeetingRepeatCustomRoute extends StatefulWidget {
  final NEMeetingRecurringRule recurringRule;
  final int startTime;

  /// 是编辑还是创建，创建时不允许取消选择当天
  final bool isEdit;

  ScheduleMeetingRepeatCustomRoute(
      this.recurringRule, this.startTime, this.isEdit);

  @override
  State<ScheduleMeetingRepeatCustomRoute> createState() =>
      _ScheduleMeetingRepeatCustomRouteState();
}

class _ScheduleMeetingRepeatCustomRouteState
    extends AppBaseState<ScheduleMeetingRepeatCustomRoute>
    with SingleTickerProviderStateMixin {
  get _shouldShowWeek =>
      _customizedFrequency.stepUnit == NEMeetingFrequencyUnitType.weekday;

  get _shouldShowMonth =>
      _customizedFrequency.stepUnit == NEMeetingFrequencyUnitType.dayOfMonth ||
      _customizedFrequency.stepUnit ==
          NEMeetingFrequencyUnitType.weekdayOfMonth;

  get _selectedCalendarType =>
      _customizedFrequency.stepUnit == NEMeetingFrequencyUnitType.weekdayOfMonth
          ? 1
          : 0;

  /// 最大步长，月、周为12，天为30
  var _maxUnit = 12;

  /// 临时记录设置，只有点完成才会同步到item
  late NEMeetingRecurringRule recurringRule;
  late NEMeetingCustomizedFrequency _customizedFrequency;

  late FixedExtentScrollController _stepSizeController;
  late FixedExtentScrollController _stepUnitController;

  @override
  void initState() {
    super.initState();

    recurringRule = NEMeetingRecurringRule(
      type: NEMeetingRecurringRuleType.custom,
      startTime: DateTime.fromMillisecondsSinceEpoch(widget.startTime),
    );
    _customizedFrequency = NEMeetingCustomizedFrequency(
        stepSize: 0, stepUnit: NEMeetingFrequencyUnitType.day);

    if (widget.recurringRule.customizedFrequency != null) {
      _customizedFrequency.stepSize =
          widget.recurringRule.customizedFrequency!.stepSize;
      _customizedFrequency.stepUnit =
          widget.recurringRule.customizedFrequency!.stepUnit;
      _customizedFrequency.daysOfMonth = widget
          .recurringRule.customizedFrequency!.daysOfMonth
          ?.map((e) => e)
          .toList();
      _customizedFrequency.daysOfWeek = widget
          .recurringRule.customizedFrequency!.daysOfWeek
          ?.map((e) => e)
          .toList();
    }

    /// 月日历默认选中startTime
    if (_customizedFrequency.daysOfMonth == null) {
      final now = DateTime.fromMillisecondsSinceEpoch(widget.startTime).day;
      _customizedFrequency.daysOfMonth = [now];
    }

    /// 周日历默认选中startTime
    if (_customizedFrequency.daysOfWeek == null) {
      final now = DateTime.fromMillisecondsSinceEpoch(widget.startTime).weekday;
      if (now == DateTime.sunday) {
        _customizedFrequency.daysOfWeek = [NEMeetingRecurringWeekday.sunday];
      } else {
        _customizedFrequency.daysOfWeek = [
          NEMeetingRecurringWeekday.values[now + 1]
        ];
      }
    }

    /// 默认步长1
    if (_customizedFrequency.stepSize <= 0) {
      _customizedFrequency.stepSize = 1;
    }
    _maxUnit = _customizedFrequency.stepUnit == NEMeetingFrequencyUnitType.day
        ? 30
        : 12;

    _stepSizeController = FixedExtentScrollController(
      initialItem: _customizedFrequency.stepSize - 1,
    );
    _stepUnitController = FixedExtentScrollController(
      initialItem: stepUnit,
    );
    recurringRule.customizedFrequency = _customizedFrequency;
  }

  @override
  List<Widget> buildActions() {
    return <Widget>[
      TextButton(
        child: Text(
          getAppLocalizations().globalComplete,
          style: TextStyle(
            color: AppColors.color_337eff,
            fontSize: 16.0,
          ),
        ),
        onPressed: () {
          widget.recurringRule.type = NEMeetingRecurringRuleType.custom;
          widget.recurringRule.customizedFrequency = _customizedFrequency;
          widget.recurringRule.customizedFrequency?.updateTarget();
          Navigator.maybePop(context);
        },
      )
    ];
  }

  @override
  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 16, top: 16, right: 16),
          child: Text(
            MeetingStringUtil.getCustomRepeatDesc(
                recurringRule, widget.startTime),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 14,
                color: AppColors.color_1E1F27,
                fontWeight: FontWeight.w500),
          ),
        ),
        MeetingCard(children: [buildDatePicker()]),
        if (_shouldShowWeek) MeetingCard(children: [buildWeekCalendar()]),
        if (_shouldShowMonth) MeetingCard(children: [buildCalendar()]),
        SizedBox(height: 16),
      ]),
    );
  }

  @override
  String getTitle() {
    return getAppLocalizations().meetingRepeatCustom;
  }

  Widget buildDatePicker() {
    final textStyle = TextStyle(
        fontSize: 16,
        color: AppColors.color_1E1F27,
        fontWeight: FontWeight.w500);
    return Column(children: <Widget>[
      Container(
        height: 144,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40.0,
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {});
                },
                selectionOverlay: null,
                children: List<Widget>.generate(1, (int index) {
                  return Center(
                      child: Text(
                    getAppLocalizations().meetingRepeatUnitEvery,
                    style: textStyle,
                  ));
                }),
              ),
            ),

            /// 频率
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40.0,
                scrollController: _stepSizeController,
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    _customizedFrequency.stepSize = selectedItem + 1;
                  });
                },
                selectionOverlay: null,
                children: List<Widget>.generate(_maxUnit, (int index) {
                  return Center(
                      child: Text(
                    (index + 1).toString(),
                    style: textStyle,
                  ));
                }),
              ),
            ),

            /// 单位
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40.0,
                scrollController: _stepUnitController,
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    _customizedFrequency.stepUnit =
                        NEMeetingFrequencyUnitType.values[selectedItem + 1];

                    /// 切换后默认步长为1
                    _customizedFrequency.stepSize = 1;
                    _maxUnit = _customizedFrequency.stepUnit ==
                            NEMeetingFrequencyUnitType.day
                        ? 30
                        : 12;

                    _stepSizeController.jumpToItem(0);
                  });
                },
                selectionOverlay: null,
                children: List<Widget>.generate(3, (int index) {
                  return Center(
                      child: Text(
                    [
                      getAppLocalizations().meetingRepeatUnitDay,
                      getAppLocalizations().meetingRepeatUnitWeek,
                      getAppLocalizations().meetingRepeatUnitMonth
                    ][index]
                        .toString(),
                    style: textStyle,
                  ));
                }),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  get stepUnit {
    if (_customizedFrequency.stepUnit == NEMeetingFrequencyUnitType.day) {
      return 0;
    } else if (_customizedFrequency.stepUnit ==
        NEMeetingFrequencyUnitType.weekday) {
      return 1;
    } else if (_customizedFrequency.stepUnit ==
            NEMeetingFrequencyUnitType.dayOfMonth ||
        _customizedFrequency.stepUnit ==
            NEMeetingFrequencyUnitType.weekdayOfMonth) {
      return 2;
    }
  }

  Widget buildSpace({double height = 16}) {
    return Container(
      color: AppColors.globalBg,
      height: height,
    );
  }

  Widget buildWeekCalendar() {
    return Column(
      children: buildWeeks(),
    );
  }

  List<Widget> buildWeeks() {
    final List<Widget> weeks = [];
    NEMeetingRecurringWeekday.values.forEach((element) {
      if (element != NEMeetingRecurringWeekday.undefine) {
        weeks.add(buildCheckableItem(element));
      }
    });
    return weeks;
  }

  Widget buildCheckableItem(NEMeetingRecurringWeekday weekday) {
    final title = getWeekdayEx(weekday);
    final checked = _customizedFrequency.daysOfWeek?.contains(weekday);
    return NEGestureDetector(
      child: Container(
          padding: EdgeInsets.only(left: 20),
          height: 48,
          alignment: Alignment.center,
          child: Row(
            children: [
              Icon(
                checked == true
                    ? IconFont.icon_checked
                    : IconFont.icon_unchecked,
                size: 16,
                color: checked == true
                    ? AppColors.blue_337eff
                    : AppColors.color_CDCFD7,
              ),
              SizedBox(
                width: 12,
              ),
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.color_1E1F27,
                      fontWeight: FontWeight.w500)),
            ],
          )),
      onTap: () {
        setState(() {
          if (_customizedFrequency.daysOfWeek == null) {
            _customizedFrequency.daysOfWeek = [];
          }
          if (_customizedFrequency.daysOfWeek!.contains(weekday)) {
            if (widget.isEdit) {
              if (_customizedFrequency.daysOfWeek!.length != 1) {
                _customizedFrequency.daysOfWeek!.remove(weekday);
              }
            } else {
              /// 非编辑模式不能取消startTime
              int now =
                  DateTime.fromMillisecondsSinceEpoch(widget.startTime).weekday;
              NEMeetingRecurringWeekday nowWeekday;
              if (now == DateTime.sunday) {
                nowWeekday = NEMeetingRecurringWeekday.sunday;
              } else {
                nowWeekday = NEMeetingRecurringWeekday.values[now + 1];
              }
              if (weekday != nowWeekday) {
                if (_customizedFrequency.daysOfWeek!.length != 1) {
                  _customizedFrequency.daysOfWeek!.remove(weekday);
                }
              } else {
                ToastUtils.showToast(
                    context,
                    getAppLocalizations()
                        .meetingRepeatUncheckTips(getWeekday(now)));
              }
            }
          } else {
            _customizedFrequency.daysOfWeek!.add(weekday);
          }
        });
      },
    );
  }

  Widget buildCalendar() {
    return Container(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 48,
          child: Row(
            children: [
              Expanded(
                  child: TextButton(
                      child: Text(getAppLocalizations().meetingRepeatDate,
                          style: _selectedCalendarType == 0
                              ? TextStyle(
                                  color: AppColors.color_337eff, fontSize: 16)
                              : TextStyle(color: Colors.black, fontSize: 16)),
                      onPressed: () {
                        setState(() {
                          _customizedFrequency.stepUnit =
                              NEMeetingFrequencyUnitType.dayOfMonth;
                        });
                      })),
              Container(
                width: 1,
                height: 24,
                color: AppColors.colorE6E7EB,
              ),
              Expanded(
                  child: TextButton(
                      child: Text(getAppLocalizations().meetingRepeatWeekday,
                          style: _selectedCalendarType == 0
                              ? TextStyle(color: Colors.black, fontSize: 16)
                              : TextStyle(
                                  color: AppColors.color_337eff, fontSize: 16)),
                      onPressed: () {
                        setState(() {
                          _customizedFrequency.stepUnit =
                              NEMeetingFrequencyUnitType.weekdayOfMonth;
                        });
                      })),
            ],
          ),
        ),
        Container(
          height: 1,
          color: AppColors.colorE6E7EB,
        ),
        if (_selectedCalendarType == 0) buildMonth(),
        if (_selectedCalendarType == 1) buildWeek(),
      ],
    ));
  }

  Widget buildMonth() {
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width - 32,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          childAspectRatio: 1,
          crossAxisSpacing: 14,
          mainAxisSpacing: 8,
          children: List.generate(31, (index) {
            return NEGestureDetector(
              child: buildDay(index),
              onTap: () {
                setState(() {
                  if (_customizedFrequency.daysOfMonth == null) {
                    _customizedFrequency.daysOfMonth = [];
                  }
                  if (_customizedFrequency.daysOfMonth!.contains(index + 1)) {
                    if (widget.isEdit) {
                      if (_customizedFrequency.daysOfMonth!.length != 1) {
                        _customizedFrequency.daysOfMonth!.remove(index + 1);
                      }
                    } else {
                      /// 非编辑模式不能取消startTime
                      if (index !=
                          DateTime.fromMillisecondsSinceEpoch(widget.startTime)
                                  .day -
                              1) {
                        if (_customizedFrequency.daysOfMonth!.length != 1) {
                          _customizedFrequency.daysOfMonth!.remove(index + 1);
                        }
                      } else {
                        ToastUtils.showToast(
                            context,
                            getAppLocalizations().meetingRepeatUncheckTips(
                                getAppLocalizations().meetingDayInMonth(
                                    DateTime.fromMillisecondsSinceEpoch(
                                            widget.startTime)
                                        .day)));
                      }
                    }
                  } else {
                    _customizedFrequency.daysOfMonth!.add(index + 1);
                  }
                });
              },
            );
          }),
        ),
      ),
    );
  }

  Widget buildWeek() {
    return Container(
      height: 56,
      alignment: Alignment.center,
      child: Text(getDayOfWeekInMonth(widget.startTime),
          style: TextStyle(color: AppColors.color_999999),
          textAlign: TextAlign.center),
    );
  }

  String getDayOfWeekInMonth(int date) {
    final time;
    if (date == 0) {
      time = DateTime.now();
    } else {
      time = DateTime.fromMillisecondsSinceEpoch(date);
    }
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
    return getAppLocalizations().meetingRepeatOrderWeekday(
        currentWeekOfMonth, getWeekday(currentWeekDay));
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

  Widget buildDay(int index) {
    if (_customizedFrequency.daysOfMonth != null &&
        _customizedFrequency.daysOfMonth!.contains(index + 1)) {
      return Center(
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.color_337eff,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      );
    } else {
      return Container(
        child: Center(
          child: Text(
            '${index + 1}',
            style: const TextStyle(fontSize: 16, color: AppColors.black_222222),
          ),
        ),
      );
    }
  }
}
