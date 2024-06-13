// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class ChatRoomManager with NEPreMeetingListener, _AloggerMixin {
  final NERoomContext roomContext;
  final WaitingRoomManager waitingRoomManager;
  late final NERoomEventCallback _roomEventCallback;

  ChatRoomManager(this.roomContext, this.waitingRoomManager) {
    roomContext.addEventCallback(_roomEventCallback = NERoomEventCallback(
      memberRoleChanged: memberRoleChanged,
      memberJoinRoom: memberJoinRoom,
      memberLeaveRoom: memberLeaveRoom,
      roomPropertiesChanged: roomPropertiesChanged,
      memberNameChanged: memberNameChanged,
    ));
    NEMeetingKit.instance.getPreMeetingService().addListener(this);
    subscriptions.add(waitingRoomManager.userListChanged
        .listen((event) => waitingRoomUserListChanged()));
    subscriptions.add(waitingRoomManager.hostAndCoHostListChanged
        .listen(hostAndCoHostListChanged));
    updateWaitingRoomConfig();
    initConnectivityStatus();
  }

  List<NEBaseRoomMember> get hostAndCoHost {
    return roomContext.isInWaitingRoom()
        ? waitingRoomManager.hostAndCoHostList
        : roomContext.getHostAndCoHost().toList();
  }

  /// 会中聊天室权限事件流
  final _chatPermissionChanged = StreamController<NEChatPermission>.broadcast();
  Stream<NEChatPermission> get chatPermissionChanged =>
      _chatPermissionChanged.stream;

  /// 等候室聊天室权限事件流
  final _waitingRoomChatPermissionChanged =
      StreamController<NEWaitingRoomChatPermission>.broadcast();
  Stream<NEWaitingRoomChatPermission> get waitingRoomChatPermissionChanged =>
      _waitingRoomChatPermissionChanged.stream;

  /// 消息发送对象，支持NERoomChatroomType和NEBaseRoomMember，null代表禁言状态
  final _sendToTarget = ValueNotifier<dynamic>(null);
  ValueListenable<dynamic> get sendToTarget => _sendToTarget;

  /// 记录用户选中的发送对象，作为默认值，用于切换权限时恢复
  dynamic userSelectedTarget;

  bool _isDisposed = false;

  final subscriptions = <StreamSubscription?>[];

  /// 网络恢复时，刷新发送对象和等候室聊天权限配置
  void initConnectivityStatus() {
    final _connectivitySubscription =
        ConnectivityManager().onReconnected.listen((connected) {
      if (connected) {
        updateWaitingRoomConfig();
      }
    });
    subscriptions.add(_connectivitySubscription);
  }

  /// 会议状态变更时，刷新等候室主持人信息
  @override
  void onMeetingItemInfoChanged(List<NEMeetingItem> items) {
    for (var item in items) {
      if (item.roomUuid == roomContext.roomUuid) {
        waitingRoomManager.tryLoadHostAndCoHost();
      }
    }
  }

  Future<void> updateWaitingRoomConfig() async {
    if (_isDisposed) return;
    if (roomContext.isInWaitingRoom()) {
      final map = await roomContext.getWaitingRoomProperties();
      if (map?[NEWaitingRoomChatPermissionProperty.key] != null) {
        final value = map![NEWaitingRoomChatPermissionProperty.key]['value'];
        final permission = value != null ? int.tryParse(value) : null;
        if (!_waitingRoomChatPermissionChanged.isClosed) {
          _waitingRoomChatPermissionChanged
              .add(NEWaitingRoomChatPermissionValue.fromValue(permission));
        }
      }
    }
    updateSendTarget();
  }

  /// 更新发送对象，优先更换成用户选择的对象，其次根据权限配置切换
  void updateSendTarget({dynamic newTarget, bool userSelected = false}) {
    /// 刷新当前选择的发送对象
    if (_sendToTarget.value is NEBaseRoomMember &&
        newTarget is NEBaseRoomMember &&
        _sendToTarget.value.uuid == newTarget.uuid) {
      _sendToTarget.value = null;
      _sendToTarget.value = newTarget;
    }
    if (userSelectedTarget is NEBaseRoomMember &&
        newTarget is NEBaseRoomMember &&
        userSelectedTarget.uuid == newTarget.uuid) {
      userSelectedTarget = newTarget;
    }

    /// 用户选择的用户对象,选择发送至全部人时恢复默认
    if (userSelected) {
      userSelectedTarget =
          newTarget != NEChatroomType.common ? newTarget : null;
    }
    _sendToTarget.value = userSelectedTarget ?? newTarget;

    /// 根据身份权限配置，不在范围内，则切换为默认对象
    _updateSendTargetBasedOnUserRole();
  }

  void _updateSendTargetBasedOnUserRole() {
    /// 处理等候室的普通成员
    if (roomContext.isInWaitingRoom() == true) {
      _handleWaitingRoomMember();
      return;
    }

    /// 选中的成员离开会议
    bool resetSendTarget = _sendToTarget.value is NERoomMember &&
        !isMemberInMeeting(_sendToTarget.value);

    /// 选中的等候室成员离开
    resetSendTarget = resetSendTarget ||
        (_sendToTarget.value is NEWaitingRoomMember &&
            !isMemberInWaitingRoom(_sendToTarget.value));

    /// 选中的等候室成员，但自己已经不是主持人或者联席主持人
    resetSendTarget = resetSendTarget ||
        (_sendToTarget.value is NEWaitingRoomMember &&
            !roomContext.isMySelfHostOrCoHost());
    if (resetSendTarget) {
      _sendToTarget.value = null;
    }

    /// 主持人或者联席主持人的情况进行处理
    if (roomContext.isMySelfHostOrCoHost()) {
      /// 等候室人数为0或选中的成员离开，自动切回会议中所有人
      if (_sendToTarget.value == NEChatroomType.waitingRoom &&
          _isWaitingRoomEmpty) {
        _sendToTarget.value = null;
      }
      // _sendToTarget.value ??= NEChatroomType.common;
      selectDefaultSendTargetForInMeeting();
      return;
    }

    /// 处理会议内的普通成员
    _handleRoomMember();
  }

  /// 成员是否在等候室内
  bool isMemberInWaitingRoom(NEWaitingRoomMember user) {
    return waitingRoomManager.userList.contains(user) == true;
  }

  /// 成员是否在会议内(不包含本端)
  bool isMemberInMeeting(NERoomMember user) {
    return roomContext.remoteMembers.contains(user);
  }

  bool get _isWaitingRoomEmpty => waitingRoomManager.userList.isEmpty == true;

  /// 根据等候室聊天权限，处理等候室成员
  void _handleWaitingRoomMember() {
    if (roomContext.waitingRoomChatPermission ==
        NEWaitingRoomChatPermission.privateChatHostOnly) {
      _updateSendTargetForPrivateChatWithHost();
    } else {
      _sendToTarget.value = null;
    }
  }

  /// 根据聊天权限来处理普通参会者
  void _handleRoomMember() {
    switch (roomContext.chatPermission) {
      case NEChatPermission.freeChat:
        // _sendToTarget.value ??= NEChatroomType.common;
        selectDefaultSendTargetForInMeeting();
        break;
      case NEChatPermission.publicChatOnly:
        _updateSendTargetForPublicChat();
        break;
      case NEChatPermission.privateChatHostOnly:
        _updateSendTargetForPrivateChatWithHost();
        break;
      default:
        _sendToTarget.value = null;
    }
  }

  ValueGetter<bool> hasJoinInMeetingChatroom = () => false;
  ValueGetter<bool> hasJoinWaitingRoomChatroom = () => false;
  void selectDefaultSendTargetForInMeeting() {
    if (_sendToTarget.value != null) return;
    bool isManager = roomContext.isMySelfHostOrCoHost();
    bool isInMeetingChatroomFreeChat =
        roomContext.chatPermission == NEChatPermission.freeChat ||
            roomContext.chatPermission == NEChatPermission.publicChatOnly;
    if (hasJoinInMeetingChatroom() &&
        (isManager || isInMeetingChatroomFreeChat)) {
      _sendToTarget.value = NEChatroomType.common;
    } else if (hasJoinWaitingRoomChatroom() && isManager) {
      _sendToTarget.value = NEChatroomType.waitingRoom;
    }
    debugPrint('selectDefaultSendTargetForInMeeting: ${_sendToTarget.value}');
  }

  /// 是否是主持人或者联席主持人
  bool isHostOrCoHost(String uuid) {
    return hostAndCoHost.where((member) => member.uuid == uuid).isNotEmpty;
  }

  /// 成员处理仅公共聊天权限，如果是发送给非主持人，重置发送对象
  void _updateSendTargetForPublicChat() {
    if (_sendToTarget.value is NEBaseRoomMember &&
        !isHostOrCoHost(_sendToTarget.value.uuid)) {
      _sendToTarget.value = null;
    }
    // _sendToTarget.value ??= NEChatroomType.common;
    selectDefaultSendTargetForInMeeting();
  }

  /// 成员处理私聊主持人权限，如果是发送全体或者发送给非主持人，重置发送对象
  void _updateSendTargetForPrivateChatWithHost() {
    if (!(_sendToTarget.value is NEBaseRoomMember) ||
        (_sendToTarget.value is NEBaseRoomMember &&
            !isHostOrCoHost(_sendToTarget.value.uuid))) {
      _sendToTarget.value = null;
    }
    _sendToTarget.value ??= hostAndCoHost.firstOrNull;
  }

  void memberRoleChanged(
      NERoomMember member, NERoomRole before, NERoomRole after) async {
    /// 如果是自己的身份变更或者用户选中的对象身份变更，刷新发送对象
    if (roomContext.isMySelf(member.uuid)) {
      updateSendTarget();
    }

    /// 解决收回主持人事件顺序问题
    if (before.name == MeetingRoles.kHost &&
        after.name == MeetingRoles.kMember) {
      await ensureNewHostActive();
    }

    /// 如果用户选中的对象身份变更，刷新发送对象
    if (userSelectedTarget is NERoomMember &&
        userSelectedTarget!.uuid == member.uuid) {
      updateSendTarget(newTarget: member, userSelected: true);
      return;
    }

    /// 如果是当前对象身份变更，刷新选中对象
    if (sendToTarget.value is NERoomMember &&
        (sendToTarget.value as NERoomMember).uuid == member.uuid) {
      updateSendTarget();
    }
  }

  /// 被收回主持人、转移主持人后，确保新的主持人生效
  /// 事件可能乱序到达，需要延迟等待新主持人生效
  Future ensureNewHostActive() async {
    for (var i = 0; i < 3; i++) {
      final nowHost = roomContext.getHostMember(refresh: true);
      if (nowHost == null) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  void memberLeaveRoom(List<NERoomMember> members) {
    /// 如果用户选择的对象离开了
    if (userSelectedTarget is NERoomMember &&
        members
            .where((element) => element.uuid == userSelectedTarget!.uuid)
            .isNotEmpty) {
      userSelectedTarget = null;
    }

    /// 如果当前选择的对象离开了，重置发送对象
    if (members.contains(_sendToTarget.value)) {
      updateSendTarget();
    }
  }

  void memberJoinRoom(List<NERoomMember> members) {
    /// 仅允许私聊主持人的情况下，如果主持人或联席主持人入会，自动切换到私聊主持人
    if (roomContext.chatPermission == NEChatPermission.privateChatHostOnly &&
        members
            .where((element) => roomContext.isHostOrCoHost(element.uuid))
            .isNotEmpty) {
      updateSendTarget();
    }
  }

  void roomPropertiesChanged(Map<String, dynamic> properties) {
    /// 权限变更时，刷新发送对象
    if (properties.containsKey(NEChatPermissionProperty.key)) {
      _chatPermissionChanged.add(roomContext.chatPermission);
      updateSendTarget();
    }
    if (properties.containsKey(NEWaitingRoomChatPermissionProperty.key) &&
        (roomContext.isInWaitingRoom() || roomContext.isMySelfHostOrCoHost())) {
      _waitingRoomChatPermissionChanged
          .add(roomContext.waitingRoomChatPermission);
      updateSendTarget();
    }
  }

  void memberNameChanged(
      NERoomMember member, String name, NERoomMember? operateBy) {
    /// 选中对象的名称变更，刷新选中对象
    if (sendToTarget.value is NERoomMember &&
        (sendToTarget.value as NERoomMember).uuid == member.uuid) {
      updateSendTarget(newTarget: member);
    }
  }

  /// 等候室成员列表变更时，刷新发送对象
  void waitingRoomUserListChanged() {
    /// 用户选择的对象是等候室成员，恢复选中对象
    if (userSelectedTarget is NEWaitingRoomMember) {
      final member = getWaitingRoomMember(userSelectedTarget!.uuid);
      userSelectedTarget = member;
    }

    /// 当前对象为等候室成员
    if (sendToTarget.value is NEWaitingRoomMember) {
      final member = getWaitingRoomMember(sendToTarget.value.uuid);
      if (member != null) {
        updateSendTarget(newTarget: member);
        return;
      }
    }

    updateSendTarget();
  }

  /// 等候室主持人信息变更时
  void hostAndCoHostListChanged(List<NEWaitingRoomHost> members) {
    /// 如果用户选择的对象离开了
    if (userSelectedTarget is NEWaitingRoomHost &&
        members.where((e) => e.uuid == userSelectedTarget!.uuid).isEmpty) {
      userSelectedTarget = null;
    }

    /// 用户选择的对象变更时，选中对象
    final newOne = members
        .where((element) => element.uuid == userSelectedTarget?.uuid)
        .firstOrNull;
    if (newOne != null) {
      updateSendTarget(newTarget: newOne);
      return;
    }
    updateSendTarget();
  }

  /// 获取等候室成员
  NEWaitingRoomMember? getWaitingRoomMember(String uuid) {
    return waitingRoomManager.userList
        .where((element) => element.uuid == uuid)
        .firstOrNull;
  }

  dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    subscriptions.forEach((element) => element?.cancel());
    NEMeetingKit.instance.getPreMeetingService().removeListener(this);
    roomContext.removeEventCallback(_roomEventCallback);
    _sendToTarget.dispose();
    _chatPermissionChanged.close();
    _waitingRoomChatPermissionChanged.close();
  }
}
