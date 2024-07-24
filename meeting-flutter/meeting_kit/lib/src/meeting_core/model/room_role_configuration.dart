// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 会议角色限制数据，上行参数，包括角色最大数量、是否进行账号限制以及限制账号列表
class NEMeetingRoleConfiguration {
  /// 角色身份RoleType，1成员，2主持人，3管理员，4隐藏
  /// [RoleType]
  late int roleType;

  ///该类型的角色允许的在会最大人数
  late int maxCount;

  ///是否采用限制成员 true为限制，限制情况下只有accountIds才能进入会议
  bool _accountIdRestrict = false;

  ///该类型的角色限制可以参加会议的成员列表
  List<String>? accountIds;

  NEMeetingRoleConfiguration({
    required this.roleType,
    this.maxCount = 0,
    this.accountIds,
  }) {
    if (accountIds != null) {
      _accountIdRestrict = true;
    }
  }

  Map toJson() => {
        'roleType': roleType,
        if (maxCount > 0) 'maxCount': maxCount,
        'accountIdRestrict': _accountIdRestrict,
        if (accountIds != null)
          'accountIds':
              accountIds?.map((e) => e.toString()).toList(growable: false),
      };

  static NEMeetingRoleConfiguration fromJson(Map<dynamic, dynamic> map) {
    return NEMeetingRoleConfiguration(
        roleType: (map['roleType'] ?? RoleType.normal) as int,
        maxCount: (map['maxCount'] ?? 0) as int,
        accountIds: (map['accountIds'] as List?)?.cast<String>());
  }
}
