// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEMeetingServiceImpl extends NEMeetingService
    with _AloggerMixin, EventTrackMixin, _MeetingKitLocalizationsMixin {
  static final _NEMeetingServiceImpl _instance = _NEMeetingServiceImpl._();

  factory _NEMeetingServiceImpl() => _instance;

  final _roomService = NERoomKit.instance.roomService;
  late final _accountService = NEMeetingKit.instance.getAccountService();

  _NEMeetingServiceImpl._();

  @override
  Future<NEResult<NERoomContext>> startMeeting(
    NEStartMeetingParams param,
    NEStartMeetingOptions opts,
  ) async {
    apiLogger.i('startMeeting');
    final trackingEvent = param.trackingEvent;

    final checkParamsResult = checkParameters(param);
    if (checkParamsResult != null) {
      return checkParamsResult.cast();
    }
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      return _handleMeetingResultCode(MeetingErrorCode.networkError).cast();
    }

    /// 如果指定了会议ID，需要检查会议ID是否为个人会议ID或个人会议短ID
    final meetingNum = param.meetingNum;
    final accountInfo =
        NEMeetingKit.instance.getAccountService().getAccountInfo();
    if (meetingNum != null &&
        meetingNum.isNotEmpty &&
        accountInfo != null &&
        meetingNum != accountInfo.privateShortMeetingNum &&
        meetingNum != accountInfo.privateMeetingNum) {
      return NEResult(
        code: NEMeetingErrorCode.paramError,
        msg: 'MeetingNum is incorrect',
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
    roomProperties[GuestJoinProperty.key] = opts.enableGuestJoin
        ? GuestJoinProperty.enable
        : GuestJoinProperty.disable;
    if (param.extraData?.isNotEmpty ?? false) {
      roomProperties[MeetingPropertyKeys.kExtraData] = param.extraData;
    }
    late MeetingInfo _meetingInfo;
    late NERoomContext _roomContext;
    trackingEvent?.beginStep(kMeetingStepCreateRoom);
    return MeetingRepository.createMeeting(
      type: (param.meetingNum?.isNotEmpty ?? false)
          ? NEMeetingType.kPersonal
          : NEMeetingType.kRandom,
      subject: param.subject,
      password: param.password,
      enableWaitingRoom: opts.enableWaitingRoom,
      roomConfigId: kMeetingTemplateId,
      roomProperties: roomProperties,
      roleBinds: param.roleBinds?.map((key, value) {
        var roleType = MeetingRoles.mapEnumRoleToString(value);
        return MapEntry(key, roleType);
      }),
      featureConfig: NEMeetingFeatureConfig(
        enableChatroom: !opts.noChat,
        enableLive: false,
        enableWhiteboard: SDKConfig.current.isWhiteboardSupported,
        enableRecord:
            !opts.noCloudRecord && SDKConfig.current.isCloudRecordSupported,
        enableSip: !opts.noSip && SDKConfig.current.isSipSupported,
      ),
    ).thenEndStep(trackingEvent).map<NERoomContext>((meetingInfo) {
      _meetingInfo = meetingInfo.copyWith(
        state: NEMeetingState.started,
      );
      trackingEvent?.beginStep(kMeetingStepJoinRoom);
      return _roomService
          .joinRoom(
            NEJoinRoomParams(
              roomUuid: meetingInfo.roomUuid,
              userName: param.displayName,
              role: MeetingRoles.kHost,
              password: param.password,
              avatar: param.avatar ?? _accountService.getAccountInfo()?.avatar,
              initialMyProperties: param.tag != null && param.tag!.isNotEmpty
                  ? {
                      MeetingPropertyKeys.kMemberTag: param.tag!,
                    }
                  : null,
            ),
            NEJoinRoomOptions(
              enableMyAudioDeviceOnJoinRtc: opts.enableMyAudioDeviceOnJoinRtc,
            ),
          )
          .thenEndStep(trackingEvent);
    }).map<void>((roomContext) async {
      _roomContext = roomContext;
      return NEResult<void>(code: NEMeetingErrorCode.success);
    }).then((result) {
      return _handleMeetingResultCode(result.code, result.msg);
    }).map(() {
      return _roomContext..setupMeetingEnv(_meetingInfo);
    });
  }

  @override
  Future<NEResult<NERoomContext>> joinMeeting(
      NEJoinMeetingParams param, NEJoinMeetingOptions opts,
      {bool isInvite = false}) async {
    apiLogger.i('joinMeeting');
    final trackingEvent = param.trackingEvent;

    final checkParamsResult = checkParameters(param);
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
      avatar: param.avatar ?? _accountService.getAccountInfo()?.avatar,
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
    var joinRoomResult = await _roomService.joinRoom(
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

  @override
  Future<NEResult<NERoomContext>> anonymousJoinMeeting(
    NEJoinMeetingParams param,
    NEJoinMeetingOptions opts,
  ) async {
    if (await NERoomKit.instance.authService.isLoggedIn) {
      return joinMeeting(param, opts);
    } else {
      apiLogger.i('anonymousJoinMeeting');
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
    if ((param is NEStartMeetingParams && param.displayName.isEmpty) ||
        (param is NEJoinMeetingParams && param.displayName.isEmpty)) {
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

    if (param is NEJoinMeetingParams && param.meetingNum.isEmpty) {
      return NEResult<void>(
          code: NEMeetingErrorCode.paramError,
          msg: localizations.meetingIdShouldNotBeEmpty);
    }

    return null;
  }

  @override
  Future<NEResult<List<NERoomRecord>>> getRoomCloudRecordList(
      String roomArchiveId) {
    return NERoomKit.instance.roomService.getRoomCloudRecordList(roomArchiveId);
  }

  @override
  Future<NEResult<List<NERoomChatMessage>>> fetchChatroomHistoryMessages(
      String roomArchiveId, NEChatroomHistoryMessageSearchOption option) {
    return NERoomKit.instance.roomService
        .fetchChatroomHistoryMessages(roomArchiveId, option);
  }

  @override
  Future<NEResult<VoidResult>> downloadAttachment(String messageUuid) {
    return NERoomKit.instance.roomService.downloadAttachment(messageUuid);
  }
}
