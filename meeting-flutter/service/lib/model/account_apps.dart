// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class AccountApps {
  late final String _accountId;
  late final List<Apps> _apps;

  String get accountId => _accountId;

  List<Apps> get apps => _apps;

  AccountApps({required String accountId, required List<Apps> apps}) {
    _accountId = accountId;
    _apps = apps;
  }

  AccountApps.fromJson(Map json) {
    _accountId = json['accountId'] as String;
    if (json['apps'] != null) {
      _apps = [];
      json['apps'].forEach((v) {
        _apps.add(Apps.fromJson(v as Map));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['accountId'] = _accountId;
    // if (_apps != null) {
      map['apps'] = _apps.map((v) => v.toJson()).toList();
    // }
    return map;
  }
}

class Apps {
  final String _appKey;
  final String _appName;

  String get appKey => _appKey;

  String get appName => _appName;

  Apps.fromJson(Map json):
    _appKey = json['appKey'] as String,
    _appName = json['appName'] as String;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['appKey'] = _appKey;
    map['appName'] = _appName;
    return map;
  }
}
