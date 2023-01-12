// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEMeetingServiceImpl extends NEMeetingService
    with _AloggerMixin, EventTrackMixin, _MeetingKitLocalizationsMixin {
  static final _NEMeetingServiceImpl _instance = _NEMeetingServiceImpl._();

  factory _NEMeetingServiceImpl() => _instance;

  final _roomService = NERoomKit.instance.roomService;

  _NEMeetingServiceImpl._();

  @override
  Future<NEResult<NERoomContext>> startMeeting(
    NEStartMeetingParams param,
    NEStartMeetingOptions opts,
  ) async {
    apiLogger.i('startMeeting');

    final checkParamsResult = checkParameters(param);
    if (checkParamsResult != null) {
      return checkParamsResult.cast();
    }
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      return _handleMeetingResultCode(MeetingErrorCode.networkError).cast();
    }

    // 如果指定了会议ID，需要检查会议ID是否为个人会议ID或个人会议短ID
    final meetingId = param.meetingId;
    final accountInfo =
        NEMeetingKit.instance.getAccountService().getAccountInfo();
    if (meetingId != null &&
        meetingId.isNotEmpty &&
        accountInfo != null &&
        meetingId != accountInfo.privateShortMeetingNum &&
        meetingId != accountInfo.privateMeetingNum) {
      return NEResult(
        code: NEMeetingErrorCode.paramError,
        msg: 'MeetingId is incorrect',
      );
    }

    final roomProperties = {};
    param.controls?.forEach((control) {
      if (control is NERoomAudioControl) {
        roomProperties[AudioControlProperty.key] =
            control.attendeeOff == NERoomAttendeeOffType.none
                ? AudioControlProperty.disable
                : (control.attendeeOff == NERoomAttendeeOffType.offAllowSelfOn
                    ? AudioControlProperty.offAllowSelfOn
                    : AudioControlProperty.offNotAllowSelfOn);
      }
      if (control is NERoomVideoControl) {
        roomProperties[VideoControlProperty.key] =
            control.attendeeOff == NERoomAttendeeOffType.none
                ? VideoControlProperty.disable
                : (control.attendeeOff == NERoomAttendeeOffType.offAllowSelfOn
                    ? VideoControlProperty.offAllowSelfOn
                    : VideoControlProperty.offNotAllowSelfOn);
      }
    });
    if (param.extraData?.isNotEmpty ?? false) {
      roomProperties[MeetingPropertyKeys.kExtraData] = param.extraData;
    }
    late MeetingInfo _meetingInfo;
    late NERoomContext _roomContext;
    return MeetingRepository.createMeeting(
      type: (param.meetingId?.isNotEmpty ?? false)
          ? NEMeetingType.kPersonal
          : NEMeetingType.kRandom,
      subject: param.subject,
      password: param.password,
      roomConfigId: kMeetingTemplateId,
      roomProperties: roomProperties,
      roleBinds: param.roleBinds?.map((key, value) {
        var roleType = MeetingRoles.mapEnumRoleToString(value);
        return MapEntry(key, roleType);
      }),
      featureConfig: NEMeetingFeatureConfig(
        enableChatroom: !opts.noChat,
        enableLive: false,
        enableWhiteboard: SettingsRepository.isMeetingWhiteboardSupported(),
        enableRecord: !opts.noCloudRecord &&
            SettingsRepository.isMeetingCloudRecordSupported(),
        enableSip: !opts.noSip && SettingsRepository.isSipSupported(),
      ),
    ).map<NERoomContext>((meetingInfo) {
      _meetingInfo = meetingInfo;
      return _roomService.joinRoom(
        NEJoinRoomParams(
          roomUuid: meetingInfo.roomUuid,
          userName: param.displayName,
          role: MeetingRoles.kHost,
          password: param.password,
          initialMyProperties: param.tag != null && param.tag!.isNotEmpty
              ? {
                  MeetingPropertyKeys.kMemberTag: param.tag!,
                }
              : null,
        ),
        NEJoinRoomOptions(
          enableMyAudioDeviceOnJoinRtc: opts.enableMyAudioDeviceOnJoinRtc,
        ),
      );
    }).map<void>((roomContext) async {
      _roomContext = roomContext;
      return NEResult<void>(code: NEMeetingErrorCode.success);
    }).then((result) {
      trackPeriodicEvent(TrackEventName.meetingJoinFailed,
          extra: {'value': result.code});
      return _handleMeetingResultCode(result.code, result.msg);
    }).map(() {
      return _roomContext..setupMeetingEnv(_meetingInfo);
    });
  }

  NEResult<void> _handleMeetingResultCode(int code, [String? msg]) {
    if (code == MeetingErrorCode.success) {
      return NEResult<void>(code: NEMeetingErrorCode.success);
    } else if (code == MeetingErrorCode.meetingAlreadyExists) {
      return NEResult<void>(
          code: NEMeetingErrorCode.meetingAlreadyExist, msg: msg);
    } else if (code == MeetingErrorCode.networkError) {
      return NEResult<void>(
          code: NEMeetingErrorCode.noNetwork,
          msg: localizations.networkUnavailableCheck);
    } else if (code == MeetingErrorCode.unauthorized) {
      return NEResult<void>(
          code: NEMeetingErrorCode.noAuth,
          msg: msg ?? localizations.unauthorized);
    } else if (code == MeetingErrorCode.roomLock) {
      return NEResult<void>(
          code: NEMeetingErrorCode.meetingLocked,
          msg: localizations.meetingLocked);
    } else if (code == MeetingErrorCode.meetingNotInProgress) {
      return NEResult<void>(
          code: NEMeetingErrorCode.meetingNotInProgress,
          msg: localizations.meetingNotExist);
    } else if (code == NEMeetingErrorCode.meetingNotExist) {
      return NEResult<void>(
          code: NEMeetingErrorCode.meetingNotExist,
          msg: localizations.meetingNotExist);
    } else {
      return NEResult<void>(code: code, msg: msg);
    }
  }

  @override
  Future<NEResult<NERoomContext>> joinMeeting(
    NEJoinMeetingParams param,
    NEJoinMeetingOptions opts,
  ) async {
    apiLogger.i('joinMeeting');

    final checkParamsResult = checkParameters(param);
    if (checkParamsResult != null) {
      return checkParamsResult.cast();
    }
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      return _handleMeetingResultCode(MeetingErrorCode.networkError).cast();
    }

    final meetingInfoResult =
        await MeetingRepository.getMeetingInfo(param.meetingId);
    if (!meetingInfoResult.isSuccess()) {
      return _handleMeetingResultCode(
              meetingInfoResult.code, meetingInfoResult.msg)
          .cast();
    }

    var joinRoomResult = await _roomService.joinRoom(
      NEJoinRoomParams(
        roomUuid: meetingInfoResult.nonNullData.roomUuid,
        userName: param.displayName,
        role: MeetingRoles.kUndefined,
        password: param.password,
        initialMyProperties: param.tag != null && param.tag!.isNotEmpty
            ? {
                MeetingPropertyKeys.kMemberTag: param.tag!,
              }
            : null,
      ),
      NEJoinRoomOptions(
        enableMyAudioDeviceOnJoinRtc: opts.enableMyAudioDeviceOnJoinRtc,
      ),
    );
    if (joinRoomResult.code == MeetingErrorCode.success &&
        joinRoomResult.data != null) {
      final roomContext = joinRoomResult.nonNullData;
      roomContext.setupMeetingEnv(meetingInfoResult.nonNullData);
      return NEResult(code: NEMeetingErrorCode.success, data: roomContext);
    } else {
      return _handleMeetingResultCode(joinRoomResult.code, joinRoomResult.msg)
          .cast();
    }
  }

  @override
  Future<NEResult<NERoomContext>> anonymousJoinMeeting(
    NEJoinMeetingParams param,
    NEJoinMeetingOptions opts,
  ) async {
    if (await NERoomKit.instance.authService.isLoggedIn) {
      return joinMeeting(param, opts);
    } else {
      apiLogger.i('anonymousJoinMeeting');

      if (NEMeetingKit.instance.config?.reuseIM ?? false) {
        return NEResult(
            code: NEMeetingErrorCode.reuseIMNotSupportAnonymousLogin,
            msg: localizations.reuseIMNotSupportAnonymousLogin);
      }
      var result = await MeetingRepository.anonymousLogin();
      if (result.isSuccess()) {
        var anonymousLoginInfo = result.data;
        var roomLoginResult = await NERoomKit.instance.authService
            .login(anonymousLoginInfo!.userUuid, anonymousLoginInfo.userToken);
        if (roomLoginResult.isSuccess()) {
          final accountInfo = NEAccountInfo(
            userUuid: anonymousLoginInfo.userUuid,
            userToken: anonymousLoginInfo.userToken,
          );
          NEMeetingKit.instance
              .getAccountService()
              ._setAccountInfo(accountInfo, true);
          return joinMeeting(
            param,
            opts,
          ).onFailure((p0, p1) => NEMeetingKit.instance.logout());
        } else {
          return NEResult(
            code: roomLoginResult.code,
            msg: roomLoginResult.msg ?? 'anonymous login error',
          );
        }
      } else {
        return NEResult(code: result.code, msg: result.msg);
      }
    }
  }

  /// 统一参数校验
  NEResult<void>? checkParameters(Object param) {
    if (param is NEStartMeetingParams && param.displayName.isEmpty) {
      return NEResult<void>(
          code: NEMeetingErrorCode.paramError,
          msg: localizations.displayNameShouldNotBeEmpty);
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
          msg: localizations.meetingPasswordNotValid);
    }

    if (param is NEJoinMeetingParams && param.displayName.isEmpty) {
      return NEResult<void>(
          code: NEMeetingErrorCode.paramError,
          msg: localizations.displayNameShouldNotBeEmpty);
    }

    if (param is NEJoinMeetingParams && param.meetingId.isEmpty) {
      return NEResult<void>(
          code: NEMeetingErrorCode.paramError,
          msg: localizations.meetingIdShouldNotBeEmpty);
    }

    return null;
  }
}
