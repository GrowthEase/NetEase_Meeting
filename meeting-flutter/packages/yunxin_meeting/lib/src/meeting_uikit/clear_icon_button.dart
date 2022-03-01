// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_uikit;

class ClearIconButton extends IconButton {
  ClearIconButton({required VoidCallback onPressed, Key? key})
      : super(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          padding: EdgeInsets.all(0),
          alignment: Alignment.centerRight,
          icon: Icon(
            NEMeetingIconFont.icon_yx_input_clearx,
            size: 17,
            color: UIColors.color_60_3C3C43,
          ),
          onPressed: onPressed,
          key: key,
        );
}
