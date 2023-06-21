// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class PreVirtualBackgroundPage extends StatefulWidget {
  PreVirtualBackgroundPage({Key? key});

  @override
  _PreVirtualBackgroundPageState createState() =>
      _PreVirtualBackgroundPageState();
}

class _PreVirtualBackgroundPageState
    extends BaseState<PreVirtualBackgroundPage> {
  NERtcVideoRenderer? renderer;
  NEPreviewRoomRtcController? previewRoomRtcController;
  List<String> sourceList = <String>[virtualNone];
  List<String>? addExternalVirtualList;
  int currentSelected = 0;
  static late SharedPreferences _sharedPreferences;
  bool allowedDeleteAll = false;
  bool bCanPress = true;
  NEPreviewRoomContext? previewRoomContext;
  late final NEPreviewRoomEventCallback eventCallback;
  @override
  void initState() {
    super.initState();
    eventCallback = NEPreviewRoomEventCallback(
        rtcVirtualBackgroundSourceEnabled: onRtcVirtualBackgroundSourceEnabled);
    NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions())
        .then((value) {
      previewRoomContext = value.nonNullData;
      previewRoomContext?.addEventCallback(eventCallback);
      previewRoomRtcController = previewRoomContext?.previewController;
      _checkPermission().then((granted) {
        if (granted) {
          _initRenderer();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            body: Container(
          color: Colors.white,
          child: buildBeautyPreViewWidget(context),
        )),
        onWillPop: () async {
          _requestPop();
          return false;
        });
  }

  Widget buildBeautyPreViewWidget(BuildContext context) {
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
          color: Colors.white,
          height: 78,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sourceList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  child: Container(
                      width: 68,
                      // height: 48,
                      margin: EdgeInsets.all(4),
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
                      // color: UIColors.grey_8F8F8F,
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
          color: Colors.white,
          child: Row(children: <Widget>[
            Opacity(
              opacity: (currentSelected > virtualListMax &&
                          currentSelected < sourceList.length - 1) ||
                      allowedDeleteAll
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
                          enableVirtualBackground(
                              previewRoomRtcController, false, '');
                        }
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
      if (!granted) UINavUtils.pop(context, rootNavigator: true);
    }
    return granted;
  }

  Widget buildCallingVideoViewWidget(BuildContext context) {
    return renderer != null ? NERtcVideoView(renderer!) : Container();
  }

  Future<void> _initRenderer() async {
    renderer = await NERtcVideoRendererFactory.createVideoRenderer('');
    await renderer!.attachToLocalVideo();
    renderer!.setMirror(true);
    await previewRoomRtcController?.startPreview();
    Directory? cache;
    if (Platform.isAndroid) {
      cache = await getExternalStorageDirectory();
    } else {
      cache = await getApplicationDocumentsDirectory();
    }

    ///默认的前6张
    var setting = NEMeetingKit.instance.getSettingsService();

    var list = await setting.getBuiltinVirtualBackgrounds();
    await previewRoomRtcController?.startBeauty();
    await previewRoomRtcController?.enableBeauty(true);

    _sharedPreferences = await SharedPreferences.getInstance();

    if (list.isNotEmpty && list.length > 0) {
      for (var element in list) {
        sourceList.add(element.path);
      }
      sourceList = replaceBundleId(cache!.path, sourceList);
      allowedDeleteAll = true;
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
    if (mounted) setState(() {});
  }

  void _requestPop() => Navigator.of(context).pop();

  @override
  void dispose() {
    previewRoomRtcController?.stopPreview();
    enableVirtualBackground(previewRoomRtcController, false, '');
    previewRoomContext?.removeEventCallback(eventCallback);
    renderer?.dispose();
    super.dispose();
  }

  void onRtcVirtualBackgroundSourceEnabled(bool enabled, int reason) {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content:
            'preview onRtcVirtualBackgroundSourceEnabled enabled=$enabled,reason:$reason');
    switch (reason) {
      case NERoomVirtualBackgroundSourceStateReason.kImageNotExist:
        ToastUtils.showToast(
            context,
            NEMeetingUIKitLocalizations.of(context)!
                .virtualBackgroundImageNotExist);
        break;
      case NERoomVirtualBackgroundSourceStateReason.kImageFormatNotSupported:
        ToastUtils.showToast(
            context,
            NEMeetingUIKitLocalizations.of(context)!
                .virtualBackgroundImageFormatNotSupported);
        break;
      case NERoomVirtualBackgroundSourceStateReason.kDeviceNotSupported:
        ToastUtils.showToast(
            context,
            NEMeetingUIKitLocalizations.of(context)!
                .virtualBackgroundImageDeviceNotSupported);
        break;
    }
  }
}

List<String> replaceBundleId(String replaceStr, List<String> list) {
  if (Platform.isIOS) {
    List<String> convertList = [];
    for (var e in list) {
      if (e == virtualNone) {
        convertList.add(virtualNone);
      } else {
        convertList.add(replaceBundleIdByStr(e, replaceStr));
      }
    }
    return convertList;
  }
  return list;
}

String replaceBundleIdByStr(String e, String replaceStr) {
  String str = '';
  if (Platform.isIOS) {
    List<String> patterns = e.split('/');
    patterns[6] = replaceStr.split('/')[6];
    for (var element in patterns) {
      if (element.isNotEmpty) {
        str = str + '/' + element;
      }
    }
    return str;
  }
  return e;
}

void enableVirtualBackground(NERoomBaseRtcController? previewRoomRtcController,
    bool enable, String path) async {
  final result = await previewRoomRtcController?.enableVirtualBackground(
      enable,
      NERoomVirtualBackgroundSource(
          backgroundSourceType: NERoomVirtualBackgroundType.kBackgroundImg,
          source: path,
          color: 0,
          blurDegree: NERoomVirtualBackgroundType.kBlurDegreeHigh));
  debugPrint('enableVirtualBackground result:$result');
}

Future<bool> pickFiles(
    BuildContext context,
    List<String> sourceList,
    SharedPreferences _sharedPreferences,
    List<String>? addExternalVirtualList,
    void Function(List<String>?) callback) async {
  bool selected = false;
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
  );
  if (result != null && result.files.length > 0) {
    final file = result.files.first;
    String originPath = file.path!;
    String originName = file.name;
    if (!(const {'jpg', 'png', 'jpeg'}.contains(file.extension))) {
      ToastUtils.showToast(
          context,
          NEMeetingUIKitLocalizations.of(context)!
              .virtualBackgroundImageFormatNotSupported);
      return false;
    }
    File originFile = File(originPath);
    int size = await originFile.length();
    int mb = 1024 * 1024;

    ///定义MB的计算常量
    if (size >= 5 * mb) {
      ToastUtils.showToast(context,
          NEMeetingUIKitLocalizations.of(context)!.virtualBackgroundImageLarge);
      return false;
    }
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }
    String path = '${directory!.path}/virtual/$originName';
    final contents = await originFile.readAsBytes();
    File('$path')
      ..createSync(recursive: true)
      ..writeAsBytes(contents);
    sourceList.removeLast();
    sourceList.add(path);
    addExternalVirtualList =
        _sharedPreferences.getStringList(addExternalVirtualListKey);
    if (addExternalVirtualList == null || addExternalVirtualList.length <= 0) {
      addExternalVirtualList = <String>[];
    }
    addExternalVirtualList.add(path);
    _sharedPreferences.setStringList(
        addExternalVirtualListKey, addExternalVirtualList);
    sourceList.add('+');
    selected = true;
  } else {
    Alog.i(
        tag: _tag,
        moduleName: _moduleName,
        content: 'User canceled the picker');
    // User canceled the picker
    selected = false;
  }
  callback(addExternalVirtualList);
  return selected;
}

Widget buildItem(BuildContext context, int index, List<String> sourceList) {
  Widget view = Container();
  final density = MediaQuery.of(context).devicePixelRatio.ceil();
  if (index == 0) {
    view = Container(
      alignment: Alignment.center,
      child: Text(
        NEMeetingUIKitLocalizations.of(context)!.nothing,
        style: TextStyle(color: Colors.black),
      ),
    );
  } else if (index > 0 && index < sourceList.length - 1) {
    view = Center(
        child: Image.file(
      File(sourceList[index]),
      width: 68,
      height: 68,
      fit: BoxFit.fill,
      cacheWidth: 68 * density,
      cacheHeight: 68 * density,
    ));
  } else if (index == sourceList.length - 1) {
    view = Container(
      child: Icon(NEMeetingIconFont.icon_unfold, color: _UIColors.black_333333),
    );
  }
  return view;
}
