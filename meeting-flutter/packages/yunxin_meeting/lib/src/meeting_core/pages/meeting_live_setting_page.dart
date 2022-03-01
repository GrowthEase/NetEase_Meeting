// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class MeetingLiveSettingPage extends StatefulWidget {
  final LiveArguments _arguments;

  final NEInRoomLiveInfo _live;

  MeetingLiveSettingPage(this._arguments, this._live);

  @override
  State<StatefulWidget> createState() {
    return MeetingLiveSettingState(_arguments, _live);
  }
}

class MeetingLiveSettingState extends LifecycleBaseState<MeetingLiveSettingPage> {
  final LiveArguments _arguments;

  final NEInRoomLiveInfo _live;

  MeetingLiveSettingState(this._arguments, this._live);

  List<String> availableLiveUids = [];
  List<String> liveUids = [];

  NELiveLayout liveLayout = NELiveLayout.none;

  late NEInRoomService inRoomService;
  late NEInRoomLiveStreamController liveStreamController;

  @override
  void initState() {
    super.initState();
    inRoomService = NERoomKit.instance.getInRoomService()!;
    liveStreamController = inRoomService.getInRoomLiveStreamController();
    if (_live.userList != null) {
      liveUids.addAll(_live.userList!);
    }
    filterAvailableUsers();
    determineLiveLayoutType();
    lifecycleListen(_arguments.roomInfoUpdatedEventStream, (_) {
      filterAvailableUsers();
      determineLiveLayoutType();
      setState(() {});
    });
  }

  bool isUserValidForLive(NEInRoomUserInfo user) =>
      !RoleType.isHide(user.roleType) &&
          (user.videoStatus == NERoomVideoStatus.on ||
              user.isScreenSharing);

