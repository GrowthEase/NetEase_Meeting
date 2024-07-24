// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class AuthCodeModel {
  /// 授权码
  final String authCode;

  AuthCodeModel(this.authCode);

  factory AuthCodeModel.fromMap(Map map) {
    return AuthCodeModel(map['authCode'] as String);
  }

  Map toJson() => {'authCode': authCode};
}
