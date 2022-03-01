// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class PopupMenuWidget extends StatefulWidget {
  PopupMenuWidget({
    Key? key,
    required this.onValueChanged,
    required this.actions,
    required this.child,
    this.onShow,
    this.onDismiss,
    this.pressType = PressType.longPress,
    this.pageMaxChildCount = 5,
    this.backgroundColor = Colors.black,
    this.menuWidth = 40,
    this.menuHeight = 35,
    this.textSize = 12,
  });

  final ValueChanged<int> onValueChanged;
  final VoidCallback? onShow;
  final VoidCallback? onDismiss;
  final List<String> actions;
  final Widget child;
  final PressType pressType; // 点击方式 长按 还是单击
  final int pageMaxChildCount;
  final Color backgroundColor;
  final double menuWidth;
  final double menuHeight;
  final double textSize;

  @override
  _PopupMenuWidgetState createState() => _PopupMenuWidgetState();
}

class _PopupMenuWidgetState extends State<PopupMenuWidget> {
  double? width;
  double? height;
  late RenderBox button;
  late RenderBox overlay;
  OverlayEntry? entry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((call) {
      if (!mounted) return;
      if (context.size != null) {
        width = context.size!.width;
        height = context.size!.height;
      }
      button = context.findRenderObject() as RenderBox;
      overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        removeOverlay();
        return Future.value(true);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: widget.child,
        onTap: () {
          if (widget.pressType == PressType.singleClick) {
            onTap();
          }
        },
        onLongPress: () {
          if (widget.pressType == PressType.longPress) {
            onTap();
          }
        },
      ),
    );
  }

  void onTap() {
    Widget menuWidget = _MenuPopWidget(
      context,
      height,
      width,
      widget.actions,
      widget.pageMaxChildCount,
      widget.backgroundColor,
      widget.menuWidth,
      widget.menuHeight,
      widget.textSize,
      button,
      overlay,
      (index) {
        if (index != -1) widget.onValueChanged(index);
        removeOverlay();
      },
    );

    entry = OverlayEntry(builder: (context) {
      return menuWidget;
    });
    Overlay.of(context)!.insert(entry!);
    widget.onShow?.call();
  }

  void removeOverlay() {
    if (entry != null) {
      entry!.remove();
      entry = null;

      widget.onDismiss?.call();
    }
  }
}

enum PressType {
  // 长按
  longPress,
  // 单击
  singleClick,
}

class _MenuPopWidget extends StatefulWidget {
  final BuildContext btnContext;
  final List<String> actions;
  final int _pageMaxChildCount;
  final Color backgroundColor;
  final double menuWidth;
  final double menuHeight;
  final double textSize;
  final double? _height;
  final double? _width;
  final RenderBox button;
  final RenderBox overlay;
  final ValueChanged<int> onValueChanged;

  _MenuPopWidget(
    this.btnContext,
    this._height,
    this._width,
    this.actions,
    this._pageMaxChildCount,
    this.backgroundColor,
    this.menuWidth,
    this.menuHeight,
    this.textSize,
    this.button,
    this.overlay,
    this.onValueChanged,
  );

  @override
  _MenuPopWidgetState createState() => _MenuPopWidgetState();
}

class _MenuPopWidgetState extends State<_MenuPopWidget> {
  int _curPage = 0;
  final double _arrowWidth = 40;
  final double _separatorWidth = 1;
  final double _triangleHeight = 5;
  final double _triangleRadius = 6;

  late RelativeRect position;

