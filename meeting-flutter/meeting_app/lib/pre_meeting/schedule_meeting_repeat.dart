// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_repeat_custom.dart';
import 'package:nemeeting/utils/meeting_string_util.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/colors.dart';

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
    extends AppBaseState<ScheduleMeetingRepeatRoute> {
  @override
  String getTitle() {
    return getAppLocalizations().meetingFrequency;
  }

  @override
  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MeetingCard(
            children: buildTypeItems(),
          ),
          MeetingCard(children: [
            buildCustomItem(getAppLocalizations().meetingRepeatCustom),
            if (widget.recurringRule.type == NEMeetingRecurringRuleType.custom)
              buildCustomDetail()
          ])
        ],
      ),
    );
  }

  List<Widget> buildTypeItems() {
    final ruleTypes = NEMeetingRecurringRuleType.values;
    final widgets = <Widget>[];
    ruleTypes.forEach((element) {
      if (element != NEMeetingRecurringRuleType.custom &&
          element != NEMeetingRecurringRuleType.undefine) {
        widgets.add(buildCheckableItem(element));
      }
    });
    return widgets;
  }

  Widget buildCheckableItem(NEMeetingRecurringRuleType type) {
    final time = DateTime.fromMillisecondsSinceEpoch(widget.startTime);
    final title;
    String? subTitle;
    switch (type) {
      case NEMeetingRecurringRuleType.no:
        title = getAppLocalizations().meetingNoRepeat;
        break;
      case NEMeetingRecurringRuleType.day:
        title = getAppLocalizations().meetingRepeatEveryday;
        break;
      case NEMeetingRecurringRuleType.weekday:
        title = getAppLocalizations().meetingRepeatEveryWeekday;
        break;
      case NEMeetingRecurringRuleType.week:
        title = getAppLocalizations().meetingRepeatEveryWeek;
        subTitle = ' (${MeetingStringUtil.getWeekday(time.weekday)})';
        break;
      case NEMeetingRecurringRuleType.twoWeeks:
        title = getAppLocalizations().meetingRepeatEveryTwoWeek;
        subTitle = ' (${MeetingStringUtil.getWeekday(time.weekday)})';
        break;
      case NEMeetingRecurringRuleType.dayOfMonth:
        title = getAppLocalizations().meetingRepeatEveryMonth;
        subTitle = ' (${MeetingStringUtil.getDay(time)})';
        break;
      default:
        title = '';
        break;
    }
    return MeetingCheckItem(
      title: title,
      subTitle: subTitle,
      isSelected: type == widget.recurringRule.type,
      onTap: () {
        setState(() {
          widget.recurringRule.type = type;
        });
      },
    );
  }

  Widget buildCustomItem(String title) {
    final isCustomSelected =
        widget.recurringRule.type == NEMeetingRecurringRuleType.custom;
    return isCustomSelected
        ? MeetingCheckItem(title: title, isSelected: true)
        : MeetingArrowItem(
            title: title,
            onTap: () {
              Navigator.of(context).push(NEMeetingPageRoute(builder: (context) {
                return ScheduleMeetingRepeatCustomRoute(
                    widget.recurringRule, widget.startTime, widget.isEdit);
              })).then((value) => setState(() {}));
            },
          );
  }

  Widget buildCustomDetail() {
    return MeetingArrowItem(
      padding: EdgeInsets.only(left: 32, right: 16, top: 3, bottom: 3),
      title: MeetingStringUtil.getCustomRepeatDesc(
          widget.recurringRule, widget.startTime),
      titleTextStyle: TextStyle(fontSize: 14, color: AppColors.color_53576A),
      onTap: () {
        Navigator.of(context).push(NEMeetingPageRoute(builder: (context) {
          return ScheduleMeetingRepeatCustomRoute(
              widget.recurringRule, widget.startTime, widget.isEdit);
        })).then((value) => setState(() {}));
      },
    );
  }
}
