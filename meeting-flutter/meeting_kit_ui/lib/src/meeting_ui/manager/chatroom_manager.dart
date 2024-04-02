// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class ChatRoomManager with _AloggerMixin {
  final NERoomContext roomContext;
  final WaitingRoomManager? waitingRoomManager;
  late final NERoomEventCallback _roomEventCallback;

  ChatRoomManager(this.roomContext, {this.waitingRoomManager}) {
    roomContext.addEventCallback(_roomEventCallback = NERoomEventCallback(
      memberRoleChanged: memberRoleChanged,
      memberJoinRoom: memberJoinRoom,
      memberLeaveRoom: memberLeaveRoom,
      roomPropertiesChanged: roomPropertiesChanged,
      memberNameChanged: memberNameChanged,
    ));
    NEMeetingKit.instance
        .getPreMeetingService()
        .registerScheduleMeetingStatusChange(onMeetingStatusChange);
    waitingRoomManager?.userListChanged
        .listen((event) => waitingRoomUserListChanged());
    updateSendTarget();
    updateHostAndCoHostInWaitingRoom();
    updateWaitingRoomConfig();
    initConnectivityStatus();
  }

  final _waitingRoomHostAndCoHost = <NEBaseRoomMember>[];
  List<NEBaseRoomMember> get hostAndCoHost {
    return roomContext.isInWaitingRoom()
        ? _waitingRoomHostAndCoHost
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

  /// 等候室成员调用接口更新主持人信息事件流
  final _waitingRoomHostAndCoHostUpdated = StreamController.broadcast();
  Stream get waitingRoomHostAndCoHostUpdated =>
      _waitingRoomHostAndCoHostUpdated.stream;

  /// 消息发送对象，支持NERoomChatroomType和NEBaseRoomMember，null代表禁言状态
  final _sendToTarget = ValueNotifier<dynamic>(null);
  ValueListenable<dynamic> get sendToTarget => _sendToTarget;

  /// 记录用户选中的发送对象，作为默认值，用于切换权限时恢复
  NEBaseRoomMember? userSelectedTarget;

  bool _isDisposed = false;

  StreamSubscription? _connectivitySubscription;

  /// 网络恢复时，刷新发送对象和等候室聊天权限配置
  void initConnectivityStatus() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((event) {
      if (event != ConnectivityResult.none) {
        updateHostAndCoHostInWaitingRoom();
        updateWaitingRoomConfig();
      }
    });
  }

  /// 会议状态变更时，刷新等候室主持人信息
  void onMeetingStatusChange(List<NEMeetingItem> items, _) {
    for (var item in items) {
      if (item.roomUuid == roomContext.roomUuid) {
        updateHostAndCoHostInWaitingRoom();
      }
    }
  }

  Future<void> updateHostAndCoHostInWaitingRoom() async {
    if (_isDisposed) return;
    if (roomContext.isInWaitingRoom()) {
      final result = await roomContext.getHostAndCoHostList();
      _waitingRoomHostAndCoHost.clear();
      _waitingRoomHostAndCoHost.addAll(result ?? []);
      if (!_waitingRoomHostAndCoHostUpdated.isClosed) {
        _waitingRoomHostAndCoHostUpdated.add(null);
      }
    }
    updateSendTarget();
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

    /// 用户选择的用户对象,选择发送至全部人时恢复默认
    if (userSelected) {
      userSelectedTarget = newTarget is NEBaseRoomMember ? newTarget : null;
    }

    _sendToTarget.value = newTarget != null ? newTarget : userSelectedTarget;

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
    if (_sendToTarget.value is NERoomMember &&
        !isMemberInMeeting(_sendToTarget.value)) {
      _sendToTarget.value = null;
    }

    /// 主持人或者联席主持人的情况进行处理
    if (roomContext.isMySelfHostOrCoHost()) {
      /// 等候室人数为0或选中的成员离开，自动切回会议中所有人
      if ((_sendToTarget.value == NEChatroomType.waitingRoom &&
              _isWaitingRoomEmpty) ||
          (_sendToTarget.value is NEWaitingRoomMember &&
              !isMemberInWaitingRoom(_sendToTarget.value))) {
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
    return waitingRoomManager?.userList.contains(user) == true;
  }

  /// 成员是否在会议内(不包含本端)
  bool isMemberInMeeting(NERoomMember user) {
    return roomContext.remoteMembers.contains(user);
  }

  bool get _isWaitingRoomEmpty => waitingRoomManager?.userList.isEmpty == true;

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
      NERoomMember member, NERoomRole before, NERoomRole after) {
    /// 等候室成员收到主持人信息变更事件
    if (roomContext.isInWaitingRoom()) {
      updateHostAndCoHostInWaitingRoom();
      return;
    }

    /// 如果是自己的身份变更或者用户选中的对象身份变更，刷新发送对象
    if (roomContext.isMySelf(member.uuid)) {
      updateSendTarget();
    }

    /// 如果用户选中的对象身份变更，刷新发送对象
    if (userSelectedTarget != null && userSelectedTarget!.uuid == member.uuid) {
      userSelectedTarget = member;
      updateSendTarget(newTarget: member);
    }

    /// 如果是当前对象身份变更，刷新选中对象
    if (sendToTarget.value is NERoomMember &&
        (sendToTarget.value as NERoomMember).uuid == member.uuid) {
      updateSendTarget(newTarget: member);
    }
  }

  void memberLeaveRoom(List<NERoomMember> members) {
    /// 如果用户选择的对象离开了
    if (userSelectedTarget != null &&
        members
            .where((element) => element.uuid == userSelectedTarget!.uuid)
            .isNotEmpty) {
      userSelectedTarget = null;
    }

    /// 等候室成员收到主持人离开的消息
    if (roomContext.isInWaitingRoom()) {
      updateHostAndCoHostInWaitingRoom();
      return;
    }

    /// 如果当前选择的对象离开了，重置发送对象
    if (members.contains(_sendToTarget.value)) {
      updateSendTarget();
    }
  }

  void memberJoinRoom(List<NERoomMember> members) {
    /// 等候室成员收到主持人加入的消息
    if (roomContext.isInWaitingRoom()) {
      updateHostAndCoHostInWaitingRoom();
      return;
    }

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
    /// 等候室成员收到主持人改名消息
    if (roomContext.isInWaitingRoom()) {
      updateHostAndCoHostInWaitingRoom();
      return;
    }

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

  /// 获取等候室成员
  NEWaitingRoomMember? getWaitingRoomMember(String uuid) {
    return waitingRoomManager?.userList
        .where((element) => element.uuid == uuid)
        .firstOrNull;
  }

  dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _waitingRoomHostAndCoHost.clear();
    _connectivitySubscription?.cancel();
    NEMeetingKit.instance
        .getPreMeetingService()
        .unRegisterScheduleMeetingStatusChange(onMeetingStatusChange);
    roomContext.removeEventCallback(_roomEventCallback);
    _sendToTarget.dispose();
    _chatPermissionChanged.close();
    _waitingRoomChatPermissionChanged.close();
    _waitingRoomHostAndCoHostUpdated.close();
  }
}
