// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 提供加入会议时必要的额外参数，如会议ID、用户会议昵称等
class NEGuestJoinMeetingParams extends NEJoinMeetingParams {
  ///
  /// 访客入会验证手机号，当目标会议需要进行访客认证时需要提供。
  ///
  final String? phoneNumber;

  ///
  /// 访客入会验证码，当目标会议需要进行访客认证时需要提供。
  /// 可通过 [NEGuestService.requestSmsCodeForVerify] 接口请求获取。
  ///
  final String? smsCode;

  NEGuestJoinMeetingParams({
    this.phoneNumber,
    this.smsCode,
    required String super.meetingNum,
    required super.displayName,
    super.password,
    super.tag,
    super.avatar,
    super.encryptionConfig,
    super.watermarkConfig,
  });

  NEGuestJoinMeetingParams copyWith({
    String? phoneNumber,
    String? smsCode,
  }) {
    return NEGuestJoinMeetingParams(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      smsCode: smsCode ?? this.smsCode,
      meetingNum: this.meetingNum!,
      displayName: this.displayName,
      password: this.password,
      tag: this.tag,
      avatar: this.avatar,
      encryptionConfig: this.encryptionConfig,
      watermarkConfig: this.watermarkConfig,
    );
  }
}

///
/// 访客服务。提供访客认证、访客入会功能。
///
abstract class NEGuestService {
  /// 以访客身份加入一个当前正在进行中的会议。
  /// 加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作。
  ///
  /// [param] 会议参数对象，不能为空
  /// [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  ///
  Future<NEResult<void>> joinMeetingAsGuest(
    BuildContext context,
    NEGuestJoinMeetingParams param,
    NEMeetingOptions opts, {
    PasswordPageRouteWillPushCallback? onPasswordPageRouteWillPush,
    MeetingPageRouteWillPushCallback? onMeetingPageRouteWillPush,
    MeetingPageRouteDidPushCallback? onMeetingPageRouteDidPush,
    Widget? backgroundWidget,
  });

  ///
  /// 请求验证码用于访客入会登录认证。
  ///
  /// * [meetingNum] 会议号
  /// * [phoneNumber] 电话号码
  ///
  Future<VoidResult> requestSmsCodeForGuestJoin(
    String meetingNum,
    String phoneNumber,
  );
}
