// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

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

  /// 如果是跨应用入会，则返回跨应用的用户鉴权，否则返回为空
  /// 其他会中需要使用用户鉴权进行 Http 请求的都需要使用这个鉴权信息
  /// 例如：小应用相关的接口
  NEInjectedAuthorization? get crossAppAuthorization {
    final authorization = meetingInfo.authorization;
    return authorization != null
        ? NEInjectedAuthorization(
            appKey: authorization.appKey,
            user: authorization.user,
            token: authorization.token)
        : null;
  }

  /// 如果是跨应用入会，则返回跨应用的appKey，否则返回为空
  /// 小应用，需要使用该 AppKey 进行鉴权
  String? get overrideAppKey => meetingInfo.authorization?.appKey;

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
    annotationController.stopAnnotationShare();
    return meetingSecurityCtrl(
        {MeetingSecurityCtrlKey.ANNOTATION_DISABLE: !enable});
  }

  /// 允许或关闭成员屏幕共享权限
  Future<NEResult<void>> updateScreenSharePermission(bool enable) {
    stopMemberScreenShare();
    return meetingSecurityCtrl(
        {MeetingSecurityCtrlKey.SCREEN_SHARE_DISABLE: !enable});
  }

  /// 停止普通成员的屏幕共享
  void stopMemberScreenShare() {
    // 有人在共享，但是不是主持人与联席主持人
    final userUuid = rtcController.getScreenSharingUserUuid();
    final member = getMember(userUuid);
    if (member != null && !member.isHost && !member.isCohost) {
      rtcController.stopMemberScreenShare(userUuid!);
    }
  }

  /// 允许或关闭成员白板共享权限
  Future<NEResult<void>> updateWhiteboardPermission(bool enable) {
    stopMemberWhiteboard();
    return meetingSecurityCtrl(
        {MeetingSecurityCtrlKey.WHILE_BOARD_SHARE_DISABLE: !enable});
  }

  /// 停止普通成员的白板
  void stopMemberWhiteboard() {
    // 有人在共享，但是不是主持人与联席主持人
    final userUuid = whiteboardController.getWhiteboardSharingUserUuid();
    final member = getMember(userUuid);
    if (member != null && !member.isHost && !member.isCohost) {
      whiteboardController.stopMemberWhiteboardShare(userUuid!);
    }
  }

  /// 允许或关闭成员自己改名权限
  Future<NEResult<void>> updateNicknamePermission(bool enable) {
    return meetingSecurityCtrl(
        {MeetingSecurityCtrlKey.EDIT_NAME_DISABLE: !enable});
  }

  /// 允许或关闭成员自己解除静音权限
  Future<NEResult<void>> updateUnmuteAudioBySelfPermission(bool enable) {
    return meetingSecurityCtrl(
        {MeetingSecurityCtrlKey.AUDIO_NOT_ALLOW_SELF_ON: !enable});
  }

  /// 允许或关闭成员自己打开视频权限
  Future<NEResult<void>> updateUnmuteVideoBySelfPermission(bool enable) {
    return meetingSecurityCtrl(
        {MeetingSecurityCtrlKey.VIDEO_NOT_ALLOW_SELF_ON: !enable});
  }

  /// 允许或关闭成员表情回应权限
  Future<NEResult<void>> updateEmojiRespPermission(bool enable) {
    return meetingSecurityCtrl(
        {MeetingSecurityCtrlKey.EMOJI_RESP_DISABLE: !enable});
  }

  /// 允许或关闭成员本地录制权限
  Future<NEResult<void>> updateLocalRecordPermission(bool enable) {
    return meetingSecurityCtrl(
        {MeetingSecurityCtrlKey.LOCAL_RECORD_DISABLE: !enable});
  }

  /// 允许或关闭成员在成员离开入会播放提示声音权限
  Future<NEResult<void>> updatePlaySound(bool play) {
    return meetingSecurityCtrl({MeetingSecurityCtrlKey.PLAY_SOUND: play});
  }

  /// 允许或关闭头像显示
  Future<NEResult<void>> updateHideAvatar(bool hide) {
    return meetingSecurityCtrl({MeetingSecurityCtrlKey.AVATAR_HIDE: hide});
  }

  Future<NEResult<void>> meetingSecurityCtrl(Map<String, bool> body) {
    return HttpApiHelper._meetingSecurityCtrl(body, roomUuid);
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

  bool checkSecurity(int securityCtrlValue) {
    final securityCtrl = roomProperties[MeetingSecurityCtrlKey.securityCtrlKey];
    if (securityCtrl != null) {
      final number = int.tryParse(securityCtrl);
      if (number != null) {
        return (number & securityCtrlValue) != 0;
      }
    }
    return false;
  }

  /// 是否在成员加入离开的时候播放铃声
  bool get canPlayRing => checkSecurity(MeetingSecurityCtrlValue.PLAY_SOUND);

  /// 是否隐藏头像
  bool get isAvatarHidden =>
      checkSecurity(MeetingSecurityCtrlValue.AVATAR_HIDE);

  /// 是否允许成员批注
  bool get isAnnotationPermissionEnabled =>
      !checkSecurity(MeetingSecurityCtrlValue.ANNOTATION_DISABLE);

  /// 是否允许成员屏幕共享
  bool get isScreenSharePermissionEnabled =>
      !checkSecurity(MeetingSecurityCtrlValue.SCREEN_SHARE_DISABLE);

  /// 是否允许成员自行解除静音
  bool get isUnmuteAudioBySelfEnabled =>
      !checkSecurity(MeetingSecurityCtrlValue.AUDIO_NOT_ALLOW_SELF_ON);

  /// 是否允许成员自行打开视频
  bool get isUnmuteVideoBySelfEnabled =>
      !checkSecurity(MeetingSecurityCtrlValue.VIDEO_NOT_ALLOW_SELF_ON);

  /// 是否允许成员更新昵称
  bool get isUpdateNicknamePermissionEnabled =>
      !checkSecurity(MeetingSecurityCtrlValue.EDIT_NAME_DISABLE);

  /// 是否允许成员本地录制
  bool get isLocalRecordPermissionEnabled =>
      !checkSecurity(MeetingSecurityCtrlValue.LOCAL_RECORD_DISABLE);

  /// 是否允许成员共享白板
  bool get isWhiteboardPermissionEnabled =>
      !checkSecurity(MeetingSecurityCtrlValue.WHILE_BOARD_SHARE_DISABLE);

  /// 设置是否允许访客入会
  Future<NEResult<void>> enableGuestJoin(bool enable) {
    return updateRoomProperty(
      GuestJoinProperty.key,
      enable ? GuestJoinProperty.enable : GuestJoinProperty.disable,
    );
  }

  /// 当前是否全体静音
  bool get isAllAudioMuted => checkSecurity(MeetingSecurityCtrlValue.AUDIO_OFF);

  /// 当前是否全体关闭视频
  bool get isAllVideoMuted => checkSecurity(MeetingSecurityCtrlValue.VIDEO_OFF);

  bool get canReclaimHost {
    return meetingInfo.ownerUserUuid == localMember.uuid && !isMySelfHost();
  }

  /// 是否可以自行解除静音
  bool canUnmuteMyAudio() {
    final propertyCan =
        !checkSecurity(MeetingSecurityCtrlValue.AUDIO_NOT_ALLOW_SELF_ON);

    // 自己是主持人或联席主持人
    return isMySelfHost() ||
        isMySelfCoHost() ||
        propertyCan ||
        // 自己在屏幕共享中
        localMember.isSharingScreen;
  }

  /// 是否可以自行打开视频
  bool canUnmuteMyVideo() {
    final propertyCan =
        !checkSecurity(MeetingSecurityCtrlValue.VIDEO_NOT_ALLOW_SELF_ON);

    // 自己是主持人或联席主持人
    return isMySelfHost() ||
        isMySelfCoHost() ||
        propertyCan ||
        // 自己在屏幕共享中
        localMember.isSharingScreen;
  }

  /// 获取所有用户
  Iterable<NERoomMember> getAllUsers(
      {bool sort = true,
      bool enableSpeakerSpotlight = true,
      bool isViewOrder = false,
      // 是否包含邀请成员
      bool includeInviteMember = false,
      // 是否包含等待加入成员
      bool includeInviteWaitingJoinMember = true}) {
    /// 所有需要展示的成员列表
    List<NERoomMember> members = [];
    if (includeInviteMember) {
      inviteMembers.forEach((element) {
        if (includeInviteWaitingJoinMember ||
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

  /// 获取联席主持人
  List<NERoomMember> getCoHosts() {
    return remoteMembers.where((member) => isCoHost(member.uuid)).toList();
  }

  bool isMySelfHostOrCoHost() => isHostOrCoHost(localMember.uuid);

  /// 判断用户是不是会议创建者
  bool isOwner(String? uuid) =>
      uuid != null && meetingInfo.ownerUserUuid == uuid;

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
    return WebAppRepository.getWebAppList(crossAppAuthorization);
  }

  /// 获取最新的等候室属性配置
  Future<Map<String, dynamic>?> getWaitingRoomProperties() {
    return HttpApiHelper._getWaitingRoomProperties(meetingInfo.roomUuid)
        .then((value) => value.data);
  }

  /// 暂停参会者活动
  Future<VoidResult> stopMemberActivities() {
    return HttpApiHelper._stopMemberActivities(meetingInfo.meetingId);
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

  ///主持人将所有与会者静音, [allowUnmuteSelf] true：允许取消自己静音；反之，不允许
  Future<NEResult<void>> muteAllParticipantsAudio(bool allowUnmuteSelf) {
    return meetingSecurityCtrl({
      MeetingSecurityCtrlKey.AUDIO_OFF: true,
      MeetingSecurityCtrlKey.AUDIO_NOT_ALLOW_SELF_ON: !allowUnmuteSelf
    });
  }

  /// 主持人取消全体静音
  Future<NEResult<void>> unmuteAllParticipantsAudio() {
    return meetingSecurityCtrl({
      MeetingSecurityCtrlKey.AUDIO_OFF: false,
      MeetingSecurityCtrlKey.AUDIO_NOT_ALLOW_SELF_ON: false
    });
  }

  ///主持人将所有与会者视频关闭。
  /// [allowUnmuteSelf] true：允许取消自己静音；反之，不允许
  Future<NEResult<void>> muteAllParticipantsVideo(bool allowUnmuteSelf) {
    return meetingSecurityCtrl({
      MeetingSecurityCtrlKey.VIDEO_OFF: true,
      MeetingSecurityCtrlKey.VIDEO_NOT_ALLOW_SELF_ON: !allowUnmuteSelf
    });
  }

  /// 主持人取消全体视频关闭
  Future<NEResult<void>> unmuteAllParticipantsVideo() {
    return meetingSecurityCtrl({
      MeetingSecurityCtrlKey.VIDEO_OFF: false,
      MeetingSecurityCtrlKey.VIDEO_NOT_ALLOW_SELF_ON: false
    });
  }

  Future<NEResult<void>> meetingSecurityCtrl(Map<String, bool> body) {
    return HttpApiHelper._meetingSecurityCtrl(body, _ctx.roomUuid);
  }

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

  bool get isCohost => role.name == MeetingRoles.kCohost;

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

class MeetingCustomMessage {
  static const _type = 'type';
  static const int stopMemberActivitiesType = 203;

  static int? parseMessage(String customMessage) {
    try {
      final message = json.decode(customMessage);
      if (message is Map) {
        return message[_type] as int;
      }
    } catch (e) {}
    return null;
  }
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
