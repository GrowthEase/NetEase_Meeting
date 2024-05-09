// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nemeeting/service/util/user_preferences.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../language/meeting_localization/meeting_app_localizations.dart';

/// 默认开启白板
const bool openWhiteBoard = true;

///是否展示全体视频开/关入口

const kNoMuteAllVideo = false;

/// 默认关闭录制
const bool kNoCloudRecord = true;

///
const kNoSip = false;

const kNoMinimize = false;

const kEnablePictureInPicture = true;

/// 配置会议中开启剩余时间提醒
const kShowMeetingRemainingTip = true;

/// 开启密码登录
const kEnablePasswordLogin = !kReleaseMode;

/// 开启摇一摇打开二维码扫描
const kEnableShakeAndOpenQrScan = false;

const inMeetingMoreMenuItemId = 101;

Future<NEMeetingUIOptions> buildMeetingUIOptions({
  bool? noVideo,
  bool? noAudio,
  bool? showMeetingTime,
  bool? noCloudRecord,
  bool? audioAINSEnabled,
  required BuildContext context,
}) async {
  final meetingAppLocalizations = MeetingAppLocalizations.of(context)!;
  final settingsService = NEMeetingKit.instance.getSettingsService();
  noVideo ??= !(await settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled());
  noAudio ??= !(await settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled());
  showMeetingTime ??= await settingsService.isShowMyMeetingElapseTimeEnabled();
  final enableAudioDeviceSwitch =
      await UserPreferences().isAudioDeviceSwitchEnabled();
  // audioAINSEnabled ??= await settingsService.isAudioAINSEnabled();
  noCloudRecord ??= kNoCloudRecord;
  final showShareUserVideo = await UserPreferences().getShowShareUserVideo();
  final enableTransparentWhiteboard =
      await UserPreferences().isTransparentWhiteboardEnabled();
  final enableFrontCameraMirror =
      await UserPreferences().isFrontCameraMirrorEnabled();
  return NEMeetingUIOptions(
    noVideo: noVideo,
    noAudio: noAudio,
    noMuteAllVideo: kNoMuteAllVideo,
    noWhiteBoard: !openWhiteBoard,
    noSip: kNoSip,
    noCloudRecord: noCloudRecord,
    showScreenShareUserVideo: showShareUserVideo,
    showWhiteboardShareUserVideo: showShareUserVideo,
    showMeetingTime: showMeetingTime,
    noMinimize: kNoMinimize,
    enablePictureInPicture: kEnablePictureInPicture,
    // audioAINSEnabled: audioAINSEnabled,
    enableTransparentWhiteboard: enableTransparentWhiteboard,
    enableFrontCameraMirror: enableFrontCameraMirror,
    showMeetingRemainingTip: kShowMeetingRemainingTip,
    restorePreferredOrientations: [DeviceOrientation.portraitUp],
    extras: {'shareScreenTips': meetingAppLocalizations.meetingShareScreenTips},
    showCloudRecordMenuItem: true,
    showCloudRecordingUI: true,
    enableAudioDeviceSwitch: enableAudioDeviceSwitch,
  );
}
