// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

final _stateHolder = Expando<_MeetingStates>();

final _ctxHolder = Expando<NERoomContext>();

final _alog = Alogger.api('MeetingContext', 'meeting_core');

class _MeetingStates {
  String? hostUuid;
  MeetingInfo meetingInfo;

  _MeetingStates(this.meetingInfo);
}

extension NEMeetingContext on NERoomContext {
  _MeetingStates get _state => _stateHolder[this]!;

  MeetingInfo get meetingInfo => _state.meetingInfo;

  NEInjectedAuthorization? get crossAppAuthorization {
    final authorization = meetingInfo.authorization;
    return authorization != null
        ? NEInjectedAuthorization(
            appKey: authorization.appKey,
            user: authorization.user,
            token: authorization.token)
        : null;
  }

  bool get isCrossAppJoining => meetingInfo.authorization != null;

  NEMeetingWatermark get watermark {
    final value = roomProperties[WatermarkProperty.key];
    if (value == null || value.isEmpty) {
      return NEMeetingWatermark.fromMap(null);
    }
    final map = jsonDecode(value) as Map?;
    return NEMeetingWatermark.fromMap(map);
  }

  /// 获取视频跟随模式下的用户列表
  List<String> get hostVideoOrderList {
    final value = roomProperties[ViewOrderConfigProperty.key];
    if (value == null || value.isEmpty) {
      return [];
    }
    List<String> list = value.split(',');
    return list;
  }

  /// 是否开启视频跟随模式
  bool isFollowHostVideoOrderOn() {
    final value = roomProperties[ViewOrderConfigProperty.key];
    return value != null && value.isNotEmpty && value.length > 1;
  }

  /// 会中聊天权限
  NEChatPermission get chatPermission {
    final value = roomProperties[NEChatPermissionProperty.key];
    final permission =
        value == null ? NEChatPermission.freeChat.index : int.tryParse(value);
    return NEChatPermissionValue.fromValue(permission);
  }

  /// 会中被邀请的人员列表
  List<NERoomMember> get inviteMembers {
    List<NERoomMember> members = [];
    members.addAll(inSIPInvitingMembers);
    members.addAll(inAppInvitingMembers);
    return members;
  }

  /// 等候室聊天权限
  NEWaitingRoomChatPermission get waitingRoomChatPermission {
    final value = roomProperties[NEWaitingRoomChatPermissionProperty.key];
    final permission = value == null
        ? NEWaitingRoomChatPermission.privateChatHostOnly.index
        : int.tryParse(value);
    return NEWaitingRoomChatPermissionValue.fromValue(permission);
  }

  /// 修改聊天室权限接口
  Future<NEResult<void>> updateChatPermission(NEChatPermission chatPermission) {
    return updateRoomProperty(
        NEChatPermissionProperty.key, chatPermission.value.toString());
  }

  /// 修改等候室聊天室权限接口
  Future<NEResult<void>> updateWaitingRoomChatPermission(
      NEWaitingRoomChatPermission waitingRoomChatPermission) {
    return updateRoomProperty(NEWaitingRoomChatPermissionProperty.key,
        waitingRoomChatPermission.value.toString());
  }

  Future<NEResult<void>> enableConfidentialWatermark(bool enable) {
    final newWatermark = watermark..videoStrategy = enable ? 1 : 0;
    return updateRoomProperty(
      WatermarkProperty.key,
      jsonEncode(newWatermark.toMap()),
    );
  }

  /// 允许或关闭成员批注权限
  Future<NEResult<void>> enableAnnotationPermission(bool enable) {
    return updateRoomProperty(
      AnnotationProperty.key,
      enable ? AnnotationProperty.enable : AnnotationProperty.disable,
    );
  }

  void setupMeetingEnv(MeetingInfo meetingInfo) {
    _stateHolder[this] = _MeetingStates(meetingInfo);

    _ctxHolder[rtcController] = this;
    _ctxHolder[whiteboardController] = this;
    _findHost();
    addEventCallback(NERoomEventCallback(
      memberRoleChanged:
          (NERoomMember member, NERoomRole before, NERoomRole after) {
        if (isHost(member.uuid)) {
          _state.hostUuid = member.uuid;
        } else if (_state.hostUuid == member.uuid && !member.isHost) {
          _state.hostUuid = null;
        }
      },
      memberPropertiesChanged: (member, _) => member._updateStates(),
      memberPropertiesDeleted: (member, _) => member._updateStates(),
    ));
    localMember.updateMyPhoneStateLocal(false);
  }

