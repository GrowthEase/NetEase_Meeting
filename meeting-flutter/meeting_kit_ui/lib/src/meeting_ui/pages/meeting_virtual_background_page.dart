// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class VirtualBackgroundPage extends StatefulWidget {
  final NERoomContext roomContext;
  final NERoomUserVideoStreamSubscriber videoStreamSubscriber;
  final ValueListenable<bool> mirrorListenable;

  VirtualBackgroundPage({
    Key? key,
    required this.roomContext,
    required this.mirrorListenable,
    required this.videoStreamSubscriber,
  });

  @override
  _VirtualBackgroundPageState createState() => _VirtualBackgroundPageState();
}

class _VirtualBackgroundPageState extends BaseState<VirtualBackgroundPage> {
  late NERoomRtcController rtcController;
  late NERoomContext roomContext;
  List<String> sourceList = <String>['-'];
  List<String>? addExternalVirtualList;
  int currentSelected = 0;
  final _settingsService = NEMeetingKit.instance.getSettingsService();
  bool bCanPress = true;
  List<NEMeetingVirtualBackground> builtinVirtualBackgroundList = [];
  int _builtInVirtualBackgroundPicSize = 0;

  @override
  void initState() {
    super.initState();
    roomContext = widget.roomContext;
    rtcController = roomContext.rtcController;
    _checkPermission().then((granted) {
      if (granted) {
        _initVirtualBackgroundPictures();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            body: Container(
          color: Colors.black,
          child: buildVirtualPreViewWidget(context),
        )),
        onWillPop: () async {
          _requestPop();
          return false;
        });
  }

  Widget buildVirtualPreViewWidget(BuildContext context) {
    return NERoomUserVideoStreamSubscriberProvider(
      subscriber: widget.videoStreamSubscriber,
      child: Stack(
        children: <Widget>[
          ValueListenableBuilder<bool>(
            valueListenable: widget.mirrorListenable,
            builder: (context, mirror, child) {
              return NERoomUserVideoView(
                roomContext.myUuid,
                mirror: mirror,
                debugName: roomContext.localMember.name,
              );
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              color: _UIColors.white,
              child: SafeArea(
                top: false,
                child: buildAction(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAction() {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          // color: Color.fromARGB(33, 33, 41, 1),
          height: 78,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sourceList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  key: MeetingUIValueKeys.virtualBackgroundItem,
                  child: Container(
                      width: 68,
                      height: 68,
                      margin: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(33, 33, 41, 1),
                        border: Border.all(
                            color: currentSelected == index
                                ? _UIColors.color_007AFF
                                : _UIColors.white,
                            width: 2,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(4), // 设置四周圆角
                      ),
                      child: buildItem(context, index, sourceList)),
                  onTap: () async {
                    bool selected = true;
                    if (index < sourceList.length - 1) {
                    } else {
                      if (addExternalVirtualList != null &&
                          addExternalVirtualList!.length >=
                              addExternalVirtualMax) {
                        ToastUtils.showToast(
                            context,
                            NEMeetingUIKitLocalizations.of(context)!
                                .virtualBackgroundImageMax);
                        setState(() {});
                        return;
                      }
                      selected = await pickFiles(
                          context,
                          sourceList,
                          _settingsService,
                          addExternalVirtualList, (List<String>? list) {
                        addExternalVirtualList = list;
                      });
                    }
                    if (selected) {
                      currentSelected = index;
                      _settingsService
                          .setCurrentVirtualBackgroundSelected(currentSelected);
                      enableVirtualBackground(
                          rtcController, index != 0, sourceList[index]);
                      if (!mounted) return;
                      setState(() {});
                    }
                  },
                );
              }),
        ),
        Container(
          height: 48,
          alignment: Alignment.bottomCenter,
          child: Row(children: <Widget>[
            Opacity(
              opacity: currentSelected > _builtInVirtualBackgroundPicSize &&
                      currentSelected < sourceList.length - 1
                  ? 1.0
                  : 0.0,
              child: GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                        NEMeetingUIKitLocalizations.of(context)!.globalDelete,
                        style: TextStyle(color: Colors.grey)),
                  ),
                  onTap: () async {
                    if (bCanPress) {
                      bCanPress = false;
                      Future.delayed(Duration(milliseconds: 200), () {
                        bCanPress = true;
                        if (currentSelected >
                            _builtInVirtualBackgroundPicSize) {
                          try {
                            sourceList.removeAt(currentSelected);
                            int addExternalVirtualListIndex = currentSelected -
                                _builtInVirtualBackgroundPicSize -
                                1;
                            if (addExternalVirtualListIndex <
                                    (addExternalVirtualList?.length ?? 0) &&
                                addExternalVirtualListIndex >= 0) {
                              addExternalVirtualList
                                  ?.removeAt(addExternalVirtualListIndex);
                            }
                          } catch (e) {
                            Alog.e(
                              tag: _tag,
                              moduleName: _moduleName,
                              content: '==== BuiltinVirtualBackgrounds$e ',
                            );
                          }
                          _settingsService
                              .setCurrentVirtualBackgroundSelected(0);
                          currentSelected = 0;
                          if (addExternalVirtualList != null) {
                            _settingsService.setExternalVirtualBackgrounds(
                                addExternalVirtualList!);
                          }
                        }
                        enableVirtualBackground(rtcController, false, '');
                        setState(() {});
                      });
                    }
                  }),
            ),
            Expanded(
              child: Center(
                child: Text(
                    NEMeetingUIKitLocalizations.of(context)!
                        .virtualBackgroundSelectTip,
                    style: TextStyle(color: Colors.black)),
              ),
            ),
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: Text(
                  NEMeetingUIKitLocalizations.of(context)!.globalSure,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              onTap: () => _requestPop(),
            ),
          ]),
        ),
      ],
    );
  }

