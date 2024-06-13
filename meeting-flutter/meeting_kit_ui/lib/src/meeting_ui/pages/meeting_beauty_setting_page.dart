// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class BeautySettingPage extends StatefulWidget {
  final int beautyLevel;

  BeautySettingPage({Key? key, required this.beautyLevel});

  @override
  _BeautySettingPageState createState() {
    return _BeautySettingPageState();
  }
}

class _BeautySettingPageState extends LifecycleBaseState<BeautySettingPage> {
  NERtcVideoRenderer? renderer;
  late int beautyLevel;
  NEPreviewRoomRtcController? previewRoomRtcController;
  bool isInitMeetingUiLocalizations = false;

  @override
  void initState() {
    super.initState();
    beautyLevel = widget.beautyLevel;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, // 设置状态栏颜色为透明
      statusBarIconBrightness: Brightness.light, // 设置状态栏文字颜色为白色
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitMeetingUiLocalizations) {
      isInitMeetingUiLocalizations = true;
      _checkPermission(
              NEMeetingUIKit.instance.getUIKitLocalizations().meetingCamera)
          .then((granted) {
        if (mounted && granted) {
          NERoomKit.instance.roomService
              .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions())
              .then((value) {
            previewRoomRtcController = value.nonNullData.previewController;
            _initRenderer();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        child: Scaffold(body: buildBeautyPreViewWidget(context)),
        onPopInvoked: (didPop) async {
          NEMeetingKit.instance
              .getSettingsService()
              .setBeautyFaceValue(beautyLevel);
        });
  }

  Widget buildBeautyPreViewWidget(BuildContext context) {
    return Stack(children: <Widget>[
      buildCallingVideoViewWidget(context),
      Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            color: _UIColors.black.withOpacity(0.8),
          ),
          child: SliderWidget(
              onChange: (value) {
                _setBeautyParams(value);
              },
              level: beautyLevel.toInt(),
              isShowClose: false),
        ),
      ),
      Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          child: IconButton(
            padding: EdgeInsets.all(5),
            key: MeetingUIValueKeys.back,
            icon: Icon(NEMeetingIconFont.icon_yx_returnx,
                color: _UIColors.white, size: 14),
            onPressed: () {
              UINavUtils.pop(context, rootNavigator: true);
            },
          )),
    ]);
  }

  Widget buildCallingVideoViewWidget(BuildContext context) {
    return renderer != null ? NERtcVideoView(renderer!) : Container();
  }

  Future<bool> _checkPermission(String meetingCamera) async {
    var granted = (await Permission.camera.status) == PermissionStatus.granted;
    if (!granted && mounted) {
      granted = await PermissionHelper.requestPermissionSingle(
          context, Permission.camera, '', meetingCamera);
      if (!granted && mounted) UINavUtils.pop(context, rootNavigator: true);
    }
    return granted;
  }

  Future<void> _initRenderer() async {
    renderer = await NERtcVideoRendererFactory.createVideoRenderer('');
    await renderer!.attachToLocalVideo();
    renderer!.setMirror(true);
    await previewRoomRtcController?.startPreview();
    await previewRoomRtcController?.startBeauty();
    await previewRoomRtcController?.enableBeauty(true);
    _setBeautyParams(beautyLevel);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    EventBus().emit(NEMeetingUIEvents.flutterPageDisposed);
    previewRoomRtcController?.stopBeauty();
    previewRoomRtcController?.stopPreview();
    renderer?.detach();
    super.dispose();
  }

  void _setBeautyParams(int v) {
    beautyLevel = v;
    var level = beautyLevel.toDouble() / 10;
    previewRoomRtcController?.setBeautyEffect(
        NERoomBeautyEffectType.kWhiten, level);
    previewRoomRtcController?.setBeautyEffect(
        NERoomBeautyEffectType.kSmooth, level);
    previewRoomRtcController?.setBeautyEffect(
        NERoomBeautyEffectType.kFaceRuddy, level);
    previewRoomRtcController?.setBeautyEffect(
        NERoomBeautyEffectType.kFaceSharpen, level);
  }
}
