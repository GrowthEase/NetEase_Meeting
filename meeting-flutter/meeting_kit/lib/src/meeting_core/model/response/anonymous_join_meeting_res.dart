// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class AnonymousLoginInfo {
  ///im AppKey
  final String imKey;

  ///Rtc AppKey
  final String rtcKey;

  /// userUuid
  final String userUuid;

  /// userToken
  final String userToken;

  /// im token
  final String imToken;

  const AnonymousLoginInfo({
    required this.imKey,
    required this.rtcKey,
    required this.userUuid,
    required this.userToken,
    required this.imToken,
  });

  factory AnonymousLoginInfo.fromMap(Map map) {
    return AnonymousLoginInfo(
      imToken: map['imToken'] as String,
      imKey: map['imKey'] as String,
      rtcKey: map['rtcKey'] as String,
      userUuid: map['userUuid'] as String,
      userToken: map['userToken'] as String,
    );
  }
}
