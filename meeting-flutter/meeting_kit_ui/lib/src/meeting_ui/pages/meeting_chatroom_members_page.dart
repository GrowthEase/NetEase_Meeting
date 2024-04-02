// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 聊天室选择发送端界面
class MeetingChatRoomMemberPage extends StatefulWidget {
  final NERoomContext roomContext;
  final WaitingRoomManager? waitingRoomManager;
  final ChatRoomManager chatRoomManager;
  final Stream? roomInfoUpdatedEventStream;

  MeetingChatRoomMemberPage(
    this.roomContext,
    this.waitingRoomManager,
    this.chatRoomManager,
    this.roomInfoUpdatedEventStream,
  );

  @override
  State<StatefulWidget> createState() {
    return MeetingChatRoomMembersPageState(roomContext, waitingRoomManager,
        chatRoomManager, roomInfoUpdatedEventStream);
  }
}

class MeetingChatRoomMembersPageState
    extends LifecycleBaseState<MeetingChatRoomMemberPage>
    with
        EventTrackMixin,
        MeetingKitLocalizationsMixin,
        MeetingStateScope,
        _AloggerMixin {
  MeetingChatRoomMembersPageState(
    this.roomContext,
    this.waitingRoomManager,
    this.chatRoomManager,
    this.roomInfoUpdatedEventStream,
  );

  static const _radius = Radius.circular(8);

  bool allowSelfAudioOn = false;
  bool allowSelfVideoOn = false;

  final NERoomContext roomContext;
  final WaitingRoomManager? waitingRoomManager;
  final ChatRoomManager chatRoomManager;
  final Stream? roomInfoUpdatedEventStream;
  late final NERoomEventCallback roomEventCallback;

  final _subscriptions = <StreamSubscription>[];

  final checkedIcon = Icon(
    NEMeetingIconFont.icon_check_line,
    size: 16,
    color: _UIColors.color_337eff,
  );

  @override
  void initState() {
    roomContext.addEventCallback(roomEventCallback = NERoomEventCallback(
      memberRoleChanged: _onMemberRoleChanged,
    ));
    _subscriptions.add(
        chatRoomManager.chatPermissionChanged.listen(_onChatPermissionChanged));
    _subscriptions.add(chatRoomManager.waitingRoomChatPermissionChanged
        .listen(_onWaitingRoomChatPermissionChanged));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    var padding = data.size.height * 0.15;
    return Padding(
      padding: EdgeInsets.only(top: padding),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.only(topLeft: _radius, topRight: _radius)),
        child: MeetingMemberPageView(
          title: (_) => meetingUiLocalizations.chatSendTo,
          roomContext: roomContext,
          waitingRoomManager: waitingRoomManager,
          chatRoomManager: chatRoomManager,
          roomInfoUpdatedEventStream: roomInfoUpdatedEventStream,
          showUserEnterHint: false,
          pageFilter: (page) {
            return (page.type == _MembersPageType.inMeeting &&
                    meetingUIState.inMeetingChatroom.hasJoin) ||
                (page.type == _MembersPageType.waitingRoom &&
                    meetingUIState.waitingRoomChatroom.hasJoin);
          },
          pageBuilder: (page, searchKey) =>
              _buildMemberListPage(page, searchKey),
          memberSize: calculateMemberSize,
        ),
      ),
    );
  }

  /// 计算成员列表的大小
  int calculateMemberSize(_PageData pageData, _) =>
      getFilterMemberList(pageData).length;

  /// 获取筛选后的成员列表
  List<NEBaseRoomMember> getFilterMemberList(_PageData pageData) {
    final memberList = <NEBaseRoomMember>[];
    if (pageData.type == _MembersPageType.inMeeting) {
      final members = pageData.filteredUserList as List<NEBaseRoomMember>;

      /// 不是自由聊天的时候，移除普通成员
      if (roomContext.chatPermission != NEChatPermission.freeChat &&
          !roomContext.isMySelfHostOrCoHost()) {
        members.removeWhere((member) => chatRoomManager.hostAndCoHost
            .where((e) => member.uuid == e.uuid)
            .isEmpty);
      }
      memberList.addAll(members);
    } else {
      if (roomContext.isMySelfHostOrCoHost()) {
        memberList.addAll(pageData.filteredUserList as List<NEBaseRoomMember>);
      } else {
        memberList.addAll(chatRoomManager.hostAndCoHost);
      }
    }

    /// 移除自己和SIP成员
    memberList.removeWhere((element) =>
        roomContext.isMySelf(element.uuid) ||
        (element is NERoomMember && element.clientType == NEClientType.sip));
    return memberList;
  }

  Widget _buildMemberListPage(_PageData pageData, String? searchKey) {
    final memberList = getFilterMemberList(pageData);
    final isChatToAllEnabled = roomContext.isMySelfHostOrCoHost() ||
        (!roomContext.isInWaitingRoom() &&
            roomContext.chatPermission != NEChatPermission.privateChatHostOnly);
    return Column(
      children: [
        if (isChatToAllEnabled && searchKey?.isNotEmpty != true) ...[
          buildChatToAllMembers(pageData.type),
          buildDivider(),
        ] else if (memberList.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: Text(
              meetingUiLocalizations.participantNotFound,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: _UIColors.color3D3D3D,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        Expanded(
          child: buildMembers(memberList),
        ),
      ],
    );
  }

  Widget buildMembers(List<NEBaseRoomMember> userList) {
    final len = userList.length;

    return ListView.separated(
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
        },
        separatorBuilder: (context, index) {
          return buildDivider();
        });
  }

  Widget buildChatToAllMembers(_MembersPageType pageType) {
    final chatRoomType = pageType == _MembersPageType.inMeeting
        ? NEChatroomType.common
        : NEChatroomType.waitingRoom;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        chatRoomManager.updateSendTarget(
            newTarget: chatRoomType, userSelected: true);
        Navigator.of(context).pop();
      },
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              NEMeetingIconFont.icon_all_members_32,
              size: 32,
              color: _UIColors.color656A72,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                meetingUiLocalizations.chatAllMembers,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: _UIColors.color_333333,
                  decoration: TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (chatRoomManager.sendToTarget.value == chatRoomType) checkedIcon,
          ],
        ),
      ),
    );
  }

  Widget buildMemberItem(NEBaseRoomMember user) {
    final target = chatRoomManager.sendToTarget.value;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        chatRoomManager.updateSendTarget(newTarget: user, userSelected: true);
        Navigator.of(context).pop();
      },
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            NEMeetingAvatar.medium(
              name: user.name,
              url: user.avatar,
            ),
            SizedBox(width: 6),
            Expanded(
              child: _memberItemNick(user),
            ),
            if (target is NEBaseRoomMember && target.uuid == user.uuid)
              checkedIcon,
          ],
        ),
      ),
    );
  }

  Widget _memberItemNick(NEBaseRoomMember user) {
    var subtitle = <String>[];
    if (user is NERoomMember) {
      switch (user.role.name) {
        case MeetingRoles.kHost:
          subtitle.add(meetingUiLocalizations.participantHost);
          break;
        case MeetingRoles.kCohost:
          subtitle.add(meetingUiLocalizations.participantCoHost);
          break;
      }
    }
    if (roomContext.isMySelf(user.uuid)) {
      subtitle.add(meetingUiLocalizations.participantMe);
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
            '(${subtitle.join(',')})',
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
  Widget buildDivider({bool isShow = true}) {
    return Visibility(
      visible: isShow,
      child: Container(height: 1, color: _UIColors.globalBg),
    );
  }

  void _onMemberRoleChanged(
      NERoomMember member, NERoomRole oldRole, NERoomRole newRole) {
    if (roomContext.isMySelf(member.uuid)) {
      setState(() {});
    }
  }

  void _onChatPermissionChanged(NEChatPermission chatPermission) {
    if (!roomContext.isMySelfHostOrCoHost() &&
        roomContext.chatPermission == NEChatPermission.noChat) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  void _onWaitingRoomChatPermissionChanged(
      NEWaitingRoomChatPermission chatPermission) {
    if (!roomContext.isMySelfHostOrCoHost() &&
        roomContext.waitingRoomChatPermission ==
            NEWaitingRoomChatPermission.noChat) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _subscriptions.forEach((element) {
      element.cancel();
    });
    roomContext.removeEventCallback(roomEventCallback);
    super.dispose();
  }
}
