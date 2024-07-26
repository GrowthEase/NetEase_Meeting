// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class DropdownIconButton extends StatelessWidget {
  final double size;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;

  DropdownIconButton({super.key, this.size = 17, this.onPressed, this.padding});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        padding: padding,
        child: Icon(
          NEMeetingIconFont.icon_arrow_down,
          size: size,
          color: _UIColors.color_60_3C3C43,
        ),
      ),
    );
  }
}
