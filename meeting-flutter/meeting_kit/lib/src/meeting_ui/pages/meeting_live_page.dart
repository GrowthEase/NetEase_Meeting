// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingLivePage extends StatefulWidget {
  final LiveArguments _arguments;

  MeetingLivePage(this._arguments);

  @override
  State<StatefulWidget> createState() {
    return MeetingLiveState(_arguments);
  }
}

class MeetingLiveState extends LifecycleBaseState<MeetingLivePage> {
  final LiveArguments _arguments;

  MeetingLiveState(this._arguments);

  final FocusNode _focusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  late TextEditingController _liveTitleController, _livePasswordController;

  bool livePwdSwitch = false;
  bool chatRoomEnableSwitch = true;
  bool liveLevelEnableSwitch = false;

  String? livePassword;

  static const int passwordRange = 900000,
      basePassword = 100000,
      oneDay = 24 * 60 * 60 * 1000;

  List<String?> liveUids = [];

  NERoomLiveLayout liveLayout = NERoomLiveLayout.none;

  bool viewChange = false;

  late NERoomLiveController liveStreamController;
  late NERoomLiveInfo _liveInfo;
  late NERoomContext _roomContext;
  NERoomEventCallback? roomEventCallback;

  @override
  void initState() {
    super.initState();
    _roomContext = _arguments.roomContext;
    _liveInfo = _arguments.live;
    liveStreamController = _arguments.roomContext.liveController;
    _liveTitleController =
        TextEditingController(text: _liveInfo.title ?? _roomContext.roomName);
    initPassword();
    liveUidFromJson();
    viewChange = !listEquals(_liveInfo.userUuidList, liveUids);
    liveLayout = _liveInfo.liveLayout;
    chatRoomEnableSwitch = liveChatRoomEnable();
    liveLevelEnableSwitch = onlyEmployeesAllow();
    lifecycleListen(_arguments.roomInfoUpdatedEventStream, (_) {
      filterLiveUids();
      viewChange = !listEquals(_liveInfo.userUuidList, liveUids);
      setState(() {});
    });
    _focusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _roomContext.addEventCallback(roomEventCallback = NERoomEventCallback(
      liveStateChanged: (_) => _updateLiveInfo(),
    ));
  }

  void _updateLiveInfo() async {
    final currentLiveInfo =
        (await _roomContext.liveController.getLiveInfo()).data;
    if (currentLiveInfo != null) {
      _liveInfo = currentLiveInfo;
      _liveTitleController.text = _liveInfo.title ?? _roomContext.roomName;
      _livePasswordController.text = _liveInfo.password ?? '';
      liveUidFromJson();
      viewChange = !listEquals(_liveInfo.userUuidList, liveUids);
      liveLayout = _liveInfo.liveLayout;
      chatRoomEnableSwitch = liveChatRoomEnable();
      liveLevelEnableSwitch = onlyEmployeesAllow();
      setState(() {});
    }
  }

  bool liveChatRoomEnable() {
    if (_liveInfo.extensionConfig != null) {
      var map = jsonDecode(_liveInfo.extensionConfig!);
      return map['liveChatRoomEnable'] ?? false;
    }
    return true;
  }

  bool onlyEmployeesAllow() {
    if (_liveInfo.extensionConfig != null) {
      var map = jsonDecode(_liveInfo.extensionConfig!);
      return map['onlyEmployeesAllow'] ?? false;
    }
    return false;
  }

  List<String?> liveUidFromJson() {
    if (_liveInfo.extensionConfig != null) {
      liveUids.clear();
      var map = jsonDecode(_liveInfo.extensionConfig!);
      var uids = (map['listUids'] ?? []) as List;
      liveUids.addAll(uids.map((e) => e as String?).toList());
    }
    filterLiveUids();
    return liveUids;
  }

  /// 在有 已选中的用户离开的时候要重新过滤下
  void filterLiveUids() {
    liveUids.removeWhere((userId) {
      final user = _arguments.roomContext.getMember(userId.toString());
      return user == null || (!user.isVideoOn && !user.isSharingScreen);
    });
  }