  void _findHost({bool refresh = false}) {
    if (!refresh && _state.hostUuid != null) {
      return;
    }
    for (var user in [localMember, ...remoteMembers]) {
      if (isHost(user.uuid)) {
        _state.hostUuid = user.uuid;
        return;
      }
    }
  }

  bool get isGuestJoinEnabled =>
      roomProperties[GuestJoinProperty.key] == GuestJoinProperty.enable;

  /// 是否允许成员批注
  bool get isAnnotationPermissionEnabled =>
      roomProperties[AnnotationProperty.key] != AnnotationProperty.disable;

  /// 设置是否允许访客入会
  Future<NEResult<void>> enableGuestJoin(bool enable) {
    return updateRoomProperty(
      GuestJoinProperty.key,
      enable ? GuestJoinProperty.enable : GuestJoinProperty.disable,
    );
  }

  bool get isAllAudioMuted {
    final value = roomProperties[AudioControlProperty.key];
    return value != null &&
        value.startsWith(RegExp(AudioControlProperty.disable)) != true;
  }

  bool get isAllVideoMuted {
    final value = roomProperties[VideoControlProperty.key];
    return value != null &&
        value.startsWith(RegExp(VideoControlProperty.disable)) != true;
  }

  bool get canReclaimHost {
    return meetingInfo.ownerUserUuid == localMember.uuid && !isMySelfHost();
  }

  bool canUnmuteMyAudio() =>
      isMySelfHost() ||
      isMySelfCoHost() ||
      roomProperties[AudioControlProperty.key]
              ?.startsWith(RegExp(AudioControlProperty.offNotAllowSelfOn)) !=
          true ||
      localMember.isSharingScreen;

  bool canUnmuteMyVideo() =>
      isMySelfHost() ||
      isMySelfCoHost() ||
      roomProperties[VideoControlProperty.key]
              ?.startsWith(RegExp(VideoControlProperty.offNotAllowSelfOn)) !=
          true ||
      localMember.isSharingScreen;

  /// 获取所有用户
  Iterable<NERoomMember> getAllUsers(
      {bool sort = true,
      bool enableSpeakerSpotlight = true,
      bool isViewOrder = false,
      bool isIncludeInviteMember = false,
      bool isIncludeInviteWaitingJoinMember = true}) {
    /// 所有需要展示的成员列表
    List<NERoomMember> members = [];
    if (isIncludeInviteMember) {
      inviteMembers.forEach((element) {
        if (isIncludeInviteWaitingJoinMember ||
            element.inviteState != NERoomMemberInviteState.waitingJoin) {
          members.add(element);
        }
      });
    }
    members.addAll(remoteMembers);
    members.add(localMember);
    if (sort) {
      members.sort((lhs, rhs) => compareUser(lhs, rhs,
          enableSpeakerSpotlight: enableSpeakerSpotlight));
    }
    if (isViewOrder &&
        hostVideoOrderList.isNotEmpty &&
        hostVideoOrderList.length > 0) {
      // 根据 hostVideoOrderList 的顺序重新排序 remoteMembers
      List<NERoomMember> sortedRemoteMembers = hostVideoOrderList
          .map((uuid) => getMember(uuid))
          .whereType<NERoomMember>()
          .toList();
      // 添加未在 hostVideoOrderList 中的用户
      members.removeWhere((member) => sortedRemoteMembers.contains(member));
      members = [...sortedRemoteMembers, ...members];
    }
    return members.where((member) => member.isVisible).toSet().toList();
  }

  /// 获取主持人和联席主持人
  Iterable<NERoomMember> getHostAndCoHost({bool sort = true}) {
    final members = remoteMembers;
    if (sort) {
      members.sort(compareUser);
    }
    return members.where((member) => isHostOrCoHost(member.uuid));
  }

  bool isMySelfHostOrCoHost() => isHostOrCoHost(localMember.uuid);

