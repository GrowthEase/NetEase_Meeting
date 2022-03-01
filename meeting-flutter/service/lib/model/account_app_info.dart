
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class AccountAppInfo {
  final String appKey;
  final String appName;
  final Edition edition;

  AccountAppInfo.fromJson(Map json) :
    appKey = json['appKey'] as String,
    appName = json['appName'] as String,
    edition = Edition.fromJson(json['edition'] as Map);

}

class Edition {
  final int type;
  final String name;
  final List<Feature> featureList;
  final int expireAt;
  final String? extra;

  Edition.fromJson(Map json)
      : type = json['type'] as int,
        name = json['name'] as String,
        featureList = ((json['functionList'] ?? []) as List)
            .map((e) => Feature.fromJson(e as Map))
            .toList(),
        expireAt = (json['expireAt'] ?? 0) as int,
        extra = json['extra'] as String?;

}

class Feature {
  final String code;
  final String description;
  final String? value;
  final int? status;

  Feature.fromJson(Map json):
    code = json['code'] as String,
    description = json['description'] as String,
    value = json['value'] as String?,
    status = json['status'] as int?;

}