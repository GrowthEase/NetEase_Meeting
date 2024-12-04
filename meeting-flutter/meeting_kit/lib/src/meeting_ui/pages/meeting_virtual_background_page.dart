// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class InMeetingVirtualBackgroundPage extends StatefulWidget {
  final NERoomContext roomContext;
  final NERoomUserVideoStreamSubscriber videoStreamSubscriber;
  final ValueListenable<bool> mirrorListenable;
  final ValueListenable<bool> videoMuteListenable;

  InMeetingVirtualBackgroundPage({
    Key? key,
    required this.roomContext,
    required this.mirrorListenable,
    required this.videoStreamSubscriber,
    required this.videoMuteListenable,
  });

  @override
  _VirtualBackgroundPageState createState() =>
      _InMeetingVirtualBackgroundPageState(
          rtcController: roomContext.rtcController);
}

class _InMeetingVirtualBackgroundPageState
    extends _VirtualBackgroundPageState<InMeetingVirtualBackgroundPage> {
  final NERoomRtcController? rtcController;
  VoidCallback? listener;

  _InMeetingVirtualBackgroundPageState({required this.rtcController});

  @override
  void initState() {
    super.initState();
    rtcController?.getVirtualBackgroundSupportedType().then((value) {
      supportedType = value;
    });
    checkPermission().then((granted) {
      if (granted) {
        _initVirtualBackgroundPictures();

        /// 会中关闭视频进入，仅开启视频，不推流
        _enableLocalVideo();
      }
    });

    widget.videoMuteListenable.addListener(listener = () {
      /// 在当前页面被关闭了视频
      _enableLocalVideo();
    });
  }

  void _enableLocalVideo() {
    if (widget.videoMuteListenable.value) {
      rtcController?.enableLocalVideo(true);
    }
  }

  Widget buildVideoView() {
    return NERoomUserVideoStreamSubscriberProvider(
      subscriber: widget.videoStreamSubscriber,
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.mirrorListenable,
        builder: (context, mirror, child) {
          return NERoomUserVideoView(
            widget.roomContext.myUuid,
            mirror: mirror,
            debugName: widget.roomContext.localMember.name,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (listener != null) {
      widget.videoMuteListenable.removeListener(listener!);
    }

    /// 会中关闭视频进入，关闭视频退出
    if (widget.videoMuteListenable.value) {
      rtcController?.enableLocalVideo(false);
    }
  }
}

abstract class _VirtualBackgroundPageState<T extends StatefulWidget>
    extends BaseState<T> {
  String? currentSelectedPath;

  final _settingsService = NEMeetingKit.instance.getSettingsService();
  List<String> builtinVirtualBackgroundList = [];
  List<String> externalVirtualBackgroundList = <String>[];
  bool virtualBackgroundIsEnable = false;
  NERoomVirtualBackgroundSupportedType supportedType =
      NERoomVirtualBackgroundSupportedType.kNEVirtualBackgroundSupportFull;

  NERoomBaseRtcController? get rtcController;

  double boxRatio = 80 / 46;

  final _virtualBackgroundPictureStream = StreamController<Object?>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NEMeetingKitUIStyle.setSystemUIOverlayStyle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          buildVideoView(),
          buildBottomDialog(),
          buildReturnIcon(),
        ],
      ),
    );
  }

  Widget buildVideoView();

  Widget buildReturnIcon() {
    return Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        child: IconButton(
          padding: EdgeInsets.all(5),
          key: MeetingUIValueKeys.back,
          icon: Icon(NEMeetingIconFont.icon_yx_returnx,
              color: _UIColors.white, size: 14),
          onPressed: () {
            UINavUtils.pop(context);
          },
        ));
  }

  Widget buildBottomDialog() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: _UIColors.black.withOpacity(0.8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          children: [
            buildTitle(),
            Container(
              height: 240,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildSelector(),
                    if (builtinVirtualBackgroundList.isNotEmpty)
                      buildDefaultSelector(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Row(
      children: [
        Spacer(),
        Container(
          height: 44,
          alignment: Alignment.center,
          child: Text(
            NEMeetingUIKit.instance.getUIKitLocalizations().virtualBackground,
            style: TextStyle(
                color: _UIColors.white,
                fontSize: 16,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
            child: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          child: Visibility(
            visible:
                externalVirtualBackgroundList.contains(currentSelectedPath),
            child: GestureDetector(
              onTap: () async {
                externalVirtualBackgroundList.remove(currentSelectedPath);
                final addExternalVirtualList =
                    await _settingsService.getExternalVirtualBackgroundList();
                addExternalVirtualList.remove(currentSelectedPath);
                _settingsService
                    .setExternalVirtualBackgroundList(addExternalVirtualList);
                _settingsService.setCurrentVirtualBackground(null);
                currentSelectedPath = null;
                enableVirtualBackground(false, '');
                _virtualBackgroundPictureStream.add(null);
                setState(() {});
              },
              child: Text(
                NEMeetingUIKit.instance.getUIKitLocalizations().globalDelete,
                style: TextStyle(
                    color: _UIColors.color_337eff,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        )),
      ],
    );
  }

  /// 构建用户自定义背景选择器
  Widget buildSelector() {
    return StreamBuilder<Object?>(
        stream: _virtualBackgroundPictureStream.stream,
        builder: (context, snapshot) {
          final child = Container(
            padding: EdgeInsets.only(left: 12, bottom: 16, right: 16, top: 16),
            child: divideToGroup(
              [
                buildNothing(),
                buildPickImage(),
                if (externalVirtualBackgroundList.isNotEmpty)
                  ...externalVirtualBackgroundList
                      .map((e) => buildItem(e))
                      .toList()
              ],
            ),
          );
          return snapshot.data == true ? SizedBox(child: child) : child;
        });
  }

  /// 构建默认背景选择器
  Widget buildDefaultSelector() {
    return Container(
      padding: EdgeInsets.only(left: 12, bottom: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                NEMeetingUIKit.instance
                    .getUIKitLocalizations()
                    .virtualDefaultBackground,
                style: TextStyle(
                    color: _UIColors.white,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w500),
              )),
          SizedBox(height: 8),
          divideToGroup(
              builtinVirtualBackgroundList.map((e) => buildItem(e)).toList()),
        ],
      ),
    );
  }

  /// 将列表分组，每行四个
  Widget divideToGroup(List<Widget> list) {
    List<Widget> groupList = [];
    for (int i = 0; i < list.length; i += 4) {
      List<Widget> rowList = [];
      for (int j = 0; j < 4; j++) {
        if (i + j < list.length) {
          rowList.add(list[i + j]);
        } else {
          rowList.add(Spacer());
        }
      }
      groupList.add(Row(
        children: rowList,
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: groupList,
    );
  }

  /// 包裹高亮边框
  Widget wrapOutsideBorder(
      {required Widget child,
      required bool showBorder,
      required VoidCallback onTap}) {
    return Expanded(
        child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.all(1),
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                border: Border.all(
                    color: showBorder
                        ? _UIColors.color_337eff
                        : Colors.transparent,
                    width: 2),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: AspectRatio(
                  aspectRatio: boxRatio,
                  child: child,
                ),
              ),
            )));
  }

  /// 不选择虚拟背景
  Widget buildNothing() {
    return wrapOutsideBorder(
        onTap: () {
          selectVirtualBackground(null);
        },
        showBorder: currentSelectedPath == null,
        child: Container(
          decoration: BoxDecoration(
            color: _UIColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                NEMeetingIconFont.icon_forbidden,
                size: 16,
                color: _UIColors.color_337eff,
              ),
              SizedBox(height: 2),
              Text(
                NEMeetingUIKit.instance.getUIKitLocalizations().globalNothing,
                style: TextStyle(color: _UIColors.color_337eff, fontSize: 12),
              ),
            ],
          ),
        ));
  }

  bool uploading = false;
  Widget buildPickImage() {
    return wrapOutsideBorder(
      onTap: () async {
        if (uploading) return;
        uploading = true;
        _virtualBackgroundPictureStream.add(null);
        try {
          await pickFiles(context);

          /// 解决ios18上遇到的，新写入的图片，展示失败的问题
          Future.delayed(Duration(seconds: 1)).then((value) {
            if (failImages.isNotEmpty) {
              failImages.clear();
              _virtualBackgroundPictureStream.add(true);
            }
          });
        } catch (e) {
          Alog.e(
              tag: _tag,
              moduleName: _moduleName,
              content: 'pickFiles error: $e');
        }
        uploading = false;
        _virtualBackgroundPictureStream.add(null);
      },
      showBorder: false,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_UIColors.color95B8FF, _UIColors.color5367B9],
          ),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  NEMeetingIconFont.icon_add_picture,
                  size: 16,
                  color: _UIColors.white,
                ),
                SizedBox(height: 2),
                Text(
                  NEMeetingUIKit.instance.getUIKitLocalizations().virtualCustom,
                  style: TextStyle(color: _UIColors.white, fontSize: 12),
                ),
              ],
            ),
            if (uploading)
              Container(
                  alignment: Alignment.center,
                  color: _UIColors.black.withOpacity(0.6),
                  child: SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(),
                  )),
          ],
        ),
      ),
    );
  }

  final failImages = <String>[];

  Widget buildItem(String path) {
    return wrapOutsideBorder(
        onTap: () {
          selectVirtualBackground(path);
        },
        showBorder: path == currentSelectedPath,
        child: Image.file(File(path), fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
          failImages.add(path);
          return Container(
            color: _UIColors.white.withOpacity(0.2),
          );
        }));
  }

  Future<bool> checkPermission() async {
    var granted = (await Permission.camera.status) == PermissionStatus.granted;
    if (!granted) {
      granted = await PermissionHelper.requestPermissionSingle(
          context,
          Permission.camera,
          '',
          NEMeetingUIKit.instance.getUIKitLocalizations().meetingCamera);
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
        await _settingsService.getBuiltinVirtualBackgroundList();
    if (builtinVirtualBackgroundList.isNotEmpty) {
      builtinVirtualBackgroundList =
          replaceBundleId(cache!.path, builtinVirtualBackgroundList);
      _settingsService
          .setBuiltinVirtualBackgroundList(builtinVirtualBackgroundList);
    }

    externalVirtualBackgroundList =
        await _settingsService.getExternalVirtualBackgroundList();
    if (externalVirtualBackgroundList.length > 0) {
      externalVirtualBackgroundList =
          replaceBundleId(cache!.path, externalVirtualBackgroundList);
      _settingsService
          .setExternalVirtualBackgroundList(externalVirtualBackgroundList);
    }
    currentSelectedPath = await _settingsService.getCurrentVirtualBackground();
    if (currentSelectedPath != null) {
      currentSelectedPath =
          replaceBundleIdByStr(currentSelectedPath!, cache!.path);
      _settingsService.setCurrentVirtualBackground(currentSelectedPath);
    }
    if (currentSelectedPath != null) {
      /// 已经开启的默认直接开启
      enableVirtualBackground(true, currentSelectedPath!, force: true);
    }
    if (mounted) setState(() {});
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

  void selectVirtualBackground(String? path) {
    if (currentSelectedPath == path && virtualBackgroundIsEnable) {
      return;
    }
    currentSelectedPath = path;
    if (path == null) {
      enableVirtualBackground(false, '');
    } else {
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content:
              'getVirtualBackgroundSupportedType ret supportedType: $supportedType');

      switch (supportedType) {
        case NERoomVirtualBackgroundSupportedType
              .kNEVirtualBackgroundSupportFull:
          enableVirtualBackground(true, path);
          break;
        case NERoomVirtualBackgroundSupportedType
              .kNEVirtualBackgroundSupportHardwareLimit:
          ToastUtils.showToast(
              context,
              NEMeetingUIKit.instance
                  .getUIKitLocalizations()
                  .virtualBackgroundImageDeviceNotSupported);
          break;
        case NERoomVirtualBackgroundSupportedType
              .kNEVirtualBackgroundSupportPerformanceLimit:
          if (!virtualBackgroundIsEnable) {
            DialogUtils.showVirtualBackgroundAlertDialog(
                context: context,
                onCancelCallback: () {
                  Navigator.of(context).pop();
                },
                onForceOpenCallback: () {
                  enableVirtualBackground(true, path, force: true);
                  Navigator.of(context).pop();
                });
          } else {
            Alog.i(
                tag: _tag,
                moduleName: _moduleName,
                content:
                    'already virtualBackgroundIsEnable: $virtualBackgroundIsEnable');
            enableVirtualBackground(true, path, force: true);
          }
          break;
      }
    }
    _settingsService.setCurrentVirtualBackground(path);
    if (mounted) setState(() {});
  }

  void enableVirtualBackground(bool enable, String path,
      {bool force = false}) async {
    virtualBackgroundIsEnable = enable;
    await rtcController?.enableVirtualBackground(
        enable,
        NERoomVirtualBackgroundSource(
            backgroundSourceType: NERoomVirtualBackgroundType.kBackgroundImg,
            source: path,
            color: 0,
            blurDegree: NERoomVirtualBackgroundType.kBlurDegreeHigh),
        force: force);
  }

  Future<bool> pickFiles(BuildContext context) async {
    /// API小于33时，主动申请存储权限，解决部分设备pickFiles不触发权限申请的情况
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 33) {
        var granted = await Permission.storage.isGranted;
        if (!granted) {
          granted =
              await Permission.storage.request() == PermissionStatus.granted;
          if (mounted && !granted) {
            ToastUtils.showToast(context,
                NEMeetingUIKitLocalizations.of(context)!.globalNoPermission);
            return false;
          }
        }
      }
    }

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
        ToastUtils.showToast(
            context,
            NEMeetingUIKitLocalizations.of(context)!
                .virtualBackgroundImageLarge);
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
      externalVirtualBackgroundList.add(path);

      var addExternalVirtualList =
          await _settingsService.getExternalVirtualBackgroundList();
      if (addExternalVirtualList.length <= 0) {
        addExternalVirtualList = <String>[];
      }
      addExternalVirtualList.add(path);
      _settingsService.setExternalVirtualBackgroundList(addExternalVirtualList);
      selected = true;
    } else {
      Alog.i(
          tag: _tag,
          moduleName: _moduleName,
          content: 'User canceled the picker');
      // User canceled the picker
      selected = false;
    }
    return selected;
  }

  @override
  void dispose() {
    super.dispose();
    _virtualBackgroundPictureStream.close();
  }
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