  void filterAvailableUsers() {
    availableLiveUids = inRoomService
        .getAllUsers()
        .where((user) {
          return isUserValidForLive(user);
        })
        .map((user) => user.userId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.white,
      appBar: buildAppBar(context),
      body: buildBody(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        title: Text(Strings.liveViewSetting, style: TextStyle(color: UIColors.color_222222, fontSize: 17)),
        centerTitle: true,
        backgroundColor: UIColors.white,
        elevation: 0.0,
        brightness: Brightness.light,
        actions: [
          TextButton(
              child: Text(Strings.save, style: TextStyle(color: UIColors.color_337eff, fontSize: 16.0)),
              onPressed: () {
                final newList = [...liveUids]..removeWhere((userId) {
                  final user = inRoomService.getUserInfoById(userId);
                  return user == null || !isUserValidForLive(user);
                });
                Navigator.pop(
                    context,
                    liveLayout != NELiveLayout.none ?
                    (NEInRoomLiveInfo()
                      ..liveLayout = liveLayout
                      ..userList = newList)
                        : null
                );
              })
        ],
        leading: GestureDetector(
          child: Container(
              alignment: Alignment.center,
              key: MeetingCoreValueKey.liveLayoutClose,
              child: Text(Strings.close,
                  style: TextStyle(color: UIColors.blue_337eff, fontSize: 16), textAlign: TextAlign.center)),
          onTap: () {
            Navigator.pop(context);
          },
        ));
  }

  Widget buildBody() {
    return Container(
        color: UIColors.globalBg,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildViewCountTips(),
              Container(
                color: Colors.white,
                height: 329,
                child: availableLiveUids.isNotEmpty ? buildMembers() : Container(),
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
      color: UIColors.globalBg,
      padding: EdgeInsets.only(left: 20, top: 20),
      child: Text(Strings.liveChooseView, style: TextStyle(fontSize: 14, color: UIColors.color_999999)),
    );
  }

  Widget buildViewPreview() {
    final children = [
      if (liveLayout != NELiveLayout.screenShare || liveLayout == NELiveLayout.none)
        buildPreview(buildGalleryView(liveLayout == NELiveLayout.gallery), MeetingCoreValueKey.liveLayoutGallery,
          Strings.liveGalleryView, liveUids.isEmpty ? null : () {
            if (liveLayout != NELiveLayout.gallery) {
              setState(() {
                liveLayout = NELiveLayout.gallery;
              });
            }
          }, liveLayout == NELiveLayout.gallery),
      if (liveLayout != NELiveLayout.screenShare || liveLayout == NELiveLayout.none)
        buildPreview(buildFocusView(liveLayout == NELiveLayout.focus), MeetingCoreValueKey.liveLayoutFocus,
          Strings.liveFocusView, liveUids.isEmpty ? null : () {
            if (liveLayout != NELiveLayout.focus) {
              setState(() {
                liveLayout = NELiveLayout.focus;
              });
            }
          }, liveLayout == NELiveLayout.focus),
      if (liveLayout == NELiveLayout.screenShare ||
          (liveLayout == NELiveLayout.none && liveUids.isEmpty))
      buildPreview(buildScreenShareView(liveLayout == NELiveLayout.screenShare), MeetingCoreValueKey.liveLayoutScreenShare,
          Strings.liveScreenShareView, null, liveLayout == NELiveLayout.screenShare),
    ];
    final horizontalPadding = (children.length <= 2 ? 63 : 20).toDouble();
    return Container(
        color: Colors.white,
        height: 120,
        padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
        child: Row(
          mainAxisAlignment: children.length >= 2 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
          children: children,
        ));
  }

  Widget buildScreenShareView(bool isSelect) {
    return Column(
      children: [
        Expanded(
          child: Container(
              color: isSelect ? UIColors.color_337eff : UIColors.colorEBEDF0),
        ),
        SizedBox(height: 2),
        Row(
          children: List.generate(7, (index) {
            return index.isOdd ? SizedBox(width: 2) : Expanded(
              child: Container(
                height: 16,
                color: isSelect ? UIColors.color_337eff : UIColors.colorEBEDF0,
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
        Container(width: 63, color: isSelect ? UIColors.color_337eff : UIColors.colorEBEDF0),
        SizedBox(width: 2),
        Expanded(
          child: Column(
            children: List.generate(
              5, (index) => index.isEven ? Expanded(
                child: Container(
                  color: isSelect ? UIColors.color_337eff : UIColors.colorEBEDF0,
                ),
              ) : SizedBox(height: 2,),
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
                child: Container(color: isSelect ? UIColors.color_337eff : UIColors.colorEBEDF0),
              ),
              SizedBox(width: 2),
              Expanded(
                child: Container(color: isSelect ? UIColors.color_337eff : UIColors.colorEBEDF0),
              ),
            ],
          ),
        ),
        SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(color: isSelect ? UIColors.color_337eff : UIColors.colorEBEDF0),
              ),
              SizedBox(width: 2),
              Expanded(
                child: Container(color: isSelect ? UIColors.color_337eff : UIColors.colorEBEDF0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPreview(Widget child, ValueKey key, String viewType, VoidCallback? callback, bool isSelect) {
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
                  border: Border.all(color: isSelect ? UIColors.color_337eff : UIColors.colorE1E3E6),
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
      color: UIColors.globalBg,
      padding: EdgeInsets.only(left: 20, top: 20),
      child: Text(
        Strings.liveChooseCountTips,
        style: TextStyle(fontSize: 16, color: UIColors.color_999999),
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
          return Divider(height: 1, color: UIColors.globalBg);
        });
  }

  Widget buildMemberItem(int index) {
    final user = inRoomService.getUserInfoById(availableLiveUids[index])!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(user.userId),
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                user.displayName,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: UIColors.color_333333,
                    decoration: TextDecoration.none),
              ),
            ),
            buildIndex(user.userId)
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
          backgroundColor: UIColors.color_337eff,
          child: Text('${liveUids.indexOf(uid) + 1}', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      );
    } else {
      return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              border: Border.all(color: UIColors.colorE1E3E6), borderRadius: BorderRadius.all(Radius.circular(10))));
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
    if (liveLayout == NELiveLayout.none) {
      liveLayout = _live.liveLayout;
    }
    if (liveUids.isEmpty) {
      liveLayout = NELiveLayout.none;
    } else if (liveLayout == NELiveLayout.none ||
        liveLayout == NELiveLayout.screenShare) {
      liveLayout = NELiveLayout.gallery;
    }
    final screenSharingUserId = inRoomService.getInRoomScreenShareController().getScreenSharingUserId();
    if (screenSharingUserId != null && liveUids.contains(screenSharingUserId)) {
      liveLayout = NELiveLayout.screenShare;
    }
  }
}
