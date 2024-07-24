// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:fluttermodule/meeting_kit_bridge.dart';
import 'package:fluttermodule/src/callback.dart';
import 'package:fluttermodule/src/service.dart';

class ContactsServiceBridge extends Service {
  final MeetingKitBridge meetingKitBridge;

  ContactsServiceBridge.asService(this.meetingKitBridge);
  @override
  String get name => 'contacts';

  String mapMethodName(String method) => name + '.' + method;

  @override
  Future handleCall(String method, arguments) {
    switch (method) {
      case 'getContactsInfo':
        return _handleGetContactsInfo(arguments);
      case 'searchContactListByPhoneNumber':
        return _handleSearchContactListByPhoneNumber(arguments);
      case 'searchContactListByName':
        return _handleSearchContactListByName(arguments);
    }
    return super.handleCall(method, arguments);
  }

  Future _handleGetContactsInfo(arguments) {
    return meetingKitBridge.contactsService
        .getContactsInfo(
            (arguments as List? ?? []).whereType<String>().toList())
        .then((value) {
      return Callback.wrap('getContactsInfo', value.code,
              msg: value.msg, data: value.data?.toJson())
          .result;
    });
  }

  Future<Map> _handleSearchContactListByPhoneNumber(arguments) async {
    assert(arguments is Map);
    final phoneNumber = arguments['phoneNumber'];
    final pageSize = arguments['pageSize'] as int? ?? 20;
    final pageNum = arguments['pageNum'] as int? ?? 1;
    return meetingKitBridge.contactsService
        .searchContactListByPhoneNumber(phoneNumber, pageSize, pageNum)
        .then((value) {
      final contacts = value.data?.map((e) => e.toJson()).toList();
      return Callback.wrap('searchContactListByPhoneNumber', value.code,
              msg: value.msg, data: contacts)
          .result;
    });
  }

  Future _handleSearchContactListByName(arguments) {
    assert(arguments is Map);
    final name = arguments['name'];
    final pageSize = arguments['pageSize'] as int? ?? 20;
    final pageNum = arguments['pageNum'] as int? ?? 1;
    return meetingKitBridge.contactsService
        .searchContactListByName(name, pageSize, pageNum)
        .then((value) {
      final contacts = value.data?.map((e) => e.toJson()).toList();
      return Callback.wrap('searchContactListByName', value.code,
              msg: value.msg, data: contacts)
          .result;
    });
  }
}
