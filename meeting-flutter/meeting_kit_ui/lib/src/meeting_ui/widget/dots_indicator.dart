// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class DotsIndicator extends StatefulWidget {
  const DotsIndicator({
    Key? key,
    required this.itemCount,
    required this.selectedIndex,
    this.background = _UIColors.color_292933,
    this.color = const Color(0x80FFFFFF),
    this.selectedColor = Colors.white,
  }) : super(key: key);

  final int itemCount;

  final ValueListenable<int> selectedIndex;

  final Color background;

  final Color color;

  final Color selectedColor;

  @override
  State<DotsIndicator> createState() => _DotsIndicatorState();
}

class _DotsIndicatorState extends State<DotsIndicator> {
  static const kTag = 'DotsIndicator';

  // The base size of the dots
  static const double _kDotSize = 7.0;
  static const double _kPaddingValue = 4.0;
  static const double _kStride = _kDotSize + _kPaddingValue;
  static const int _kPageSize = 10;
  static const double _kMaxWidth = _kStride * _kPageSize + _kDotSize / 2;
  static const double _kHeight = _kDotSize * 2;

  final controller = ScrollController();

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex.value;
    widget.selectedIndex.addListener(onSelectedIndexChanged);
  }

  @override
  void dispose() {
    widget.selectedIndex.removeListener(onSelectedIndexChanged);
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DotsIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.selectedIndex.removeListener(onSelectedIndexChanged);
    widget.selectedIndex.addListener(onSelectedIndexChanged);
  }

  void onSelectedIndexChanged() {
    setState(() {});
    final index = widget.selectedIndex.value;
    debugPrint('$kTag#onSelectedIndexChanged: $_selectedIndex -> $index');
    final movingRight = index > _selectedIndex;
    _selectedIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if ((index > 0 && movingRight && index % _kPageSize == 0) ||
          (!movingRight && (index + 1) % _kPageSize == 0)) {
        if (movingRight) {
          var count = index;
          if (widget.itemCount - index < _kPageSize) {
            count = widget.itemCount - _kPageSize;
          }
          controller.jumpTo(count * _kStride);
        } else {
          controller.jumpTo((index + 1 - _kPageSize) * _kStride);
        }
      }
    });
  }

  Widget _buildDot(int index) {
    var select = index == widget.selectedIndex.value;
    return Container(
      child: ClipPath.shape(
        shape: CircleBorder(),
        child: Container(
          color: select ? widget.selectedColor : widget.color,
          width: _kDotSize,
          height: _kDotSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.background,
        borderRadius: BorderRadius.circular(_kDotSize),
        shape: BoxShape.rectangle,
      ),
      padding: EdgeInsets.symmetric(horizontal: _kPaddingValue),
      height: _kHeight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _kMaxWidth,
        ),
        child: MediaQuery.removePadding(
          removeLeft: true,
          removeRight: true,
          context: context,
          child: ListView.separated(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: widget.itemCount,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return _buildDot(index);
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                width: _kPaddingValue,
              );
            },
          ),
        ),
      ),
    );
  }
}
