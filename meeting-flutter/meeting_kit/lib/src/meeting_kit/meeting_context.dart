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

  NECrossAppAuthorization? get crossAppAuthorization {
    final authorization = meetingInfo.authorization;
    return authorization != null
        ? NECrossAppAuthorization(
            appKey: authorization.appKey,
            user: authorization.user,
            token: authorization.token)
        : null;
  }

  bool get isCrossAppJoining => meetingInfo.authorization != null;

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
        }
      },
      memberPropertiesChanged: (member, _) => member._updateStates(),
      memberPropertiesDeleted: (member, _) => member._updateStates(),
    ));
    localMember.updateMyPhoneStateLocal(false);
  }

  void _findHost() {
    if (_state.hostUuid == null) {
      final members = remoteMembers;
      members.add(localMember);
      members.forEach((user) {
        if (isHost(user.uuid)) {
          _state.hostUuid = user.uuid;
          return;
        }
      });
    }
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
  Iterable<NERoomMember> getAllUsers() {
    final members = remoteMembers;
    members.add(localMember);
    return members.where((member) =>
        member.isVisible && (member.isInRtcChannel || member.uuid == myUuid));
  }

  /// 自己是不是主持人
  bool isMySelfHost() => isHost(localMember.uuid);

  /// 判断用户是不是主持人
  bool isHost(String? uuid) =>
      uuid != null && getMember(uuid)?.role.name == MeetingRoles.kHost;

  /// 是不是当前用户
  bool isMySelf(String uuid) => localMember.uuid == uuid;

  String get myUuid => localMember.uuid;

  /// 获取主持人用户id
  String? getHostUuid() {
    _findHost();
    return _state.hostUuid;
  }

  /// 获取主持人member
  NERoomMember? getHostMember() => getMember(getHostUuid());

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
      crossAppAuthorization: _ctx.crossAppAuthorization,
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
      crossAppAuthorization: _ctx.crossAppAuthorization,
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
      crossAppAuthorization: _ctx.crossAppAuthorization,
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

  bool isDrawWhiteboardEnabled() => _ctx.localMember.isWhiteboardDrawable;

  bool isDrawWhiteboardEnabledWithUserId(String? uuid) =>
      _ctx.getMember(uuid)?.isWhiteboardDrawable == true;
}

extension NEMeetingMember on NERoomMember {
  bool get isVisible => role.name != 'hide';

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
    notifier = ValueNotifier(false);
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
