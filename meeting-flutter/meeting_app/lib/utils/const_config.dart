// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nemeeting/service/util/user_preferences.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../uikit/values/asset_name.dart';
import '../uikit/values/strings.dart';

/// 默认开启白板
const bool openWhiteBoard = true;

///是否展示全体视频开/关入口

const kNoMuteAllVideo = false;

/// 默认开启录制
const bool kNoCloudRecord = false;

///
const kNoSip = true;

/// 使用默认的短信验证码：081166
const kUseFakeCheckCode = false;

/// 配置会议中开启剩余时间提醒
const kShowMeetingRemainingTip = true;

/// 开启密码登录
const kEnablePasswordLogin = !kReleaseMode;

const inMeetingMoreMenuItemId = 101;
const inMeetingFeedbackMenu = NESingleStateMenuItem(
  itemId: inMeetingMoreMenuItemId,
  visibility: NEMenuVisibility.visibleAlways,
  singleStateItem: NEMenuItemInfo(
      text: Strings.inRoomFeedBack,
      icon: AssetName.iconInRoomFeedback,
      platformPackage: '/'),
);

Future<NEMeetingUIOptions> buildMeetingUIOptions({
  bool? noVideo,
  bool? noAudio,
  bool? showMeetingTime,
  bool? noCloudRecord,
  bool? audioAINSEnabled,
}) async {
  final settingsService = NEMeetingKit.instance.getSettingsService();
  noVideo ??= !(await settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled());
  noAudio ??= !(await settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled());
  showMeetingTime ??= await settingsService.isShowMyMeetingElapseTimeEnabled();
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
    // audioAINSEnabled: audioAINSEnabled,
    enableTransparentWhiteboard: enableTransparentWhiteboard,
    enableFrontCameraMirror: enableFrontCameraMirror,
    showMeetingRemainingTip: kShowMeetingRemainingTip,
    restorePreferredOrientations: [DeviceOrientation.portraitUp],
    extras: {'shareScreenTips': Strings.shareScreenTips},
  );
}
