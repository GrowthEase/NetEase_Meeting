// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class NEPreVirtualBackgroundPage extends StatefulWidget {
  NEPreVirtualBackgroundPage({Key? key});

  @override
  _PreVirtualBackgroundPageState createState() =>
      _PreVirtualBackgroundPageState();
}

class _PreVirtualBackgroundPageState
    extends _VirtualBackgroundPageState<NEPreVirtualBackgroundPage> {
  NERtcVideoRenderer? renderer;
  NEPreviewRoomRtcController? rtcController;
  NEPreviewRoomContext? previewRoomContext;
  late final NEPreviewRoomEventCallback eventCallback;

  @override
  void initState() {
    super.initState();
    eventCallback = NEPreviewRoomEventCallback(
        rtcVirtualBackgroundSourceEnabled: onRtcVirtualBackgroundSourceEnabled);
    checkPermission().then((granted) {
      if (granted && mounted) {
        NERoomKit.instance.roomService
            .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions())
            .then((value) async {
          previewRoomContext = value.nonNullData;
          previewRoomContext?.addEventCallback(eventCallback);
          rtcController = previewRoomContext?.previewController;

          await _initRenderer();
          await _initVirtualBackgroundPictures();
          var type = await rtcController?.getVirtualBackgroundSupportedType();
          if (type != null) {
            supportedType = type;
          }
        });
      }
    });
  }

  @override
  Widget buildVideoView() {
    return renderer != null ? NERtcVideoView(renderer!) : Container();
  }

  Future<void> _initRenderer() async {
    renderer = await NERtcVideoRendererFactory.createVideoRenderer('');
    await renderer!.attachToLocalVideo();
    renderer!.setMirror(true);
    await rtcController?.startPreview();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    rtcController?.stopPreview();
    enableVirtualBackground(false, '');
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
