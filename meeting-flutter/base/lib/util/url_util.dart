// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class UrlUtil{

  static const paramMeetingId = 'meetingid';
  static const paramSSOToken = 'ssoToken';
  static const paramAppKey = 'appKey';

  static String? getParamValue(String uri, String key){
    Uri deepLink = Uri.dataFromString(uri);
    String? value;
    deepLink.queryParameters.forEach((k, v) {
      if (k == key) {
        value = v;
      }
    });
    return value;
  }
}