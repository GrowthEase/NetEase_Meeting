// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class UrlUtil {
  static const paramMeetingId = 'meetingid';
  static const paramUserUuid = 'userUuid';
  static const paramUserToken = 'userToken';
  static const paramAppId = 'appId';

  static String? getParamValue(String uri, String key) {
    var deepLink = Uri.dataFromString(uri);
    String? value;
    deepLink.queryParameters.forEach((k, v) {
      if (k == key) {
        value = v;
      }
    });
    return value;
  }
}
