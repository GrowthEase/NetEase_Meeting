// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

class _NEMeetingAccountServiceImpl extends NEMeetingAccountService {
  static const _tag = '_NEAccountServiceImpl';
  static final _NEMeetingAccountServiceImpl _instance = _NEMeetingAccountServiceImpl._();

  factory _NEMeetingAccountServiceImpl() => _instance;

  _NEMeetingAccountServiceImpl._();

  final NEAuthService _accountService = NERoomKit.instance.getAuthService();

  @override
  NEAccountInfo? getAccountInfo() {
    return _accountService.getAccountInfo();
  }
}
