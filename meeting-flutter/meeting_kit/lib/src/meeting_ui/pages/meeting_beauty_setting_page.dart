// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class PreBeautySettingPage extends StatefulWidget {
  PreBeautySettingPage({Key? key});

  @override
  _PreBeautySettingPageState createState() {
    return _PreBeautySettingPageState();
  }
}

class _PreBeautySettingPageState
    extends _BeautyPageState<PreBeautySettingPage> {
  NERtcVideoRenderer? renderer;
  NEPreviewRoomRtcController? rtcController;

  @override
  void initState() {
    super.initState();
    checkPermission().then((granted) {
      if (mounted && granted) {
        NERoomKit.instance.roomService
            .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions())
            .then((value) {
          rtcController = value.nonNullData.previewController;
          _initRenderer();
        });
      }
    });
  }

  Widget buildVideoView() {
    return renderer != null ? NERtcVideoView(renderer!) : Container();
  }

  Future<void> _initRenderer() async {
    renderer = await NERtcVideoRendererFactory.createVideoRenderer('');
    await renderer!.attachToLocalVideo();
    renderer!.setMirror(true);
    await rtcController?.startPreview();
    setBeautyParams();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    EventBus().emit(NEMeetingUIEvents.flutterPageDisposed);
    rtcController?.stopPreview();
    renderer?.detach();
    super.dispose();
  }
}

class InMeetingBeautyPage extends StatefulWidget {
  final NERoomContext roomContext;
  final NERoomUserVideoStreamSubscriber videoStreamSubscriber;
  final ValueListenable<bool> mirrorListenable;
  final ValueListenable<bool> videoMuteListenable;

  InMeetingBeautyPage({
    Key? key,
    required this.roomContext,
    required this.mirrorListenable,
    required this.videoStreamSubscriber,
    required this.videoMuteListenable,
  });

  @override
  _BeautyPageState createState() =>
      _InMeetingBeautyPageState(rtcController: roomContext.rtcController);
}

class _InMeetingBeautyPageState extends _BeautyPageState<InMeetingBeautyPage> {
  final NERoomRtcController? rtcController;
  VoidCallback? listener;

  _InMeetingBeautyPageState({required this.rtcController});

  @override
  void initState() {
    super.initState();
    checkPermission().then((granted) {
      if (granted) {
        setBeautyParams();

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

abstract class _BeautyPageState<T extends StatefulWidget> extends BaseState<T> {
  final _settingsService = NEMeetingKit.instance.getSettingsService();
  int beautyLevel = 0;
  NERoomBaseRtcController? get rtcController;

  @override
  void initState() {
    super.initState();
    _settingsService.getBeautyFaceValue().then((value) {
      setState(() {
        beautyLevel = value;
      });
    });
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
            SliderWidget(
                onChange: (value) {
                  setBeautyParams(value);
                },
                level: beautyLevel.toInt(),
                isShowClose: false),
          ],
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Container(
      height: 44,
      width: double.infinity,
      alignment: Alignment.center,
      child: Text(
        NEMeetingUIKit.instance.getUIKitLocalizations().meetingBeauty,
        style: TextStyle(
            color: _UIColors.white,
            fontSize: 16,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w500),
      ),
    );
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

  bool isBeautyEnabled = false;
  void setBeautyParams([int? v]) async {
    v ??= await _settingsService.getBeautyFaceValue();
    beautyLevel = v;

    /// 关闭美颜
    if (v == 0) {
      isBeautyEnabled = false;
      rtcController?.stopBeauty();
      rtcController?.enableBeauty(false);
      return;
    }
    if (!isBeautyEnabled) {
      isBeautyEnabled = true;
      rtcController?.startBeauty();
      rtcController?.enableBeauty(true);
    }
    var level = beautyLevel.toDouble() / 10;
    rtcController?.setBeautyEffect(NERoomBeautyEffectType.kWhiten, level);
    rtcController?.setBeautyEffect(NERoomBeautyEffectType.kSmooth, level);
    rtcController?.setBeautyEffect(NERoomBeautyEffectType.kFaceRuddy, level);
    rtcController?.setBeautyEffect(NERoomBeautyEffectType.kFaceSharpen, level);
  }

  @override
  void dispose() {
    NEMeetingKit.instance.getSettingsService().setBeautyFaceValue(beautyLevel);
    super.dispose();
  }
}
