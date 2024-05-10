// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/pre_meeting/schedule_meeting_base_state.dart';
import 'package:netease_meeting_core/meeting_service.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import 'package:nemeeting/utils/const_config.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:nemeeting/service/client/http_code.dart';
import '../language/localizations.dart';
import '../uikit/values/colors.dart';

class ScheduleMeetingEditRoute extends StatefulWidget {
  final NEMeetingItem item;

  /// 是否修改所有会议（周期性会议）
  final bool isEditAll;

  ScheduleMeetingEditRoute(this.item, {this.isEditAll = false});

  @override
  State<StatefulWidget> createState() {
    return _ScheduleMeetingEditRouteState(item);
  }
}

class _ScheduleMeetingEditRouteState
    extends ScheduleMeetingBaseState<ScheduleMeetingEditRoute>
    with MeetingAppLocalizationsMixin {
  _ScheduleMeetingEditRouteState(NEMeetingItem item) : super(item: item);

  bool cloudRecordOn = !kNoCloudRecord;

  @override
  bool? isEditAll() {
    return widget.isEditAll;
  }

  @override
  void initState() {
    super.initState();
    meetingPasswordController.text = meetingItem.password ?? '';
    meetingPwdSwitch = !TextUtil.isEmpty(meetingItem.password);
    cloudRecordOn = meetingItem.settings.cloudRecordOn;
    enableWaitingRoom = meetingItem.isWaitingRoomEnabled;
    enableJoinBeforeHost = meetingItem.isEnableJoinBeforeHost();
    enableGuestJoin = meetingItem.isEnableGuestJoin();
    attendeeAudioAutoOff = meetingItem.settings.isAudioOffAllowSelfOn ||
        meetingItem.settings.isAudioOffNotAllowSelfOn;
    attendeeAudioAutoOffNotAllowSelfOn =
        meetingItem.settings.isAudioOffNotAllowSelfOn;
    liveSwitch = meetingItem.live?.enable ?? false;
    liveLevelSwitch = meetingItem.live?.liveWebAccessControlLevel ==
        NELiveAuthLevel.appToken.index;

    meetingSubjectController =
        TextEditingController(text: '${meetingItem.subject}');
    callTime();

    /// 不能直接把item里的recurringRule赋值给recurringRule，只在点击保存时改
    recurringRule = NEMeetingRecurringRule(
        type: meetingItem.recurringRule.type, startTime: startTime);
    if (meetingItem.recurringRule.customizedFrequency != null) {
      recurringRule.customizedFrequency = NEMeetingCustomizedFrequency(
        stepSize: meetingItem.recurringRule.customizedFrequency!.stepSize,
        stepUnit: meetingItem.recurringRule.customizedFrequency!.stepUnit,
        daysOfMonth: meetingItem.recurringRule.customizedFrequency!.daysOfMonth,
        daysOfWeek: meetingItem.recurringRule.customizedFrequency!.daysOfWeek,
        recurringRule: WeakReference(recurringRule),
      );
    }
    if (meetingItem.recurringRule.endRule != null) {
      recurringRule.endRule = NEMeetingRecurringEndRule(
        recurringRule: WeakReference(recurringRule),
        type: meetingItem.recurringRule.endRule!.type,
        date: meetingItem.recurringRule.endRule!.date,
        times: meetingItem.recurringRule.endRule!.times,
      );
    }
  }

  void callTime() {
    startTime = DateTime.fromMillisecondsSinceEpoch(meetingItem.startTime);
    endTime = DateTime.fromMillisecondsSinceEpoch(meetingItem.endTime);
  }

  @override
  String getTitle() {
    return meetingAppLocalizations.meetingEdit;
  }

  @override
  List<Widget> buildActions() {
    return <Widget>[
      TextButton(
        key: MeetingValueKey.scheduleBtn,
        child: Text(
          meetingAppLocalizations.globalSave,
          style: TextStyle(
            color: AppColors.color_337eff,
            fontSize: 16.0,
          ),
        ),
        onPressed: _editMeeting,
      )
    ];
  }

  void _editMeeting() {
    final requestMeetingItem = meetingItem.copy();
    var subject = meetingSubjectController.text.trim();
    if (TextUtil.isEmpty(subject)) {
      ToastUtils.showToast(context, meetingAppLocalizations.meetingEnterTopic);
      return;
    }
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
    final startTimeChanged =
        requestMeetingItem.startTime != startTime.millisecondsSinceEpoch;
    final endTimeChanged =
        requestMeetingItem.endTime != endTime.millisecondsSinceEpoch;
    if (startTimeChanged &&
        startTime.millisecondsSinceEpoch <
            DateTime.now().millisecondsSinceEpoch) {
      ToastUtils.showToast(
          context, meetingAppLocalizations.meetingScheduleTimeIllegal);
      return;
    }
    LoadingUtil.showLoading();
    requestMeetingItem.subject = subject;
    requestMeetingItem.scheduledMemberList = scheduledMemberList;
    requestMeetingItem.startTime =
        startTimeChanged ? startTime.millisecondsSinceEpoch : 0;
    requestMeetingItem.endTime =
        endTimeChanged ? endTime.millisecondsSinceEpoch : 0;
    requestMeetingItem.setWaitingRoomEnabled(enableWaitingRoom);
    requestMeetingItem.setEnableJoinBeforeHost(enableJoinBeforeHost);
    requestMeetingItem.setEnableGuestJoin(enableGuestJoin);
    requestMeetingItem.password = meetingPwdSwitch == true ? password : '';
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
    setting.cloudRecordOn = cloudRecordOn;
    requestMeetingItem.settings = setting;
    var live = NEMeetingItemLive();
    live.enable = liveSwitch;
    live.liveWebAccessControlLevel = (liveSwitch && liveLevelSwitch)
        ? NELiveAuthLevel.appToken.index
        : NELiveAuthLevel.token.index;
    requestMeetingItem.live = live;
    final editRecurringMeeting = widget.isEditAll &&
        requestMeetingItem.recurringRule.type != NEMeetingRecurringRuleType.no;
    requestMeetingItem.recurringRule = recurringRule;
    NEMeetingKit.instance
        .getPreMeetingService()
        .editMeeting(requestMeetingItem, editRecurringMeeting)
        .then((result) {
      LoadingUtil.cancelLoading();
      if (result.isSuccess()) {
        ToastUtils.showToast(
            context,
            !MeetingValueKey.inProduction
                ? '${requestMeetingItem.meetingId}&${requestMeetingItem.meetingNum}'
                : meetingAppLocalizations.meetingScheduleEditSuccess,
            key: MeetingValueKey.scheduleMeetingEditSuccessToast);
        Navigator.pop(context);
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
