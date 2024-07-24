// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import '../uikit/state/meeting_base_state.dart';
import '../language/localizations.dart';
import '../uikit/values/colors.dart';
import 'package:intl/intl.dart';

class ScheduleMeetingRepeatEndRoute extends StatefulWidget {
  final NEMeetingRecurringRule recurringRule;

  ScheduleMeetingRepeatEndRoute(this.recurringRule);

  @override
  State<ScheduleMeetingRepeatEndRoute> createState() =>
      _ScheduleMeetingRepeatEndRouteState();
}

class _ScheduleMeetingRepeatEndRouteState
    extends AppBaseState<ScheduleMeetingRepeatEndRoute> {
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(
        text: widget.recurringRule.endRule?.times.toString());
  }

  @override
  String getTitle() {
    return getAppLocalizations().meetingRepeatStop;
  }

  @override
  Widget buildBody() {
    return NEGestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MeetingCard(children: [
                buildCheckableItem(NEMeetingRecurringEndRuleType.date),
                if (widget.recurringRule.endRule?.type ==
                    NEMeetingRecurringEndRuleType.date)
                  buildArrowItem(
                      '${getAppLocalizations().meetingRepeatEndAt} ${widget.recurringRule.endRule?.date?.replaceAll('/', '-')}'),
                buildCheckableItem(NEMeetingRecurringEndRuleType.times),
                if (widget.recurringRule.endRule?.type ==
                    NEMeetingRecurringEndRuleType.times)
                  buildMeetingCount(),
              ]),
            ],
          ),
        ));
  }

  Widget buildCheckableItem(NEMeetingRecurringEndRuleType type) {
    final title;
    if (type == NEMeetingRecurringEndRuleType.date) {
      title = getAppLocalizations().meetingRepeatEndAtOneday;
    } else {
      title = getAppLocalizations().meetingRepeatTimes;
    }
    final checked = widget.recurringRule.endRule?.type == type;
    return MeetingCheckItem(
        title: title,
        isSelected: checked,
        onTap: () {
          if (type != widget.recurringRule.endRule?.type) {
            setState(() {
              widget.recurringRule.isEndTypeLocked = true;
              widget.recurringRule.endRule?.type = type;
            });
          }
        });
  }

  Widget buildArrowItem(String title) {
    return MeetingArrowItem(
      title: title,
      minHeight: 40,
      padding: EdgeInsets.only(
        left: 32,
        right: 16,
      ),
      titleTextStyle: TextStyle(
          color: AppColors.color_53576A,
          fontSize: 14,
          fontWeight: FontWeight.w400),
      onTap: () {
        widget.recurringRule.isEndTypeLocked = true;
        _showCupertinoDatePicker();
      },
    );
  }

  DateTime? _selectedEndTime;

  void _showCupertinoDatePicker() {
    final date = widget.recurringRule.endRule!.date;
    final initialDateTime;
    if (date == null) {
      initialDateTime = DateTime.now();
    } else {
      final format = DateFormat('yyyy/MM/dd').parse(date);
      initialDateTime =
          DateTime(format.year, format.month, format.day, 23, 59, 59);
    }
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            _timeSelectTitle(),
            Container(
                color: AppColors.white,
                height: MediaQuery.of(context).copyWith().size.height / 3,
                child: CupertinoDatePicker(
                  minimumDate: DateTime.now(),
                  maximumDate: widget.recurringRule.endRule!.calculateEndDate(
                      DateTime.now(), widget.recurringRule.maxRepeatTimes),
                  initialDateTime: initialDateTime,
                  mode: CupertinoDatePickerMode.date,
                  backgroundColor: AppColors.white,
                  onDateTimeChanged: (DateTime time) {
                    _selectedEndTime = time;
                  },
                )),
          ]);
        }).then((value) {
      if (mounted && value == 'done' && _selectedEndTime != null) {
        setState(() {
          widget.recurringRule.endRule!.date =
              DateFormat('yyyy/MM/dd').format(_selectedEndTime!);
          _inputController.text =
              widget.recurringRule.endRule!.times.toString();
        });
      }
    });
  }

  Widget _timeSelectTitle() {
    return Container(
      height: 44,
      decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: AppColors.colorF2F2F5,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(getAppLocalizations().globalCancel,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.color_1f2329,
                      fontWeight: FontWeight.normal))),
          Text(getAppLocalizations().meetingChooseDate,
              style: TextStyle(fontSize: 17, color: AppColors.color_1f2329)),
          TextButton(
              onPressed: () {
                Navigator.pop(context, 'done');
              },
              child: Text(getAppLocalizations().globalComplete,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.blue_337eff,
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget buildSpace({double height = 40}) {
    return Container(
      color: AppColors.globalBg,
      height: height,
    );
  }

  Widget buildSplit(double left) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(left: left),
      child: Container(
        height: 0.5,
        color: AppColors.colorE8E9EB,
      ),
    );
  }

  Widget buildMeetingCount() {
    return Container(
      height: 40,
      padding: EdgeInsets.only(left: 32, right: 16),
      child: Row(
        children: [
          Text(getAppLocalizations().meetingRepeatTimes,
              style: TextStyle(fontSize: 14, color: AppColors.color_53576A)),
          Expanded(child: SizedBox()),
          buildMeetingCounter(),
        ],
      ),
    );
  }

  Widget buildMeetingCounter() {
    final addEnable = widget.recurringRule.endRule?.times != null &&
        widget.recurringRule.endRule!.times <
            widget.recurringRule.maxRepeatTimes;
    final subEnable = widget.recurringRule.endRule?.times != null &&
        widget.recurringRule.endRule!.times > 1;
    final borderSide = BorderSide(
      color: AppColors.colorE1E3E5,
      width: 1,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NEGestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.color_F7F8FA,
              border: Border.fromBorderSide(borderSide),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
              ),
            ),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              '−',
              style: TextStyle(
                  fontSize: 20,
                  color: subEnable
                      ? AppColors.color_53576A
                      : AppColors.color_999999),
            ),
          ),
          onTap: () {
            if (subEnable) {
              _dealCount(false);
            }
          },
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: borderSide,
              bottom: borderSide,
            ),
          ),
          width: 52,
          height: 32,
          alignment: Alignment.center,
          child: TextField(
            controller: _inputController,
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
            ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.color_53576A,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            onChanged: (value) {
              setState(() {
                final times =
                    int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
                if (times != null) {
                  if (times > widget.recurringRule.maxRepeatTimes) {
                    widget.recurringRule.endRule!.times =
                        widget.recurringRule.maxRepeatTimes;
                  } else if (times < 1) {
                    widget.recurringRule.endRule!.times = 1;
                  } else {
                    widget.recurringRule.endRule!.times = times;
                  }
                  _inputController.text =
                      widget.recurringRule.endRule!.times.toString();
                }
              });
            },
          ),
        ),
        NEGestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.color_F7F8FA,
              border: Border.fromBorderSide(borderSide),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              '+',
              style: TextStyle(
                  fontSize: 20,
                  color: addEnable
                      ? AppColors.color_53576A
                      : AppColors.color_999999),
            ),
          ),
          onTap: () {
            if (addEnable) {
              _dealCount(true);
            }
          },
        ),
      ],
    );
  }

  _dealCount(bool isAdd) {
    widget.recurringRule.isEndTypeLocked = true;
    setState(() {
      if (widget.recurringRule.endRule?.times != null) {
        final times = widget.recurringRule.endRule!.times;
        if (isAdd) {
          if (times < widget.recurringRule.maxRepeatTimes) {
            widget.recurringRule.endRule!.times = times + 1;
          }
        } else {
          if (times > 1) {
            widget.recurringRule.endRule!.times = times - 1;
          }
        }
        _inputController.text = widget.recurringRule.endRule!.times.toString();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _inputController.dispose();
  }
}
