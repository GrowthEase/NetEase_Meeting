// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_kit;

class MeetingServiceUtil {
  /// 统一参数校验
  static NEResult<void>? checkParameters(
      Object param, NEMeetingKitLocalizations _localizations) {
    if ((param is NEStartMeetingParams && param.displayName.isEmpty) ||
        (param is NEJoinMeetingParams && param.displayName.isEmpty)) {
      return NEResult<void>(
          code: NEMeetingErrorCode.paramError,
          msg: _localizations.displayNameShouldNotBeEmpty);
    }

    if (param is NEStartMeetingParams &&
        (param.password != null &&
            (param.password!.length >
                    NEMeetingConstants.meetingPasswordMaxLen ||
                param.password!.length <
                    NEMeetingConstants.meetingPasswordMinLen ||
                !TextUtils.isLetterOrDigital(param.password!)))) {
      return NEResult<void>(
          code: NEMeetingErrorCode.paramError,
          msg: _localizations.meetingPasswordNotValid);
    }

    if (param is NEJoinMeetingParams && param.meetingNum.isEmpty) {
      return NEResult<void>(
          code: NEMeetingErrorCode.paramError,
          msg: _localizations.meetingIdShouldNotBeEmpty);
    }

    return null;
  }

  ///
  /// 加入会议
  /// [param] 会议参数对象，不能为空
  /// [opts]  会议选项对象，可空；当未指定时，会使用默认的选项
  /// [isInvite] 是否是邀请
  /// [localizations] 本地化
  ///
  static Future<NEResult<NERoomContext>> joinMeetingInternal(
      NEJoinMeetingParams param, NEJoinMeetingOptions opts,
      {isInvite = false,
      required NEMeetingKitLocalizations localizations}) async {
    final trackingEvent = param.trackingEvent;

    final checkParamsResult =
        MeetingServiceUtil.checkParameters(param, localizations);
    if (checkParamsResult != null) {
      return checkParamsResult.cast();
    }
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      return _handleMeetingResultCode(MeetingErrorCode.networkError).cast();
    }

    trackingEvent?.beginStep(kMeetingStepMeetingInfo);
    final meetingInfoResult =
        await MeetingRepository.getMeetingInfo(param.meetingNum);
    trackingEvent?.endStepWithResult(meetingInfoResult);
    if (!meetingInfoResult.isSuccess()) {
      return _handleMeetingResultCode(
              meetingInfoResult.code, meetingInfoResult.msg)
          .cast();
    }

    trackingEvent?.beginStep(kMeetingStepJoinRoom);
    final meetingInfo = meetingInfoResult.nonNullData;
    final authorization = meetingInfo.authorization;
    final _params = NEJoinRoomParams(
      roomUuid: meetingInfo.roomUuid,
      userName: param.displayName,
      role: MeetingRoles.kUndefined,
      password: param.password,
      avatar: param.avatar ??
          NEMeetingKit.instance.getAccountService().getAccountInfo()?.avatar,
      injectedAuthorization: authorization != null
          ? NEInjectedAuthorization(
              appKey: authorization.appKey,
              user: authorization.user,
              token: authorization.token)
          : null,
      initialMyProperties: param.tag != null && param.tag!.isNotEmpty
          ? {
              MeetingPropertyKeys.kMemberTag: param.tag!,
            }
          : null,
    );
    final _options = NEJoinRoomOptions(
      enableMyAudioDeviceOnJoinRtc: opts.enableMyAudioDeviceOnJoinRtc,
    );
    var joinRoomResult = await NERoomKit.instance.roomService.joinRoom(
      _params,
      _options,
      isInvite: isInvite,
    );
    trackingEvent?.endStepWithResult(joinRoomResult);
    if (joinRoomResult.code == MeetingErrorCode.success &&
        joinRoomResult.data != null) {
      final roomContext = joinRoomResult.nonNullData;
      roomContext.setupMeetingEnv(meetingInfo);
      return NEResult(code: NEMeetingErrorCode.success, data: roomContext);
    } else {
      return _handleMeetingResultCode(joinRoomResult.code, joinRoomResult.msg)
          .cast();
    }
  }
}
