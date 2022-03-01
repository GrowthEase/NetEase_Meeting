// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

///集成测试：
///为widgets提供ValueKey，可以识别测试套件中的这些特定widgets并与之交互
class ControllerMeetingCoreValueKey {
  ///会中界面 meeting_page.dart
  static const nickName = ValueKey('nickName');
  static const meetingId = ValueKey('meetingId');
  static const switchLoudspeaker = ValueKey('switchLoudspeaker');
  static const switchCamera = ValueKey('switchCamera');
  static const meetingDuration = ValueKey('meetingDuration');
  static const meetingFullScreen = ValueKey('meetingFullScreen');
  static const inputMeetingPassword = ValueKey('inputMeetingPassword');
  static const inputMeetingPasswordJoinMeeting = ValueKey('inputMeetingPasswordJoinMeeting');

  ///会议创建模板 MeetCreateRoute
  static const openMicrophoneCreateMeeting = ValueKey('openMicrophoneCreateMeeting');
  static const openCameraCreateMeeting = ValueKey('openCameraCreateMeeting');
  static const createMeetingBtn = ValueKey('createMeetingBtn');

  ///会议设置模板 MeetJoinRoute
  static const openCameraJoinMeeting = ValueKey('openCameraJoinMeeting');
  static const openMicrophoneJoinMeeting = ValueKey('openMicrophoneJoinMeeting');
  static const joinMeetingBtn = ValueKey('joinMeetingBtn');

  ///返回按钮
  static const back = ValueKey('back');

  ///会中界面 meeting_members_page.dart
  static const close = ValueKey('close');

  ///会中聊天界面 meeting_chatroom_page.dart
  static const inputMessageKey = ValueKey('inputMessageKey');
  static const chatRoomSendBtn = ValueKey('chatRoomSendBtn');
  static const chatRoomListView = ValueKey('chatRoomListView');
  static const chatRoomClose = ValueKey('chatRoomClose');

  ///会中聊天界面 meeting_members_page.dart
  static const meetingMembersLockSwitchBtn = ValueKey('meetingMembersLockSwitchBtn');

  static const minimize = ValueKey('minimize');

  static const copy = ValueKey('copy');

  ///会议直播页面
  static const inputLiveTitle = ValueKey('inputLiveTitle');
  static const clearInputLiveTitle = ValueKey('clearInputLiveTitle');
  static const copyLiveUrl = ValueKey('copyLiveUrl');
  static const copyLivePassword = ValueKey('copyLivePassword');
  static const livePwdSwitch = ValueKey('livePwdSwitch');
  static const livePwdInput = ValueKey('livePwdInput');
  static const clearInputLivePassword = ValueKey('clearInputLivePassword');
  static const liveInteraction = ValueKey('liveInteraction');
  static const liveLevel = ValueKey('liveLevel');
  static const liveStartBtn = ValueKey('liveStartBtn');
  static const liveUpdateBtn = ValueKey('liveUpdateBtn');
  static const liveStopBtn = ValueKey('liveStopBtn');
  static const liveLayoutClose = ValueKey('liveLayoutClose');
  static const liveLayoutSetting = ValueKey('liveLayoutSetting');
  static const liveLayoutGallery = ValueKey('liveLayoutGallery');
  static const liveLayoutFocus = ValueKey('liveLayoutFocus');
  static const liveLayoutScreenShare = ValueKey('liveLayoutScreenShare');

  ///美颜页面
  static const beautyLevelSlider = ValueKey('beautyLevelSlider');
  static const beautyPageClose = ValueKey('beautyPageClose');

  /// 非product的版本，则显示。switchButton 默认 valueKey的后缀是value = false  -1; value = true 0，
  static Widget addTextWidgetTest({bool? value, ValueKey<String>? valueKey}) {
    return !inProduction
        ? Container(
            width: 60,
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: Text(
              '${valueKey?.value}${(value??false) ? '0' : '-1'}',
              style: TextStyle(color: Color(0xff222222), fontSize: 10),
            ),
          )
        : Container();
  }

  static const bool inProduction = bool.fromEnvironment('dart.vm.product');
}
