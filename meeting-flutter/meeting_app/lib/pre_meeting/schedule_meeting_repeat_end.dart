// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../uikit/state/meeting_base_state.dart';
import '../language/localizations.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/fonts.dart';
import 'package:intl/intl.dart';

class ScheduleMeetingRepeatEndRoute extends StatefulWidget {
  final NEMeetingRecurringRule recurringRule;

  ScheduleMeetingRepeatEndRoute(this.recurringRule);

  @override
  State<ScheduleMeetingRepeatEndRoute> createState() =>
      _ScheduleMeetingRepeatEndRouteState();
}

class _ScheduleMeetingRepeatEndRouteState
    extends MeetingBaseState<ScheduleMeetingRepeatEndRoute>
    with MeetingAppLocalizationsMixin {
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(
        text: widget.recurringRule.endRule?.times.toString());
  }

  @override
  String getTitle() {
    return meetingAppLocalizations.meetingRepeatStop;
  }

  @override
  Widget buildBody() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    buildSpace(height: 16),
                    buildCheckableItem(NEMeetingRecurringEndRuleType.date),
                    buildSplit(15),
                    if (widget.recurringRule.endRule?.type ==
                        NEMeetingRecurringEndRuleType.date)
                      buildArrowItem(
                          '${meetingAppLocalizations.meetingRepeatEndAt} ${widget.recurringRule.endRule?.date?.replaceAll('/', '-')}'),
                    if (widget.recurringRule.endRule?.type ==
                        NEMeetingRecurringEndRuleType.date)
                      buildSplit(31),
                    buildCheckableItem(NEMeetingRecurringEndRuleType.times),
                    if (widget.recurringRule.endRule?.type ==
                        NEMeetingRecurringEndRuleType.times)
                      buildSplit(15),
                    if (widget.recurringRule.endRule?.type ==
                        NEMeetingRecurringEndRuleType.times)
                      buildMeetingCount(),
                  ],
                ),
              ),
            ),
          );
        }));
  }

  Widget buildCheckableItem(NEMeetingRecurringEndRuleType type) {
    final title;
    if (type == NEMeetingRecurringEndRuleType.date) {
      title = meetingAppLocalizations.meetingRepeatEndAtOneday;
    } else {
      title = meetingAppLocalizations.meetingRepeatTimes;
    }
    final checked = widget.recurringRule.endRule?.type == type;
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
                : null,
          )),
      onTap: () {
        if (type != widget.recurringRule.endRule?.type) {
          setState(() {
            widget.recurringRule.isEndTypeLocked = true;
            widget.recurringRule.endRule?.type = type;
          });
        }
      },
    );
  }

  Widget buildArrowItem(String title) {
    return GestureDetector(
      child: Container(
          padding: EdgeInsets.only(left: 16),
          height: 56,
          color: Colors.white,
          alignment: Alignment.center,
          child: ListTile(
            title: Text(title,
                style: TextStyle(fontSize: 16, color: AppColors.color_999999)),
            trailing: Icon(IconFont.iconyx_allowx,
                size: 14, color: AppColors.greyCCCCCC),
          )),
      onTap: () {
        widget.recurringRule.isEndTypeLocked = true;
        _showCupertinoDatePicker();
      },
    );
  }

  var _time;

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
                    _time = time;
                  },
                )),
          ]);
        }).then((value) {
      if (value == 'done') {
        setState(() {
          widget.recurringRule.endRule!.date =
              DateFormat('yyyy/MM/dd').format(_time);
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
              child: Text(meetingAppLocalizations.globalCancel,
                  style:
                      TextStyle(fontSize: 14, color: AppColors.color_1f2329))),
          Text(meetingAppLocalizations.meetingChooseDate,
              style: TextStyle(fontSize: 17, color: AppColors.color_1f2329)),
          TextButton(
              onPressed: () {
                Navigator.pop(context, 'done');
              },
              child: Text(meetingAppLocalizations.globalComplete,
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
      height: 50,
      color: AppColors.white,
      padding: EdgeInsets.only(left: 36, right: 16),
      child: Container(
        child: Row(
          children: [
            Text(meetingAppLocalizations.meetingRepeatTimes,
                style: TextStyle(fontSize: 16, color: AppColors.color_999999)),
            Expanded(child: SizedBox()),
            buildMeetingCounter(),
          ],
        ),
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
        GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.color_F7F8FA,
              border: Border.fromBorderSide(borderSide),
            ),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              '−',
              style: TextStyle(
                  fontSize: 20,
                  color: subEnable
                      ? AppColors.color_222222
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
          width: 50,
          height: 32,
          child: TextField(
            controller: _inputController,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
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
        GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.color_F7F8FA,
              border: Border.fromBorderSide(borderSide),
            ),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              '+',
              style: TextStyle(
                  fontSize: 20,
                  color: addEnable
                      ? AppColors.color_222222
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
