// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 参会者界面
class MeetMemberPage extends StatefulWidget {
  final MembersArguments arguments;

  MeetMemberPage(this.arguments);

  @override
  State<StatefulWidget> createState() {
    return MeetMemberPageState(arguments);
  }
}

class MeetMemberPageState extends LifecycleBaseState<MeetMemberPage>
    with EventTrackMixin {
  MeetMemberPageState(this.arguments);

  final MembersArguments arguments;

  late Radius _radius;

  bool isLock = true;

  final FocusNode _focusNode = FocusNode();

  String? _searchKey;
  late TextEditingController _searchTextEditingController;

  bool allowSelfAudioOn = false;

  late final  NEInRoomService inRoomService;
  late final NEInRoomWhiteboardController whiteboardController;

  late final String roomId;

  @override
  void initState() {
    super.initState();
    inRoomService = NERoomKit.instance.getInRoomService()!;
    whiteboardController = inRoomService.getInRoomWhiteboardController();
    roomId = inRoomService.getCurrentRoomId();
    _searchTextEditingController = TextEditingController();
    isLock = inRoomService.isRoomLocked();
    _radius = Radius.circular(8);
    lifecycleListen(arguments.roomInfoUpdatedEventStream, (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    var padding = data.size.height * 0.15;
    return WillPopScope(
      child: Padding(
        padding: EdgeInsets.only(top: padding),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.only(topLeft: _radius, topRight: _radius)),
            child: SafeArea(top: false, child: buildContent())),
      ),
      onWillPop: () async {
        return onWillPop();
      },
    );
  }

  Widget buildContent() {
    final userList = inRoomService
        .getAllUsers()
        .where((element) => _searchKey == null || element.displayName.contains(_searchKey!))
        .toList()..sort(compareUser);

    return StreamBuilder(
      //stream: arguments.,
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            title(userList.length),
            buildSearch(),
            Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_focusNode.hasFocus) {
                      _focusNode.unfocus();
                    }
                  },
                  child: buildMembers(userList),
                )),
            if (inRoomService.isMySelfHost()) ...buildHost(),
          ],
        );
      },
    );
  }

  bool onWillPop() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      return false;
    }
    return true;
  }

  Widget buildSearch() {
    return Material(
      color: Colors.white,
      child: Container(
          margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          padding: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
              color: UIColors.colorF7F8FA,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border.all(width: 1, color: UIColors.colorF2F3F5)),
          height: 36,
          alignment: Alignment.center,
          child: TextField(
            focusNode: _focusNode,
            controller: _searchTextEditingController,
            cursorColor: UIColors.blue_337eff,
            keyboardAppearance: Brightness.light,
            textAlignVertical: TextAlignVertical.center,
            onChanged: (String value) {
              setState(() {
                _searchKey = value;
              });
            },
            decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
                hintText: Strings.searchMember,
                hintStyle: TextStyle(
                    fontSize: 15,
                    color: UIColors.colorD8D8D8,
                    decoration: TextDecoration.none),
                border: InputBorder.none,
                prefixIcon: Icon(
                  NEMeetingIconFont.icon_search2_line1x,
                  size: 16,
                  color: UIColors.colorD8D8D8,
                ),
                prefixIconConstraints: BoxConstraints(
                    minWidth: 32, minHeight: 32, maxHeight: 32, maxWidth: 32),
                suffixIcon: TextUtils.isEmpty(_searchTextEditingController.text)
                    ? null
                    : ClearIconButton(
                        onPressed: () {
                          _searchTextEditingController.clear();
                          setState(() {
                            _searchKey = null;
                          });
                        },
                      )),
          )),
    );
  }

  Widget shadow() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: UIColors.white,
        boxShadow: [
          BoxShadow(
              color: UIColors.color_19242744,
              offset: Offset(4, 0),
              blurRadius: 8),
        ],
      ),
    );
  }

  int compareUser(NEInRoomUserInfo lhs, NEInRoomUserInfo rhs) {
      if (inRoomService.isHostUser(lhs.userId)) {
        return -1;
      }
      if (inRoomService.isHostUser(rhs.userId)) {
        return 1;
      }
      final cmp = (rhs.raiseHandDetail.timestamp).compareTo(lhs.raiseHandDetail.timestamp);
      if (cmp == 0) {
        return lhs.audioStatus.index.compareTo(rhs.audioStatus.index);
      }
      return cmp;
  }

  Widget buildMembers(List<NEInRoomUserInfo> userList) {
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
          return Divider(height: 1, color: UIColors.globalBg);
        });
  }

  List<Widget> buildHost() {
    return [buildLockItem(), shadow(), buildBottomItem()];
  }

  Widget buildLockItem() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: UIColors.colorE8E9EB, width: 0.5))),
      padding: EdgeInsets.only(left: 30, right: 24),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(Strings.lockMeeting,
                style: TextStyle(
                    color: UIColors.black_222222,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none)),
          ),
          MeetingCoreValueKey.addTextWidgetTest(
              valueKey: MeetingCoreValueKey.meetingMembersLockSwitchBtn,
              value: isLock),
          CupertinoSwitch(
            key: MeetingCoreValueKey.meetingMembersLockSwitchBtn,
            value: isLock,
            onChanged: (bool value) {
              setState(() {
                updateLockState(value);
              });
            },
            activeColor: UIColors.blue_337eff,
          )
        ],
      ),
    );
  }

  /// 锁定状态， 失败回退
  void updateLockState(bool lock) {
    isLock = lock;
    lifecycleExecute(inRoomService.lockRoom(lock))
        .then((result) {
      if (!mounted) return;
      if (result?.isSuccess() ?? false) {
        ToastUtils.showToast(
            context,
            result?.msg ??
                (lock
                    ? Strings.lockMeetingByHost
                    : Strings.unLockMeetingByHost));
      } else {
        ToastUtils.showToast(
          context,
          result?.msg ??
              (lock
                  ? Strings.lockMeetingByHostFail
                  : Strings.unLockMeetingByHostFail),
        );
      }
      setState(() {
        isLock = inRoomService.isRoomLocked();
      });
    });
  }

  Widget buildBottomItem() {
    return Container(
      height: 49,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
              child: TextButton(
            child: Text(Strings.muteAudioAll),
            onPressed: _onMuteAll,
            style: ButtonStyle(
                textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
                foregroundColor:
                    MaterialStateProperty.all(UIColors.blue_337eff)),
          )),
          Center(
            child: Container(height: 24, width: 1, color: UIColors.colorE9E9E9),
          ),
          Expanded(
              child: TextButton(
            child: Text(Strings.unMuteAudioAll),
            onPressed: unMuteAll2Server,
            style: ButtonStyle(
                textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
                foregroundColor:
                    MaterialStateProperty.all(UIColors.blue_337eff)),
          )),
        ],
      ),
    );
  }

  void _onMuteAll() {
    trackPeriodicEvent(TrackEventName.muteAll,
        extra: {'meeting_id': roomId});
    DialogUtils.showChildNavigatorDialog(context, StatefulBuilder(
      builder: (context, setState) {
        return CupertinoAlertDialog(
          title: Text(Strings.muteAudioAllDialogTips,
              style: TextStyle(color: Colors.black, fontSize: 17)),
          content: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                allowSelfAudioOn = !allowSelfAudioOn;
              });
            },
            child: Text.rich(
              TextSpan(children: [
                WidgetSpan(
                  child: Icon(Icons.check_box,
                      size: 14,
                      color: allowSelfAudioOn
                          ? UIColors.blue_337eff
                          : UIColors.colorB3B3B3),
                ),
                TextSpan(text: Strings.muteAllAudioTip)
              ]),
              style: TextStyle(fontSize: 13, color: UIColors.color_333333),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(Strings.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
              textStyle: TextStyle(color: UIColors.color_666666),
            ),
            CupertinoDialogAction(
              child: Text(Strings.muteAudioAll),
              onPressed: () {
                Navigator.of(context).pop();
                muteAll2Server();
              },
              textStyle: TextStyle(color: UIColors.color_337eff),
            ),
          ],
        );
      },
    ));
  }

  void muteAll2Server() {
    lifecycleExecute(inRoomService
            .getInRoomAudioController()
            .muteAllParticipantsAudio(allowSelfAudioOn))
        .then((result) {
      if (!mounted || result == null) return;
      if (result.isSuccess()) {
        ToastUtils.showToast(context, Strings.muteAllAudioSuccess);
      } else {
        ToastUtils.showToast(context, result.msg ?? Strings.muteAllAudioFail);
      }
    });
  }

  void unMuteAll2Server() {
    trackPeriodicEvent(TrackEventName.unMuteAll,
        extra: {'meeting_id': roomId});
    lifecycleExecute(inRoomService.getInRoomAudioController().unmuteAllParticipantsAudio())
        .then((result) {
      if (!mounted || result == null) return;
      if (result.isSuccess()) {
        ToastUtils.showToast(context, Strings.unMuteAllAudioSuccess);
      } else {
        ToastUtils.showToast(
            context, result.msg ?? Strings.unMuteAllAudioFail);
      }
    });
  }

  Widget title(int userCount) {
    return Container(
      height: 48,
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
              side: BorderSide(color: UIColors.globalBg),
              borderRadius:
                  BorderRadius.only(topLeft: _radius, topRight: _radius))),
      child: Stack(
        children: <Widget>[
          Center(
            child: Text(
              '${Strings.memberlistTitle}($userCount)',
              style: TextStyle(
                  color: UIColors.black_333333,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  decoration: TextDecoration.none),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: RawMaterialButton(
              constraints:
                  const BoxConstraints(minWidth: 40.0, minHeight: 48.0),
              child: Icon(
                NEMeetingIconFont.icon_yx_tv_duankaix,
                color: UIColors.color_666666,
                size: 15,
                key: MeetingCoreValueKey.close,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          )
        ],
      ),
    );
  }

  Widget buildMemberItem(NEInRoomUserInfo user) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(user),
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _memberItemNick(user),
            ),
            MeetingCoreValueKey.addTextWidgetTest(
                valueKey: ValueKey('${user.tag}'),
                value: true),
            if (user.isScreenSharing)
              Icon(NEMeetingIconFont.icon_yx_tv_sharescreen,
                  color: UIColors.color_337eff, size: 20),
            if (user.isWhiteBoardSharing)
              Icon(NEMeetingIconFont.icon_whiteboard,
                  color: UIColors.color_337eff, size: 20),
            if (user.isScreenSharing || user.isWhiteBoardSharing)
              SizedBox(width: 20),
            if (inRoomService.isMySelfHost() && user.raiseHandDetail.isRaisingHand)
              /// 主持人才显示
              Icon(NEMeetingIconFont.icon_raisehands,
                  color: UIColors.color_337eff, size: 20),
            SizedBox(width: 20),
            Icon(
                user.videoStatus != NERoomVideoStatus.on
                    ? NEMeetingIconFont.icon_yx_tv_video_offx
                    : NEMeetingIconFont.icon_yx_tv_video_onx,
                color:
                  user.videoStatus != NERoomVideoStatus.on ? Colors.red : Colors.black,
                size: 20),
            SizedBox(width: 20),
            Icon(
                user.audioStatus != NERoomAudioStatus.on
                    ? NEMeetingIconFont.icon_yx_tv_voice_offx
                    : NEMeetingIconFont.icon_yx_tv_voice_onx,
                color:
                  user.audioStatus != NERoomAudioStatus.on ? Colors.red : Colors.black,
                size: 20)
          ],
        ),
      ),
    );
  }

  Widget buildPopupText(String text) {
    return Text(text,
        style: TextStyle(color: UIColors.color_007AFF, fontSize: 20));
  }

  Widget buildActionSheet(
      String text, NEInRoomUserInfo user, MemberActionType memberActionType) {
    return CupertinoActionSheetAction(
      child: buildPopupText(text),
      onPressed: () {
        Navigator.pop(context, _ActionData(memberActionType, user));
      },
    );
  }

  void _onTap(NEInRoomUserInfo user) {
    final isHost = inRoomService.isMySelfHost();
    final isSelf = inRoomService.isMyself(user.userId);
    final hasScreenSharing = inRoomService.getInRoomScreenShareController().getScreenSharingUserId() != null;
    final hasInteract = whiteboardController.hasInteractPrivilegeWithUserId(user.userId);
    final isCurrentSharingWhiteboard =  whiteboardController.isWhiteboardSharing(user.userId);
    final isSelfSharingWhiteboard =  whiteboardController.isSharingWhiteboard();

    final actions = <Widget>[
      if (!arguments.options.noRename && isSelf)
        buildActionSheet(Strings.rename, user, MemberActionType.updateNick),
      if (isHost && user.raiseHandDetail.isRaisingHand)
        buildActionSheet(Strings.handsUpDown, user, MemberActionType.hostRejectAudioHandsUp),
      if (isHost && user.audioStatus == NERoomAudioStatus.on)
        buildActionSheet(Strings.muteAudio, user, MemberActionType.hostMuteAudio),
      if (isHost && user.audioStatus != NERoomAudioStatus.on)
        buildActionSheet(Strings.unMuteAudio, user, MemberActionType.hostUnMuteAudio),
      if (isHost && !user.isScreenSharing && user.videoStatus == NERoomVideoStatus.on)
        buildActionSheet(Strings.muteVideo, user, MemberActionType.hostMuteVideo),
      if (isHost && !user.isScreenSharing && user.videoStatus != NERoomVideoStatus.on)
        buildActionSheet(Strings.unMuteVideo, user, MemberActionType.hostUnMuteVideo),
      if (isHost && !hasScreenSharing && !user.isPinned)
        buildActionSheet(Strings.focusVideo, user, MemberActionType.setFocusVideo),
      if (isHost && !hasScreenSharing && user.isPinned)
        buildActionSheet(Strings.unFocusVideo, user, MemberActionType.cancelFocusVideo),
      if (isHost && !isSelf && user.clientType != ClientType.sip)
        buildActionSheet(Strings.changeHost, user, MemberActionType.changeHost),
      if (isHost && user.isScreenSharing)
        buildActionSheet(Strings.unScreenShare, user, MemberActionType.hostStopScreenShare),
      if (isHost && isCurrentSharingWhiteboard)
        buildActionSheet(Strings.closeWhiteBoard, user, MemberActionType.hostStopWhiteBoardShare),
      if (!isSelf && isSelfSharingWhiteboard && hasInteract)
        buildActionSheet(Strings.undoWhiteBoardInteract, user, MemberActionType.undoMemberWhiteboardInteraction),
      if (!isSelf && isSelfSharingWhiteboard && !hasInteract)
        buildActionSheet(Strings.whiteBoardInteract, user, MemberActionType.awardedMemberWhiteboardInteraction),
      if (isHost && !isSelf)
        buildActionSheet(Strings.remove, user, MemberActionType.removeMember),
    ];
    if (actions.isEmpty) return;

    DialogUtils.showChildNavigatorPopup<_ActionData>(
        context,
        CupertinoActionSheet(
          title: Text(
            '${user.displayName}',
            style: TextStyle(color: UIColors.grey_8F8F8F, fontSize: 13),
          ),
          actions: actions,
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: buildPopupText(Strings.cancel),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        )).then<void>((_ActionData? value) {
      if (value != null && value.action.index != -1) {
        handleAction(value.action, value.user);
      }
    });
  }

