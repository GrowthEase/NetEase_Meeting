// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class ClearIconButton extends StatelessWidget {
  final double size;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;

  ClearIconButton({super.key, this.size = 16, this.onPressed, this.padding});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        padding: padding,
        child: Icon(
          NEMeetingIconFont.icon_yx_input_clearx,
          size: size,
          color: _UIColors.color8D90A0,
        ),
      ),
    );
  }
}