  /// 自己是不是主持人
  bool isMySelfHost() => isHost(localMember.uuid);

  /// 判断用户是不是主持人
  bool isHost(String? uuid) =>
      uuid != null && getMember(uuid)?.role.name == MeetingRoles.kHost;

  /// 判断用户是不是外部访客
  bool isGuest(String? uuid) =>
      uuid != null && getMember(uuid)?.role.name == MeetingRoles.kGuest;

  /// 是不是当前用户
  bool isMySelf(String uuid) => localMember.uuid == uuid;

  String get myUuid => localMember.uuid;

  /// 获取主持人用户id
  String? getHostUuid({bool refresh = false}) {
    _findHost(refresh: refresh);
    return _state.hostUuid;
  }

  /// 获取主持人member
  NERoomMember? getHostMember({bool refresh = false}) =>
      getMember(getHostUuid(refresh: refresh));

  String? getFocusUuid() {
    final member = getMember(roomProperties[_PropertyKeys.kFocus]);
    return member != null && member.isInRtcChannel ? member.uuid : null;
  }

  String? getMemberName(String? uuid) => getMember(uuid)?.name;

  /// 额外数据
  String? get extraData => roomProperties[MeetingPropertyKeys.kExtraData];

  String get meetingNum => roomUuid;

  Future<NEResult<void>> updateMyPhoneState(bool isInCall) {
    _alog.i('update my phone state: $isInCall');
    if (isInCall) {
      return updateMemberProperty(
          myUuid, PhoneStateProperty.key, PhoneStateProperty.valueIsInCall);
    } else {
      return deleteMemberProperty(myUuid, PhoneStateProperty.key);
    }
  }

  Future<NEResult<void>> handOverHost(String userId) {
    assert(isMySelfHost());
    return handOverMyRole(userId);
  }

  Future<NEResult<void>> reclaimHost(String userId) {
    assert(canReclaimHost && isHost(userId));
    return changeMembersRole({
      localMember.uuid: MeetingRoles.kHost,
      userId: MeetingRoles.kMember,
    });
  }

  Future<NEResult<void>> raiseMyHand() {
    assert(!localMember.isRaisingHand);
    return updateMemberProperty(
        myUuid, HandsUpProperty.key, HandsUpProperty.up);
  }

  Future<NEResult<void>> lowerMyHand() {
    assert(localMember.isRaisingHand);
    return deleteMemberProperty(myUuid, HandsUpProperty.key);
  }

  Future<NEResult<void>> lowerUserHand(String userId) {
    assert(getMember(userId)?.isRaisingHand == true);
    return updateMemberProperty(
        userId, HandsUpProperty.key, HandsUpProperty.reject);
  }

  /// 设置联席主持人
  Future<NEResult<void>> makeCoHost(String uuid) {
    return changeMemberRole(uuid, MeetingRoles.kCohost);
  }

  /// 取消联席主持人
  Future<NEResult<void>> cancelCoHost(String uuid) {
    return changeMemberRole(uuid, MeetingRoles.kMember);
  }

  /// 判断用户是否是联席主持人
  bool isCoHost(String? uuid) {
    return getMember(uuid)?.role.name == MeetingRoles.kCohost;
  }

  /// 当前用户是否是联席主持人
  bool isMySelfCoHost() {
    return isCoHost(localMember.uuid);
  }

  /// 是不是主持人或者
  bool isHostOrCoHost(String? uuid) {
    return isHost(uuid) || isCoHost(uuid);
  }

  void fillEventParams(IntervalEvent event) {
    event
      ..addParam(kEventParamMeetingId, meetingInfo.meetingId)
      ..addParam(kEventParamMeetingNum, meetingInfo.meetingNum)
      ..addParam(kEventParamRoomArchiveId, meetingInfo.roomArchiveId);
  }

  /// 获取小应用列表
  Future<NEResult<List<NEMeetingWebAppItem>>> getWebAppList() {
    return WebAppRepository.getWebAppList();
  }

  /// 获取最新的等候室属性配置
  Future<Map<String, dynamic>?> getWaitingRoomProperties() {
    return MeetingRepository.getWaitingRoomProperties(meetingInfo.roomUuid)
        .then((value) => value.data);
  }

