// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class BeautySettingPage extends StatefulWidget {
  final int beautyLevel;

  BeautySettingPage({Key? key, required this.beautyLevel});

  @override
  _BeautySettingPageState createState() {
    return _BeautySettingPageState();
  }
}

class _BeautySettingPageState extends LifecycleBaseState<BeautySettingPage> {
  late NEPreRoomBeautyController beautyController;
  NERtcVideoRenderer? renderer;
  late int beautyLevel;

  @override
  void initState() {
    super.initState();
    beautyController =
        NERoomKit.instance.getPreRoomService().getPreRoomBeautyController();
    beautyLevel = widget.beautyLevel;
    _checkPermission().then((granted) => {
          if (granted) {_initRenderer()}
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
                title: Text(
                  Strings.beauty,
                  style: TextStyle(
                      color: UIColors.color_222222,
                      fontSize: 19,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w500),
                ),
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0.0,
                brightness: Brightness.light,
                leading: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  key: ValueKey('back'),
                  child: Container(
                      width: 150,
                      height: 40,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 20, bottom: 10),
                      child: Text(
                        Strings.save,
                        style: TextStyle(
                            color: Color(0xff2575FF),
                            fontSize: 14,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w500),
                      )),
                  onTap: () {
                    _requestPop();
                  },
                )),
            body: buildBeautyPreViewWidget(context)),
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
        child: SliderWidget(
            onChange: (value) {
              _setBeautyParams(value);
            },
            level: beautyLevel.toInt(),
            isShowClose: false),
      )
    ]);
  }

  Widget buildCallingVideoViewWidget(BuildContext context) {
    return renderer != null ? NERtcVideoView(renderer!) : Container();
  }

  Future<bool> _checkPermission() async {
    var granted = (await Permission.camera.status) == PermissionStatus.granted;
    if (!granted) {
      granted = await PermissionHelper.requestPermissionSingle(
          context, Permission.camera, '', Strings.cameraPermission);
     if(!granted) UINavUtils.pop(context, rootNavigator: true);
    }
    return granted;
  }

  void _requestPop() {
    beautyController
        .setBeautyFaceValue(beautyLevel);
    UINavUtils.pop(context, rootNavigator: true);
  }

  Future<void> _initRenderer() async {
    await beautyController.enableBeauty(true);
    renderer = await beautyController.createVideoPreview();
    _setBeautyParams(beautyLevel);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    EventBus().emit(UIEventName.flutterEngineCanRecycle);
    beautyController.enableBeauty(false);
    super.dispose();
  }

  void _setBeautyParams(int v) {
    beautyLevel = v;
    beautyController
        .setBeautyFaceValue(beautyLevel,save: false)
        .then((value) => setState(() => {}));
  }
}
