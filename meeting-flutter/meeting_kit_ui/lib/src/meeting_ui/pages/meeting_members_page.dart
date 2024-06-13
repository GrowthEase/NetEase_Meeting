// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 参会者界面
class MeetMemberPage extends StatefulWidget {
  final MembersArguments arguments;
  final _MembersPageType? initialPageType;
  final void Function(dynamic actionType, NEBaseRoomMember user)?
      onMemberItemClick;

  MeetMemberPage(this.arguments,
      {this.initialPageType, this.onMemberItemClick});

  @override
  State<StatefulWidget> createState() {
    return MeetMemberPageState(arguments, initialPageType, onMemberItemClick);
  }
}

class MeetMemberPageState extends LifecycleBaseState<MeetMemberPage>
    with
        EventTrackMixin,
        MeetingKitLocalizationsMixin,
        MeetingStateScope,
        _AloggerMixin {
  MeetMemberPageState(
      this.arguments, this.initialPageType, this.onMemberItemClick);

  final MembersArguments arguments;
  final _MembersPageType? initialPageType;

  bool allowSelfAudioOn = false;
  bool allowSelfVideoOn = false;

  late final NERoomContext roomContext;
  late final NERoomWhiteboardController whiteboardController;
  late final NERoomRtcController rtcController;
  late final WaitingRoomManager waitingRoomManager;
  late final String roomId;
  late final int maxCount;
  final void Function(dynamic actionType, NEBaseRoomMember user)?
      onMemberItemClick;

  @override
  void initState() {
    super.initState();
    roomContext = arguments.roomContext;
    whiteboardController = roomContext.whiteboardController;
    rtcController = roomContext.rtcController;
    waitingRoomManager = arguments.waitingRoomManager;
    roomId = roomContext.roomUuid;
    maxCount = parseMaxCountByContract(roomContext.extraData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeetingMemberPageView(
        title: title,
        roomContext: roomContext,
        waitingRoomManager: waitingRoomManager,
        roomInfoUpdatedEventStream: arguments.roomInfoUpdatedEventStream,
        initialPageType: initialPageType,
        pageFilter: (_PageData page) {
          if (page.type == _MembersPageType.notYetJoined) {
            /// 只有主持人跟联席主持人才展示未入会列表
            return isSelfHostOrCoHost();
          }
          return true;
        },
        pageBuilder: (page, _) {
          if (page.filteredUserList.isEmpty) {
            return Column(children: [
              SizedBox(height: 40),
              Text(
                meetingUiLocalizations.participantNotFound,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: _UIColors.color3D3D3D,
                  decoration: TextDecoration.none,
                ),
              ),
            ]);
          }
          if (page.type == _MembersPageType.inMeeting) {
            return _buildInMeetingPage(
                page.filteredUserList as List<NERoomMember>);
          } else if (page.type == _MembersPageType.waitingRoom) {
            return WaitingRoomMemberList(
              waitingRoomManager,
              page.filteredUserList as List<NEWaitingRoomMember>,
              arguments.isMySelfManagerListenable,
              onMemberItemClick,
            );
          } else if (page.type == _MembersPageType.notYetJoined &&
              isSelfHostOrCoHost()) {
            return InviteMemberList(
              arguments.isMySelfManagerListenable,
              page.filteredUserList as List<NERoomMember>,
              arguments.roomContext.sipController,
              arguments.roomContext.appInviteController,
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  int parseMaxCountByContract(String? data) {
    if (data != null) {
      try {
        final json = jsonDecode(data);
        if (json is Map) {
          return (json['maxCount'] as int?) ?? 0;
        }
      } catch (e) {}
    }
    return 0;
  }

  String title(PageDataManager pageDataManager) {
    var title = isSelfHostOrCoHost()
        ? meetingUiLocalizations.participantAttendees
        : meetingUiLocalizations.participants;
    if (!pageDataManager.shouldShowTabBar) {
      title +=
          '(${pageDataManager.inMeeting.userCount}${maxCount > 0 ? '/$maxCount' : ''})';
    }
    return title;
  }

  Widget _buildInMeetingPage(List<NERoomMember> userList) {
    return Column(
      children: [
        Expanded(
          child: buildMembers(userList),
        ),
        if (isSelfHostOrCoHost() ||
            (roomContext.canReclaimHost &&
                roomContext.getHostMember() != null)) ...[
          buildDivider(),
          SizedBox(height: 8),
          if (isSelfHostOrCoHost()) ...[
            buildMuteAllAudioActions(),
            SizedBox(height: 8),
            buildMuteAllVideoActions(),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: MeetingTextButton.outlined(
                  text: meetingUiLocalizations.meetingReclaimHost,
                  onPressed: () => reclaimHost(roomContext.getHostMember()),
                ),
              ),
            ),
          ],
          SizedBox(height: 8),
        ]
      ],
    );
  }

  Widget shadow() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: _UIColors.white,
        boxShadow: [
          BoxShadow(
              color: _UIColors.color_19242744,
              offset: Offset(4, 0),
              blurRadius: 8),
        ],
      ),
    );
  }

  /// 自己是否是主持人或者联席主持人
  bool isSelfHostOrCoHost() {
    return roomContext.isMySelfHost() || roomContext.isMySelfCoHost();
  }

  Widget buildMembers(List<NERoomMember> userList) {
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

  ///构建分割线
  Widget buildDivider({bool isShow = true}) {
    return Visibility(
      visible: isShow,
      child: Container(height: 1, color: _UIColors.globalBg),
    );
  }

  /// 创建"全体视频关闭/打开widget"
  Widget buildMuteAllVideoActions() {
    return Visibility(
      visible: !arguments.options.noMuteAllVideo,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: MeetingTextButton.outlined(
                text: meetingUiLocalizations.participantTurnOffVideos,
                onPressed: _onMuteAllVideo,
              ),
            ),
            SizedBox(width: 9),
            Expanded(
              child: MeetingTextButton.outlined(
                text: meetingUiLocalizations.participantTurnOnVideos,
                onPressed: unMuteAllVideo2Server,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 管理会议成员弹窗下的 全体静音相关操作ui
  Widget buildMuteAllAudioActions() {
    return Visibility(
      visible: !arguments.options.noMuteAllAudio,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: MeetingTextButton.outlined(
                text: meetingUiLocalizations.participantMuteAudioAll,
                onPressed: _onMuteAllAudio,
              ),
            ),
            SizedBox(width: 9),
            Expanded(
              child: MeetingTextButton.outlined(
                text: meetingUiLocalizations.participantUnmuteAll,
                onPressed: unMuteAllAudio2Server,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMuteAllAudio() async {
    final result = await showConfirmDialogWithCheckbox(
      title: meetingUiLocalizations.participantMuteAudioAllDialogTips,
      checkboxMessage: meetingUiLocalizations.participantMuteAllAudioTip,
      cancelLabel: meetingUiLocalizations.globalCancel,
      okLabel: meetingUiLocalizations.participantMuteAudioAll,
      contentWrapperBuilder: (child) {
        return AutoPopScope(
          listenable: arguments.isMySelfManagerListenable,
          onWillAutoPop: (_) {
            return !arguments.isMySelfManagerListenable.value;
          },
          child: child,
        );
      },
    );
    if (!mounted || result == null) return;
    lifecycleExecute(rtcController.muteAllParticipantsAudio(result.checked))
        .then((result) {
      if (!mounted || result == null) return;
      if (result.isSuccess()) {
        showToast(meetingUiLocalizations.participantMuteAllAudioSuccess);
      } else {
        showToast(
            result.msg ?? meetingUiLocalizations.participantMuteAllAudioFail);
      }
    });
  }

  void unMuteAllAudio2Server() {
    lifecycleExecute(rtcController.unmuteAllParticipantsAudio()).then((result) {
      if (!mounted || result == null) return;
      if (result.isSuccess()) {
        showToast(meetingUiLocalizations.participantUnMuteAllAudioSuccess);
      } else {
        showToast(
            result.msg ?? meetingUiLocalizations.participantUnMuteAllAudioFail);
      }
    });
  }

  void _onMuteAllVideo() async {
    final result = await showConfirmDialogWithCheckbox(
      title: meetingUiLocalizations.participantMuteVideoAllDialogTips,
      checkboxMessage: meetingUiLocalizations.participantMuteAllVideoTip,
      cancelLabel: meetingUiLocalizations.globalCancel,
      okLabel: meetingUiLocalizations.participantTurnOffVideos,
      contentWrapperBuilder: (child) {
        return AutoPopScope(
          listenable: arguments.isMySelfManagerListenable,
          onWillAutoPop: (_) {
            return !arguments.isMySelfManagerListenable.value;
          },
          child: child,
        );
      },
    );
    if (!mounted || result == null) return;
    lifecycleExecute(rtcController.muteAllParticipantsVideo(result.checked))
        .then((result) {
      if (!mounted || result == null) return;
      if (result.isSuccess()) {
        showToast(meetingUiLocalizations.participantMuteAllVideoSuccess);
      } else {
        showToast(
            result.msg ?? meetingUiLocalizations.participantMuteAllVideoFail);
      }
    });
  }

  void unMuteAllVideo2Server() {
    lifecycleExecute(rtcController.unmuteAllParticipantsVideo()).then((result) {
      if (!mounted || result == null) return;
      if (result.isSuccess()) {
        showToast(meetingUiLocalizations.participantUnMuteAllVideoSuccess);
      } else {
        showToast(
            result.msg ?? meetingUiLocalizations.participantUnMuteAllVideoFail);
      }
    });
  }

  Widget buildMemberItem(NERoomMember user) {
    /// 未加入 RTC 的成员也展示在列表中
    if (!user.isInRtcChannel) {
      return GestureDetector(
        key: MeetingUIValueKeys.memberItem,
        behavior: HitTestBehavior.opaque,
        onTap: () => handleInMeetingMemberItemClick(user),
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
              Spacer(),
              Text(
                meetingUiLocalizations.participantJoining,
                style: TextStyle(
                  color: Color(0xFF53576A),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      key: MeetingUIValueKeys.memberItem,
      behavior: HitTestBehavior.opaque,
      onTap: () => handleInMeetingMemberItemClick(user),
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
            ValueListenableBuilder<bool>(
              valueListenable: user.isInCallListenable,
              builder: (context, isInCall, child) {
                if (!isInCall) {
                  return SizedBox.shrink();
                } else {
                  return Container(
                    margin: EdgeInsets.only(right: 16.0),
                    child: const Icon(
                      Icons.phone,
                      size: 20.0,
                      color: const Color(0xFF26CE17),
                    ),
                  );
                }
              },
            ),
            if (isSelfHostOrCoHost() && user.isRaisingHand) ...[
              Icon(
                  key: MeetingUIValueKeys.handsUpIcon,
                  NEMeetingIconFont.icon_raisehands,
                  color: _UIColors.color_337eff,
                  size: 20),
              const SizedBox(width: 16),
            ],
            if (user.clientType == NEClientType.sip) ...[
              Icon(NEMeetingIconFont.icon_sip,
                  color: _UIColors.color_337eff, size: 20),
              const SizedBox(width: 16),
            ],
            if (user.isSharingWhiteboard) ...[
              Icon(NEMeetingIconFont.icon_whiteboard,
                  color: _UIColors.color_337eff, size: 20),
              const SizedBox(width: 16),
            ],
            if (user.isSharingScreen) ...[
              Icon(NEMeetingIconFont.icon_yx_tv_sharescreen,
                  color: _UIColors.color_337eff, size: 20),
              const SizedBox(width: 16),
            ],
            if (roomContext.getFocusUuid() == user.uuid) ...[
              Icon(NEMeetingIconFont.icon_focus,
                  color: const Color(0xFF49494d), size: 20),
              const SizedBox(width: 16),
            ],
            Icon(
                !user.isVideoOn
                    ? NEMeetingIconFont.icon_yx_tv_video_offx
                    : NEMeetingIconFont.icon_yx_tv_video_onx,
                color: !user.isVideoOn ? Colors.red : const Color(0xFF49494d),
                size: 20),
            if (user.isAudioConnected) ...[
              const SizedBox(width: 16),
              SizedBox(
                width: 20,
                height: 20,
                child: buildRoomUserVolumeIndicator(user),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildRoomUserVolumeIndicator(NERoomMember user, [double? opacity]) {
    if ((!arguments.audioVolumeStreams.containsKey(user.uuid) ||
            !user.isAudioOn) &&
        user.isAudioConnected) {
      return Icon(
        NEMeetingIconFont.icon_yx_tv_voice_offx,
        color: Colors.red,
        size: 20,
      );
    } else {
      return AnimatedMicphoneVolume.dark(
        volume: arguments.audioVolumeStreams[user.uuid]!.stream,
      );
    }
  }

  Widget buildPopupText(String text) {
    return Text(text,
        style: TextStyle(color: _UIColors.color_007AFF, fontSize: 20));
  }

  Widget buildActionSheet(
      String text, NERoomMember user, MemberActionType memberActionType) {
    return CupertinoActionSheetAction(
      child: buildPopupText(text),
      onPressed: () {
        Navigator.pop(context, _ActionData(memberActionType, user));
      },
    );
  }

  List<Widget> getInMeetingUserActions(
      BuildContext buildContext, NERoomMember user) {
    if (roomContext.getMember(user.uuid) == null) {
      return [];
    }

    final isSelfHost = roomContext.isMySelfHost();
    final isSelf = roomContext.isMySelf(user.uuid);
    final isUserCoHost = roomContext.isCoHost(user.uuid);
    final isUserHost = roomContext.isHost(user.uuid);
    final isPinned = roomContext.getFocusUuid() == user.uuid;
    final hasScreenSharing =
        roomContext.rtcController.getScreenSharingUserUuid() != null;
    final hasWhiteboardSharing =
        whiteboardController.getWhiteboardSharingUserUuid() != null;
    final hasInteract =
        whiteboardController.isDrawWhiteboardEnabledWithUserId(user.uuid);
    final isCurrentSharingWhiteboard =
        whiteboardController.isWhiteboardSharing(user.uuid);
    final isSelfSharingWhiteboard = whiteboardController.isSharingWhiteboard();
    final lockedUser = buildContext.read<MeetingUIState>().lockedUser;

    if (user.clientType == NEClientType.sip) {
      return <Widget>[
        if (isSelfHostOrCoHost() && !arguments.options.noRename)
          buildActionSheet(meetingUiLocalizations.participantRename, user,
              MemberActionType.updateNick),
        if (isSelfHostOrCoHost() && user.isAudioOn && user.isAudioConnected)
          buildActionSheet(meetingUiLocalizations.participantMute, user,
              MemberActionType.hostMuteAudio),
        if (isSelfHostOrCoHost() && !user.isAudioOn && user.isAudioConnected)
          buildActionSheet(meetingUiLocalizations.participantUnmute, user,
              MemberActionType.hostUnMuteAudio),
        if (isSelfHostOrCoHost() && user.isVideoOn)
          buildActionSheet(meetingUiLocalizations.participantStopVideo, user,
              MemberActionType.hostMuteVideo),
        if (isSelfHostOrCoHost() && !user.isVideoOn)
          buildActionSheet(meetingUiLocalizations.participantStartVideo, user,
              MemberActionType.hostUnMuteVideo),
      ];
    } else {
      return <Widget>[
        if (!arguments.options.noRename && (isSelf || isSelfHostOrCoHost()))
          buildActionSheet(meetingUiLocalizations.participantRename, user,
              MemberActionType.updateNick),
        if (isSelfHostOrCoHost() && user.isRaisingHand)
          buildActionSheet(meetingUiLocalizations.meetingHandsUpDown, user,
              MemberActionType.hostRejectHandsUp),
        if (isSelfHostOrCoHost() && user.isAudioOn && user.isAudioConnected)
          buildActionSheet(meetingUiLocalizations.participantMute, user,
              MemberActionType.hostMuteAudio),
        if (isSelfHostOrCoHost() && !user.isAudioOn && user.isAudioConnected)
          buildActionSheet(meetingUiLocalizations.participantUnmute, user,
              MemberActionType.hostUnMuteAudio),
        if (isSelfHostOrCoHost() && user.isVideoOn)
          buildActionSheet(meetingUiLocalizations.participantStopVideo, user,
              MemberActionType.hostMuteVideo),
        if (isSelfHostOrCoHost() && !user.isVideoOn)
          buildActionSheet(meetingUiLocalizations.participantStartVideo, user,
              MemberActionType.hostUnMuteVideo),
        if (isSelfHostOrCoHost() &&
            (!user.isVideoOn || !user.isAudioOn) &&
            user.isAudioConnected)
          buildActionSheet(
              meetingUiLocalizations.participantTurnOnAudioAndVideo,
              user,
              MemberActionType.hostUnmuteAudioAndVideo),
        if (isSelfHostOrCoHost() &&
            user.isVideoOn &&
            user.isAudioOn &&
            user.isAudioConnected)
          buildActionSheet(
              meetingUiLocalizations.participantTurnOffAudioAndVideo,
              user,
              MemberActionType.hostMuteAudioAndVideo),
        if (!isSelf &&
            (isSelfHostOrCoHost() ||
                roomContext.chatPermission == NEChatPermission.freeChat ||
                (roomContext.chatPermission != NEChatPermission.noChat &&
                    roomContext.isHostOrCoHost(user.uuid))))
          buildActionSheet(meetingUiLocalizations.chatPrivate, user,
              MemberActionType.chatPrivate),
        if (isSelfHostOrCoHost() && !hasScreenSharing && !isPinned)
          buildActionSheet(
              meetingUiLocalizations.participantAssignActiveSpeaker,
              user,
              MemberActionType.setFocusVideo),
        if (isSelfHostOrCoHost() && !hasScreenSharing && isPinned)
          buildActionSheet(
              meetingUiLocalizations.participantUnassignActiveSpeaker,
              user,
              MemberActionType.cancelFocusVideo),
        if (user.isVideoOn &&
            lockedUser != user.uuid &&
            !hasScreenSharing &&
            !hasWhiteboardSharing &&
            roomContext.getFocusUuid() == null)
          buildActionSheet(meetingUiLocalizations.meetingPinView, user,
              MemberActionType.lockVideo),
        if (lockedUser == user.uuid)
          buildActionSheet(meetingUiLocalizations.meetingUnpinView, user,
              MemberActionType.unlockVideo),
        if (isSelfHost && !isSelf && !isUserCoHost)
          buildActionSheet(meetingUiLocalizations.participantAssignCoHost, user,
              MemberActionType.makeCoHost),
        if (isSelfHost && !isSelf && isUserCoHost)
          buildActionSheet(meetingUiLocalizations.participantUnassignCoHost,
              user, MemberActionType.cancelCoHost),
        if (isSelfHost && !isSelf)
          buildActionSheet(meetingUiLocalizations.participantTransferHost, user,
              MemberActionType.changeHost),
        if (isUserHost && roomContext.canReclaimHost)
          buildActionSheet(meetingUiLocalizations.meetingReclaimHost, user,
              MemberActionType.reclaimHost),
        if (isSelfHostOrCoHost() && user.isSharingScreen && !isSelf)
          buildActionSheet(meetingUiLocalizations.screenShareStop, user,
              MemberActionType.hostStopScreenShare),
        if (isSelfHostOrCoHost() && isCurrentSharingWhiteboard)
          buildActionSheet(meetingUiLocalizations.whiteBoardClose, user,
              MemberActionType.hostStopWhiteBoardShare),
        if (!isSelf && isSelfSharingWhiteboard && hasInteract)
          buildActionSheet(
              meetingUiLocalizations.participantUndoWhiteBoardInteract,
              user,
              MemberActionType.undoMemberWhiteboardInteraction),
        if (!isSelf && isSelfSharingWhiteboard && !hasInteract)
          buildActionSheet(meetingUiLocalizations.participantWhiteBoardInteract,
              user, MemberActionType.awardedMemberWhiteboardInteraction),
        if ((isSelfHost || roomContext.isMySelfCoHost()) &&
            !isSelf &&
            !isUserHost &&
            !isUserCoHost &&
            waitingRoomManager.waitingRoomEnabledOnEntryListenable.value)
          buildActionSheet(meetingUiLocalizations.participantPutInWaitingRoom,
              user, MemberActionType.putInWaitingRoom),
        if (isSelfHost && !isSelf)
          buildActionSheet(meetingUiLocalizations.participantRemove, user,
              MemberActionType.removeMember),
        if (roomContext.isMySelfCoHost() && !isSelf && !isUserHost)
          buildActionSheet(meetingUiLocalizations.participantRemove, user,
              MemberActionType.removeMember),
      ];
    }
  }

  void handleInMeetingMemberItemClick(NERoomMember user) {
    final actions = getInMeetingUserActions(context, user);
    if (actions.isEmpty) return;
    DialogUtils.showChildNavigatorPopup<_ActionData>(
      context,
      (context) {
        return StreamBuilder(
          stream: arguments.roomInfoUpdatedEventStream,
          builder: (context, _) {
            final actions = getInMeetingUserActions(context, user);
            final child = CupertinoActionSheet(
              title: Text(
                '${user.name}',
                style: TextStyle(color: _UIColors.grey_8F8F8F, fontSize: 13),
              ),
              actions: actions,
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: buildPopupText(meetingUiLocalizations.globalCancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
            return AutoPopScope(
              child: child,
              listenable: ValueNotifier(actions.isEmpty),
            );
          },
        );
      },
    ).then<void>((_ActionData? value) {
      if (value != null && value.action.index != -1) {
        handleAction(value.action, value.user);
      }
    });
  }

  void handleAction(MemberActionType action, NERoomMember user) {
    switch (action) {
      case MemberActionType.hostMuteAudio:
        muteMemberAudio(user, true);
        break;
      case MemberActionType.hostUnMuteAudio:
        muteMemberAudio(user, false);
        break;
      case MemberActionType.hostMuteVideo:
        muteMemberVideo(user, true);
        break;
      case MemberActionType.hostUnMuteVideo:
        muteMemberVideo(user, false);
        break;
      case MemberActionType.setFocusVideo:
        setFocusVideo(user, true);
        break;
      case MemberActionType.cancelFocusVideo:
        setFocusVideo(user, false);
        break;
      case MemberActionType.lockVideo:
        context.read<MeetingUIState>().lockUserVideo(user.uuid);
        showToast(meetingUiLocalizations.meetingPinViewTip(
            meetingUiLocalizations.meetingBottomRightCorner));
        break;
      case MemberActionType.unlockVideo:
        context.read<MeetingUIState>().lockUserVideo(null);
        showToast(meetingUiLocalizations.meetingUnpinViewTip);
        break;
      case MemberActionType.changeHost:
        changeHost(user);
        break;
      case MemberActionType.reclaimHost:
        reclaimHost(user);
        break;
      case MemberActionType.removeMember:
        removeMember(user);
        break;
      case MemberActionType.hostRejectHandsUp:
        hostRejectHandsUp(user);
        break;
      case MemberActionType.awardedMemberWhiteboardInteraction:
        _awardedWhiteboardInteraction(user);
        break;
      case MemberActionType.undoMemberWhiteboardInteraction:
        _undoWhiteboardInteraction(user);
        break;
      case MemberActionType.hostStopScreenShare:
        _hostStopScreenShare(user);
        break;
      case MemberActionType.hostStopWhiteBoardShare:
        _hostStopWhiteBoard(user);
        break;
      case MemberActionType.updateNick:
        _rename(user);
        break;
      case MemberActionType.hostMuteAudioAndVideo:
        muteMemberAudioAndVideo(user, true);
        break;
      case MemberActionType.hostUnmuteAudioAndVideo:
        muteMemberAudioAndVideo(user, false);
        break;
      case MemberActionType.makeCoHost:
        roomContext.makeCoHost(user.uuid).then((result) {
          commonLogger.i('makeCoHost result: $result');
          if (result.isSuccess()) {
            final member = roomContext.getMember(user.uuid);
            if (member != null) {
              showToast(
                '${member.name}${meetingUiLocalizations.participantUserHasBeenAssignCoHostRole}',
              );
            }
          } else if (result.code == NEErrorCode.overRoleLimitCount) {
            /// 达到分配角色的上限
            showToast(meetingUiLocalizations.participantOverRoleLimitCount);
          }
        });
        break;
      case MemberActionType.cancelCoHost:
        roomContext.cancelCoHost(user.uuid).then((result) {
          commonLogger.i('cancelCoHost result: $result');
          if (result.isSuccess()) {
            final member = roomContext.getMember(user.uuid);
            if (member != null) {
              showToast(
                  '${member.name}${meetingUiLocalizations.participantUserHasBeenRevokeCoHostRole}');
            }
          }
        });
        break;
      case MemberActionType.putInWaitingRoom:
        roomContext.waitingRoomController
            .putInWaitingRoom(user.uuid)
            .then((result) {
          if (!mounted) return;
          if (!result.isSuccess()) {
            showToast(
              result.msg ?? meetingUiLocalizations.globalOperationFail,
            );
          }
        });
        break;
      case MemberActionType.chatPrivate:
        break;
    }
    onMemberItemClick?.call(action, user);
    setState(() {});
  }

  Future<void> _hostStopWhiteBoard(NERoomMember member) async {
    final value = await DialogUtils.showStopSharingDialog(context);
    if (value != true) return;
    var result =
        await whiteboardController.stopMemberWhiteboardShare(member.uuid);
    if (!result.isSuccess() && mounted) {
      showToast(result.msg ?? meetingUiLocalizations.whiteBoardShareStopFail);
    }
  }

  Future<void> _hostStopScreenShare(NERoomMember user) async {
    final value = await DialogUtils.showStopSharingDialog(context);
    if (value != true) return;
    await lifecycleExecute(roomContext.rtcController
        .stopMemberScreenShare(user.uuid)
        // .stopParticipantScreenShare(user.uuid)
        .then((NEResult? result) {
      if (!mounted || result == null) return;
      if (!result.isSuccess()) {
        showToast(result.msg ?? meetingUiLocalizations.screenShareStopFail);
      }
    }));
  }

  Future<void> _awardedWhiteboardInteraction(NERoomMember user) async {
    var result = await whiteboardController.grantPermission(user.uuid);
    if (!result.isSuccess() && mounted) {
      showToast(
        result.msg ?? meetingUiLocalizations.participantWhiteBoardInteractFail,
      );
    }
  }

  Future<void> _undoWhiteboardInteraction(NERoomMember user) async {
    var result = await whiteboardController.revokePermission(user.uuid);
    if (!result.isSuccess() && mounted) {
      showToast(
        result.msg ??
            meetingUiLocalizations.participantUndoWhiteBoardInteractFail,
      );
    }
  }

  void hostRejectHandsUp(NERoomMember user) {
    trackPeriodicEvent(TrackEventName.handsUpDown,
        extra: {'value': 0, 'member_uid': user.uuid, 'meeting_num': roomId});
    lifecycleExecute(roomContext.lowerUserHand(user.uuid))
        .then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        showToast(
          result.msg ?? meetingUiLocalizations.participantFailedToLowerHand,
        );
      }
    });
  }

  Future<void> removeMember(NERoomMember user) async {
    trackPeriodicEvent(TrackEventName.removeMember,
        extra: {'member_uid': user.uuid, 'meeting_num': roomId});
    if (roomContext.isMySelf(user.uuid)) {
      showToast(
        meetingUiLocalizations.participantCannotRemoveSelf,
      );
      return;
    }

    final result = await showConfirmDialogWithCheckbox(
      title: meetingUiLocalizations.participantRemoveConfirm + '${user.name}?',
      checkboxMessage: roomContext.isRoomBlackListEnabled
          ? meetingUiLocalizations.meetingNotAllowedToRejoin
          : null,
      initialChecked: false,
      cancelLabel: meetingUiLocalizations.globalCancel,
      okLabel: meetingUiLocalizations.globalSure,
      contentWrapperBuilder: (child) {
        return AutoPopScope(
          listenable: arguments.isMySelfManagerListenable,
          onWillAutoPop: (_) {
            return !arguments.isMySelfManagerListenable.value;
          },
          child: child,
        );
      },
    );
    if (!mounted || result == null) return;
    removeMember2Server(user, result.checked);
  }

  void removeMember2Server(NERoomMember user, bool toBlacklist) {
    lifecycleExecute(roomContext.kickMemberOut(user.uuid, toBlacklist))
        .then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        showToast(
          result.msg ?? meetingUiLocalizations.participantFailedToRemove,
        );
      }
    });
  }

  void muteMemberAudio(NERoomMember user, bool mute) async {
    trackPeriodicEvent(TrackEventName.switchAudioMember, extra: {
      'value': mute ? 0 : 1,
      'member_uid': user.uuid,
      'meeting_num': roomId
    });
    if (user.uuid == roomContext.myUuid) {
      mute
          ? rtcController.muteMyAudio()
          : rtcController.unmuteMyAudioWithCheckPermission(
              context, arguments.meetingTitle);
      return;
    }
    var future = mute
        ? roomContext.rtcController.muteMemberAudio(user.uuid)
        : roomContext.rtcController.inviteParticipantTurnOnAudio(user.uuid);
    lifecycleExecute(future).then((NEResult? result) {
      if (result != null && mounted && !result.isSuccess()) {
        showToast(
          result.msg ??
              (mute
                  ? meetingUiLocalizations.participantMuteAudioFail
                  : meetingUiLocalizations.participantUnMuteAudioFail),
        );
      }
    });
  }

  void muteMemberVideo(NERoomMember user, bool mute) async {
    trackPeriodicEvent(TrackEventName.switchCameraMember, extra: {
      'value': mute ? 0 : 1,
      'member_uid': user.uuid,
      'meeting_num': roomId
    });
    if (user.uuid == roomContext.myUuid) {
      mute
          ? rtcController.muteMyVideo()
          : rtcController.unmuteMyVideoWithCheckPermission(
              context, arguments.meetingTitle);
      return;
    }
    final result = mute
        ? roomContext.rtcController.muteMemberVideo(user.uuid)
        : roomContext.rtcController.inviteParticipantTurnOnVideo(user.uuid);
    lifecycleExecute(result).then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        showToast(
          result.msg ??
              (mute
                  ? meetingUiLocalizations.participantMuteVideoFail
                  : meetingUiLocalizations.participantUnMuteVideoFail),
        );
      }
    });
  }

  void muteMemberAudioAndVideo(NERoomMember user, bool mute) async {
    trackPeriodicEvent(TrackEventName.muteAudioAndVideo, extra: {
      'value': mute ? 0 : 1,
      'member_uid': user.uuid,
      'meeting_num': roomId
    });
    if (user.uuid == roomContext.myUuid) {
      mute
          ? rtcController.muteMyAudio()
          : rtcController.unmuteMyAudioWithCheckPermission(
              context, arguments.meetingTitle);
      mute
          ? rtcController.muteMyVideo()
          : rtcController.unmuteMyVideoWithCheckPermission(
              context, arguments.meetingTitle);
      return;
    }
    if (mute) {
      muteMemberAudio(user, true);
      muteMemberVideo(user, true);
    } else {
      final result =
          rtcController.inviteParticipantTurnOnAudioAndVideo(user.uuid);
      lifecycleExecute(result).then((NEResult? result) {
        if (mounted && result != null && !result.isSuccess()) {
          showToast(
            result.msg ??
                '${(mute ? meetingUiLocalizations.participantTurnOffAudioAndVideo : meetingUiLocalizations.participantTurnOnAudioAndVideo)}${meetingUiLocalizations.globalFail}',
          );
        }
      });
    }
  }

  void setFocusVideo(NERoomMember user, bool focus) {
    trackPeriodicEvent(TrackEventName.focusMember, extra: {
      'value': focus ? 1 : 0,
      'member_uid': user.uuid,
      'meeting_num': roomId
    });
    lifecycleExecute(rtcController.pinVideo(user.uuid, focus))
        .then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        showToast(
          result.msg ??
              (focus
                  ? meetingUiLocalizations
                      .participantFailedToAssignActiveSpeaker
                  : meetingUiLocalizations
                      .participantFailedToUnassignActiveSpeaker),
        );
      }
    });
  }

  void changeHost(NERoomMember user) {
    trackPeriodicEvent(TrackEventName.changeHost,
        extra: {'member_uid': user.uuid, 'meeting_num': roomId});
    showDialog(
      context: context,
      builder: (_) {
        return NEMeetingUIKitLocalizationsScope(
          builder: (BuildContext context, localizations, _) {
            return CupertinoAlertDialog(
              title: Text(localizations.participantTransferHost),
              content:
                  Text(localizations.participantTransferHostConfirm(user.name)),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(localizations.globalNo),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text(localizations.globalYes),
                  onPressed: () {
                    Navigator.of(context).pop();
                    changeHost2Server(user);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void reclaimHost(NERoomMember? user) {
    if (user == null) return;
    roomContext.reclaimHost(user.uuid).onFailure((code, msg) {
      showToast(msg ?? meetingUiLocalizations.globalOperationFail);
    }).ignore();
  }

  void changeHost2Server(NERoomMember user) {
    if (roomContext.getMember(user.uuid) == null) {
      /// 执行移交主持人时，check 用户是否还在会议中，不在的话直接提示 移交主持人失败
      showToast(meetingUiLocalizations.participantFailedToTransferHost);
      return;
    }
    lifecycleExecute(roomContext.handOverHost(user.uuid))
        .then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        showToast(
          result.msg ?? meetingUiLocalizations.participantFailedToTransferHost,
        );
      }
    });
  }

  Widget _memberItemNick(NERoomMember user) {
    var subtitle = <String>[];
    if (roomContext.isHost(user.uuid)) {
      subtitle.add(meetingUiLocalizations.participantHost);
    }
    if (roomContext.isCoHost(user.uuid)) {
      subtitle.add(meetingUiLocalizations.participantCoHost);
    }
    if (roomContext.isGuest(user.uuid)) {
      subtitle.add(meetingUiLocalizations.meetingGuest);
    }
    if (roomContext.isMySelf(user.uuid)) {
      subtitle.add(meetingUiLocalizations.participantMe);
    }
    if (user.clientType == NEClientType.sip) {
      subtitle.add(meetingUiLocalizations.meetingSip);
    }
    if (meetingUIState.interpretationController.isUserInterpreter(user.uuid)) {
      subtitle.add(meetingUiLocalizations.interpInterpreter);
    }
    if (arguments.options.showMemberTag &&
        user.tag != null &&
        user.tag!.isNotEmpty) {
      subtitle.add(user.tag!);
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
            '(${subtitle.join('，')})',
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

  void _rename(NERoomMember user) async {
    final newName = await showRenameDialog(user.name);
    if (!mounted || newName == null || newName == user.name) return;
    final future = user.uuid == roomContext.myUuid
        ? roomContext.changeMyName(newName)
        : roomContext.changeMemberName(user.uuid, newName);
    lifecycleExecute(future).then((NEResult? result) {
      if (mounted && result != null) {
        if (result.isSuccess()) {
          showToast(
            meetingUiLocalizations.participantRenameSuccess,
          );
        } else {
          showToast(
            result.msg ?? meetingUiLocalizations.participantRenameFail,
          );
        }
      }
    });
  }
}

class _ActionData {
  final MemberActionType action;
  final NERoomMember user;

  _ActionData(this.action, this.user);
}

enum MemberActionType {
  hostMuteAudio,
  hostUnMuteAudio,
  hostMuteVideo,
  hostUnMuteVideo,
  setFocusVideo,
  cancelFocusVideo,
  lockVideo,
  unlockVideo,
  changeHost,
  reclaimHost,
  removeMember,
  hostRejectHandsUp,
  awardedMemberWhiteboardInteraction,
  undoMemberWhiteboardInteraction,
  hostStopScreenShare,
  hostStopWhiteBoardShare,
  updateNick,
  hostMuteAudioAndVideo,
  hostUnmuteAudioAndVideo,
  makeCoHost,
  cancelCoHost,
  putInWaitingRoom,
  chatPrivate,
}

class WaitingRoomMemberList extends StatefulWidget {
  final WaitingRoomManager waitingRoomManager;
  final List<NEWaitingRoomMember> userList;
  final void Function(dynamic actionType, NEBaseRoomMember user)?
      onMemberItemClick;
  final ValueListenable<bool> isMySelfManagerListenable;

  const WaitingRoomMemberList(this.waitingRoomManager, this.userList,
      this.isMySelfManagerListenable, this.onMemberItemClick,
      {super.key});

  @override
  State<WaitingRoomMemberList> createState() => _WaitingRoomMemberListState();
}

class _WaitingRoomMemberListState extends State<WaitingRoomMemberList>
    with MeetingKitLocalizationsMixin {
  StreamController? oneMinuteTick;
  StreamSubscription? oneMinuteTickSubscription;
  final userAutoPopListenable = <String, ValueNotifier<bool>>{};
  bool isShowMaxMembersTipDialog = false;

  @override
  void initState() {
    super.initState();
    restartOneMinuteTick();
  }

  @override
  void didUpdateWidget(WaitingRoomMemberList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userList != widget.userList) {
      restartOneMinuteTick();

      userAutoPopListenable.removeWhere((user, onPop) {
        onPop.value = widget.userList.every((element) => element.uuid != user);
        return onPop.value;
      });
    }
  }

  @override
  void dispose() {
    oneMinuteTickSubscription?.cancel();
    oneMinuteTick?.close();
    userAutoPopListenable
      ..forEach((user, onPop) {
        onPop.value = true;
      })
      ..clear();
    super.dispose();
  }

  void restartOneMinuteTick() {
    oneMinuteTickSubscription?.cancel();
    oneMinuteTick?.close();
    oneMinuteTick = createOneMinuteTickStreamController();
    oneMinuteTickSubscription = oneMinuteTick!.stream.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userList = widget.userList;
    final list = ListView.separated(
      cacheExtent: 48,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: userList.length > 0 ? userList.length + 1 : 0,
      itemBuilder: (context, index) {
        if (index == userList.length) {
          return SizedBox.shrink();
        }
        return buildMemberItem(userList[index]);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(height: 1, color: _UIColors.globalBg);
      },
    );
    return NotificationListener<ScrollNotification>(
      child: Column(
        children: <Widget>[
          Expanded(child: list),
          Container(height: 1, color: _UIColors.globalBg),
          buildHostActions(),
        ],
      ),
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          if (notification.metrics.pixels ==
              notification.metrics.maxScrollExtent) {
            widget.waitingRoomManager.tryLoadMoreUser();
          }
        }
        return false;
      },
    );
  }

  Widget buildHostActions() {
    return ValueListenableBuilder(
        valueListenable: widget.isMySelfManagerListenable,
        builder: (context, isMySelfManager, child) {
          return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: MeetingTextButton.fill(
                      text: meetingUiLocalizations.waitingRoomAdmitAll,
                      onPressed: admitAllMembers,
                    ),
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: MeetingTextButton.outlined(
                      text: meetingUiLocalizations.waitingRoomRemoveAll,
                      onPressed: expelAllMembers,
                    ),
                  ),
                ],
              ));
        });
  }

  Widget buildMemberItem(NEWaitingRoomMember user) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => handleWaitingRoomMemberItemClick(user),
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
              child: buildUserInfo(user),
            ),
            if (user.status == NEWaitingRoomConstants.STATUS_WAITING) ...[
              _buildWaitingTextButton(meetingUiLocalizations.participantAdmit,
                  () {
                admitMember(user.uuid);
              }),
              SizedBox(
                width: 16,
              ),
              _buildWaitingTextButton(meetingUiLocalizations.participantRemove,
                  () {
                expelMember(user);
              }),
            ],
            if (user.status == NEWaitingRoomConstants.STATUS_ADMITTED)
              Text(
                meetingUiLocalizations.meetingJoinTips,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: _UIColors.color_999999,
                  decoration: TextDecoration.none,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildUserInfo(NEWaitingRoomMember user) {
    final waitingTime = _getWaitingTime(user.joinTime);
    final name = Text(
      user.name,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: _UIColors.color_333333,
        decoration: TextDecoration.none,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    return waitingTime != null
        ? Column(
            children: [
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: _UIColors.color_333333,
                  decoration: TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${meetingUiLocalizations.participantWaitingTimePrefix}$waitingTime',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: _UIColors.color_999999,
                  decoration: TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
          )
        : name;
  }

  String? _getWaitingTime(int joinTime) {
    if (joinTime == 0) return null;
    final waitingTime = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(joinTime));
    if (waitingTime.isNegative) return null;
    final days = waitingTime.inDays;
    final hours = waitingTime.inHours % 24;
    final minutes = waitingTime.inMinutes % 60;
    final buf = StringBuffer();
    if (days > 0) {
      buf.write(days);
      buf.write(meetingUiLocalizations.globalDays);
    }
    if (hours > 0) {
      buf.write(hours);
      buf.write(meetingUiLocalizations.globalHours);
    }
    if (minutes > 0) {
      buf.write(minutes);
      buf.write(meetingUiLocalizations.globalMinutes);
    }
    return buf.isNotEmpty ? buf.toString() : null;
  }

  Widget _buildWaitingTextButton(String text, VoidCallback onPressed) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: _UIColors.greyCCCCCC, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: _UIColors.black_333333,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none),
        ),
      ),
      onTap: onPressed,
    );
  }

  void handleWaitingRoomMemberItemClick(NEWaitingRoomMember user) {
    if (user.status == NEWaitingRoomConstants.STATUS_ADMITTED) {
      return;
    }
    final actions = [
      buildActionSheet(meetingUiLocalizations.participantAdmit, user,
          WaitingRoomMemberActionType.admit),
      buildActionSheet(meetingUiLocalizations.waitingRoomAutoAdmit, user,
          WaitingRoomMemberActionType.autoAdmit),
      buildActionSheet(meetingUiLocalizations.participantRemove, user,
          WaitingRoomMemberActionType.expel),
      buildActionSheet(meetingUiLocalizations.participantRename, user,
          WaitingRoomMemberActionType.rename),
      buildActionSheet(meetingUiLocalizations.chatPrivate, user,
          WaitingRoomMemberActionType.chatPrivate),
    ];
    DialogUtils.showChildNavigatorPopup<WaitingRoomMemberAction>(
      context,
      (context) => AutoPopScope(
        listenable: userAutoPopListenable.putIfAbsent(
            user.uuid, () => ValueNotifier(false)),
        child: CupertinoActionSheet(
          title: Text(
            '${user.name}',
            style: TextStyle(color: _UIColors.grey_8F8F8F, fontSize: 13),
          ),
          actions: actions,
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: buildPopupText(meetingUiLocalizations.globalCancel),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    ).then<void>((WaitingRoomMemberAction? value) {
      if (value != null) {
        handleMemberAction(value);
      }
    });
  }

  void handleMemberAction(WaitingRoomMemberAction action) {
    switch (action.action) {
      case WaitingRoomMemberActionType.expel:
        expelMember(action.member);
        break;
      case WaitingRoomMemberActionType.admit:
        admitMember(action.member.uuid);
        break;
      case WaitingRoomMemberActionType.rename:
        renameMember(action.member.uuid, action.member.name);
        break;
      case WaitingRoomMemberActionType.autoAdmit:
        admitMember(action.member.uuid, autoAdmit: true);
        break;
      case WaitingRoomMemberActionType.chatPrivate:
        break;
    }
    widget.onMemberItemClick?.call(action.action, action.member);
  }

  void admitMember(String uuid, {bool autoAdmit = false}) {
    if (checkMaxMember(false) && !isShowMaxMembersTipDialog) {
      isShowMaxMembersTipDialog = !isShowMaxMembersTipDialog;
      DialogUtils.showMaxMembersTipDialog(
        context,
        title: NEMeetingUIKitLocalizations.of(context)!.meetingMemberMaxTip,
        content: NEMeetingUIKitLocalizations.of(context)!
            .participantUpperLimitTipAdmitOtherTip,
        cancelTitle: NEMeetingUIKitLocalizations.of(context)!.globalIKnow,
        onCancel: () => isShowMaxMembersTipDialog = false,
      ).whenComplete(() => isShowMaxMembersTipDialog = false);
    } else {
      widget.waitingRoomManager.admitMember(uuid, autoAdmit: autoAdmit);
    }
  }

  void admitAllMembers() async {
    if (checkMaxMember(true) && !isShowMaxMembersTipDialog) {
      isShowMaxMembersTipDialog = !isShowMaxMembersTipDialog;
      DialogUtils.showMaxMembersTipDialog(
        context,
        onCancel: () => isShowMaxMembersTipDialog = false,
        title: NEMeetingUIKitLocalizations.of(context)!.meetingMemberMaxTip,
        content: NEMeetingUIKitLocalizations.of(context)!
            .participantUpperLimitTipAdmitOtherTip,
        cancelTitle: NEMeetingUIKitLocalizations.of(context)!.globalIKnow,
      ).whenComplete(() => isShowMaxMembersTipDialog = false);
    } else {
      final result = await showConfirmDialog(
        title: meetingUiLocalizations.waitingRoomAdmitMember,
        message: meetingUiLocalizations.waitingRoomAdmitAllMembersTip,
        cancelLabel: meetingUiLocalizations.globalCancel,
        okLabel: meetingUiLocalizations.waitingRoomAdmitAll,
        contentWrapperBuilder: (child) {
          return AutoPopScope(
            listenable: widget.isMySelfManagerListenable,
            onWillAutoPop: (_) {
              return !widget.isMySelfManagerListenable.value;
            },
            child: child,
          );
        },
      );
      if (!mounted || result != true) return;
      widget.waitingRoomManager.admitAllMembers();
    }
  }

  void expelAllMembers() async {
    final result = await showConfirmDialogWithCheckbox(
      title: meetingUiLocalizations.waitingRoomExpelWaitingMember,
      message: meetingUiLocalizations.waitingRoomRemoveAllMemberTip,
      checkboxMessage:
          meetingUiLocalizations.participantDisallowMemberRejoinMeeting,
      cancelLabel: meetingUiLocalizations.globalCancel,
      okLabel: meetingUiLocalizations.waitingRoomRemoveAll,
      contentWrapperBuilder: (child) {
        return AutoPopScope(
          listenable: widget.isMySelfManagerListenable,
          onWillAutoPop: (_) {
            return !widget.isMySelfManagerListenable.value;
          },
          child: child,
        );
      },
    );
    if (!mounted || result == null) return;
    widget.waitingRoomManager.expelAllMembers(disallowRejoin: result.checked);
  }

  void expelMember(NEWaitingRoomMember user) async {
    final isRoomBlackListEnabled =
        widget.waitingRoomManager.roomContext.isRoomBlackListEnabled;
    final result = await showConfirmDialogWithCheckbox(
      title: meetingUiLocalizations.waitingRoomExpelWaitingMember,
      message:
          meetingUiLocalizations.participantRemoveConfirm + '${user.name}?',
      checkboxMessage: isRoomBlackListEnabled
          ? meetingUiLocalizations.participantDisallowMemberRejoinMeeting
          : null,
      cancelLabel: meetingUiLocalizations.globalCancel,
      okLabel: meetingUiLocalizations.participantRemove,
      contentWrapperBuilder: (child) {
        return AutoPopScope(
          listenable: userAutoPopListenable.putIfAbsent(
              user.uuid, () => ValueNotifier(false)),
          child: child,
        );
      },
    );
    if (!mounted || result == null) return;
    widget.waitingRoomManager
        .expelMember(user.uuid, disallowRejoin: result.checked);
  }

  void renameMember(String uuid, String name) {
    showRenameDialog(
      name,
      contentWrapperBuilder: (child) {
        return AutoPopScope(
          listenable: userAutoPopListenable.putIfAbsent(
              uuid, () => ValueNotifier(false)),
          child: child,
        );
      },
    ).then((newName) {
      if (!mounted) return;
      if (newName != null && newName != name) {
        widget.waitingRoomManager.waitingRoomController
            .changeMemberName(uuid, newName.trimRight());
      }
    });
  }

  Widget buildPopupText(String text) {
    return Text(text,
        style: TextStyle(color: _UIColors.color_007AFF, fontSize: 20));
  }

  Widget buildActionSheet(String text, NEWaitingRoomMember user,
      WaitingRoomMemberActionType memberActionType) {
    return CupertinoActionSheetAction(
      child: buildPopupText(text),
      onPressed: () {
        Navigator.pop(context, WaitingRoomMemberAction(user, memberActionType));
      },
    );
  }

  /// 检查是否达到最大人数
  bool checkMaxMember(bool admitAllMembers) {
    NERoomContext? currentRoomContext =
        NEMeetingUIKit.instance.getCurrentRoomContext();
    int waitingRoomMemberCount = 0;
    if (admitAllMembers) {
      waitingRoomMemberCount = currentRoomContext?.waitingRoomController
              .getWaitingRoomInfo()
              .memberCount ??
          0;
    } else {
      waitingRoomMemberCount = currentRoomContext!.waitingRoomController
                  .getWaitingRoomInfo()
                  .memberCount >
              0
          ? 1
          : 0;
    }
    return currentRoomContext != null &&
        currentRoomContext
                    .getAllUsers(
                        isIncludeInviteMember: true,
                        isIncludeInviteWaitingJoinMember: false)
                    .length +
                waitingRoomMemberCount >
            currentRoomContext.maxMembers;
  }
}

class WaitingRoomMemberAction {
  final NEWaitingRoomMember member;
  final WaitingRoomMemberActionType action;

  WaitingRoomMemberAction(this.member, this.action);
}

enum WaitingRoomMemberActionType {
  expel,
  admit,
  autoAdmit,
  rename,
  chatPrivate,
}

extension RenameDialogUtils on State {
  Future<String?> showRenameDialog(
    String name, {
    ContentWrapperBuilder? contentWrapperBuilder,
  }) {
    final localizations = NEMeetingUIKitLocalizations.of(context)!;
    return showInputDialog(
      textFieldKey: MeetingUIValueKeys.renameDialogInputKey,
      initialInput: name,
      title: localizations.participantRenameDialogTitle,
      cancelLabel: localizations.globalCancel,
      okLabel: localizations.globalDone,
      hintText: localizations.participantRenameTips,
      inputFormatters: [
        MeetingLengthLimitingTextInputFormatter(20),
      ],
      contentWrapperBuilder: contentWrapperBuilder,
    ).then((result) => result?.value);
  }
}

class InviteMemberList extends StatefulWidget {
  final List<NERoomMember> userList;
  final ValueListenable<bool> isMySelfManagerListenable;
  final NERoomSIPController sipController;
  final NERoomAppInviteController appInviteController;

  const InviteMemberList(this.isMySelfManagerListenable, this.userList,
      this.sipController, this.appInviteController,
      {super.key});

  @override
  State<InviteMemberList> createState() => _InviteMemberListState(
      isMySelfManagerListenable, sipController, appInviteController);
}

class _InviteMemberListState extends State<InviteMemberList>
    with MeetingKitLocalizationsMixin {
  final ValueListenable<bool> isMySelfManagerListenable;
  final NERoomSIPController sipController;
  final NERoomAppInviteController appInviteController;

  _InviteMemberListState(this.isMySelfManagerListenable, this.sipController,
      this.appInviteController);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            cacheExtent: 48,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: widget.userList.length,
            itemBuilder: (context, index) {
              return buildMemberItem(widget.userList[index]);
            },
            separatorBuilder: (BuildContext context, int index) {
              return Container(height: 1, color: _UIColors.globalBg);
            },
          ),
        ),
        Container(height: 1, color: _UIColors.globalBg),
      ],
    );
  }

  /// 成员是否正在邀请中，正在邀请显示取消，已经没在邀请的显示再次呼叫
  bool _isUserInInviting(NERoomMember user) {
    return (user.isInSIPInviting || user.isInAppInviting) &&
        (user.inviteState == NERoomMemberInviteState.calling ||
            user.inviteState == NERoomMemberInviteState.waitingCall);
  }

  Widget buildMemberItem(NERoomMember user) {
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          NEMeetingAvatar.large(
            name: user.name,
            url: user.avatar,
          ),
          SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.name,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: _UIColors.color_333333,
                  decoration: TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                getInviteState(user),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: user.inviteState == NERoomMemberInviteState.calling
                      ? _UIColors.color_26BD71
                      : _UIColors.color_999999,
                  decoration: TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _isUserInInviting(user)
                        ? _UIColors.colorF24957
                        : _UIColors.color_26BD71,
                    width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _isUserInInviting(user)
                    ? meetingUiLocalizations.globalCancel
                    : meetingUiLocalizations.sipCall,
                style: TextStyle(
                    color: _isUserInInviting(user)
                        ? _UIColors.colorF24957
                        : _UIColors.color_26BD71,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none),
              ),
            ),
            onTap: () {
              ConnectivityManager().isConnected().then((value) async {
                if (!value) {
                  ToastUtils.showToast(
                      context,
                      meetingUiLocalizations
                          .networkAbnormalityPleaseCheckYourNetwork,
                      isError: true);
                  return;
                }
                if (_isUserInInviting(user)) {
                  if (user.isInSIPInviting) {
                    sipController.cancelCall(user.uuid);
                  } else if (user.isInAppInviting) {
                    appInviteController.cancelCall(user.uuid);
                  }
                } else {
                  VoidResult voidResult = VoidResult(code: -1);
                  if (user.isInSIPInviting) {
                    voidResult = await sipController.callByUserUuid(user.uuid);
                  } else if (user.isInAppInviting) {
                    voidResult =
                        await appInviteController.callByUserUuid(user.uuid);
                  }
                  switch (voidResult.code) {
                    case 1022:
                      ToastUtils.showToast(context,
                          meetingUiLocalizations.memberCountOutOfRange);
                      break;
                    case 3005:
                      ToastUtils.showToast(
                          context, meetingUiLocalizations.sipCallIsInInviting);
                      break;
                    case 3006:
                      ToastUtils.showToast(
                          context, meetingUiLocalizations.sipCallIsInMeeting);
                      break;
                    case 601011:
                      ToastUtils.showToast(
                          context, meetingUiLocalizations.sipCallIsInBlacklist);
                      break;
                    default:
                      break;
                  }
                }
              });
            },
          ),
          GestureDetector(
            child: Container(
              margin: EdgeInsets.only(left: 12, right: 12),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: _UIColors.greyCCCCCC, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                meetingUiLocalizations.participantRemove,
                style: TextStyle(
                    color: _UIColors.black_333333,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none),
              ),
            ),
            onTap: () {
              ConnectivityManager().isConnected().then((value) {
                if (!value) {
                  ToastUtils.showToast(
                      context,
                      meetingUiLocalizations
                          .networkAbnormalityPleaseCheckYourNetwork,
                      isError: true);
                  return;
                }
                if (user.isInSIPInviting) {
                  sipController.removeCall(user.uuid);
                } else if (user.isInAppInviting) {
                  appInviteController.removeCall(user.uuid);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  String getInviteState(NERoomMember user) {
    switch (user.inviteState) {
      case NERoomMemberInviteState.calling:
        return user.isInSIPInviting
            ? meetingUiLocalizations.sipCallStatusCalling
            : meetingUiLocalizations.callStatusCalling;
      case NERoomMemberInviteState.waitingCall:
        return meetingUiLocalizations.sipCallStatusWaiting;
      case NERoomMemberInviteState.rejected:
        return meetingUiLocalizations.sipCallStatusRejected;
      case NERoomMemberInviteState.noAnswer:
        return meetingUiLocalizations.sipCallStatusUnaccepted;
      case NERoomMemberInviteState.canceled:
        return meetingUiLocalizations.sipCallStatusCanceled;
      case NERoomMemberInviteState.error:
        return meetingUiLocalizations.sipCallStatusError;
      case NERoomMemberInviteState.waitingJoin:
        return meetingUiLocalizations.callStatusWaitingJoin;
      default:
        break;
    }
    return '';
  }
}
