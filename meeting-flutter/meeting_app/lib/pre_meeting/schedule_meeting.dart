// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_base_state.dart';
import 'package:netease_meeting_core/meeting_service.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/uikit/values/colors.dart';

import '../language/localizations.dart';

class ScheduleMeetingRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ScheduleMeetingRouteState();
  }
}

class _ScheduleMeetingRouteState
    extends ScheduleMeetingBaseState<ScheduleMeetingRoute>
    with MeetingAppLocalizationsMixin {
  @override
  void initState() {
    super.initState();
    meetingItem = NEMeetingItem();
    meetingSubjectController = TextEditingController();
    callTime();
    recurringRule = NEMeetingRecurringRule(
        type: NEMeetingRecurringRuleType.no, startTime: startTime);
  }

  // 是否被初始化
  bool isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInit) {
      isInit = true;
      meetingSubjectController.text =
          meetingAppLocalizations.meetingSubject(MeetingUtil.getNickName());
    }
  }

  ///会议开始时间为时间选择框，默认时间为点击会议预约当前时刻的最近一个半点时刻
  ///会议结束时间为时间选择框，默认时间为会议开始时间的下一个半点时刻
  void callTime() {
    var now = DateTime.now();
    startTime = DateTime(now.year, now.month, now.day,
        now.minute > 30 ? now.hour + 1 : now.hour, now.minute <= 30 ? 30 : 0);
    endTime = startTime.add(Duration(minutes: 30));
  }

  @override
  String getTitle() {
    return meetingAppLocalizations.meetingSchedule;
  }

  @override
  List<Widget> buildActions() {
    return <Widget>[
      TextButton(
        child: Text(
          meetingAppLocalizations.globalComplete,
          style: TextStyle(
            color: AppColors.color_337eff,
            fontSize: 16.0,
          ),
        ),
        onPressed: _scheduleMeeting,
      )
    ];
  }

  void _scheduleMeeting() {
    if (scheduling) return;
    var subject = meetingSubjectController.text.trim();
    // if (TextUtil.isEmpty(subject)) {
    //   ToastUtils.showToast(context, meetingAppLocalizations.pleaseInputMeetingSubject);
    //   return;
    // }
    var password = meetingPasswordController.text.trim();
    if (meetingPwdSwitch == true) {
      if (TextUtil.isEmpty(password)) {
        ToastUtils.showToast(
            context, meetingAppLocalizations.meetingEnterPassword);
        return;
      } else if (password.length != 6) {
        ToastUtils.showToast(
            context, meetingAppLocalizations.meetingEnterSixDigitPassword);
        return;
      }
    }
    if (startTime.millisecondsSinceEpoch <
        DateTime.now().millisecondsSinceEpoch) {
      ToastUtils.showToast(
          context, meetingAppLocalizations.meetingScheduleTimeIllegal);
      return;
    }
    scheduling = true;
    LoadingUtil.showLoading();
    meetingItem.recurringRule = recurringRule;
    meetingItem.subject = subject;
    meetingItem.startTime = startTime.millisecondsSinceEpoch;
    meetingItem.endTime = endTime.millisecondsSinceEpoch;
    meetingItem.password = meetingPwdSwitch ? password : null;
    var setting = NEMeetingItemSettings();
    if (attendeeAudioAutoOff) {
      setting.controls = [
        if (attendeeAudioAutoOffNotAllowSelfOn)
          NERoomAudioControl(NERoomAttendeeOffType.offNotAllowSelfOn)
        else
          NERoomAudioControl(NERoomAttendeeOffType.offAllowSelfOn)
      ];
    } else {
      setting.controls = null;
    }
    setting.cloudRecordOn = attendeeRecordOn;
    meetingItem.settings = setting;
    var live = NEMeetingItemLive();
    live.enable = liveSwitch;
    live.liveWebAccessControlLevel = liveSwitch && liveLevelSwitch
        ? NELiveAuthLevel.appToken.index
        : NELiveAuthLevel.token.index;
    meetingItem.live = live;
    meetingItem.noSip = kNoSip;
    meetingItem.setWaitingRoomEnabled(enableWaitingRoom);
    meetingItem.setEnableJoinBeforeHost(enableJoinBeforeHost);
    NEMeetingKit.instance
        .getPreMeetingService()
        .scheduleMeeting(meetingItem)
        .then((result) {
      LoadingUtil.cancelLoading();
      scheduling = false;
      if (result.code == HttpCode.success && result.data != null) {
        ToastUtils.showToast(
            context,
            !MeetingValueKey.inProduction
                ? '${result.data!.meetingId}&${result.data!.meetingNum}'
                : meetingAppLocalizations.meetingScheduleSuccess,
            key: MeetingValueKey.scheduleMeetingSuccessToast);
        Navigator.pop(context, result.data);
      } else if (result.code == HttpCode.meetingDurationTooLong) {
        ToastUtils.showToast(
            context, meetingAppLocalizations.meetingDurationTooLong);
      } else {
        var errorMsg = result.msg;
        errorMsg = HttpCode.getMsg(errorMsg);
        ToastUtils.showToast(context, errorMsg);
      }
    });
  }
}