  //修正直播视图布局，但不更新字段
  NERoomLiveLayout determineLiveLayoutType() {
    final screenSharingUserId =
        _arguments.roomContext.rtcController.getScreenSharingUserUuid();
    if (screenSharingUserId != null && liveUids.contains(screenSharingUserId)) {
      return NERoomLiveLayout.screenShare;
    }
    return liveLayout;
  }

  void initPassword() {
    livePassword = _liveInfo.password;
    livePwdSwitch = !TextUtils.isEmpty(livePassword);
    _livePasswordController = TextEditingController(text: livePassword);
  }

  void generatePassword() {
    livePassword = (Random().nextInt(passwordRange) + basePassword).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TitleBar(
          title: TitleBarTitle(
            NEMeetingUIKitLocalizations.of(context)!.liveMeeting,
          ),
        ),
        backgroundColor: _UIColors.globalBg,
        body: ListView(
          children: <Widget>[
            buildSpace(),
            buildTitleWithState(),
            buildSpace(),
            buildLiveUrl(),
            ...buildPwdWithState(),
            buildSpace(),
            buildLiveInteraction(),
            buildSpace(),
            buildLiveLevel(),
            buildSpace(),
            buildViewItem(),
            _buildSplit(),
            buildViewPreview(),
            buildViewTips(),
            buildActionButton()
          ],
        ));
  }

  Widget buildSpace() {
    return Container(
      color: _UIColors.globalBg,
      height: 20,
    );
  }

  Widget _buildSplit() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 20),
      height: 1,
      child: Divider(height: 1),
    );
  }

  Widget buildTitleWithState() {
    if (_liveInfo.state == NERoomLiveState.started) {
      return buildNotModifyTitle();
    }
    return buildTitle();
  }

  Widget buildNotModifyTitle() {
    return Container(
      height: 56,
      color: Colors.white,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        _liveInfo.title ?? '',
        style: TextStyle(fontSize: 16, color: _UIColors.black_222222),
      ),
    );
  }

  Widget buildTitle() {
    return Container(
      height: 56,
      color: Colors.white,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        key: MeetingUIValueKeys.inputLiveTitle,
        autofocus: false,
        focusNode: _focusNode,
        controller: _liveTitleController,
        keyboardAppearance: Brightness.light,
        textAlign: TextAlign.left,
        inputFormatters: [
          LengthLimitingTextInputFormatter(30),
        ],
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
            hintText:
                '${NEMeetingUIKitLocalizations.of(context)!.liveMeetingTitle}',
            hintStyle: TextStyle(fontSize: 16, color: _UIColors.color_999999),
            border: InputBorder.none,
            suffixIcon: _focusNode.hasFocus &&
                    !TextUtils.isEmpty(_liveTitleController.text)
                ? ClearIconButton(
                    key: MeetingUIValueKeys.clearInputLiveTitle,
                    onPressed: () {
                      _liveTitleController.clear();
                      setState(() {});
                    })
                : null),
        style: TextStyle(color: _UIColors.color_222222, fontSize: 16),
      ),
    );
  }

  Widget buildLiveUrl() {
    return buildCopyItem(
        MeetingUIValueKeys.copyLiveUrl,
        NEMeetingUIKitLocalizations.of(context)!.liveMeetingUrl,
        _arguments.liveAddress ?? '');
  }

  Widget buildCopyItem(Key key, String itemTitle, String itemDetail) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: itemTitle,
                        style: TextStyle(
                            fontSize: 16, color: _UIColors.black_222222)),
                    TextSpan(
                        text: '   $itemDetail',
                        style: TextStyle(
                            fontSize: 16, color: _UIColors.color_999999))
                  ]),
                  softWrap: false,
                  overflow: TextOverflow.fade)),
          GestureDetector(
            key: key,
            child: Text(NEMeetingUIKitLocalizations.of(context)!.globalCopy,
                style: TextStyle(fontSize: 14, color: _UIColors.blue_337eff)),
            onTap: () {
              Clipboard.setData(ClipboardData(text: itemDetail));
              ToastUtils.showToast(context,
                  NEMeetingUIKitLocalizations.of(context)!.globalCopySuccess);
            },
          ),
        ],
      ),
    );
  }

  List<Widget> buildPwdWithState() {
    if (_liveInfo.state == NERoomLiveState.started) {
      return TextUtils.isEmpty(_liveInfo.password)
          ? []
          : [buildSpace(), buildNotModifyPwd()];
    } else {
      return [
        buildSpace(),
        buildPwd(),
        if (livePwdSwitch) _buildSplit(),
        if (livePwdSwitch) buildPwdInput(),
      ];
    }
  }

  Widget buildNotModifyPwd() {
    return buildCopyItem(
        MeetingUIValueKeys.copyLivePassword,
        NEMeetingUIKitLocalizations.of(context)!.livePassword,
        _liveInfo.password!);
  }

  Widget buildPwd() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              NEMeetingUIKitLocalizations.of(context)!.livePassword,
              style: TextStyle(color: _UIColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingUIValueKeys.addTextWidgetTest(
              valueKey: MeetingUIValueKeys.livePwdSwitch, value: livePwdSwitch),
          CupertinoSwitch(
              key: MeetingUIValueKeys.livePwdSwitch,
              value: livePwdSwitch,
              onChanged: (bool value) {
                setState(() {
                  livePwdSwitch = value;
                  if (livePwdSwitch &&
                      TextUtils.isEmpty(_livePasswordController.text)) {
                    generatePassword();
                    _livePasswordController.text = livePassword ?? '';
                  }
                });
              },
              activeColor: _UIColors.blue_337eff)
        ],
      ),
    );
  }

  Widget buildPwdInput() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: TextField(
        key: MeetingUIValueKeys.livePwdInput,
        autofocus: false,
        keyboardAppearance: Brightness.light,
        controller: _livePasswordController,
        keyboardType: TextInputType.number,
        focusNode: _passwordFocusNode,
        inputFormatters: [
          LengthLimitingTextInputFormatter(6),
          FilteringTextInputFormatter.allow(RegExp(r'\d+')),
        ],
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
            hintText:
                '${NEMeetingUIKitLocalizations.of(context)!.liveEnterLiveSixDigitPassword}',
            hintStyle: TextStyle(fontSize: 14, color: _UIColors.color_999999),
            border: InputBorder.none,
            suffixIcon: !_passwordFocusNode.hasFocus ||
                    TextUtils.isEmpty(_livePasswordController.text)
                ? null
                : ClearIconButton(
                    key: MeetingUIValueKeys.clearInputLivePassword,
                    onPressed: () {
                      _livePasswordController.clear();
                      setState(() {
                        livePassword = null;
                      });
                    })),
        style: TextStyle(color: _UIColors.color_222222, fontSize: 16),
      ),
    );
  }

  Widget buildLiveInteraction() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(NEMeetingUIKitLocalizations.of(context)!.liveInteraction,
                      style: TextStyle(
                          color: _UIColors.black_222222, fontSize: 16)),
                  Text(
                      NEMeetingUIKitLocalizations.of(context)!
                          .liveInteractionTips,
                      style: TextStyle(
                          color: _UIColors.color_999999, fontSize: 12)),
                ],
              )),
          CupertinoSwitch(
              key: MeetingUIValueKeys.liveInteraction,
              value: chatRoomEnableSwitch,
              onChanged: (bool value) {
                setState(() {
                  chatRoomEnableSwitch = value;
                });
              },
              activeColor: _UIColors.blue_337eff)
        ],
      ),
    );
  }

  Widget buildLiveLevel() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.only(left: 20, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(NEMeetingUIKitLocalizations.of(context)!.liveLevel,
                      style: TextStyle(
                          color: _UIColors.black_222222, fontSize: 16)),
                  Text(NEMeetingUIKitLocalizations.of(context)!.liveLevelTip,
                      style: TextStyle(
                          color: _UIColors.color_999999, fontSize: 12)),
                ],
              )),
          CupertinoSwitch(
              key: MeetingUIValueKeys.liveLevel,
              value: liveLevelEnableSwitch,
              onChanged: (bool value) {
                if (_liveInfo.state != NERoomLiveState.started) {
                  setState(() {
                    liveLevelEnableSwitch = value;
                  });
                } else {
                  ToastUtils.showToast(
                      context,
                      NEMeetingUIKitLocalizations.of(context)!
                          .liveDisableAuthLevel);
                }
              },
              activeColor: _UIColors.blue_337eff)
        ],
      ),
    );
  }

  Widget buildViewItem() {
    return GestureDetector(
        key: MeetingUIValueKeys.liveLayoutSetting,
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
          showMeetingPopupPageRoute(
            context: context,
            builder: (context) {
              return MeetingLiveSettingPage(
                _arguments,
                NERoomLiveInfo(
                  title: _liveTitleController.text,
                  liveLayout: liveLayout,
                  userUuidList: liveUids,
                ),
              );
            },
            routeSettings: RouteSettings(name: 'MeetingLiveSettingPage'),
          ).then((value) {
            if (value is NERoomLiveInfo) {
              viewChange =
                  !listEquals(value.userUuidList, _liveInfo.userUuidList) ||
                      (_liveInfo.liveLayout != value.liveLayout &&
                          value.liveLayout != NERoomLiveLayout.screenShare);
              liveUids.clear();
              if (value.userUuidList != null)
                liveUids.addAll(value.userUuidList!);
              if (value.liveLayout != NERoomLiveLayout.screenShare) {
                liveLayout = value.liveLayout;
              }
              setState(() {});
            }
          });
        },
        child: Container(
          height: 56,
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              Text(NEMeetingUIKitLocalizations.of(context)!.liveViewSetting,
                  style:
                      TextStyle(fontSize: 16, color: _UIColors.black_222222)),
              Spacer(),
              viewTips(),
              SizedBox(
                width: 8,
              ),
              Icon(NEMeetingIconFont.icon_yx_allowx,
                  size: 14, color: _UIColors.greyCCCCCC)
            ],
          ),
        ));
  }

  Widget viewTips() {
    if (_liveInfo.state == NERoomLiveState.init) {
      return Text(
          liveUids.isNotEmpty
              ? '${NEMeetingUIKitLocalizations.of(context)!.livePickerCount(liveUids.length)}'
              : '',
          style: TextStyle(fontSize: 14, color: _UIColors.color_999999));
    } else if (viewChange && _liveInfo.state != NERoomLiveState.ended) {
      return Text(
          NEMeetingUIKitLocalizations.of(context)!.liveViewSettingChange,
          style: TextStyle(fontSize: 14, color: _UIColors.colorEB352B));
    }
    return Container();
  }

  Widget buildViewTips() {
    return Container(
        height: 45,
        color: _UIColors.white,
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(top: 8),
        child: Text(
          NEMeetingUIKitLocalizations.of(context)!.liveViewPreviewTips,
          style: TextStyle(fontSize: 12, color: _UIColors.color_999999),
        ));
  }

  Widget buildViewPreview() {
    Widget preview;
    if (liveUids.isEmpty) {
      preview = Text(
        NEMeetingUIKitLocalizations.of(context)!.liveViewPreviewDesc,
        style: TextStyle(color: _UIColors.black_333333, fontSize: 12),
        textAlign: TextAlign.center,
      );
    } else {
      switch (determineLiveLayoutType()) {
        case NERoomLiveLayout.focus:
          preview = buildFocusPreviewChild();
          break;
        case NERoomLiveLayout.screenShare:
          preview = buildScreenSharePreviewChild();
          break;
        default:
          preview = buildGalleryPreviewChild();
      }
    }
    // assert((){
    //   preview = buildScreenSharePreviewChild(debugCount: 4);
    //   return true;
    // }());
    return Container(
        height: 116,
        color: Colors.white,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 20),
        child: Container(
          width: 160,
          height: 96,
          child: preview,
          alignment: Alignment.center,
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
              border: Border.all(color: _UIColors.colorE1E3E6),
              borderRadius: BorderRadius.all(Radius.circular(2))),
        ));
  }

  Widget buildFocusPreviewChild() {
    if (liveUids.length == 1) {
      return Container(color: _UIColors.colorEBEDF0, child: buildIndex(1));
    } else {
      return Row(
        children: [
          Container(
              height: 82,
              width: 101,
              color: _UIColors.colorEBEDF0,
              child: buildIndex(1)),
          SizedBox(width: 2),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 26,
                  width: 43,
                  color: _UIColors.colorEBEDF0,
                  child: buildIndex(2)),
              if (liveUids.length > 2) SizedBox(height: 2),
              if (liveUids.length > 2)
                Container(
                    height: 26,
                    width: 43,
                    color: _UIColors.colorEBEDF0,
                    child: buildIndex(3)),
              if (liveUids.length > 3) SizedBox(height: 2),
              if (liveUids.length > 3)
                Container(
                    height: 26,
                    width: 43,
                    color: _UIColors.colorEBEDF0,
                    child: buildIndex(4)),
            ],
          )
        ],
      );
    }
  }

  Widget buildGalleryPreviewChild() {
    if (liveUids.length == 1) {
      return Container(color: _UIColors.colorEBEDF0, child: buildIndex(1));
    } else if (liveUids.length == 2) {
      return buildPreviewItem(0);
    } else if (liveUids.length == 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildPreviewItem(0),
          SizedBox(height: 2),
          Container(
              height: 40,
              width: 72,
              color: _UIColors.colorEBEDF0,
              child: buildIndex(3)),
        ],
      );
    } else {
      return Column(
        children: [
          buildPreviewItem(0),
          SizedBox(height: 2),
          buildPreviewItem(2),
        ],
      );
    }
  }

  Widget buildScreenSharePreviewChild({int? debugCount}) {
    assert(liveUids.isNotEmpty || debugCount != null);
    final count = debugCount ?? liveUids.length;
    return Column(
      children: [
        Expanded(
          child: Container(
            color: _UIColors.colorEBEDF0,
          ),
        ),
        SizedBox(height: 4),
        Row(
          children: List.generate(count * 2 - 1, (index) {
            return index.isOdd
                ? SizedBox(width: 4, height: 27)
                : Expanded(
                    child: Container(
                      height: 27,
                      color: _UIColors.colorEBEDF0,
                      child: buildIndex((index / 2).floor() + 1),
                    ),
                  );
          }),
        ),
      ],
    );
  }

  Widget buildPreviewItem(int base) {
    return Row(
      children: [
        Container(
            height: 40,
            width: 72,
            color: _UIColors.colorEBEDF0,
            child: buildIndex(base + 1)),
        SizedBox(width: 2),
        Container(
            height: 40,
            width: 72,
            color: _UIColors.colorEBEDF0,
            child: buildIndex(base + 2))
      ],
    );
  }

  Widget buildIndex(int index) {
    return Center(
      child: CircleAvatar(
        maxRadius: 10,
        backgroundColor: _UIColors.color_337eff,
        child:
            Text('$index', style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  Widget buildActionButton() {
    if (_liveInfo.state == NERoomLiveState.started) {
      return Row(children: [
        Expanded(child: buildUpdate()),
        SizedBox(width: 9),
        Expanded(child: buildStop())
      ]);
    } else {
      return Container(
        margin: EdgeInsets.only(top: 35, bottom: 35, left: 20, right: 20),
        child: MeetingTextButton.fill(
          key: MeetingUIValueKeys.liveStartBtn,
          text: NEMeetingUIKitLocalizations.of(context)!.liveStart,
          onPressed:
              (TextUtils.isEmpty(_liveTitleController.text) || liveUids.isEmpty)
                  ? null
                  : () {
                      updateLiveParams(NERoomLiveState.init, checkParams: true);
                    },
        ),
      );
    }
  }

  Widget buildUpdate() {
    return Container(
      margin: EdgeInsets.only(top: 35, bottom: 35, left: 20),
      child: MeetingTextButton.fill(
        key: MeetingUIValueKeys.liveUpdateBtn,
        onPressed: isStateDirty()
            ? () {
                updateLiveParams(NERoomLiveState.started, checkParams: true);
              }
            : null,
        text: NEMeetingUIKitLocalizations.of(context)!.liveUpdate,
      ),
    );
  }

  bool isStateDirty() {
    var live = _liveInfo;
    return liveChatRoomEnable() != chatRoomEnableSwitch ||
        live.password != livePassword ||
        live.liveLayout != liveLayout ||
        !listEquals(live.userUuidList, liveUids) ||
        viewChange;
  }

  Widget buildStop() {
    return Container(
      padding: EdgeInsets.only(top: 35, bottom: 35, right: 20),
      child: MeetingTextButton.fill(
        key: MeetingUIValueKeys.liveStopBtn,
        backgroundColor: _UIColors.colorE6352B,
        onPressed: () {
          updateLiveParams(NERoomLiveState.ended);
        },
        text: NEMeetingUIKitLocalizations.of(context)!.liveStop,
      ),
    );
  }

  void updateLiveParams(NERoomLiveState status, {bool checkParams = false}) {
    if (checkParams) {
      livePassword = _livePasswordController.text.trim();
      if (livePwdSwitch == true) {
        if (TextUtils.isEmpty(livePassword)) {
          ToastUtils.showToast(context,
              NEMeetingUIKitLocalizations.of(context)!.liveEnterLivePassword);
          return;
        } else if (livePassword!.length != 6) {
          ToastUtils.showToast(
              context,
              NEMeetingUIKitLocalizations.of(context)!
                  .liveEnterLiveSixDigitPassword);
          return;
        }
      }
    }
    ConnectivityManager().isConnected().then((connected) {
      if (!connected) {
        ToastUtils.showToast(context,
            NEMeetingUIKitLocalizations.of(context)!.networkUnavailableCheck);
      } else {
        // var live = NEInRoomLiveInfo()
        //   ..password = livePwdSwitch ? (livePassword ?? '') : ''
        //   ..userList = liveUids
        //   ..liveChatRoomEnable = chatRoomEnableSwitch
        //   ..webAccessControlLevel = liveLevelEnableSwitch ? NELiveAuthLevel.appToken : NELiveAuthLevel.token
        //   ..title = _liveTitleController.text
        //   ..liveLayout = liveLayout == NELiveLayout.none ? NELiveLayout.gallery : liveLayout;
        var password = livePwdSwitch ? (livePassword ?? '') : '';
        var live = NERoomLiveRequest(
          title: _liveTitleController.text,
          liveLayout: liveLayout == NERoomLiveLayout.none
              ? NERoomLiveLayout.gallery
              : liveLayout,
          password: password,
          userUuidList: liveUids,
          extensionConfig: jsonEncode({
            'liveChatRoomEnable': chatRoomEnableSwitch,
            'onlyEmployeesAllow': liveLevelEnableSwitch,
            'listUids': liveUids
          }),
        );
        handleLive(status, live);
      }
    });
  }

  void handleLive(NERoomLiveState status, NERoomLiveRequest live) async {
    if (status == NERoomLiveState.init) {
      final result = await liveStreamController.startLive(live);
      if (!mounted) return;
      if (result.isSuccess()) {
        ToastUtils.showToast(
            context, NEMeetingUIKitLocalizations.of(context)!.liveStartSuccess);
        Navigator.pop(context, true);
      } else {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.liveStartFail);
      }
    } else if (status == NERoomLiveState.started) {
      final result = await liveStreamController.updateLive(live);
      if (!mounted) return;
      if (result.isSuccess()) {
        ToastUtils.showToast(context,
            NEMeetingUIKitLocalizations.of(context)!.liveUpdateSuccess);
        Navigator.pop(context, true);
      } else {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.liveUpdateFail);
      }
    } else {
      final result = await liveStreamController.stopLive();
      if (!mounted) return;
      if (result.isSuccess()) {
        Navigator.pop(context, true);
        ToastUtils.showToast(
            context, NEMeetingUIKitLocalizations.of(context)!.liveStopSuccess);
      } else {
        ToastUtils.showToast(
            context,
            result.msg ??
                NEMeetingUIKitLocalizations.of(context)!.liveStopFail);
      }
    }
  }

  @override
  void dispose() {
    _liveTitleController.dispose();
    _livePasswordController.dispose();
    _focusNode.dispose();
    _passwordFocusNode.dispose();
    _roomContext.removeEventCallback(roomEventCallback!);
    super.dispose();
  }
}
