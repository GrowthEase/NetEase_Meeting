// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:netease_common/netease_common.dart';

class PasswordUtils {
  static const minPasswordLen = 6;
  static const maxPasswordLen = 18;
  static final passwordTextInputFormatters = [
    LengthLimitingTextInputFormatter(maxPasswordLen),

    /// visible ASCII characters
    FilteringTextInputFormatter.allow(RegExp(r'[\x20-\x7E]')),
  ];

  static bool isLengthValid(String password) {
    return password.length >= minPasswordLen &&
        password.length <= maxPasswordLen;
  }

  // 6 - 18 位 大小写字母 + 数字组合
  static bool isValid(String password) {
    return isLengthValid(password) &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  static String hash(String password) {
    return '$password@yiyong.im'.md5;
  }
}