  Future<bool> _checkPermission() async {
    var granted = (await Permission.camera.status) == PermissionStatus.granted;
    if (!granted) {
      granted = await PermissionHelper.requestPermissionSingle(
          context,
          Permission.camera,
          '',
          NEMeetingUIKitLocalizations.of(context)!.meetingCamera);
      if (!granted && ModalRoute.of(context)?.isActive == true)
        UINavUtils.pop(context);
    }
    return granted;
  }

  Future<void> _initVirtualBackgroundPictures() async {
    Directory? cache;
    if (Platform.isAndroid) {
      cache = await getExternalStorageDirectory();
    } else {
      cache = await getApplicationDocumentsDirectory();
    }

    builtinVirtualBackgroundList =
        await _settingsService.getBuiltinVirtualBackgrounds();
    if (builtinVirtualBackgroundList.isNotEmpty) {
      _builtInVirtualBackgroundPicSize = builtinVirtualBackgroundList.length;
      builtinVirtualBackgroundList.forEach((element) {
        sourceList.add(element.path);
      });
      sourceList = replaceBundleId(cache!.path, sourceList);
    } else {
      for (var i = 1; i <= 9; ++i) {
        String filePath = '${cache?.path}/virtual/$i.png';
        File file = File(filePath);
        var exist = await file.exists();
        if (exist) {
          sourceList.add(filePath);
          _builtInVirtualBackgroundPicSize++;
        }
      }
    }

    addExternalVirtualList =
        await _settingsService.getExternalVirtualBackgrounds();
    if (addExternalVirtualList != null && addExternalVirtualList!.length > 0) {
      addExternalVirtualList =
          replaceBundleId(cache!.path, addExternalVirtualList!);
      sourceList.addAll(addExternalVirtualList!);
    }
    sourceList.add('+');
    currentSelected =
        await _settingsService.getCurrentVirtualBackgroundSelected();
    if (currentSelected != 0) {
      enableVirtualBackground(rtcController, true, sourceList[currentSelected]);
    }
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) setState(() {});
    });
  }

  void _requestPop() {
    Navigator.of(context).pop();
  }
}
