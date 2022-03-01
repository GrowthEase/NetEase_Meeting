// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class TrackAppEventName{
  /// added 0.5.0
  ///应用启动
  static const String applicationInit = 'application_init';

  ///登陆
  static const String login = 'login';

  ///登出
  static const String logout = 'logout';

  ///反馈
  static const String feedback = 'feedback';

  ///注册
  static const String register = 'register';

  ///使用个人会议ID
  static const String usePersonalId = 'use_personal_id';

  ///入会时打开摄像头
  static const String openCamera = 'open_camera';

  ///入会时打开麦克风
  static const String openMicro = 'open_micro';

  ///入会时打开录制
  static const String openRecord = 'open_record';
}

class AppModuleName {
  static const String moduleName = 'nemeeting';
}