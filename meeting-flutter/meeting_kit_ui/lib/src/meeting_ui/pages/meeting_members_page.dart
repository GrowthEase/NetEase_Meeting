// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 参会者界面
class MeetMemberPage extends StatefulWidget {
  final MembersArguments arguments;
  final _MembersPageType? initialPageType;

  MeetMemberPage(this.arguments, {this.initialPageType});

  @override
  State<StatefulWidget> createState() {
    return MeetMemberPageState(arguments, initialPageType);
  }
}

class MeetMemberPageState extends LifecycleBaseState<MeetMemberPage>
    with
        EventTrackMixin,
        MeetingKitLocalizationsMixin,
        MeetingUIStateScope,
        _AloggerMixin {
  MeetMemberPageState(this.arguments, this.initialPageType);

  final MembersArguments arguments;
  final _MembersPageType? initialPageType;

  static const _radius = Radius.circular(8);

  final FocusNode _focusNode = FocusNode();

  late TextEditingController _searchTextEditingController;

  bool allowSelfAudioOn = false;
  bool allowSelfVideoOn = false;

  late final NERoomContext roomContext;
  late final NERoomWhiteboardController whiteboardController;
  late final NERoomRtcController rtcController;
  late final WaitingRoomManager waitingRoomManager;

  late final String roomId;

  late final int maxCount;

  late final NERoomEventCallback roomEventCallback;

  final _pageIndex = ValueNotifier<int>(0);
  final _pageController = PageController(initialPage: 0);
  late PageDataManager pageDataManager;

  late void Function() _resetUnreadMemberCount = () {
    if (pageDataManager.pages[_pageIndex.value].type ==
        _MembersPageType.waitingRoom) {
      waitingRoomManager.resetUnreadMemberCount();
    }
  };

  void onMemberRoleChanged(
      NERoomMember member, NERoomRole before, NERoomRole after) {
    if (roomContext.isMySelf(member.uuid)) {
      pageDataManager.isHostOrCoHost = isSelfHostOrCoHost();
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
    pageDataManager = PageDataManager(isSelfHostOrCoHost());
    roomContext.addEventCallback(roomEventCallback = NERoomEventCallback(
      memberRoleChanged: onMemberRoleChanged,
    ));
    whiteboardController = roomContext.whiteboardController;
    rtcController = roomContext.rtcController;
    waitingRoomManager = arguments.waitingRoomManager;
    roomId = roomContext.roomUuid;
    maxCount = parseMaxCountByContract(roomContext.extraData);
    _searchTextEditingController = TextEditingController()
      ..addListener(() {
        pageDataManager.searchKey = _searchTextEditingController.text;
      });
    lifecycleListen(arguments.roomInfoUpdatedEventStream, (_) {
      setState(() {
        pageDataManager.inMeeting.userList = roomContext.getAllUsers().toList()
          ..sort(compareUser);
      });
    });
    lifecycleListen(waitingRoomManager.userListChanged, (_) {
      setState(() {
        pageDataManager.waitingRoom.userList =
            waitingRoomManager.userList.toList();
      });
    });
    pageDataManager.inMeeting.userList = roomContext.getAllUsers().toList()
      ..sort(compareUser);
    pageDataManager.waitingRoom.userList = waitingRoomManager.userList.toList();

    waitingRoomManager.unreadMemberCountListenable
        .addListener(_resetUnreadMemberCount);
    _pageIndex.addListener(_resetUnreadMemberCount);

    /// 传入初始页面类型
    final index = pageDataManager.pages
        .firstIndexOf((page) => page.type == initialPageType);
    if (index != -1) {
      _jumpToPage(index);
    }
    pageDataManager.addListener(() {
      final pages = pageDataManager.pages;
      final index = _pageIndex.value.clamp(0, pages.length - 1);
      _pageIndex.value = index;
      _pageController.jumpToPage(index);
    });
  }

  bool get isWaitingRoomEnabled =>
      waitingRoomManager.waitingRoomEnabledOnEntryListenable.value;

  void _jumpToPage(int index) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _pageIndex.value = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchTextEditingController.dispose();
    roomContext.removeEventCallback(roomEventCallback);
    waitingRoomManager.unreadMemberCountListenable
        .removeListener(_resetUnreadMemberCount);
    _pageIndex.removeListener(_resetUnreadMemberCount);
    pageDataManager.dispose();
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
          child: SafeArea(
            top: false,
            child: Listener(
              onPointerDown: (_) {
                if (_focusNode.hasFocus) {
                  _focusNode.unfocus();
                }
              },
              child: ListenableBuilder(
                listenable: pageDataManager,
                builder: (context, child) {
                  return buildContent();
                },
              ),
            ),
          ),
        ),
      ),
      onWillPop: () async {
        return onWillPop();
      },
    );
  }

  Widget buildContent() {
    return Column(
      children: <Widget>[
        title(maxCount),
        buildSearch(),
        buildDivider(),
        if (pageDataManager.shouldShowTabBar) _buildPageSelector(),
        if (pageDataManager.shouldShowTabBar) buildDivider(),
        Expanded(
            child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            _pageIndex.value = index;
          },
          children: pageDataManager.pages.map((page) {
            if (page.type == _MembersPageType.inMeeting) {
              return _buildInMeetingPage(
                  page.filteredUserList as List<NERoomMember>);
            } else if (page.type == _MembersPageType.waitingRoom) {
              return WaitingRoomMemberList(waitingRoomManager,
                  page.filteredUserList as List<NEWaitingRoomMember>);
            } else {
              return SizedBox.shrink();
            }
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildInMeetingPage(List<NERoomMember> userList) {
    return Column(
      children: [
        Expanded(
          child: buildMembers(userList),
        ),
        if (isSelfHostOrCoHost()) ...buildHost(),
      ],
    );
  }

  Widget _buildPageSelector() {
    return Container(
      height: 38,
      margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
      decoration: BoxDecoration(
        color: _UIColors.colorEEF0F3,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _pageIndex,
        builder: (context, value, child) {
          final pages = pageDataManager.pages;
          return Row(
            children: [
              for (int i = 0; i < pages.length; i++)
                Expanded(
                    child: GestureDetector(
                        onTap: () => _onPageSelect(i, pages[i].type),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: value == i
                                ? _UIColors.color_337eff
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SafeValueListenableBuilder(
                              valueListenable:
                                  getHintCountListenable(pages[i].type),
                              builder: (BuildContext context,
                                  int unreadMemberCount, _) {
                                return Stack(
                                  children: [
                                    Container(
                                        child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          getSubject(pages[i].type),
                                          style: TextStyle(
                                            color: value == i
                                                ? _UIColors.white
                                                : _UIColors.color_333333,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        _buildMemberSizeWidget(
                                            pages[i], value == i),
                                      ],
                                    )),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Visibility(
                                        visible:
                                            unreadMemberCount > 0 && value != i,
                                        child: ClipOval(
                                            child: Container(
                                                height: 6,
                                                width: 6,
                                                decoration: BoxDecoration(
                                                    color: _UIColors
                                                        .colorFE3B30))),
                                      ),
                                    )
                                  ],
                                );
                              }),
                        )))
            ],
          );
        },
      ),
    );
  }

  void _onPageSelect(int index, _MembersPageType type) {
    _pageIndex.value = index;
    _pageController.jumpToPage(index);
  }

  ValueListenable<int> getHintCountListenable(_MembersPageType type) {
    switch (type) {
      case _MembersPageType.inMeeting:
        return ValueNotifier(0);
      case _MembersPageType.waitingRoom:
        return waitingRoomManager.unreadMemberCountListenable;
      case _MembersPageType.notYetJoined:
        return ValueNotifier(0);
    }
  }

  String getSubject(_MembersPageType type) {
    switch (type) {
      case _MembersPageType.inMeeting:
        return meetingUiLocalizations.participantInMeeting;
      case _MembersPageType.waitingRoom:
        return meetingUiLocalizations.waitingRoom;
      case _MembersPageType.notYetJoined:
        return meetingUiLocalizations.participantNotJoined;
    }
  }

  Widget _buildMemberSizeWidget(_PageData pageData, bool isCurrent) {
    final textStyle = TextStyle(
      color: isCurrent ? _UIColors.white : _UIColors.color676B73,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
    );
    Widget Function(int value) buildRoomUserCount = (count) => count > 0
        ? Text(
            '($count)',
            style: textStyle,
          )
        : SizedBox.shrink();
    return buildRoomUserCount.call(pageData.userCount);
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
            decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
                hintText: meetingUiLocalizations.participantSearchMember,
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
      buildMuteAllAudioActions(),
      buildDivider(isShow: !arguments.options.noMuteAllVideo),
      buildMuteAllVideoActions(),
    ];
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
      child: Container(
        height: 49,
        color: _UIColors.colorF7F9FBF0,
        child: Row(
          children: <Widget>[
            Expanded(
                child: TextButton(
              child: Text(meetingUiLocalizations.participantTurnOffVideos),
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
              child: Text(meetingUiLocalizations.participantTurnOnVideos),
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
              child: Text(meetingUiLocalizations.participantMuteAudioAll),
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
              child: Text(meetingUiLocalizations.participantUnmuteAll),
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

  Widget title([int maxCount = 0]) {
    var title = isSelfHostOrCoHost()
        ? meetingUiLocalizations.participantAttendees
        : meetingUiLocalizations.participants;
    if (!pageDataManager.shouldShowTabBar) {
      title +=
          '(${pageDataManager.inMeeting.userCount}${maxCount > 0 ? '/$maxCount' : ''})';
    }

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
              title,
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
              Icon(
                  key: MeetingUIValueKeys.handsUpIcon,
                  NEMeetingIconFont.icon_raisehands,
                  color: _UIColors.color_337eff,
                  size: 20),
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

  List<Widget> getInMeetingUserActions(NERoomMember user) {
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
    final hasInteract =
        whiteboardController.isDrawWhiteboardEnabledWithUserId(user.uuid);
    final isCurrentSharingWhiteboard =
        whiteboardController.isWhiteboardSharing(user.uuid);
    final isSelfSharingWhiteboard = whiteboardController.isSharingWhiteboard();

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
        buildActionSheet(meetingUiLocalizations.participantTurnOnAudioAndVideo,
            user, MemberActionType.hostUnmuteAudioAndVideo),
      if (isSelfHostOrCoHost() &&
          user.isVideoOn &&
          user.isAudioOn &&
          user.isAudioConnected)
        buildActionSheet(meetingUiLocalizations.participantTurnOffAudioAndVideo,
            user, MemberActionType.hostMuteAudioAndVideo),
      if (isSelfHostOrCoHost() && !hasScreenSharing && !isPinned)
        buildActionSheet(meetingUiLocalizations.participantAssignActiveSpeaker,
            user, MemberActionType.setFocusVideo),
      if (isSelfHostOrCoHost() && !hasScreenSharing && isPinned)
        buildActionSheet(
            meetingUiLocalizations.participantUnassignActiveSpeaker,
            user,
            MemberActionType.cancelFocusVideo),
      if (isSelfHost &&
          !isSelf &&
          !isUserCoHost &&
          user.clientType != NEClientType.sip)
        buildActionSheet(meetingUiLocalizations.participantAssignCoHost, user,
            MemberActionType.makeCoHost),
      if (isSelfHost &&
          !isSelf &&
          isUserCoHost &&
          user.clientType != NEClientType.sip)
        buildActionSheet(meetingUiLocalizations.participantUnassignCoHost, user,
            MemberActionType.cancelCoHost),
      if (isSelfHost && !isSelf && user.clientType != NEClientType.sip)
        buildActionSheet(meetingUiLocalizations.participantTransferHost, user,
            MemberActionType.changeHost),
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
      if ((isSelfHost || isSelfCoHost()) &&
          !isSelf &&
          !isUserHost &&
          !isUserCoHost &&
          waitingRoomManager.waitingRoomEnabledOnEntryListenable.value)
        buildActionSheet(meetingUiLocalizations.participantPutInWaitingRoom,
            user, MemberActionType.putInWaitingRoom),
      if (isSelfHost && !isSelf)
        buildActionSheet(meetingUiLocalizations.participantRemove, user,
            MemberActionType.removeMember),
      if (isSelfCoHost() && !isSelf && !isUserHost)
        buildActionSheet(meetingUiLocalizations.participantRemove, user,
            MemberActionType.removeMember),
    ];
  }

  void handleInMeetingMemberItemClick(NERoomMember user) {
    final actions = getInMeetingUserActions(user);
    if (actions.isEmpty) return;
    DialogUtils.showChildNavigatorPopup<_ActionData>(
      context,
      (context) {
        return StreamBuilder(
          stream: arguments.roomInfoUpdatedEventStream,
          builder: (context, _) {
            final actions = getInMeetingUserActions(user);
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
          commonLogger.i('makeCoHost result: $result');
          if (result.isSuccess()) {
            final member = roomContext.getMember(user.uuid);
            if (member != null) {
              showToast(
                '${member.name}${meetingUiLocalizations.participantAssignedCoHost}',
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
    }
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

  void removeMember(NERoomMember user) {
    trackPeriodicEvent(TrackEventName.removeMember,
        extra: {'member_uid': user.uuid, 'meeting_num': roomId});
    if (roomContext.isMySelf(user.uuid)) {
      showToast(
        meetingUiLocalizations.participantCannotRemoveSelf,
      );
      return;
    }
    showDialog(
        context: context,
        builder: (_) {
          final child =
              NEMeetingUIKitLocalizationsScope(builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(meetingUiLocalizations.participantRemove),
              content: Text(meetingUiLocalizations.participantRemoveConfirm +
                  '${user.name}?'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(meetingUiLocalizations.globalNo),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text(meetingUiLocalizations.globalYes),
                  onPressed: () {
                    Navigator.of(context).pop();
                    removeMember2Server(user);
                  },
                ),
              ],
            );
          });
          return AutoPopScope(
            listenable: arguments.isMySelfManagerListenable,
            onWillAutoPop: (_) {
              return !arguments.isMySelfManagerListenable.value;
            },
            child: child,
          );
        });
  }

  void removeMember2Server(NERoomMember user) {
    lifecycleExecute(roomContext.kickMemberOut(user.uuid))
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
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(meetingUiLocalizations.participantTransferHost),
              content: Text(meetingUiLocalizations
                  .participantTransferHostConfirm(user.name)),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(meetingUiLocalizations.globalNo),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text(meetingUiLocalizations.globalYes),
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
    if (roomContext.isMySelf(user.uuid)) {
      subtitle.add(meetingUiLocalizations.participantMe);
    }
    if (user.clientType == NEClientType.sip) {
      subtitle.add(meetingUiLocalizations.meetingSip);
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
  putInWaitingRoom,
}

class WaitingRoomMemberList extends StatefulWidget {
  final WaitingRoomManager waitingRoomManager;
  final List<NEWaitingRoomMember> userList;

  const WaitingRoomMemberList(this.waitingRoomManager, this.userList,
      {super.key});

  @override
  State<WaitingRoomMemberList> createState() => _WaitingRoomMemberListState();
}

class _WaitingRoomMemberListState extends State<WaitingRoomMemberList>
    with MeetingKitLocalizationsMixin {
  StreamController? oneMinuteTick;
  StreamSubscription? oneMinuteTickSubscription;
  final userAutoPopListenable = <String, ValueNotifier<bool>>{};

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
      child: list,
      onNotification: (ScrollNotification notification) {
        // print('''OnScrollNotification:
        // type: ${notification.runtimeType},
        // pixels: ${notification.metrics.pixels},
        // minScrollExtent: ${notification.metrics.minScrollExtent},
        // maxScrollExtent: ${notification.metrics.maxScrollExtent},
        // viewportDimension: ${notification.metrics.viewportDimension},
        // atEdge: ${notification.metrics.atEdge},
        // outOfRange: ${notification.metrics.outOfRange},
        // extentBefore: ${notification.metrics.extentBefore},
        // extentInside: ${notification.metrics.extentInside},
        // extentAfter: ${notification.metrics.extentAfter},
        // ''');
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
                expelMember(user.uuid);
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
      buildActionSheet(meetingUiLocalizations.participantRemove, user,
          WaitingRoomMemberActionType.expel),
      buildActionSheet(meetingUiLocalizations.participantRename, user,
          WaitingRoomMemberActionType.rename),
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
        expelMember(action.member.uuid);
        break;
      case WaitingRoomMemberActionType.admit:
        admitMember(action.member.uuid);
        break;
      case WaitingRoomMemberActionType.rename:
        renameMember(action.member.uuid, action.member.name);
        break;
    }
  }

  void admitMember(String uuid) {
    widget.waitingRoomManager.admitMember(uuid);
  }

  void expelMember(String uuid) async {
    final result = await showConfirmDialogWithCheckbox(
      title: meetingUiLocalizations.participantExpelWaitingMemberDialogTitle,
      checkboxMessage:
          meetingUiLocalizations.participantDisallowMemberRejoinMeeting,
      cancelLabel: meetingUiLocalizations.globalCancel,
      okLabel: meetingUiLocalizations.participantRemove,
      contentWrapperBuilder: (child) {
        return AutoPopScope(
          listenable: userAutoPopListenable.putIfAbsent(
              uuid, () => ValueNotifier(false)),
          child: child,
        );
      },
    );
    if (!mounted || result == null) return;
    widget.waitingRoomManager.expelMember(uuid, disallowRejoin: result.checked);
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
}

class WaitingRoomMemberAction {
  final NEWaitingRoomMember member;
  final WaitingRoomMemberActionType action;

  WaitingRoomMemberAction(this.member, this.action);
}

enum WaitingRoomMemberActionType {
  expel,
  admit,
  rename,
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

enum _MembersPageType { inMeeting, waitingRoom, notYetJoined }

class _PageData<T> extends ChangeNotifier {
  final _MembersPageType type;
  final bool Function(T t, String searchKey) filter;

  _PageData(this.type, this.filter);

  List<T>? _userList;
  List<T>? _filteredUserList;
  set userList(List<T> value) {
    _userList = value;
    _filteredUserList = null;
    notifyListeners();
  }

  List<T> get filteredUserList {
    if (_filteredUserList == null) {
      _filteredUserList = _userList?.where((element) {
        return _searchKey == null || filter(element, _searchKey!);
      }).toList();
    }
    return _filteredUserList ?? [];
  }

  int get userCount => _userList?.length ?? 0;

  bool get hasData => _userList?.isNotEmpty ?? false;

  String? _searchKey;
  set searchKey(String? text) {
    _searchKey = text;
    _filteredUserList = null;
    notifyListeners();
  }
}

class PageDataManager extends ChangeNotifier {
  final inMeeting = _PageData<NERoomMember>(
    _MembersPageType.inMeeting,
    (user, searchKey) {
      return user.name.contains(searchKey);
    },
  );

  final waitingRoom = _PageData<NEWaitingRoomMember>(
    _MembersPageType.waitingRoom,
    (user, searchKey) {
      return user.name.contains(searchKey);
    },
  );

  bool _isHostOrCoHost;

  PageDataManager(this._isHostOrCoHost) {
    Listenable.merge([inMeeting, waitingRoom]).addListener(() {
      notifyListeners();
    });
  }

  set isHostOrCoHost(bool value) {
    if (_isHostOrCoHost != value) {
      _isHostOrCoHost = value;
      notifyListeners();
    }
  }

  List<_PageData> get pages => [
        if (inMeeting.hasData) inMeeting,
        if (waitingRoom.hasData && _isHostOrCoHost) waitingRoom,
      ];

  set searchKey(String? text) {
    inMeeting.searchKey = text;
    waitingRoom.searchKey = text;
  }

  bool get shouldShowTabBar => pages.length > 1;
}