  ///成员列表展示顺序：
  /// 主持人->联席主持人->自己->举手->屏幕共享（白板）->音视频->视频->音频-> 邀请 -> 昵称排序
  /// 优先处理如果是邀请状态就不向前排序
  ///
  int compareUser(NERoomMember lhs, NERoomMember rhs,
      {bool enableSpeakerSpotlight = true}) {
    final isLhsInvite = lhs.isInSIPInviting || lhs.isInAppInviting;
    final isRhsInvite = rhs.isInSIPInviting || rhs.isInAppInviting;

    if (isLhsInvite) {
      return 1;
    }
    if (isRhsInvite) {
      return -1;
    }
    if (isHost(lhs.uuid)) {
      return -1;
    }
    if (isHost(rhs.uuid)) {
      return 1;
    }
    if (isCoHost(lhs.uuid)) {
      return -1;
    }
    if (isCoHost(rhs.uuid)) {
      return 1;
    }
    if (isMySelf(lhs.uuid)) {
      return -1;
    }
    if (isMySelf(rhs.uuid)) {
      return 1;
    }
    if (lhs.isRaisingHand) {
      return -1;
    }
    if (rhs.isRaisingHand) {
      return 1;
    }
    if (lhs.isSharingScreen) {
      return -1;
    }
    if (rhs.isSharingScreen) {
      return 1;
    }
    if (lhs.isSharingWhiteboard) {
      return -1;
    }
    if (rhs.isSharingWhiteboard) {
      return 1;
    }
    if (lhs.isVideoOn && lhs.isAudioOn) {
      return -1;
    }
    if (rhs.isVideoOn && rhs.isAudioOn) {
      return 1;
    }
    if (lhs.isVideoOn) {
      return -1;
    }
    if (rhs.isVideoOn) {
      return 1;
    }
    if (enableSpeakerSpotlight) {
      if (lhs.isAudioOn) {
        return -1;
      }
      if (rhs.isAudioOn) {
        return 1;
      }
    }
    return lhs.name.compareTo(rhs.name);
  }
}

extension NEMeetingRtcController on NERoomRtcController {
  NERoomContext get _ctx => _ctxHolder[this]!;

  ///
  /// 邀请成员打开音视频，走自定义透传
  ///
  Future<NEResult<void>> inviteParticipantTurnOnAudioAndVideo(String userId) {
    return NERoomKit.instance.messageChannelService.sendCustomMessage(
      _ctx.roomUuid,
      userId,
      MeetingControlMessenger.commandId,
      MeetingControlMessenger.buildControlMessage(
          MeetingControlMessenger.inviteToOpenAudioVideo),
      injectedAuthorization: _ctx.crossAppAuthorization,
    );
  }

  ///
  /// 邀请成员打开音频
  ///
  Future<NEResult<void>> inviteParticipantTurnOnAudio(String userId) {
    return NERoomKit.instance.messageChannelService.sendCustomMessage(
      _ctx.roomUuid,
      userId,
      MeetingControlMessenger.commandId,
      MeetingControlMessenger.buildControlMessage(
          MeetingControlMessenger.inviteToOpenAudio),
      injectedAuthorization: _ctx.crossAppAuthorization,
    );
  }

  ///
  /// 邀请成员打开视频
  ///
  Future<NEResult<void>> inviteParticipantTurnOnVideo(String userId) {
    return NERoomKit.instance.messageChannelService.sendCustomMessage(
      _ctx.roomUuid,
      userId,
      MeetingControlMessenger.commandId,
      MeetingControlMessenger.buildControlMessage(
          MeetingControlMessenger.inviteToOpenVideo),
      injectedAuthorization: _ctx.crossAppAuthorization,
    );
  }

  ///主持人将所有与会者静音, [allowUnmuteSelf] true：允许取消自己静音；反之，不允许
  Future<NEResult<void>> muteAllParticipantsAudio(bool allowUnmuteSelf) {
    final sed = DateTime.now().millisecondsSinceEpoch;
    return _ctx.updateRoomProperty(
        AudioControlProperty.key,
        allowUnmuteSelf
            ? '${AudioControlProperty.offAllowSelfOn}_$sed'
            : '${AudioControlProperty.offNotAllowSelfOn}_$sed');
  }

