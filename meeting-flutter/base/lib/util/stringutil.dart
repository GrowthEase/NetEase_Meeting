// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class StringUtil {
  static final String regexLetterOrDigitalLimit = r'[0-9a-zA-Z]';
  static final String regexZh = r'[\u4e00-\u9fa5]';
  static final String regexLetterOrDigitalOrZhLimit =
      r'[0-9a-zA-Z\u4e00-\u9fa5]';
  static final String regexLetterOrDigital = "^[0-9a-zA-Z]*\$";
  static final String regexLetterOrDigitalOrZh =
      "^[0-9a-zA-Z\\u4e00-\\u9fa5]*\$";

  static bool isLetterOrDigital(String? input) {
    if (input == null || input.isEmpty) return false;
    return new RegExp(regexLetterOrDigital).hasMatch(input);
  }

  static bool isLetterOrDigitalOrZh(String? input) {
    if (input == null || input.isEmpty) return false;
    return new RegExp(regexLetterOrDigitalOrZh).hasMatch(input);
  }

  static String dartMD5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  // 加盐md5
  static String pwdMD5(String input) {
    return dartMD5('$input@163');
  }

  static bool isChinese(String value) {
    return RegExp(regexZh).hasMatch(value);
  }

  // static bool isLetterOrDigital(String value) {
  //   return RegExp(regexLetterOrDigitalLimit).hasMatch(value);
  // }

  /// 是否超过传入value，true为超过，false为没有超过
  static bool isExceedLimit(String value, int lengthMax) {
    int len = calculateStrLength(value);
    return len > lengthMax;
  }

  static int calculateStrLength(String? input) {
    int len = 0;
    if (input == null || input.isEmpty) return 0;
    for (int i = 0; i < input.length; i++) {
      if (isChinese(input[i])) {
        len += 2;
      } else if (isLetterOrDigital(input[i])) {
        len += 1;
      }
    }
    return len;
  }

  /*
  * Base64加密
  */
  static String encodeBase64(String data){
    var content = utf8.encode(data);
    var digest = base64Encode(content);
    return digest;
  }

  /*
  * Base64解密
  */
  static String decodeBase64(String data){
    return String.fromCharCodes(base64Decode(data));
  }
}
