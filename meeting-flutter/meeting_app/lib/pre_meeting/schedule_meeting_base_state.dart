// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../base/util/text_util.dart';
import '../base/util/timeutil.dart';
import '../language/localizations.dart';
import '../uikit/const/consts.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';
import '../uikit/values/fonts.dart';
import '../utils/const_config.dart';
import '../utils/integration_test.dart';

import '../widget/switch_item.dart';

abstract class ScheduleMeetingBaseState<T extends StatefulWidget>
    extends MeetingBaseState<T> with MeetingAppLocalizationsMixin {
  bool meetingPwdSwitch = false;
  bool enableWaitingRoom = false;

  bool attendeeAudioAutoOff = false;
  bool attendeeAudioAutoOffNotAllowSelfOn = false;

  bool liveSwitch = false;
  bool liveLevelSwitch = false;

  bool scheduling = false;

  static const int passwordRange = 900000,
      basePassword = 100000,
      oneDay = 24 * 60 * 60 * 1000;

  late NEMeetingItem meetingItem;

  late DateTime startTime, endTime;

  late TextEditingController meetingSubjectController,
      meetingPasswordController;
  final FocusNode focusNode = FocusNode();

  bool isLiveEnabled = false;

  bool attendeeRecordOn = !kNoCloudRecord;

  bool showMeetingRecord = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {});
    });
    meetingPasswordController = TextEditingController();
    var settingsService = NEMeetingKit.instance.getSettingsService();
    Future.wait([
      settingsService.isMeetingLiveEnabled(),
      settingsService.isMeetingCloudRecordEnabled(),
    ]).then((values) {
      setState(() {
        isLiveEnabled = values[0];
        // showMeetingRecord = values[1];
      });
    });
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
                      buildPartTitle(meetingAppLocalizations.meetingInfo),
                      buildSubject(
                          focusNode: focusNode,
                          controller: meetingSubjectController),
                      buildSpace(),
                      buildStartTime(
                          startTime: startTime,
                          endTime: endTime,
                          selectTimeCallback: (dateTime) {
                            setState(() {
                              startTime = dateTime;
                              if (startTime.millisecondsSinceEpoch >=
                                  endTime.millisecondsSinceEpoch) {
                                endTime = startTime.add(Duration(minutes: 30));
                              } else if (endTime.millisecondsSinceEpoch -
                                      startTime.millisecondsSinceEpoch >
                                  oneDay) {
                                endTime = startTime.add(Duration(minutes: 30));
                              }
                            });
                          }),
                      buildSplit(),
                      buildEndTime(
                          startTime: startTime,
                          endTime: endTime,
                          selectTimeCallback: (dateTime) {
                            setState(() {
                              endTime = dateTime;
                            });
                          }),
                      buildPartTitle(meetingAppLocalizations.meetingSecurity),
                      buildPwd(),
                      if (meetingPwdSwitch) buildSplit(),
                      if (meetingPwdSwitch) buildPwdInput(),
                      if (context.isWaitingRoomEnabled) buildSpace(),
                      if (context.isWaitingRoomEnabled)
                        SwitchItem(
                            key: MeetingValueKey.scheduleWaitingRoom,
                            value: enableWaitingRoom,
                            title: meetingAppLocalizations
                                .meetingEnableWaitingRoom,
                            summary:
                                meetingAppLocalizations.meetingWaitingRoomHint,
                            onChange: (value) {
                              setState(() {
                                enableWaitingRoom = value;
                              });
                            }),
                      buildPartTitle(meetingAppLocalizations.settingMeeting),
                      SwitchItem(
                          key: MeetingValueKey.scheduleAttendeeAudio,
                          value: attendeeAudioAutoOff,
                          title:
                              meetingAppLocalizations.meetingAttendeeAudioOff,
                          onChange: (value) {
                            setState(() {
                              attendeeAudioAutoOff = value;
                            });
                          }),
                      if (attendeeAudioAutoOff) ...[
                        buildSplit(),
                        buildRadio(
                            value: false,
                            padding: EdgeInsets.only(
                                left: 20, right: 16, top: 17, bottom: 12),
                            title: meetingAppLocalizations
                                .meetingAttendeeAudioOffAllowOn,
                            groupValue: attendeeAudioAutoOffNotAllowSelfOn,
                            onChanged: (_) {
                              attendeeAudioAutoOffNotAllowSelfOn = false;
                              setState(() {});
                            }),
                        buildRadio(
                            value: true,
                            padding: EdgeInsets.only(
                                left: 20, right: 16, bottom: 17),
                            title: meetingAppLocalizations
                                .meetingAttendeeAudioOffNotAllowOn,
                            groupValue: attendeeAudioAutoOffNotAllowSelfOn,
                            onChanged: (_) {
                              attendeeAudioAutoOffNotAllowSelfOn = true;
                              setState(() {});
                            }),
                      ],
                      buildSpace(),
                      if (isLiveEnabled) buildLive(),
                      if (isLiveEnabled && liveSwitch) buildSplit(),
                      if (isLiveEnabled && liveSwitch) buildLiveLevel(),
                      if (showMeetingRecord) buildSpace(),
                      if (showMeetingRecord) buildRecord(),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: AppColors.globalBg,
                        ),
                      ),
                      buildActionButton(),
                    ],
                  ))));
        }));
  }

  Widget buildActionButton();

  Widget buildRadio({
    required String title,
    required bool value,
    required bool groupValue,
    required Function(bool?)? onChanged,
    EdgeInsetsGeometry? padding,
  }) {
    return GestureDetector(
      child: Container(
        padding: padding,
        color: Colors.white,
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              child: Radio<bool>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return AppColors.blue_337eff.withOpacity(
                      states.contains(MaterialState.disabled) ? 0.5 : 1.0,
                    );
                  }
                  return null;
                }),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.black_333333,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none))),
          ],
        ),
      ),
      onTap: () => onChanged?.call(value),
    );
  }

  Widget buildPartTitle(String title) {
    return Container(
      color: AppColors.globalBg,
      padding: EdgeInsets.only(left: 20, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.color_999999,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget buildSpace({double height = 10}) {
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
        height: 1,
        color: AppColors.colorE8E9EB,
      ),
    );
  }

  Widget buildSubject(
      {FocusNode? focusNode, TextEditingController? controller}) {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      child: TextField(
        key: MeetingValueKey.scheduleSubject,
        autofocus: false,
        focusNode: focusNode,
        controller: controller,
        keyboardAppearance: Brightness.light,
        textAlign: TextAlign.left,
        inputFormatters: [
          LengthLimitingTextInputFormatter(meetingSubjectLengthMax),
        ],
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
            hintText: '${meetingAppLocalizations.meetingEnterTopic}',
            hintStyle: TextStyle(fontSize: 16, color: AppColors.color_999999),
            border: InputBorder.none,
            suffixIcon: focusNode?.hasFocus == true &&
                    !TextUtil.isEmpty(controller?.text)
                ? ClearIconButton(
                    key: MeetingValueKey.clearInputMeetingSubject,
                    onPressed: () {
                      controller?.clear();
                      setState(() {});
                    })
                : null),
        style: TextStyle(color: AppColors.color_222222, fontSize: 16),
      ),
    );
  }

  Widget buildStartTime(
      {required DateTime startTime,
      required DateTime endTime,
      required Function(DateTime dateTime) selectTimeCallback}) {
    var now = DateTime.now();
    var initDate = DateTime(now.year, now.month, now.day,
        now.minute > 30 ? now.hour + 1 : now.hour, now.minute <= 30 ? 30 : 0);
    return buildTime(meetingAppLocalizations.meetingStartTime, startTime,
        initDate, null, MeetingValueKey.scheduleStartTime, selectTimeCallback);
  }

  Widget buildEndTime(
      {required DateTime startTime,
      required DateTime endTime,
      required Function(DateTime dateTime) selectTimeCallback}) {
    return buildTime(
        meetingAppLocalizations.meetingEndTime,
        endTime,
        startTime.add(Duration(minutes: 30)),
        startTime.add(Duration(days: 1)),
        MeetingValueKey.scheduleEndTime,
        selectTimeCallback);
  }

  Widget buildTime(
      String itemTitle,
      DateTime showTime,
      DateTime minTime,
      DateTime? maxTime,
      ValueKey key,
      Function(DateTime dateTime) selectTimeCallback) {
    return GestureDetector(
      key: key,
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        child: Row(
          children: <Widget>[
            Text(itemTitle,
                style: TextStyle(fontSize: 16, color: AppColors.black_222222)),
            Spacer(),
            Text(TimeUtil.timeFormatWithMinute(showTime),
                style: TextStyle(fontSize: 14, color: AppColors.color_999999)),
            SizedBox(
              width: 8,
            ),
            Icon(IconFont.iconyx_allowx, size: 14, color: AppColors.greyCCCCCC)
          ],
        ),
      ),
      onTap: () {
        _showCupertinoDatePicker(
            minTime, maxTime, showTime, selectTimeCallback);
      },
    );
  }

  void _showCupertinoDatePicker(
    final DateTime minTime,
    DateTime? maxTime,
    DateTime? initialDateTime,
    Function(DateTime dateTime) selectTimeCallback,
  ) {
    if (initialDateTime != null) {
      if (initialDateTime.isBefore(minTime)) {
        initialDateTime = minTime;
      } else if (maxTime != null && initialDateTime.isAfter(maxTime)) {
        initialDateTime = maxTime;
      }
    }
    var selectTime = minTime;
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
                  minimumDate: minTime,
                  maximumDate: maxTime,
                  minuteInterval: 30,
                  use24hFormat: true,
                  initialDateTime: initialDateTime ?? minTime,
                  backgroundColor: AppColors.white,
                  onDateTimeChanged: (DateTime time) {
                    selectTime = time;
                  },
                )),
          ]);
        }).then((value) {
      if (value == 'done') {
        selectTimeCallback.call(selectTime);
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
                  style: TextStyle(fontSize: 14))),
          Text(meetingAppLocalizations.meetingChooseDate,
              style: TextStyle(fontSize: 17, color: AppColors.color_1f2329)),
          TextButton(
              onPressed: () {
                Navigator.pop(context, 'done');
              },
              child: Text(meetingAppLocalizations.globalComplete,
                  style:
                      TextStyle(fontSize: 14, color: AppColors.blue_337eff))),
        ],
      ),
    );
  }

  void _generatePassword() {
    meetingPasswordController.text =
        (Random().nextInt(passwordRange) + basePassword).toString();
  }

  Widget buildPwd() {
    return Container(
      height: 56,
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              meetingAppLocalizations.meetingPassword,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.schedulePwdSwitch,
              value: meetingPwdSwitch),
          CupertinoSwitch(
              key: MeetingValueKey.schedulePwdSwitch,
              value: meetingPwdSwitch,
              onChanged: (bool value) {
                setState(() {
                  meetingPwdSwitch = value;
                  if (meetingPwdSwitch &&
                      TextUtil.isEmpty(meetingPasswordController.text)) {
                    _generatePassword();
                  }
                });
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }

  Widget buildPwdInput() {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      alignment: Alignment.center,
      child: TextField(
        key: MeetingValueKey.schedulePwdInput,
        autofocus: false,
        keyboardAppearance: Brightness.light,
        controller: meetingPasswordController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(meetingPasswordLengthMax),
          FilteringTextInputFormatter.allow(RegExp(r'\d+')),
        ],
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
            hintText: '${meetingAppLocalizations.meetingEnterSixDigitPassword}',
            hintStyle: TextStyle(fontSize: 14, color: AppColors.color_999999),
            border: InputBorder.none,
            suffixIcon: TextUtil.isEmpty(meetingPasswordController.text)
                ? null
                : ClearIconButton(
                    key: MeetingValueKey.clearInputMeetingPassword,
                    onPressed: () {
                      meetingPasswordController.clear();
                    })),
        style: TextStyle(color: AppColors.color_222222, fontSize: 16),
      ),
    );
  }

  Widget buildLive() {
    return Container(
      height: 56,
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              meetingAppLocalizations.meetingLiveOn,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.scheduleLiveSwitch, value: liveSwitch),
          CupertinoSwitch(
              key: MeetingValueKey.scheduleLiveSwitch,
              value: liveSwitch,
              onChanged: (bool value) {
                setState(() {
                  liveSwitch = value;
                });
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }

  Widget buildLiveLevel() {
    return Container(
      height: 56,
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              meetingAppLocalizations.meetingLiveLevelTip,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          // MeetingValueKey.addTextWidgetTest(valueKey: MeetingValueKey.scheduleLiveSwitch, value: liveSwitch),
          CupertinoSwitch(
              key: MeetingValueKey.scheduleLiveLevel,
              value: liveLevelSwitch,
              onChanged: (bool value) {
                setState(() {
                  liveLevelSwitch = value;
                });
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }

  Widget buildRecord() {
    return Container(
      height: 56,
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              meetingAppLocalizations.meetingRecordOn,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          // MeetingValueKey.addTextWidgetTest(valueKey: MeetingValueKey.scheduleLiveSwitch, value: liveSwitch),
          CupertinoSwitch(
              // key: MeetingValueKey.scheduleLiveSwitch,
              value: attendeeRecordOn,
              onChanged: (bool value) {
                setState(() {
                  attendeeRecordOn = value;
                });
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }

  @override
  void dispose() {
    meetingPasswordController.dispose();
    meetingSubjectController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
