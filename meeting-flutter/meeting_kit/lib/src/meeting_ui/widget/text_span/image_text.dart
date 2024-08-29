// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class ImageText extends SpecialText {
  ImageText(TextStyle? textStyle,
      {this.start, SpecialTextGestureTapCallback? onTap, required this.size})
      : super(
          ImageText.flag,
          ']',
          textStyle,
          onTap: onTap,
        );

  static const String flag = '[';
  final int? start;
  final double size;

  @override
  InlineSpan finishText() {
    ///content already has endflag '/'
    final String text = toString();

    if (NEMeetingEmojis.hasEmoji(text))
      return ExtendedWidgetSpan(
          start: start!,
          actualText: text,
          child: NEMeetingEmojis.assetImage(
            text,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ));
    return TextSpan(text: toString(), style: textStyle);
  }
}
