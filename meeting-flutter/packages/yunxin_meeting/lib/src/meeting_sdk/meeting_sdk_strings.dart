// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

class NEMeetingSDKStrings {
  static const String apiCallTooFrequent = '接口调用频繁';

  static const String imLoginErrorAnonymousLoginUnSupported = '复用NIM时不支持匿名入会';

  static const String cancelled = '已取消';

  static const String defaultAppName = '会议';

  static const String meetingIsUnderGoing = '当前会议还未结束，不能进行此类操作';

  static const String meetingIsAnonymous= '匿名入会，不支持操作自动登录';

  static const String tryAutoLoginFailedByAccountIdOrAccountTokenEmpty= 'accountId或者accountToken为空，自动登录失败';

  static const String unauthorized = '登录状态已过期，请重新登录';

  static const String meetingIdShouldNotBeEmpty = '会议号不能为空';

  static const String meetingPasswordNotValid = '会议密码不合法';

  static const String displayNameShouldNotBeEmpty = '昵称不能为空';


  static const String meetingLogPathParamsError = '参数错误，日志路径不合法或无创建权限';

}
