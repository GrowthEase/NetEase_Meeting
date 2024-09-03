// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 供创建和加入会议时必要的基本参数，如会议ID、会议昵称等
class NEMeetingParams {
  ///
  /// 会议中的用户昵称，不能为空
  ///
  final String displayName;

  ///
  /// 会议中的用户头像，可空
  ///
  final String? avatar;

  /// 指定要创建或加入的目标会议ID
  /// 加入会议时，该字段必须是一个当前正在进行中的会议ID，不能为空
  /// 创建会议时，该字段可使用通过[NEAccountService.getAccountInfo]返回的个人会议号，或者不指定(置空)。
  /// 当不指定会议ID创建会议时，由服务端随机分配一个会议ID
  final String? meetingNum;

  ///
  /// 会议中的用户成员标签，自定义，最大长度50
  ///
  final String? tag;

  ///
  /// 会议密码
  ///
  final String? password;

  ///
  /// 媒体流加密设置
  ///
  final NEEncryptionConfig? encryptionConfig;

  ///
  /// 水印设置
  ///
  final NEWatermarkConfig? watermarkConfig;

  IntervalEvent? trackingEvent;

  NEMeetingParams({
    this.meetingNum,
    required this.displayName,
    this.password,
    this.tag,
    this.avatar,
    this.encryptionConfig,
    this.watermarkConfig,
  });

  @override
  String toString() {
    return 'NEMeetingParams{meetingNum: $meetingNum, displayName: $displayName, tag: $tag}';
  }
}

/// 提供创建会议时必要的额外参数，如会议ID、用户会议昵称等
class NEStartMeetingParams extends NEMeetingParams {
  ///
  /// 会议扩展字段，可空，最大长度为 2K。
  ///
  final String? extraData;

  ///
  /// 会议主题
  ///
  final String? subject;

  ///
  /// 成员音视频控制
  ///
  final List<NEMeetingControl>? controls;

  ///
  /// 会议成员角色
  ///
  final Map<String, NEMeetingRoleType>? roleBinds;

  NEStartMeetingParams({
    this.extraData,
    this.subject,
    this.controls,
    this.roleBinds,
    required super.displayName,
    super.avatar,
    super.meetingNum,
    super.tag,
    super.password,
    super.encryptionConfig,
    super.watermarkConfig,
  });

  NEStartMeetingParams.fromMap(Map map)
      : this(
          subject: map['subject'] as String?,
          meetingNum: map['meetingNum'] as String?,
          displayName: (map['displayName'] ?? '') as String,
          password: map['password'] as String?,
          tag: map['tag'] as String?,
          avatar: map['avatar'] as String?,
          extraData: map['extraData'] as String?,
          controls: (map['controls'] as List?)
              ?.map((e) => NEMeetingControl.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList(),
          roleBinds:
              ((map['roleBinds']) as Map<String, dynamic>?)?.map((key, value) {
            var roleType = MeetingRoles.mapIntRoleToEnum(value);
            return MapEntry(key, roleType);
          }),
          encryptionConfig: map['encryptionConfig'] == null
              ? null
              : NEEncryptionConfig.fromJson(
                  Map<String, dynamic>.from(map['encryptionConfig'] as Map)),
          watermarkConfig: map['watermarkConfig'] == null
              ? null
              : NEWatermarkConfig.fromJson(
                  Map<String, dynamic>.from(map['watermarkConfig'] as Map)),
        );
}

/// 提供加入会议时必要的额外参数，如会议ID、用户会议昵称等
class NEJoinMeetingParams extends NEMeetingParams {
  NEJoinMeetingParams({
    required super.meetingNum,
    required super.displayName,
    super.password,
    super.tag,
    super.avatar,
    super.encryptionConfig,
    super.watermarkConfig,
  });

  NEJoinMeetingParams.fromMap(Map map)
      : this(
          meetingNum: map['meetingNum'] as String? ?? '',
          displayName: (map['displayName'] ?? '') as String,
          password: map['password'] as String?,
          tag: map['tag'] as String?,
          avatar: map['avatar'] as String?,
          encryptionConfig: map['encryptionConfig'] == null
              ? null
              : NEEncryptionConfig.fromJson(
                  Map<String, dynamic>.from(map['encryptionConfig'] as Map)),
          watermarkConfig: map['watermarkConfig'] == null
              ? null
              : NEWatermarkConfig.fromJson(
                  Map<String, dynamic>.from(map['watermarkConfig'] as Map)),
        );

  NEJoinMeetingParams copy({String? password}) {
    return NEJoinMeetingParams(
      meetingNum: meetingNum ?? '',
      displayName: displayName,
      password: password ?? this.password,
      tag: tag,
      avatar: avatar,
      encryptionConfig: encryptionConfig,
      watermarkConfig: watermarkConfig,
    );
  }
}

class NEStartMeetingBaseOptions {
  final bool noChat;

