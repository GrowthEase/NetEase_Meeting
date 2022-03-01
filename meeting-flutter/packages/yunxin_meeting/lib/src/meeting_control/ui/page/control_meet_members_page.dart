// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

/// 参会者界面
class ControlMeetMemberPage extends StatefulWidget {
  final ControlMembersArguments arguments;

  ControlMeetMemberPage(this.arguments);

  @override
  State<StatefulWidget> createState() {
    return _ControlMeetMemberPageState(arguments);
  }
}

class _ControlMeetMemberPageState extends LifecycleBaseState<ControlMeetMemberPage>
    with EventTrackMixin {
  _ControlMeetMemberPageState(this.arguments);

  static const  _tag = 'ControlMeetMemberPage';

  final ControlMembersArguments arguments;

  late Radius _radius;

  bool isLock = true;

  final FocusNode _focusNode = FocusNode();

  late TextEditingController _contentController;

  bool allowSelfAudioOn = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    allowSelfAudioOn =
        arguments.memberSource.meetingInfo?.settings?.isAllowSelfAudioOn ??
            true;
    _radius = Radius.circular(8);
    isLock = JoinControlType.isLock(arguments.joinControlType);

    lifecycleListen(arguments.memberSource.stream, (dynamic dataSource) {
      isLock = JoinControlType.isLock(arguments.joinControlType);
      arguments.memberSource.onSearch(_contentController.text);
      setState(() {});
    });
  }

  @override
  void dispose() {
    arguments.memberSource.resetSearch();
    _focusNode.dispose();
    _contentController.dispose();
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
    return Column(
      children: <Widget>[
        title(),
        Expanded(
          child: buildMembers(),
        ),
        if (arguments.isHost()) ...buildHost(),
      ],
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
            controller: _contentController,
            cursorColor: UIColors.blue_337eff,
            keyboardAppearance: Brightness.light,
            textAlignVertical: TextAlignVertical.center,
            onChanged: (String value) {
              setState(() {
                arguments.memberSource.onSearch(value);
              });
            },
            decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
                hintText: _Strings.searchMember,
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
                suffixIcon: TextUtils.isEmpty(_contentController.text)
                    ? null
                    : ClearIconButton(
                  onPressed: () {
                    _contentController.clear();
                    setState(() {
                      arguments.memberSource.onSearch(null);
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

  Widget buildMembers() {
    return ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        primary: false,
        cacheExtent: 48,
        itemCount: arguments.memberSource.length + 1,
        itemBuilder: (context, index) {
          if (index == arguments.memberSource.length) {
            return SizedBox(height: 1);
          }
          return buildMemberItem(index);
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
            child: Text(_Strings.lockMeeting,
                style: TextStyle(
                    color: UIColors.black_222222,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none)),
          ),
          ControllerMeetingCoreValueKey.addTextWidgetTest(
              valueKey: ControllerMeetingCoreValueKey.meetingMembersLockSwitchBtn,
              value: isLock),
          CupertinoSwitch(
            key: ControllerMeetingCoreValueKey.meetingMembersLockSwitchBtn,
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

  Widget buildBottomItem() {
    return Container(
      height: 49,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
              child: TextButton(
                child: Text(_Strings.muteAudioAll),
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
                child: Text(_Strings.unMuteAudioAll),
                onPressed: _onUnMuteAll,
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
        extra: {'meeting_id': arguments.meetingId});
    DialogUtils.showChildNavigatorDialog(context, StatefulBuilder(
      builder: (context, setState) {
        return CupertinoAlertDialog(
          title: Text(_Strings.muteAudioAllDialogTips,
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
                TextSpan(text: _Strings.muteAllAudioTip)
              ]),
              style: TextStyle(fontSize: 13, color: UIColors.color_333333),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(_Strings.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
              textStyle: TextStyle(color: UIColors.color_666666),
            ),
            CupertinoDialogAction(
              child: Text(_Strings.muteAudioAll),
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

  void _onUnMuteAll() {
    trackPeriodicEvent(TrackEventName.unMuteAll,
        extra: {'meeting_id': arguments.meetingId});
    unMuteAll2Server();
  }
  

  Widget title() {
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
              '${_Strings.memberlistTitle}(${arguments.memberSource.length})',
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
                key: ControllerMeetingCoreValueKey.close,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          )
        ],
      ),
    );
  }

  Widget buildMemberItem(int index) {
    var member = arguments.findMemberInfo(arguments.memberSource.get(index));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(arguments.memberSource.get(index), member!),
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _memberItemNick(member),
            ),
            if (arguments.isScreenShare(member?.accountId))
              Icon(NEMeetingIconFont.icon_yx_tv_sharescreen,
                  color: UIColors.color_337eff, size: 20),
            if (arguments.isWhiteBoardShare(member?.avRoomUid))
              Icon(NEMeetingIconFont.icon_whiteboard,
                  color: UIColors.color_337eff, size: 20),
            if (arguments.isScreenShare(member?.accountId) ||
                arguments.isWhiteBoardShare(member?.avRoomUid))
              SizedBox(width: 20),
            if (arguments.isHost() && (member?.isAudioHandsUp() ?? false))

            /// 主持人才显示
              Icon(NEMeetingIconFont.icon_raisehands,
                  color: UIColors.color_337eff, size: 20),
            SizedBox(width: 20),
            Icon(
                member?.video != AVState.open
                    ? NEMeetingIconFont.icon_yx_tv_video_offx
                    : NEMeetingIconFont.icon_yx_tv_video_onx,
                color:
                member?.video != AVState.open ? Colors.red : Colors.black,
                size: 20),
            SizedBox(width: 20),
            Icon(
                member?.audio != AVState.open
                    ? NEMeetingIconFont.icon_yx_tv_voice_offx
                    : NEMeetingIconFont.icon_yx_tv_voice_onx,
                color:
                member?.audio != AVState.open ? Colors.red : Colors.black,
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
      String text, int roomUid, InMeetingMemberInfo? member, int actionType) {
    return CupertinoActionSheetAction(
      child: buildPopupText(text),
      onPressed: () {
        Navigator.pop(context,
            _ActionData(roomUid: roomUid, action: actionType, member: member));
      },
    );
  }

  void _onTap(int roomUid, InMeetingMemberInfo member) {
    if (arguments.isHost()) {
      _onHostTap(roomUid, member);
    } else if (arguments.isWhiteBoardOwner(member.avRoomUid) &&
        member.accountId != UserProfile.accountId ||
        arguments.showRename(member.accountId)) {
      _onMemberTap(roomUid, member);
    }
  }

//4334
  void _onMemberTap(int roomUid, InMeetingMemberInfo? member) {
    final whiteBoardOwner = arguments.isWhiteBoardOwner(member?.avRoomUid) &&
        member?.accountId != UserProfile.accountId;
    DialogUtils.showChildNavigatorPopup<_ActionData>(
        context,
        CupertinoActionSheet(
          title: Text(
            '${member?.nickName}',
            style: TextStyle(color: UIColors.grey_8F8F8F, fontSize: 13),
          ),
          actions: <Widget>[
            if (arguments.showRename(member?.accountId))
              buildActionSheet(
                  _Strings.rename, roomUid, member, ActionType.updateNick),
            if (whiteBoardOwner && (member?.hasWhiteBoardInteract() ?? false))
              buildActionSheet(_Strings.undoWhiteBoardInteract, roomUid, member,
                  ActionType.undoMemberWhiteboardInteraction),
            if (whiteBoardOwner && !(member?.hasWhiteBoardInteract() ?? false))
              buildActionSheet(_Strings.whiteBoardInteract, roomUid, member,
                  ActionType.awardedMemberWhiteboardInteraction),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: buildPopupText(_Strings.cancel),
            onPressed: () {
              Navigator.pop(context, _ActionData(roomUid: roomUid, action: -1));
            },
          ),
        )).then<void>((_ActionData? value) {
      if (value != null) {
        handleAction(value.action, value.member!);
      }
    });
  }

  void _onHostTap(int roomUid, InMeetingMemberInfo member) {
    DialogUtils.showChildNavigatorPopup<_ActionData>(
        context,
        CupertinoActionSheet(
          title: Text(
            '${member.nickName}',
            style: TextStyle(color: UIColors.grey_8F8F8F, fontSize: 13),
          ),
          actions: <Widget>[
            if (arguments.showRename(member.accountId))
              buildActionSheet(
                  _Strings.rename, roomUid, member, ActionType.updateNick),
            if (member.isAudioHandsUp() == true)
              buildActionSheet(_Strings.handsUpDown, roomUid, member,
                  ActionType.hostRejectAudioHandsUp),
            if (member.audio == AVState.open)
              buildActionSheet(
                  _Strings.muteAudio, roomUid, member, ActionType.hostMuteAudio),
            if (member.audio != AVState.open)
              buildActionSheet(_Strings.unMuteAudio, roomUid, member,
                  ActionType.hostUnMuteAudio),
            if (!arguments.isScreenShare(member.accountId) &&
                member.video == AVState.open)
              buildActionSheet(
                  _Strings.muteVideo, roomUid, member, ActionType.hostMuteVideo),
            if (!arguments.isScreenShare(member.accountId) &&
                member.video != AVState.open)
              buildActionSheet(_Strings.unMuteVideo, roomUid, member,
                  ActionType.hostUnMuteVideo),
            if (arguments.memberSource.screenSharersUid.isEmpty &&
                arguments.focusAccountId != member.accountId)
              buildActionSheet(_Strings.focusVideo, roomUid, member,
                  ActionType.setFocusVideo),
            if (arguments.memberSource.screenSharersUid.isEmpty &&
                arguments.focusAccountId == member.accountId)
              buildActionSheet(_Strings.unFocusVideo, roomUid, member,
                  ActionType.cancelFocusVideo),
            if (getCurrentAccountId() != member.accountId &&
                member.clientType != ClientType.sip)
              buildActionSheet(
                  _Strings.changeHost, roomUid, member, ActionType.changeHost),
            if (arguments.isScreenShare(member.accountId) &&
                member.accountId != UserProfile.accountId)
              buildScreenShareActionSheet(roomUid, member),
            if (arguments.isWhiteBoardShare(roomUid) &&
                member.accountId != UserProfile.accountId)
              buildWhiteBoardShareActionSheet(roomUid, member),
            if (arguments.isWhiteBoardOwner(member.avRoomUid) &&
                member.accountId != UserProfile.accountId &&
                member.hasWhiteBoardInteract())
              buildActionSheet(_Strings.undoWhiteBoardInteract, roomUid, member,
                  ActionType.undoMemberWhiteboardInteraction),
            if (arguments.isWhiteBoardOwner(member.avRoomUid) &&
                member.accountId != UserProfile.accountId &&
                !member.hasWhiteBoardInteract())
              buildActionSheet(_Strings.whiteBoardInteract, roomUid, member,
                  ActionType.awardedMemberWhiteboardInteraction),
            if (getCurrentAccountId() != member.accountId)
              buildActionSheet(
                  _Strings.remove, roomUid, member, ActionType.removeMember),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: buildPopupText(_Strings.cancel),
            onPressed: () {
              Navigator.pop(context, _ActionData(roomUid: roomUid, action: -1));
            },
          ),
        )).then<void>((_ActionData? value) {
      if (value != null && value.action != -1) {
        handleAction(value.action, value.member!);
      }
    });
  }

  // Future<void> _hostStopWhiteBoard(InMeetingMemberInfo member) async {
  //   await lifecycleExecute(InRoomRepository.hostStopWhiteBoardShare(
  //       arguments.meetingId, [member.accountId])).then((NEResult? result) {
  //     if (result?.code != RoomErrorCode.success) {
  //       ToastUtils.showToast(
  //           context, result?.msg ?? _Strings.whiteBoardShareStopFail);
  //     } else {
  //       notifyAction(ActionType.stopWhiteBoardShare, member.avRoomUid, member);
  //     }
  //   });
  // }
  //
  // Future<void> _hostStopScreenShare(InMeetingMemberInfo member) async {
  //   await lifecycleExecute(InRoomRepository.hostStopScreenShare(
  //       arguments.meetingId, [member.accountId])).then((NEResult? result) {
  //     if (result?.code != RoomErrorCode.success) {
  //       ToastUtils.showToast(
  //           context, result?.msg ?? _Strings.screenShareStopFail);
  //     } else {
  //       notifyAction(ActionType.hostStopScreenShare, member.avRoomUid, member);
  //     }
  //   });
  // }
  //
  // Future<void> _awardedMemberWhiteboardInteraction(
  //     InMeetingMemberInfo member) async {
  //   await lifecycleExecute(
  //       InRoomRepository.awardedMemberWhiteboardInteraction(
  //           arguments.meetingId, [member.avRoomUid]))
  //       .then((NEResult? result) async {
  //     if (result?.code == RoomErrorCode.success) {
  //       notifyAction(ActionType.awardedMemberWhiteboardInteraction,
  //           member.avRoomUid, member);
  //     } else {
  //       ToastUtils.showToast(
  //           context, result?.msg ?? _Strings.whiteBoardInteractFail);
  //     }
  //   });
  // }
  //
  // Future<void> _undoMemberWhiteboardInteraction(
  //     InMeetingMemberInfo member) async {
  //   await lifecycleExecute(InRoomRepository.undoMemberWhiteboardInteraction(
  //       arguments.meetingId, [member.avRoomUid]))
  //       .then((NEResult? result) async {
  //     if (result?.code == RoomErrorCode.success) {
  //       notifyAction(ActionType.undoMemberWhiteboardInteraction, member.avRoomUid, member,);
  //     } else {
  //       ToastUtils.showToast(
  //           context, result?.msg ?? _Strings.undoWhiteBoardInteractFail);
  //     }
  //   });
  // }

  void removeMember(InMeetingMemberInfo member) {
    trackPeriodicEvent(TrackEventName.removeMember,
        extra: {'member_uid': member.avRoomUid, 'meeting_id': arguments.meetingId});
    if (member.accountId == getCurrentAccountId()) {
      ToastUtils.showToast(context, _Strings.cannotRemoveSelf);
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(_Strings.remove),
            content: Text(_Strings.removeTips + '${member.nickName}?'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(_Strings.no),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(_Strings.yes),
                onPressed: () {
                  Navigator.of(context).pop();
                  removeMember2Server(member);
                },
              ),
            ],
          );
        });
  }
  
  void hostMuteAudio(InMeetingMemberInfo member, bool self) {
    trackPeriodicEvent(TrackEventName.switchAudioMember,
        extra: {'value': 0, 'member_uid': member.avRoomUid, 'meeting_id': arguments.meetingId});
    var future = self
        ? InRoomRepository.muteSelfAudio(arguments.meetingId)
        : InRoomRepository.hostMuteAudio(arguments.meetingId, [member.accountId]);
    var action = self ? ActionType.muteSelfAudio : ActionType.hostMuteAudio;
    lifecycleExecute(future).then((NEResult? result) {
      if (result?.isSuccess() ?? false) {
        notifyAction(action, member.avRoomUid, member);
      } else {
        ToastUtils.showToast(context, result?.msg ?? _Strings.muteAudioFail);
      }
    });
  }

  void hostUnMuteAudio(InMeetingMemberInfo? member, bool self) {
    trackPeriodicEvent(TrackEventName.switchAudioMember,
        extra: {'value': 1, 'member_uid': member?.avRoomUid, 'meeting_id': arguments.meetingId});
    var future = self
        ? InRoomRepository.unMuteSelfAudio(arguments.meetingId)
        : InRoomRepository.hostUnMuteAudio(arguments.meetingId, [member?.accountId]);
    var action = self ? ActionType.unMuteSelfAudio : ActionType.hostUnMuteAudio;
    lifecycleExecute(future).then((NEResult? result) {
      if (result?.code == RoomErrorCode.success) {
        notifyAction(action, member?.avRoomUid, member, handsUpDown: true);
      } else {
        ToastUtils.showToast(context, result?.msg ?? _Strings.unMuteAudioFail);
      }
    });
  }

  void hostMuteVideo(InMeetingMemberInfo member, bool self) {
    trackPeriodicEvent(TrackEventName.switchCameraMember,
        extra: {'value': 0, 'member_uid': member.avRoomUid, 'meeting_id': arguments.meetingId});
    var future = self
        ? InRoomRepository.muteSelfVideo(arguments.meetingId)
        : InRoomRepository.hostMuteVideo(arguments.meetingId, [member.accountId]);
    var action = self ? ActionType.muteSelfVideo : ActionType.hostMuteVideo;
    lifecycleExecute(future).then((NEResult? result) {
      if (result?.code == RoomErrorCode.success) {
        notifyAction(action, member.avRoomUid, member);
      } else {
        ToastUtils.showToast(context, result?.msg ?? _Strings.muteVideoFail);
      }
    });
  }

  void hostUnMuteVideo(InMeetingMemberInfo member, bool self) {
    trackPeriodicEvent(TrackEventName.switchCameraMember,
        extra: {'value': 1, 'member_uid': member.avRoomUid, 'meeting_id': arguments.meetingId});
    var future = self
        ? InRoomRepository.unMuteSelfVideo(arguments.meetingId)
        : InRoomRepository.hostUnMuteVideo(arguments.meetingId, [member.accountId]);
    var action = self ? ActionType.unMuteSelfVideo : ActionType.hostUnMuteVideo;
    lifecycleExecute(future).then((NEResult? result) {
      if (result?.code == RoomErrorCode.success) {
        notifyAction(action, member.avRoomUid, member);
      } else {
        ToastUtils.showToast(context, result?.msg ?? _Strings.unMuteVideoFail);
      }
    });
  }

  void cancelFocusVideo(InMeetingMemberInfo member) {
    trackPeriodicEvent(TrackEventName.focusMember,
        extra: {'value': 0, 'member_uid': member.avRoomUid, 'meeting_id': arguments.meetingId});
    lifecycleExecute(InRoomRepository.hostCancelFocusVideo(arguments.meetingId, [member.accountId]))
        .then((NEResult? result) {
      if (result?.code == RoomErrorCode.success) {
        notifyAction(ActionType.cancelFocusVideo, member.avRoomUid, member);
      } else {
        ToastUtils.showToast(context, result?.msg ?? _Strings.unFocusVideoFail);
      }
    });
  }

  void setFocusVideo(InMeetingMemberInfo member) {
    trackPeriodicEvent(TrackEventName.focusMember,
        extra: {'value': 1, 'member_uid': member.avRoomUid, 'meeting_id': arguments.meetingId});
    lifecycleExecute(InRoomRepository.hostSetFocusVideo(arguments.meetingId, [member.accountId]))
        .then((NEResult? result) {
      if (result?.code == RoomErrorCode.success) {
        notifyAction(ActionType.setFocusVideo, member.avRoomUid, member);
      } else {
        ToastUtils.showToast(context, result?.msg ?? _Strings.focusVideoFail);
      }
    });
  }

  void changeHost(InMeetingMemberInfo member) {
    trackPeriodicEvent(TrackEventName.changeHost, extra: {'member_uid': member.avRoomUid, 'meeting_id': arguments.meetingId});
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(_Strings.changeHost),
            content: Text('${_Strings.changeHostTips}${member.nickName}?'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(_Strings.no),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(_Strings.yes),
                onPressed: () {
                  Navigator.of(context).pop();
                  changeHost2Server(member);
                },
              ),
            ],
          );
        });
  }

  void notifyAction(int action, int? roomUid, InMeetingMemberInfo? member, {String? toastTips, bool handsUpDown = false}) {
    if (toastTips != null) {
      ToastUtils.showToast(context, toastTips);
    }
    if (handsUpDown) {
      member?.updateMuteAllHandsUp(false); //手放下
    }
    arguments.callback(action, roomUid, member);
    // update state
    setState(() {});
  }

  Widget _memberItemNick(InMeetingMemberInfo? member) {
    var nick = member?.nickName ?? '';
    var subtitle = <String>[];
    if (member?.accountId == arguments.hostAccountId) {
      subtitle.add(_Strings.host);
    }

    if (member?.accountId == getCurrentAccountId()) {
      subtitle.add(_Strings.me);
    }
    if(member?.clientType == ClientType.sip){
      subtitle.add(_Strings.sipTip);
    }
    if (subtitle.isNotEmpty) {
      return Column(
        children: [
          Text(
            nick,
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
        nick,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.normal, color: UIColors.color_333333, decoration: TextDecoration.none),
      );
    }
  }

  Widget buildScreenShareActionSheet(int roomUid, InMeetingMemberInfo member) {
    return Container();
  }

  Widget buildWhiteBoardShareActionSheet(int roomUid, InMeetingMemberInfo member) {
    return Container();
  }

  void muteAll2Server() {
    lifecycleExecute(ControlInMeetingRepository.hostMuteAllAudio(
        fromUser: getCurrentAccountId()!,
        allowSelfAudioOn: allowSelfAudioOn ? 1 : 2))
        .then((result) {
      if (result?.code == ControlCode.success) {
        notifyAction(ActionType.hostMuteAllAudio, null, null,
            toastTips: _Strings.muteAllAudioSuccess);
      } else if (result!.code == RoomErrorCode.networkError) {
        ToastUtils.showToast(context, _Strings.networkUnavailable);
      } else {
        ToastUtils.showToast(context, _Strings.muteAllAudioFail);
        setState(() {});
      }
    });
  }
  
  void unMuteAll2Server() {
    lifecycleExecute(ControlInMeetingRepository.hostUnMuteAllAudio(
        fromUser: getCurrentAccountId()!))
        .then((result) {
      if (result?.code == ControlCode.success) {
        notifyAction(ActionType.hostUnMuteAllAudio, null, null,
            toastTips: _Strings.unMuteAllAudioSuccess);
      } else if (result!.code == RoomErrorCode.networkError) {
        ToastUtils.showToast(context, _Strings.networkUnavailable);
      } else {
        ToastUtils.showToast(context, _Strings.unMuteAllAudioFail);
      }
    });
  }
  
  void handleAction(int action, InMeetingMemberInfo member) {
    var self = getCurrentAccountId() == member.accountId;

    ///如果离开了会议（不在成员列表）就不能再继续操作了
    if (arguments.findMemberInfo(member.avRoomUid) == null) {
      Alog.d(
          tag: _tag,
          moduleName: _moduleName,
          content: '_handleAction but ${member.avRoomUid} not in memberList');
      return;
    }

    switch (action) {
      case ActionType.hostMuteAudio:
        if (self) {
          lifecycleExecute(ControlInMeetingRepository.muteSelfAudio())
              .then((result) {
            if (result?.code == ControlCode.success) {
              notifyAction(ActionType.muteSelfAudio, member.avRoomUid, member);
            } else if (result!.code == RoomErrorCode.networkError) {
              ToastUtils.showToast(context, _Strings.networkUnavailable);
            } else {
              ToastUtils.showToast(context, _Strings.muteAudioFail);
            }
          });
        } else {
          lifecycleExecute(ControlInMeetingRepository.hostMuteAudio(
              fromUser: ControlProfile.pairedAccountId!,
              operaUser: member.accountId))
              .then((result) {
            if (result?.code == ControlCode.success) {
              notifyAction(ActionType.hostMuteAudio, member.avRoomUid, member);
            } else if (result!.code == RoomErrorCode.networkError) {
              ToastUtils.showToast(context, _Strings.networkUnavailable);
            } else {
              ToastUtils.showToast(context, _Strings.muteAudioFail);
            }
          });
        }
        break;
      case ActionType.hostUnMuteAudio:
        if (self) {
          lifecycleExecute(ControlInMeetingRepository.unMuteSelfAudio())
              .then((result) {
            if (result?.code == ControlCode.success) {
              notifyAction(
                  ActionType.unMuteSelfAudio, member.avRoomUid, member);
            } else if (result!.code == RoomErrorCode.networkError) {
              ToastUtils.showToast(context, _Strings.networkUnavailable);
            } else {
              ToastUtils.showToast(context, _Strings.muteAudioFail);
            }
          });
        } else {
          lifecycleExecute(ControlInMeetingRepository.hostUnMuteAudio(
              fromUser: ControlProfile.pairedAccountId!,
              operaUser: member.accountId))
              .then((result) {
            if (result?.code == ControlCode.success) {
              notifyAction(
                  ActionType.hostUnMuteAudio, member.avRoomUid, member);
            } else if (result!.code == RoomErrorCode.networkError) {
              ToastUtils.showToast(context, _Strings.networkUnavailable);
            } else {
              ToastUtils.showToast(context, _Strings.unMuteAudioFail);
            }
          });
        }
        break;
      case ActionType.hostMuteVideo:
        if (self) {
          lifecycleExecute(ControlInMeetingRepository.muteSelfVideo())
              .then((result) {
            if (result?.code == ControlCode.success) {
              notifyAction(ActionType.muteSelfVideo, member.avRoomUid, member);
            } else if (result!.code == RoomErrorCode.networkError) {
              ToastUtils.showToast(context, _Strings.networkUnavailable);
            } else {
              ToastUtils.showToast(context, _Strings.muteAudioFail);
            }
          });
        } else {
          lifecycleExecute(ControlInMeetingRepository.hostMuteVideo(
              fromUser: ControlProfile.pairedAccountId,
              operaUser: member.accountId))
              .then((result) {
            if (result?.code == ControlCode.success) {
              notifyAction(ActionType.hostMuteVideo, member.avRoomUid, member);
            } else if (result!.code == RoomErrorCode.networkError) {
              ToastUtils.showToast(context, _Strings.networkUnavailable);
            } else {
              ToastUtils.showToast(context, _Strings.muteVideoFail);
            }
          });
        }
        break;
      case ActionType.hostUnMuteVideo:
        if (self) {
          lifecycleExecute(ControlInMeetingRepository.unMuteSelfVideo())
              .then((result) {
            if (result?.code == ControlCode.success) {
              notifyAction(
                  ActionType.unMuteSelfVideo, member.avRoomUid, member);
            } else if (result!.code == RoomErrorCode.networkError) {
              ToastUtils.showToast(context, _Strings.networkUnavailable);
            } else {
              ToastUtils.showToast(context, _Strings.muteAudioFail);
            }
          });
        } else {
          lifecycleExecute(ControlInMeetingRepository.hostUnMuteVideo(
              fromUser: ControlProfile.pairedAccountId,
              operaUser: member.accountId))
              .then((result) {
            if (result?.code == ControlCode.success) {
              notifyAction(
                  ActionType.hostUnMuteVideo, member.avRoomUid, member);
            } else if (result!.code == RoomErrorCode.networkError) {
              ToastUtils.showToast(context, _Strings.networkUnavailable);
            } else {
              ToastUtils.showToast(context, _Strings.unMuteVideoFail);
            }
          });
        }
        break;
      case ActionType.setFocusVideo:
        lifecycleExecute(
            ControlInMeetingRepository.changeFocus(member.accountId, true))
            .then((result) {
          if (result?.code == ControlCode.success) {
            notifyAction(ActionType.setFocusVideo, member.avRoomUid, member);
          } else if (result!.code == RoomErrorCode.networkError) {
            ToastUtils.showToast(context, _Strings.networkUnavailable);
          } else {
            ToastUtils.showToast(context, _Strings.focusVideoFail);
          }
        });
        break;
      case ActionType.cancelFocusVideo:
        lifecycleExecute(
            ControlInMeetingRepository.changeFocus(member.accountId, false))
            .then((result) {
          if (result?.code == ControlCode.success) {
            notifyAction(ActionType.cancelFocusVideo, member.avRoomUid, member);
          } else if (result!.code == RoomErrorCode.networkError) {
            ToastUtils.showToast(context, _Strings.networkUnavailable);
          } else {
            ToastUtils.showToast(context, _Strings.unFocusVideoFail);
          }
        });
        break;
      case ActionType.changeHost:
        changeHost(member);
        break;
      case ActionType.removeMember:
        removeMember(member);
        break;
      case ActionType.hostRejectAudioHandsUp:
        hostRejectAudioHandsUp(member);
    }
    setState(() {});
  }
  
  void hostRejectAudioHandsUp(InMeetingMemberInfo member) {
    lifecycleExecute(
        ControlInMeetingRepository.hostRejectAudioHandsUp(member.accountId))
        .then((result) {
      if (result!.code == ControlCode.success) {
        notifyAction(
            ActionType.hostRejectAudioHandsUp, member.avRoomUid, member);
      } else if (result.code == RoomErrorCode.networkError) {
        ToastUtils.showToast(context, _Strings.networkUnavailable);
      } else {
        ToastUtils.showToast(context, _Strings.hostRejectAudioHandsUpFailed);
      }
    });
  }
  
  void removeMember2Server(InMeetingMemberInfo member) {
    lifecycleExecute(
        ControlInMeetingRepository.removeAttendee(member.accountId))
        .then((result) {
      if (result!.code == ControlCode.success) {
        notifyAction(ActionType.removeMember, member.avRoomUid, member);
      } else if (result.code == RoomErrorCode.networkError) {
        ToastUtils.showToast(context, _Strings.networkUnavailable);
      } else {
        ToastUtils.showToast(context, _Strings.removeMemberFail);
      }
    });
  }
  
  String? getCurrentAccountId() {
    return ControlProfile.pairedAccountId;
  }
  
  void changeHost2Server(InMeetingMemberInfo member) {
    lifecycleExecute(ControlInMeetingRepository.changeHost(member.accountId))
        .then((result) {
      if (result!.code == ControlCode.success) {
        notifyAction(ActionType.hostUnMuteAudio, member.avRoomUid, member);
      } else if (result.code == RoomErrorCode.networkError) {
        ToastUtils.showToast(context, _Strings.networkUnavailable);
      } else {
        ToastUtils.showToast(context, _Strings.changeHostFail);
      }
    });
  }
  
  void updateLockState(bool selected) {
    lifecycleExecute(ControlInMeetingRepository.changeLockState(
        arguments.meetingId, selected))
        .then((result) {
      if (result!.code == RoomErrorCode.success) {
        isLock = selected;
        if (isLock) {
          notifyAction(ActionType.hostLockMeeting, null, null,
              toastTips: _Strings.lockMeetingByHost);
        } else {
          notifyAction(ActionType.hostUnLockMeeting, null, null,
              toastTips: _Strings.unLockMeetingByHost);
        }
      } else if (result.code == RoomErrorCode.networkError) {
        ToastUtils.showToast(context, _Strings.networkUnavailable);
      } else {
        /// revert
        ToastUtils.showToast(context, _Strings.lockMeetingByHostFail);
        setState(() {});
      }
    });
  }
  
}

class _ActionData {
  int roomUid;
  int action;
  InMeetingMemberInfo? member;

  _ActionData({required this.roomUid, required this.action, this.member});
}
