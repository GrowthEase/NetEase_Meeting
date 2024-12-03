// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nemeeting/base/util/global_preferences.dart';
import 'package:nemeeting/service/util/user_preferences.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import '../language/localizations.dart';
import 'meeting_util.dart';

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

Future<NEMeetingOptions> buildMeetingUIOptions({
  bool? noVideo,
  bool? noAudio,
  bool? showMeetingTime,
  bool? noCloudRecord,
  bool? audioAINSEnabled,
  required BuildContext context,
}) async {
  final title = getAppLocalizations().globalAppName;
  final settingsService = NEMeetingKit.instance.getSettingsService();
  noVideo ??= !(await settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled());
  noAudio ??= !(await settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled());
  showMeetingTime ??= await settingsService.isShowMyMeetingElapseTimeEnabled();
  final showNameInVideo = await settingsService.isShowNameInVideoEnabled();
  final showNotYetJoinedMembers =
      await settingsService.isShowNotYetJoinedMembersEnabled();
  noCloudRecord ??= kNoCloudRecord;
  final showShareUserVideo = await UserPreferences().getShowShareUserVideo();
  final enableTransparentWhiteboard =
      await settingsService.isTransparentWhiteboardEnabled();
  final enableFrontCameraMirror =
      await settingsService.isFrontCameraMirrorEnabled();
  final enableSpeakerSpotlight =
      await settingsService.isSpeakerSpotlightEnabled();
  final cloudRecordConfig = await settingsService.getCloudRecordConfig();
  final chatMessageNotificationType =
      await settingsService.getChatMessageNotificationType();
  final enableLeaveTheMeetingRequiresConfirmation =
      await settingsService.isLeaveTheMeetingRequiresConfirmationEnabled();
  return NEMeetingOptions(
    title: title,
    noVideo: noVideo,
    noAudio: noAudio,
    noMuteAllVideo: kNoMuteAllVideo,
    noWhiteBoard: !openWhiteBoard,
    noSip: kNoSip,
    cloudRecordConfig: cloudRecordConfig,
    showScreenShareUserVideo: showShareUserVideo,
    showWhiteboardShareUserVideo: showShareUserVideo,
    showMeetingTime: showMeetingTime,
    showNotYetJoinedMembers: showNotYetJoinedMembers,
    showNameInVideo: showNameInVideo,
    noMinimize: kNoMinimize,
    enablePictureInPicture: kEnablePictureInPicture,
    enableTransparentWhiteboard: enableTransparentWhiteboard,
    enableFrontCameraMirror: enableFrontCameraMirror,
    showMeetingRemainingTip: kShowMeetingRemainingTip,
    restorePreferredOrientations: [DeviceOrientation.portraitUp],
    showCloudRecordMenuItem: true,
    showCloudRecordingUI: true,
    enableSpeakerSpotlight: enableSpeakerSpotlight,
    autoEnableCaptionsOnJoin:
        await GlobalPreferences().isEnableCaptionsOnJoin(),
    chatMessageNotificationType: chatMessageNotificationType,
    enableLeaveTheMeetingRequiresConfirmation:
        enableLeaveTheMeetingRequiresConfirmation,
  );
}

NEWatermarkConfig buildNEWatermarkConfig({
  String? name,
  String? phone,
  String? email,
  String? jobNumber,
}) {
  final NEAccountService accountService =
      NEMeetingKit.instance.getAccountService();
  return NEWatermarkConfig(
    name: name ?? MeetingUtil.getNickName(),
    phone: phone ?? accountService.getAccountInfo()?.phoneNumber,
    email: email ?? accountService.getAccountInfo()?.email,
    jobNumber: jobNumber,
  );
}
