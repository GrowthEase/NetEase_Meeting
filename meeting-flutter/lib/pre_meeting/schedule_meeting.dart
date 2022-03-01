// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:base/util/textutil.dart';
import 'package:base/util/timeutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:yunxin_meeting/meeting_sdk.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:service/client/http_code.dart';
import 'package:uikit/const/consts.dart';
import 'package:uikit/state/meeting_base_state.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/dimem.dart';
import 'package:uikit/values/fonts.dart';
import 'package:uikit/values/strings.dart';

class ScheduleMeetingRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ScheduleMeetingRouteState();
  }
}

class _ScheduleMeetingRouteState extends MeetingBaseState<ScheduleMeetingRoute> {
  bool meetingPwdSwitch = false;

  bool attendeeAudioSwitch = false;

  bool liveSwitch = false;
  bool liveLevel = false;

  bool scheduling = false;

  String? meetingPassword;

  static const int passwordRange = 900000, basePassword = 100000, oneDay = 24 * 60 * 60 * 1000;

  late NERoomItem meetingItem;

  late DateTime startTime, endTime;
  DateTime? selectTime;

  late TextEditingController _meetingSubjectController, _meetingPasswordController;
  final FocusNode _focusNode = FocusNode();

  bool isLiveEnabled = false;

  bool attendeeRecordOn = !noCloudRecord;