  final bool noSip;

  final bool enableWaitingRoom;

  final bool enableMyAudioDeviceOnJoinRtc;

  final bool enableGuestJoin;

  final NECloudRecordConfig? cloudRecordConfig;

  NEStartMeetingBaseOptions({
    this.noChat = false,
    this.cloudRecordConfig,
    this.noSip = false,
    this.enableWaitingRoom = false,
    this.enableMyAudioDeviceOnJoinRtc = true,
    this.enableGuestJoin = false,
  });
}

class NEJoinMeetingBaseOptions {
  final bool enableMyAudioDeviceOnJoinRtc;

  NEJoinMeetingBaseOptions({
    this.enableMyAudioDeviceOnJoinRtc = true,
  });
}

class MeetingRepository with _AloggerMixin {
  static final MeetingRepository _instance = MeetingRepository._();

  factory MeetingRepository() => _instance;

  final _roomService = NERoomKit.instance.roomService;

  final _localHistoryMeetingManager = LocalHistoryMeetingManager();

  MeetingRepository._();

  String? _currentRoomUuid;
  NERoomContext? get currentRoomContext {
    if (_currentRoomUuid != null &&
        _roomService.getRoomContext(_currentRoomUuid!) != null) {
      return _roomService.getRoomContext(_currentRoomUuid!);
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
  Future<NEResult<NERoomContext>> joinMeeting(
      NEJoinMeetingParams param, NEJoinMeetingBaseOptions opts,
      {isInvite = false}) async {
    final trackingEvent = param.trackingEvent;

    trackingEvent?.beginStep(kMeetingStepMeetingInfo);
    final meetingInfoResult =
        await HttpApiHelper.execute(_GetMeetingInfoApi(param.meetingNum ?? ''));
    trackingEvent?.endStepWithResult(meetingInfoResult);
    if (!meetingInfoResult.isSuccess()) {
      return NEResult(code: meetingInfoResult.code, msg: meetingInfoResult.msg);
    }

    trackingEvent?.beginStep(kMeetingStepJoinRoom);
    final meetingInfo = meetingInfoResult.nonNullData;
    final authorization = meetingInfo.authorization;
    final _params = NEJoinRoomParams(
      roomUuid: meetingInfo.roomUuid,
      userName: param.displayName,
      role: MeetingRoles.kUndefined,
      password: param.password,
      avatar: param.avatar ?? AccountRepository().getAccountInfo()?.avatar,
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
      _currentRoomUuid = roomContext.roomUuid;
      roomContext.setupMeetingEnv(meetingInfo);
      return NEResult(code: NEMeetingErrorCode.success, data: roomContext);
    } else {
      return NEResult(code: joinRoomResult.code, msg: joinRoomResult.msg);
    }
  }

  Future<NEResult<NERoomContext>> startMeeting(
    NEStartMeetingParams param,
    NEStartMeetingBaseOptions opts,
  ) async {
    apiLogger.i('startMeeting');
    final trackingEvent = param.trackingEvent;

    /// 如果指定了会议ID，需要检查会议ID是否为个人会议ID或个人会议短ID
    final meetingNum = param.meetingNum;
    final accountInfo = AccountRepository().getAccountInfo();
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
    int securityCtrl = 0;
    param.controls?.forEach((control) {
      if (control is NEMeetingAudioControl) {
        if (control.attendeeOff == NEMeetingAttendeeOffType.offAllowSelfOn) {
          securityCtrl &= ~MeetingSecurityCtrlValue.AUDIO_NOT_ALLOW_SELF_ON;
        } else if (control.attendeeOff ==
            NEMeetingAttendeeOffType.offNotAllowSelfOn) {
          securityCtrl |= MeetingSecurityCtrlValue.AUDIO_NOT_ALLOW_SELF_ON;
        }
      }
      if (control is NEMeetingVideoControl) {
        if (control.attendeeOff == NEMeetingAttendeeOffType.offAllowSelfOn) {
          securityCtrl &= ~MeetingSecurityCtrlValue.VIDEO_NOT_ALLOW_SELF_ON;
        } else if (control.attendeeOff ==
            NEMeetingAttendeeOffType.offNotAllowSelfOn) {
          securityCtrl |= MeetingSecurityCtrlValue.VIDEO_NOT_ALLOW_SELF_ON;
        }
      }
    });
    roomProperties[MeetingSecurityCtrlKey.securityCtrlKey] =
        securityCtrl.toString();
    roomProperties[GuestJoinProperty.key] = opts.enableGuestJoin
        ? GuestJoinProperty.enable
        : GuestJoinProperty.disable;
    if (param.extraData?.isNotEmpty ?? false) {
      roomProperties[MeetingPropertyKeys.kExtraData] = param.extraData;
    }
    late MeetingInfo _meetingInfo;
    late NERoomContext _roomContext;
    trackingEvent?.beginStep(kMeetingStepCreateRoom);
    return _createMeeting(
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
        enableWhiteboard: SDKConfig.global.isWhiteboardSupported,
        enableRecord: opts.cloudRecordConfig?.enable == true &&
            SDKConfig.global.isCloudRecordSupported,
        enableSip: !opts.noSip && SDKConfig.global.isSipSupported,
      ),
      cloudRecordConfig: opts.cloudRecordConfig,
    ).thenEndStep(trackingEvent).map<NERoomContext>((meetingInfo) {
      _meetingInfo = meetingInfo.copyWith(
        state: NEMeetingItemStatus.started,
      );
      trackingEvent?.beginStep(kMeetingStepJoinRoom);
      return _roomService
          .joinRoom(
            NEJoinRoomParams(
              roomUuid: meetingInfo.roomUuid,
              userName: param.displayName,
              role: MeetingRoles.kHost,
              password: param.password,
              avatar:
                  param.avatar ?? AccountRepository().getAccountInfo()?.avatar,
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
      return NEResult(code: result.code, msg: result.msg);
    }).map(() {
      return _roomContext..setupMeetingEnv(_meetingInfo);
    });
  }

  /// 创建会议
  Future<NEResult<MeetingInfo>> _createMeeting({
    required NEMeetingType type,
    String? subject,
    String? password,
    required int roomConfigId,
    Map? roomProperties,
    Map? roleBinds,
    bool enableWaitingRoom = false,
    NEMeetingFeatureConfig featureConfig = const NEMeetingFeatureConfig(),
    NECloudRecordConfig? cloudRecordConfig,
  }) {
    return HttpApiHelper.execute(
      _CreateMeetingApi(
        type,
        _CreateMeetingRequest(
          subject: subject,
          password: password,
          enableWaitingRoom: enableWaitingRoom,
          roomConfigId: roomConfigId,
          roomProperties:
              roomProperties?.map((k, v) => MapEntry(k, {'value': v})),
          roleBinds: roleBinds,
          featureConfig: featureConfig,
          cloudRecordConfig: cloudRecordConfig,
        ),
      ),
    );
  }

  Future<NEResult<List<NEMeetingRecord>>> getMeetingCloudRecordList(
      int meetingId) async {
    final list = NERoomKit.instance.roomService
        .getRoomCloudRecordList(meetingId.toString());
    return list.map((p0) => p0
        .map((p1) => NEMeetingRecord(
              recordId: p1.recordId,
              recordStartTime: p1.recordStartTime,
              recordEndTime: p1.recordEndTime,
              infoList: p1.infoList
                  .map((p2) => NEMeetingRecordFileInfo(
                        type: p2.type,
                        mix: p2.mix,
                        filename: p2.filename,
                        md5: p2.md5,
                        size: p2.size,
                        url: p2.url,
                        vid: p2.vid,
                        pieceIndex: p2.pieceIndex,
                        userUuid: p2.userUuid,
                        nickname: p2.nickname,
                      ))
                  .toList(),
            ))
        .toList());
  }

  Future<NEResult<List<NERoomChatMessage>>> fetchChatroomHistoryMessages(
      String roomArchiveId, NEChatroomHistoryMessageSearchOption option) {
    if (option.startTime == 0) {
      option.startTime = DateTime.now().millisecondsSinceEpoch;
    }
    return NERoomKit.instance.roomService
        .fetchChatroomHistoryMessages(roomArchiveId, option);
  }

  Future<NEResult<VoidResult>> downloadAttachment(String messageUuid) {
    return NERoomKit.instance.roomService.downloadAttachment(messageUuid);
  }

  List<NELocalHistoryMeeting> getLocalHistoryMeetingList() {
    return _localHistoryMeetingManager.localHistoryMeetingList;
  }

  void clearLocalHistoryMeetingList() {
    _localHistoryMeetingManager.clearAll();
  }

  Future<NEResult<MeetingInfo>> getMeetingInfo(String meetingNum) {
    return HttpApiHelper.execute(_GetMeetingInfoApi(meetingNum));
  }

  Future<NEResult<MeetingInfo>> getMeetingInfoBySharingCode(
      String sharingCode) async {
    _LoginInfo? logInfo = await _LoginInfoCache.getLoginInfo();
    return HttpApiHelper.execute(
        _GetMeetingBySharingCodeApi(sharingCode, logInfo));
  }

  /// 获取安全提示
  Future<NEResult<NEMeetingAppNoticeTips>> getSecurityNotice(String time) {
    return HttpApiHelper._getSecurityNotice(time);
  }
}
