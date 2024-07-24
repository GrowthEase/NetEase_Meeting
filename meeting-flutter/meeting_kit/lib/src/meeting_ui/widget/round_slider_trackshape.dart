// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class RoundSliderTrackShape extends SliderTrackShape {
  const RoundSliderTrackShape(
      {this.disabledThumbGapWidth = 2.0, this.radius = 0});

  final double disabledThumbGapWidth;
  final double radius;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool? isEnabled,
    bool? isDiscrete,
  }) {
    final overlayWidth = sliderTheme.overlayShape!
        .getPreferredSize(isEnabled ?? false, isDiscrete ?? false)
        .width;
    final trackHeight = sliderTheme.trackHeight ?? 0.0;
    assert(overlayWidth >= 0);
    assert(trackHeight >= 0.0);
    assert(parentBox.size.width >= overlayWidth);
    assert(parentBox.size.height >= trackHeight);

    final trackLeft = offset.dx + overlayWidth / 2;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;

    final trackWidth = parentBox.size.width - overlayWidth;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool? isEnabled,
    bool? isDiscrete,
    required TextDirection textDirection,
  }) {
    if (sliderTheme.trackHeight == 0) {
      return;
    }

    final activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation) as Color;
    final inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation) as Color;
    Paint leftTrackPaint;
    Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    var horizontalAdjustment = 0.0;
    if (!(isEnabled ?? false)) {
      final disabledThumbRadius = sliderTheme.thumbShape!
              .getPreferredSize(false, isDiscrete ?? false)
              .width /
          2.0;
      final gap = disabledThumbGapWidth * (1.0 - enableAnimation.value);
      horizontalAdjustment = disabledThumbRadius + gap;
    }

    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    //进度条两头圆角
    final leftTrackSegment = RRect.fromLTRBR(
        trackRect.left,
        trackRect.top,
        thumbCenter.dx - horizontalAdjustment,
        trackRect.bottom,
        Radius.circular(radius));
    context.canvas.drawRRect(leftTrackSegment, leftTrackPaint);
    final rightTrackSegment = RRect.fromLTRBR(
        thumbCenter.dx + horizontalAdjustment,
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
        Radius.circular(radius));
    context.canvas.drawRRect(rightTrackSegment, rightTrackPaint);
  }
}

class RoundBorderSliderThumbShape extends RoundSliderThumbShape {
  const RoundBorderSliderThumbShape({
    super.enabledThumbRadius,
    super.disabledThumbRadius,
    super.elevation,
    super.pressedElevation,
    this.border,
  });

  final BorderSide? border;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    super.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
    );
    if (border != null) {
      final Canvas canvas = context.canvas;
      final paint = border!.toPaint();
      final Tween<double> radiusTween = Tween<double>(
        begin: disabledThumbRadius ?? enabledThumbRadius,
        end: enabledThumbRadius,
      );
      final double radius = radiusTween.evaluate(enableAnimation);
      canvas.drawCircle(
        center,
        radius,
        paint,
      );
    }
  }
}
