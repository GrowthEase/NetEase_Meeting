// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netease_meeting_core/meeting_kit.dart';
import 'package:nemeeting/utils/integration_test.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/strings.dart';

class MeetingSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeetingSettingState();
  }
}

class _MeetingSettingState extends MeetingBaseState<MeetingSetting> {
  bool openCamera = false;

  bool openMicrophone = false;

  bool openShowMeetTime = false;

  bool audioAINSEnabled = false;

  @override
  void initState() {
    super.initState();
    updateSettings();
  }

  void updateSettings() {
    var settingsService = NEMeetingKit.instance.getSettingsService();
    Future.wait([
      settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled(),
      settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled(),
      settingsService.isShowMyMeetingElapseTimeEnabled(),
      settingsService.isAudioAINSEnabled(),
    ]).then((values) {
      setState(() {
        openCamera = values[0];
        openMicrophone = values[1];
        openShowMeetTime = values[2];
        audioAINSEnabled = values[3];
      });
    });
  }

  @override
  Widget buildBody() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 20),
          buildSplit(),
          buildCameraItem(),
          buildSplit(),
          buildMicrophoneItem(),
          buildSplit(),
          buildMeetTimeItem(),
          buildSplit(),
          buildSwitchItem(
            MeetingValueKey.audioAINS,
            Strings.audioAINS,
            audioAINSEnabled,
            (value) {
              NEMeetingKit.instance.getSettingsService().enableAudioAINS(value);
              setState(() {
                audioAINSEnabled = value;
              });
            },
          ),
        ]);
  }

  @override
  String getTitle() {
    return Strings.meetingSetting;
  }

  Container buildSplit() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20),
      height: 1,
      child: Divider(height: 1),
    );
  }

  Container buildSwitchItem(
    ValueKey<String> key,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      height: 56,
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
            valueKey: key,
            value: value,
          ),
          CupertinoSwitch(
            key: key,
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.blue_337eff,
          ),
        ],
      ),
    );
  }

  Container buildCameraItem() {
    return Container(
      height: 56,
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              Strings.openCameraMeeting,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.openCameraMeeting, value: openCamera),
          CupertinoSwitch(
              key: MeetingValueKey.openCameraMeeting,
              value: openCamera,
              onChanged: (bool value) {
                NEMeetingKit.instance
                    .getSettingsService()
                    .setTurnOnMyVideoWhenJoinMeeting(value);
                setState(() {
                  openCamera = value;
                });
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }

  Container buildMicrophoneItem() {
    return Container(
      height: 56,
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              Strings.openMicroMeeting,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.openMicrophone, value: openMicrophone),
          CupertinoSwitch(
              key: MeetingValueKey.openMicrophone,
              value: openMicrophone,
              onChanged: (bool value) {
                NEMeetingKit.instance
                    .getSettingsService()
                    .setTurnOnMyAudioWhenJoinMeeting(value);
                setState(() {
                  openMicrophone = value;
                });
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }

  Container buildMeetTimeItem() {
    return Container(
      height: 56,
      color: AppColors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              Strings.showMeetTime,
              style: TextStyle(color: AppColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingValueKey.addTextWidgetTest(
              valueKey: MeetingValueKey.openShowMeetTime,
              value: openShowMeetTime),
          CupertinoSwitch(
              key: MeetingValueKey.openShowMeetTime,
              value: openShowMeetTime,
              onChanged: (bool value) {
                NEMeetingKit.instance
                    .getSettingsService()
                    .enableShowMyMeetingElapseTime(value);
                setState(() {
                  openShowMeetTime = value;
                });
              },
              activeColor: AppColors.blue_337eff)
        ],
      ),
    );
  }
}
