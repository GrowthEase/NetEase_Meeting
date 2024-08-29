// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingTextSpanBuilder extends SpecialTextSpanBuilder {
  final double emojiSize;
  final bool showNickname;

  MeetingTextSpanBuilder({this.emojiSize = 21, this.showNickname = false});

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap,
      int? index}) {
    if (flag == '') {
      return null;
    }

    if (showNickname && index == 0) {
      return LeadingText(start: 0, flag: flag);
    }

    if (isStart(flag, ImageText.flag)) {
      return ImageText(textStyle,
          start: index! - (ImageText.flag.length - 1), size: emojiSize);
    }
    return null;
  }
}