void handleAction(MemberActionType action, NEInRoomUserInfo user) {
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
      case MemberActionType.changeHost:
        changeHost(user);
        break;
      case MemberActionType.removeMember:
        removeMember(user);
        break;
      case MemberActionType.hostRejectAudioHandsUp:
        hostRejectAudioHandsUp(user);
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
    }
    setState(() {});
  }

  Future<void> _hostStopWhiteBoard(NEInRoomUserInfo member) async {
    var result = await whiteboardController.stopParticipantWhiteboardShare(
        member.userId);
    if (!result.isSuccess() && mounted) {
      ToastUtils.showToast(
          context, result.msg ?? Strings.whiteBoardShareStopFail);
    }
  }

  Future<void> _hostStopScreenShare(NEInRoomUserInfo user) async {
    await lifecycleExecute(inRoomService.getInRoomScreenShareController()
        .stopParticipantScreenShare(user.userId)
        .then((NEResult? result) {
      if (!mounted || result == null) return;
      if (!result.isSuccess()) {
        ToastUtils.showToast(
            context, result.msg ?? Strings.screenShareStopFail);
      }
    }));
    }

  Future<void> _awardedWhiteboardInteraction(NEInRoomUserInfo user) async {
    var result = await whiteboardController.setInteractPrivilege(user.userId, true);
    if (!result.isSuccess() && mounted) {
      ToastUtils.showToast(
          context, result.msg ?? Strings.whiteBoardInteractFail);
    }
  }

  Future<void> _undoWhiteboardInteraction(NEInRoomUserInfo user) async {
    var result =
        await whiteboardController.setInteractPrivilege(user.userId, false);
    if (!result.isSuccess() && mounted) {
      ToastUtils.showToast(
          context, result.msg ?? Strings.undoWhiteBoardInteractFail);
    }
  }

  void hostRejectAudioHandsUp(NEInRoomUserInfo user) {
    trackPeriodicEvent(TrackEventName.handsUpDown,
        extra: {'value': 0, 'member_uid': user.userId, 'meeting_id': roomId});
    lifecycleExecute(inRoomService.getInRoomAudioController().lowerHand(user.userId))
        .then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        ToastUtils.showToast(context, result.msg ?? Strings.handsUpDownFail);
      }
    });
  }

  void removeMember(NEInRoomUserInfo user) {
    trackPeriodicEvent(TrackEventName.removeMember,
        extra: {'member_uid': user.userId, 'meeting_id': roomId});
    if (inRoomService.isMyself(user.userId)) {
      ToastUtils.showToast(context, Strings.cannotRemoveSelf);
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(Strings.remove),
            content: Text(Strings.removeTips + '${user.displayName}?'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(Strings.no),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(Strings.yes),
                onPressed: () {
                  Navigator.of(context).pop();
                  removeMember2Server(user);
                },
              ),
            ],
          );
        });
  }

  void removeMember2Server(NEInRoomUserInfo user) {
    lifecycleExecute(inRoomService.getInRoomUserController().removeUser(user.userId))
        .then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        ToastUtils.showToast(context, result.msg ?? Strings.removeMemberFail);
      }
    });
  }

  void muteMemberAudio(NEInRoomUserInfo user, bool mute) {
    trackPeriodicEvent(TrackEventName.switchAudioMember,
        extra: {'value': mute ? 0 : 1, 'member_uid': user.userId, 'meeting_id': roomId});
    var future = inRoomService.getInRoomAudioController().muteParticipantAudio(user.userId, mute);
    lifecycleExecute(future).then((NEResult? result) {
      if (result != null && mounted && !result.isSuccess()) {
        ToastUtils.showToast(context, result.msg ?? (mute ? Strings.muteAudioFail : Strings.unMuteAudioFail));
      }
    });
  }

  void muteMemberVideo(NEInRoomUserInfo user, bool mute) {
    trackPeriodicEvent(TrackEventName.switchCameraMember,
        extra: {'value': mute ? 0 : 1, 'member_uid': user.userId, 'meeting_id': roomId});
    final result = mute
          ? inRoomService.getInRoomVideoController().stopParticipantVideo(user.userId)
          : inRoomService.getInRoomVideoController().askParticipantStartVideo(user.userId);
    lifecycleExecute(result).then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        ToastUtils.showToast(context, result.msg ?? (mute ? Strings.muteVideoFail : Strings.unMuteVideoFail));
      }
    });
  }

  void setFocusVideo(NEInRoomUserInfo user, bool focus) {
    trackPeriodicEvent(TrackEventName.focusMember,
        extra: {'value': focus ? 1 : 0, 'member_uid': user.userId, 'meeting_id': roomId});
    lifecycleExecute(inRoomService.getInRoomVideoController().pinVideo(user.userId, focus))
        .then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        ToastUtils.showToast(context, result.msg ?? (focus ? Strings.focusVideoFail : Strings.unFocusVideoFail));
      }
    });
  }

  void changeHost(NEInRoomUserInfo user) {
    trackPeriodicEvent(TrackEventName.changeHost, extra: {'member_uid': user.userId, 'meeting_id': roomId});
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(Strings.changeHost),
            content: Text('${Strings.changeHostTips}${user.displayName}?'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(Strings.no),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(Strings.yes),
                onPressed: () {
                  Navigator.of(context).pop();
                  changeHost2Server(user);
                },
              ),
            ],
          );
        });
  }

  void changeHost2Server(NEInRoomUserInfo user) {
    lifecycleExecute(inRoomService.getInRoomUserController().makeHost(user.userId)).then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        ToastUtils.showToast(context, result.msg ?? Strings.changeHostFail);
      }
    });
  }

  Widget _memberItemNick(NEInRoomUserInfo user) {
    var subtitle = <String>[];
    if (inRoomService.isHostUser(user.userId)) {
      subtitle.add(Strings.host);
    }
    if (inRoomService.isMyself(user.userId)) {
      subtitle.add(Strings.me);
    }
    if(user.clientType == ClientType.sip){
      subtitle.add(Strings.sipTip);
    }
    if (subtitle.isNotEmpty) {
      return Column(
        children: [
          Text(
            user.displayName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: UIColors.color_333333,
              decoration: TextDecoration.none,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '(${subtitle.reduce((String value, String element) => value + '，' + element)})',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: UIColors.color_999999,
              decoration: TextDecoration.none,
            ),
          ),
        ],
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } else {
      return Text(
        user.displayName,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.normal, color: UIColors.color_333333, decoration: TextDecoration.none),
      );
    }
  }

  final TextEditingController _textFieldController = TextEditingController();
  void _rename(NEInRoomUserInfo user) {
    _textFieldController.text = user.displayName;
    _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => CupertinoAlertDialog(
            title: Text(Strings.rename),
            content: Container(
                margin: EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoTextField(
                        autofocus: true,
                        controller: _textFieldController,
                        placeholder: Strings.renameTips,
                        placeholderStyle: const TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.placeholderText,
                        ),
                        onChanged: (_) => setState((){}),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _nicknameValid() ? () => _doRename(context, user) : null,
                        clearButtonMode: OverlayVisibilityMode.editing,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20),
                        ],
                    ),
                  ],
                )),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(Strings.cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                  child: Text(Strings.done),
                  onPressed: _nicknameValid() ? () => _doRename(context, user) : null,
              ),
            ],
          ),
        );
      },
    );
  }

  bool _nicknameValid() => _textFieldController.text.isNotEmpty;

  void _doRename(BuildContext dialogContext, NEInRoomUserInfo user) {
    final nickname = _textFieldController.text;

    if (nickname == user.displayName) return;

    Navigator.of(dialogContext).pop();

    lifecycleExecute(inRoomService.getInRoomUserController().changeMyName(nickname))
        .then((NEResult? result) {
      if (mounted && result != null) {
        if (result.isSuccess()) {
          ToastUtils.showToast(context, Strings.renameSuccess);
        } else {
          ToastUtils.showToast(context, result.msg ?? Strings.renameFail);
        }
      }
    });
  }
}


class _ActionData {
  final MemberActionType action;
  final NEInRoomUserInfo user;

  _ActionData(this.action, this.user);
}

enum MemberActionType {
  hostMuteAudio,
  hostUnMuteAudio,
  hostMuteVideo,
  hostUnMuteVideo,
  setFocusVideo,
  cancelFocusVideo,
  changeHost,
  removeMember,
  hostRejectAudioHandsUp,
  awardedMemberWhiteboardInteraction,
  undoMemberWhiteboardInteraction,
  hostStopScreenShare,
  hostStopWhiteBoardShare,
  updateNick,
}