  @override
  void initState() {
    super.initState();
    position = RelativeRect.fromRect(
      Rect.fromPoints(
        widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
        widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
      ),
      Offset.zero & widget.overlay.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 这里计算出来 当前页的 child 一共有多少个
    var _curPageChildCount =
        (_curPage + 1) * widget._pageMaxChildCount > widget.actions.length
            ? widget.actions.length % widget._pageMaxChildCount
            : widget._pageMaxChildCount;

    var _curArrowWidth = 0.0;
    var _curArrowCount = 0; // 一共几个箭头

    if (widget.actions.length > widget._pageMaxChildCount) {
      // 数据长度大于 widget._pageMaxChildCount
      if (_curPage == 0) {
        // 如果是第一页
        _curArrowWidth = _arrowWidth;
        _curArrowCount = 1;
      } else {
        // 如果不是第一页 则需要也显示左箭头
        _curArrowWidth = _arrowWidth * 2;
        _curArrowCount = 2;
      }
    }

    var _curPageWidth = widget.menuWidth +
        (_curPageChildCount - 1 + _curArrowCount) * _separatorWidth +
        _curArrowWidth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onValueChanged(-1);
      },
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: Builder(
          builder: (BuildContext context) {
            var isInverted = (position.top +
                    (MediaQuery.of(context).size.height -
                            position.top -
                            position.bottom) /
                        2.0 -
                    (widget.menuHeight + _triangleHeight)) <
                (widget.menuHeight + _triangleHeight) * 2;
            return CustomSingleChildLayout(
              // 这里计算偏移量
              delegate: _PopupMenuRouteLayout(
                  context,
                  position,
                  widget.menuHeight + _triangleHeight,
                  Directionality.of(widget.btnContext),
                  widget._width!,
                  widget.menuWidth,
                  widget._height!),
              child: SizedBox(
                height: widget.menuHeight + _triangleHeight,
                width: _curPageWidth,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      isInverted
                          ? CustomPaint(
                              size: Size(_curPageWidth, _triangleHeight),
                              painter: TrianglePainter(
                                color: widget.backgroundColor,
                                position: position,
                                isInverted: true,
                                size: widget.button.size,
                                radius: _triangleRadius,
                                screenWidth: MediaQuery.of(context).size.width,
                              ),
                            )
                          : Container(),
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              child: Container(
                                color: widget.backgroundColor,
                                height: widget.menuHeight,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                // 左箭头：判断是否是第一页，如果是第一页则不显示
                                _curPage == 0
                                    ? Container(
                                        height: widget.menuHeight,
                                      )
                                    : InkWell(
                                        onTap: () {
                                          setState(() {
                                            _curPage--;
                                          });
                                        },
                                        child: Container(
                                          width: _arrowWidth,
                                          height: widget.menuHeight,
                                          child: NEMeetingImages.assetImage(
                                              NEMeetingImages.arrowLeftWhite),
                                        ),
                                      ),
                                // 左箭头：判断是否是第一页，如果是第一页则不显示
                                _curPage == 0
                                    ? Container(
                                        height: widget.menuHeight,
                                      )
                                    : Container(
                                        width: 1,
                                        height: widget.menuHeight,
                                        color: Colors.grey,
                                      ),

                                // 中间是ListView
                                _buildList(_curPageChildCount, _curPageWidth,
                                    _curArrowWidth, _curArrowCount),

                                // 右箭头：判断是否有箭头，如果有就显示，没有就不显示
                                _curArrowCount > 0
                                    ? Container(
                                        width: 1,
                                        color: Colors.grey,
                                        height: widget.menuHeight,
                                      )
                                    : Container(
                                        height: widget.menuHeight,
                                      ),
                                _curArrowCount > 0
                                    ? InkWell(
                                        onTap: () {
                                          if ((_curPage + 1) *
                                                  widget._pageMaxChildCount <
                                              widget.actions.length) {
                                            setState(() {
                                              _curPage++;
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: _arrowWidth,
                                          height: widget.menuHeight,
                                          child: (_curPage + 1) *
                                                      widget
                                                          ._pageMaxChildCount >=
                                                  widget.actions.length
                                              ? NEMeetingImages.assetImage(
                                                  NEMeetingImages
                                                      .arrowRightGray)
                                              : NEMeetingImages.assetImage(
                                                  NEMeetingImages
                                                      .arrowRightWhite),
                                        ),
                                      )
                                    : Container(
                                        height: widget.menuHeight,
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      isInverted
                          ? Container()
                          : CustomPaint(
                              size: Size(_curPageWidth, _triangleHeight),
                              painter: TrianglePainter(
                                color: widget.backgroundColor,
                                position: position,
                                size: widget.button.size,
                                radius: _triangleRadius,
                                screenWidth: MediaQuery.of(context).size.width,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(int _curPageChildCount, double _curPageWidth,
      double _curArrowWidth, int _curArrowCount) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: _curPageChildCount,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            widget.onValueChanged(_curPage * widget._pageMaxChildCount + index);
          },
          child: SizedBox(
            width: (_curPageWidth -
                    _curArrowWidth -
                    (_curPageChildCount - 1 + _curArrowCount) *
                        _separatorWidth) /
                _curPageChildCount,
            height: widget.menuHeight,
            child: Center(
              child: Text(
                widget.actions[_curPage * widget._pageMaxChildCount + index],
                style:
                    TextStyle(color: Colors.white, fontSize: widget.textSize),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: 1,
          height: widget.menuHeight,
          color: Colors.grey,
        );
      },
    );
  }
}

// Positioning of the menu on the screen.
class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(this.context, this.position, this.selectedItemOffset,
      this.textDirection, this.width, this.menuWidth, this.height);

  BuildContext context;

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final RelativeRect position;

  // The distance from the top of the menu to the middle of selected item.
  //
  // This will be null if there's no item to position in this way.
  final double selectedItemOffset;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  final double width;
  final double height;
  final double menuWidth;

  // We put the child wherever position specifies, so long as it will fit within
  // the specified parent size padded (inset) by 8. If necessary, we adjust the
  // child's position so that it fits.

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    var size = (constraints.biggest -
            const Offset(_kMenuScreenPadding * 2.0, _kMenuScreenPadding * 2.0))
        as Size;
    return BoxConstraints.loose(size);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.

    // Find the ideal vertical position.
    double y;
    if (selectedItemOffset == null) {
      y = position.top;
    } else {
      y = position.top +
          (size.height - position.top - position.bottom) / 2.0 -
          selectedItemOffset;
    }

    // Find the ideal horizontal position.
    double x;

    var topPadding = MediaQuery.of(context).padding.top;
    var bottomPadding = MediaQuery.of(context).padding.bottom;
    // 如果menu 的宽度 小于 child 的宽度，则直接把menu 放在 child 中间
    if (childSize.width < width) {
      x = position.left + (width - childSize.width) / 2;
    } else {
      // 如果靠右
      if (position.left > size.width - (position.left + width)) {
        if (size.width - (position.left + width) >
            childSize.width / 2 + _kMenuScreenPadding) {
          x = position.left - (childSize.width - width) / 2;
        } else {
          x = position.left + width - childSize.width;
        }
      } else if (position.left < size.width - (position.left + width)) {
        if (position.left > childSize.width / 2 + _kMenuScreenPadding) {
          x = position.left - (childSize.width - width) / 2;
        } else {
          x = position.left;
        }
      } else {
        x = position.right - width / 2 - childSize.width / 2;
      }
    }

    // Alog.i(tag: _tag,moduleName: moduleName,content:'popup_menu_widget screenHeight = $_screenHeight, taskBarHeight = $_taskBarHeight, '
    //     'bottomNavigationBarHeight = $_bottomNavigationBarHeight');
    // Alog.i(tag: _tag,moduleName: moduleName,content:'popup_menu_widget position.top = ${position.top}, position.bottom = ${position.bottom} , '
    //     'size.height = ${size.height}, childSize.height = ${childSize.height}, y = $y， itemHeight = $height, '
    //     'selectedItemOffset = $selectedItemOffset' );
    if ((y < _taskBarHeight + _titleBarHeight) &&
        (position.top + height > getContainerHeight(size))) {
      y = size.height / 2;
    } else if (y < _taskBarHeight + _titleBarHeight) {
      y = position.top + height;
    } else if (y + childSize.height > size.height - _kMenuScreenPadding) {
      y = size.height - childSize.height;
    } else if (y < childSize.height * 2) {
      y = position.top + height;
    }
    return Offset(x, y);
  }

  double getContainerHeight(Size size) {
    return size.height -
        _titleBarHeight -
        _taskBarHeight -
        _inputBarHeight -
        _bottomNavigationBarHeight;
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}
