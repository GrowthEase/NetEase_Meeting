// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class NEContact {
  /// 账号id
  final int? accountId;

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
    this.accountId,
    required this.userUuid,
    this.name,
    this.avatar,
    this.dept,
    this.phoneNumber,
  });

  factory NEContact.fromJson(Map json) {
    return NEContact(
      accountId: json['accountId'],
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
    data['accountId'] = accountId;
    data['userUuid'] = userUuid;
    data['name'] = name;
    data['avatar'] = avatar;
    data['dept'] = dept;
    data['phoneNumber'] = phoneNumber;
    return data;
  }
}

class NEContactsInfoResponse {
  final List<NEContact> meetingAccountListResp;
  final List<String> notFindUserUuids;

  NEContactsInfoResponse(this.meetingAccountListResp, this.notFindUserUuids);

  factory NEContactsInfoResponse.fromJson(Map json) {
    List<NEContact> meetingAccountListResp = [];
    List<String> notFindUserUuids = [];
    if (json['meetingAccountListResp'] != null) {
      List list = json['meetingAccountListResp'] as List;
      if (list.isNotEmpty) {
        meetingAccountListResp = list.map((e) {
          assert(e is Map);
          final item = e as Map<String, dynamic>;
          return NEContact.fromJson(item);
        }).toList();
      }
    }
    if (json['notFindUserUuids'] != null) {
      List list = json['notFindUserUuids'] as List;
      if (list.isNotEmpty) {
        notFindUserUuids = list.map((e) {
          assert(e is String);
          return e as String;
        }).toList();
      }
    }
    return NEContactsInfoResponse(meetingAccountListResp, notFindUserUuids);
  }
}
