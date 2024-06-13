// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:nemeeting/service/util/user_preferences.dart';
import 'package:nemeeting/uikit/state/meeting_base_state.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:nemeeting/utils/integration_test.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../language/localizations.dart';

class MeetingSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeetingSettingState();
  }
}

class _MeetingSettingState extends AppBaseState {
  final settings = NEMeetingKit.instance.getSettingsService();

  @override
  Widget buildBody() {
    final settingAudioItems = getSettingAudioItems();
    final settingVideoItems = getSettingVideoItems();
    final settingCommonItems = getSettingCommonItems();
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (settingAudioItems.isNotEmpty)
              MeetingSettingGroup(
                title: NEMeetingUIKit.instance
                    .getUIKitLocalizations()
                    .settingAudio,
                iconData: IconFont.icon_audio,
                iconColor: AppColors.color_1BB650,
                children: settingAudioItems,
              ),
            if (settingVideoItems.isNotEmpty)
              MeetingSettingGroup(
                title: NEMeetingUIKit.instance
                    .getUIKitLocalizations()
                    .settingVideo,
                iconData: IconFont.icon_camera,
                iconColor: AppColors.color_1BB650,
                children: getSettingVideoItems(),
              ),
            if (settingCommonItems.isNotEmpty)
              MeetingSettingGroup(
                title: NEMeetingUIKit.instance
                    .getUIKitLocalizations()
                    .settingCommon,
                iconData: IconFont.icon_settings,
                iconColor: AppColors.color_8D90A0,
                children: getSettingCommonItems(),
              ),
            SizedBox(height: 16),
          ]),
    );
  }

  @override
  String getTitle() {
    return getAppLocalizations().settingMeeting;
  }

  /// 构建音频智能降噪选项
  MeetingSwitchItem buildAudioAINS() {
    return buildSwitchItem(
      key: MeetingUIValueKeys.audioAINS,
      label: NEMeetingUIKit.instance.getUIKitLocalizations().settingAudioAINS,
      asyncData: settings.isAudioAINSEnabled(),
      onDataChanged: (value) => settings.enableAudioAINS(value),
    );
  }

  /// 构建语音激励选项
  MeetingSwitchItem buildSpeakerSpotlight() {
    return buildSwitchItem(
        key: MeetingUIValueKeys.enableSpeakerSpotlight,
        label: NEMeetingUIKit.instance
            .getUIKitLocalizations()
            .settingSpeakerSpotlight,
        content: NEMeetingUIKit.instance
            .getUIKitLocalizations()
            .settingSpeakerSpotlightTip,
        asyncData: settings.isSpeakerSpotlightEnabled(),
        onDataChanged: (value) {
          settings.enableSpeakerSpotlight(value);
        });
  }

  /// 前置摄像头镜像
  MeetingSwitchItem buildFrontCameraMirror() {
    return buildSwitchItem(
      key: MeetingUIValueKeys.enableFrontCameraMirror,
      label: NEMeetingUIKit.instance
          .getUIKitLocalizations()
          .settingEnableFrontCameraMirror,
      asyncData: settings.isFrontCameraMirrorEnabled(),
      onDataChanged: settings.enableFrontCameraMirror,
    );
  }

  /// 通用开关选项
  MeetingSwitchItem buildSwitchItem({
    required ValueKey<String> key,
    required String label,
    required Future<bool> asyncData,
    required ValueChanged<bool> onDataChanged,
    String? content,
  }) {
    final valueNotifier = ValueNotifier<bool>(false);
    asyncData.then((value) {
      valueNotifier.value = value;
    });
    return MeetingSwitchItem(
      key: key,
      title: label,
      valueNotifier: valueNotifier,
      content: content,
      onChanged: (value) {
        onDataChanged(value);
        valueNotifier.value = value;
      },
    );
  }

  /// 白板透明
  MeetingSwitchItem buildWhiteboardTransparent() {
    return buildSwitchItem(
      key: MeetingUIValueKeys.enableTransparentWhiteboard,
      label: NEMeetingUIKit.instance
          .getUIKitLocalizations()
          .settingEnableTransparentWhiteboard,
      asyncData: settings.isTransparentWhiteboardEnabled(),
      onDataChanged: settings.enableTransparentWhiteboard,
    );
  }

  /// 显示会议持续事件
  MeetingSwitchItem buildMeetTimeItem() {
    return buildSwitchItem(
      key: MeetingUIValueKeys.openShowMeetTime,
      label: NEMeetingUIKit.instance
          .getUIKitLocalizations()
          .settingShowMeetDuration,
      asyncData: settings.isShowMyMeetingElapseTimeEnabled(),
      onDataChanged: (value) => settings.enableShowMyMeetingElapseTime(value),
    );
  }

  /// 音频模块
  List<MeetingSwitchItem> getSettingAudioItems() {
    return [
      buildMicrophoneItem(),
      buildAudioDeviceSwitch(),
      buildAudioAINS(),
      buildSpeakerSpotlight(),
    ];
  }

  /// 视频模块
  List<MeetingSwitchItem> getSettingVideoItems() {
    return [
      buildCameraItem(),
      buildFrontCameraMirror(),
      buildShowShareUserVideo(),
    ];
  }

  /// 通用模块
  List<MeetingSwitchItem> getSettingCommonItems() {
    return [
      buildMeetTimeItem(),
      buildWhiteboardTransparent(),
    ];
  }

  /// 构建音频设备切换选项
  MeetingSwitchItem buildAudioDeviceSwitch() {
    return buildSwitchItem(
        key: MeetingValueKey.enableAudioDeviceSwitch,
        label: getAppLocalizations().settingEnableAudioDeviceSwitch,
        asyncData: UserPreferences().isAudioDeviceSwitchEnabled(),
        onDataChanged: (value) {
          UserPreferences().enableAudioDeviceSwitch(value);
        });
  }

  /// 共享时开启摄像头
  MeetingSwitchItem buildShowShareUserVideo() {
    return buildSwitchItem(
      key: MeetingValueKey.showShareUserVideo,
      label: getAppLocalizations().settingShowShareUserVideo,
      asyncData: UserPreferences().getShowShareUserVideo(),
      onDataChanged: (value) => UserPreferences().setShowShareUserVideo(value),
    );
  }

  /// 构建摄像头选项
  MeetingSwitchItem buildCameraItem() {
    return buildSwitchItem(
      key: MeetingValueKey.openCameraMeeting,
      label: getAppLocalizations().settingOpenCameraMeeting,
      asyncData: settings.isTurnOnMyVideoWhenJoinMeetingEnabled(),
      onDataChanged: (value) =>
          settings.enableTurnOnMyVideoWhenJoinMeeting(value),
    );
  }

  /// 构建麦克风选项
  MeetingSwitchItem buildMicrophoneItem() {
    return buildSwitchItem(
      key: MeetingValueKey.openMicrophone,
      label: getAppLocalizations().settingOpenMicroMeeting,
      asyncData: settings.isTurnOnMyAudioWhenJoinMeetingEnabled(),
      onDataChanged: (value) =>
          settings.enableTurnOnMyAudioWhenJoinMeeting(value),
    );
  }
}
