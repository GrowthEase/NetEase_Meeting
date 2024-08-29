// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class LeadingText extends SpecialText {
  LeadingText(
      {required this.flag, this.start, SpecialTextGestureTapCallback? onTap})
      : super(
          flag,
          LeadingText.leadingEndFlag,
          null,
          onTap: onTap,
        );

  final String flag;
  static const String leadingEndFlag = '</>';
  final int? start;

  @override
  InlineSpan finishText() {
    final text = toString().removeSuffix(leadingEndFlag);
    return TextSpan(
        text: text,
        style: TextStyle(
          color: _UIColors.colorF29900,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.none,
        ));
  }
}
