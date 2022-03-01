// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

/// 遥控器
class ControlMeetingPage extends StatefulWidget {
  final ControlMeetingArguments arguments;

  ControlMeetingPage(this.arguments);

  @override
  State<StatefulWidget> createState() {
    return _ControlMeetingPageState(arguments);
  }
}

class _ControlMeetingPageState extends ControlBaseState<ControlMeetingPage> {
  static const  _tag = 'ControlMeetingPage';
  static const int requestIdPairInMeeting = 1;
  static const int requestIdCreateOrJoinSuccess = 2;
  static const int requestIdMemberChange = 3;
  static const int requestIdUserJoin = 4;
  static const int requestIdAllMuteAudio = 5;
  static const int requestIdChangeHost = 6;

  static const meetingCloseBySelf = 0;
  static const meetingCloseByMaster = 1;
  static const removedByMaster = 2;
  bool isJoining = true;
  StreamSubscription<MeetingAction>? subscription;
  StreamSubscription<dynamic>? _memberChangeSubscription;
  bool isSharkHandDialogShow = false;
  final MembersDataSource _membersDataSource = MembersDataSource.empty();

  /// 显示逻辑，有焦点显示焦点， 否则显示活跃， 否则显示host，否则显示自己
  String? focusAccountId, hostAccountId, activeUId, bigUId;

  MeetingInfo? _meetingInfo;

  /// userId---> member
  Map<String, InMeetingMemberInfo> uid2Members = <String, InMeetingMemberInfo>{};

  Map<int, InMeetingMemberInfo> roomUid2Members = <int, InMeetingMemberInfo>{};

  final SessionInfo _sessionInfo = SessionInfo();

  int selfAvRoomUid = 0;

  ///防止弹出多个dialog
  bool _isShowOpenMicroDialog = false;

  final ControlMeetingArguments arguments;

  _ControlMeetingPageState(this.arguments);

  Iterable<NEMeetingMenuItem> get _fullMenuItemList =>
      arguments.injectedToolbarMenuItems.followedBy(_fullMoreMenuItemList);

  Iterable<NEMeetingMenuItem> get _fullMoreMenuItemList =>
      ControlInternalMenuItems.dynamicFeatureMenuItemList.followedBy(arguments.injectedMoreMenuItems);

  bool _willMoreMenuShow() => _fullMoreMenuItemList.any(shouldShowMenu);

  bool _isMenuItemShowing(int itemId) =>
      _fullMenuItemList.any((element) => element.itemId == itemId && shouldShowMenu(element));

  @override
  void initState() {
    super.initState();
    _registerOnlineStatus();
    _registerTVControlListener();
    _memberChangeSubscription = _membersDataSource.stream.listen((dynamic dataSource) {
      setState(() {});
    });

    var showType = arguments.tvStatus?.showType ?? showTypePresenter;
    Store.value<ShowTypeModel>(context, isListen: false).reset(showType, false);
    fetchMember(requestIdCreateOrJoinSuccess);
    if (TextUtils.nonEmptyEquals(arguments.fromRoute, _PageName.controlHome)) {
      isJoining = false;
      fetchMember(requestIdPairInMeeting);
    }
  }

