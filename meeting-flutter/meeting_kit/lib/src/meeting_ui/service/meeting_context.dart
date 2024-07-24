// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

extension NEMeetingUIRtcController on NERoomRtcController {
  Future<VoidResult> unmuteMyAudioWithCheckPermission(
      BuildContext context, String title,
      {bool needAwaitResult = true}) {
    return PermissionHelper.enableLocalAudioAndCheckPermission(
            context, true, title)
        .then((enable) async {
      if (enable) {
        var enableMediaPub = true;
        final interpController =
            Provider.of<MeetingUIState?>(context, listen: false)
                ?.interpretationController;
        if (interpController != null &&
            interpController.speakLanguage != null) {
          // 如果同声传译语言不为空，则打开麦克风时不允许开启主频道的音频pub
          enableMediaPub = false;
        }
        final result = unmuteMyAudio(enableMediaPub);
        return needAwaitResult
            ? result
            : Future.value(const VoidResult.success());
      }
      return NEResult<void>(
          code: -1,
          msg: NEMeetingUIKit.instance
              .getUIKitLocalizations()
              .globalNoPermission);
    });
  }

  Future<VoidResult> unmuteMyVideoWithCheckPermission(
      BuildContext context, String title,
      {bool needAwaitResult = true}) {
    return PermissionHelper.enableLocalVideoAndCheckPermission(
            context, true, title)
        .then((enable) {
      if (enable) {
        final result = unmuteMyVideo();
        return needAwaitResult
            ? result
            : Future.value(const VoidResult.success());
      }
      return NEResult<void>(
          code: -1,
          msg: NEMeetingUIKit.instance
              .getUIKitLocalizations()
              .globalNoPermission);
    });
  }
}
