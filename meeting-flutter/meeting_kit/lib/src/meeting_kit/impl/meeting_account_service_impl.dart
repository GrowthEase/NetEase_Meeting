// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEMeetingAccountServiceImpl extends NEMeetingAccountService {
  static final _NEMeetingAccountServiceImpl _instance =
      _NEMeetingAccountServiceImpl._();

  factory _NEMeetingAccountServiceImpl() => _instance;

  _NEMeetingAccountServiceImpl._() {
    HttpHeaderRegistry().addContributor(() {
      return getAccountInfo().guard((value) => {
                'user': value.userUuid,
                'token': value.userToken,
              }) ??
          const {};
    });
  }

  NEAccountInfo? _accountInfo;
  bool _anonymous = false;

  @override
  NEAccountInfo? getAccountInfo() {
    return _accountInfo;
  }

  @override
  _setAccountInfo(NEAccountInfo? accountInfo, [bool anonymous = false]) {
    this._accountInfo = accountInfo;
    this._anonymous = anonymous;
  }

  @override
  bool get _isAnonymous => _anonymous;
}