  void _showAudioAllMuteToast() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (arguments.meetingInfo.audioAllMute == audioAllMute && !isHost()) {
        arguments.audioMute = true;
        ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!,
            _Strings.meetingHostMuteAudio);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isJoining ? buildJoiningUI() : buildControlPage();
  }

  Widget buildControlPage() {
    return WillPopScope(
      child: Scaffold(
          backgroundColor: UIColors.globalBg,
          appBar: AppBar(
              title: Text(
                _Strings.tvControl,
                style: TextStyle(color: UIColors.color_222222, fontSize: 17),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0.0,
              brightness: Brightness.light,
              leading: IconButton(
                icon: const Icon(
                  NEMeetingIconFont.icon_yx_returnx,
                  size: 18,
                  color: UIColors.black_333333,
                ),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              )),
          body: SafeArea(child: buildBody())),
      onWillPop: () {
        _exit();
        return Future.value(false);
      },
    );
  }

  @override
  Widget buildBody() {
    return Container(
      color: UIColors.globalBg,
      child: Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: UIColors.white,
            boxShadow: [
              BoxShadow(
                color: UIColors.color_19242744,
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          child: Column(
            children: [
              Container(
                height: 44,
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.only(top: 6),
                  child: Text(
                    '${_Strings.tvControlTitlePrefix}${getMeetId().toMeetingIdFormat()}',
                    key: ControllerMeetingCoreValueKey.meetingId,
                    style: TextStyle(fontSize: 14, color: UIColors.black_333333),
                  ),
                ),
              ),
              Divider(
                thickness: 1,
                color: UIColors.globalBg,
              ),
              buildMeetBtns(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    buildStopBtn(),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                alignment: Alignment.center,
                child: Text(
                  arguments.tvStatus?.tvNick ?? arguments.tvStatus?.nick ?? '',
                  style: TextStyle(fontSize: 14, color: UIColors.color_666666),
                ),
              ),
            ],
          )),
    );
  }

  /// 加入中状态
  Widget buildJoiningUI() {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.clamp,
              colors: [UIColors.grey_292933, UIColors.grey_1E1E25])),
      child: Column(
        children: <Widget>[
          Spacer(),
          Image.asset(NEMeetingImages.meetingJoin, package: NEMeetingImages.package),
          SizedBox(
            height: 16,
          ),
          Text(
            _Strings.joiningTips,
            style: TextStyle(
                color: Colors.white, fontSize: 14, decoration: TextDecoration.none, fontWeight: FontWeight.w400),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget buildHandsUpBtns() {
    Widget handsupWidget;
    if (selfMemberInfo()?.isAudioHandsUp() ?? false) {
      handsupWidget = buildHandsUp(_Strings.inHandsUp, _onToggleAudioMute);
    } else if (hasHandsUp() && isHost()) {
      handsupWidget = buildHandsUp(handsUpCount().toString(), _onMember);
    } else {
      handsupWidget = Container(width: 72);
    }
    return Container(
        height: 60,
        alignment: Alignment.center,
        child: handsupWidget,
    );
  }

  bool hasHandsUp() {
    return _sessionInfo.joinList.any((element) => roomUid2Members[element]?.isAudioHandsUp() ?? false);
  }

  int handsUpCount() {
    var count = 0;
    _sessionInfo.joinList.forEach((element) {
      if (roomUid2Members[element]?.isAudioHandsUp() ?? false) {
        count++;
      }
    });
    return count;
  }

  Widget buildMeetBtns() {
    return Column(children: [
      buildHandsUpBtns(),
      Container(
          width: 750,
          height: 300,
          child:
          GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, //横轴三个子widget
                childAspectRatio: 1.0 //宽高比为1时，子widget
            ),
            children: [
              ...?arguments.options?.injectedToolbarMenuItems?.where(shouldShowMenu)
                  .map(menuItem2Widget)
                  .whereType<Widget>()
                  .toList(),
              if (_willMoreMenuShow())
                SingleStateMenuItem(
                  menuItem: ControlInternalMenuItems.more,
                  callback: handleMenuItemClick,
                  tipBuilder: getMenuItemTipBuilder(_InternalMenuIDs.more),
                ),
            ],
          )),
      Container(
        margin: EdgeInsets.only(top: 32),
        padding: EdgeInsets.only(left: 36, right: 36),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          ],
        ),
      ),
    ]);
  }

  final Map<int, ControllerCyclicStateListController> menuId2Controller = {};

  Widget? menuItem2Widget(NEMeetingMenuItem item) {
    final tipBuilder = getMenuItemTipBuilder(item.itemId);
    if (item is NESingleStateMenuItem) {
      return SingleStateMenuItem(
        menuItem: item,
        callback: handleMenuItemClick,
        tipBuilder: tipBuilder,
      );
    } else if (item is NECheckableMenuItem) {
      final controller = menuId2Controller.putIfAbsent(item.itemId, () => getMenuItemStateController(item.itemId));
      return CheckableMenuItem(
        menuItem: item,
        controller: controller,
        callback: handleMenuItemClick,
        tipBuilder: tipBuilder,
      );
    }
    return null;
  }

  MenuItemTipBuilder? getMenuItemTipBuilder(int menuId) {
    switch (menuId) {
    }
    return null;
  }

  ControllerCyclicStateListController getMenuItemStateController(int menuId) {
    var initialState = NEMenuItemState.uncheck;
    ValueListenable? listenTo;
    switch (menuId) {
      case NEMenuIDs.microphone:
        listenTo = arguments.audioMuteListenable;
        initialState = arguments.audioMute
            ? NEMenuItemState.checked
            : NEMenuItemState.uncheck;
        break;
      case NEMenuIDs.camera:
        listenTo = arguments.videoMuteListenable;
        initialState = arguments.videoMute
            ? NEMenuItemState.checked
            : NEMenuItemState.uncheck;
        break;
      case NEMenuIDs.switchShowType:
        listenTo = arguments.showTypeListenable;
        initialState = (arguments.showType == showTypePresenter)
            ? NEMenuItemState.checked
            : NEMenuItemState.uncheck;
    }
    return ControllerCyclicStateListController(
      stateList: [NEMenuItemState.uncheck, NEMenuItemState.checked],
      initialState: initialState,
      listenTo: listenTo,
    );
  }

  void handleMenuItemClick(NEMenuClickInfo clickInfo) {
    final itemId = clickInfo.itemId;
    switch (itemId) {
      case NEMenuIDs.microphone:
        _onToggleAudioMute();
        return;
      case NEMenuIDs.camera:
        _onToggleVideoMute();
        return;
      case NEMenuIDs.switchShowType:
        if (clickInfo is NEStatefulMenuClickInfo) {
          toChangeShowTypePage(clickInfo.state == 1 ? showTypeGallery : showTypePresenter);
        }
        return;
      case NEMenuIDs.managerParticipants:
      case NEMenuIDs.participants:
        _onMember();
        return;
      case NEMenuIDs.invitation:
        _onInvite();
        return;
      case _InternalMenuIDs.more:
        _onShowMoreMenu();
        return;
    }
    if (itemId >= firstInjectableMenuId) {
      final transitionFuture = MeetingControlUIService().injectedMenuItemClickHandler?.call(context,clickInfo);
      menuId2Controller[itemId]?.didStateTransition(transitionFuture);
    }
  }

  Widget buildHandsUp(String desc, VoidCallback callback) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: callback,
        child: Container(
          height: 46,
          width: 72,
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    color: UIColors.color_337eff,
                    width: 36,
                    height: 40,
                  )),
              Align(
                alignment: Alignment.bottomCenter,
                child: Icon(NEMeetingIconFont.icon_triangle_down, size: 7, color: UIColors.color_337eff),
              ),
              Align(
                alignment: Alignment(0.0, -0.8),
                child: Icon(NEMeetingIconFont.icon_raisehands, size: 20, color: Colors.white),
              ),
              Align(
                  alignment: Alignment(0.0, 0.5),
                  child: Text(desc,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w400)))
            ],
          ),
        ));
  }

  void _onToggleVideoMute() {
    Alog.d(tag: _tag,moduleName: _moduleName, content: '_onToggleVideoMute current unMute state =${isCurrentVideoUnMute()}');
    if (!isHost() && findMemberByUserId(getCurrentAccountId())?.video == AVState.hostClose) {
      ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.forbiddenByHostVideo); // 自己想解除
    } else {
      if (isCurrentVideoUnMute()) {
        ControlInMeetingRepository.muteSelfVideo().then((result) {
          if (result.code == ControlCode.success) {
            if (isCurrentVideoUnMute()) {
              findMemberByUserId(getCurrentAccountId())?.video = AVState.close;
            } else {
              findMemberByUserId(getCurrentAccountId())?.video = AVState.open;
            }
            setState(() {});
          } else if (result.code == RoomErrorCode.networkError) {
            ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.networkUnavailable);
          }
        });
      } else {
        ControlInMeetingRepository.unMuteSelfVideo().then((result) {
          if (result.code == ControlCode.success) {
            if (isCurrentVideoUnMute()) {
              findMemberByUserId(getCurrentAccountId())?.video = AVState.close;
            } else {
              findMemberByUserId(getCurrentAccountId())?.video = AVState.open;
            }
            setState(() {});
          } else if (result.code == RoomErrorCode.networkError) {
            ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.networkUnavailable);
          }
        });
      }
    }
  }

  Widget buildStopBtn() {
    var isMaster = isHost();
    return GestureDetector(
      onTap: () {
        _exit();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Image.asset(
              isMaster ? NEMeetingImages.stopMeeting : NEMeetingImages.leaveMeeting,
              package: NEMeetingImages.package,
              fit: BoxFit.none,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(
              isMaster ? _Strings.finish : _Strings.leave,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: UIColors.primaryText,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exit() {
    DialogUtils.showChildNavigatorPopup<String>(context,
            CupertinoActionSheet(
              title: Text(
                isHost() ? _Strings.hostExitTips : _Strings.leaveTips,
                style: TextStyle(color: UIColors.grey_8F8F8F, fontSize: 13),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(_Strings.leaveMeeting, style: TextStyle(color: UIColors.color_007AFF)),
                    onPressed: () {
                      Navigator.pop(context, _Strings.leaveMeeting);
                    }),
                if (isHost())
                  CupertinoActionSheetAction(
                      child: Text(_Strings.quitMeeting, style: TextStyle(color: UIColors.colorFE3B30)),
                      onPressed: () {
                        Navigator.pop(context, _Strings.quitMeeting);
                      }),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text(_Strings.cancel, style: TextStyle(color: UIColors.color_007AFF)),
                onPressed: () {
                  Navigator.pop(context, _Strings.cancel);
                },
              ),
            )).then<void>((String? value) {
      if (value == _Strings.leaveMeeting) {
        ControlInMeetingRepository.leaveMeeting(ControlProfile.pairedAccountId).then((result) {
          if (result.code == ControlCode.success) {
            Navigator.of(context).popUntil(ModalRoute.withName(_PageName.controlHome));
          } else if (result.code == RoomErrorCode.networkError) {
            ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.networkUnavailable);
          }
        });
      } else if (value == _Strings.quitMeeting) {
        ControlInMeetingRepository.stopMeeting(ControlProfile.pairedAccountId).then((result) {
          if (result.code == ControlCode.success) {
            Navigator.of(context).popUntil(ModalRoute.withName(_PageName.controlHome));
          } else if (result.code == RoomErrorCode.networkError) {
            ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.networkUnavailable);
          }
        });
      }
    });
  }

  void _unregisterListener() {
    subscription?.cancel();
    _memberChangeSubscription?.cancel();
  }

  void _registerTVControlListener() {
    var stream = ControlInMeetingRepository.controlMessageStream();
    subscription = stream.listen((MeetingAction action) {
      switch (action.type) {
        case TCProtocol.controlAudio:
          onChangeAudioStatus(action as TCAudioAction);
          break;
        case TCProtocol.controlVideo:
          onChangeVideoStatus(action as TCVideoAction);
          break;
        case TCProtocol.controlFocus:
          onChangeFocus(action as TCChangeFocusAction);
          break;
        case TCProtocol.controlHost:
          onChangeHost(action as TCChangeHostAction);
          break;
        case TCProtocol.screenShare:
          onScreenShare(action as TCScreenShareAction);
          break;
        case TCProtocol.meetingLock:
          onMeetingLock(action as TCMeetingLockAction);
          break;
        case TCProtocol.tvStatusResult2Controller:
          onTVStatusResult2Controller(action as TCControlRequestTVResultAction);
          break;
        case TCProtocol.fetchJoinersResult2Controller:
          onFetchJoinersResult2Controller(action as TCRequestJoinersResultAction);
          break;
        case TCProtocol.fetchMemberInfoResult2Controller:
          onRequestMembersResult(action as TCRequestMembersResultAction);
          break;
        case TCProtocol.joinChannelResult2Controller:
          onJoinChannelResult2Controller();
          break;
        case TCProtocol.removeMember:
          onRemoveMember(action as TCRemoveAttendeeAction);
          break;
        case TCProtocol.leaveMeeting:
          onLeaveMeeting(action as TCLeaveMeetingAction);
          break;
        case TCProtocol.memberJoin:
          onMemberJoin(action as TCUserJoinedAction);
          break;
        case TCProtocol.memberLeave2Controller:
          onMemberLeave2Controller(action as TCUserLeaveAction);
          break;
        case TCProtocol.handsUp:
          onHandsUp(action as TCHandsUpAction);
          break;
        case TCProtocol.selfHandsUpResult2Controller:
          onHandsUpResult(action as TCHandsUpResultAction);
          break;
        case TCProtocol.selfUnHandsUpResult2Controller:
        case TCProtocol.finishMeetingResult2TV:
        case TCProtocol.removeMemberResult:
        case TCProtocol.controlFocusResult:
        case TCProtocol.controlHostResult:
        case TCProtocol.meetingLockResult:
        case TCProtocol.selfAudioResult:
        case TCProtocol.hostAudioResult:
        case TCProtocol.selfVideoResult:
        case TCProtocol.hostVideoResult:
        case TCProtocol.hostRejectAudioHandsUpResult:
          if (action is TCResultAction && action.code != RoomErrorCode.success) {
            ToastUtils.showToast(context, action.msg);
          }
          break;
      }
    });
  }

  void _onToggleAudioMute() async {
    /// 静音且不是主持人且不允许自行解除，走举手逻辑
    if (!isCurrentAudioUnMute() && !isHost() && !_allowAudioOn()) {
      _handMuteAllHandsUp();
    } else {
      if (isCurrentAudioUnMute()) {
        await ControlInMeetingRepository.muteSelfAudio().then((value) {
          if (value.code == ControlCode.success) {
            if (isCurrentAudioUnMute()) {
              findMemberByUserId(getCurrentAccountId())?.audio = AVState.close;
            } else {
              findMemberByUserId(getCurrentAccountId())?.audio = AVState.open;
            }
            setState(() {});
          } else if (value.code == RoomErrorCode.networkError) {
            ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.networkUnavailable);
          }
        });
      } else {
        await ControlInMeetingRepository.unMuteSelfAudio().then((value) {
          if (value.code == ControlCode.success) {
            if (isCurrentAudioUnMute()) {
              findMemberByUserId(getCurrentAccountId())?.audio = AVState.close;
            } else {
              findMemberByUserId(getCurrentAccountId())?.audio = AVState.open;
            }
            setState(() {});
          } else if (value.code == RoomErrorCode.networkError) {
            ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.networkUnavailable);
          }
        });
      }
    }
  }

  bool _allowAudioOn() {
    return _meetingInfo!.settings?.isAllowSelfAudioOn ?? true;
  }

  /// 全体静音不允许自行解除举手
  void _handMuteAllHandsUp() {
    if (selfMemberInfo()?.isAudioHandsUp() ?? false) {
      // trackPeriodicEvent(TrackEventName.hands_up, extra: {'value': 0, 'meeting_id': arguments.meetingId});
      DialogUtils.showCommonDialog(context, _Strings.cancelHandsUp, _Strings.cancelHandsUpTips, () {
        Navigator.of(context).pop();
      }, () {
        Navigator.of(context).pop();
        lifecycleExecute(ControlInMeetingRepository.muteAllUnHandsUp(arguments.meetingId)).then((NEResult? result) {
          if (!result!.isSuccess()) {
            ToastUtils.showToast(context, _Strings.cancelHandsUpFail);
          }
          setState(() {
            // fail reset
            selfMemberInfo()?.updateMuteAllHandsUp(result.isSuccess() ? false : true);
          });
        });
      });
    } else {
      _onHandsUpOn();
    }
  }

  void _onHandsUpOn() {
    // 举手
    // trackPeriodicEvent(TrackEventName.hands_up, extra: {'value': 1, 'meeting_id': arguments.meetingId});
    DialogUtils.showCommonDialog(context, _Strings.muteAudioAll, _Strings.muteAllHandsUpTips, () {
      Navigator.of(context).pop();
    }, () {
      Navigator.of(context).pop();
      lifecycleExecute(ControlInMeetingRepository.muteAllHandsUp(arguments.meetingId)).then((NEResult? result) {
        if (!result!.isSuccess()) {
          ToastUtils.showToast(context, _Strings.handsUpFail);
        }
        setState(() {
          selfMemberInfo()?.updateMuteAllHandsUp(result.isSuccess() ? true : false);
        });
      });
    }, acceptText: _Strings.handsUpApply);
  }

  void _onOpenSelfAudio() {
    arguments.audioMute = false;
    selfMemberInfo()?.updateMuteAllHandsUp(false);
    // trackPeriodicEvent(TrackEventName.switchAudio, extra: {'value': 1, 'meeting_id': arguments.meetingId});
    lifecycleExecute(ControlInMeetingRepository.unMuteSelfAudio()).then((NEResult? result) {
      if (result!.isSuccess()) {
        selfMemberInfo()?.audio = AVState.open;
      } else {
        // 失败则回退
        selfMemberInfo()?.audio = AVState.close;
        arguments.audioMute = true;
      }
    });
  }

  InMeetingMemberInfo? selfMemberInfo() => findMemberByUserId(getCurrentAccountId());

  void onMeetingLock(TCMeetingLockAction action) {
    _meetingInfo?.joinControlType = action.joinControlType;
    _fireMembersChanged();
  }

  // 被主持人关闭
  void showTips(bool isShowToast, TCAudioAction action, bool changed, String? operateUser) {
    // 被主持人关闭
    if (isShowToast && action.muteAudio == AVState.hostClose) {
      ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!,
          TextUtils.isEmpty(action.operateUser) ? _Strings.meetingHostMuteAllAudio : _Strings.meetingHostMuteAudio);
    }

    if (changed && isSelf(operateUser)) {
      updateSelfAudioState(action.muteAudio);
    }
  }

  void onScreenShare(TCScreenShareAction action) {
    if (TextUtils.isEmpty(action.userId)) {
      return;
    }
    refreshShowTypeBtnState(action.userId, action.screenSharing);

    _fireMembersChanged();
  }

  void refreshShowTypeBtnState(String? userId, int shareState) {
    if (TextUtils.isEmpty(userId)) {
      return;
    }
    if (shareState == ScreenShareAction.notShare) {
      _meetingInfo?.screenSharersAccountId.remove(userId);
    } else {
      findMemberByUserId(userId)?.updateMuteAllHandsUp(false);
      addScreenShareUid(userId!);

      /// 屏幕共享开启默认视频关闭
//      findMemberByUserId(action.userId).video = AVState.close;
    }

    Store.value<ShowTypeModel>(context, isListen: false).changeClickable(_isShowTypeClickable());
  }

  InMeetingMemberInfo? findMemberByUserId(String? userId) {
    return uid2Members[userId!];
  }

  void addScreenShareUid(String uid) {
    Alog.d(tag: _tag,moduleName: _moduleName, content: 'addScreenShareUid uid=$uid');
    // _meetingInfo = _meetingInfo ?? MeetingInfo();
    // _meetingInfo!.screenSharersAccountId = _meetingInfo?.screenSharersAccountId ?? <String>{};
    // _meetingInfo!.screenSharersAccountId.add(uid);
  }

  void onUserJoin(InMeetingMemberInfo? member) {
    if (isHost()) {
      ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, (member?.nickName ?? '') + '加入会议');
    }
    _onUserChanged();
    setState(() {});
  }

  bool _isShowTypeClickable() {
    return _sessionInfo.joinList.isNotEmpty && !((_meetingInfo?.screenSharersAccountId.length ?? 0) > 0);
  }

  void _onUserChanged() {
    if (_sessionInfo.joinList.isNotEmpty) {
      Store.value<ShowTypeModel>(context, isListen: false).changeClickable(_isShowTypeClickable());
    } else {
      Store.value<ShowTypeModel>(context, isListen: false).changeClickable(_isShowTypeClickable());
      changeShowType(showTypePresenter);
    }

    _fireMembersChanged();
  }

  void updateSelfAudioState(int mute) {
    if (mute == AVState.waitingOpen) {
      uid2Members[getCurrentAccountId()!]?.audio = AVState.waitingOpen;
      if (_isShowOpenMicroDialog) {
        closeOpenMicroDialog();
      }
      DialogUtils.showOpenAudioDialog(context, _Strings.openMicro, _Strings.hostOpenMicroTips, () {
        closeOpenMicroDialog();

        /// hands up down
        selfMemberInfo()?.audio = AVState.close;
        selfMemberInfo()?.updateMuteAllHandsUp(false);
        arguments.audioMute = true;
      }, () {
        closeOpenMicroDialog();
        ControlInMeetingRepository.unMuteSelfAudio().then((result) {
          if (result.code == ControlCode.success) {
            actionCallback(CallbackAction.hostUnMuteAudio, getCurrentAccountId());
          } else if (result.code == RoomErrorCode.networkError) {
            ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.networkUnavailable);
          } else {
            ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.unMuteAudioFail);
          }
        });
      });
      _isShowOpenMicroDialog = true;
    } else {}
  }

  void closeOpenMicroDialog() {
    Navigator.of(context).pop();
    _isShowOpenMicroDialog = false;
  }

  void updateSelfVideoState(String userId, int mute, {bool dialog = false}) {
    if (isSelf(userId)) {
      if (dialog && mute == AVState.waitingOpen) {
        uid2Members[userId]?.video = AVState.waitingOpen;
        DialogUtils.showOpenVideoDialog(context, _Strings.openCamera, _Strings.hostOpenCameraTips, () {
          Navigator.of(context).pop();
          uid2Members[userId]?.video = AVState.close;
        }, () {
          Navigator.of(context).pop();
          _onToggleVideoMute();
        });
      } else {
        arguments.videoMute = AVState.isMute(mute);
      }
    }
  }

  InMeetingMemberInfo? findMemberByRoomUid(int roomUid) {
    return roomUid2Members[roomUid];
  }

  void _fireMembersChanged() {
    _membersDataSource.update([arguments.avRoomUid, ..._sessionInfo.joinList], _meetingInfo, roomUid2Members);
  }

  String getMeetId() {
    return arguments.tvStatus?.meetingId ?? arguments.meetingId;
  }

  @override
  String? getTitle() {
    return null;
  }

  void _registerOnlineStatus() {
    lifecycleListen(AuthRepository.imOnlineStatusChanged, (dynamic code) {
      //由于应用程序在后台\锁屏的时候，core进程可能被杀死，导致透传消息丢失，这里需要在应用回到前台的时候，数据补充
      Alog.d(tag: _tag,moduleName: _moduleName,content:'imOnlineStatusChanged code = $code');
      if (code == StatusCode.logined) {
        fetchMember(requestIdPairInMeeting);
      }
    });
  }

  @override
  void dispose() {
    _unregisterListener();

    /// cannot call contain context op, because already removed
    super.dispose();
  }

  void fetchMember(int requestId, {int? uid}) {
    ControlInMeetingRepository.requestMembers(requestId, uid);
  }

  /// 被提出, 没有操作3秒自动退出
  void onKicked() {
    late BuildContext dialogContext;
    var countDown = Timer(const Duration(seconds: 3), () {
      UINavUtils.pop(dialogContext);
    });
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return CupertinoAlertDialog(
            title: Text(_Strings.notify),
            content: Text(_Strings.hostKickedYou),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(_Strings.sure),
                onPressed: () {
                  countDown.cancel();
                  UINavUtils.pop(context);
                },
              )
            ],
          );
        });
  }

  bool isHost() {
    return TextUtils.nonEmptyEquals(ControlProfile.pairedAccountId, hostAccountId);
  }

  void showError({int? code, String? msg, String? defaultTips}) {
    if (code == null && defaultTips == null) {
      return;
    }
    ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, ControlCode.getErrorMsg(msg, defaultTips)!);
    switch (code) {
      case ControlCode.meetingNotExist:
        Navigator.of(context).popUntil(ModalRoute.withName(_PageName.controlHome));
        break;
      default:
        break;
    }
  }

  bool isCurrentAudioUnMute() {
    var member = uid2Members[getCurrentAccountId()!];
    return member == null || member.audio == 1;
  }

  bool isCurrentVideoUnMute() {
    var member = uid2Members[getCurrentAccountId()!];
    return member == null || member.video == 1;
  }

  void actionCallbackRoomUid(int actionType, int? roomUid, InMeetingMemberInfo? member) {
    var userId = roomUid2Members[roomUid]?.accountId;
    actionCallback(actionType, userId);
  }

  void actionCallback(int actionType, String? accountId) {
    switch (actionType) {
      case CallbackAction.hostMuteAudio:
        uid2Members[accountId!]?.audio = AVState.hostClose;
        break;
      case CallbackAction.hostUnMuteAudio:
        if (isSelf(accountId)) {
          findMemberByUserId(accountId)?.updateMuteAllHandsUp(false);
          uid2Members[accountId!]?.audio = AVState.open;
        } else {
          // 他人
          if (uid2Members[accountId!]?.audio != AVState.open) {
            uid2Members[accountId]?.audio = AVState.waitingOpen;
          }
        }
        break;
      case CallbackAction.hostMuteVideo:
        uid2Members[accountId!]?.video = AVState.hostClose;
        break;
      case CallbackAction.hostUnMuteVideo:
        if (isSelf(accountId)) {
          uid2Members[accountId!]?.video = AVState.open;
        } else {
          // 他人
          if (uid2Members[accountId!]?.video != AVState.open) {
            uid2Members[accountId]?.video = AVState.waitingOpen;
          }
        }
        break;
      case CallbackAction.setFocusVideo:
        _meetingInfo?.focusAccountId = accountId;
        _fireMembersChanged();
        break;
      case CallbackAction.cancelFocusVideo:
        _meetingInfo?.focusAccountId = null;
        _fireMembersChanged();
        break;
      case CallbackAction.changeHost:
        hostAccountId = accountId;
        _meetingInfo?.hostAccountId = hostAccountId!;
        _fireMembersChanged();
        break;
      case CallbackAction.removeMember:
        break;
      case CallbackAction.hostMuteAllAudio:
      case CallbackAction.hostUnMuteAllAudio:
        // 全体静音,解除静音只是发消息，等待服务器通知再做同步
        break;
    }
    setState(() {});
  }

  String? getCurrentAccountId() {
    return ControlProfile.pairedAccountId;
  }

  int userId2RoomUid(String? userId) {
    return uid2Members[userId!]?.avRoomUid ?? 0;
  }

  bool isSelf(String? accountId) {
    return accountId == getCurrentAccountId();
  }

  void fetchJoinFromTV() {
    ControlInMeetingRepository.requestJoinersFromTV(ControlProfile.pairedAccountId);
  }

  void changeShowType(int showType) {
    ControlInMeetingRepository.changeShowType(showType).then((result) {
      if (result.code == ControlCode.success) {
        Store.value<ShowTypeModel>(context, isListen: false).changeShowType(showType);
      }
    });
  }

  void onRequestMembersResult(TCRequestMembersResultAction action) {
    if (action.code == ControlCode.success) {
      var meetingInfo = action.meetingInfo;
      if (meetingInfo != null) {
        _meetingInfo = meetingInfo;
        ControlInMeetingService().updateMeetingInfo(_meetingInfo!);
        _sessionInfo.onUserMemberInfos(_meetingInfo!.members);
        hostAccountId = _meetingInfo!.hostAccountId;
        focusAccountId = _meetingInfo!.focusAccountId;
        _meetingInfo!.members.forEach((item) {
          uid2Members[item.accountId] = item;
          roomUid2Members[item.avRoomUid] = item;
        });

        if (requestIdPairInMeeting == action.requestId) {
          fetchJoinFromTV();
        } else if (requestIdCreateOrJoinSuccess == action.requestId) {
          _fireMembersChanged();
        } else if (requestIdMemberChange == action.requestId) {
          _fireMembersChanged();
        } else if (requestIdUserJoin == action.requestId) {
          var uid = _meetingInfo?.members[0].avRoomUid ?? 0;
          onUserJoin(findMemberByRoomUid(uid));
        } else if (requestIdAllMuteAudio == action.requestId) {
          _fireMembersChanged();
        } else if (requestIdChangeHost == action.requestId) {
          _fireMembersChanged();
        }
      } else {
        Alog.d(tag: _tag,moduleName: _moduleName, content: 'action.type == ActionType.requestMembersResult but member = null');
      }
    } else {
      Alog.d(tag: _tag,moduleName: _moduleName, content: 'action.type == ActionType.requestMembersResult but code = ${action.code}');
    }
  }

  void onChangeAudioStatus(TCAudioAction action) {
    var subType = action.subType;
    if (subType == AudioSubType.muteAllOpenOff) {
      _meetingInfo!.settings?.allowSelfAudioOn = false;
      hostMuteAll(action);
    } else if (subType == AudioSubType.muteAllOpenOn) {
      _meetingInfo!.settings?.allowSelfAudioOn = true;
      hostMuteAll(action);
    } else if (subType == AudioSubType.unMuteAll) {
      hostUnMuteAll(action);
    } else if (subType == AudioSubType.muteAudioHandsUpOn) {
      //解除静音发下手直接打开音频，不需要弹窗确认
      var member = findMemberByUserId(action.operateUser);
      member?.audio = action.muteAudio;
      member?.updateMuteAllHandsUp(false);
      if (isSelf(action.operateUser)) {
        arguments.audioMute = false;
        ToastUtils.showToast(context, _Strings.hostAgreeAudioHandsUp);
        // _syncLocalAudio();
      }
    } else if (action.fromUser == action.operateUser && isSelf(action.operateUser)) {
      selfControlAudio(action);
    } else {
      //主持人操作
      hostControlAudio(action);
    }

    _fireMembersChanged();
    setState(() {});
  }

  void hostMuteAll(TCAudioAction action) {
    var operateUser = !TextUtils.isEmpty(action.operateUser) ? action.operateUser : getCurrentAccountId();
    var isShowToast = false;
    var changed = false;
    var member = findMemberByUserId(operateUser);
    var now = member?.audio;
    var isMeNotHost = hostAccountId != operateUser;
    Alog.d(tag: _tag,moduleName: _moduleName,content: 'want to show audio dialog operUser = $operateUser, hostUserId = $hostAccountId');
    isShowToast = true;

    /// 除了主持人，其他需要执行操作
    if (isMeNotHost) {
      member!.audio = AVState.hostClose;
    }
    changed = isMeNotHost;
    /// 如果包括自己，修改自己的音频状态
    if (changed && isSelf(operateUser)) {
      arguments.audioMute = AVState.isMute(action.muteAudio);
    }
    /// 数据更新完刷新内容
    isShowToast = isMeNotHost &&
        now == AVState.open &&
        now != action.muteAudio && isSelf(operateUser);

    showTips(isShowToast, action, changed, operateUser);

    /// 全体静音 同步状态
    fetchMember(requestIdAllMuteAudio);
  }

  void hostUnMuteAll(TCAudioAction action) {
    _meetingInfo!.settings?.allowSelfAudioOn = true;
    updateAllMemberHandsUp(false);
    var self = selfMemberInfo();
    var hostUserId = findMemberByRoomUid(userId2RoomUid(hostAccountId))?.accountId;
    if (hostUserId != self?.accountId && self?.audio != action.muteAudio && self?.audio != AVState.open) {
      self!.audio = action.muteAudio;
      updateSelfAudioState(action.muteAudio);
    }
  }

  void updateAllMemberHandsUp(bool handsUp) {
    roomUid2Members.values.forEach((element) {
      element.updateMuteAllHandsUp(handsUp);
    });
  }

  void selfControlAudio(TCAudioAction action) {
    findMemberByUserId(action.operateUser)?.audio = action.muteAudio;
    findMemberByUserId(action.operateUser)?.updateMuteAllHandsUp(false);
    if (isSelf(action.operateUser)) {
      arguments.audioMute = AVState.isMute(action.muteAudio);
    }
  }

  void hostControlAudio(TCAudioAction action) {
    var member = findMemberByUserId(action.operateUser);
    member?.audio = action.muteAudio;

    if (action.muteAudio == AVState.open) {
      findMemberByUserId(action.operateUser)?.updateMuteAllHandsUp(false);
    }

    if (isSelf(action.operateUser)) {
      arguments.audioMute = AVState.isMute(action.muteAudio);
      if (action.muteAudio == AVState.hostClose) {
        ToastUtils.showToast(context, _Strings.meetingHostMuteAudio);
      }
      updateSelfAudioState(action.muteAudio);
    }
  }

  void onChangeVideoStatus(TCVideoAction action) {
    if (action.fromUser == action.operateUser) {
      // 说明是自己设置的
      if (!TextUtils.isEmpty(action.operateUser)) {
        findMemberByUserId(action.operateUser)?.video = action.muteVideo;
        updateSelfVideoState(action.operateUser, action.muteVideo);
      }
    } else {
      if (findMemberByUserId(action.operateUser)?.video != action.muteVideo) {
        /// waiting open
        findMemberByUserId(action.operateUser)?.video = action.muteVideo;

        // 自己被主持人关闭
        if (isSelf(action.operateUser) && action.muteVideo == AVState.hostClose) {
          ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.meetingHostMuteVideo);
        }

        updateSelfVideoState(action.operateUser, action.muteVideo, dialog: true);
      }
    }

    _fireMembersChanged();
  }

  void onChangeHost(TCChangeHostAction action) {
    var accountId = action.operateAccountId;

    if (getCurrentAccountId() == accountId) {
      findMemberByUserId(getCurrentAccountId())?.updateMuteAllHandsUp(false);
      ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.yourChangeHost);
    }
    hostAccountId = accountId;
    _meetingInfo?.hostAccountId = accountId;

    fetchMember(requestIdChangeHost);
  }

  void onChangeFocus(TCChangeFocusAction action) {
    var operaUser = action.operateUser;
    if (action.isFocus) {
      if (getCurrentAccountId() == operaUser) {
        ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.yourChangeFocus);
      }
      //如果之前是焦点视频，现在把别人设备焦点视频，要提示取消焦点视频
      if (TextUtils.nonEmptyEquals(getCurrentAccountId(), focusAccountId) &&
          !TextUtils.nonEmptyEquals(getCurrentAccountId(), operaUser)) {
        ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.yourChangeUnFocus);
      }
      focusAccountId = operaUser;
      _meetingInfo?.focusAccountId = focusAccountId;
    } else {
      if (TextUtils.nonEmptyEquals(getCurrentAccountId(), operaUser)) {
        ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, _Strings.yourChangeUnFocus);
      }
      focusAccountId = null;
      _meetingInfo?.focusAccountId = focusAccountId;
    }
    _fireMembersChanged();
  }

  void onRemoveMember(TCRemoveAttendeeAction action) {
    if (getCurrentAccountId() == action.operateUser) {
      UINavUtils.popUntil(context, _PageName.controlHome);
      onKicked();
    }
  }

  void onLeaveMeeting(TCLeaveMeetingAction action) {
    UINavUtils.popUntil(context, _PageName.controlHome);
    if (action.reason == removedByMaster) {
      onKicked();
    } else if (action.reason == meetingCloseByMaster) {
      EventBus().emit(_EventName.meetingClose);
    } else if (action.reason == meetingCloseBySelf) {}
  }

  void onMemberJoin(TCUserJoinedAction action) {
    var uid = action.uid;
    _sessionInfo.onUserJoined(uid);

    /// 每次加进来 刷新一下资料
    var member = findMemberByRoomUid(uid);
    if (member == null) {
      fetchMember(requestIdUserJoin, uid: uid);
    } else {
      _sessionInfo.onUserMemberInfo(member);
      onUserJoin(member);
    }
  }

  void onMemberLeave2Controller(TCUserLeaveAction action) {
    var uid = action.uid;
    var member = findMemberByRoomUid(uid);
    if (member != null && isHost()) {
      ToastUtils.showToast(MeetingControl.controlNavigatorKey.currentContext!, '${member.nickName}离开会议');
    }
    if (member?.accountId == hostAccountId) {
      hostAccountId = null;
    }
    if (member?.accountId == hostAccountId) {
      focusAccountId = null;
    }
    if (member?.accountId == hostAccountId) {
      activeUId = null;
    }
    _sessionInfo.onUserLeave(uid);
    roomUid2Members.remove(uid);
    uid2Members.remove(member?.accountId);
    refreshShowTypeBtnState(member?.accountId, ScreenShareAction.notShare);
    //只剩下一个人的时候只能演讲者视图
    _onUserChanged();
  }

  void onJoinChannelResult2Controller() {
    setState(() {
      isJoining = false;
    });

    _showAudioAllMuteToast();
  }

  void onFetchJoinersResult2Controller(TCRequestJoinersResultAction action) {
    var uidList = action.uidList;
    _sessionInfo.joinList.clear();
    _sessionInfo.videoList.clear();
    uidList.forEach((uid) {
      if (uid != arguments.avRoomUid) {
        _sessionInfo.joinList.add(uid);
        _sessionInfo.videoList.putIfAbsent(uid, () {
          /// add self
          return VideoInfo();
        });
      }
    });
    _onUserChanged();
  }

  void onTVStatusResult2Controller(TCControlRequestTVResultAction action) {
    arguments.tvStatus = action.tvStatus;
    arguments.audioMute = action.tvStatus.muteAudio != AVState.open;
    arguments.videoMute = action.tvStatus.muteVideo != AVState.open;
    setState(() {});
    if (arguments.tvStatus?.status == StatusType.meeting) {
      setState(() {
        isJoining = false;
      });
    }
  }

  void onHandsUp(TCHandsUpAction action) {
    var subType = action.subType;
    if (subType == HandsUpSubType.memberHandsUp) {
      findMemberByUserId(action.operateUser)?.updateMuteAllHandsUp(true);
    } else if (subType == HandsUpSubType.memberHandsUpDown) {
      findMemberByUserId(action.operateUser)?.updateMuteAllHandsUp(false);
    } else if (subType == HandsUpSubType.hostRejectAudioHandsUp) {
      findMemberByUserId(action.operateUser)?.updateMuteAllHandsUp(false);
      if (!isHost()) {
        ToastUtils.showToast(context, _Strings.hostRejectAudioHandsUp);
      }
    }
    _fireMembersChanged();
    setState(() {});
  }

  void onHandsUpResult(TCHandsUpResultAction action) {
    if (action.code == RoomErrorCode.success) {
      ToastUtils.showToast(context, _Strings.handsUpSuccess);
    } else if (action.code == RoomErrorCode.allowSelfAudioOn) {
      _meetingInfo!.settings?.allowSelfAudioOn = true;
      _onOpenSelfAudio();
    } else if (action.code == RoomErrorCode.audioAlreadyOn) {
      arguments.audioMute = false;
      selfMemberInfo()?.audio = AVState.open;
      selfMemberInfo()?.updateMuteAllHandsUp(false);
      ToastUtils.showToast(context, _Strings.audioAlreadyOpen);
    } else if (action.code == RoomErrorCode.audioNeedHandsUp) {
      _onHandsUpOn();
    } else {
      ToastUtils.showToast(context, _Strings.handsUpFail);
    }
  }

  bool shouldShowMenu(NEMeetingMenuItem item) {
    if (!item.isValid) return false;
    switch (item.visibility) {
      case NEMenuVisibility.visibleToHostOnly:
        return isHost();
      case NEMenuVisibility.visibleExcludeHost:
        return !isHost();
      case NEMenuVisibility.visibleAlways:
        return true;
    }
  }

  /// 从下往上显示
  void _onMember() {
    _fireMembersChanged();
    DialogUtils.showChildNavigatorPopup(context, ControlMeetMemberPage(ControlMembersArguments(
              meetingId: getMeetId(),
              memberSource: _membersDataSource,
              callback: actionCallbackRoomUid)));
  }

  void toChangeShowTypePage(int showType) {
    Alog.d(tag: _tag,moduleName: _moduleName, content: 'showType = $showType');
    DialogUtils.showChildNavigatorPopup(context, ControlShowTypePage(arguments));
  }

  void _onShowMoreMenu() {
    DialogUtils.showChildNavigatorPopup(context, ControlMoreMenuPage(ControlMoreMenuArguments(controlMeetingArguments: arguments,
        moreMenuActionCallback: moreMenuActionCallback,
        menuId2Controller: menuId2Controller,
        hostAccountId: hostAccountId)));
  }

  void moreMenuActionCallback(NEMenuClickInfo clickInfo) {
    handleMenuItemClick(clickInfo);
  }

  void _onInvite() {
    DialogUtils.showInviteDialog(context, _buildInviteInfo());
  }

  String _buildInviteInfo() {
    var info = '${_Strings.inviteTitle}';

    info += '${_Strings.meetingSubject}${_meetingInfo!.subject}\n';
    if (_meetingInfo!.type == NERoomType.schedule) {
      info +=
      '${_Strings.meetingTime}${_meetingInfo!.scheduleStartTime.formatToTimeString('yyyy/MM/dd HH:mm')} - ${_meetingInfo!.scheduleEndTime.formatToTimeString('yyyy/MM/dd HH:mm')}\n';
    }

    info += '\n';
    if (!arguments.options!.isShortMeetingIdEnabled ||
        TextUtils.isEmpty(_meetingInfo!.shortMeetingId)) {
      info += '${_Strings.meetingID}${_meetingInfo!.meetingId.toMeetingIdFormat()}\n';
    } else if (!arguments.options!.isLongMeetingIdEnabled) {
      info += '${_Strings.meetingID}${_meetingInfo!.shortMeetingId}\n';
    } else {
      info += '${_Strings.shortMeetingID}${_meetingInfo!.shortMeetingId}(${_Strings.internalSpecial})\n';
      info += '${_Strings.meetingID}${_meetingInfo!.meetingId.toMeetingIdFormat()}\n';
    }
    if (!TextUtils.isEmpty(_meetingInfo!.password)) {
      info += '${_Strings.meetingPwd}${_meetingInfo!.password}\n';
    }
    if (!TextUtils.isEmpty(_meetingInfo!.sipCid)) {
      info += '\n';
      info += '${_Strings.sipID}${_meetingInfo!.sipCid}\n';
    }
    return info;
  }
}

