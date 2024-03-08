// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class RawPIPView extends StatefulWidget {
  final PIPViewCorner initialCorner;
  final double? floatingWidth;
  final double? floatingHeight;
  final bool avoidKeyboard;
  final Widget? topWidget;
  final Widget? bottomWidget;
  final double? ratio;

  // this is exposed because trying to watch onTap event
  // by wrapping the top widget with a gesture detector
  // causes the tap to be lost sometimes because it
  // is competing with the drag
  final void Function()? onTapTopWidget;

  const RawPIPView({
    Key? key,
    this.initialCorner = PIPViewCorner.bottomRight,
    this.ratio,
    this.floatingWidth,
    this.floatingHeight,
    this.avoidKeyboard = true,
    this.topWidget,
    this.bottomWidget,
    this.onTapTopWidget,
  }) : super(key: key);

  @override
  RawPIPViewState createState() => RawPIPViewState();
}

class RawPIPViewState extends State<RawPIPView> with TickerProviderStateMixin {
  late final AnimationController _toggleFloatingAnimationController;
  late final AnimationController _dragAnimationController;
  late PIPViewCorner _corner;
  Offset _dragOffset = Offset.zero;
  var _isDragging = false;
  var _isFloating = false;
  Widget? _bottomWidgetGhost;
  final pipDefaultRatio = 9 / 16;
  final _ratio = ValueNotifier(9 / 16);
  Map<PIPViewCorner, Offset> _offsets = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _corner = widget.initialCorner;
    _toggleFloatingAnimationController = AnimationController(
      duration: defaultAnimationDuration,
      vsync: this,
    );
    _dragAnimationController = AnimationController(
      duration: defaultAnimationDuration,
      vsync: this,
    );
    _ratio.value = pipDefaultRatio;
    if (widget.topWidget != null && widget.bottomWidget != null) {
      _isFloating = true;
      _toggleFloatingAnimationController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant RawPIPView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isFloating) {
      if (widget.topWidget == null || widget.bottomWidget == null) {
        _isFloating = false;
        _bottomWidgetGhost = oldWidget.bottomWidget;
        _toggleFloatingAnimationController.reverse().whenCompleteOrCancel(() {
          if (mounted) {
            setState(() => _bottomWidgetGhost = null);
          }
        });
      }
    } else {
      if (widget.topWidget != null && widget.bottomWidget != null) {
        _isFloating = true;
        _toggleFloatingAnimationController.forward();
      }
    }
  }

  void _updateCornersOffsets({
    required Size spaceSize,
    required Size widgetSize,
    required EdgeInsets windowPadding,
    required bool portrait,
  }) {
    _offsets = _calculateOffsets(
        spaceSize: spaceSize,
        widgetSize: widgetSize,
        windowPadding: windowPadding,
        portrait: portrait);
  }

  bool _isAnimating() {
    return _toggleFloatingAnimationController.isAnimating ||
        _dragAnimationController.isAnimating;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset = _dragOffset.translate(
        details.delta.dx,
        details.delta.dy,
      );
    });
  }

  void _onPanCancel() {
    if (!_isDragging) return;
    setState(() {
      _dragAnimationController.value = 0;
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final nearestCorner = _calculateNearestCorner(
      offset: _dragOffset,
      offsets: _offsets,
    );
    setState(() {
      _corner = nearestCorner;
      _isDragging = false;
    });
    _dragAnimationController.forward().whenCompleteOrCancel(() {
      _dragAnimationController.value = 0;
      _dragOffset = Offset.zero;
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating()) return;
    setState(() {
      _dragOffset = _offsets[_corner]!;
      _isDragging = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    var windowPadding = mediaQuery.padding;
    if (widget.avoidKeyboard) {
      windowPadding += mediaQuery.viewInsets;
    }
    if (widget.ratio != null) {
      _ratio.value = widget.ratio!;
    }
    return ValueListenableBuilder<double>(
      valueListenable: _ratio,
      builder: (context, state, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            bool portrait = state < 1;
            final bottomWidget = widget.bottomWidget ?? _bottomWidgetGhost;
            var width = constraints.maxWidth;
            var height = constraints.maxHeight;
            double? floatingWidth = widget.floatingWidth;
            double? floatingHeight = widget.floatingHeight;

            if (portrait) {
              floatingWidth = 100.0;
              floatingHeight = floatingWidth / state;
            } else {
              floatingHeight = 100.0;
              floatingWidth = floatingHeight * state;
            }

            final floatingWidgetSize = Size(floatingWidth, floatingHeight);
            final fullWidgetSize = Size(width, height);

            _updateCornersOffsets(
                spaceSize: fullWidgetSize,
                widgetSize: floatingWidgetSize,
                windowPadding: windowPadding,
                portrait: portrait);

            final calculatedOffset = _offsets[_corner];

            // BoxFit.cover
            // final widthRatio = floatingWidth / width;
            // final heightRatio = floatingHeight / height;
            // final scaledDownScale = portrait ? widthRatio : widthRatio;

            return Stack(
              children: <Widget>[
                if (bottomWidget != null) bottomWidget,
                if (widget.topWidget != null)
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _toggleFloatingAnimationController,
                      _dragAnimationController,
                    ]),
                    builder: (context, child) {
                      final animationCurve = CurveTween(
                        curve: Curves.easeInOutQuad,
                      );
                      final dragAnimationValue = animationCurve.transform(
                        _dragAnimationController.value,
                      );
                      final toggleFloatingAnimationValue =
                          animationCurve.transform(
                        _toggleFloatingAnimationController.value,
                      );

                      final floatingOffset = _isDragging
                          ? _dragOffset
                          : Tween<Offset>(
                              begin: _dragOffset,
                              end: calculatedOffset,
                            ).transform(_dragAnimationController.isAnimating
                              ? dragAnimationValue
                              : toggleFloatingAnimationValue);
                      final borderRadius = Tween<double>(
                        begin: 0,
                        end: 0.0,
                      ).transform(toggleFloatingAnimationValue);
                      final width = Tween<double>(
                        begin: fullWidgetSize.width,
                        end: floatingWidgetSize.width,
                      ).transform(toggleFloatingAnimationValue);
                      final height = Tween<double>(
                        begin: fullWidgetSize.height,
                        end: floatingWidgetSize.height,
                      ).transform(toggleFloatingAnimationValue);
                      // final scale = Tween<double>(
                      //   begin: 1,
                      //   end: scaledDownScale,
                      // ).transform(toggleFloatingAnimationValue);
                      return Positioned(
                        left: floatingOffset.dx,
                        top: floatingOffset.dy,
                        child: GestureDetector(
                          onPanStart: _isFloating ? _onPanStart : null,
                          onPanUpdate: _isFloating ? _onPanUpdate : null,
                          onPanCancel: _isFloating ? _onPanCancel : null,
                          onPanEnd: _isFloating ? _onPanEnd : null,
                          onTap: widget.onTapTopWidget,
                          child: Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(borderRadius),
                            child: Container(
                              // clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(borderRadius),
                              ),
                              width: width,
                              height: height,
                              child: child,
                              // child: Transform.scale(
                              //   scale: scale,
                              //   child: OverflowBox(
                              //     maxHeight: fullWidgetSize.height,
                              //     maxWidth: fullWidgetSize.width,
                              //     child: child,
                              //   ),
                              // ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: widget.topWidget,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

enum PIPViewCorner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _CornerDistance {
  final PIPViewCorner corner;
  final double distance;

  _CornerDistance({
    required this.corner,
    required this.distance,
  });
}

PIPViewCorner _calculateNearestCorner({
  required Offset offset,
  required Map<PIPViewCorner, Offset> offsets,
}) {
  _CornerDistance calculateDistance(PIPViewCorner corner) {
    final distance = offsets[corner]!
        .translate(
          -offset.dx,
          -offset.dy,
        )
        .distanceSquared;
    return _CornerDistance(
      corner: corner,
      distance: distance,
    );
  }

  final distances = PIPViewCorner.values.map(calculateDistance).toList();

  distances.sort((cd0, cd1) => cd0.distance.compareTo(cd1.distance));

  return distances.first.corner;
}

Map<PIPViewCorner, Offset> _calculateOffsets({
  required Size spaceSize,
  required Size widgetSize,
  required EdgeInsets windowPadding,
  required bool portrait,
}) {
  Offset getOffsetForCorner(PIPViewCorner corner) {
    final spacing = 16;
    final left = spacing + windowPadding.left;
    final top = spacing + windowPadding.top;
    final right =
        spaceSize.width - widgetSize.width - windowPadding.right - spacing;
    final bottom =
        spaceSize.height - widgetSize.height - windowPadding.bottom - spacing;

    switch (corner) {
      case PIPViewCorner.topLeft:
        return Offset(left, top);
      case PIPViewCorner.topRight:
        return Offset(right, top);
      case PIPViewCorner.bottomLeft:
        return Offset(left, bottom);
      case PIPViewCorner.bottomRight:
        return Offset(right, bottom);
      default:
        throw UnimplementedError();
    }
  }

  final corners = PIPViewCorner.values;
  final Map<PIPViewCorner, Offset> offsets = {};
  for (final corner in corners) {
    offsets[corner] = getOffsetForCorner(corner);
  }

  return offsets;
}
