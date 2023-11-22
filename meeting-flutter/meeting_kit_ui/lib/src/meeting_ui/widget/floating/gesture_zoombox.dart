// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 可缩放/平移的盒子小部件
class GestureZoomBox extends StatefulWidget {
  final double maxScale;
  final double doubleTapScale;
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;

  /// 通过最大缩放比例 [maxScale]、双击缩放比例 [doubleTapScale]、子部件 [child]、点击事件 [onPressed] 创建小部件
  const GestureZoomBox({
    Key? key,
    this.maxScale = 5.0,
    this.doubleTapScale = 2.0,
    required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 200),
  })  : assert(maxScale >= 1.0),
        assert(doubleTapScale >= 1.0 && doubleTapScale <= maxScale),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GestureZoomBoxState();
  }
}

class _GestureZoomBoxState extends State<GestureZoomBox>
    with TickerProviderStateMixin {
  // 缩放动画控制器
  AnimationController? _scaleAnimController;

  // 偏移动画控制器
  AnimationController? _offsetAnimController;

  // 首次缩放变化数据
  ScaleUpdateDetails? _firstScaleUpdateDetails;

  // 上次缩放变化数据
  ScaleUpdateDetails? _latestScaleUpdateDetails;

  // 当前缩放值
  double _scale = 1.0;

  // 当前偏移值
  Offset _offset = Offset.zero;

  // 双击缩放的点击位置
  Offset? _doubleTapPosition;

  bool _isScaling = false;
  bool _isDragging = false;

  // 拖动超出边界的最大值
  double _maxDragOver = 100;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..translate(_offset.dx, _offset.dy)
        ..scale(_scale, _scale),
      child: Listener(
        onPointerUp: _onPointerUp,
        child: GestureDetector(
          onTap: widget.onPressed,
          onDoubleTap: _onDoubleTap,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleAnimController?.dispose();
    _offsetAnimController?.dispose();
    super.dispose();
  }

  /// 处理手指抬起事件 [event]
  _onPointerUp(PointerUpEvent event) {
    _doubleTapPosition = event.localPosition;
  }

  /// 处理双击
  _onDoubleTap() {
    double targetScale = _scale == 1.0 ? widget.doubleTapScale : 1.0;
    _animationScale(targetScale);
    if (targetScale == 1.0) {
      _animationOffset(Offset.zero);
    }
  }

  _onScaleStart(ScaleStartDetails details) {
    _scaleAnimController?.stop();
    _offsetAnimController?.stop();
    _isScaling = false;
    _isDragging = false;
    _firstScaleUpdateDetails = null;
    _latestScaleUpdateDetails = null;
  }

  /// 处理缩放变化 [details]
  _onScaleUpdate(ScaleUpdateDetails details) {
    // 弃用首次事件，因为首次事件的 scale 经常为 1.0，会导致无法触发缩放
    if (_firstScaleUpdateDetails == null) {
      _firstScaleUpdateDetails = details;
      return;
    }
    // 触发缩放/拖动
    setState(() {
      if (details.scale != 1.0) {
        _scaling(details);
      } else {
        _dragging(details);
      }
    });
  }

  /// 执行缩放
  _scaling(ScaleUpdateDetails details) {
    if (_isDragging) {
      return;
    }
    final latestScaleUpdateDetails = _latestScaleUpdateDetails,
        size = context.size;
    _isScaling = true;
    if (latestScaleUpdateDetails == null || size == null) {
      _latestScaleUpdateDetails = details;
      return;
    }

    // 计算缩放比例
    double scaleIncrement = details.scale - latestScaleUpdateDetails.scale;
    if (details.scale < 1.0 && _scale > 1.0) {
      scaleIncrement *= _scale;
    }
    if (_scale < 1.0 && scaleIncrement < 0) {
      scaleIncrement *= (_scale - 0.5);
    } else if (_scale > widget.maxScale && scaleIncrement > 0) {
      scaleIncrement *= (2.0 - (_scale - widget.maxScale));
    }
    _scale = max(_scale + scaleIncrement, 0.0);

    // 计算缩放后偏移前（缩放前后的内容中心对齐）的左上角坐标变化
    double scaleOffsetX = size.width * (_scale - 1.0) / 2;
    double scaleOffsetY = size.height * (_scale - 1.0) / 2;
    // 将缩放前的触摸点映射到缩放后的内容上
    double scalePointDX =
        (details.localFocalPoint.dx + scaleOffsetX - _offset.dx) / _scale;
    double scalePointDY =
        (details.localFocalPoint.dy + scaleOffsetY - _offset.dy) / _scale;
    // 计算偏移，使缩放中心在屏幕上的位置保持不变
    _offset += Offset(
      (size.width / 2 - scalePointDX) * scaleIncrement,
      (size.height / 2 - scalePointDY) * scaleIncrement,
    );

    _latestScaleUpdateDetails = details;
  }

  /// 执行拖动
  _dragging(ScaleUpdateDetails details) {
    if (_isScaling) {
      return;
    }
    final latestScaleUpdateDetails = _latestScaleUpdateDetails,
        size = context.size;
    _isDragging = true;
    if (latestScaleUpdateDetails == null || size == null) {
      _latestScaleUpdateDetails = details;
      return;
    }

    // 计算本次拖动增量
    double offsetXIncrement = (details.localFocalPoint.dx -
            latestScaleUpdateDetails.localFocalPoint.dx) *
        _scale;
    double offsetYIncrement = (details.localFocalPoint.dy -
            latestScaleUpdateDetails.localFocalPoint.dy) *
        _scale;
    // 处理 X 轴边界
    double scaleOffsetX =
        (size.width * _scale - MediaQuery.of(context).size.width) / 2;
    if (scaleOffsetX <= 0) {
      offsetXIncrement = 0;
    } else if (_offset.dx > scaleOffsetX) {
      offsetXIncrement *=
          (_maxDragOver - (_offset.dx - scaleOffsetX)) / _maxDragOver;
    } else if (_offset.dx < -scaleOffsetX) {
      offsetXIncrement *=
          (_maxDragOver - (-scaleOffsetX - _offset.dx)) / _maxDragOver;
    }
    // 处理 Y 轴边界
    double scaleOffsetY =
        (size.height * _scale - MediaQuery.of(context).size.height) / 2;
    if (scaleOffsetY <= 0) {
      offsetYIncrement = 0;
    } else if (_offset.dy > scaleOffsetY) {
      offsetYIncrement *=
          (_maxDragOver - (_offset.dy - scaleOffsetY)) / _maxDragOver;
    } else if (_offset.dy < -scaleOffsetY) {
      offsetYIncrement *=
          (_maxDragOver - (-scaleOffsetY - _offset.dy)) / _maxDragOver;
    }

    _offset += Offset(offsetXIncrement, offsetYIncrement);

    _latestScaleUpdateDetails = details;
  }

  /// 缩放/拖动结束
  _onScaleEnd(ScaleEndDetails details) {
    final size = context.size;

    if (size == null) {
      return;
    }

    if (_scale < 1.0) {
      // 缩放值过小，恢复到 1.0
      _animationScale(1.0);
    } else if (_scale > widget.maxScale) {
      // 缩放值过大，恢复到最大值
      _animationScale(widget.maxScale);
    }
    if (_scale <= 1.0) {
      // 缩放值过小，修改偏移值，使内容居中
      _animationOffset(Offset.zero);
    } else if (_isDragging) {
      // 处理拖动超过边界的情况（自动回弹到边界）
      double realScale = _scale > widget.maxScale ? widget.maxScale : _scale;
      double targetOffsetX = _offset.dx, targetOffsetY = _offset.dy;
      // 处理 X 轴边界
      double scaleOffsetX =
          (size.width * realScale - MediaQuery.of(context).size.width) / 2;
      if (scaleOffsetX <= 0) {
        targetOffsetX = 0;
      } else if (_offset.dx > scaleOffsetX) {
        targetOffsetX = scaleOffsetX;
      } else if (_offset.dx < -scaleOffsetX) {
        targetOffsetX = -scaleOffsetX;
      }
      // 处理 Y 轴边界
      double scaleOffsetY =
          (size.height * realScale - MediaQuery.of(context).size.height) / 2;
      if (scaleOffsetY < 0) {
        targetOffsetY = 0;
      } else if (_offset.dy > scaleOffsetY) {
        targetOffsetY = scaleOffsetY;
      } else if (_offset.dy < -scaleOffsetY) {
        targetOffsetY = -scaleOffsetY;
      }
      if (_offset.dx != targetOffsetX || _offset.dy != targetOffsetY) {
        // 启动越界回弹
        _animationOffset(Offset(targetOffsetX, targetOffsetY));
      } else {
        // 处理 X 轴边界
        double duration =
            (widget.duration.inSeconds + widget.duration.inMilliseconds / 1000);
        Offset targetOffset =
            _offset + details.velocity.pixelsPerSecond * duration;
        targetOffsetX = targetOffset.dx;
        if (targetOffsetX > scaleOffsetX) {
          targetOffsetX = scaleOffsetX;
        } else if (targetOffsetX < -scaleOffsetX) {
          targetOffsetX = -scaleOffsetX;
        }
        // 处理 X 轴边界
        targetOffsetY = targetOffset.dy;
        if (targetOffsetY > scaleOffsetY) {
          targetOffsetY = scaleOffsetY;
        } else if (targetOffsetY < -scaleOffsetY) {
          targetOffsetY = -scaleOffsetY;
        }
        // 启动惯性滚动
        _animationOffset(Offset(targetOffsetX, targetOffsetY));
      }
    }

    _isScaling = false;
    _isDragging = false;
    _latestScaleUpdateDetails = null;
  }

  /// 执行动画缩放内容到 [targetScale]
  _animationScale(double targetScale) {
    _scaleAnimController?.dispose();
    final scaleAnimController = _scaleAnimController =
        AnimationController(vsync: this, duration: widget.duration);
    Animation anim = Tween<double>(begin: _scale, end: targetScale)
        .animate(scaleAnimController);
    anim.addListener(() {
      setState(() {
        _scaling(ScaleUpdateDetails(
          focalPoint: _doubleTapPosition!,
          localFocalPoint: _doubleTapPosition!,
          scale: anim.value,
          horizontalScale: anim.value,
          verticalScale: anim.value,
        ));
      });
    });
    anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onScaleEnd(ScaleEndDetails());
      }
    });
    scaleAnimController.forward();
  }

  /// 执行动画偏移内容到 [targetOffset]
  _animationOffset(Offset targetOffset) {
    _offsetAnimController?.dispose();
    final offsetAnimController = _offsetAnimController =
        AnimationController(vsync: this, duration: widget.duration);
    Animation anim = offsetAnimController
        .drive(Tween<Offset>(begin: _offset, end: targetOffset));
    anim.addListener(() {
      setState(() {
        _offset = anim.value;
      });
    });
    offsetAnimController.fling();
  }
}
