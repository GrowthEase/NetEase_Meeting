// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/stringutil.dart';
import 'package:flutter/services.dart';
import 'package:characters/characters.dart';

import 'dart:math' as math;

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
      return truncate(newValue, calculateMaxLength(newValue.text, maxLength!));
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
        baseOffset: math.min(value.selection.start, truncated.length),
        extentOffset: math.min(value.selection.end, truncated.length),
      ),
      composing: TextRange.empty,
    );
  }

  int calculateMaxLength(String newValue, int maxLength) {
    var index = 0;
    var len = 0;
    for (var i = 0; i < newValue.length; i++) {
      if (StringUtil.isChinese(newValue[i])) {
        len += 2;
      } else if (StringUtil.isLetterOrDigital(newValue[i])) {
        len += 1;
      }
      if (len > maxLength) {
        break;
      }
      index += 1;
    }
    return index;
  }
}
