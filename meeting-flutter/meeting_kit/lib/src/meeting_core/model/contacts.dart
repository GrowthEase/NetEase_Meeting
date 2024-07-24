// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class NEContact {
  /// 用户id
  final String userUuid;

  /// 用户名
  final String? name;

  /// 用户头像
  final String? avatar;

  /// 用户部门信息
  final String? dept;

  /// 用户手机号
  final String? phoneNumber;

  NEContact({
    required this.userUuid,
    this.name,
    this.avatar,
    this.dept,
    this.phoneNumber,
  });

  factory NEContact.fromJson(Map json) {
    return NEContact(
      userUuid: json['userUuid'],
      name: json['name'],
      avatar: json['avatar'],
      dept: json['dept'],
      phoneNumber: json['phoneNumber'],
    );
  }

  /// toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userUuid'] = userUuid;
    data['name'] = name;
    data['avatar'] = avatar;
    data['dept'] = dept;
    data['phoneNumber'] = phoneNumber;
    return data;
  }
}

///
/// 企业通讯录成员列表查询结果
///
class NEContactsInfoResult {
  ///
  /// 查询到的成员列表
  ///
  final List<NEContact> foundList;

  ///
  /// 未查询到的成员列表
  ///
  final List<String> notFoundList;

  NEContactsInfoResult(this.foundList, this.notFoundList);

  Map toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['foundList'] = foundList.map((e) => e.toJson()).toList();
    data['notFoundList'] = notFoundList;
    return data;
  }

  factory NEContactsInfoResult._fromServer(Map json) {
    List<NEContact> foundList = [];
    List<String> notFoundList = [];
    if (json['meetingAccountListResp'] != null) {
      List list = json['meetingAccountListResp'] as List;
      if (list.isNotEmpty) {
        foundList = list.map((e) {
          assert(e is Map);
          final item = e as Map<String, dynamic>;
          return NEContact.fromJson(item);
        }).toList();
      }
    }
    if (json['notFindUserUuids'] != null) {
      List list = json['notFindUserUuids'] as List;
      if (list.isNotEmpty) {
        notFoundList = list.map((e) {
          assert(e is String);
          return e as String;
        }).toList();
      }
    }
    return NEContactsInfoResult(foundList, notFoundList);
  }
}
