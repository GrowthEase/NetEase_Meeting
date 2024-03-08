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

  ScheduleMeetingEditRoute(this.item);

  @override
  State<StatefulWidget> createState() {
    return _ScheduleMeetingEditRouteState(item);
  }
}

class _ScheduleMeetingEditRouteState
    extends ScheduleMeetingBaseState<ScheduleMeetingEditRoute>
    with MeetingAppLocalizationsMixin {
  NEMeetingItem item;

  _ScheduleMeetingEditRouteState(this.item);

  bool cloudRecordOn = !kNoCloudRecord;

  @override
  void initState() {
    super.initState();
    meetingPasswordController.text = item.password ?? '';
    meetingPwdSwitch = !TextUtil.isEmpty(item.password);
    cloudRecordOn = item.settings.cloudRecordOn;
    enableWaitingRoom = item.isWaitingRoomEnabled;
    attendeeAudioAutoOff = item.settings.isAudioOffAllowSelfOn ||
        item.settings.isAudioOffNotAllowSelfOn;
    attendeeAudioAutoOffNotAllowSelfOn = item.settings.isAudioOffNotAllowSelfOn;
    liveSwitch = item.live?.enable ?? false;
    liveLevelSwitch =
        item.live?.liveWebAccessControlLevel == NELiveAuthLevel.appToken.index;

    meetingSubjectController = TextEditingController(text: '${item.subject}');
    callTime();
  }

  void callTime() {
    startTime = DateTime.fromMillisecondsSinceEpoch(item.startTime);
    endTime = DateTime.fromMillisecondsSinceEpoch(item.endTime);
  }

  @override
  String getTitle() {
    return meetingAppLocalizations.meetingEdit;
  }

  @override
  Widget buildActionButton() {
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
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                side: BorderSide(color: AppColors.blue_337eff, width: 0),
                borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: _editMeeting,
        child: Text(
          meetingAppLocalizations.globalSave,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _editMeeting() {
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
    final startTimeChanged = item.startTime != startTime.millisecondsSinceEpoch;
    final endTimeChanged = item.endTime != endTime.millisecondsSinceEpoch;
    if (startTimeChanged &&
        startTime.millisecondsSinceEpoch <
            DateTime.now().millisecondsSinceEpoch) {
      ToastUtils.showToast(
          context, meetingAppLocalizations.meetingScheduleTimeIllegal);
      return;
    }
    LoadingUtil.showLoading();
    item.subject = subject;
    item.startTime = startTimeChanged ? startTime.millisecondsSinceEpoch : 0;
    item.endTime = endTimeChanged ? endTime.millisecondsSinceEpoch : 0;
    item.setWaitingRoomEnabled(enableWaitingRoom);
    item.password = meetingPwdSwitch == true ? password : '';
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
    item.settings = setting;
    // Todo: @sunjian
    var live = NEMeetingItemLive();
    live.enable = liveSwitch;
    live.liveWebAccessControlLevel = (liveSwitch && liveLevelSwitch)
        ? NELiveAuthLevel.appToken.index
        : NELiveAuthLevel.token.index;
    item.live = live;
    NEMeetingKit.instance
        .getPreMeetingService()
        .editMeeting(item)
        .then((result) {
      LoadingUtil.cancelLoading();
      if (result.isSuccess()) {
        ToastUtils.showToast(
            context,
            !MeetingValueKey.inProduction
                ? '${item.meetingId}&${item.meetingNum}'
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
