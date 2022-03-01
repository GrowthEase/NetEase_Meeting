// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uikit/values/colors.dart';

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    required this.controller,
    required this.itemCount,
    required this.onPageSelected,
    this.color: Colors.white,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  // The base size of the dots
  static const double _kDotSize = 7.0;

  // The increase in the size of the selected dot
  // static const double _kMaxZoom = 1.5;

  // The distance between the center of each dot
  static const double _kDotSpacing = 16.0;

  Widget _buildDot(int index) {
//    double select = Curves.easeOut.transform(
//      max(
//        0.0,
//        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
//      ),
//    );
//    double zoom = 1.0 + (_kMaxZoom - 1.0) * select;
    bool select = ((controller.page?.round() ?? controller.initialPage) - index) == 0;
    return Container(
      width: _kDotSpacing,
      child: new Material(
        color: select ? Colors.white : AppColors.white50FFFFFF,
        type: MaterialType.circle,
        child: new Container(
          width: _kDotSize,
          height: _kDotSize,
          //            child: new InkWell(
          //              onTap: () => onPageSelected(index),
          //            ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
