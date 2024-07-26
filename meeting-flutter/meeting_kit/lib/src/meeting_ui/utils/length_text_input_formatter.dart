// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingLengthLimitingTextInputFormatter
    extends LengthLimitingTextInputFormatter {
  MeetingLengthLimitingTextInputFormatter(int maxLength) : super(maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    var newValueLength = StringUtil.calculateStrLength(newValue.text);
    var oldValueLength = StringUtil.calculateStrLength(oldValue.text);
    if (maxLength != null && maxLength! > 0 && newValueLength > maxLength!) {
      // If already at the maximum and tried to enter even more, keep the old
      // value.
      if (oldValueLength == maxLength) {
        return oldValue;
      }
      return truncate(newValue,
          StringUtil.calculateMaxLengthIndex(newValue.text, maxLength!));
    }
    return newValue;
  }

  TextEditingValue truncate(TextEditingValue value, int maxLength) {
    final iterator = CharacterRange(value.text);
    if (StringUtil.calculateStrLength(value.text) > maxLength) {
      iterator.expandNext(maxLength);
    }
    final truncated = iterator.current;
    return TextEditingValue(
      text: truncated,
      selection: value.selection.copyWith(
        baseOffset: min(value.selection.start, truncated.length),
        extentOffset: min(value.selection.end, truncated.length),
      ),
      composing: TextRange.empty,
    );
  }
}
