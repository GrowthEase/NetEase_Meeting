// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class RoundSliderTrackShape extends SliderTrackShape {
  const RoundSliderTrackShape({this.disabledThumbGapWidth = 2.0, this.radius = 0});

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
    final overlayWidth = sliderTheme.overlayShape!.getPreferredSize(isEnabled ?? false, isDiscrete ?? false).width;
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
    bool? isEnabled,
    bool? isDiscrete,
    required TextDirection textDirection,
  }) {
    if (sliderTheme.trackHeight == 0) {
      return;
    }

    final activeTrackColorTween =
        ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final inactiveTrackColorTween =
        ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation) as Color;
    final inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation) as Color;
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
      final disabledThumbRadius = sliderTheme.thumbShape!.getPreferredSize(false, isDiscrete ?? false).width / 2.0;
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
    final leftTrackSegment = RRect.fromLTRBR(trackRect.left, trackRect.top, thumbCenter.dx - horizontalAdjustment,
        trackRect.bottom, Radius.circular(radius));
    context.canvas.drawRRect(leftTrackSegment, leftTrackPaint);
    final rightTrackSegment = RRect.fromLTRBR(thumbCenter.dx + horizontalAdjustment, trackRect.top, trackRect.right,
        trackRect.bottom, Radius.circular(radius));
    context.canvas.drawRRect(rightTrackSegment, rightTrackPaint);
  }
}
