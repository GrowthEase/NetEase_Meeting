// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class AppUtil {
  static bool isDebug() {
    return bool.fromEnvironment('dart.vm.product') != true;
  }

  static bool isURL(String urlString) {
    // 正则表达式判断是否是URL
    RegExp urlRegex = RegExp(
      r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );
    return urlRegex.hasMatch(urlString);
  }

  static Map<String, String> parseURLParameters(String urlString) {
    Uri uri = Uri.parse(urlString);
    return uri.queryParameters;
  }
}
