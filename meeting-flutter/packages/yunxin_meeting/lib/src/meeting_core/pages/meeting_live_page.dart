// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

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

  late TextEditingController _liveTitleController, _livePasswordController;

  bool livePwdSwitch = false;
  bool chatRoomEnableSwitch = true;
  bool liveLevelEnableSwitch = false;

  String? livePassword;

  static const int passwordRange = 900000, basePassword = 100000, oneDay = 24 * 60 * 60 * 1000;

  var liveUids = <String>[];

  NELiveLayout liveLayout = NELiveLayout.none;

  bool viewChange = false;

  late NEInRoomService inRoomService;
  late NEInRoomLiveStreamController liveStreamController;

  @override
  void initState() {
    super.initState();
    inRoomService = NERoomKit.instance.getInRoomService()!;
    liveStreamController = inRoomService.getInRoomLiveStreamController();

    _liveTitleController = TextEditingController(text: _arguments.live.title ?? inRoomService.getCurrentRoomInfo()!.subject);
    initPassword();
    if (_arguments.live.userList != null) {
      liveUids.addAll(_arguments.live.userList!);
    }
    _handViewChange(updateState: false);
    liveLayout = _arguments.live.liveLayout;
    chatRoomEnableSwitch = _arguments.live.liveChatRoomEnable;
    liveLevelEnableSwitch = _arguments.live.webAccessControlLevel == NELiveAuthLevel.appToken;
    lifecycleListen(_arguments.roomInfoUpdatedEventStream, (_) {
      _handViewChange();
    });
  }

  //修正直播视图布局，但不更新字段
  NELiveLayout determineLiveLayoutType() {
    final screenSharingUserId = inRoomService.getInRoomScreenShareController().getScreenSharingUserId();
    if (screenSharingUserId != null && liveUids.contains(screenSharingUserId)) {
      return NELiveLayout.screenShare;
    }
    return liveLayout;
  }

  void _handViewChange({bool updateState = true}) {
    var tempUids = <String>[...liveUids];
    liveUids.removeWhere((userId) {
      final user = inRoomService.getUserInfoById(userId);
      return user == null || (user.videoStatus != NERoomVideoStatus.on && !user.isScreenSharing);
    });
    viewChange = !listEquals(tempUids, liveUids);
    if (updateState) {
      setState(() {});
    }
  }

  void initPassword() {
    if (_arguments.live.state == NERoomItemLiveState.started) {
      livePassword = _arguments.live.password;
      if (TextUtils.isEmpty(livePassword)) {
        livePwdSwitch = false;
      }
    } else {
      generatePassword();
    }
    _livePasswordController = TextEditingController(text: livePassword);
  }

  void generatePassword() {
    livePassword = (Random().nextInt(passwordRange) + basePassword).toString();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: UIColors.white,
        appBar: buildAppBar(context),
        //body: SafeArea(top: false, left: false, right: false, child: buildBody()),
        body: buildBody(),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: Text(
          Strings.meetingLive,
          style: TextStyle(color: UIColors.color_222222, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: UIColors.white,
        elevation: 0.0,
        brightness: Brightness.light,
        leading: GestureDetector(
          child: Container(
            alignment: Alignment.center,
            key: MeetingCoreValueKey.chatRoomClose,
            child: Text(
              Strings.close,
              style: TextStyle(color: UIColors.blue_337eff, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ));
  }

  Widget buildBody() {
    return Container(
        color: UIColors.globalBg,
        child: SafeArea(
          child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        ))));
              })),
        ));
  }

  Widget buildSpace() {
    return Container(
      color: UIColors.globalBg,
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
    if (_arguments.live.state == NERoomItemLiveState.started) {
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
        _arguments.live.title ?? '',
        style: TextStyle(fontSize: 16, color: UIColors.black_222222),
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
        key: MeetingCoreValueKey.inputLiveTitle,
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
            hintText: '${Strings.meetingLiveTitle}',
            hintStyle: TextStyle(fontSize: 16, color: UIColors.color_999999),
            border: InputBorder.none,
            suffixIcon: _focusNode.hasFocus && !TextUtils.isEmpty(_liveTitleController.text)
                ? ClearIconButton(
                    key: MeetingCoreValueKey.clearInputLiveTitle,
                    onPressed: () {
                      _liveTitleController.clear();
                      setState(() {});
                    })
                : null),
        style: TextStyle(color: UIColors.color_222222, fontSize: 16),
      ),
    );
  }

  Widget buildLiveUrl() {
    return buildCopyItem(MeetingCoreValueKey.copyLiveUrl, Strings.meetingLiveUrl, _arguments.live.liveUrl!);
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
                    TextSpan(text: itemTitle, style: TextStyle(fontSize: 16, color: UIColors.black_222222)),
                    TextSpan(
                        text: '   $itemDetail', style: TextStyle(fontSize: 16, color: UIColors.color_999999))
                  ]),
                  softWrap: false,
                  overflow: TextOverflow.fade)),
          GestureDetector(
            key: key,
            child: Text(Strings.copy, style: TextStyle(fontSize: 14, color: UIColors.blue_337eff)),
            onTap: () {
              Clipboard.setData(ClipboardData(text: itemDetail));
              ToastUtils.showToast(context, Strings.copySuccess);
            },
          ),
        ],
      ),
    );
  }

  List<Widget> buildPwdWithState() {
    if (_arguments.live.state == NERoomItemLiveState.started) {
      return TextUtils.isEmpty(_arguments.live.password) ? [] : [buildSpace(), buildNotModifyPwd()];
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
    return buildCopyItem(MeetingCoreValueKey.copyLivePassword, Strings.livePassword, _arguments.live.password!);
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
              Strings.livePassword,
              style: TextStyle(color: UIColors.black_222222, fontSize: 16),
            ),
          ),
          MeetingCoreValueKey.addTextWidgetTest(valueKey: MeetingCoreValueKey.livePwdSwitch, value: livePwdSwitch),
          CupertinoSwitch(
              key: MeetingCoreValueKey.livePwdSwitch,
              value: livePwdSwitch,
              onChanged: (bool value) {
                setState(() {
                  livePwdSwitch = value;
                  if (livePwdSwitch && TextUtils.isEmpty(_livePasswordController.text)) {
                    generatePassword();
                    _livePasswordController.text = livePassword??'';
                  }
                });
              },
              activeColor: UIColors.blue_337eff)
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
        key: MeetingCoreValueKey.livePwdInput,
        autofocus: false,
        keyboardAppearance: Brightness.light,
        controller: _livePasswordController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(6),
          FilteringTextInputFormatter.allow(RegExp(r'\d+')),
        ],
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
            hintText: '${Strings.pleaseInputLivePasswordHint}',
            hintStyle: TextStyle(fontSize: 14, color: UIColors.color_999999),
            border: InputBorder.none,
            suffixIcon: TextUtils.isEmpty(_livePasswordController.text)
                ? null
                : ClearIconButton(
                    key: MeetingCoreValueKey.clearInputLivePassword,
                    onPressed: () {
                      _livePasswordController.clear();
                      setState(() {
                        livePassword = null;
                      });
                    })),
        style: TextStyle(color: UIColors.color_222222, fontSize: 16),
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
                  Text(Strings.liveInteraction, style: TextStyle(color: UIColors.black_222222, fontSize: 16)),
                  Text(Strings.liveInteractionTips, style: TextStyle(color: UIColors.color_999999, fontSize: 12)),
                ],
              )),
          MeetingCoreValueKey.addTextWidgetTest(
              valueKey: MeetingCoreValueKey.liveInteraction, value: chatRoomEnableSwitch),
          CupertinoSwitch(
              key: MeetingCoreValueKey.liveInteraction,
              value: chatRoomEnableSwitch,
              onChanged: (bool value) {
                setState(() {
                  chatRoomEnableSwitch = value;
                });
              },
              activeColor: UIColors.blue_337eff)
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
                  Text(Strings.liveLevel, style: TextStyle(color: UIColors.black_222222, fontSize: 16)),
                  Text(Strings.liveLevelTip, style: TextStyle(color: UIColors.color_999999, fontSize: 12)),
                ],
              )),
          MeetingCoreValueKey.addTextWidgetTest(valueKey: MeetingCoreValueKey.liveLevel, value: liveLevelEnableSwitch),
          CupertinoSwitch(
              key: MeetingCoreValueKey.liveLevel,
              value: liveLevelEnableSwitch,
              onChanged: (bool value) {
                if (_arguments.live.state != NERoomItemLiveState.started) {
                  setState(() {
                    liveLevelEnableSwitch = value;
                  });
                } else {
                  ToastUtils.showToast(context, Strings.disableLiveAuthLevel);
                }
              },
              activeColor: UIColors.blue_337eff)
        ],
      ),
    );
  }

  Widget buildViewItem() {
    return GestureDetector(
        key: MeetingCoreValueKey.liveLayoutSetting,
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return MeetingLiveSettingPage(
                _arguments,
                NEInRoomLiveInfo()
                  ..liveLayout = liveLayout
                  ..userList = [...liveUids]);
          })).then((value) {
            if (value is NEInRoomLiveInfo) {
              viewChange = !listEquals(value.userList, liveUids) ||
                  (liveLayout != value.liveLayout && value.liveLayout != NELiveLayout.screenShare);
              liveUids.clear();
              if (value.userList != null) liveUids.addAll(value.userList!);
              if (value.liveLayout != NELiveLayout.screenShare) {
                liveLayout = value.liveLayout;
              }
              if (viewChange) {
                setState(() {});
              }
            }
          });
        },
        child: Container(
          height: 56,
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              Text(Strings.liveViewSetting, style: TextStyle(fontSize: 16, color: UIColors.black_222222)),
              Spacer(),
              viewTips(),
              SizedBox(
                width: 8,
              ),
              Icon(NEMeetingIconFont.icon_yx_allowx, size: 14, color: UIColors.greyCCCCCC)
            ],
          ),
        ));
  }

  Widget viewTips() {
    if (_arguments.live.state == NERoomItemLiveState.init) {
      return Text(
          liveUids.isNotEmpty ? '${Strings.livePickerCount}${liveUids.length}${Strings.livePickerCountPrefix}' : '',
          style: TextStyle(fontSize: 14, color: UIColors.color_999999));
    } else if (viewChange) {
      return Text(Strings.liveViewSettingChange, style: TextStyle(fontSize: 14, color: UIColors.colorEB352B));
    }
    return Container();
  }

  Widget buildViewTips() {
    return Container(
        height: 45,
        color: UIColors.white,
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(top: 8),
        child: Text(
          Strings.liveViewPreviewTips,
          style: TextStyle(fontSize: 12, color: UIColors.color_999999),
        ));
  }

  Widget buildViewPreview() {
    Widget preview;
    if (liveUids.isEmpty) {
      preview = Text(
        Strings.liveViewPreviewDesc,
        style: TextStyle(color: UIColors.black_333333, fontSize: 12),
        textAlign: TextAlign.center,
      );
    } else {
      switch (determineLiveLayoutType()) {
        case NELiveLayout.focus:
          preview = buildFocusPreviewChild();
          break;
        case NELiveLayout.screenShare:
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
              border: Border.all(color: UIColors.colorE1E3E6), borderRadius: BorderRadius.all(Radius.circular(2))),
        ));
  }

  Widget buildFocusPreviewChild() {
    if (liveUids.length == 1) {
      return Container(color: UIColors.colorEBEDF0, child: buildIndex(1));
    } else {
      return Row(
        children: [
          Container(height: 82, width: 101, color: UIColors.colorEBEDF0, child: buildIndex(1)),
          SizedBox(width: 2),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 26, width: 43, color: UIColors.colorEBEDF0, child: buildIndex(2)),
              if (liveUids.length > 2) SizedBox(height: 2),
              if (liveUids.length > 2)
                Container(height: 26, width: 43, color: UIColors.colorEBEDF0, child: buildIndex(3)),
              if (liveUids.length > 3) SizedBox(height: 2),
              if (liveUids.length > 3)
                Container(height: 26, width: 43, color: UIColors.colorEBEDF0, child: buildIndex(4)),
            ],
          )
        ],
      );
    }
  }

  Widget buildGalleryPreviewChild() {
    if (liveUids.length == 1) {
      return Container(color: UIColors.colorEBEDF0, child: buildIndex(1));
    } else if (liveUids.length == 2) {
      return buildPreviewItem(0);
    } else if (liveUids.length == 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildPreviewItem(0),
          SizedBox(height: 2),
          Container(height: 40, width: 72, color: UIColors.colorEBEDF0, child: buildIndex(3)),
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
            color: UIColors.colorEBEDF0,
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
                      color: UIColors.colorEBEDF0,
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
        Container(height: 40, width: 72, color: UIColors.colorEBEDF0, child: buildIndex(base + 1)),
        SizedBox(width: 2),
        Container(height: 40, width: 72, color: UIColors.colorEBEDF0, child: buildIndex(base + 2))
      ],
    );
  }

  Widget buildIndex(int index) {
    return Center(
      child: CircleAvatar(
        maxRadius: 10,
        backgroundColor: UIColors.color_337eff,
        child: Text('$index', style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  Widget buildActionButton() {
    if (_arguments.live.state == NERoomItemLiveState.started) {
      return Row(children: [Expanded(child: buildUpdate()), SizedBox(width: 9), Expanded(child: buildStop())]);
    } else {
      return Container(
        margin: EdgeInsets.only(top: 35, bottom: 35, left: 20, right: 20),
        child: ElevatedButton(
          key: MeetingCoreValueKey.liveStartBtn,
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.disabled)) {
                  return UIColors.blue_50_337eff;
                }
                return UIColors.blue_337eff;
              }),
              padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 13)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25))))),
          onPressed: (TextUtils.isEmpty(_liveTitleController.text) || liveUids.isEmpty)
              ? null
              : () {
                  updateLiveParams(NERoomItemLiveState.init, checkParams: true);
                },
          child: Text(
            Strings.liveStart,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget buildUpdate() {
    return Container(
      margin: EdgeInsets.only(top: 35, bottom: 35, left: 20),
      child: ElevatedButton(
        key: MeetingCoreValueKey.liveUpdateBtn,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return UIColors.blue_50_337eff;
              }
              return UIColors.blue_337eff;
            }),
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical:13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: isUpdate()
            ? () {
                updateLiveParams(NERoomItemLiveState.started, checkParams: true);
              }
            : null,
        child: Text(
          Strings.liveUpdate,
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  bool isUpdate() {
    var live = _arguments.live;
    return live.liveChatRoomEnable != chatRoomEnableSwitch ||
        live.password != livePassword ||
        live.liveLayout != liveLayout ||
        !listEquals(live.userList, liveUids);
  }

  Widget buildStop() {
    return Container(
      padding: EdgeInsets.only(top: 35, bottom: 35, right: 20),
      child: ElevatedButton(
        key: MeetingCoreValueKey.liveStopBtn,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              return UIColors.colorE6352B;
            }),
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical:13)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))))),
        onPressed: () {
          updateLiveParams(NERoomItemLiveState.ended);
        },
        child: Text(
          Strings.liveStop,
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void updateLiveParams(NERoomItemLiveState status, {bool checkParams = false}) {
    if (checkParams) {
      livePassword = _livePasswordController.text.trim();
      if (livePwdSwitch == true) {
        if (TextUtils.isEmpty(livePassword)) {
          ToastUtils.showToast(context, Strings.pleaseInputLivePassword);
          return;
        } else if (livePassword!.length != 6) {
          ToastUtils.showToast(context, Strings.pleaseInputLivePasswordHint);
          return;
        }
      }
    }
    Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.none) {
        ToastUtils.showToast(context, Strings.networkUnavailableCheck);
      } else {
        var live = NEInRoomLiveInfo()
          ..password = livePwdSwitch ? (livePassword ?? '') : ''
          ..userList = liveUids
          ..liveChatRoomEnable = chatRoomEnableSwitch
          ..webAccessControlLevel = liveLevelEnableSwitch ? NELiveAuthLevel.appToken : NELiveAuthLevel.token
          ..title = _liveTitleController.text
          ..liveLayout = liveLayout == NELiveLayout.none ? NELiveLayout.gallery : liveLayout;
        handleLive(status, live);
      }
    });
  }

  void handleLive(NERoomItemLiveState status, NEInRoomLiveInfo live) async {
    if (status == NERoomItemLiveState.init) {
      final result = await liveStreamController.startLiveStream(live);
      if (!mounted) return;
      if (result.isSuccess()) {
        ToastUtils.showToast(context, Strings.liveStartSuccess);
        Navigator.pop(context);
      } else {
        ToastUtils.showToast(context, result.msg ?? Strings.liveStartFail);
      }
    } else if (status == NERoomItemLiveState.started) {
      final result = await liveStreamController.updateLiveStream(live);
      if (!mounted) return;
      if (result.isSuccess()) {
        ToastUtils.showToast(context, Strings.liveUpdateSuccess);
        Navigator.pop(context);
      } else {
        ToastUtils.showToast(context, result.msg ?? Strings.liveUpdateFail);
      }
    } else {
      final result = await liveStreamController.stopLiveStream();
      if (!mounted) return;
      if (result.isSuccess()) {
        Navigator.pop(context);
        ToastUtils.showToast(context, Strings.liveStopSuccess);
      } else {
        ToastUtils.showToast(context, result.msg ?? Strings.liveStopFail);
      }
    }
  }

  @override
  void dispose() {
    _liveTitleController.dispose();
    _livePasswordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
