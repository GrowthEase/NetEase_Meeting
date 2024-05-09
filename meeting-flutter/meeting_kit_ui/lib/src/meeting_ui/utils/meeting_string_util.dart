// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class StringUtil {
  static final String _tag = 'StringUtil';
  static final String regexLetterOrDigitalLimit = r'[0-9a-zA-Z]';
  static final String regexZh = r'[\u4e00-\u9fff]';
  static final String regexLetterOrDigitalOrZhLimit =
      r'[0-9a-zA-Z\u4e00-\u9fff]';
  static final String regexLetterOrDigital = "^[0-9a-zA-Z]*\$";
  static final String regexLetterOrDigitalOrZh =
      "^[0-9a-zA-Z\\u4e00-\\u9fff]*\$";

  static final zhRegex = RegExp(regexZh);
  static final letterRegex = RegExp(r'[a-zA-Z]');
  static final digitRegex = RegExp(r'[0-9]');
  static final emojiRegex = RegExp(
      r'\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]');

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
    return meetingHex.hex.encode(digest.bytes);
  }

  // 加盐md5
  static String pwdMD5(String input) {
    return dartMD5('$input@163');
  }

  static bool isChinese(String value) {
    return zhRegex.hasMatch(value);
  }

  static bool isLetter(String value) {
    return letterRegex.hasMatch(value);
  }

  static bool isDigit(String value) {
    return digitRegex.hasMatch(value);
  }

  /// 是否超过传入value，true为超过，false为没有超过
  static bool isExceedLimit(String value, int lengthMax) {
    int len = calculateStrLength(value);
    return len > lengthMax;
  }

  static bool isEmoji(String character) {
    if (character.runes.length > 1) {
      return true; // 表情符号的情况
    } else {
      var firstRune = character.runes.first;
      // 在 Unicode 中，一些表情符号的编码范围是 0x1F300 到 0x1F6FF
      // 你可以根据你的需求调整这个范围
      return (firstRune >= 0x1F300 && firstRune <= 0x1F6FF);
    }
  }

  static int calculateCharacterLength(int charCode, int len) {
    String char = String.fromCharCode(charCode);
    if (!isEmoji(char)) {
      if (isChinese(char)) {
        len += 2;
      } else {
        len += 1;
      }
    } else {
      len += 4;
    }
    return len;
  }

  static int calculateStrLength(String? input) {
    int len = 0;
    if (input == null || input.isEmpty) return 0;
    for (var character in input.runes) {
      len = calculateCharacterLength(character, len);
    }
    return len;
  }

  static int calculateMaxLengthIndex(String newValue, int maxLength) {
    var index = 0;
    var len = 0;
    for (var character in newValue.runes) {
      len = calculateCharacterLength(character, len);
      if (len > maxLength) {
        break;
      }
      index += 1;
    }
    return index;
  }

  /*
  * Base64加密
  */
  static String encodeBase64(String data) {
    var content = utf8.encode(data);
    var digest = base64Encode(content);
    return digest;
  }

  /*
  * Base64解密
  */
  static String decodeBase64(String data) {
    return String.fromCharCodes(base64Decode(data));
  }

  static String truncate(String str) {
    Characters characters = str.characters;
    return '${characters.take(calculateMaxLengthIndex(str, 20)).toString()}${((str.length) > 20 ? "..." : "")}';
    // return '${str.substring(0, min(str.length, 10))}${((str.length) > 10 ? "..." : "")}';
  }

  static String truncateEx(String str) {
    Characters characters = str.characters;
    return characters.take(calculateMaxLengthIndex(str, 20)).toString();
  }

  static String hideMobileNumMiddleFour(String phoneNumber) {
    if (phoneNumber.length != 11) {
      Alog.d(
          tag: _tag,
          moduleName: _moduleName,
          content:
              'hideMobileNumMiddleFour, phoneNumber length is not 11, phoneNumber = $phoneNumber');
      return phoneNumber;
    }
    String maskedNumber = phoneNumber.substring(0, 3) +
        '****' +
        phoneNumber.substring(7); // 显示前三位和后四位，中间四位显示****
    return maskedNumber;
  }
}
