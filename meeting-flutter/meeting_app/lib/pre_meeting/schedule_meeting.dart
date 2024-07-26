// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_base_state.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/uikit/values/colors.dart';

import '../language/localizations.dart';
import '../service/auth/auth_manager.dart';

class ScheduleMeetingRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    final meetingItem = NEMeetingItem();
    meetingItem.ownerUserUuid = AuthManager().accountId;
    meetingItem.scheduledMemberList = [];
    return _ScheduleMeetingRouteState(meetingItem);
  }
}

class _ScheduleMeetingRouteState
    extends ScheduleMeetingBaseState<ScheduleMeetingRoute> {
  _ScheduleMeetingRouteState(NEMeetingItem meetingItem)
      : super(meetingItem, {});

  @override
  void initState() {
    super.initState();
    meetingSubjectController = TextEditingController();
    callTime();
    recurringRule = NEMeetingRecurringRule(
        type: NEMeetingRecurringRuleType.no, startTime: startTime);
    TimezonesUtil.getTimezoneById(null)
        .then((timezone) => timezoneNotifier.value = timezone);
  }

  // 是否被初始化
  bool isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInit) {
      isInit = true;
      meetingSubjectController.text =
          getAppLocalizations().meetingSubject(MeetingUtil.getNickName());
    }
  }

  ///会议开始时间为时间选择框，默认时间为点击会议预约当前时刻的最近一个半点时刻
  ///会议结束时间为时间选择框，默认时间为会议开始时间的下一个半点时刻
  void callTime() {
    var now = DateTime.now();
    startTime = DateTime(now.year, now.month, now.day,
        now.minute >= 30 ? now.hour + 1 : now.hour, now.minute < 30 ? 30 : 0);
    endTime = startTime.add(Duration(minutes: 30));
  }

  @override
  String getTitle() {
    return getAppLocalizations().meetingSchedule;
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
        onPressed: _scheduleMeeting,
      )
    ];
  }

  void _scheduleMeeting() {
    if (scheduling) return;
    var subject = meetingSubjectController.text.trim();
    // if (TextUtil.isEmpty(subject)) {
    //   ToastUtils.showToast(context, getAppLocalizations().pleaseInputMeetingSubject);
    //   return;
    // }
    var password = meetingPasswordController.text.trim();
    if (meetingPwdSwitch.value) {
      if (TextUtil.isEmpty(password)) {
        ToastUtils.showToast(
            context, getAppLocalizations().meetingEnterPassword);
        return;
      } else if (password.length != 6) {
        ToastUtils.showToast(
            context, getAppLocalizations().meetingEnterSixDigitPassword);
        return;
      }
    }
    if (startTime.millisecondsSinceEpoch <
        DateTime.now().millisecondsSinceEpoch) {
      ToastUtils.showToast(
          context, getAppLocalizations().meetingScheduleTimeIllegal);
      return;
    }
    scheduling = true;
    LoadingUtil.showLoading();
    meetingItem.recurringRule = recurringRule;
    meetingItem.subject = subject;
    meetingItem.scheduledMemberList = scheduledMemberList;
    meetingItem.startTime = startTime.millisecondsSinceEpoch;
    meetingItem.endTime = endTime.millisecondsSinceEpoch;
    meetingItem.password = meetingPwdSwitch.value ? password : null;
    meetingItem.timezoneId = timezoneNotifier.value?.id;
    var setting = NEMeetingItemSetting();
    if (attendeeAudioAutoOff.value) {
      setting.controls = [
        if (attendeeAudioAutoOffNotAllowSelfOn)
          NEMeetingAudioControl(NEMeetingAttendeeOffType.offNotAllowSelfOn)
        else
          NEMeetingAudioControl(NEMeetingAttendeeOffType.offAllowSelfOn)
      ];
    } else {
      setting.controls = null;
    }
    meetingItem.cloudRecordConfig = cloudRecordConfig;
    meetingItem.settings = setting;
    var live = NEMeetingItemLive();
    live.enable = liveSwitch.value;
    live.liveWebAccessControlLevel = liveSwitch.value && liveLevelSwitch.value
        ? NEMeetingLiveAuthLevel.appToken
        : NEMeetingLiveAuthLevel.token;
    meetingItem.live = live;
    meetingItem.noSip = kNoSip;
    meetingItem.setWaitingRoomEnabled(enableWaitingRoom.value);
    meetingItem.setEnableJoinBeforeHost(enableJoinBeforeHost.value);
    meetingItem.setEnableGuestJoin(enableGuestJoin.value);

    /// 同声传译
    meetingItem.interpretationSettings = null;
    if (enableInterpretation.value) {
      final interpreters = interpreterListController?.getInterpreterList();
      if (interpreters != null) {
        meetingItem.interpretationSettings =
            NEMeetingInterpretationSettings(interpreters);
      }
    }

    NEMeetingKit.instance
        .getPreMeetingService()
        .scheduleMeeting(meetingItem)
        .then((result) {
      LoadingUtil.cancelLoading();
      scheduling = false;
      if (!mounted) return;
      if (result.code == HttpCode.success && result.data != null) {
        ToastUtils.showToast(
            context,
            !MeetingValueKey.inProduction
                ? '${result.data!.meetingId}&${result.data!.meetingNum}'
                : getAppLocalizations().meetingScheduleSuccess,
            key: MeetingValueKey.scheduleMeetingSuccessToast);
        Navigator.pop(context, result.data);
      } else if (result.code == HttpCode.meetingDurationTooLong) {
        ToastUtils.showToast(
            context, getAppLocalizations().meetingDurationTooLong);
      } else {
        var errorMsg = result.msg;
        errorMsg = HttpCode.getMsg(errorMsg);
        ToastUtils.showToast(context, errorMsg);
      }
    });
  }
}
