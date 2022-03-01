// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yunxin_meeting/meeting_sdk.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:uikit/state/meeting_base_state.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/strings.dart';

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

  @override
  void initState() {
    super.initState();
    updateSettings();
  }

  void updateSettings() {
    var settingsService = NEMeetingSDK.instance.getSettingsService();
    Future.wait([
      settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled(),
      settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled(),
      settingsService.isShowMyMeetingElapseTimeEnabled(),
    ]).then((values) {
      setState(() {
        openCamera = values[0];
        openMicrophone = values[1];
        openShowMeetTime = values[2];
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
          MeetingValueKey.addTextWidgetTest(valueKey:MeetingValueKey.openCameraMeeting,value: openCamera),
          CupertinoSwitch(
              key: MeetingValueKey.openCameraMeeting,
              value: openCamera,
              onChanged: (bool value) {
                NEMeetingSDK.instance.getSettingsService().setTurnOnMyVideoWhenJoinMeeting(value);
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
          MeetingValueKey.addTextWidgetTest(valueKey:MeetingValueKey.openMicrophone,value: openMicrophone),
          CupertinoSwitch(
              key: MeetingValueKey.openMicrophone,
              value: openMicrophone,
              onChanged: (bool value) {
                NEMeetingSDK.instance.getSettingsService().setTurnOnMyAudioWhenJoinMeeting(value);
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
          MeetingValueKey.addTextWidgetTest(valueKey:MeetingValueKey.openShowMeetTime,value: openShowMeetTime),
          CupertinoSwitch(
              key: MeetingValueKey.openShowMeetTime,
              value: openShowMeetTime,
              onChanged: (bool value) {
                NEMeetingSDK.instance.getSettingsService().enableShowMyMeetingElapseTime(value);
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
