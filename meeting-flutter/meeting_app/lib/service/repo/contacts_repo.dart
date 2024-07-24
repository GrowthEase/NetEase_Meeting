// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_kit/meeting_kit.dart';

class ContactsRepo {
  static final _singleton = ContactsRepo._internal();

  factory ContactsRepo() => _singleton;

  final _contactsCache = <String, Completer<NEContact?>>{};
  final _pendingRequest = <String>{};
  Timer? _timer;

  ContactsRepo._internal() {
    Timer.periodic(
      Duration(minutes: 30),
      (timer) {
        _contactsCache.removeWhere((key, value) => value.isCompleted);
      },
    );
  }

  Future<NEContact?> getContact(String userId) async {
    if (_contactsCache.containsKey(userId)) {
      return _contactsCache[userId]!.future;
    }
    final completer = Completer<NEContact>();
    _contactsCache[userId] = completer;
    _pendingRequest.add(userId);
    _scheduleFetchContacts();
    return completer.future;
  }

  void _scheduleFetchContacts() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 1), _realFetchContacts);
  }

  void _realFetchContacts() {
    final pendings = List.of(_pendingRequest);
    _pendingRequest.clear();
    pendings.slices(20).forEach((userList) {
      NEMeetingKit.instance
          .getContactsService()
          .getContactsInfo(userList)
          .then((result) {
        if (result.isSuccess()) {
          final data = result.nonNullData;
          for (final contact in data.foundList) {
            _contactsCache[contact.userUuid]?.complete(contact);
          }
          for (final userId in data.notFoundList) {
            _contactsCache[userId]?.complete(null);
          }
        } else {
          for (final userId in userList) {
            _contactsCache.remove(userId)?.complete(null);
          }
        }
      });
    });
  }
}
