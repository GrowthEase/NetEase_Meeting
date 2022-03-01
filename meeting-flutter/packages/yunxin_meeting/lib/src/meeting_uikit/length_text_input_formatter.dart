// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_uikit;

class NEMeetingLengthLimitingTextInputFormatter
    extends LengthLimitingTextInputFormatter {
  NEMeetingLengthLimitingTextInputFormatter(int maxLength) : super(maxLength);

  static final regexZh = RegExp(r'[\u4e00-\u9fa5]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    int newValueLength = calculateStrLength(newValue.text);
    int oldValueLength = calculateStrLength(oldValue.text);
    if (maxLength != null && maxLength! > 0 && newValueLength > maxLength!) {
      // If already at the maximum and tried to enter even more, keep the old
      // value.
      if (oldValueLength == maxLength) {
        return oldValue;
      }
      return truncate(newValue, calculateMaxLength(newValue.text, maxLength!));
    }
    return newValue;
  }

  TextEditingValue truncate(TextEditingValue value, int maxLength) {
    final CharacterRange iterator = CharacterRange(value.text);
    if (calculateStrLength(value.text) > maxLength) {
      iterator.expandNext(maxLength);
    }
    final String truncated = iterator.current;
    return TextEditingValue(
      text: truncated,
      selection: value.selection.copyWith(
        baseOffset: math.min(value.selection.start, truncated.length),
        extentOffset: math.min(value.selection.end, truncated.length),
      ),
      composing: TextRange.empty,
    );
  }

  int calculateMaxLength(String newValue, int maxLength) {
    int index = 0;
    int len = 0;
    for (int i = 0; i < newValue.length; i++) {
      if (isChinese(newValue[i])) {
        len += 2;
      } else if (TextUtils.isLetterOrDigital(newValue[i])) {
        len += 1;
      }
      if (len > maxLength) {
        break;
      }
      index += 1;
    }
    return index;
  }

  static int calculateStrLength(String? input) {
    int len = 0;
    if (input == null || input.isEmpty) return 0;
    for (int i = 0; i < input.length; i++) {
      if (isChinese(input[i])) {
        len += 2;
      } else if (TextUtils.isLetterOrDigital(input[i])) {
        len += 1;
      }
    }
    return len;
  }

  static bool isChinese(String value) {
    return regexZh.hasMatch(value);
  }

}
