// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

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

  static const _radius = Radius.circular(8);

  bool isLock = true;

  final FocusNode _focusNode = FocusNode();

  String? _searchKey;
  late TextEditingController _searchTextEditingController;

  bool allowSelfAudioOn = false;
  bool allowSelfVideoOn = false;

  late final NERoomContext roomContext;
  late final NERoomWhiteboardController whiteboardController;
  late final NERoomRtcController rtcController;

  late final String roomId;

  late final int maxCount;

  late final NERoomEventCallback roomEventCallback;

  final String _tag = 'MeetMemberPage';

  bool moreDialogIsShow = false; // 更多菜单对话框是否展示
  String? moreDialogBindingMember; // 更多菜单对话框对应的成员

  void onRoomLockStateChanged(bool isLocked) {
    if (mounted) {
      setState(() {
        isLock = isLocked;
      });
    }
  }

  void onMemberRoleChanged(
      NERoomMember member, NERoomRole before, NERoomRole after) {
    if (moreDialogIsShow && member.uuid == roomContext.localMember.uuid) {
      Navigator.pop(context);
    }
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

  @override
  void initState() {
    super.initState();
    roomContext = arguments.roomContext;
    roomContext.addEventCallback(roomEventCallback = NERoomEventCallback(
      roomLockStateChanged: onRoomLockStateChanged,
      memberRoleChanged: onMemberRoleChanged,
      memberLeaveRoom: (members) {
        if (moreDialogIsShow &&
            members.any((member) => member.uuid == moreDialogBindingMember)) {
          Navigator.pop(context);
        }
      },
    ));
    whiteboardController = roomContext.whiteboardController;
    rtcController = roomContext.rtcController;
    roomId = roomContext.roomUuid;
    maxCount = parseMaxCountByContract(roomContext.extraData);
    _searchTextEditingController = TextEditingController();
    isLock = roomContext.isRoomLocked;
    lifecycleListen(arguments.roomInfoUpdatedEventStream, (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchTextEditingController.dispose();
    roomContext.removeEventCallback(roomEventCallback);
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
    final userList = roomContext
        .getAllUsers()
        .where((user) => _searchKey == null || user.name.contains(_searchKey!))
        .toList()
      ..sort(compareUser);

    return StreamBuilder(
      //stream: arguments.,
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            title(userList.length, maxCount),
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
            if (isSelfHostOrCoHost()) ...buildHost(),
          ],
        );
      },
    );
  }

  /// 自己是否是主持人或者联席主持人
  bool isSelfHostOrCoHost() {
    return roomContext.isMySelfHost() || isSelfCoHost();
  }

  /// 自己是否是联席主持人
  bool isSelfCoHost() {
    return roomContext.isMySelfCoHost();
  }

  /// [uuid] 是否是主持人或者联席主持人
  bool isHostOrCoHost(String? uuid) {
    return roomContext.isHostOrCoHost(uuid);
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
              color: _UIColors.colorF7F8FA,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border.all(width: 1, color: _UIColors.colorF2F3F5)),
          height: 36,
          alignment: Alignment.center,
          child: TextField(
            focusNode: _focusNode,
            controller: _searchTextEditingController,
            cursorColor: _UIColors.blue_337eff,
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
                hintText: NEMeetingUIKitLocalizations.of(context)!.searchMember,
                hintStyle: TextStyle(
                    fontSize: 15,
                    color: _UIColors.colorD8D8D8,
                    decoration: TextDecoration.none),
                border: InputBorder.none,
                prefixIcon: Icon(
                  NEMeetingIconFont.icon_search2_line1x,
                  size: 16,
                  color: _UIColors.colorD8D8D8,
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

  ///成员列表展示顺序：
  /// 主持人->联席主持人->自己->举手->屏幕共享（白板）->音视频->视频->音频->昵称排序
  ///
  int compareUser(NERoomMember lhs, NERoomMember rhs) {
    if (roomContext.isHost(lhs.uuid)) {
      return -1;
    }
    if (roomContext.isHost(rhs.uuid)) {
      return 1;
    }
    if (roomContext.isCoHost(lhs.uuid)) {
      return -1;
    }
    if (roomContext.isCoHost(rhs.uuid)) {
      return 1;
    }
    if (roomContext.isMySelf(lhs.uuid)) {
      return -1;
    }
    if (roomContext.isMySelf(rhs.uuid)) {
      return 1;
    }
    if (lhs.isRaisingHand) {
      return -1;
    }
    if (rhs.isRaisingHand) {
      return 1;
    }
    if (lhs.isSharingScreen) {
      return -1;
    }
    if (rhs.isSharingScreen) {
      return 1;
    }
    if (lhs.isSharingWhiteboard) {
      return -1;
    }
    if (rhs.isSharingWhiteboard) {
      return 1;
    }
    if (lhs.isVideoOn && lhs.isAudioOn) {
      return -1;
    }
    if (rhs.isVideoOn && rhs.isAudioOn) {
      return 1;
    }
    if (lhs.isVideoOn) {
      return -1;
    }
    if (rhs.isVideoOn) {
      return 1;
    }
    if (lhs.isAudioOn) {
      return -1;
    }
    if (rhs.isAudioOn) {
      return 1;
    }
    return lhs.name.compareTo(rhs.name);
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

  List<Widget> buildHost() {
    return [
      buildLockItem(),
      buildDivider(isShow: !arguments.options.noMuteAllAudio),
      buildMuteAllAudioActions(),
      buildDivider(isShow: !arguments.options.noMuteAllVideo),
      buildMuteAllVideoActions(),
    ];
  }

  ///构建分割线
  Widget buildDivider({bool isShow = true}) {
    return Visibility(
      visible: isShow,
      child: Divider(height: 1, color: _UIColors.globalBg),
    );
  }

  Widget buildLockItem() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: _UIColors.globalBg, width: 0.5))),
      padding: EdgeInsets.only(left: 30, right: 24),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(NEMeetingUIKitLocalizations.of(context)!.lockMeeting,
                style: TextStyle(
                    color: _UIColors.black_222222,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none)),
          ),
          MeetingUIValueKeys.addTextWidgetTest(
              valueKey: MeetingUIValueKeys.meetingMembersLockSwitchBtn,
              value: isLock),
          CupertinoSwitch(
            key: MeetingUIValueKeys.meetingMembersLockSwitchBtn,
            value: isLock,
            onChanged: (bool value) {
              setState(() {
                updateLockState(value);
              });
            },
            activeColor: _UIColors.blue_337eff,
          )
        ],
      ),
    );
  }

  /// 锁定状态， 失败回退
  void updateLockState(bool lock) {
    isLock = lock;
    lifecycleExecute(lock ? roomContext.lockRoom() : roomContext.unlockRoom())
        .then((result) {
      if (!mounted) return;
      if (result?.isSuccess() ?? false) {
        ToastUtils.showToast(
            context,
            lock
                ? NEMeetingUIKitLocalizations.of(context)!.lockMeetingByHost
                : NEMeetingUIKitLocalizations.of(context)!.unLockMeetingByHost);
      } else {
        ToastUtils.showToast(
          context,
          lock
              ? NEMeetingUIKitLocalizations.of(context)!.lockMeetingByHostFail
              : NEMeetingUIKitLocalizations.of(context)!
                  .unLockMeetingByHostFail,
        );
      }
    });
  }

  /// 创建"全体视频关闭/打开widget"
  Widget buildMuteAllVideoActions() {
    return Visibility(
      visible: !arguments.options.noMuteAllVideo,
      child: Container(
        height: 49,
        color: _UIColors.colorF7F9FBF0,
        child: Row(
          children: <Widget>[
            Expanded(
                child: TextButton(
              child:
                  Text(NEMeetingUIKitLocalizations.of(context)!.muteAllVideo),
              onPressed: _onMuteAllVideo,
              style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
                  foregroundColor:
                      MaterialStateProperty.all(_UIColors.blue_337eff)),
            )),
            Center(
              child:
                  Container(height: 24, width: 1, color: _UIColors.colorE9E9E9),
            ),
            Expanded(
                child: TextButton(
              child:
                  Text(NEMeetingUIKitLocalizations.of(context)!.unmuteAllVideo),
              onPressed: unMuteAllVideo2Server,
              style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
                  foregroundColor:
                      MaterialStateProperty.all(_UIColors.blue_337eff)),
            )),
          ],
        ),
      ),
    );
  }

  /// 管理会议成员弹窗下的 全体静音相关操作ui
  Widget buildMuteAllAudioActions() {
    return Visibility(
      visible: !arguments.options.noMuteAllAudio,
      child: Container(
        height: 49,
        color: _UIColors.colorF7F9FBF0,
        child: Row(
          children: <Widget>[
            Expanded(
                child: TextButton(
              child:
                  Text(NEMeetingUIKitLocalizations.of(context)!.muteAudioAll),
              onPressed: _onMuteAllAudio,
              style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
                  foregroundColor:
                      MaterialStateProperty.all(_UIColors.blue_337eff)),
            )),
            Center(
              child:
                  Container(height: 24, width: 1, color: _UIColors.colorE9E9E9),
            ),
            Expanded(
                child: TextButton(
              child:
                  Text(NEMeetingUIKitLocalizations.of(context)!.unMuteAudioAll),
              onPressed: unMuteAllAudio2Server,
              style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
                  foregroundColor:
                      MaterialStateProperty.all(_UIColors.blue_337eff)),
            )),
          ],
        ),
      ),
    );
  }

  void _onMuteAllAudio() {
    trackPeriodicEvent(TrackEventName.muteAllAudio,
        extra: {'meeting_num': roomId});
    DialogUtils.showChildNavigatorDialog(
        context,
        (context) => StatefulBuilder(
              builder: (context, setState) {
                return CupertinoAlertDialog(
                  title: Text(
                      NEMeetingUIKitLocalizations.of(context)!
                          .muteAudioAllDialogTips,
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
                              key: MeetingUIValueKeys.muteAudioAllCheckbox,
                              size: 14,
                              color: allowSelfAudioOn
                                  ? _UIColors.blue_337eff
                                  : _UIColors.colorB3B3B3),
                        ),
                        TextSpan(
                            text: NEMeetingUIKitLocalizations.of(context)!
                                .muteAllAudioTip)
                      ]),
                      style: TextStyle(
                          fontSize: 13, color: _UIColors.color_333333),
                    ),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child:
                          Text(NEMeetingUIKitLocalizations.of(context)!.cancel),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      textStyle: TextStyle(color: _UIColors.color_666666),
                    ),
                    CupertinoDialogAction(
                      key: MeetingUIValueKeys.muteAudioAll,
                      child: Text(NEMeetingUIKitLocalizations.of(context)!
                          .muteAudioAll),
                      onPressed: () {
                        Navigator.of(context).pop();
                        muteAllAudio2Server();
                      },
                      textStyle: TextStyle(color: _UIColors.color_337eff),
                    ),
                  ],
                );
              },
            ));
  }

  void muteAllAudio2Server() {
    lifecycleExecute(rtcController.muteAllParticipantsAudio(allowSelfAudioOn))
        .then((result) {
      if (!mounted || result == null) return;
      if (result.isSuccess()) {
        ToastUtils.showToast(context,
            NEMeetingUIKitLocalizations.of(context)!.muteAllAudioSuccess);
      } else {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.muteAllAudioFail);
      }
    });
  }

  void unMuteAllAudio2Server() {
    trackPeriodicEvent(TrackEventName.unMuteAllAudio,
        extra: {'meeting_num': roomId});
    lifecycleExecute(rtcController.unmuteAllParticipantsAudio()).then((result) {
      if (!mounted || result == null) return;
      if (result.isSuccess()) {
        ToastUtils.showToast(context,
            NEMeetingUIKitLocalizations.of(context)!.unMuteAllAudioSuccess);
      } else {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.unMuteAllAudioFail);
      }
    });
  }

  void _onMuteAllVideo() {
    trackPeriodicEvent(TrackEventName.muteAllVideo,
        extra: {'meeting_num': roomId});
    DialogUtils.showChildNavigatorDialog(
        context,
        (context) => StatefulBuilder(
              builder: (context, setState) {
                return CupertinoAlertDialog(
                  title: Text(
                      NEMeetingUIKitLocalizations.of(context)!
                          .muteVideoAllDialogTips,
                      style: TextStyle(color: Colors.black, fontSize: 17)),
                  content: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        allowSelfVideoOn = !allowSelfVideoOn;
                      });
                    },
                    child: Text.rich(
                      TextSpan(children: [
                        WidgetSpan(
                          child: Icon(Icons.check_box,
                              key: MeetingUIValueKeys.muteVideoAllCheckbox,
                              size: 14,
                              color: allowSelfVideoOn
                                  ? _UIColors.blue_337eff
                                  : _UIColors.colorB3B3B3),
                        ),
                        TextSpan(
                            text: NEMeetingUIKitLocalizations.of(context)!
                                .muteAllVideoTip)
                      ]),
                      style: TextStyle(
                          fontSize: 13, color: _UIColors.color_333333),
                    ),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child:
                          Text(NEMeetingUIKitLocalizations.of(context)!.cancel),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      textStyle: TextStyle(color: _UIColors.color_666666),
                    ),
                    CupertinoDialogAction(
                      child: Text(
                        NEMeetingUIKitLocalizations.of(context)!.muteAllVideo,
                        key: MeetingUIValueKeys.muteVideoAll,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        muteAllVideo2Server();
                      },
                      textStyle: TextStyle(color: _UIColors.color_337eff),
                    ),
                  ],
                );
              },
            ));
  }

  void muteAllVideo2Server() {
    lifecycleExecute(rtcController.muteAllParticipantsVideo(allowSelfVideoOn))
        .then((result) {
      if (!mounted || result == null) return;
      if (result.isSuccess()) {
        ToastUtils.showToast(context,
            NEMeetingUIKitLocalizations.of(context)!.muteAllVideoSuccess);
      } else {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.muteAllVideoFail);
      }
    });
  }

  void unMuteAllVideo2Server() {
    trackPeriodicEvent(TrackEventName.unMuteAllVideo,
        extra: {'meeting_num': roomId});
    lifecycleExecute(rtcController.unmuteAllParticipantsVideo()).then((result) {
      if (!mounted || result == null) return;
      if (result.isSuccess()) {
        ToastUtils.showToast(context,
            NEMeetingUIKitLocalizations.of(context)!.unMuteAllVideoSuccess);
      } else {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.unMuteAllVideoFail);
      }
    });
  }

  Widget title(int userCount, [int maxCount = 0]) {
    return Container(
      height: 48,
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
              side: BorderSide(color: _UIColors.globalBg),
              borderRadius:
                  BorderRadius.only(topLeft: _radius, topRight: _radius))),
      child: Stack(
        children: <Widget>[
          Center(
            child: Text(
              '${NEMeetingUIKitLocalizations.of(context)!.memberlistTitle}($userCount${maxCount > 0 ? '/$maxCount' : ''})',
              style: TextStyle(
                  color: _UIColors.black_333333,
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
                color: _UIColors.color_666666,
                size: 15,
                key: MeetingUIValueKeys.close,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          )
        ],
      ),
    );
  }

  Widget buildMemberItem(NERoomMember user) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(user),
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: _memberItemNick(user),
            ),
            MeetingUIValueKeys.addTextWidgetTest(
                valueKey: ValueKey('${user.tag}'), value: true),
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
              Icon(NEMeetingIconFont.icon_raisehands,
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
            Icon(
                !user.isVideoOn
                    ? NEMeetingIconFont.icon_yx_tv_video_offx
                    : NEMeetingIconFont.icon_yx_tv_video_onx,
                color: !user.isVideoOn ? Colors.red : Color(0xFF49494d),
                size: 20),
            const SizedBox(width: 16),
            SizedBox(
              width: 20,
              height: 20,
              child: buildRoomUserVolumeIndicator(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRoomUserVolumeIndicator(NERoomMember user, [double? opacity]) {
    if (!arguments.audioVolumeStreams.containsKey(user.uuid) ||
        !user.isAudioOn) {
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

  void _onTap(NERoomMember user) {
    final isHost = roomContext.isMySelfHost();
    final isSelf = roomContext.isMySelf(user.uuid);
    final isCoHost = roomContext.isCoHost(user.uuid);
    final isPinned = roomContext.getFocusUuid() == user.uuid;
    final hasScreenSharing =
        roomContext.rtcController.getScreenSharingUserUuid() != null;
    final hasInteract =
        whiteboardController.isDrawWhiteboardEnabledWithUserId(user.uuid);
    final isCurrentSharingWhiteboard =
        whiteboardController.isWhiteboardSharing(user.uuid);
    final isSelfSharingWhiteboard = whiteboardController.isSharingWhiteboard();

    final actions = <Widget>[
      if (!arguments.options.noRename && isSelf)
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.rename, user,
            MemberActionType.updateNick),
      if (isSelfHostOrCoHost() && user.isRaisingHand)
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.handsUpDown,
            user, MemberActionType.hostRejectHandsUp),
      if (isSelfHostOrCoHost() && user.isAudioOn)
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.muteAudio,
            user, MemberActionType.hostMuteAudio),
      if (isSelfHostOrCoHost() && !user.isAudioOn)
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.unMuteAudio,
            user, MemberActionType.hostUnMuteAudio),
      if (isSelfHostOrCoHost() && user.isVideoOn)
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.muteVideo,
            user, MemberActionType.hostMuteVideo),
      if (isSelfHostOrCoHost() && !user.isVideoOn)
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.unMuteVideo,
            user, MemberActionType.hostUnMuteVideo),
      if (isSelfHostOrCoHost() && (!user.isVideoOn || !user.isAudioOn))
        buildActionSheet(
            NEMeetingUIKitLocalizations.of(context)!.unmuteAudioAndVideo,
            user,
            MemberActionType.hostUnmuteAudioAndVideo),
      if (isSelfHostOrCoHost() && user.isVideoOn && user.isAudioOn)
        buildActionSheet(
            NEMeetingUIKitLocalizations.of(context)!.muteAudioAndVideo,
            user,
            MemberActionType.hostMuteAudioAndVideo),
      if (isSelfHostOrCoHost() && !hasScreenSharing && !isPinned)
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.focusVideo,
            user, MemberActionType.setFocusVideo),
      if (isSelfHostOrCoHost() && !hasScreenSharing && isPinned)
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.unFocusVideo,
            user, MemberActionType.cancelFocusVideo),
      if (isHost && !isSelf && !isCoHost && user.clientType != NEClientType.sip)
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.makeCoHost,
            user, MemberActionType.makeCoHost),
      if (isHost && !isSelf && isCoHost && user.clientType != NEClientType.sip)
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.cancelCoHost,
            user, MemberActionType.cancelCoHost),
      if (isHost &&
          !isSelf &&
          user.clientType !=
              NEClientType
                  .sip) // todo sunjian 暂时去掉   user.clientType != ClientType.sip
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.changeHost,
            user, MemberActionType.changeHost),
      if (isSelfHostOrCoHost() && user.isSharingScreen && !isSelf)
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.unScreenShare,
            user, MemberActionType.hostStopScreenShare),
      if (isSelfHostOrCoHost() && isCurrentSharingWhiteboard)
        buildActionSheet(
            NEMeetingUIKitLocalizations.of(context)!.closeWhiteBoard,
            user,
            MemberActionType.hostStopWhiteBoardShare),
      if (!isSelf && isSelfSharingWhiteboard && hasInteract)
        buildActionSheet(
            NEMeetingUIKitLocalizations.of(context)!.undoWhiteBoardInteract,
            user,
            MemberActionType.undoMemberWhiteboardInteraction),
      if (!isSelf && isSelfSharingWhiteboard && !hasInteract)
        buildActionSheet(
            NEMeetingUIKitLocalizations.of(context)!.whiteBoardInteract,
            user,
            MemberActionType.awardedMemberWhiteboardInteraction),
      if (isHost && !isSelf)
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.remove, user,
            MemberActionType.removeMember),
      if (isSelfCoHost() && !isSelf && !roomContext.isHost(user.uuid))
        buildActionSheet(NEMeetingUIKitLocalizations.of(context)!.remove, user,
            MemberActionType.removeMember),
    ];
    if (actions.isEmpty) return;
    moreDialogBindingMember = user.uuid;
    moreDialogIsShow = true;
    DialogUtils.showChildNavigatorPopup<_ActionData>(
        context,
        (context) => CupertinoActionSheet(
              title: Text(
                '${user.name}',
                style: TextStyle(color: _UIColors.grey_8F8F8F, fontSize: 13),
              ),
              actions: actions,
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: buildPopupText(
                    NEMeetingUIKitLocalizations.of(context)!.cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )).then<void>((_ActionData? value) {
      if (value != null && value.action.index != -1) {
        handleAction(value.action, value.user);
      }
    }).then((value) {
      moreDialogIsShow = false;
      moreDialogBindingMember = null;
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
      case MemberActionType.changeHost:
        changeHost(user);
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
          if (result.isSuccess()) {
            ToastUtils.showToast(context,
                '${roomContext.getMember(user.uuid)?.name}${NEMeetingUIKitLocalizations.of(context)!.userHasBeenAssignCoHostRole}');
          } else {
            if (result.code == NEErrorCode.overRoleLimitCount) {
              /// 达到分配角色的上限
              showToast(
                  NEMeetingUIKitLocalizations.of(context)!.overRoleLimitCount);
            }
            Alog.i(
                tag: _tag,
                moduleName: _moduleName,
                content:
                    'makeCoHost code: ${result.code}, msg:${result.msg ?? ''}');
          }
        });
        break;
      case MemberActionType.cancelCoHost:
        roomContext.cancelCoHost(user.uuid).then((result) {
          if (result.isSuccess()) {
            ToastUtils.showToast(context,
                '${roomContext.getMember(user.uuid)?.name}${NEMeetingUIKitLocalizations.of(context)!.userHasBeenRevokeCoHostRole}');
          } else {
            Alog.i(
                tag: _tag,
                moduleName: _moduleName,
                content:
                    'cancelCoHost code: ${result.code}, msg:${result.msg ?? ''}');
          }
        });
        break;
    }
    setState(() {});
  }

  Future<void> _hostStopWhiteBoard(NERoomMember member) async {
    var result =
        await whiteboardController.stopMemberWhiteboardShare(member.uuid);
    if (!result.isSuccess() && mounted) {
      ToastUtils.showToast(
          context,
          result.msg ??
              NEMeetingUIKitLocalizations.of(context)!.whiteBoardShareStopFail);
    }
  }

  Future<void> _hostStopScreenShare(NERoomMember user) async {
    await lifecycleExecute(
        roomContext.rtcController.stopMemberScreenShare(user.uuid)
            // .stopParticipantScreenShare(user.uuid)
            .then((NEResult? result) {
      if (!mounted || result == null) return;
      if (!result.isSuccess()) {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.screenShareStopFail);
      }
    }));
  }

  Future<void> _awardedWhiteboardInteraction(NERoomMember user) async {
    var result = await whiteboardController.grantPermission(user.uuid);
    if (!result.isSuccess() && mounted) {
      ToastUtils.showToast(
          context,
          result.msg ??
              NEMeetingUIKitLocalizations.of(context)!.whiteBoardInteractFail);
    }
  }

  Future<void> _undoWhiteboardInteraction(NERoomMember user) async {
    var result = await whiteboardController.revokePermission(user.uuid);
    if (!result.isSuccess() && mounted) {
      ToastUtils.showToast(
          context,
          result.msg ??
              NEMeetingUIKitLocalizations.of(context)!
                  .undoWhiteBoardInteractFail);
    }
  }

  void hostRejectHandsUp(NERoomMember user) {
    trackPeriodicEvent(TrackEventName.handsUpDown,
        extra: {'value': 0, 'member_uid': user.uuid, 'meeting_num': roomId});
    lifecycleExecute(roomContext.lowerUserHand(user.uuid))
        .then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.handsUpDownFail);
      }
    });
  }

  void removeMember(NERoomMember user) {
    trackPeriodicEvent(TrackEventName.removeMember,
        extra: {'member_uid': user.uuid, 'meeting_num': roomId});
    if (roomContext.isMySelf(user.uuid)) {
      ToastUtils.showToast(
          context, NEMeetingUIKitLocalizations.of(context)!.cannotRemoveSelf);
      return;
    }
    showDialog(
        context: context,
        builder: (_) {
          return NEMeetingUIKitLocalizationsScope(
              builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(NEMeetingUIKitLocalizations.of(context)!.remove),
              content: Text(
                  NEMeetingUIKitLocalizations.of(context)!.removeTips +
                      '${user.name}?'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(NEMeetingUIKitLocalizations.of(context)!.no),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text(NEMeetingUIKitLocalizations.of(context)!.yes),
                  onPressed: () {
                    Navigator.of(context).pop();
                    removeMember2Server(user);
                  },
                ),
              ],
            );
          });
        });
  }

  void removeMember2Server(NERoomMember user) {
    lifecycleExecute(roomContext.kickMemberOut(user.uuid))
        .then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.removeMemberFail);
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
          ? rtcController.muteMyAudioAndAdjustVolume()
          : rtcController.unmuteMyAudioWithCheckPermission(
              context, arguments.meetingTitle);
      return;
    }
    var future = mute
        ? roomContext.rtcController.muteMemberAudio(user.uuid)
        : roomContext.rtcController.inviteParticipantTurnOnAudio(user.uuid);
    lifecycleExecute(future).then((NEResult? result) {
      if (result != null && mounted && !result.isSuccess()) {
        ToastUtils.showToast(
            context,
            result.msg ??
                (mute
                    ? NEMeetingUIKitLocalizations.of(context)!.muteAudioFail
                    : NEMeetingUIKitLocalizations.of(context)!
                        .unMuteAudioFail));
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
        ToastUtils.showToast(
            context,
            result.msg ??
                (mute
                    ? NEMeetingUIKitLocalizations.of(context)!.muteVideoFail
                    : NEMeetingUIKitLocalizations.of(context)!
                        .unMuteVideoFail));
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
          ? rtcController.muteMyAudioAndAdjustVolume()
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
          ToastUtils.showToast(
              context,
              result.msg ??
                  '${(mute ? NEMeetingUIKitLocalizations.of(context)!.muteAudioAndVideo : NEMeetingUIKitLocalizations.of(context)!.unmuteAudioAndVideo)}${NEMeetingUIKitLocalizations.of(context)!.fail}');
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
        ToastUtils.showToast(
            context,
            result.msg ??
                (focus
                    ? NEMeetingUIKitLocalizations.of(context)!.focusVideoFail
                    : NEMeetingUIKitLocalizations.of(context)!
                        .unFocusVideoFail));
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
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(NEMeetingUIKitLocalizations.of(context)!.changeHost),
              content: Text(
                  '${NEMeetingUIKitLocalizations.of(context)!.changeHostTips}${user.name}?'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(NEMeetingUIKitLocalizations.of(context)!.no),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text(NEMeetingUIKitLocalizations.of(context)!.yes),
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

  void changeHost2Server(NERoomMember user) {
    if (roomContext.getMember(user.uuid) == null) {
      /// 执行移交主持人时，check 用户是否还在会议中，不在的话直接提示 移交主持人失败
      ToastUtils.showToast(
          context, NEMeetingUIKitLocalizations.of(context)!.changeHostFail);
      return;
    }
    lifecycleExecute(roomContext.handOverHost(user.uuid))
        .then((NEResult? result) {
      if (mounted && result != null && !result.isSuccess()) {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.changeHostFail);
      }
    });
  }

  Widget _memberItemNick(NERoomMember user) {
    var subtitle = <String>[];
    if (roomContext.isHost(user.uuid)) {
      subtitle.add(NEMeetingUIKitLocalizations.of(context)!.host);
    }
    if (roomContext.isCoHost(user.uuid)) {
      subtitle.add(NEMeetingUIKitLocalizations.of(context)!.coHost);
    }
    if (roomContext.isMySelf(user.uuid)) {
      subtitle.add(NEMeetingUIKitLocalizations.of(context)!.me);
    }
    if (user.clientType == NEClientType.sip) {
      subtitle.add(NEMeetingUIKitLocalizations.of(context)!.sipTip);
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

  final TextEditingController _textFieldController = TextEditingController();
  void _rename(NERoomMember user) {
    _textFieldController.text = user.name;
    _textFieldController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textFieldController.text.length));
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (_, setState) =>
              NEMeetingUIKitLocalizationsScope(builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(NEMeetingUIKitLocalizations.of(context)!.rename),
              content: Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CupertinoTextField(
                        key: MeetingUIValueKeys.rename,
                        autofocus: true,
                        controller: _textFieldController,
                        placeholder:
                            NEMeetingUIKitLocalizations.of(context)!.renameTips,
                        placeholderStyle: const TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.placeholderText,
                        ),
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _nicknameValid()
                            ? () => _doRename(context, user)
                            : null,
                        clearButtonMode: OverlayVisibilityMode.editing,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20),
                        ],
                      ),
                    ],
                  )),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(NEMeetingUIKitLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text(NEMeetingUIKitLocalizations.of(context)!.done),
                  onPressed:
                      _nicknameValid() ? () => _doRename(context, user) : null,
                ),
              ],
            );
          }),
        );
      },
    );
  }

  bool _nicknameValid() =>
      _textFieldController.text.isNotBlank &&
      _textFieldController.text.isNotEmpty;

  void _doRename(BuildContext dialogContext, NERoomMember user) {
    final nickname = _textFieldController.text;

    if (nickname == user.name) return;

    Navigator.of(dialogContext).pop();

    lifecycleExecute(roomContext.changeMyName(nickname))
        .then((NEResult? result) {
      if (mounted && result != null) {
        if (result.isSuccess()) {
          ToastUtils.showToast(
              context, NEMeetingUIKitLocalizations.of(context)!.renameSuccess);
        } else {
          ToastUtils.showToast(
              context,
              result.msg ??
                  NEMeetingUIKitLocalizations.of(context)!.renameFail);
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
  changeHost,
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
}
