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
  late final NERoomAnnotationController annotationController;
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
    annotationController = roomContext.annotationController;
    waitingRoomManager = arguments.waitingRoomManager;
    roomId = roomContext.roomUuid;
    maxCount = parseMaxCountByContract(roomContext.extraData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _UIColors.globalBg,
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
            return Padding(
              padding: EdgeInsets.only(top: 64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NEMeetingImages.assetImage(NEMeetingImages.iconNoContent,
                      width: 120, height: 120),
                  SizedBox(height: 8),
                  Text(
                    meetingUiLocalizations.participantNotFound,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: _UIColors.color3D3D3D,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            );
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
                arguments.hideAvatar);
          } else if (page.type == _MembersPageType.notYetJoined &&
              isSelfHostOrCoHost()) {
            return SafeArea(
              left: false,
              child: InviteMemberList(
                arguments.isMySelfManagerListenable,
                page.filteredUserList as List<NERoomMember>,
                arguments.roomContext.sipController,
                arguments.roomContext.appInviteController,
                arguments.hideAvatar,
              ),
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
        SizedBox(height: 16),
        Expanded(
            child: SingleChildScrollView(
          child: buildMembers(userList),
        )),
        if (isSelfHostOrCoHost() ||
            (roomContext.canReclaimHost &&
                roomContext.getHostMember() != null)) ...[
          buildDivider(),
          if (isSelfHostOrCoHost()) ...[
            buildMuteAllAudioActions(),
          ] else ...[
            Container(
              color: _UIColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: MeetingTextButton.outlined(
                  text: meetingUiLocalizations.meetingReclaimHost,
                  onPressed: () => reclaimHost(roomContext.getHostMember()),
                ),
              ),
            ),
          ],
        ],
        Container(
          height: MediaQuery.of(context).padding.bottom,
          color: isSelfHostOrCoHost() ||
                  (roomContext.canReclaimHost &&
                      roomContext.getHostMember() != null)
              ? _UIColors.white
              : _UIColors.globalBg,
        ),
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

    return MeetingCard(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      children: [
        if (isSelfHostOrCoHost()) buildHandsUpDownAll(),
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          primary: false,
          cacheExtent: 1,
          itemCount: len,
          itemBuilder: (context, index) {
            return buildMemberItem(userList[index]);
          },
        ),
      ],
    );
  }

  Widget buildHandsUpDownAll() {
    return ValueListenableBuilder<int>(
        valueListenable: arguments.handsUpHelper.handsUpCount,
        builder: (_, count, child) {
          return count > 0
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 38,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(children: <Widget>[
                        NEMeetingImages.assetImage(
                          NEMeetingImages.iconHandsUp,
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('$count',
                              style: TextStyle(
                                  color: _UIColors.color8D90A0,
                                  fontSize: 12,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w400)),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              arguments.handsUpHelper.handsUpDownAll(context),
                          child: Text(
                              NEMeetingUIKitLocalizations.of(context)!
                                  .meetingHandsUpDownAll,
                              style: TextStyle(
                                  color: _UIColors.blue_337eff,
                                  fontSize: 14,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ]),
                      Container(
                        height: 1,
                        color: Colors.transparent,
                      )
                    ],
                  ),
                )
              : SizedBox.shrink();
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
  void showMuteAllVideoActions() {
    BottomSheetUtils.showMeetingBottomDialog(
        buildContext: context,
        isSubpage: true,
        actionText: meetingUiLocalizations.globalCancel,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildMuteAllVideoAction(
                meetingUiLocalizations.participantTurnOffVideos,
                _onMuteAllVideo),
            buildMuteAllVideoAction(
                meetingUiLocalizations.participantTurnOnVideos,
                unMuteAllVideo2Server),
            _buildEmojiResponse(),
          ],
        ));
  }

  Widget _buildEmojiResponse() {
    return ValueListenableBuilder(
        valueListenable: arguments.emojiResponseHelper.isEmojiResponseEnabled,
        builder: (_, enable, child) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context);
              _updateEmojiResponsePermission(!enable);
            },
            child: Container(
                alignment: Alignment.center,
                height: 48,
                child: Text(
                    enable
                        ? meetingUiLocalizations.meetingRejectEmojiResponse
                        : meetingUiLocalizations.meetingAllowEmojiResponse,
                    style: TextStyle(
                      color: _UIColors.color1E1F27,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ))),
          );
        });
  }

  void _updateEmojiResponsePermission(bool enable) {
    doIfNetworkAvailable(() {
      lifecycleExecute(roomContext.updateEmojiRespPermission(enable));
    });
  }

  Widget buildMuteAllVideoAction(String text, VoidCallback? onPressed) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context);
        onPressed?.call();
      },
      child: Container(
          alignment: Alignment.center,
          height: 48,
          child: Text(text,
              style: TextStyle(
                color: _UIColors.color1E1F27,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ))),
    );
  }

  /// 管理会议成员弹窗下的 全体静音相关操作ui
  Widget buildMuteAllAudioActions() {
    return Visibility(
      visible: !arguments.options.noMuteAllAudio,
      child: Container(
        color: _UIColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: MeetingTextButton.outlined(
                text: meetingUiLocalizations.participantMuteAudioAll,
                onPressed: _onMuteAllAudio,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: MeetingTextButton.outlined(
                text: meetingUiLocalizations.participantUnmuteAll,
                onPressed: unMuteAllAudio2Server,
              ),
            ),
            Visibility(
                visible: !arguments.options.noMuteAllVideo,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(width: 8),
                  Container(
                    width: 80,
                    child: MeetingTextButton.outlined(
                      text: meetingUiLocalizations.meetingMore,
                      onPressed: showMuteAllVideoActions,
                    ),
                  ),
                ])),
          ],
        ),
      ),
    );
  }

  void _onMuteAllAudio() async {
    final result = await showConfirmDialogWithCheckbox(
      title: meetingUiLocalizations.participantMuteAudioAllDialogTips,
      initialChecked: roomContext.isUnmuteAudioBySelfEnabled,
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
      initialChecked: roomContext.isUnmuteVideoBySelfEnabled,
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
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: arguments.hideAvatar,
                builder: (context, hideAvatar, child) {
                  return NEMeetingAvatar.large(
                    name: user.name,
                    url: user.avatar,
                    hideImageAvatar: hideAvatar,
                  );
                },
              ),
              SizedBox(width: 12),
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
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: arguments.hideAvatar,
              builder: (context, hideAvatar, child) {
                return NEMeetingAvatar.large(
                  name: user.name,
                  url: user.avatar,
                  hideImageAvatar: hideAvatar,
                );
              },
            ),
            SizedBox(width: 12),
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
              NEMeetingImages.assetImage(
                NEMeetingImages.iconHandsUp,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
            ],
            if (user.clientType == NEClientType.sip) ...[
              Icon(NEMeetingIconFont.icon_sip,
                  color: _UIColors.color_337eff, size: 20),
              const SizedBox(width: 16),
            ],
            if (user.clientType == NEClientType.h323) ...[
              Icon(NEMeetingIconFont.icon_h323,
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
            if (user.isSharingSystemAudio) ...[
              Icon(NEMeetingIconFont.icon_share_system_audio,
                  color: _UIColors.color53576A, size: 20),
              const SizedBox(width: 16),
            ],
            if (roomContext.getFocusUuid() == user.uuid) ...[
              Icon(NEMeetingIconFont.icon_focus,
                  color: _UIColors.color53576A, size: 20),
              const SizedBox(width: 16),
            ],
            Icon(
                !user.isVideoOn
                    ? NEMeetingIconFont.icon_yx_tv_video_offx
                    : NEMeetingIconFont.icon_yx_tv_video_onx,
                color: !user.isVideoOn ? Colors.red : _UIColors.color53576A,
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
        style: TextStyle(
            color: _UIColors.color1E1F27,
            fontSize: 16,
            fontWeight: FontWeight.w500));
  }

  Widget buildActionSheet(NERoomMember user, NEMeetingMenuItem menuActionItem) {
    String text = getMenuItemTitle(menuActionItem, user);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          Navigator.pop(context, _ActionData(menuActionItem.itemId, user)),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        child: buildPopupText(text),
      ),
    );
  }

  List<Widget> getInMeetingUserActions(
      BuildContext buildContext, NERoomMember user) {
    if (roomContext.getMember(user.uuid) == null) {
      return [];
    }
    return arguments.memberActionMenuItems
        .where((item) => shouldShowAction(item, user))
        .map((item) => buildActionSheet(user, item))
        .toList();
  }

  void handleInMeetingMemberItemClick(NERoomMember user) async {
    final actions = getInMeetingUserActions(context, user);
    if (actions.isEmpty) return;
    final controller = BottomSheetUtils.showMeetingBottomDialog<_ActionData>(
        buildContext: context,
        title: '${user.name}',
        isSubpage: true,
        child: StreamBuilder(
          stream: arguments.roomInfoUpdatedEventStream,
          builder: (context, _) {
            final actions = getInMeetingUserActions(context, user);
            return AutoPopScope(
              child: Column(mainAxisSize: MainAxisSize.min, children: actions),
              listenable: ValueNotifier(actions.isEmpty),
            );
          },
        ));
    controller.result.then<void>((_ActionData? value) {
      if (value != null && value.actionId != -1) {
        handleAction(value.actionId, value.user);
      }
    });
  }

  void handleAction(int action, NERoomMember user) {
    final isSelf = roomContext.isMySelf(user.uuid);
    final isUserCoHost = roomContext.isCoHost(user.uuid);
    final isUserHost = roomContext.isHost(user.uuid);
    final isUserOwner = roomContext.isOwner(user.uuid);
    final isPinned = roomContext.getFocusUuid() == user.uuid;
    final lockedUser = context.read<MeetingUIState>().lockedUser;
    final hasInteract =
        whiteboardController.isDrawWhiteboardEnabledWithUserId(user.uuid);
    switch (action) {
      case NEActionMenuIDs.audio:
        muteMemberAudio(user, user.isAudioOn);
        break;
      case NEActionMenuIDs.video:
        muteMemberVideo(user, user.isVideoOn);
        break;
      case NEActionMenuIDs.focusVideo:
        setFocusVideo(user, !isPinned);
        break;
      case NEActionMenuIDs.lockVideo:
        if (lockedUser != user.uuid) {
          context.read<MeetingUIState>().lockUserVideo(user.uuid);
          showToast(meetingUiLocalizations.meetingPinViewTip(
              meetingUiLocalizations.meetingBottomRightCorner));
        } else {
          context.read<MeetingUIState>().lockUserVideo(null);
          showToast(meetingUiLocalizations.meetingUnpinViewTip);
        }
        break;
      case NEActionMenuIDs.changeHost:
        changeHost(user);
        break;
      case NEActionMenuIDs.reclaimHost:
        reclaimHost(user);
        break;
      case NEActionMenuIDs.removeMember:
        if (isSelfHostOrCoHost() &&
            !isSelf &&
            !isUserCoHost &&
            !isUserHost &&
            !isUserOwner) {
          removeMember(user);
        }
        break;
      case NEActionMenuIDs.rejectHandsUp:
        hostRejectHandsUp(user);
        break;
      case NEActionMenuIDs.whiteboardInteraction:
        if (!hasInteract) {
          _awardedWhiteboardInteraction(user);
        } else {
          _undoWhiteboardInteraction(user);
        }
        break;
      case NEActionMenuIDs.screenShare:
        _hostStopScreenShare(user);
        break;
      case NEActionMenuIDs.whiteBoardShare:
        _hostStopWhiteBoard(user);
        break;
      case NEActionMenuIDs.updateNick:
        _rename(user);
        break;
      case NEActionMenuIDs.audioAndVideo:
        if (user.isVideoOn && user.isAudioOn) {
          muteMemberAudioAndVideo(user, true);
        } else {
          muteMemberAudioAndVideo(user, false);
        }
        break;
      case NEActionMenuIDs.coHost:
        if (isUserCoHost) {
          roomContext.cancelCoHost(user.uuid).then((result) {
            commonLogger.i('cancelCoHost result: $result');
            if (result.isSuccess()) {
              final member = roomContext.getMember(user.uuid);
              if (member != null) {
                // 这个人在共享，结束他
                var userUuid = rtcController.getScreenSharingUserUuid();
                if (userUuid == user.uuid &&
                    !roomContext.isScreenSharePermissionEnabled) {
                  roomContext.stopMemberScreenShare(userUuid!);
                }
                // 这个人在白板，结束他
                userUuid = whiteboardController.getWhiteboardSharingUserUuid();
                if (userUuid == user.uuid &&
                    !roomContext.isWhiteboardPermissionEnabled) {
                  whiteboardController.stopMemberWhiteboardShare(userUuid!);
                }
                showToast(
                    '${member.name}${meetingUiLocalizations.participantUserHasBeenRevokeCoHostRole}');
              }
            }
          });
        } else {
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
        }
        break;
      case NEActionMenuIDs.putInWaitingRoom:
        if (isSelfHostOrCoHost() &&
            !isUserOwner &&
            !isSelf &&
            !isUserHost &&
            !isUserCoHost &&
            waitingRoomManager.waitingRoomEnabledOnEntryListenable.value) {
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
        }
        break;
      case NEActionMenuIDs.chatPrivate:
        break;
      default:
        NEMeetingUIKit.instance.notifyOnInjectedMenuItemClick(context,
            NEActionMenuClickInfo(itemId: action, userUuid: user.uuid));
        break;
    }
    onMemberItemClick?.call(action, user);
    setState(() {});
  }

  bool shouldShowAction(NEMeetingMenuItem menuActionItem, NERoomMember user) {
    final isSelfHost = roomContext.isMySelfHost();
    final isSelf = roomContext.isMySelf(user.uuid);
    final isUserCoHost = roomContext.isCoHost(user.uuid);
    final isUserHost = roomContext.isHost(user.uuid);
    final isUserOwner = roomContext.isOwner(user.uuid);
    final isCoHostFull = roomContext.getCoHosts().length >=
        meetingUIState.sdkConfig.scheduledMemberConfig.coHostLimit;
    final hasScreenSharing =
        roomContext.rtcController.getScreenSharingUserUuid() != null;
    final hasWhiteboardSharing =
        whiteboardController.getWhiteboardSharingUserUuid() != null;
    final isCurrentSharingWhiteboard =
        whiteboardController.isWhiteboardSharing(user.uuid);
    final isSelfSharingWhiteboard = whiteboardController.isSharingWhiteboard();
    final lockedUser = context.read<MeetingUIState>().lockedUser;
    bool shouldShow = true;
    switch (menuActionItem.itemId) {
      case NEActionMenuIDs.audio:
        shouldShow = shouldShow && user.isAudioConnected;
        break;
      case NEActionMenuIDs.audioAndVideo:
        shouldShow = shouldShow && user.isAudioConnected;
        break;
      case NEActionMenuIDs.focusVideo:
        shouldShow = !hasScreenSharing;
        break;
      case NEActionMenuIDs.lockVideo:
        shouldShow = user.isVideoOn &&
                lockedUser != user.uuid &&
                !hasScreenSharing &&
                !hasWhiteboardSharing &&
                roomContext.getFocusUuid() == null ||
            lockedUser == user.uuid;
        break;
      case NEActionMenuIDs.changeHost:
        shouldShow = !isSelf && !user.isRoomSystemDevice;
        break;
      case NEActionMenuIDs.reclaimHost:
        shouldShow = isUserHost && roomContext.canReclaimHost;
        break;
      case NEActionMenuIDs.removeMember:
        shouldShow = !isSelf && !isUserCoHost && !isUserHost && !isUserOwner;
        break;
      case NEActionMenuIDs.rejectHandsUp:
        shouldShow = user.isRaisingHand;
        break;
      case NEActionMenuIDs.whiteboardInteraction:
        shouldShow =
            !isSelf && isSelfSharingWhiteboard && !user.isRoomSystemDevice;
        break;
      case NEActionMenuIDs.screenShare:
        shouldShow =
            (user.isSharingScreen || user.isSharingSystemAudio) && !isSelf;
        break;
      case NEActionMenuIDs.whiteBoardShare:
        shouldShow = isCurrentSharingWhiteboard;
        break;
      case NEActionMenuIDs.updateNick:
        return !arguments.options.noRename && (isSelf || isSelfHostOrCoHost());
      case NEActionMenuIDs.coHost:
        shouldShow = !isSelf &&
            (!isUserCoHost && !isCoHostFull || isUserCoHost) &&
            !user.isRoomSystemDevice;
        break;
      case NEActionMenuIDs.putInWaitingRoom:
        shouldShow = !isUserOwner &&
            !isSelf &&
            !isUserHost &&
            !isUserCoHost &&
            waitingRoomManager.waitingRoomEnabledOnEntryListenable.value &&
            !user.isRoomSystemDevice;
        break;
      case NEActionMenuIDs.chatPrivate:
        return !isSelf &&
            meetingUIState.sdkConfig.isMeetingChatSupported &&
            // 已经加入聊天室才展示私聊按钮
            context.read<MeetingUIState>().inMeetingChatroom.hasJoin &&
            (isSelfHostOrCoHost() ||
                roomContext.chatPermission == NEChatPermission.freeChat ||
                (roomContext.chatPermission != NEChatPermission.noChat &&
                    roomContext.isHostOrCoHost(user.uuid))) &&
            !user.isRoomSystemDevice;
    }
    if (shouldShow) {
      switch (menuActionItem.visibility) {
        case NEMenuVisibility.visibleExcludeHost:
          shouldShow = shouldShow && !isSelfHostOrCoHost();
          break;
        case NEMenuVisibility.visibleToHostOnly:
          shouldShow = shouldShow && isSelfHostOrCoHost();
          break;
        case NEMenuVisibility.visibleExcludeRoomSystemDevice:
          shouldShow = shouldShow && !user.isRoomSystemDevice;
          break;
        case NEMenuVisibility.visibleToOwnerOnly:
          shouldShow = shouldShow && roomContext.isOwner(roomContext.myUuid);
          break;
        case NEMenuVisibility.visibleToHostExcludeCoHost:
          shouldShow = shouldShow && isSelfHost;
          break;
        default:
          break;
      }
    }
    return shouldShow;
  }

  String getMenuItemTitle(NEMeetingMenuItem menuActionItem, NERoomMember user) {
    String? menuItemTitle;
    final isPinned = roomContext.getFocusUuid() == user.uuid;
    final lockedUser = context.read<MeetingUIState>().lockedUser;
    final hasInteract =
        whiteboardController.isDrawWhiteboardEnabledWithUserId(user.uuid);
    final isUserCoHost = roomContext.isCoHost(user.uuid);
    switch (menuActionItem.itemId) {
      case NEActionMenuIDs.audio:
        menuItemTitle = user.isAudioOn
            ? meetingUiLocalizations.participantMute
            : meetingUiLocalizations.participantUnmute;
        break;
      case NEActionMenuIDs.video:
        menuItemTitle = user.isVideoOn
            ? meetingUiLocalizations.participantStopVideo
            : meetingUiLocalizations.participantStartVideo;
        break;
      case NEActionMenuIDs.audioAndVideo:
        menuItemTitle = user.isAudioOn && user.isVideoOn
            ? meetingUiLocalizations.participantTurnOffAudioAndVideo
            : meetingUiLocalizations.participantTurnOnAudioAndVideo;
        break;
      case NEActionMenuIDs.focusVideo:
        menuItemTitle = isPinned
            ? meetingUiLocalizations.participantUnassignActiveSpeaker
            : meetingUiLocalizations.participantAssignActiveSpeaker;
        break;
      case NEActionMenuIDs.lockVideo:
        menuItemTitle = lockedUser == user.uuid
            ? meetingUiLocalizations.meetingUnpinView
            : meetingUiLocalizations.meetingPinView;
        break;
      case NEActionMenuIDs.changeHost:
        menuItemTitle = meetingUiLocalizations.participantTransferHost;
        break;
      case NEActionMenuIDs.reclaimHost:
        menuItemTitle = meetingUiLocalizations.meetingReclaimHost;
        break;
      case NEActionMenuIDs.removeMember:
        menuItemTitle = meetingUiLocalizations.participantRemove;
        break;
      case NEActionMenuIDs.rejectHandsUp:
        menuItemTitle = meetingUiLocalizations.meetingHandsUpDown;
        break;
      case NEActionMenuIDs.whiteboardInteraction:
        menuItemTitle = hasInteract
            ? meetingUiLocalizations.participantUndoWhiteBoardInteract
            : meetingUiLocalizations.participantWhiteBoardInteract;
        break;
      case NEActionMenuIDs.screenShare:
        menuItemTitle = meetingUiLocalizations.screenShareStop;
        break;
      case NEActionMenuIDs.whiteBoardShare:
        menuItemTitle = meetingUiLocalizations.whiteBoardClose;
        break;
      case NEActionMenuIDs.updateNick:
        menuItemTitle = meetingUiLocalizations.participantRename;
        break;
      case NEActionMenuIDs.coHost:
        menuItemTitle = isUserCoHost
            ? meetingUiLocalizations.participantUnassignCoHost
            : meetingUiLocalizations.participantAssignCoHost;
        break;
      case NEActionMenuIDs.putInWaitingRoom:
        menuItemTitle = meetingUiLocalizations.participantPutInWaitingRoom;
        break;
      case NEActionMenuIDs.chatPrivate:
        menuItemTitle = meetingUiLocalizations.chatPrivate;
        break;
    }
    NEMenuItemInfo? itemInfo;
    if (menuActionItem is NESingleStateMenuItem) {
      itemInfo = menuActionItem.singleStateItem;
    } else if (menuActionItem is NECheckableMenuItem) {
      itemInfo = menuActionItem.checked
          ? menuActionItem.checkedStateItem
          : menuActionItem.uncheckStateItem;
    }
    if (menuItemTitle == null && itemInfo != null) {
      menuItemTitle =
          (itemInfo.textGetter?.call(context) ?? itemInfo.text)?.trim();
    }
    return menuItemTitle ?? '';
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
    final future = user.isSharingScreen
        ? roomContext.stopMemberScreenShare(user.uuid)
        : roomContext.rtcController.stopMemberSystemAudioShare(user.uuid);
    await lifecycleExecute(future.then((NEResult? result) {
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
    lifecycleExecute(roomContext.handOverHost(user.uuid, false))
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
    if (user.clientType == NEClientType.h323) {
      subtitle.add(meetingUiLocalizations.h323);
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
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: _UIColors.color8D90A0,
      decoration: TextDecoration.none,
    );
    if (subtitle.isNotEmpty) {
      return Column(
        children: [
          Text(
            user.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: _UIColors.color1E1F27,
              decoration: TextDecoration.none,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${subtitle.join('，')}',
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
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: _UIColors.color1E1F27,
            decoration: TextDecoration.none),
      );
    }
  }

  void _rename(NERoomMember user) async {
    /// 不允许自己修改名字，且自己是普通成员，则弹窗提示
    if (!roomContext.isUpdateNicknamePermissionEnabled &&
        !isSelfHostOrCoHost()) {
      showToast(
        meetingUiLocalizations.updateNicknameNoPermission,
      );
      return;
    }
    final newName = await showRenameDialog(user.name);
    if (!mounted || newName == null || newName == user.name) return;

    /// 已经在编辑了也要给提示
    if (!roomContext.isUpdateNicknamePermissionEnabled &&
        !isSelfHostOrCoHost()) {
      showToast(
        meetingUiLocalizations.updateNicknameNoPermission,
      );
      return;
    }
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
  final int actionId;
  final NERoomMember user;

  _ActionData(this.actionId, this.user);
}

class WaitingRoomMemberList extends StatefulWidget {
  final WaitingRoomManager waitingRoomManager;
  final List<NEWaitingRoomMember> userList;
  final void Function(dynamic actionType, NEBaseRoomMember user)?
      onMemberItemClick;
  final ValueListenable<bool> isMySelfManagerListenable;
  final ValueListenable<bool> hideAvatar;

  const WaitingRoomMemberList(this.waitingRoomManager, this.userList,
      this.isMySelfManagerListenable, this.onMemberItemClick, this.hideAvatar,
      {super.key});

  @override
  State<WaitingRoomMemberList> createState() =>
      _WaitingRoomMemberListState(hideAvatar);
}

class _WaitingRoomMemberListState extends State<WaitingRoomMemberList>
    with MeetingKitLocalizationsMixin {
  StreamController? oneMinuteTick;
  StreamSubscription? oneMinuteTickSubscription;
  final userAutoPopListenable = <String, ValueNotifier<bool>>{};
  bool isShowMaxMembersTipDialog = false;
  final ValueListenable<bool> hideAvatar;

  _WaitingRoomMemberListState(this.hideAvatar);

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
    return NotificationListener<ScrollNotification>(
      child: Column(
        children: <Widget>[
          SizedBox(height: 16),
          Expanded(
              child: SingleChildScrollView(
                  child: MeetingCard(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            children: [
              ListView.builder(
                cacheExtent: 1,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                primary: false,
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  return buildMemberItem(userList[index]);
                },
              )
            ],
          ))),
          Container(height: 1, color: _UIColors.globalBg),
          buildHostActions(),
          Container(
            color: _UIColors.white,
            height: MediaQuery.of(context).padding.bottom,
          ),
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
    return Container(
        color: _UIColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            Expanded(
              child: MeetingTextButton.outlined(
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
  }

  Widget buildMemberItem(NEWaitingRoomMember user) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => handleWaitingRoomMemberItemClick(user),
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: hideAvatar,
              builder: (context, hideAvatar, child) {
                return NEMeetingAvatar.large(
                  name: user.name,
                  url: user.avatar,
                  hideImageAvatar: hideAvatar,
                );
              },
            ),
            SizedBox(width: 12),
            Expanded(
              child: buildUserInfo(user),
            ),
            if (user.status == NEWaitingRoomConstants.STATUS_WAITING) ...[
              _buildWaitingTextButton(meetingUiLocalizations.participantAdmit,
                  () {
                admitMember(user.uuid);
              }),
              SizedBox(
                width: 12,
              ),
              _buildWaitingTextButton(meetingUiLocalizations.participantRemove,
                  () {
                expelMember(user);
              }),
            ],
            if (user.status == NEWaitingRoomConstants.STATUS_ADMITTED)
              Text(
                meetingUiLocalizations.participantJoining,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: _UIColors.color1E1F27,
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
        color: _UIColors.color1E1F27,
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
                  color: _UIColors.color1E1F27,
                  decoration: TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${meetingUiLocalizations.participantWaitingTimePrefix}$waitingTime',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: _UIColors.color8D90A0,
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
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: _UIColors.colorE6E7EB, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
              color: _UIColors.color1E1F27,
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
          WaitingRoomNEMenuActionIDs.admit),
      buildActionSheet(meetingUiLocalizations.waitingRoomAutoAdmit, user,
          WaitingRoomNEMenuActionIDs.autoAdmit),
      buildActionSheet(meetingUiLocalizations.participantRemove, user,
          WaitingRoomNEMenuActionIDs.expel),
      buildActionSheet(meetingUiLocalizations.participantRename, user,
          WaitingRoomNEMenuActionIDs.rename),
      // 已经加入聊天室才展示私聊按钮
      if (context.read<MeetingUIState>().waitingRoomChatroom.hasJoin)
        buildActionSheet(meetingUiLocalizations.chatPrivate, user,
            WaitingRoomNEMenuActionIDs.chatPrivate),
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
      case WaitingRoomNEMenuActionIDs.expel:
        expelMember(action.member);
        break;
      case WaitingRoomNEMenuActionIDs.admit:
        admitMember(action.member.uuid);
        break;
      case WaitingRoomNEMenuActionIDs.rename:
        renameMember(action.member.uuid, action.member.name);
        break;
      case WaitingRoomNEMenuActionIDs.autoAdmit:
        admitMember(action.member.uuid, autoAdmit: true);
        break;
      case WaitingRoomNEMenuActionIDs.chatPrivate:
        break;
    }
    widget.onMemberItemClick?.call(action.action, action.member);
  }

  void admitMember(String uuid, {bool autoAdmit = false}) {
    if (checkMaxMember(false) && !isShowMaxMembersTipDialog) {
      isShowMaxMembersTipDialog = true;
      showMaxMembersTipDialog();
    } else {
      widget.waitingRoomManager
          .admitMember(uuid, autoAdmit: autoAdmit)
          .then((result) {
        if (result.code == 1022) {
          ToastUtils.showToast(
              context, meetingUiLocalizations.memberCountOutOfRange);
        }
      });
    }
  }

  void showMaxMembersTipDialog() {
    DialogUtils.showOneButtonCommonDialog(
      context,
      NEMeetingUIKitLocalizations.of(context)!.meetingMemberMaxTip,
      content: NEMeetingUIKitLocalizations.of(context)!
          .participantUpperLimitTipAdmitOtherTip,
    ).then((value) {
      isShowMaxMembersTipDialog = false;
    });
  }

  void admitAllMembers() async {
    if (checkMaxMember(true) && !isShowMaxMembersTipDialog) {
      isShowMaxMembersTipDialog = true;
      showMaxMembersTipDialog();
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
      WaitingRoomNEMenuActionIDs NEMenuActionIDs) {
    return CupertinoActionSheetAction(
      child: buildPopupText(text),
      onPressed: () {
        Navigator.pop(context, WaitingRoomMemberAction(user, NEMenuActionIDs));
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
                        includeInviteMember: true,
                        includeInviteWaitingJoinMember: false)
                    .length +
                waitingRoomMemberCount >
            currentRoomContext.maxMembers;
  }
}

class WaitingRoomMemberAction {
  final NEWaitingRoomMember member;
  final WaitingRoomNEMenuActionIDs action;

  WaitingRoomMemberAction(this.member, this.action);
}

enum WaitingRoomNEMenuActionIDs {
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
  final ValueListenable<bool> hideAvatar;
  final NERoomSIPController sipController;
  final NERoomAppInviteController appInviteController;

  const InviteMemberList(this.isMySelfManagerListenable, this.userList,
      this.sipController, this.appInviteController, this.hideAvatar,
      {super.key});

  @override
  State<InviteMemberList> createState() => _InviteMemberListState(
      isMySelfManagerListenable,
      sipController,
      appInviteController,
      hideAvatar);
}

class _InviteMemberListState extends State<InviteMemberList>
    with MeetingKitLocalizationsMixin {
  final ValueListenable<bool> isMySelfManagerListenable;
  final ValueListenable<bool> hideAvatar;
  final NERoomSIPController sipController;
  final NERoomAppInviteController appInviteController;

  _InviteMemberListState(this.isMySelfManagerListenable, this.sipController,
      this.appInviteController, this.hideAvatar);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: MeetingCard(
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              children: [
                ListView.builder(
                  cacheExtent: 1,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: widget.userList.length,
                  itemBuilder: (context, index) {
                    return buildMemberItem(widget.userList[index]);
                  },
                )
              ],
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).padding.bottom,
          color: _UIColors.globalBg,
        ),
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
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          ValueListenableBuilder(
            valueListenable: hideAvatar,
            builder: (context, hideAvatar, child) {
              return NEMeetingAvatar.large(
                name: user.name,
                url: user.avatar,
                hideImageAvatar: hideAvatar,
              );
            },
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
          _buildTextButton(
              text: _isUserInInviting(user)
                  ? meetingUiLocalizations.globalCancel
                  : meetingUiLocalizations.sipCall,
              color: _isUserInInviting(user)
                  ? _UIColors.colorF24957
                  : _UIColors.color_26BD71,
              onPressed: () {
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
                      voidResult =
                          await sipController.callByUserUuid(user.uuid);
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
                        ToastUtils.showToast(context,
                            meetingUiLocalizations.sipCallIsInInviting);
                        break;
                      case 3006:
                        ToastUtils.showToast(
                            context, meetingUiLocalizations.sipCallIsInMeeting);
                        break;
                      case 601011:
                        ToastUtils.showToast(context,
                            meetingUiLocalizations.sipCallIsInBlacklist);
                        break;
                      default:
                        break;
                    }
                  }
                });
              }),
          SizedBox(width: 12),
          _buildTextButton(
            text: meetingUiLocalizations.participantRemove,
            borderColor: _UIColors.colorE6E7EB,
            color: _UIColors.color1E1F27,
            onPressed: () {
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

  Widget _buildTextButton(
      {required String text,
      required Color color,
      Color? borderColor,
      required VoidCallback onPressed}) {
    return GestureDetector(
      child: Container(
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? color, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none),
        ),
      ),
      onTap: onPressed,
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
      case NERoomMemberInviteState.busy:
        return meetingUiLocalizations.sipCallBusy;
      default:
        break;
    }
    return '';
  }
}
