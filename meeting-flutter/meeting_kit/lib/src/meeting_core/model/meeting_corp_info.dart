// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 应用SSO登录等级
enum NEMeetingCorpSSOLevel {
  /// 未开启SSO登录
  kNone,

  /// 可选SSO登录
  kOptional,

  /// 强制SSO登录
  kForce,
}

final class NEMeetingCorpInfo {
  final String appKey;
  final String corpName;
  final String? corpCode;
  final NEMeetingCorpSSOLevel? ssoLevel;
  final List<NEMeetingIdpInfo> idpList;

  NEMeetingCorpInfo(
    this.appKey,
    this.corpName,
    this.idpList, {
    this.corpCode,
    this.ssoLevel,
  });

  NEMeetingCorpInfo.fromJson(Map map, {this.corpCode})
      : appKey = map['appKey'],
        corpName = map['appName'],
        ssoLevel = NEMeetingCorpSSOLevel.values[(map['ssoLevel'] ?? 0) as int],
        idpList = (map['idpList'] as List? ?? [])
            .map((e) => NEMeetingIdpInfo.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() {
    return {
      'appKey': appKey,
      'corpName': corpName,
      'corpCode': corpCode,
      'ssoLevel': ssoLevel?.index,
      'idpList': idpList.map((e) => e.toJson()).toList(),
    };
  }

  /// 是否强制 sso 登录
  bool get isForceSSOLogin =>
      ssoLevel == NEMeetingCorpSSOLevel.kForce && idpList.isNotEmpty;
}

final class NEMeetingIdpInfo {
  static const int _typeOAuth2 = 1;

  final int id;
  final int type;
  final String? name;

  NEMeetingIdpInfo(this.id, this.type, this.name);

  NEMeetingIdpInfo.fromJson(Map map)
      : id = map['id'],
        type = map['type'],
        name = map['name'];

  bool get isOAuth2 => type == _typeOAuth2;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
    };
  }
}
