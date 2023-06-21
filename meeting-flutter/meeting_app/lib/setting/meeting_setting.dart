// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/service/util/user_preferences.dart';
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
            false,
            NEMeetingKit.instance.getSettingsService().isAudioAINSEnabled(),
            (value) => NEMeetingKit.instance
                .getSettingsService()
                .enableAudioAINS(value),
          ),
          buildSplit(),
          buildSwitchItem(
            MeetingValueKey.showShareUserVideo,
            Strings.showShareUserVideo,
            true,
            UserPreferences().getShowShareUserVideo(),
            (value) => UserPreferences().setShowShareUserVideo(value),
          ),
          buildSplit(),
          buildSwitchItem(
            MeetingValueKey.enableTransparentWhiteboard,
            Strings.enableTransparentWhiteboard,
            false,
            UserPreferences().isTransparentWhiteboardEnabled(),
            UserPreferences().setTransparentWhiteboardEnabled,
          ),
          buildSplit(),
          buildSwitchItem(
              MeetingValueKey.enableFrontCameraMirror,
              Strings.enableFrontCameraMirror,
              true,
              UserPreferences().isFrontCameraMirrorEnabled(),
              UserPreferences().setFrontCameraMirrorEnabled)
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

  Widget buildSwitchItem(
    ValueKey<String> key,
    String label,
    bool initialData,
    Future<bool> asyncData,
    ValueChanged<bool> onDataChanged,
  ) {
    var data = initialData;
    return FutureBuilder<bool>(
      future: asyncData,
      initialData: initialData,
      builder: (context, snapshot) {
        data = snapshot.requireData;
        return StatefulBuilder(
          builder: (context, setState) {
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
                      style: TextStyle(
                          color: AppColors.black_222222, fontSize: 16),
                    ),
                  ),
                  MeetingValueKey.addTextWidgetTest(
                    valueKey: key,
                    value: data,
                  ),
                  CupertinoSwitch(
                    key: key,
                    value: data,
                    onChanged: (newValue) {
                      setState(() {
                        data = newValue;
                        onDataChanged(newValue);
                      });
                    },
                    activeColor: AppColors.blue_337eff,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildCameraItem() {
    final settings = NEMeetingKit.instance.getSettingsService();
    return buildSwitchItem(
      MeetingValueKey.openCameraMeeting,
      Strings.openCameraMeeting,
      false,
      settings.isTurnOnMyVideoWhenJoinMeetingEnabled(),
      (value) => settings.setTurnOnMyVideoWhenJoinMeeting(value),
    );
  }

  Widget buildMicrophoneItem() {
    final settings = NEMeetingKit.instance.getSettingsService();
    return buildSwitchItem(
      MeetingValueKey.openMicrophone,
      Strings.openMicroMeeting,
      false,
      settings.isTurnOnMyAudioWhenJoinMeetingEnabled(),
      (value) => settings.setTurnOnMyAudioWhenJoinMeeting(value),
    );
  }

  Widget buildMeetTimeItem() {
    final settings = NEMeetingKit.instance.getSettingsService();
    return buildSwitchItem(
      MeetingValueKey.openShowMeetTime,
      Strings.showMeetTime,
      false,
      settings.isShowMyMeetingElapseTimeEnabled(),
      (value) => settings.enableShowMyMeetingElapseTime(value),
    );
  }
}
