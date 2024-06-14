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
    extends ScheduleMeetingBaseState<ScheduleMeetingEditRoute> {
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
    meetingPwdSwitch.value = !TextUtil.isEmpty(meetingItem.password);
    cloudRecordOn = meetingItem.settings.cloudRecordOn;
    enableWaitingRoom.value = meetingItem.waitingRoomEnabled;
    enableJoinBeforeHost.value = meetingItem.enableJoinBeforeHost;
    enableGuestJoin.value = meetingItem.enableGuestJoin;
    attendeeAudioAutoOff.value = meetingItem.settings.isAudioOffAllowSelfOn ||
        meetingItem.settings.isAudioOffNotAllowSelfOn;
    attendeeAudioAutoOffNotAllowSelfOn =
        meetingItem.settings.isAudioOffNotAllowSelfOn;
    liveSwitch.value = meetingItem.live?.enable ?? false;
    liveLevelSwitch.value = meetingItem.live?.liveWebAccessControlLevel ==
        NEMeetingLiveAuthLevel.appToken.index;

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

    /// 同声传译
    enableInterpretation.value =
        meetingItem.interpretationSettings?.isEmpty == false;
    interpreterListController = InterpreterListController.withInterpreters(
        meetingItem.interpretationSettings?.getInterpreterList());
    TimezonesUtil.getTimezoneById(meetingItem.timezoneId)
        .then((value) => timezoneNotifier.value = value);
  }

  void callTime() {
    startTime = DateTime.fromMillisecondsSinceEpoch(meetingItem.startTime);
    endTime = DateTime.fromMillisecondsSinceEpoch(meetingItem.endTime);
  }

  @override
  String getTitle() {
    return getAppLocalizations().meetingEdit;
  }

  @override
  List<Widget> buildActions() {
    return <Widget>[
      TextButton(
        key: MeetingValueKey.scheduleBtn,
        child: Text(
          getAppLocalizations().globalSave,
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
      ToastUtils.showToast(context, getAppLocalizations().meetingEnterTopic);
      return;
    }
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
    final startTimeChanged =
        requestMeetingItem.startTime != startTime.millisecondsSinceEpoch;
    final endTimeChanged =
        requestMeetingItem.endTime != endTime.millisecondsSinceEpoch;
    if (startTimeChanged &&
        startTime.millisecondsSinceEpoch <
            DateTime.now().millisecondsSinceEpoch) {
      ToastUtils.showToast(
          context, getAppLocalizations().meetingScheduleTimeIllegal);
      return;
    }
    LoadingUtil.showLoading();
    requestMeetingItem.subject = subject;
    requestMeetingItem.scheduledMemberList = scheduledMemberList;
    requestMeetingItem.startTime =
        startTimeChanged ? startTime.millisecondsSinceEpoch : 0;
    requestMeetingItem.endTime =
        endTimeChanged ? endTime.millisecondsSinceEpoch : 0;
    requestMeetingItem.setWaitingRoomEnabled(enableWaitingRoom.value);
    requestMeetingItem.setEnableJoinBeforeHost(enableJoinBeforeHost.value);
    requestMeetingItem.setEnableGuestJoin(enableGuestJoin.value);
    requestMeetingItem.password = meetingPwdSwitch.value ? password : '';
    requestMeetingItem.timezoneId = timezoneNotifier.value?.id;
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
    setting.cloudRecordOn = cloudRecordOn;
    requestMeetingItem.settings = setting;
    var live = NEMeetingItemLive();
    live.enable = liveSwitch.value;
    live.liveWebAccessControlLevel = (liveSwitch.value && liveLevelSwitch.value)
        ? NEMeetingLiveAuthLevel.appToken
        : NEMeetingLiveAuthLevel.token;
    requestMeetingItem.live = live;
    final editRecurringMeeting = widget.isEditAll &&
        requestMeetingItem.recurringRule.type != NEMeetingRecurringRuleType.no;
    requestMeetingItem.recurringRule = recurringRule;

    requestMeetingItem.interpretationSettings = null;
    if (enableInterpretation.value) {
      final interpreters = interpreterListController?.getInterpreterList();
      if (interpreters != null) {
        requestMeetingItem.interpretationSettings =
            NEMeetingInterpretationSettings(interpreters);
      }
    }

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
                : getAppLocalizations().meetingScheduleEditSuccess,
            key: MeetingValueKey.scheduleMeetingEditSuccessToast);
        Navigator.pop(context);
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
