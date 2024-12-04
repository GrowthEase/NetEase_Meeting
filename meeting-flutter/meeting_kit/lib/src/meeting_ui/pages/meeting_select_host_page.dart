// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 聊天室选择发送端界面
class MeetingSelectHostPage extends StatefulWidget {
  final NERoomContext roomContext;
  final ValueNotifier<bool> hideAvatar;

  MeetingSelectHostPage(
    this.roomContext,
    this.hideAvatar,
  );

  @override
  State<StatefulWidget> createState() {
    return MeetingSelectHostState(roomContext, hideAvatar);
  }
}

class MeetingSelectHostState extends LifecycleBaseState<MeetingSelectHostPage>
    with
        EventTrackMixin,
        MeetingKitLocalizationsMixin,
        MeetingStateScope,
        _AloggerMixin {
  MeetingSelectHostState(
    this.roomContext,
    this.hideAvatar,
  );

  final NERoomContext roomContext;
  late final NERoomEventCallback roomEventCallback;
  final ValueNotifier<bool> hideAvatar;
  final checkedIcon = Icon(
    NEMeetingIconFont.icon_check_line,
    size: 16,
    color: _UIColors.color_337eff,
  );
  NEBaseRoomMember? wantHostTargetMember;

  @override
  void initState() {
    super.initState();
    roomContext.addEventCallback(roomEventCallback = NERoomEventCallback(
      memberJoinRoom: _onMemberJoinOrLeaveRoom,
      memberLeaveRoom: _onMemberJoinOrLeaveRoom,
    ));
    wantHostTargetMember = SelectHostHelper().getDefaultWantHostMember();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _UIColors.globalBg,
      appBar: TitleBar(
        title: TitleBarTitle(meetingUiLocalizations.meetingAppointNewHost),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return AutoPopIfNotManager(
      roomContext: roomContext,
      child: _buildMemberListPage(),
    );
  }

  void _onMemberJoinOrLeaveRoom(List<NERoomMember> members) {
    if (SelectHostHelper().getFilteredMemberList().isEmpty) {
      Navigator.of(context).pop();
    } else {
      wantHostTargetMember = SelectHostHelper().getDefaultWantHostMember();
    }
    setState(() {});
  }

  Widget _buildMemberListPage() {
    final memberList = SelectHostHelper().getFilteredMemberList();
    return Column(
      children: [
        buildMembers(memberList),
        Spacer(),
        buildBottomButton(),
      ],
    );
  }

  Widget buildMembers(List<NEBaseRoomMember> userList) {
    final len = userList.length;

    return MeetingCard(
        margin: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16),
        children: [
          ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              primary: false,
              cacheExtent: 48,
              itemCount: len + 1,
              itemBuilder: (context, index) {
                if (index == len) {
                  return SizedBox(height: 1);
                }
                return buildMemberItem(userList[index]);
              })
        ]);
  }

  Widget buildMemberItem(NEBaseRoomMember user) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          wantHostTargetMember = user;
        });
        // chatRoomManager.updateSendTarget(newTarget: user, userSelected: true);
      },
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: hideAvatar,
              builder: (context, hideAvatar, child) {
                return NEMeetingAvatar.medium(
                  name: user.name,
                  url: user.avatar,
                  hideImageAvatar: hideAvatar,
                );
              },
            ),
            SizedBox(width: 6),
            Expanded(
              child: _memberItemNick(user),
            ),
            if (wantHostTargetMember?.uuid == user.uuid) checkedIcon,
          ],
        ),
      ),
    );
  }

  /// 昵称和头衔
  Widget _memberItemNick(NEBaseRoomMember user) {
    var subtitle = <String>[];
    String? hostName;
    if (user is NERoomMember) {
      hostName = user.role.name;
    }
    switch (hostName) {
      case MeetingRoles.kHost:
        subtitle.add(meetingUiLocalizations.participantHost);
        break;
      case MeetingRoles.kCohost:
        subtitle.add(meetingUiLocalizations.participantCoHost);
        break;
    }
    final subTitleTextStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: _UIColors.color_999999,
      decoration: TextDecoration.none,
    );
    if (subtitle.isNotEmpty) {
      return Column(
        children: [
          Text(
            user.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: _UIColors.color_333333,
              decoration: TextDecoration.none,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${subtitle.join(',')}',
            style: subTitleTextStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } else {
      return Text(
        user.name,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: _UIColors.color_333333,
            decoration: TextDecoration.none),
      );
    }
  }

  ///构建分割线
  Widget _buildDivider({bool isShow = true}) {
    return Visibility(
      visible: isShow,
      child: Container(height: 1, color: _UIColors.globalBg),
    );
  }

  Widget buildSubmit() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                return _UIColors.color_337eff;
              }),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  side: BorderSide(color: _UIColors.color_337eff, width: 0),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              )),
          onPressed: commit,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: Text(
              meetingUiLocalizations.meetingAppointAndLeave,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }

  bool canSubmit() {
    return SelectHostHelper().getFilteredMemberList().isNotEmpty;
  }

  void commit() {
    if (roomContext.getMember(wantHostTargetMember?.uuid) == null) {
      /// 执行移交主持人时，check 用户是否还在会议中，不在的话直接提示 移交主持人失败
      showToast(meetingUiLocalizations.participantFailedToTransferHost);
      return;
    }

    Navigator.of(context).pop(wantHostTargetMember!.uuid);
  }

  Widget buildBottomButton() {
    return Container(
      color: _UIColors.white,
      child: Padding(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 10 + MediaQuery.of(context).padding.bottom),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.resolveWith<Color>((states) {
                  return states.contains(WidgetState.disabled)
                      ? _UIColors.blue_50_337eff
                      : _UIColors.color_337eff;
                }),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    side: BorderSide(
                        color: canSubmit()
                            ? _UIColors.color_337eff
                            : _UIColors.blue_50_337eff,
                        width: 0),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                )),
            onPressed: canSubmit() ? commit : null,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: Text(
                meetingUiLocalizations.meetingAppointAndLeave,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    roomContext.removeEventCallback(roomEventCallback);
    super.dispose();
  }
}
