// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

double _screenHeight = 500.0;
double _taskBarHeight = 30.0;
double _bottomNavigationBarHeight = 30.0;
double _titleBarHeight = 50.0;
double _inputBarHeight = 50.0;
const double _kMenuScreenPadding = 50.0;

class TrianglePainter extends CustomPainter {
  late Paint _paint;
  final Color color;
  final RelativeRect position;
  final Size size;
  final double radius;
  final bool isInverted;
  final double screenWidth;

  TrianglePainter({required this.color,
    required this.position,
    required this.size,
    this.radius = 20,
    this.isInverted = false,
    required this.screenWidth}) {
    _paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..strokeWidth = 10
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();

    // 如果 menu 的长度 大于 child 的长度
    if (size.width > this.size.width) {
      // 靠右
      if (position.left + this.size.width / 2 > position.right) {
        if (screenWidth - (position.left + this.size.width) > size.width / 2 + _kMenuScreenPadding) {
          path.moveTo(size.width / 2, isInverted ? 0 : size.height);
          path.lineTo(size.width / 2 - radius, isInverted ? size.height : 0);
          path.lineTo(size.width / 2 + radius, isInverted ? size.height : 0);
        } else {
          path.moveTo(size.width - this.size.width + this.size.width / 2,
              isInverted ? 0 : size.height);
          path.lineTo(
              size.width - this.size.width + this.size.width / 2 - radius,
              isInverted ? size.height : 0);
          path.lineTo(
              size.width - this.size.width + this.size.width / 2 + radius,
              isInverted ? size.height : 0);
        }
      } else {
        // 靠左
        if (position.left > size.width / 2 + _kMenuScreenPadding) {
          path.moveTo(size.width / 2, isInverted ? 0 : size.height);
          path.lineTo(size.width / 2 - radius, isInverted ? size.height : 0);
          path.lineTo(size.width / 2 + radius, isInverted ? size.height : 0);
        } else {
          path.moveTo(this.size.width / 2, isInverted ? 0 : size.height);
          path.lineTo(
              this.size.width / 2 - radius, isInverted ? size.height : 0);
          path.lineTo(
              this.size.width / 2 + radius, isInverted ? size.height : 0);
        }
      }
    } else {
      path.moveTo(size.width / 2, isInverted ? 0 : size.height);
      path.lineTo(
          size.width / 2 - radius , isInverted ? size.height : 0);
      path.lineTo(
          size.width / 2 + radius, isInverted ? size.height : 0);
    }

    path.close();

    canvas.drawPath(
      path,
      _paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
