// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class AnimatedMicphoneVolume extends StatelessWidget {
  final Stream<int> volume;

  final double? opacity;

  final Color backgroundColor;

  const AnimatedMicphoneVolume.light({
    Key? key,
    required this.volume,
    this.opacity,
  })  : backgroundColor = const Color(0xFFECEDEF),
        super(key: key);

  const AnimatedMicphoneVolume.dark({
    Key? key,
    required this.volume,
    this.opacity,
  })  : backgroundColor = const Color(0xFF49494D),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      initialData: 0,
      stream: volume,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Widget child = CustomPaint(
            painter: MicphonePainter(
              level: getLevelByVolume(snapshot.requireData),
              backgroundColor: backgroundColor,
            ),
          );
          if (opacity != null) {
            child = Opacity(
              child: child,
              opacity: opacity!,
            );
          }
          return child;
        }
        return Container();
      },
    );
  }

  int getLevelByVolume(int volume) {
    if (volume >= 1 && volume <= 30) {
      return 1;
    } else if (volume >= 31 && volume <= 70) {
      return 2;
    } else if (volume >= 71 && volume < 90) {
      return 3;
    } else if (volume >= 90) {
      return 4;
    }
    return 0;
  }
}

class MicphonePainter extends CustomPainter {
  static const int maxLevel = 4;

  static const double baseSize = 30.0;
  static const double baseWidth = 12.0;
  static const double baseHeight = 21.0;

  final int level;
  final Color backgroundColor;
  final Color foregroundColor;

  late final Paint fillPaint, strokePaint;

  MicphonePainter({
    required this.level,
    this.backgroundColor = const Color(0xFFECEDEF),
    this.foregroundColor = const Color(0xFF59E1A0),
  }) {
    // print('level: $level');
    fillPaint = Paint()
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;
    strokePaint = Paint()
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / baseSize;
    strokePaint.strokeWidth = 2.0 * scale;

    canvas.save();

    /// draw top
    final rect = Rect.fromLTWH(0, 0, baseWidth * scale, baseHeight * scale);
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(rect.width / 2));
    canvas.translate((size.width - rect.width) / 2, 0);
    canvas.drawRRect(rrect, fillPaint);

    /// draw foreground
    if (level > 0) {
      canvas.save();
      fillPaint.color = foregroundColor;
      canvas.clipRRect(rrect);
      canvas.clipRect(Rect.fromLTRB(
          rect.left,
          rect.bottom - rect.height * level / maxLevel,
          rect.right,
          rect.bottom));
      canvas.drawRect(rect, fillPaint);
      canvas.restore();
    }

    /// draw bottom
    final rect2 = rect.inflate(4 * scale);
    final rect3 = Rect.fromLTRB(
        rect2.left, rect2.bottom - rect2.width, rect2.right, rect2.bottom);
    canvas.drawArc(
      rect3,
      0,
      pi,
      false,
      strokePaint,
    );

    canvas.drawPoints(
      PointMode.lines,
      [
        rect3.centerLeft - Offset(0, 5 * scale),
        rect3.centerLeft,
        rect3.centerRight - Offset(0, 5 * scale),
        rect3.centerRight,
      ],
      strokePaint,
    );
    canvas.restore();

    /// draw bottom vertical line
    canvas.drawLine(
      Offset(size.width / 2, rect2.bottom),
      Offset(size.width / 2, size.height),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(MicphonePainter oldDelegate) =>
      level != oldDelegate.level ||
      backgroundColor != oldDelegate.backgroundColor ||
      foregroundColor != oldDelegate.foregroundColor;

  @override
  bool shouldRebuildSemantics(MicphonePainter oldDelegate) => false;
}
