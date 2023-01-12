// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class VirtualBackgroundPage extends StatefulWidget {
  final NERoomContext roomContext;
  final NERtcVideoRenderer? renderer;
  final bool muteVideo;
  final Function() callback;

  VirtualBackgroundPage({
    Key? key,
    required this.roomContext,
    required this.renderer,
    required this.muteVideo,
    required this.callback,
  });

  @override
  _VirtualBackgroundPageState createState() => _VirtualBackgroundPageState();
}

class _VirtualBackgroundPageState extends BaseState<VirtualBackgroundPage> {
  NERtcVideoRenderer? renderer;
  late int beautyLevel;
  late NEPreviewRoomRtcController? previewRoomRtcController;
  late double width;
  late double height;
  late NERoomContext roomContext;
  List<String> sourceList = <String>['-'];
  List<String>? addExternalVirtualList;
  late int currentSelected = 0;
  static late SharedPreferences _sharedPreferences;
  bool bCanPress = true;
  List<NEMeetingVirtualBackground> builtinVirtualBackgroundList = [];
  @override
  void initState() {
    super.initState();
    roomContext = widget.roomContext;
    renderer = widget.renderer;
    _checkPermission().then((granted) {
      if (granted) {
        NERoomKit.instance.roomService
            .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions())
            .then((value) {
          previewRoomRtcController = value.nonNullData.previewController;
          _initRenderer();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return WillPopScope(
        child: Scaffold(
            body: Container(
          color: Colors.black,
          width: width,
          height: height,
          child: buildVirtualPreViewWidget(context),
        )),
        onWillPop: () async {
          _requestPop();
          return false;
        });
  }

  Widget buildVirtualPreViewWidget(BuildContext context) {
    return Stack(children: <Widget>[
      buildCallingVideoViewWidget(context),
      Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: buildAction(),
      )
    ]);
  }

  Widget buildAction() {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          // color: Color.fromARGB(33, 33, 41, 1),
          color: _UIColors.white,
          height: 78,
          width: width,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sourceList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
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
                          _sharedPreferences,
                          addExternalVirtualList, (List<String>? list) {
                        addExternalVirtualList = list;
                      });
                    }
                    if (selected) {
                      currentSelected = index;
                      _sharedPreferences.setInt(
                          currentVirtualSelectedKey, currentSelected);
                      enableVirtualBackground(previewRoomRtcController,
                          index != 0, sourceList[index]);
                      setState(() {});
                    }
                  },
                );
              }),
        ),
        Container(
          height: 48,
          alignment: Alignment.bottomCenter,
          color: _UIColors.white,
          child: Row(children: <Widget>[
            Opacity(
              opacity: currentSelected > virtualListMax &&
                      currentSelected < sourceList.length - 1
                  ? 1.0
                  : 0.0,
              child: GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(NEMeetingUIKitLocalizations.of(context)!.delete,
                        style: TextStyle(color: Colors.grey)),
                  ),
                  onTap: () async {
                    if (bCanPress) {
                      bCanPress = false;
                      Future.delayed(Duration(milliseconds: 200), () {
                        bCanPress = true;
                        if (currentSelected > virtualListMax) {
                          try {
                            sourceList.removeAt(currentSelected);
                            int addExternalVirtualListIndex =
                                currentSelected - virtualListMax - 1;
                            if (addExternalVirtualListIndex <
                                    (addExternalVirtualList?.length ?? 0) &&
                                addExternalVirtualListIndex >= 0) {
                              addExternalVirtualList
                                  ?.removeAt(addExternalVirtualListIndex);
                            }
                            if (currentSelected <=
                                    builtinVirtualBackgroundList.length &&
                                currentSelected > 0) {
                              builtinVirtualBackgroundList
                                  .removeAt(currentSelected - 1);
                              NEMeetingKit.instance
                                  .getSettingsService()
                                  .setBuiltinVirtualBackgrounds(
                                      builtinVirtualBackgroundList);
                              if (builtinVirtualBackgroundList.length == 0) {
                                _sharedPreferences.setBool(
                                    builtinVirtualBackgroundListAllDelKey,
                                    true);
                              }
                            }
                          } catch (e) {
                            Alog.e(
                              tag: _tag,
                              moduleName: _moduleName,
                              content: '==== BuiltinVirtualBackgrounds$e ',
                            );
                          }
                          _sharedPreferences.setInt(
                              currentVirtualSelectedKey, 0);
                          currentSelected = 0;
                          if (addExternalVirtualList != null) {
                            _sharedPreferences.setStringList(
                                addExternalVirtualListKey,
                                addExternalVirtualList!);
                          }
                        }
                        enableVirtualBackground(
                            previewRoomRtcController, false, '');
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
                  NEMeetingUIKitLocalizations.of(context)!.sure,
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
          NEMeetingUIKitLocalizations.of(context)!.cameraPermission);
      if (!granted) UINavUtils.pop(context);
    }
    return granted;
  }

  Widget buildCallingVideoViewWidget(BuildContext context) {
    return renderer != null && !widget.muteVideo
        ? NERtcVideoView(renderer!)
        : Container();
  }

  Future<void> _initRenderer() async {
    Directory? cache;
    if (Platform.isAndroid) {
      cache = await getExternalStorageDirectory();
    } else {
      cache = await getApplicationDocumentsDirectory();
    }
    if (!widget.muteVideo) renderer?.attachToLocalVideo();

    ///默认的前6张
    var setting = NEMeetingKit.instance.getSettingsService();
    builtinVirtualBackgroundList = await setting.getBuiltinVirtualBackgrounds();
    await previewRoomRtcController?.startBeauty();
    await previewRoomRtcController?.enableBeauty(true);
    _sharedPreferences = await SharedPreferences.getInstance();
    bool builtinVirtualBackgroundListAllDelete =
        _sharedPreferences.getBool(builtinVirtualBackgroundListAllDelKey) ??
            false;
    if (builtinVirtualBackgroundList.isNotEmpty &&
            builtinVirtualBackgroundList.length > 0 ||
        builtinVirtualBackgroundListAllDelete) {
      builtinVirtualBackgroundList.forEach((element) {
        sourceList.add(element.path);
      });
      sourceList = replaceBundleId(cache!.path, sourceList);
    } else {
      for (var i = 1; i <= 6; ++i) {
        String filePath = '${cache?.path}/virtual/$i.png';
        File file = File(filePath);
        var exist = await file.exists();
        if (exist) {
          sourceList.add(filePath);
        }
      }
    }

    addExternalVirtualList =
        _sharedPreferences.getStringList(addExternalVirtualListKey);
    if (addExternalVirtualList != null && addExternalVirtualList!.length > 0) {
      addExternalVirtualList =
          replaceBundleId(cache!.path, addExternalVirtualList!);
      sourceList.addAll(addExternalVirtualList!);
    }
    sourceList.add('+');
    currentSelected = _sharedPreferences.getInt(currentVirtualSelectedKey) ?? 0;
    if (currentSelected != 0) {
      enableVirtualBackground(
          previewRoomRtcController, true, sourceList[currentSelected]);
    }
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) setState(() {});
    });
  }

  void _requestPop() {
    // beautyController
    //     .setBeautyFaceValue(beautyLevel);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    widget.callback();
    super.dispose();
  }
}
