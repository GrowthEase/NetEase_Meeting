// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEContactsServiceImpl extends NEContactsService {
  static final _NEContactsServiceImpl _instance = _NEContactsServiceImpl._();

  factory _NEContactsServiceImpl() => _instance;

  _NEContactsServiceImpl._();

  @override
  Future<NEResult<NEContactsInfoResult>> getContactsInfo(
      List<String> userUuids) {
    return ContactsRepository.getContactsInfo(userUuids);
  }

  @override
  Future<NEResult<List<NEContact>>> searchContactListByName(
      String? name, int? pageSize, int? pageNum) {
    return ContactsRepository.searchContacts(name, null, pageSize, pageNum);
  }

  @override
  Future<NEResult<List<NEContact>>> searchContactListByPhoneNumber(
      String? phoneNumber, int? pageSize, int? pageNum) {
    return ContactsRepository.searchContacts(
        null, phoneNumber, pageSize, pageNum);
  }
}
