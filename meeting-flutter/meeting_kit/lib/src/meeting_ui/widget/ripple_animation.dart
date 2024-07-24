// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 波纹动画组件
class RippleAnimation extends StatefulWidget {
  final double size;
  final double? centerSize;
  final Widget child;

  const RippleAnimation(
      {Key? key, required this.size, this.centerSize, required this.child})
      : super(key: key);

  @override
  _RippleAnimationState createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: CustomPaint(
              painter: CircleRipplePainter(
                  _animation.value, widget.size, widget.centerSize ?? 0),
              size: Size(widget.size, widget.size),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CircleRipplePainter extends CustomPainter {
  final double value;
  final double width;
  final double centerWidth;

  CircleRipplePainter(this.value, this.width, this.centerWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var i = 1; i < 3; i++) {
      final paint = Paint()
        ..color = _UIColors.white.withOpacity((1 - value) * 0.5)
        ..style = PaintingStyle.fill;
      final radius =
          (width / 2 - centerWidth / 2) / 2 * i * value + centerWidth / 2;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(CircleRipplePainter oldDelegate) {
    return value != oldDelegate.value;
  }
}
