
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// accountId : "xx"
/// accountToken : "xxx"
/// appKey : "xx"

class ParseSSOToken {
  late final String _accountId;
  late final String _accountToken;
  late final String _appKey;

  String get accountId => _accountId;
  String get accountToken => _accountToken;
  String get appKey => _appKey;

  ParseSSOToken.fromJson(Map map) {
    _accountId = map['accountId'] as String;
    _accountToken = map['accountToken'] as String;
    _appKey = map['appKey'] as String;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['accountId'] = _accountId;
    map['accountToken'] = _accountToken;
    map['appKey'] = _appKey;
    return map;
  }

}