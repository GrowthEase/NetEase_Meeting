// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class TVInfo {

  final String accountId;

  final String appKey;

  final TVInfoExtra extra;

  TVInfo(this.accountId, this.appKey, this.extra);

  static TVInfo fromJson(Map map) {
    // if (map == null) {
    //   return null;
    // }
    return TVInfo(map['accountId'] as String, map['appKey'] as String, TVInfoExtra.fromJson(map['extra'] as Map));
  }

}

class TVInfoExtra{
  final String tvProtocolVersion;

  TVInfoExtra(this.tvProtocolVersion);

  static TVInfoExtra fromJson(Map map) {
    // if (map == null) {
    //   return null;
    // }
    return TVInfoExtra(map['tvProtocolVersion'] as String);
  }
}
