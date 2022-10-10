// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingLiveSettingPage extends StatefulWidget {
  final LiveArguments _arguments;

  final NERoomLiveInfo _live;

  MeetingLiveSettingPage(this._arguments, this._live);

  @override
  State<StatefulWidget> createState() {
    return MeetingLiveSettingState(_arguments, _live);
  }
}

class MeetingLiveSettingState
    extends LifecycleBaseState<MeetingLiveSettingPage> {
  final LiveArguments _arguments;

  final NERoomLiveInfo _live;

  MeetingLiveSettingState(this._arguments, this._live);

  List<String> availableLiveUids = [];

  /// 哪些用户可被选择直播
  List<String?> liveUids = [];

  /// 哪些用户已经被选择了推流

  NERoomLiveLayout liveLayout = NERoomLiveLayout.none;

  late NERoomContext roomContext;
  late NERoomLiveController liveStreamController;

  @override
  void initState() {
    super.initState();
    roomContext = _arguments.roomContext;
    liveStreamController = roomContext.liveController;
    if (_live.userUuidList != null) {
      liveUids.addAll(_live.userUuidList!);
    }
    filterAvailableUsers();
    determineLiveLayoutType();
    lifecycleListen(_arguments.roomInfoUpdatedEventStream, (_) {
      filterLiveUids();
      filterAvailableUsers();
      determineLiveLayoutType();
      setState(() {});
    });
  }

  bool isUserValidForLive(NERoomMember? user) =>
      user != null &&
      user.isVisible &&
      (user.isVideoOn || user.isSharingScreen);

  void filterAvailableUsers() {
    availableLiveUids = roomContext
        .getAllUsers()
        .where((user) {
          return isUserValidForLive(user);
        })
        .map((user) => user.uuid)
        .toList();
  }

  /// 在有 已选中的用户离开的时候要重新过滤下
  void filterLiveUids() {
    liveUids.removeWhere(
        (uuid) => !isUserValidForLive(roomContext.getMember(uuid)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _UIColors.white,
      appBar: buildAppBar(context),
      body: buildBody(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: Text(_Strings.liveViewSetting,
            style: TextStyle(color: _UIColors.color_222222, fontSize: 17)),
        centerTitle: true,
        backgroundColor: _UIColors.white,
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          TextButton(
              child: Text(_Strings.save,
                  style:
                      TextStyle(color: _UIColors.color_337eff, fontSize: 16.0)),
              onPressed: () {
                final newList = [...liveUids]..removeWhere((userId) {
                    final user = roomContext.getMember(userId.toString());
                    return user == null || !isUserValidForLive(user);
                  });
                Navigator.pop(
                    context,
                    liveLayout != NERoomLiveLayout.none
                        ? (NERoomLiveInfo(title: _live.title)
                          ..liveLayout = liveLayout
                          ..userUuidList = newList)
                        : null);
              })
        ],
        leading: GestureDetector(
          child: Container(
              alignment: Alignment.center,
              key: MeetingUIValueKeys.liveLayoutClose,
              child: Text(_Strings.close,
                  style: TextStyle(color: _UIColors.blue_337eff, fontSize: 16),
                  textAlign: TextAlign.center)),
          onTap: () {
            Navigator.pop(context);
          },
        ));
  }

  Widget buildBody() {
    return Container(
        color: _UIColors.globalBg,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildViewCountTips(),
              Container(
                color: Colors.white,
                height: 329,
                child:
                    availableLiveUids.isNotEmpty ? buildMembers() : Container(),
              ),
              buildViewTips(),
              buildViewPreview(),
            ],
          ),
        ));
  }

  Widget buildViewTips() {
    return Container(
      height: 48,
      color: _UIColors.globalBg,
      padding: EdgeInsets.only(left: 20, top: 20),
      child: Text(_Strings.liveChooseView,
          style: TextStyle(fontSize: 14, color: _UIColors.color_999999)),
    );
  }

  Widget buildViewPreview() {
    final children = [
      if (liveLayout != NERoomLiveLayout.screenShare ||
          liveLayout == NERoomLiveLayout.none)
        buildPreview(
            buildGalleryView(liveLayout == NERoomLiveLayout.gallery),
            MeetingUIValueKeys.liveLayoutGallery,
            _Strings.liveGalleryView,
            liveUids.isEmpty
                ? null
                : () {
                    if (liveLayout != NERoomLiveLayout.gallery) {
                      setState(() {
                        liveLayout = NERoomLiveLayout.gallery;
                      });
                    }
                  },
            liveLayout == NERoomLiveLayout.gallery),
      if (liveLayout != NERoomLiveLayout.screenShare ||
          liveLayout == NERoomLiveLayout.none)
        buildPreview(
            buildFocusView(liveLayout == NERoomLiveLayout.focus),
            MeetingUIValueKeys.liveLayoutFocus,
            _Strings.liveFocusView,
            liveUids.isEmpty
                ? null
                : () {
                    if (liveLayout != NERoomLiveLayout.focus) {
                      setState(() {
                        liveLayout = NERoomLiveLayout.focus;
                      });
                    }
                  },
            liveLayout == NERoomLiveLayout.focus),
      if (liveLayout == NERoomLiveLayout.screenShare ||
          (liveLayout == NERoomLiveLayout.none && liveUids.isEmpty))
        buildPreview(
            buildScreenShareView(liveLayout == NERoomLiveLayout.screenShare),
            MeetingUIValueKeys.liveLayoutScreenShare,
            _Strings.liveScreenShareView,
            null,
            liveLayout == NERoomLiveLayout.screenShare),
    ];
    final horizontalPadding = (children.length <= 2 ? 63 : 20).toDouble();
    return Container(
        color: Colors.white,
        height: 120,
        padding:
            EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
        child: Row(
          mainAxisAlignment: children.length >= 2
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: children,
        ));
  }

  Widget buildScreenShareView(bool isSelect) {
    return Column(
      children: [
        Expanded(
          child: Container(
              color: isSelect ? _UIColors.color_337eff : _UIColors.colorEBEDF0),
        ),
        SizedBox(height: 2),
        Row(
          children: List.generate(7, (index) {
            return index.isOdd
                ? SizedBox(width: 2)
                : Expanded(
                    child: Container(
                      height: 16,
                      color: isSelect
                          ? _UIColors.color_337eff
                          : _UIColors.colorEBEDF0,
                    ),
                  );
          }),
        ),
      ],
    );
  }

  Widget buildFocusView(bool isSelect) {
    return Row(
      children: [
        Container(
            width: 63,
            color: isSelect ? _UIColors.color_337eff : _UIColors.colorEBEDF0),
        SizedBox(width: 2),
        Expanded(
          child: Column(
            children: List.generate(
              5,
              (index) => index.isEven
                  ? Expanded(
                      child: Container(
                        color: isSelect
                            ? _UIColors.color_337eff
                            : _UIColors.colorEBEDF0,
                      ),
                    )
                  : SizedBox(
                      height: 2,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGalleryView(bool isSelect) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                    color: isSelect
                        ? _UIColors.color_337eff
                        : _UIColors.colorEBEDF0),
              ),
              SizedBox(width: 2),
              Expanded(
                child: Container(
                    color: isSelect
                        ? _UIColors.color_337eff
                        : _UIColors.colorEBEDF0),
              ),
            ],
          ),
        ),
        SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                    color: isSelect
                        ? _UIColors.color_337eff
                        : _UIColors.colorEBEDF0),
              ),
              SizedBox(width: 2),
              Expanded(
                child: Container(
                    color: isSelect
                        ? _UIColors.color_337eff
                        : _UIColors.colorEBEDF0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPreview(Widget child, ValueKey key, String viewType,
      VoidCallback? callback, bool isSelect) {
    return GestureDetector(
        key: key,
        onTap: callback,
        child: Column(
          children: [
            Container(
              width: 100,
              height: 60,
              child: child,
              alignment: Alignment.center,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: isSelect
                          ? _UIColors.color_337eff
                          : _UIColors.colorE1E3E6),
                  borderRadius: BorderRadius.all(Radius.circular(2))),
            ),
            SizedBox(height: 6),
            Text(viewType)
          ],
        ));
  }

  Widget buildViewCountTips() {
    return Container(
      height: 48,
      color: _UIColors.globalBg,
      padding: EdgeInsets.only(left: 20, top: 20),
      child: Text(
        _Strings.liveChooseCountTips,
        style: TextStyle(fontSize: 16, color: _UIColors.color_999999),
      ),
    );
  }

  Widget buildMembers() {
    return ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        primary: false,
        cacheExtent: 48,
        itemCount: availableLiveUids.length + 1,
        itemBuilder: (context, index) {
          if (index == availableLiveUids.length) {
            return SizedBox(height: 1);
          }
          return buildMemberItem(index);
        },
        separatorBuilder: (context, index) {
          return Divider(height: 1, color: _UIColors.globalBg);
        });
  }

  Widget buildMemberItem(int index) {
    final user = roomContext.getMember(availableLiveUids[index])!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(user.uuid),
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                user.name,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: _UIColors.color_333333,
                    decoration: TextDecoration.none),
              ),
            ),
            buildIndex(user.uuid)
          ],
        ),
      ),
    );
  }

  Widget buildIndex(String uid) {
    if (liveUids.contains(uid)) {
      return Center(
        child: CircleAvatar(
          maxRadius: 10,
          backgroundColor: _UIColors.color_337eff,
          child: Text('${liveUids.indexOf(uid) + 1}',
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      );
    } else {
      return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              border: Border.all(color: _UIColors.colorE1E3E6),
              borderRadius: BorderRadius.all(Radius.circular(10))));
    }
  }

  void _onTap(String uid) {
    if (liveUids.contains(uid)) {
      liveUids.remove(uid);
    } else if (liveUids.length < 4) {
      liveUids.add(uid);
    }
    determineLiveLayoutType();
    setState(() {});
  }

  void determineLiveLayoutType() {
    if (liveLayout == NERoomLiveLayout.none) {
      liveLayout = _live.liveLayout;
    }
    if (liveUids.isEmpty) {
      liveLayout = NERoomLiveLayout.none;
    } else if (liveLayout == NERoomLiveLayout.none ||
        liveLayout == NERoomLiveLayout.screenShare) {
      liveLayout = NERoomLiveLayout.gallery;
    }
    final screenSharingUserId =
        roomContext.rtcController.getScreenSharingUserUuid();
    if (screenSharingUserId != null && liveUids.contains(screenSharingUserId)) {
      liveLayout = NERoomLiveLayout.screenShare;
    }
  }
}
