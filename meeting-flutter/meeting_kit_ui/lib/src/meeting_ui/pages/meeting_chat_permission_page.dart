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
  ValueNotifier<NEWaitingRoomChatPermission?> waitingRoomChatPermission =
      ValueNotifier(null);
  late final NERoomEventCallback roomEventCallback;

  @override
  void initState() {
    super.initState();
    chatPermission.value = _roomContext.chatPermission;
    waitingRoomChatPermission.value = _roomContext.waitingRoomChatPermission;
    _roomContext.addEventCallback(roomEventCallback = NERoomEventCallback(
      roomPropertiesChanged: _onRoomPropertiesChanged,
      memberRoleChanged: _onMemberRoleChanged,
    ));
  }

  void _onRoomPropertiesChanged(Map<String, String> properties) {
    if (properties.containsKey(NEChatPermissionProperty.key)) {
      chatPermission.value = _roomContext.chatPermission;
    }
    if (properties.containsKey(NEWaitingRoomChatPermissionProperty.key)) {
      waitingRoomChatPermission.value = _roomContext.waitingRoomChatPermission;
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
    return Scaffold(
      backgroundColor: _UIColors.globalBg,
      appBar: TitleBar(
        title: TitleBarTitle(meetingUiLocalizations.chat),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSubTitle(meetingUiLocalizations.chatPermissionInMeeting),
          _buildMeetingChatPermission(
              meetingUiLocalizations.chatFree, NEChatPermission.freeChat),
          _buildSplit(),
          _buildMeetingChatPermission(meetingUiLocalizations.chatPublicOnly,
              NEChatPermission.publicChatOnly),
          _buildSplit(),
          _buildMeetingChatPermission(
              meetingUiLocalizations.chatPrivateHostOnly,
              NEChatPermission.privateChatHostOnly),
          _buildSplit(),
          _buildMeetingChatPermission(
              meetingUiLocalizations.chatMuted, NEChatPermission.noChat),
          if (waitingRoomManager.isFeatureSupported) ...[
            _buildSubTitle(meetingUiLocalizations.chatPermissionInWaitingRoom),
            _buildWaitingRoomChatPermission(),
            _buildSplit(),
          ],
        ],
      ),
    );
  }

  Widget _buildSplit() {
    return Container(
      color: _UIColors.globalBg,
      padding: EdgeInsets.only(left: 20),
      child: Divider(height: 0.5),
    );
  }

  Widget _buildSubTitle(String subTitle) {
    return Container(
      child: Text(subTitle,
          style: TextStyle(fontSize: 14, color: _UIColors.color_999999)),
      padding: EdgeInsets.only(left: 20, top: 16, bottom: 8),
    );
  }

  Widget _buildMeetingChatPermission(String title, NEChatPermission itemValue) {
    return _buildItemCheck<NEChatPermission?>(
      title: title,
      valueNotifier: chatPermission,
      itemValue: itemValue,
      onClick: () {
        doIfNetworkAvailable(() async {
          _roomContext.updateChatPermission(itemValue).then((result) {
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

  Widget _buildWaitingRoomChatPermission() {
    return _buildItemSwitch<NEWaitingRoomChatPermission?>(
      key: MeetingUIValueKeys.waitingChatPermissionSwitch,
      title: meetingUiLocalizations.chatWaitingRoomPrivateHostOnly,
      valueNotifier: waitingRoomChatPermission,
      itemValue: NEWaitingRoomChatPermission.privateChatHostOnly,
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

  Widget _buildItemCheck<T>({
    required String title,
    required T itemValue,
    required ValueNotifier<T> valueNotifier,
    required Function() onClick,
    Key? key,
  }) {
    return GestureDetector(
      key: key,
      onTap: onClick,
      child: Container(
        height: 56,
        color: _UIColors.white,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: _UIColors.black_222222, fontSize: 16),
              ),
            ),
            ValueListenableBuilder<T>(
                valueListenable: valueNotifier,
                builder: (context, value, child) {
                  return Visibility(
                      child: Icon(NEMeetingIconFont.icon_check_line,
                          size: 16, color: _UIColors.color_337eff),
                      visible: value == itemValue);
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildItemSwitch<T>({
    required String title,
    required T itemValue,
    required ValueNotifier<T> valueNotifier,
    required Function(bool newValue) onChanged,
    Key? key,
  }) {
    return Container(
      height: 56,
      color: _UIColors.white,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: _UIColors.black_222222, fontSize: 16),
            ),
          ),
          ValueListenableBuilder<T>(
              valueListenable: valueNotifier,
              builder: (context, value, child) {
                return CupertinoSwitch(
                    key: key,
                    value: value == itemValue,
                    onChanged: (newValue) => onChanged.call(newValue),
                    activeColor: _UIColors.blue_337eff);
              }),
        ],
      ),
    );
  }
}