  /// 主持人取消全体静音
  Future<NEResult<void>> unmuteAllParticipantsAudio() {
    final sed = DateTime.now().millisecondsSinceEpoch;
    return _ctx.updateRoomProperty(
      AudioControlProperty.key,
      '${AudioControlProperty.disable}_$sed',
    );
  }

  /// 主持人取消设置/设置对应用户为焦点视频
  Future<NEResult<void>> pinVideo(String userUuid, bool on) {
    _alog.i('pin user video: $userUuid, $on');
    if (on) {
      return _ctx.updateRoomProperty(_PropertyKeys.kFocus, userUuid,
          associatedUuid: userUuid);
    } else if (_ctx.getFocusUuid() == userUuid) {
      return _ctx.deleteRoomProperty(_PropertyKeys.kFocus);
    }
    return Future.value(NEResult.success());
  }

  /// 主持人或者联系主持人取消设置/设置对应用户为视频跟随模式
  Future<NEResult<void>> viewOrderConfigProperty(
      String viewOrderConfigProperty) {
    _alog.i('view order config: $viewOrderConfigProperty');
    if (viewOrderConfigProperty.isNotEmpty || viewOrderConfigProperty != '') {
      return _ctx.updateRoomProperty(
          ViewOrderConfigProperty.key, viewOrderConfigProperty);
    } else {
      return _ctx.deleteRoomProperty(ViewOrderConfigProperty.key);
    }
  }

  ///主持人将所有与会者视频关闭。
  /// [allowUnmuteSelf] true：允许取消自己静音；反之，不允许
  Future<NEResult<void>> muteAllParticipantsVideo(bool allowUnmuteSelf) {
    final sed = DateTime.now().millisecondsSinceEpoch;
    return _ctx.updateRoomProperty(
        VideoControlProperty.key,
        allowUnmuteSelf
            ? '${VideoControlProperty.offAllowSelfOn}_$sed'
            : '${VideoControlProperty.offNotAllowSelfOn}_$sed');
  }

  /// 主持人取消全体视频关闭
  Future<NEResult<void>> unmuteAllParticipantsVideo() {
    final sed = DateTime.now().millisecondsSinceEpoch;
    return _ctx.updateRoomProperty(
      VideoControlProperty.key,
      '${VideoControlProperty.disable}_$sed',
    );
  }
}

extension NEMeetingWhiteboardController on NERoomWhiteboardController {
  NERoomContext get _ctx => _ctxHolder[this]!;

  ///授予白板权限
  /// [userUuid] 用户id
  Future<VoidResult> grantPermission(String userUuid) {
    return _ctx.updateMemberProperty(
      userUuid,
      WhiteboardDrawableProperty.key,
      WhiteboardDrawableProperty.drawable,
    );
  }

  ///取消白板权限
  /// [userUuid] 用户id
  Future<VoidResult> revokePermission(String userUuid) {
    return _ctx.deleteMemberProperty(
      userUuid,
      WhiteboardDrawableProperty.key,
    );
  }

  Future<VoidResult> updateWhiteboardConfig({
    bool isTransparent = false,
  }) {
    _alog.i('update whiteboard config');
    return _ctx.updateRoomProperty(
      WhiteboardConfigProperty.key,
      currentWhiteboardConfig.copyWith(isTransparent: isTransparent).toJson(),
      associatedUuid: _ctx.localMember.uuid,
    );
  }

  bool isTransparentModeEnabled() {
    return currentWhiteboardConfig.isTransparent;
  }

  Future<VoidResult> deleteWhiteboardConfig() {
    _alog.i('delete whiteboard config');
    return _ctx.deleteRoomProperty(WhiteboardConfigProperty.key);
  }

  Future<VoidResult> applyWhiteboardConfig() {
    _alog.i('apply whiteboard config');
    var color = const Color(0xFFFFFFFF);
    if (isTransparentModeEnabled()) {
      color = color.withAlpha(0);
    }
    return setCanvasBackgroundColor(color.stringify());
  }

  _WhiteboardConfig get currentWhiteboardConfig {
    return _WhiteboardConfig.fromJson(
        _ctx.roomProperties[WhiteboardConfigProperty.key]);
  }

