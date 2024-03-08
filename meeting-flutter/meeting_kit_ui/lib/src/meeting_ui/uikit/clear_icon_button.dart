// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class ClearIconButton extends StatelessWidget {
  final double size;
  final VoidCallback? onPressed;

  ClearIconButton({super.key, this.size = 17, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(
        NEMeetingIconFont.icon_yx_input_clearx,
        size: size,
        color: _UIColors.color_60_3C3C43,
      ),
    );
  }
}
