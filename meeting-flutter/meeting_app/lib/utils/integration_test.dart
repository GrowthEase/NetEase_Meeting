// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

///集成测试：
///为widgets提供ValueKey，可以识别测试套件中的这些特定widgets并与之交互
class MeetingValueKey {
  /// 首页隐私协议
  static const protocolCheckBox = ValueKey('protocolCheckBox');

  /// 昵称
  static const nickName = ValueKey('nickName');

  ///匿名会页面 [AnonyMeetJoinRoute.dart]
  static const anonymousMeetJoin = ValueKey('anonymousMeetJoin');

  /// openCameraEnterMeeting = '入会时打开摄像头'
  static const openCameraEnterMeeting = ValueKey('openCameraEnterMeeting');

  ///openMicroEnterMeeting = '入会时打开麦克风'
  static const openMicroEnterMeeting = ValueKey('openMicroEnterMeeting');

  /// inputMeetingId = '请输入会议ID'
  static const inputMeetingId = ValueKey('inputMeetingId');
  static const clearAnonyMeetIdInput = ValueKey('clearAnonyMeetIdInput');

  /// hintNick = '请输入昵称'
  static const hintNick = ValueKey('hintNick');
  static const clearAnonyNickInput = ValueKey('clearAnonyNickInput');

  /// 登录模块
  /// 密码登录 [LoginByMobileWidget]
  static const hintMobile = ValueKey('hintMobile');
  static const hintPassword = ValueKey('hintPassword');
  static const showPassword = ValueKey('showPassword');
  static const login = ValueKey('login');
  static const forgetPassword = ValueKey('forgetPassword');

  ///手机验证码登录 [LoginByMobileWidget]
  ///获取验证码
  static const getCheckCode = ValueKey('getCheckCode');

  ///修改密码 [PasswordVerifyRoute]
  static const hintNewPassword = ValueKey('hintNewPassword');
  static const hintConfirmPassword = ValueKey('hintConfirmPassword');
  static const clearHintNewPasswordInput =
      ValueKey('clearHintNewPasswordInput');
  static const clearHintConfirmPasswordInput =
      ValueKey('clearHintConfirmPasswordInput');

  ///主界面模块 [HomePageRoute]
  static const tabHomeSelect = ValueKey('tabHomeSelect');
  static const tabSettingSelect = ValueKey('tabSettingSelect');

  ///设置模块
  static const personalSetting = ValueKey('personalSetting');

  ///会议设置模板[MeetingSetting]
  static const openCameraMeeting = ValueKey('openCameraMeeting');
  static const openMicrophone = ValueKey('openMicrophone');
  static const openShowMeetTime = ValueKey('openShowMeetTime');
  static const audioAINS = ValueKey('audioAINS');
  static const showShareUserVideo = ValueKey('showShareUserVideo');
  static const enableTransparentWhiteboard =
      ValueKey('enableTransparentWhiteboard');
  static const enableFrontCameraMirror = ValueKey('enableFrontCameraMirror');

  ///会议创建模板[MeetCreateRoute]
  static const userSelfMeetingNumCreateMeeting =
      ValueKey('userSelfMeetingNumCreateMeeting');
  static const openMicrophoneCreateMeeting =
      ValueKey('openMicrophoneCreateMeeting');
  static const openRecordEnterMeeting = ValueKey('openRecordEnterMeeting');
  static const openCameraCreateMeeting = ValueKey('openCameraCreateMeeting');
  static const createMeetingBtn = ValueKey('createMeetingBtn');
  static const personalMeetingId = ValueKey('personalMeetingId');

  ///返回按钮
  static const back = ValueKey('back');

  ///会议设置模板[MeetJoinRoute]
  static const openCameraJoinMeeting = ValueKey('openCameraJoinMeeting');
  static const openMicrophoneJoinMeeting =
      ValueKey('openMicrophoneJoinMeeting');
  static const joinMeetingBtn = ValueKey('joinMeetingBtn');

  /// schedule
  static const scheduleMeetingSuccessToast =
      ValueKey('scheduleMeetingSuccessToast');
  static const scheduleMeetingEditSuccessToast =
      ValueKey('scheduleMeetingEditSuccessToast');
  static const clearInputMeetingPassword =
      ValueKey('clearInputMeetingPassword');
  static const clearInputMeetingSubject = ValueKey('clearInputMeetingSubject');

  static const scheduleSubject = ValueKey('scheduleSubject');
  static const scheduleStartTime = ValueKey('scheduleStartTime');
  static const scheduleEndTime = ValueKey('scheduleEndTime');
  static const schedulePwdSwitch = ValueKey('schedulePwdSwitch');
  static const schedulePwdInput = ValueKey('schedulePwdInput');
  static const scheduleAttendeeAudio = ValueKey('scheduleAttendeeAudio');
  static const scheduleBtn = ValueKey('scheduleBtn');
  static const scheduleCancel = ValueKey('scheduleCancel');
  static const scheduleJoin = ValueKey('scheduleJoin');
  static const scheduleCopyID = ValueKey('scheduleCopyID');
  static const scheduleCopyPwd = ValueKey('scheduleCopyPwd');
  static const scheduleCopyInviteUrl = ValueKey('scheduleCopyInviteUrl');
  static const scheduleLiveSwitch = ValueKey('scheduleLiveSwitch');
  static const scheduleCopyLiveUrl = ValueKey('scheduleCopyLiveUrl');

  static const logoutByDialog = ValueKey('logoutByDialog');

  static const feedbackInput = ValueKey("feedbackInput");

  /// 非product的版本，则显示。switchButton 默认 valueKey的后缀是value = false  -1; value = true 0，
  static Widget addTextWidgetTest(
      {required bool value, required ValueKey<String> valueKey}) {
    return !inProduction
        ? Container(
            width: 60,
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: Text(
              '${valueKey.value}${value ? '0' : '-1'}',
              style: TextStyle(fontSize: 10),
            ),
          )
        : Container();
  }

  /// 非product的版本，则显示。switchButton 默认显示 valueKey
  static Widget addTextWidgetValueKey({required String text}) {
    return !inProduction
        ? Container(
            width: 120,
            color: Colors.red,
            alignment: Alignment.centerLeft,
            child: Text(
              '$text',
              style: TextStyle(fontSize: 10),
            ),
          )
        : Container();
  }

  static ValueKey dynamicValueKey(String valueKey) {
    return ValueKey(valueKey);
  }

  static const bool inProduction = bool.fromEnvironment('dart.vm.product');
}