  bool showMeetingRecord = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    meetingItem = NEMeetingSDK.instance.getPreMeetingService().createScheduleMeetingItem();
    generatePassword();
    _meetingPasswordController = TextEditingController(text: meetingPassword);
    _meetingSubjectController =
        TextEditingController(text: '${MeetingUtil.getNickName()}${Strings.meetingSubjectSuffix}');
    callTime();
    var settingsService = NEMeetingSDK.instance.getSettingsService();
    Future.wait([
      settingsService.isMeetingLiveEnabled(),
      settingsService.isMeetingCloudRecordEnabled(),
    ]).then((values) {
      setState(() {
        isLiveEnabled = values[0];
        // showMeetingRecord = values[1];
      });
    });
    liveLevel = false;///默认是关闭公司直播限制
  }

  void generatePassword() {
    meetingPassword = (Random().nextInt(passwordRange) + basePassword).toString();
  }

  ///会议开始时间为时间选择框，默认时间为点击会议预约当前时刻的最近一个半点时刻
  ///会议结束时间为时间选择框，默认时间为会议开始时间的下一个半点时刻
  void callTime() {
    var now = DateTime.now();

    ///
    startTime =
        DateTime(now.year, now.month, now.day, now.minute > 30 ? now.hour + 1 : now.hour, now.minute <= 30 ? 30 : 0);
    endTime = startTime.add(Duration(minutes: 30));
  }

  @override
  String getTitle() {
    return Strings.scheduleMeeting;
  }

  @override
  Widget buildBody() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      buildSpace(),
                      buildSubject(),
                      buildSpace(),
                      buildStartTime(),
                      _buildSplit(),
                      buildEndTime(),
                      buildSpace(),
                      buildPwd(),
                      if (meetingPwdSwitch) _buildSplit(),
                      if (meetingPwdSwitch) buildPwdInput(),
                      buildSpace(),
                      buildAttendeeAudio(),
                      buildSpace(),
                      if (isLiveEnabled) buildLive(),
                      if (isLiveEnabled && liveSwitch) _buildSplit(),
                      if (isLiveEnabled && liveSwitch) buildLiveLevel(),
                      if (showMeetingRecord) buildSpace(),
                      if (showMeetingRecord) buildRecord(),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: AppColors.globalBg,
                        ),
                      ),
                      buildSchedule(),
                    ],
                  ))));
        }));
  }

  Widget buildSubject() {
    return Container(
      height: Dimen.primaryItemHeight,
      color: Colors.white,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      child: TextField(
        key: MeetingValueKey.scheduleSubject,
        autofocus: false,
        focusNode: _focusNode,
        controller: _meetingSubjectController,
        keyboardAppearance: Brightness.light,
        textAlign: TextAlign.left,
        inputFormatters: [
          LengthLimitingTextInputFormatter(meetingSubjectLengthMax),
        ],
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
            hintText: '${Strings.pleaseInputMeetingSubject}',
            hintStyle: TextStyle(fontSize: 16, color: AppColors.color_999999),
            border: InputBorder.none,
            suffixIcon: _focusNode.hasFocus && !TextUtil.isEmpty(_meetingSubjectController.text)
                ? ClearIconButton(
                    key: MeetingValueKey.clearInputMeetingSubject,
                    onPressed: () {
                      _meetingSubjectController.clear();
                      setState(() {});
                    })
                : null),
        style: TextStyle(color: AppColors.color_222222, fontSize: 16),
      ),
    );
  }

  Widget buildStartTime() {
    var now = DateTime.now();
    var initDate =
        DateTime(now.year, now.month, now.day, now.minute > 30 ? now.hour + 1 : now.hour, now.minute <= 30 ? 30 : 0);
    return buildTime(Strings.meetingStartTime, startTime, initDate, null, MeetingValueKey.scheduleStartTime,
        (DateTime dateTime) {
      setState(() {
        startTime = dateTime;
        if (startTime.millisecondsSinceEpoch >= endTime.millisecondsSinceEpoch) {
          endTime = startTime.add(Duration(minutes: 30));
        } else if (endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch > oneDay) {
          endTime = startTime.add(Duration(minutes: 30));
        }
      });
    });
  }

  Widget buildEndTime() {
    return buildTime(Strings.meetingEndTime, endTime, startTime.add(Duration(minutes: 30)),
        startTime.add(Duration(days: 1)), MeetingValueKey.scheduleEndTime, (DateTime dateTime) {
      setState(() {
        endTime = dateTime;
      });
    });
  }

  Widget buildTime(
      String itemTitle, DateTime showTime, DateTime minTime, DateTime? maxTime, ValueKey key, Function function) {
    selectTime = null;
    return GestureDetector(
      key: key,
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        child: Row(
          children: <Widget>[
            Text(itemTitle, style: TextStyle(fontSize: 16, color: AppColors.black_222222)),
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
        _showCupertinoDatePicker(minTime, maxTime, function);
      },
    );
  }

  void _showCupertinoDatePicker(DateTime minTime, DateTime? maxTime, Function function) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            title(),
            Container(
                color: AppColors.white,
                height: MediaQuery.of(context).copyWith().size.height / 3,
                child: CupertinoDatePicker(
                  minimumDate: minTime,
                  maximumDate: maxTime,
                  minuteInterval: 30,
                  use24hFormat: true,
                  initialDateTime: minTime,
                  backgroundColor: AppColors.white,
                  onDateTimeChanged: (DateTime time) {
                    selectTime = time;
                  },
                )),
          ]);
        }).then((value) {
      if (value == 'done') {
        function(selectTime ?? minTime);
      }
    });
  }

  Widget title() {
    return Container(
      height: 44,
      decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: AppColors.colorF2F2F5,
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(Strings.cancel, style: TextStyle(fontSize: 14))),
          Text(Strings.chooseDate, style: TextStyle(fontSize: 17, color: AppColors.color_1f2329)),
          TextButton(
              onPressed: () {
                Navigator.pop(context, 'done');
              },
              child: Text(Strings.done, style: TextStyle(fontSize: 14, color: AppColors.blue_337eff))),
        ],
      ),
    );
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
              Strings.meetingPassword,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(valueKey: MeetingValueKey.schedulePwdSwitch, value: meetingPwdSwitch),
          CupertinoSwitch(
              key: MeetingValueKey.schedulePwdSwitch,
              value: meetingPwdSwitch,
              onChanged: (bool value) {
                setState(() {
                  meetingPwdSwitch = value;
                  if (meetingPwdSwitch && TextUtil.isEmpty(_meetingPasswordController.text)) {
                    generatePassword();
                    _meetingPasswordController.text = meetingPassword!;
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
        controller: _meetingPasswordController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(meetingPasswordLengthMax),
          FilteringTextInputFormatter.allow(RegExp(r'\d+')),
        ],
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
            hintText: '${Strings.pleaseInputMeetingPasswordHint}',
            hintStyle: TextStyle(fontSize: 14, color: AppColors.color_999999),
            border: InputBorder.none,
            suffixIcon: TextUtil.isEmpty(_meetingPasswordController.text)
                ? null
                : ClearIconButton(
                    key: MeetingValueKey.clearInputMeetingPassword,
                    onPressed: () {
                      _meetingPasswordController.clear();
                      setState(() {
                        meetingPassword = null;
                      });
                    })),
        style: TextStyle(color: AppColors.color_222222, fontSize: 16),
      ),
    );
  }

  Widget buildAttendeeAudio() {
    return Container(
      height: 56,
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Strings.meetingAttendeeAudioOff, style: TextStyle(color: AppColors.black_222222, fontSize: 16)),
                  Text(Strings.meetingAttendeeAudioOffHint,
                      style: TextStyle(color: AppColors.color_999999, fontSize: 12)),
                ],
              )),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.scheduleAttendeeAudio, value: attendeeAudioSwitch),
          CupertinoSwitch(
              key: MeetingValueKey.scheduleAttendeeAudio,
              value: attendeeAudioSwitch,
              onChanged: (bool value) {
                setState(() {
                  attendeeAudioSwitch = value;
                });
              },
              activeColor: AppColors.blue_337eff)
        ],
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
              Strings.liveOn,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(valueKey: MeetingValueKey.scheduleLiveSwitch, value: liveSwitch),
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
              Strings.liveLevelTip,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          // MeetingValueKey.addTextWidgetTest(valueKey: MeetingValueKey.scheduleLiveSwitch, value: liveSwitch),
          CupertinoSwitch(
            // key: MeetingValueKey.scheduleLiveSwitch,
              value: liveLevel,
              onChanged: (bool value) {
                setState(() {
                  liveLevel = value;
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
              Strings.recordOn,
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

  Widget buildSchedule() {
    return Container(
      padding: EdgeInsets.all(30),
      child: ElevatedButton(
        key: MeetingValueKey.scheduleBtn,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return AppColors.blue_50_337eff;
              }
              return AppColors.blue_337eff;
            }),
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(
                    color:AppColors.blue_337eff , width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: _scheduleMeeting,
        child: Text(
          Strings.scheduleNow,
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _scheduleMeeting() {
    if (scheduling) return;
    var subject = _meetingSubjectController.text.trim();
    // if (TextUtil.isEmpty(subject)) {
    //   ToastUtils.showToast(context, Strings.pleaseInputMeetingSubject);
    //   return;
    // }
    var password = _meetingPasswordController.text.trim();
    if (meetingPwdSwitch == true) {
      if (TextUtil.isEmpty(password)) {
        ToastUtils.showToast(context, Strings.pleaseInputMeetingPassword);
        return;
      } else if (password.length != 6) {
        ToastUtils.showToast(context, Strings.pleaseInputMeetingPasswordHint);
        return;
      }
    }
    if (startTime.millisecondsSinceEpoch < DateTime.now().millisecondsSinceEpoch) {
      ToastUtils.showToast(context, Strings.scheduleTimeIllegal);
      return;
    }
    scheduling = true;
    LoadingUtil.showLoading();
    meetingItem.subject = subject;
    meetingItem.startTime = startTime.millisecondsSinceEpoch;
    meetingItem.endTime = endTime.millisecondsSinceEpoch;
    meetingItem.password = meetingPwdSwitch ? password : null;
    var setting = NERoomItemSettings();
    setting.setAttendeeAudioOff = attendeeAudioSwitch;
    setting.cloudRecordOn = attendeeRecordOn;
    meetingItem.settings = setting;
    var live = NEPreRoomLiveInfo();
    live.enable = liveSwitch;
    live.webAccessControlLevel = liveSwitch && liveLevel ? NELiveAuthLevel.appToken : NELiveAuthLevel
        .token;
    meetingItem.live = live;
    NEMeetingSDK.instance.getPreMeetingService().scheduleMeeting(meetingItem).then((result) {
      LoadingUtil.cancelLoading();
      scheduling = false;
      if (result.code == HttpCode.success && result.data != null) {
        ToastUtils.showToast(
            context,
            !MeetingValueKey.inProduction
                ? '${result.data!.roomUniqueId}&${result.data!.roomId}'
                : Strings.scheduleMeetingSuccess,
            key: MeetingValueKey.scheduleMeetingSuccessToast);
        Navigator.pop(context, result.data);
      } else {
        var errorMsg = result.msg;
        errorMsg = HttpCode.getMsg(errorMsg);
        ToastUtils.showToast(context, errorMsg);
      }
    });
  }

  Widget buildSpace() {
    return Container(
      color: AppColors.globalBg,
      height: Dimen.globalPadding,
    );
  }

  Widget _buildSplit() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20),
      height: 1,
      child: Divider(height: 1),
    );
  }

  @override
  void dispose() {
    _meetingPasswordController.dispose();
    _meetingSubjectController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
