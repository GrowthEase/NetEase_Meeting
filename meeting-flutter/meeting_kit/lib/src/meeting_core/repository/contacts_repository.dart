// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class ContactsRepository {
  /// 通讯录搜索
  static Future<NEResult<List<NEContact>>> searchContacts(
      String? name, String? phoneNumber, int? pageSize, int? pageNum) {
    return HttpApiHelper._searchContacts(name, phoneNumber, pageSize, pageNum);
  }

  /// 通讯录用户信息获取, userUuids最大长度50
  static Future<NEResult<NEContactsInfoResult>> getContactsInfo(
      List<String> userUuids) {
    return HttpApiHelper._getContactsInfo(userUuids);
  }
}
