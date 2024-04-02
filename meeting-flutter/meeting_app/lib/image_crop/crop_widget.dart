// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../language/meeting_localization/meeting_app_localizations.dart';
import '../uikit/values/colors.dart';
import 'crop_const.dart';
import 'crop_controller.dart';

class ImageCropper extends StatelessWidget {
  final ImageCropController ctrl;

  /// Scale image based on device pixel ratio for best quality.
  /// Fix this value to 1 if you always want to have an exact size.
  final double devicePixelRatio;

  const ImageCropper(this.ctrl, {super.key, required this.devicePixelRatio});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Crop(ctrl),
        Positioned(
            left: 0,
            bottom: 100,
            right: 0,
            child: Container(
              color: AppColors.shadow,
              height: 1,
              child: Divider(height: 1),
            )),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: TextButton(
                  onPressed: () {
                    ctrl.cancel();
                  },
                  child: Text(MeetingAppLocalizations.of(context)!.globalCancel,
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: TextButton(
                  onPressed: () {
                    ctrl.crop(devicePixelRatio);
                  },
                  child: Text(
                      MeetingAppLocalizations.of(context)!.globalComplete,
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Crop extends StatelessWidget {
  final ImageCropController ctrl;

  const Crop(this.ctrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: ctrl.handleScaleStart,
        onScaleUpdate: ctrl.handleScaleUpdate,
        onScaleEnd: ctrl.handleScaleEnd,
        child: CropCanvas(ctrl),
      ),
    );
  }
}

class CropCanvas extends StatefulWidget {
  final ImageCropController ctrl;

  const CropCanvas(this.ctrl);

  @override
  State<CropCanvas> createState() {
    return _CropCanvasState();
  }
}

class _CropCanvasState extends State<CropCanvas> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    widget.ctrl.addListener(_redraw);
    widget.ctrl.activeAnimation =
        AnimationController(vsync: this, duration: kCropAnimationDuration)
          ..addListener(_redraw);
  }

  void _redraw() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.ctrl.removeListener(_redraw);
    widget.ctrl.activeAnimation?.removeListener(_redraw);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    widget.ctrl.resolveImage(
      createLocalImageConfiguration(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CropPainter(widget.ctrl),
    );
  }
}

class CropPainter extends CustomPainter {
  final ImageCropController ctrl;

  CropPainter(this.ctrl);

  @override
  bool shouldRepaint(CropPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final vp = ctrl.setViewport(size);

    final paint = Paint()..isAntiAlias = false;
    final active = ctrl.active;

    /// 画图片
    final image = ctrl.image;
    if (image != null) {
      final src = Rect.fromLTWH(
        0.0,
        0.0,
        image.width.toDouble(),
        image.height.toDouble(),
      );

      canvas.save();
      canvas.clipRect(vp);
      canvas.drawImageRect(image, src, ctrl.imageView, paint);
      canvas.restore();
    }

    /// 画遮罩
    paint.color = Color.fromRGBO(
        0x0,
        0x0,
        0x0,
        kCropOverlayActiveOpacity * active +
            kCropOverlayInactiveOpacity * (1.0 - active));

    final cropArea = ctrl.cropArea;
    if (!cropArea.isEmpty) {
      canvas.save();
      canvas.clipRect(cropArea, clipOp: ui.ClipOp.difference);
      canvas.drawRect(vp, paint);
      canvas.restore();

      _drawGrid(canvas, cropArea, active);
      _drawHandles(canvas, cropArea);
    }
  }

  /// 画裁剪框的边角
  void _drawHandles(Canvas canvas, Rect boundaries) {
    final handleSize = kCropHandleSize;
    final handlePaint = Paint()
      ..isAntiAlias = true
      ..color = kCropHandleColor
      ..strokeWidth = kCropHandleStrokeWidth;

    final topLeft = Offset(boundaries.left, boundaries.top);
    final topRight = Offset(boundaries.right, boundaries.top);
    final bottomLeft = Offset(boundaries.left, boundaries.bottom);
    final bottomRight = Offset(boundaries.right, boundaries.bottom);

    canvas.drawLine(topLeft, topLeft + Offset(handleSize, 0), handlePaint);
    canvas.drawLine(topLeft, topLeft + Offset(0, handleSize), handlePaint);

    canvas.drawLine(topRight, topRight + Offset(-handleSize, 0), handlePaint);
    canvas.drawLine(topRight, topRight + Offset(0, handleSize), handlePaint);

    canvas.drawLine(
        bottomLeft, bottomLeft + Offset(handleSize, 0), handlePaint);
    canvas.drawLine(
        bottomLeft, bottomLeft + Offset(0, -handleSize), handlePaint);

    canvas.drawLine(
        bottomRight, bottomRight + Offset(-handleSize, 0), handlePaint);
    canvas.drawLine(
        bottomRight, bottomRight + Offset(0, -handleSize), handlePaint);
  }

  /// 画裁剪框的网格
  void _drawGrid(Canvas canvas, Rect cropArea, double active) {
    if (active == 0.0) {
      return;
    }

    final paint = Paint()
      ..isAntiAlias = false
      ..color = kCropGridColor.withOpacity(kCropGridColor.opacity * active)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawRect(cropArea, paint);

    final columnWidth = cropArea.width / kCropGridColumnCount;
    for (var column = 1; column < kCropGridColumnCount; column++) {
      final x = cropArea.left + column * columnWidth;
      final p1 = Offset(x, cropArea.top);
      final p2 = Offset(x, cropArea.bottom);
      canvas.drawLine(p1, p2, paint);
    }

    final rowHeight = cropArea.height / kCropGridRowCount;
    for (var row = 1; row < kCropGridRowCount; row++) {
      final y = cropArea.top + row * rowHeight;
      final p1 = Offset(cropArea.left, y);
      final p2 = Offset(cropArea.right, y);
      canvas.drawLine(p1, p2, paint);
    }
  }
}
