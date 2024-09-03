// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

typedef DraggablePositionedOnPinStart = void Function(Alignment alignment);

class DraggablePositioned extends StatefulWidget {
  const DraggablePositioned({
    Key? key,
    this.paddings,
    this.pinToEdge = true,
    this.pinAnimationDuration = const Duration(seconds: 1),
    this.pinAnimationCurve = Curves.ease,
    required this.size,
    required this.builder,
    this.initialAlignment = Alignment.topRight,
    this.onPositionChanged,
  }) : super(key: key);

  final Size size;
  final ValueListenable<EdgeInsets>? paddings;
  final bool pinToEdge;
  final Duration pinAnimationDuration;
  final Curve pinAnimationCurve;
  final WidgetBuilder builder;
  final Alignment initialAlignment;
  final DraggablePositionedOnPinStart? onPositionChanged;

  @override
  State<DraggablePositioned> createState() => _DraggablePositionedState();
}

class _DraggablePositionedState extends State<DraggablePositioned>
    with SingleTickerProviderStateMixin {
  static const tag = 'DraggablePositioned';

  var panEnded = true;
  var layoutChanged = false;
  var resetAlignment = false;
  Animation<RelativeRect>? currentPinAnimation;

  var stackSize = Size.zero;
  late Alignment alignment;

  var initialOffset = Offset.zero;
  var offsetByGesture = Offset.zero;
  Rect? _validChildRegion;

  late final AnimationController _pinAnimationController;

  double get childWidth => widget.size.width;

  double get childHeight => widget.size.height;

  EdgeInsets get viewPaddings => widget.paddings?.value ?? EdgeInsets.zero;

  Rect get validChildRegion {
    _validChildRegion ??= Rect.fromLTRB(
      viewPaddings.left,
      viewPaddings.top,
      stackSize.width - childWidth - viewPaddings.right,
      stackSize.height - childHeight - viewPaddings.bottom,
    );
    return _validChildRegion!;
  }

  void ensureInitialOffset() {
    final paddings = viewPaddings;
    var dx = paddings.left;
    var dy = paddings.top;
    if (alignment == Alignment.topRight) {
      dx = stackSize.width - paddings.right - childWidth;
    } else if (alignment == Alignment.bottomLeft) {
      dy = stackSize.height - paddings.bottom - childHeight;
    } else if (alignment == Alignment.bottomRight) {
      dx = stackSize.width - paddings.right - childWidth;
      dy = stackSize.height - paddings.bottom - childHeight;
    }
    initialOffset = Offset(dx, dy);
  }

  void handleViewPaddingsChanged() {
    _validChildRegion = null;
    if (panEnded) {
      setState(() {
        currentPinAnimation = null;
      });
    }
  }

  Animation<RelativeRect> calculateAnimation() {
    final offset = initialOffset + offsetByGesture;
    final left = panEnded
        ? offset.dx
        : min(max(offset.dx, viewPaddings.left),
            stackSize.width - childWidth - viewPaddings.right);
    final top = panEnded
        ? offset.dy
        : min(max(offset.dy, viewPaddings.top),
            stackSize.height - childHeight - viewPaddings.bottom);
    final currentRect = Rect.fromLTWH(left, top, childWidth, childHeight);
    debugPrintThrottled('$tag: calculateAnimation '
        'offset=$offset, '
        'rect=$currentRect, '
        'panEnded=$panEnded, '
        'layoutChanged=$layoutChanged, '
        'currentAni=${currentPinAnimation?.value}');

    Animation<RelativeRect> rect;
    if (!panEnded || layoutChanged) {
      layoutChanged = false;
      rect = AlwaysStoppedAnimation(
        RelativeRect.fromSize(currentRect, stackSize),
      );
    } else {
      if (currentPinAnimation != null) {
        return currentPinAnimation!;
      }

      final halfWidthOfContainer = stackSize.width / 2;
      final halfHeightOfContainer = stackSize.height / 2;

      final double left, top;

      Alignment? useAlignment = alignment;
      if (resetAlignment) {
        resetAlignment = false;
        useAlignment = null;
      }

      final paddings = viewPaddings;
      if (useAlignment == Alignment.topLeft ||
          Rect.fromLTWH(0, 0, halfWidthOfContainer, halfHeightOfContainer)
              .contains(currentRect.center)) {
        // top left
        left = paddings.left;
        top = paddings.top;
        alignment = Alignment.topLeft;
      } else if (useAlignment == Alignment.bottomLeft ||
          Rect.fromLTWH(0, halfHeightOfContainer, halfWidthOfContainer,
                  halfHeightOfContainer)
              .contains(currentRect.center)) {
        // bottom left
        left = paddings.left;
        top = stackSize.height - paddings.bottom - childHeight;
        alignment = Alignment.bottomLeft;
      } else if (useAlignment == Alignment.topRight ||
          Rect.fromLTWH(halfWidthOfContainer, 0, halfWidthOfContainer,
                  halfHeightOfContainer)
              .contains(currentRect.center)) {
        // top right
        left = stackSize.width - paddings.right - childWidth;
        top = paddings.top;
        alignment = Alignment.topRight;
      } else {
        // bottom right
        left = stackSize.width - paddings.right - childWidth;
        top = stackSize.height - paddings.bottom - childHeight;
        alignment = Alignment.bottomRight;
      }

      final targetRect = Rect.fromLTWH(left, top, childWidth, childHeight);

      rect = RelativeRectTween(
        begin: RelativeRect.fromSize(currentRect, stackSize),
        end: RelativeRect.fromSize(targetRect, stackSize),
      ).animate(
        CurvedAnimation(
          parent: _pinAnimationController,
          curve: widget.pinAnimationCurve,
        ),
      );
      currentPinAnimation = rect;

      _pinAnimationController.reset();
      _pinAnimationController.forward();
      initialOffset = Offset(left, top);
      offsetByGesture = Offset.zero;

      if (useAlignment == null) widget.onPositionChanged?.call(alignment);
    }

    return rect;
  }

  @override
  void initState() {
    super.initState();
    _pinAnimationController = AnimationController(
      debugLabel: tag,
      duration: widget.pinAnimationDuration,
      vsync: this,
    );
    alignment = widget.initialAlignment;
    widget.paddings?.addListener(handleViewPaddingsChanged);
  }

  @override
  void didUpdateWidget(DraggablePositioned oldWidget) {
    super.didUpdateWidget(oldWidget);
    alignment = widget.initialAlignment;
    initialOffset = Offset.zero;
    oldWidget.paddings?.removeListener(handleViewPaddingsChanged);
    widget.paddings?.addListener(handleViewPaddingsChanged);
  }

  @override
  void dispose() {
    _pinAnimationController.stop();
    _pinAnimationController.dispose();
    widget.paddings?.removeListener(handleViewPaddingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrintThrottled('screen size: ' + MediaQuery.of(context).toString());
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          debugPrintThrottled('$tag: stack size: ' + constraints.toString());
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (size != stackSize) {
            initialOffset = Offset.zero;
            stackSize = size;
            layoutChanged = true;
            currentPinAnimation = null;
          }
          if (initialOffset == Offset.zero) {
            ensureInitialOffset();
            debugPrintThrottled('$tag: ensureInitialOffset=$initialOffset');
          }
          final gestures = <Type, GestureRecognizerFactory>{
            PanGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
              () => PanGestureRecognizer(debugOwner: this),
              (PanGestureRecognizer instance) {
                instance
                  ..onStart = onPanStart
                  ..onUpdate = onPanUpdate
                  ..onEnd = onPanEnd
                  ..gestureSettings = _PanPreferredDeviceGestureSettings(
                      MediaQuery.maybeOf(context)?.gestureSettings.touchSlop);
              },
            ),
          };
          return Stack(
            key: ValueKey(stackSize),
            children: [
              PositionedTransition(
                rect: calculateAnimation(),
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  gestures: gestures,
                  child: ConstrainedBox(
                    constraints: BoxConstraints.expand(
                      width: childWidth,
                      height: childHeight,
                    ),
                    child: Builder(
                      builder: (context) {
                        return widget.builder(context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    debugPrintThrottled('onPanStart: $details');
    setState(() {
      panEnded = false;
      _pinAnimationController.stop();
    });
  }

  void onPanEnd(DragEndDetails details) {
    debugPrintThrottled('onPanEnd: $details');
    setState(() {
      panEnded = true;
      resetAlignment = true;
      currentPinAnimation = null;
    });
  }

  void onPanUpdate(DragUpdateDetails details) {
    debugPrintThrottled(
        'onPanUpdate: ${details.delta} ${details.globalPosition} ${details.localPosition}');
    final offset = offsetByGesture + details.delta;
    if (!panEnded && validChildRegion.contains(initialOffset + offset)) {
      setState(() {
        offsetByGesture = offset;
      });
    }
  }
}

///
/// 为了比 [HorizontalDragGestureRecognizer] 和 [VerticalDragGestureRecognizer] 更高优先级响应手势
/// 否则，pan 手势容易被诸如 [PageView] 的左右滑动组件抢占手势
///
class _PanPreferredDeviceGestureSettings extends DeviceGestureSettings {
  _PanPreferredDeviceGestureSettings(double? touchSlop)
      : super(touchSlop: touchSlop ?? kTouchSlop);

  @override
  double? get panSlop => touchSlop != null ? (touchSlop! * 2 / 3) : null;
}
