// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class TextWatermarkConfiguration {
  /// 水印文本
  final String text;

  /// 水印文本样式
  final TextStyle? textStyle;

  /// Y 轴与水印文字的夹角，取值范围 [0, 180]；
  /// 为0时文字方向为从下往上，为90时文字方向为从左往右，为180时文字从上往下
  final int angle;

  /// 第一个水印相对于屏幕左上角的偏移量。如果不设置，会自动计算，以保证第一排水印能够完全展示
  final Offset? offset;

  /// 水平方向的间距
  final double horizontalSpace;

  /// 垂直方向的间距
  final double verticalSpace;

  /// 背景色
  final Color? backgroundColor;

  /// 单排水印、多排水印。如果为单排，则展示在屏幕中间，其他参数无效
  final bool singleRow;

  /// 水印最大宽度，超过自动换行
  final double? maxWidth;

  /// 水印的透明度
  final double opacity;

  const TextWatermarkConfiguration({
    required this.text,
    this.angle = 75,
    this.offset,
    this.horizontalSpace = 128,
    this.verticalSpace = 128,
    this.textStyle,
    this.backgroundColor,
    this.singleRow = false,
    this.maxWidth,
    this.opacity = 0.1,
  }) : assert(angle >= 0 && angle <= 180);

  TextWatermarkConfiguration copyWith({
    String? text,
    int? angle,
    Offset? offset,
    double? horizontalSpace,
    double? verticalSpace,
    TextStyle? textStyle,
    Color? backgroundColor,
    bool? singleRow,
  }) {
    return TextWatermarkConfiguration(
      text: text ?? this.text,
      angle: angle ?? this.angle,
      offset: offset ?? this.offset,
      horizontalSpace: horizontalSpace ?? this.horizontalSpace,
      verticalSpace: verticalSpace ?? this.verticalSpace,
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      singleRow: singleRow ?? this.singleRow,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      text,
      angle,
      offset,
      horizontalSpace,
      verticalSpace,
      textStyle,
      backgroundColor,
      singleRow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TextWatermarkConfiguration) {
      return text == other.text &&
          angle == other.angle &&
          offset == other.offset &&
          horizontalSpace == other.horizontalSpace &&
          verticalSpace == other.verticalSpace &&
          textStyle == other.textStyle &&
          backgroundColor == other.backgroundColor &&
          singleRow == other.singleRow;
    }
    return false;
  }
}

class TextWatermark extends StatelessWidget {
  /// 水印配置
  final TextWatermarkConfiguration? configuration;

  /// 水印是否在子组件之上绘制
  final bool onForeground;

  /// 子组件
  final Widget child;

  const TextWatermark({
    super.key,
    required this.configuration,
    this.onForeground = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isTextNotEmpty = configuration?.text.isNotEmpty == true;
    return CustomPaint(
      foregroundPainter: onForeground && isTextNotEmpty
          ? _TextWaterMarkPainter(configuration: configuration!)
          : null,
      painter: !onForeground && isTextNotEmpty
          ? _TextWaterMarkPainter(configuration: configuration!)
          : null,
      child: child,
    );
  }
}

class _TextWaterMarkPainter extends CustomPainter {
  late TextPainter _textPainter;

  /// 水印配置
  final TextWatermarkConfiguration configuration;

  _TextWaterMarkPainter({
    required this.configuration,
  });

  void _prepareText() {
    _textPainter = TextPainter(
      text: TextSpan(
        text: configuration.text,
        style: configuration.textStyle ??
            TextStyle(
              color: _UIColors.grey_8F8F8F.withOpacity(configuration.opacity),
              fontSize: configuration.singleRow ? 16 : 12,
              fontWeight: FontWeight.w500,
              textBaseline: TextBaseline.alphabetic,
            ),
      ),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout(maxWidth: configuration.maxWidth ?? double.infinity);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _prepareText();
    final textWidth = _textPainter.width;
    final textHeight = _textPainter.height;
    final radians = configuration.angle * pi / 180; // 将角度转换为弧度
    final rotationRadians = -(90 - configuration.angle) * pi / 180; // 实际旋转的弧度
    // final adjustWidth = textWidth * sin(radians);
    final adjustHeight = textWidth * cos(radians);
    final hStep = configuration.horizontalSpace;
    final vStep = configuration.verticalSpace;
    final int row = (size.height / vStep).ceil();
    final int column = (size.width / hStep).ceil();

    final Offset initialOffset;
    if (configuration.offset == null) {
      initialOffset = Offset(0, 0);
    } else {
      initialOffset = configuration.offset!;
    }

    if (configuration.backgroundColor != null) {
      canvas.drawColor(configuration.backgroundColor!, BlendMode.clear);
    }

    /// 裁剪画布，防止水印超出屏幕
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (configuration.singleRow) {
      // assert(() {
      //   canvas.drawCircle(
      //       size.center(Offset.zero), 2, Paint()..color = Colors.teal);
      //   return true;
      // }());
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(rotationRadians);
      _textPainter.paint(canvas, Offset(-textWidth / 2, -textHeight / 2));
      canvas.restore();
    } else {
      // assert(() {
      //   for (int r = 0; r < row; r++) {
      //     final off = initialOffset + Offset(0, r * vStep);
      //     canvas.drawLine(
      //         off, off + Offset(size.width, 0), Paint()..color = Colors.teal);
      //   }
      //   return true;
      // }());

      for (int r = 0; r < row; r++) {
        for (int c = 0; c < column; c++) {
          final off =
              initialOffset + Offset(c * hStep, r * vStep + adjustHeight);
          canvas.save();
          canvas.translate(off.dx, off.dy);
          canvas.rotate(rotationRadians);
          _textPainter.paint(canvas, Offset.zero);
          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as _TextWaterMarkPainter).configuration !=
        configuration;
  }
}