class SessionInfo {
  bool debug = false;

  String logLevel = 'info';

  List<int> joinList = <int>[];

  /// 用户信息没有获取到的都在pending列表
  List<int> pendingList = <int>[];

  /// 其他用户使用的videoInfo 对应关系
  Map<int, VideoInfo> videoList = <int, VideoInfo>{};

  void onUserJoined(int uid) {
    if(!pendingList.contains(uid)){
      pendingList.add(uid);
    }
    videoList.putIfAbsent(uid, () {
      return VideoInfo();
    });
  }

  void onUserMemberInfo(InMeetingMemberInfo member) {
    // if (member == null) {
    //   return;
    // }
    if (!RoleType.isHide(member.roleType)) {
      if (!joinList.contains(member.avRoomUid) && pendingList.contains(member.avRoomUid)) {
        joinList.add(member.avRoomUid);
        pendingList.remove(member.avRoomUid);
      }
    }
  }

  void onUserMemberInfos(List<InMeetingMemberInfo>? members) {
    if (members == null) {
      return;
    }
    members.forEach((element) {
      if (!RoleType.isHide(element.roleType)) {
        if (!joinList.contains(element.avRoomUid) && pendingList.contains(element.avRoomUid)) {
          joinList.add(element.avRoomUid);
          pendingList.remove(element.avRoomUid);
        }
      }
    });
  }

  void onUserLeave(int uid) {
    joinList.remove(uid); //remove
    videoList.remove(uid);
    pendingList.remove(uid);
  }
}

class VideoInfo {
  Widget? view;
  int? viewId;
  int? profile;
}
