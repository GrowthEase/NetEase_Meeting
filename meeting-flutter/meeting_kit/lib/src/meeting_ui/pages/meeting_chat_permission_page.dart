// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingChatPermissionPage extends StatefulWidget {
  static const String routeName = "meetingChatPermission";
  final NERoomContext _roomContext;
  final WaitingRoomManager waitingRoomManager;

  MeetingChatPermissionPage(this._roomContext, this.waitingRoomManager);

  @override
  State<StatefulWidget> createState() {
    return MeetingChatPermissionState(_roomContext, waitingRoomManager);
  }
}

class MeetingChatPermissionState
    extends LifecycleBaseState<MeetingChatPermissionPage>
    with MeetingKitLocalizationsMixin, MeetingStateScope {
  late final NERoomContext _roomContext;
  final WaitingRoomManager waitingRoomManager;

  MeetingChatPermissionState(this._roomContext, this.waitingRoomManager);

  ValueNotifier<NEChatPermission?> chatPermission = ValueNotifier(null);
  ValueNotifier<bool> waitingRoomChatPermission = ValueNotifier(false);
  late final NERoomEventCallback roomEventCallback;

  @override
  void initState() {
    super.initState();
    chatPermission.value = _roomContext.chatPermission;
    waitingRoomChatPermission.value = _roomContext.waitingRoomChatPermission ==
        NEWaitingRoomChatPermission.privateChatHostOnly;
    _roomContext.addEventCallback(roomEventCallback = NERoomEventCallback(
      roomPropertiesChanged: _onRoomPropertiesChanged,
      memberRoleChanged: _onMemberRoleChanged,
    ));
  }

  void _onRoomPropertiesChanged(Map<String, String> properties) {
    if (properties.containsKey(NEChatPermissionProperty.key)) {
      chatPermission.value = _roomContext.chatPermission;
      setState(() {});
    }
    if (properties.containsKey(NEWaitingRoomChatPermissionProperty.key)) {
      waitingRoomChatPermission.value =
          _roomContext.waitingRoomChatPermission ==
              NEWaitingRoomChatPermission.privateChatHostOnly;
    }
  }

  void _onMemberRoleChanged(
      NERoomMember member, NERoomRole oldRole, NERoomRole newRole) {
    if (_roomContext.isMySelf(member.uuid) &&
        !_roomContext.isMySelfHostOrCoHost()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _roomContext.removeEventCallback(roomEventCallback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return Column(
      children: [
        MeetingCard(
            margin: EdgeInsets.zero,
            title: meetingUiLocalizations.chatPermissionInMeeting,
            children: [
              _buildMeetingChatPermission(
                  meetingUiLocalizations.chatFree, NEChatPermission.freeChat),
              _buildMeetingChatPermission(meetingUiLocalizations.chatPublicOnly,
                  NEChatPermission.publicChatOnly),
              _buildMeetingChatPermission(
                  meetingUiLocalizations.chatPrivateHostOnly,
                  NEChatPermission.privateChatHostOnly),
              _buildMeetingChatPermission(
                  meetingUiLocalizations.chatMuted, NEChatPermission.noChat),
            ]),
        if (waitingRoomManager.isFeatureSupported)
          MeetingCard(
              margin: EdgeInsets.only(top: 16),
              title: meetingUiLocalizations.chatPermissionInWaitingRoom,
              children: [
                _buildWaitingRoomChatPermission(),
              ]),
      ],
    );
  }

  Widget _buildMeetingChatPermission(String title, NEChatPermission itemValue) {
    return MeetingCheckItem(
      title: title,
      isSelected: chatPermission.value == itemValue,
      onTap: () {
        doIfNetworkAvailable(() async {
          _roomContext.updateChatPermission(itemValue).then((result) {
            if (!mounted) return;
            if (!result.isSuccess()) {
              showToast(
                result.msg ?? meetingUiLocalizations.globalOperationFail,
              );
            }
            setState(() {});
          });
        });
      },
    );
  }

  Widget _buildWaitingRoomChatPermission() {
    return MeetingSwitchItem(
      switchKey: MeetingUIValueKeys.waitingChatPermissionSwitch,
      title: meetingUiLocalizations.chatWaitingRoomPrivateHostOnly,
      valueNotifier: waitingRoomChatPermission,
      onChanged: (on) {
        doIfNetworkAvailable(() async {
          _roomContext
              .updateWaitingRoomChatPermission(on
                  ? NEWaitingRoomChatPermission.privateChatHostOnly
                  : NEWaitingRoomChatPermission.noChat)
              .then((result) {
            if (mounted && !result.isSuccess()) {
              showToast(
                result.msg ?? meetingUiLocalizations.globalOperationFail,
              );
            }
          });
        });
      },
    );
  }
}