  bool isDrawWhiteboardEnabled() => _ctx.localMember.isWhiteboardDrawable;

  bool isDrawWhiteboardEnabledWithUserId(String? uuid) =>
      _ctx.getMember(uuid)?.isWhiteboardDrawable == true;
}

extension NEMeetingMember on NERoomMember {
  bool get isVisible => !role.hide;

  bool get isHost => role.name == MeetingRoles.kHost;

  bool get canRenderVideo => isVideoOn && isInRtcChannel;

  String? get tag => properties[MeetingPropertyKeys.kMemberTag];

  bool get isWhiteboardDrawable =>
      properties[WhiteboardDrawableProperty.key] ==
          WhiteboardDrawableProperty.drawable ||
      isSharingWhiteboard;

  bool get isRaisingHand =>
      properties[HandsUpProperty.key] == HandsUpProperty.up;

  bool get isHandDownByHost =>
      properties[HandsUpProperty.key] == HandsUpProperty.reject;

  bool get isInCall =>
      properties[PhoneStateProperty.key] == PhoneStateProperty.valueIsInCall;

  ValueListenable<bool> get isInCallListenable {
    return _ensureIsInCallNotifier();
  }

  void updateMyPhoneStateLocal(bool isInCall) {
    addAttachment(_phoneStateLocalKey, isInCall);
    _updateStates();
  }

  static const _phoneStateLocalKey = 'phoneStateLocal';
  static const _isInCallListenableKey = 'isInCallListenable';
  ValueNotifier<bool> _ensureIsInCallNotifier() {
    var notifier = getAttachment(_isInCallListenableKey);
    if (notifier is ValueNotifier<bool>) {
      return notifier;
    }
    notifier = ValueNotifier(isInCall);
    addAttachment(_isInCallListenableKey, notifier);
    return notifier;
  }

  void _updateStates() {
    _ensureIsInCallNotifier().value =
        (getAttachment(_phoneStateLocalKey) as bool?) ?? isInCall;
  }
}

class _PropertyKeys {
  /// 房间焦点视频成员
  static const kFocus = 'focus';
}

class WhiteboardDrawableProperty {
  static const String key = 'wbDrawable';
  static const String drawable = '1';
  static const String notDrawable = '0';
}

class WhiteboardConfigProperty {
  static const String key = 'whiteboardConfig';
  static const String isTransparent = 'isTransparent';
}

/// 视图顺序配置
class ViewOrderConfigProperty {
  static const String key = 'viewOrder';
}

extension _ColorString on Color {
  String stringify() {
    return "rgba($red, $green, $blue, $alpha)";
  }
}

class _WhiteboardConfig {
  static const kDefault = _WhiteboardConfig(false);

  final bool isTransparent;

  const _WhiteboardConfig(this.isTransparent);

  _WhiteboardConfig copyWith({
    bool? isTransparent,
  }) {
    return _WhiteboardConfig(
      isTransparent ?? this.isTransparent,
    );
  }

  factory _WhiteboardConfig.fromJson(String? json) {
    if (json == null || json.isEmpty) return kDefault;
    try {
      final map = jsonDecode(json) as Map;
      return _WhiteboardConfig(
        map[WhiteboardConfigProperty.isTransparent] as bool? ?? false,
      );
    } catch (e) {
      return kDefault;
    }
  }

  String toJson() {
    return jsonEncode({
      WhiteboardConfigProperty.isTransparent: this.isTransparent,
    });
  }
}

class HandsUpProperty {
  static const String key = 'handsUp';
  static const String up = '1';
  static const String reject = '2';
}

/// 自定义信令透传消息
class MeetingControlMessenger {
  static const int commandId = 99;

  static const int inviteToOpenAudio = 1;
  static const int inviteToOpenVideo = 2;
  static const int inviteToOpenAudioVideo = 3;

  static const _key = 'category';
  static const _id = 'meeting_control';
  static const _type = 'type';

  static String buildControlMessage(int type) {
    return json.encode({
      _key: _id,
      _type: type,
    });
  }

  static int? parseMessage(String controlMessage) {
    try {
      final control = json.decode(controlMessage);
      if (control is Map && control[_key] == _id) {
        return control[_type] as int;
      }
    } catch (e) {}
    return null;
  }
}
